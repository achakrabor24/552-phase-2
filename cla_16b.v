/*
    CS/ECE 552 FALL '22
    Homework #2, Problem 1
    
    a 16-bit CLA module
*/
module cla_16b(sum, c_out, a, b, c_in);

    // declare constant for size of inputs, outputs (N)
    parameter   N = 16;

    output [N-1:0] sum;
    output         c_out;
    input [N-1: 0] a, b;
    input          c_in;

	wire [3:0] c_dummy;
	wire c4, c8, c12;

	wire [3:0] G;
	wire [3:0] P;
	

	// Big generates and propogates
	G_P16 f0(.a(a), .b(b), .G0_3(G[0]), .G4_7(G[1]), .G8_11(G[2]), .G12_15(G[3]), 
		.P0_3(P[0]), .P4_7(P[1]), .P8_11(P[2]), .P12_15(P[3]));

	// Carry-ins
	cla4_logic f1(.c_in(c_in), .g(G), .p(P), .c1(c4), .c2(c8), .c3(c12), .c4(c_out));

	// Cascade through 4-bit adders
    	cla_4b cla0(.sum(sum[3:0]), .c_out(c_dummy[0]), .a(a[3:0]), .b(b[3:0]), .c_in(c_in));
	cla_4b cla1(.sum(sum[7:4]), .c_out(c_dummy[1]), .a(a[7:4]), .b(b[7:4]), .c_in(c4));
	cla_4b cla2(.sum(sum[11:8]), .c_out(c_dummy[2]), .a(a[11:8]), .b(b[11:8]), .c_in(c8));
	cla_4b cla3(.sum(sum[15:12]), .c_out(c_dummy[3]), .a(a[15:12]), .b(b[15:12]), .c_in(c12));

endmodule
