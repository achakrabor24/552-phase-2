module or4(out, in1, in2, in3, in4);

	output out;
	input in1, in2, in3, in4;

	wire temp;

	or3 f0(.out(temp), .in1(in1), .in2(in2), .in3(in3));
	or2 f1(.out(out), .in1(in4), .in2(temp));

endmodule