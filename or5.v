module or5(out, in1, in2, in3, in4, in5);

	output out;
	input in1, in2, in3, in4, in5;

	wire temp;

	or4 f0(.out(temp), .in1(in1), .in2(in2), .in3(in3), .in4(in4));
	or2 f1(.out(out), .in1(in5), .in2(temp));

endmodule