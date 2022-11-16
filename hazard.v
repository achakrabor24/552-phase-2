// module hazard(clk, rst, PCSrc, stall, FD_NOP, DE_NOP, EM_NOP, MW_NOP, ID_EX_MemRead, IF_ID_RegisterRs, IF_ID_RegisterRt,
// ID_EX_RegisterRs, ID_EX_RegisterRt, EX_MEM_RegWrite, EX_MEM_RegisterRd, MEM_WB_RegWrite, MEM_WB_RegisterRd);
module hazard (clk, 
			   rst, 
			   IF_ID_RegisterRs, 
			   IF_ID_RegisterRt, 
			   ID_EX_RegisterRd, 
			   ID_EX_RegisterRs, 
			   ID_EX_RegisterRt, 
			   EX_MEM_RegisterRd, 
			   EX_MEM_RegisterRs,
			   EX_MEM_RegisterRt,
			   MEM_WB_RegisterRd, 
			   MEM_WB_RegisterRs, 
			   MEM_WB_RegisterRt, 
			   insert_nop
			   );
	input [2:0] PCSrc;
	input stall; // createdump 
	input clk, rst;
	input [2:0] IF_ID_RegisterRs, IF_ID_RegisterRt, ID_EX_RegisterRd, ID_EX_RegisterRs, ID_EX_RegisterRt, EX_MEM_RegisterRd, EX_MEM_RegisterRs,EX_MEM_RegisterRt,MEM_WB_RegisterRd, MEM_WB_RegisterRs, MEM_WB_RegisterRt;
	output insert_nop;

	// output FD_NOP, DE_NOP, EM_NOP, MW_NOP;
// Branch detection for flushing
// wire br_j_taken, if_stall_load, if_stall_exe, if_stall_mem;
// assign br_j_taken = ((PCSrc == 2'b10) | (PCSrc == 2'b11)) ? 1'b1: 1'b0;

///////////////////////////////////////////////////// Stalling logic ////////////////////////////////////////////////////////////////////
wire d_haz1, d_haz2, e_haz1, e_haz2, m_haz1, m_haz2;
assign d_haz1 = (IF_ID_RegisterRs == ID_EX_RegisterRd | IF_ID_RegisterRs == EX_MEM_RegisterRd | IF_ID_RegisterRs == MEM_WB_RegisterRd) ? 1'b1 : 1'b0;
assign d_haz2 = (IF_ID_RegisterRt == ID_EX_RegisterRd | IF_ID_RegisterRt == EX_MEM_RegisterRd | IF_ID_RegisterRt == MEM_WB_RegisterRd) ? 1'b1 : 1'b0;

assign e_haz1 = (ID_EX_RegisterRs == EX_MEM_RegisterRd | ID_EX_RegisterRs == MEM_WB_RegisterRd) ? 1'b1 : 1'b0;
assign e_haz2 = (ID_EX_RegisterRt == EX_MEM_RegisterRd | ID_EX_RegisterRt == MEM_WB_RegisterRd) ? 1'b1 : 1'b0;

assign m_haz1 = (EX_MEM_RegisterRs == MEM_WB_RegisterRd) ? 1'b1 : 1'b0;
assign m_haz2 = (EX_MEM_RegisterRt == MEM_WB_RegisterRd) ? 1'b1 : 1'b0;
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
wire nop;
assign insert_nop = d_haz1 | d_haz2 | e_haz1 | e_haz2 | m_haz1 | m_haz2;
// I force PC hold as PCSrc signal in NOP opcode in control unit

// wire stall_fd, stall_de, stall_em, stall_mw;

// Recycle signal assignment (?) 

// Not sure what this is or what to do here
// dff_N #(.N(1)) reg_stall_FD      (.q(stall_fd), .d(stall),.clk(clk),.rst(rst));
// dff_N #(.N(1)) reg_stall_DE      (.q(stall_de),.d(stall_fd),.clk(clk),.rst(rst));
// dff_N #(.N(1)) reg_stall_EM      (.q(stall_em),.d(stall_de),.clk(clk),.rst(rst));
// dff_N #(.N(1)) reg_stall_MW      (.q(stall_mw),.d(stall_em),.clk(clk),.rst(rst));

/////////////////////////////////////////////////////////// NOP signal assignment //////////////////////////////////////////////////////////

// If control unit says stall, stall or if branch taken in a predict-not-taken scheme (resolved in fetch and decode)
// assign FD_NOP = stall | br_j_taken; 
// assign DE_NOP = br_j_taken | if_stall_load | stall_de; 
// assign EM_NOP = if_stall_exe | stall_em;
// assign MW_NOP = if_stall_mem | stall_mw;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


endmodule
