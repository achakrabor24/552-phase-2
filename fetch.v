/*
   CS/ECE 552 Spring '20
  
   Filename        : fetch.v
   Description     : This is the module for the overall fetch stage of the processor.
*/
module fetch(PCSrc, PC_2_out, clk, rst, instruction, fetch_enable, createdump, err, is_branch, insert_nop, ALU_Result_in, 
		PC_2_I_in, PC_2_D_in, currPC, branch_is_taken, Stall);

	input [15:0] ALU_Result_in, PC_2_out, PC_2_I_in, PC_2_D_in;
	input [2:0] PCSrc;
	input clk, rst, fetch_enable, createdump, insert_nop, is_branch;

	output [15:0] instruction, currPC;
	output err, branch_is_taken, Stall; 

	wire dummy0, dummy1;
	wire [15:0] PC, next_PC, PC_2, branch, real_next_PC;

	// Increment to next instruction
	cla_16b cla0(.sum(PC_2), .c_out(dummy0), .a(PC), .b(16'b0000_0000_0000_0010), .c_in(1'b0));

	assign PC_2_out = PC_2; // So it can be used in decode to get PC+2+I and PC+2+D

	assign branch_is_taken = (is_branch == 1'b1 & ALU_Result_in == 1'b1);

	// Go to next instruction or branch
	assign branch = (branch_is_taken == 1'b1) ? PC_2_I_in: PC_2;


	// Find next_PC
	assign next_PC = (PCSrc == 2'b00) ? PC_2 : (PCSrc == 2'b01) ? ALU_Result_in : (PCSrc == 2'b10) ? PC_2_D_in : branch;


	wire Stall_temp;
	// Recycle PC if nop
	assign real_next_PC = (insert_nop == 1'b1 | Stall_temp == 1'b1 ) ? PC: next_PC;
	
	
	// Program counter register
	reg_16b PC0(.Q(PC), .D(real_next_PC), .clk(clk), .rst(rst), .writeEn(fetch_enable)); 


	// I-Mem
	// memory2c_align mem0(.data_out(instruction), .data_in(16'b0), .addr(PC), .enable(fetch_enable), .wr(1'b0), .createdump(createdump), .clk(clk), .rst(rst), .err(err));
	
	// New I-Mem
	// CacheHit and Done are always 1 so leave disconnected
	stallmem mem0(

	// Outputs
	.DataOut(instruction), .Done(), .Stall(Stall_temp), .CacheHit(),

	// Inputs
	 .err(err), .Addr(PC), .DataIn(16'b0), .Rd(1'b1), .Wr(1'b0), .createdump(createdump), .clk(clk), .rst(rst));
	
	// pipeline error

	assign currPC = PC;

	assign Stall = Stall_temp;

	// For now
	// assign err = 1'b0;
   
endmodule
