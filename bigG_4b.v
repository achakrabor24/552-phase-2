module bigG_4b(out, p, g);

	input [3:0] p, g;
	output out;

	wire temp1, temp2, temp3;

	and4 f0(.out(temp1), .in1(p[3]), .in2(p[2]), .in3(p[1]), .in4(g[0]));
	and3 f1(.out(temp2), .in1(p[3]), .in2(p[2]), .in3(g[1]));
	and2 f2(.out(temp3), .in1(p[3]), .in2(g[2]));
	or4 f3(.out(out), .in1(g[3]), .in2(temp1), .in3(temp2), .in4(temp3));

endmodule