module hazard(clk, rst, PCSrc, stall, FD_NOP, DE_NOP, EM_NOP, MW_NOP, ID_EX_MemRead, IF_ID_RegisterRs, IF_ID_RegisterRt,
ID_EX_RegisterRs, ID_EX_RegisterRt, EX_MEM_RegWrite, EX_MEM_RegisterRd, MEM_WB_RegWrite, MEM_WB_RegisterRd);

	input [2:0] PCSrc;
	input stall; // createdump 
	input clk, rst;
	input stall,
		  ID_EX_MemRead, 
		  IF_ID_RegisterRs, 
		  IF_ID_RegisterRt, 
		  ID_EX_RegisterRs, 
		  ID_EX_RegisterRt, 
		  EX_MEM_RegWrite, 
		  EX_MEM_RegisterRd, 
		  MEM_WB_RegWrite, 
		  MEM_WB_RegisterRd, 
		  MEM_WB_RegisterRd;

	output FD_NOP, DE_NOP, EM_NOP, MW_NOP;

// Branch detection for flushing
wire br_j_taken, if_stall_load, if_stall_exe, if_stall_mem;
assign br_j_taken = ((PCSrc == 2'b10) | (PCSrc == 2'b11)) ? 1'b1: 1'b0;

///////////////////////////////////////////////////// Stalling logic ////////////////////////////////////////////////////////////////////

// Stalling for loading
// Set if_stall_load to 1 so that EX, MEM, and WB control signals in ID are set to 0
assign if_stall_load = ID_EX_MemRead & ((ID_EX_RegisterRt == IF_ID_RegisterRs) | (ID_EX_RegisterRt == IF_ID_RegisterRt)) ? 1'b1 : 1'b0;

// Stalling for EX
assign if_stall_exe = EX_MEM_RegWrite & ~(EX_MEM_RegisterRd == 0) & ((ID_EX_RegisterRs == EX_MEM_RegisterRd) | 
(ID_EX_RegisterRt == EX_MEM_RegisterRd)) ? 1'b1 : 1'b0;

// Stalling for MEM
assign if_stall_mem = MEM_WB_RegWrite & ~(MEM_WB_RegisterRd == 0) & ((ID_EX_RegisterRs == MEM_WB_RegisterRd) | 
(ID_EX_RegisterRt == MEM_WB_RegisterRd)) ? 1'b1: 1'b0;


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// I force PC hold as PCSrc signal in NOP opcode in control unit

wire stall_fd, stall_de, stall_em, stall_mw;

// Recycle signal assignment (?) 

// Not sure what this is or what to do here
dff_N #(.N(1)) reg_stall_FD      (.Q(stall_fd), .D(stall),.clk(clk),.rst(rst));
dff_N #(.N(1)) reg_stall_DE      (.Q(stall_de),.D(stall_fd),.clk(clk),.rst(rst));
dff_N #(.N(1)) reg_stall_EM      (.Q(stall_em),.D(stall_de),.clk(clk),.rst(rst));
dff_N #(.N(1)) reg_stall_MW      (.Q(stall_mw),.D(stall_em),.clk(clk),.rst(rst));

/////////////////////////////////////////////////////////// NOP signal assignment //////////////////////////////////////////////////////////

// If control unit says stall, stall or if branch taken in a predict-not-taken scheme (resolved in fetch and decode)
assign FD_NOP = stall | br_j_taken; 
assign DE_NOP = br_j_taken | if_stall_load | stall_de; 
assign EM_NOP = if_stall_exe | stall_em;
assign MW_NOP = if_stall_mem | stall_mw;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


endmodule
