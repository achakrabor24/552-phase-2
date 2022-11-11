module or2(out, in1, in2);

	input in1, in2;
	output out;

	wire temp;

	nor2 f0(.out(temp), .in1(in1), .in2(in2));
	not1 f1(.out(out), .in1(temp));

endmodule