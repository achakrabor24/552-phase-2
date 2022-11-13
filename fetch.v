/*
   CS/ECE 552 Spring '20
  
   Filename        : fetch.v
   Description     : This is the module for the overall fetch stage of the processor.
*/
module fetch(next_PC, clk, rst, PC_2, instruction, fetch_enable, createdump, err, PC);

	input [15:0] next_PC;
	input clk, rst, fetch_enable, createdump;
	output [15:0] PC, PC_2, instruction;
	output err; 

	wire dummy;
	wire [15:0] read_addr;

	reg_16b PC0(.Q(read_addr), .D(next_PC), .clk(clk), .rst(rst), .writeEn(fetch_enable)); 

	// Increment PC using CLA
	cla_16b cla0(.sum(PC_2), .c_out(dummy), .a(read_addr), .b(16'b0000_0000_0000_0010), .c_in(1'b0));

	// I-Mem
	memory2c mem0(.data_out(instruction), .data_in(16'b0), .addr(read_addr), .enable(fetch_enable), .wr(1'b0), .createdump(createdump),
	 .clk(clk), .rst(rst));

	// For now
	assign err = 1'b0;
	assign PC = read_addr;
   
endmodule
