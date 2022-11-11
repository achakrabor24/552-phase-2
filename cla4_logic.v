module cla4_logic(c_in, g, p, c1, c2, c3, c4);

	output c1, c2, c3, c4;
	input [3:0] g, p;
	input c_in;

	wire t1, t2, t3, t4, t5, t6, t7, t8, t9, t10;

	// c1 = g0 + po*c_in
	and2 f0(.out(t1), .in1(p[0]), .in2(c_in));
	or2 f1(.out(c1), .in1(g[0]), .in2(t1));

	// c2 = g1 + p1*g0 + p1*po*c_in
	and3 f2(.out(t2), .in1(p[1]), .in2(p[0]), .in3(c_in));
	and2 f3(.out(t3), .in1(p[1]), .in2(g[0]));
	or3 f4(.out(c2), .in1(g[1]), .in2(t2), .in3(t3));

	// c3 = g2 + p2*g1 + p2*p1*g0 + p2*p1*po*c_in (something wrong here)
	and4 f5(.out(t4), .in1(p[2]), .in2(p[1]), .in3(p[0]), .in4(c_in));
	and3 f6(.out(t5), .in1(p[2]), .in2(p[1]), .in3(g[0]));
	and2 f7(.out(t6), .in1(p[2]), .in2(g[1]));
	or4 f8(.out(c3), .in1(t4), .in2(t5), .in3(t6), .in4(g[2]));

	// c4 = g3 + g2*p3 + p3*p2*g1 + p3*p2*p1*g0 + p3*p2*p1*p0*c_in
	and5 f9(.out(t7), .in1(p[3]), .in2(p[2]), .in3(p[1]), .in4(p[0]), .in5(c_in));
	and4 f10(.out(t8), .in1(p[3]), .in2(p[2]), .in3(p[1]), .in4(g[0]));
	and3 f11(.out(t9), .in1(p[3]), .in2(p[2]), .in3(g[1]));
	and2 f12(.out(t10), .in1(p[3]), .in2(g[2]));
	or5 f13(.out(c4), .in1(t7), .in2(t8), .in3(t9), .in4(t10), .in5(g[3]));


endmodule

