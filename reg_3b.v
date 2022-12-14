module reg_3b(Q, D, clk, rst, writeEn); 

parameter N = 3;
input clk, rst, writeEn; 
input [N-1:0] D;
output [N-1:0] Q;


wire [N-1:0] mux_output;

// Instantiate 16 muxes
mux2_1 mux0[N-1:0] (.out(mux_output), .inA(Q), .inB(D), .s({N{writeEn}}));

// Instantiate 16 D flip-flops
dff dff0[N-1:0] (.q(Q), .d(mux_output), .clk(clk), .rst(rst));


endmodule