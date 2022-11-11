module or3(out, in1, in2, in3);

	output out;
	input in1, in2, in3;

	wire temp;

	or2 f0(.out(temp), .in1(in1), .in2(in2));
	or2 f1(.out(out), .in1(in3), .in2(temp));

endmodule