module hazard(PCSrc, clk, rst, de_MemRead, de_rs, de_rt, fd_rs, fd_rt, em_rd, em_RegWrite, em_rs, em_rt, insert_nop, mw_RegWrite, mw_rd,
wb_RegWrite, wb_rd, de_RegWrite, de_rd, mw_rs, mw_rt, dout_RegWrite, dout_rd, opcode);

input [2:0] PCSrc;
input clk, rst, de_MemRead, em_RegWrite, mw_RegWrite, wb_RegWrite, de_RegWrite, dout_RegWrite;
input [2:0] de_rt, fd_rs, fd_rt, em_rd, de_rs, mw_rd, em_rs, em_rt, wb_rd, de_rd, mw_rs, mw_rt, dout_rd; // All registers
input [4:0] opcode; 

output insert_nop;

// I think we are stalling at the correct time, but stalling incorrectly

wire branch_stall, load_stall, de_stall, em_stall, mw_stall, wb_stall, insert_nop_dff; 

///////////////////////////////////////////////////////// Branch hazard /////////////////////////////////////////////////////////
parameter BEQZ = 5'b01100;
parameter BNEZ = 5'b01101;
parameter BLTZ = 5'b01110;
parameter BGEZ = 5'b01111;

// assign br_j_taken = ((PCSrc == 2'b10) | (PCSrc == 2'b11)) ? 1'b1: 1'b0;

// Check if instruction is a branch
wire branch_stall1, branch_stall2, branch_stall3;
assign branch_stall = (opcode == BEQZ) ? 1'b1: (opcode == BNEZ) ? 1'b1: (opcode == BLTZ) ? 1'b1: (opcode == BGEZ) ? 1'b1: 1'b0;

// Flush instead of stall
// zero out fd and de signals to throw out the next instructions because you are taking the branch
// start with new pc value found from branch

// Manually stall until branch completes
// dff dff4(.q(branch_stall1), .d(branch_stall), .clk(clk), .rst(rst));
// dff dff5(.q(branch_stall2), .d(branch_stall1), .clk(clk), .rst(rst));
// dff dff6(.q(branch_stall3), .d(branch_stall2), .clk(clk), .rst(rst));

///////////////////////////////////////////////////////// Decode hazard /////////////////////////////////////////////////////////
assign de_stall = (de_RegWrite & ((de_rd == fd_rs) | (de_rd == fd_rt) | (de_rt == fd_rt) | (de_rt == fd_rt)));

wire em_stall_latch, mw_stall_latch;

// Stall propogates through pipeline
dff dff0(.q(em_stall_latch), .d(de_stall), .clk(clk), .rst(rst));
dff dff1(.q(mw_stall_latch), .d(em_stall_latch), .clk(clk), .rst(rst));

///////////////////////////////////////////////////////// Execute hazard /////////////////////////////////////////////////////////
assign em_stall = (em_RegWrite & ((em_rd == de_rs) | (em_rd == de_rt))); // Resolve branches in execute

wire em_stall_latch1, mw_stall_latch1;

// Stall propogates through pipeline
dff dff2(.q(em_stall_latch1), .d(em_stall), .clk(clk), .rst(rst));
dff dff3(.q(mw_stall_latch1), .d(em_stall_latch1), .clk(clk), .rst(rst));

///////////////////////////////////////////////////////// Mem hazard ///////////////////////////////////////////////////////// 
assign mw_stall = (mw_RegWrite & ((mw_rd == de_rs) | (mw_rd == de_rt)));

// wire mw_stall_latch2; 

// dff dff7(.q(mw_stall_latch2), .d(mw_stall), .clk(clk), .rst(rst));


assign insert_nop = rst ? 1'b0 : (em_stall | mw_stall | de_stall | em_stall_latch | mw_stall_latch | mw_stall_latch1 | em_stall_latch1);

// | branch_stall3 | branch_stall2 | branch_stall1 | branch_stall



endmodule
