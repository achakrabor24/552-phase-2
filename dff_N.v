// Paramaterized DFF
module dff_N (q, d, clk, rst);
    parameter N = 16;
    
    output [N-1:0]   q;
    input  [N-1:0]   d;
    input          clk;
    input          rst;
    
    dff flops [N-1:0] (.q(q),.d(d),.clk(clk),.rst(rst));

endmodule