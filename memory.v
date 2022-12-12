/*
   CS/ECE 552 Spring '20
  
   Filename        : memory.v
   Description     : This module contains all components in the Memory stage of the 
                     processor.
*/
module memory (ALU_result, read_data_in, MemRead, MemWrite,  read_data_out, clk, rst, createdump, err);

	input [15:0] ALU_result, read_data_in;
	input MemRead, MemWrite, clk, rst;
	input createdump;

	output [15:0] read_data_out;
	output err;

	wire memReadorWrite;

	assign memReadorWrite = MemWrite | MemRead;
	
	// For now
	assign err = 1'b0;

	memory2c mem0(.data_out(read_data_out), .data_in(read_data_in), .addr(ALU_result), .enable(memReadorWrite), .wr(MemWrite), 
		.createdump(createdump), .clk(clk), .rst(rst));
   
endmodule
