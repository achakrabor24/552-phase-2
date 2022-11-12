module hazard(clk, rst, PCSrc, stall, FD_NOP, DE_NOP, EM_NOP, MW_NOP, if_stall, ID_EX_MemRead, IF_ID_RegisterRs, IF_ID_RegisterRt,
ID_EX_RegisterRs, ID_EX_RegisterRt, EX_MEM_RegWrite, EX_MEM_RegisterRd, MEM_WB_RegWrite, MEM_WB_RegisterRd, MEM_WB_RegisterRd);

	input [1:0] PCSrc;
	input stall; // createdump 
	input clk, rst;

	output FD_NOP, DE_NOP, EM_NOP, MW_NOP, if_stall;

// Branch detection for flushing
wire br_j_taken, if_stall_load, if_stall_exe, if_stall_mem;
assign br_j_taken = ((PCSrc == 2'b10) | (PCSrc == 2'b11)) ? 1'b1: 1'b0;

///////////////////////////////////////////////////////// Stalling logic ///////////////////////////////////////////////////////////////

// Stalling for loading
// ID/EX.MemRead & ((ID/EX.RegisterRt == IF/ID.RegisterRs) | (ID/EX.RegisterRt == IF/ID.RegisterRt))
// Set if_stall_load to 1 so that EX, MEM, and WB control signals in ID are set to 0
assign if_stall_load = ID_EX_MemRead & ((ID_EX_RegisterRt == IF_ID_RegisterRs) | (ID_EX_RegisterRt == IF_ID_RegisterRt)) ? 1'b1 : 1'b0;

// Stalling for EX
// EX/MEM.RegWrite & ~(EX/MEM.RegisterRd == 0) & ((ID/EX.RegisterRs == EX/MEM.RegisterRd) | (ID/EX.RegisterRt == EX/MEM.RegisterRd))
assign if_stall_exe = EX_MEM_RegWrite & ~(EX_MEM_RegisterRd == 0) & ((ID_EX_RegisterRs == EX_MEM_RegisterRd) | (ID_EX_RegisterRt == EX_MEM_RegisterRd)) ? 1'b1 : 1'b0;

// Stalling for MEM
// MEM/WB.RegWrite & ~(MEM/WB.RegisterRd == 0) & ((ID/EX.RegisterRs == MEM/WB.RegisterRd) | (ID/EX.RegisterRt == MEM/WB.RegisterRd))
assign if_stall_mem = MEM_WB_RegWrite & ~(MEM_WB_RegisterRd == 0) & ((ID_EX_RegisterRs == MEM_WB_RegisterRd) | (ID_EX_RegisterRt == MEM_WB_RegisterRd)) ? 1'b1: 1'b0;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// If needs to stall, force hold PC

// Recycle signal assignment

// NOP signal assignment



endmodule
