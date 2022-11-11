module shift_left(Out, A, s);

	input [15:0] A;
	input [3:0] s;
	output [15:0] Out;

	wire [15:0] B, C, D;


	// 1-bit shift left
	mux2_1 f0(.out(B[0]), .inA(A[0]), .inB(1'b0), .s(s[0]));
	mux2_1 f1(.out(B[1]), .inA(A[1]), .inB(A[0]), .s(s[0]));
	mux2_1 f2(.out(B[2]), .inA(A[2]), .inB(A[1]), .s(s[0]));
	mux2_1 f3(.out(B[3]), .inA(A[3]), .inB(A[2]), .s(s[0]));
	mux2_1 f4(.out(B[4]), .inA(A[4]), .inB(A[3]), .s(s[0]));
	mux2_1 f5(.out(B[5]), .inA(A[5]), .inB(A[4]), .s(s[0]));
	mux2_1 f6(.out(B[6]), .inA(A[6]), .inB(A[5]), .s(s[0]));
	mux2_1 f8(.out(B[7]), .inA(A[7]), .inB(A[6]), .s(s[0]));
	mux2_1 f9(.out(B[8]), .inA(A[8]), .inB(A[7]), .s(s[0]));
	mux2_1 f10(.out(B[9]), .inA(A[9]), .inB(A[8]), .s(s[0]));
	mux2_1 f11(.out(B[10]), .inA(A[10]), .inB(A[9]), .s(s[0]));
	mux2_1 f12(.out(B[11]), .inA(A[11]), .inB(A[10]), .s(s[0]));
	mux2_1 f13(.out(B[12]), .inA(A[12]), .inB(A[11]), .s(s[0]));
	mux2_1 f14(.out(B[13]), .inA(A[13]), .inB(A[12]), .s(s[0]));
	mux2_1 f15(.out(B[14]), .inA(A[14]), .inB(A[13]), .s(s[0]));
	mux2_1 f16(.out(B[15]), .inA(A[15]), .inB(A[14]), .s(s[0]));

	// 2-bit shift left
	mux2_1 p0(.out(C[0]), .inA(B[0]), .inB(1'b0), .s(s[1]));
	mux2_1 p1(.out(C[1]), .inA(B[1]), .inB(1'b0), .s(s[1]));
	mux2_1 p2(.out(C[2]), .inA(B[2]), .inB(B[0]), .s(s[1]));
	mux2_1 p3(.out(C[3]), .inA(B[3]), .inB(B[1]), .s(s[1]));
	mux2_1 p4(.out(C[4]), .inA(B[4]), .inB(B[2]), .s(s[1]));
	mux2_1 p5(.out(C[5]), .inA(B[5]), .inB(B[3]), .s(s[1]));
	mux2_1 p6(.out(C[6]), .inA(B[6]), .inB(B[4]), .s(s[1]));
	mux2_1 p7(.out(C[7]), .inA(B[7]), .inB(B[5]), .s(s[1]));
	mux2_1 p9(.out(C[8]), .inA(B[8]), .inB(B[6]), .s(s[1]));
	mux2_1 p10(.out(C[9]), .inA(B[9]), .inB(B[7]), .s(s[1]));
	mux2_1 p11(.out(C[10]), .inA(B[10]), .inB(B[8]), .s(s[1]));
	mux2_1 p12(.out(C[11]), .inA(B[11]), .inB(B[9]), .s(s[1]));
	mux2_1 p13(.out(C[12]), .inA(B[12]), .inB(B[10]), .s(s[1]));
	mux2_1 p14(.out(C[13]), .inA(B[13]), .inB(B[11]), .s(s[1]));
	mux2_1 p15(.out(C[14]), .inA(B[14]), .inB(B[12]), .s(s[1]));
	mux2_1 p16(.out(C[15]), .inA(B[15]), .inB(B[13]), .s(s[1]));

	// 4-bit shift left
	mux2_1 t0(.out(D[0]), .inA(C[0]), .inB(1'b0), .s(s[2]));
	mux2_1 t1(.out(D[1]), .inA(C[1]), .inB(1'b0), .s(s[2]));
	mux2_1 t2(.out(D[2]), .inA(C[2]), .inB(1'b0), .s(s[2]));
	mux2_1 t3(.out(D[3]), .inA(C[3]), .inB(1'b0), .s(s[2]));
	mux2_1 t4(.out(D[4]), .inA(C[4]), .inB(C[0]), .s(s[2]));
	mux2_1 t5(.out(D[5]), .inA(C[5]), .inB(C[1]), .s(s[2]));
	mux2_1 t6(.out(D[6]), .inA(C[6]), .inB(C[2]), .s(s[2]));
	mux2_1 t7(.out(D[7]), .inA(C[7]), .inB(C[3]), .s(s[2]));
	mux2_1 t9(.out(D[8]), .inA(C[8]), .inB(C[4]), .s(s[2]));
	mux2_1 t10(.out(D[9]), .inA(C[9]), .inB(C[5]), .s(s[2]));
	mux2_1 t11(.out(D[10]), .inA(C[10]), .inB(C[6]), .s(s[2]));
	mux2_1 t12(.out(D[11]), .inA(C[11]), .inB(C[7]), .s(s[2]));
	mux2_1 t13(.out(D[12]), .inA(C[12]), .inB(C[8]), .s(s[2]));
	mux2_1 t14(.out(D[13]), .inA(C[13]), .inB(C[9]), .s(s[2]));
	mux2_1 t15(.out(D[14]), .inA(C[14]), .inB(C[10]), .s(s[2]));
	mux2_1 t16(.out(D[15]), .inA(C[15]), .inB(C[11]), .s(s[2]));

	// 8-bit shift left
	mux2_1 Out1(.out(Out[0]), .inA(D[0]), .inB(1'b0), .s(s[3]));
	mux2_1 Out2(.out(Out[1]), .inA(D[1]), .inB(1'b0), .s(s[3]));
	mux2_1 Out3(.out(Out[2]), .inA(D[2]), .inB(1'b0), .s(s[3]));
	mux2_1 Out4(.out(Out[3]), .inA(D[3]), .inB(1'b0), .s(s[3]));
	mux2_1 Out5(.out(Out[4]), .inA(D[4]), .inB(1'b0), .s(s[3]));
	mux2_1 Out6(.out(Out[5]), .inA(D[5]), .inB(1'b0), .s(s[3]));
	mux2_1 Out7(.out(Out[6]), .inA(D[6]), .inB(1'b0), .s(s[3]));
	mux2_1 Out9(.out(Out[7]), .inA(D[7]), .inB(1'b0), .s(s[3]));
	mux2_1 Out10(.out(Out[8]), .inA(D[8]), .inB(D[0]), .s(s[3]));
	mux2_1 Out11(.out(Out[9]), .inA(D[9]), .inB(D[1]), .s(s[3]));
	mux2_1 Out12(.out(Out[10]), .inA(D[10]), .inB(D[2]), .s(s[3]));
	mux2_1 Out13(.out(Out[11]), .inA(D[11]), .inB(D[3]), .s(s[3]));
	mux2_1 Out14(.out(Out[12]), .inA(D[12]), .inB(D[4]), .s(s[3]));
	mux2_1 Out15(.out(Out[13]), .inA(D[13]), .inB(D[5]), .s(s[3]));
	mux2_1 Out16(.out(Out[14]), .inA(D[14]), .inB(D[6]), .s(s[3]));
	mux2_1 Out17(.out(Out[15]), .inA(D[15]), .inB(D[7]), .s(s[3]));
	

endmodule