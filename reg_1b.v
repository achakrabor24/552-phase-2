module reg_1b(Q, D, clk, rst, writeEn); 

parameter N = 1;
input clk, rst, writeEn; 
input D;
output Q;


wire mux_output;

// Instantiate 16 muxes
mux2_1 mux0(.out(mux_output), .inA(Q), .inB(D), .s(writeEn));

// Instantiate 16 D flip-flops
dff dff0(.q(Q), .d(mux_output), .clk(clk), .rst(rst));


endmodule