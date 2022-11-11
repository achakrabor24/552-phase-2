module g_p4(a, b, g, p);

	input [3:0] a, b;
	output [3:0] g, p;

	// generates
	and2 f0(.out(g[0]), .in1(a[0]), .in2(b[0]));
	and2 f1(.out(g[1]), .in1(a[1]), .in2(b[1]));
	and2 f2(.out(g[2]), .in1(a[2]), .in2(b[2]));
	and2 f3(.out(g[3]), .in1(a[3]), .in2(b[3]));

	// propogates
	or2 f4(.out(p[0]), .in1(a[0]), .in2(b[0]));
	or2 f5(.out(p[1]), .in1(a[1]), .in2(b[1]));
	or2 f6(.out(p[2]), .in1(a[2]), .in2(b[2]));
	or2 f7(.out(p[3]), .in1(a[3]), .in2(b[3])); 

endmodule