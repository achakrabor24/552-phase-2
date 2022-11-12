module hazard(clk, rst, PCSrc, stall, FD_NOP, DE_NOP, EM_NOP, MW_NOP);

	input [1:0] PCSrc;
	input stall; // createdump 
	input clk, rst;

	output FD_NOP, DE_NOP, EM_NOP, MW_NOP;

// Branch detection for flushing
wire br_j_taken;
assign br_j_taken = ((PCSrc == 2'b10) | (PCSrc == 2'b11)) ? 1'b1: 1'b0;

// Stalling 

// Recycle signal assignment

// NOP signal assignment



endmodule
