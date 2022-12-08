module hazard(PCSrc, clk, rst, de_MemRead, de_rs, de_rt, fd_rs, fd_rt, em_rd, em_RegWrite, em_rs, em_rt, insert_nop, mw_RegWrite, mw_rd,
wb_RegWrite, wb_rd, de_RegWrite, de_rd, mw_rs, mw_rt, dout_RegWrite, dout_rd);

input [2:0] PCSrc;
input clk, rst, de_MemRead, em_RegWrite, mw_RegWrite, wb_RegWrite, de_RegWrite, dout_RegWrite;
input [2:0] de_rt, fd_rs, fd_rt, em_rd, de_rs, mw_rd, em_rs, em_rt, wb_rd, de_rd, mw_rs, mw_rt, dout_rd; // All registers


output insert_nop;

// I think we are stalling at the correct time, but stalling incorrectly

wire br_j_taken, load_stall, de_stall, em_stall, mw_stall, wb_stall, insert_nop_dff; 

// assign br_j_taken = ((PCSrc == 2'b10) | (PCSrc == 2'b11)) ? 1'b1: 1'b0;


// Decode hazard
assign de_stall = de_RegWrite & ((de_rd == fd_rs) | (de_rd == fd_rt));

wire em_stall_latch, mw_stall_latch;

// Stall propogates through pipeline
dff dff0(.q(em_stall_latch), .d(de_stall), .clk(clk), .rst(rst));
dff dff1(.q(mw_stall_latch), .d(em_stall_latch), .clk(clk), .rst(rst));

// Load instruction stall
// assign load_stall = ((de_MemRead == 1'b1) & ((de_rt == fd_rs) | (de_rt == fd_rt))) & (br_j_taken == 1'b0); 

// Execute hazard
assign em_stall = em_RegWrite & ((em_rd == de_rs) | (em_rd == de_rt));

wire em_stall_latch1, mw_stall_latch1;

// Stall propogates through pipeline
dff dff2(.q(em_stall_latch1), .d(em_stall), .clk(clk), .rst(rst));
dff dff3(.q(mw_stall_latch1), .d(em_stall_latch1), .clk(clk), .rst(rst));

// Mem hazard 
assign mw_stall = mw_RegWrite & ((mw_rd == de_rs) | (mw_rd == de_rt));


assign insert_nop = rst ? 1'b0 : (em_stall | mw_stall | de_stall | em_stall_latch | mw_stall_latch | mw_stall_latch1 | em_stall_latch1);



endmodule
