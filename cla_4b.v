/*
    CS/ECE 552 FALL'22
    Homework #2, Problem 1
    
    a 4-bit CLA module
*/
module cla_4b(sum, c_out, a, b, c_in);

    // declare constant for size of inputs, outputs (N)
    parameter   N = 4;

    output [N-1:0] sum;
    output         c_out;
    input [N-1: 0] a, b;
    input          c_in;

	wire [3:0] g, p, c_dummy;
	wire c1, c2, c3;

	// Get generates and propogates
	g_p4 f0(.a(a), .b(b), .g(g), .p(p));

	// Get carry-ins
	cla4_logic f1(.c_in(c_in), .g(g), .p(p), .c1(c1), .c2(c2), .c3(c3), .c4(c_out));

	// Add 4-bits
	fullAdder_1b f2(.s(sum[0]), .c_out(c_dummy[0]), .a(a[0]), .b(b[0]), .c_in(c_in));
	fullAdder_1b f3(.s(sum[1]), .c_out(c_dummy[1]), .a(a[1]), .b(b[1]), .c_in(c1));
	fullAdder_1b f4(.s(sum[2]), .c_out(c_dummy[2]), .a(a[2]), .b(b[2]), .c_in(c2));
	fullAdder_1b f5(.s(sum[3]), .c_out(c_dummy[3]), .a(a[3]), .b(b[3]), .c_in(c3));


	

endmodule
