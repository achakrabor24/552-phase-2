module mux2_1(out, inA, inB , s);
	output out;
	input inA, inB, s;

	assign out = (s == 1'b0) ? inA : inB;

endmodule