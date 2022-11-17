/*
   CS/ECE 552 Spring '20
  
   Filename        : fetch.v
   Description     : This is the module for the overall fetch stage of the processor.
*/
module fetch(next_PC, clk, rst, PC_2, instruction, fetch_enable, createdump, err, PCSrc, PC_2_D, PC_2_I, branch, insert_nop, ALU_Result);

	input [15:0] next_PC, ALU_Result, PC_2_D, PC_2_I, branch, ALU_Result;
	input [2:0] PCSrc;
	input clk, rst, fetch_enable, createdump, insert_nop;
	output [15:0] PC_2, instruction;
	output err; 

	wire dummy;
	wire [15:0] read_addr, real_next_PC;

	reg_16b PC0(.Q(read_addr), .D(real_next_PC), .clk(clk), .rst(rst), .writeEn(fetch_enable)); 

	assign next_PC = (PCSrc == 3'b100) ? read_addr : (PCSrc == 2'b00) ? PC_2 : (PCSrc == 2'b01) ? ALU_Result : (PCSrc == 2'b10) ? PC_2_D : branch;

	// halt pc, send signal as output, make insert nop input 
	assign real_next_PC = (insert_nop) ? read_addr : next_PC; // read_addr = current PC

	// Increment PC using CLA
	cla_16b cla0(.sum(PC_2), .c_out(dummy), .a(read_addr), .b(16'b0000_0000_0000_0010), .c_in(1'b0));

	// I-Mem
	memory2c mem0(.data_out(instruction), .data_in(16'b0), .addr(read_addr), .enable(fetch_enable), .wr(1'b0), .createdump(createdump | insert_nop),
	 .clk(clk), .rst(rst));

	// assign next_PC = (PCSrc == 3'b100) ? PC : (PCSrc == 2'b00) ? PC_2 : (PCSrc == 2'b01) ? ALU_Result : (PCSrc == 2'b10) ? PC_2_D : branch;

	// For now
	assign err = 1'b0;
	// assign PC = read_addr;
   
endmodule
