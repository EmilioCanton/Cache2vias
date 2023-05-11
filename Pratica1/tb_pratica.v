module tb_pratica();

  reg clock;
  reg [2:0] tag;
  reg [1:0] index;
  reg [2:0] data_in;
  reg read;
  reg write;
  wire hit;
  wire miss;
  wire [2:0] data_out;
  wire dirty;
  wire valid;
  wire [1:0] lru;
  wire writeBack;
  wire way;
  wire [2:0] tag_before;

  // Instanciando o módulo cache_2way
  pratica cache (
    .clk(clock),
    .write(write),
    .read(read),
	 .tag_before(tag_before),
    .tag(tag),
    .index(index),
    .data_in(data_in),
    .hit(hit),
    .miss(miss),
    .data_out(data_out),
    .dirty(dirty),
    .valid(valid),
    .lru(lru),
    .writeBack(writeBack),
    .way(way)
  );

  // Clock generator
  always begin
    #5 clock = ~clock;
  end

  // Test cases
  initial begin
    clock = 0;

    // Test case 1
    tag = 3'b100;
    index = 2'b00;
    read = 1;
    write = 0;
    #10;

    // Test case 2
    tag = 3'b101;
    index = 2'b00;
    read = 1;
    write = 0;
    #10;

    // Test case 3
    tag = 3'b100;
    index = 2'b00;
    read = 1;
    write = 0;
    #10;

    // Test case 4
    tag = 3'b000;
    index = 2'b01;
    read = 0;
    write = 1;
    data_in = 3'b111;
    #10;

    // Test case 5
    tag = 3'b111;
    index = 2'b10;
    read = 0;
    write = 1;
    data_in = 3'b010;
    #10;

    // Test case 6
    tag = 3'b110;
    index = 2'b10;
    read = 0;
    write = 1;
    data_in = 3'b011;
    #10;

    // Test case 7
    tag = 3'b001;
    index = 2'b10;
    read = 1;
    write = 0;
    #10;

  end
endmodule