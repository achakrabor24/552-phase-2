module G_P16(a, b, G0_3, G4_7, G8_11, G12_15, P0_3, P4_7, P8_11, P12_15);

	input [15:0] a, b;
	output G0_3, G4_7, G8_11, G12_15;
	output P0_3, P4_7, P8_11, P12_15;

	wire [15:0] g, p;

	// all 16 generates and propogates
	g_p4 f0(.a(a[3:0]), .b(b[3:0]), .g(g[3:0]), .p(p[3:0]));
	g_p4 f1(.a(a[7:4]), .b(b[7:4]), .g(g[7:4]), .p(p[7:4]));
	g_p4 f2(.a(a[11:8]), .b(b[11:8]), .g(g[11:8]), .p(p[11:8]));
	g_p4 f3(.a(a[15:12]), .b(b[15:12]), .g(g[15:12]), .p(p[15:12]));

	// big propogates
	and4 f4(.out(P0_3), .in1(p[0]), .in2(p[1]), .in3(p[2]), .in4(p[3]));
	and4 f5(.out(P4_7), .in1(p[4]), .in2(p[5]), .in3(p[6]), .in4(p[7]));
	and4 f6(.out(P8_11), .in1(p[8]), .in2(p[9]), .in3(p[10]), .in4(p[11]));
	and4 f7(.out(P12_15), .in1(p[12]), .in2(p[13]), .in3(p[14]), .in4(p[15]));

	// big generates
	bigG_4b f8(.out(G0_3), .p(p[3:0]), .g(g[3:0]));
	bigG_4b f9(.out(G4_7), .p(p[7:4]), .g(g[7:4]));
	bigG_4b f10(.out(G8_11), .p(p[11:8]), .g(g[11:8]));
	bigG_4b f11(.out(G12_15), .p(p[15:12]), .g(g[15:12]));

	
	

endmodule