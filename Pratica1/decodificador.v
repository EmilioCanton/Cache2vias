module decodificador (
input [7:0] entrada, 
output reg [6:0] saida);

always @ (*) 
begin 
		case (entrada)
		
					 0: saida <= 7'b1000000; // 0
					 1: saida <= 7'b1111001; // 1
					 2: saida <= 7'b0100100; // 2
					 3: saida <= 7'b0110000; // 3 0110000
					 4: saida <= 7'b0011001; // 4 0011001
					 5: saida <= 7'b0010010; // 5 0010010
					 6: saida <= 7'b0000010; // 6 0000010
					 7: saida <= 7'b1111000; // 7 1111000
					 8: saida <= 7'b0000000; // 8 0000000
					 9: saida <= 7'b0011000; // 9 0011000
			      10: saida = 7'b0001000;      // A
					11: saida = 7'b0000011;      // B
					12: saida = 7'b1000110;      // C
					13: saida = 7'b0100001;      // D
					14: saida = 7'b0000110;      // E
					15: saida = 7'b0001110;      // F
		
			default : saida <= 7'b1111111;
		endcase
end 

endmodule 