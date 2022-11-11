/*
    CS/ECE 552 FALL '22
    Homework #2, Problem 1
    
    a 1-bit full adder
*/
module fullAdder_1b(s, c_out, a, b, c_in);
    output s;
    output c_out;
	input  a, b;
    input  c_in;

	wire temp1, temp2, temp3;

	xor2 f0(.out(temp1), .in1(a), .in2(b));
	xor2 f1(.out(s), .in1(temp1), .in2(c_in));

	and2 f2(.out(temp2), .in1(temp1), .in2(c_in));
	and2 f3(.out(temp3), .in1(a), .in2(b));

	or2 f4(.out(c_out), .in1(temp2), .in2(temp3));

endmodule
