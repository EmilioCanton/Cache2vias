module pratica(
clk, write, read,
 tag_before, tag, index, data_in,
 hit, miss, data_out, dirty, valid, lru,
 writeBack,way);
 
  //INPUTS:
  input clk, write, read;   
  input [2:0] tag;           
  input [1:0] index;         
  input [2:0] data_in;       

  //OUTPUTS:   
  output reg hit, miss;
  output reg way;
  output reg valid;
  output reg dirty;
  output reg writeBack;
  output reg [1:0] lru;
  output reg [2:0] tag_before;      
  output reg [2:0] data_out;   

  //CACHE IMPLEMENTATION MATRICES:
  reg [7:0] m_cache [3:0][1:0];
  reg m_dirty [3:0][1:0];
  reg m_lru [3:0][1:0];
  reg m_valid [3:0][1:0];
  
  initial begin
    //INITIALIZE MATRICES:
    //INITIALIZE CACHE DATA VALUES:
    m_cache[0][0] = 8'b10000001;
    m_cache[0][1] = 8'bzzz00010;
    m_cache[1][0] = 8'b00001011;
    m_cache[1][1] = 8'bzzz01100;
    m_cache[2][0] = 8'b10110101;
    m_cache[2][1] = 8'b11110110;
    m_cache[3][0] = 8'bzzz11zzz;
    m_cache[3][1] = 8'bzzz11zzz; 

    //INITIALIZE CACHE DIRTY VALUES:     
    m_dirty[0][0] = 1'b0;
    m_dirty[0][1] = 1'b0;
    m_dirty[1][0] = 1'b0;
    m_dirty[1][1] = 1'b0;
    m_dirty[2][0] = 1'b1;
    m_dirty[2][1] = 1'b0;
    m_dirty[3][0] = 1'bz;
    m_dirty[3][1] = 1'bz;

    //INITIALIZE CACHE LRU VALUES:
    m_lru[0][0] = 1'b0;
    m_lru[0][1] = 1'b0;
    m_lru[1][0] = 1'b1;
    m_lru[1][1] = 1'b0;
    m_lru[2][0] = 1'b0;
    m_lru[2][1] = 1'b1;
    m_lru[3][0] = 1'bz;
    m_lru[3][1] = 1'bz;

    //INITIALIZE CACHE VALID VALUES:
    m_valid[0][0] = 1'b0;
    m_valid[0][1] = 1'b0;
    m_valid[1][0] = 1'b1;
    m_valid[1][1] = 1'b0;
    m_valid[2][0] = 1'b1;
    m_valid[2][1] = 1'b1;
    m_valid[3][0] = 1'b0;
    m_valid[3][1] = 1'b0;
    
    //INITIALIZE OUTPUT VALUES:
    hit = 1'bx;
    miss = 1'bx;
    data_out = 3'bxxx;
    dirty = 1'bx;
    valid = 1'bx;
    lru = 2'bxx; 
    writeBack = 1'b0;
    way = 1'bx; 
  end
    
  //AUX:
  reg [1:0] idx_aux;
  reg [2:0] tag_aux;
  reg [2:0] datain_aux;
  reg wr_aux;
  reg writeBack_aux; // Aux WriteBack
  
  
  //PROCESS
  always @(posedge clk) begin
   idx_aux <= index;
	writeBack_aux <= 1'b0;
	//IN CASE OF A READ OPERATION:
   if(read) begin
    wr_aux = 1'b0;
    tag_aux = tag;
   end
   else begin
    wr_aux = 1'b1;
    tag_aux = tag;
    datain_aux = data_in;
   end
  end

  always @(negedge clk) begin
   writeBack_aux = 1'b0;
   if(wr_aux == 0) begin    
    //READ HIT VIA 0:
    if ((m_valid[idx_aux][0]) && (tag_aux == m_cache[idx_aux][0][7:5])) begin 
     hit = 1'b1;
     miss = 1'b0;
     m_lru[idx_aux][0] = 1'b1;
     m_lru[idx_aux][1] = 1'b0;
     tag_before = tag_aux;  
     way = 1'b0;
    end
    else begin
     //READ HIT VIA 1:
     if((m_valid[idx_aux][1]) && (tag_aux == m_cache[idx_aux][1][7:5])) begin
      hit = 1'b1;
      miss = 1'b0;
      m_lru[idx_aux][0] = 1'b0;
      m_lru[idx_aux][1] = 1'b1;
      tag_before = tag_aux; 
      way = 1'b1;
     end
     //READ MISS:
     else begin
       //READ MISS VIA 0:
      if(m_lru[idx_aux][0] <= m_lru[idx_aux][1]) begin
        hit = 1'b0;
        miss = 1'b1;
       m_lru[idx_aux][0] = 1'b1;
       m_lru[idx_aux][1] = 1'b0;
       tag_before = m_cache[idx_aux][0][7:5];
       m_cache[idx_aux][0][7:5] = tag_aux;
       m_valid[idx_aux][0] = 1'b1;
       way = 1'b0;
      end
      else begin
        //READ MISS VIA 1:
        hit = 1'b0;
        miss = 1'b1;
       m_lru[idx_aux][0] = 1'b0;
       m_lru[idx_aux][1] = 1'b1;
       tag_before = m_cache[idx_aux][1][7:5];
       m_cache[idx_aux][1][7:5] = tag_aux;
       m_valid[idx_aux][1] = 1'b1;
       way = 1'b1;
      end       
      //VERIFY DIRTY:      
       if(m_dirty[idx_aux][way] == 1'b1) begin
        //IF DIRTY=1, THEN ENABLE WRITEBACK AND UPDATE DIRTY IN CACHE (IF READ ACCESS):
			writeBack_aux = 1'b1;
			if (wr_aux == 0) begin
				m_dirty[idx_aux][way] = 1'b0;
			end
		  end
     end
    end
   end

   if(wr_aux == 1) begin 
    //WRITE HIT VIA 0:
    if ((m_valid[idx_aux][0]) && (tag_aux == m_cache[idx_aux][0][7:5])) begin 
     hit = 1'b1;
     miss = 1'b0;
     m_lru[idx_aux][0] = 1'b1;
     m_lru[idx_aux][1] = 1'b0;
     m_cache[idx_aux][0][2:0] = datain_aux;
     tag_before = tag_aux; 
     m_dirty[idx_aux][0] = 1'b1;   
     way = 1'b0;
    end
    else begin
     //WRITE HIT VIA 1:
     if((m_valid[idx_aux][1]) && (tag_aux == m_cache[idx_aux][1][7:5])) begin
      hit = 1'b1;
      miss = 1'b0;
      m_lru[idx_aux][0] = 1'b0;
      m_lru[idx_aux][1] = 1'b1;
       m_cache[idx_aux][1][2:0] = datain_aux;
       tag_before = tag_aux; 
       m_dirty[idx_aux][1] = 1'b1;
      way = 1'b1;
     end
     //WRITE MISS:
     else begin
       //WRITE MISS VIA 0:
      if(m_lru[idx_aux][0] <= m_lru[idx_aux][1]) begin
        hit = 1'b0;
        miss = 1'b1;
       m_lru[idx_aux][0] = 1'b1;
       m_lru[idx_aux][1] = 1'b0;
       m_cache[idx_aux][0][2:0] = datain_aux;
       tag_before = m_cache[idx_aux][0][7:5];
       m_cache[idx_aux][0][7:5] = tag_aux;
       m_valid[idx_aux][0] = 1'b1;
       way = 1'b0;
      end
      else begin
        //WRITE MISS VIA 1:
        hit = 1'b0;
        miss = 1'b1;
       m_lru[idx_aux][0] = 1'b0;
       m_lru[idx_aux][1] = 1'b1;
       m_cache[idx_aux][1][2:0] = datain_aux;
       tag_before = m_cache[idx_aux][1][7:5];
       m_cache[idx_aux][1][7:5] = tag_aux;
       m_valid[idx_aux][1] = 1'b1;
       way = 1'b1;
      end       
      //VERIFY DIRTY:      
       if(m_dirty[idx_aux][way] == 1'b1) begin
        //IF DIRTY=1, THEN ACTIVE WRITEBACK:
        writeBack_aux = 1'b1;
       end
       m_dirty[idx_aux][way] = 1'b1;
     end
    end
   end
   
   //UPDATE VALID OUTPUT:
   valid = m_valid[idx_aux][way];
   //UPDATE DIRTY OUTPUT:
   dirty = m_dirty[idx_aux][way];
   //UPDATE LRU OUTPUT:
   lru[0] = m_lru[idx_aux][1];
   lru[1] = m_lru[idx_aux][0];
   //OUTPUT DATA_OUT:
   data_out = m_cache[idx_aux][way][2:0];    
   writeBack <= writeBack_aux;
  end
endmodule
