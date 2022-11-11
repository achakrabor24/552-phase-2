/*
    CS/ECE 552 FALL '22
    Homework #2, Problem 3

    A multi-bit ALU module (defaults to 16-bit). It is designed to choose
    the correct operation to perform on 2 multi-bit numbers from rotate
    left, shift left, shift right arithmetic, shift right logical, add,
    or, xor, & and.  Upon doing this, it should output the multi-bit result
    of the operation, as well as drive the output signals Zero and Overflow
    (OFL).
*/
module alu (InA, InB, Cin, Oper, invA, invB, sign, Out, Zero, Ofl);

    parameter OPERAND_WIDTH = 16;    
    parameter NUM_OPERATIONS = 5;
       
    input  [OPERAND_WIDTH -1:0] InA ; // Input operand A
    input  [OPERAND_WIDTH -1:0] InB ; // Input operand B
    input                       Cin ; // Carry in
    input  [NUM_OPERATIONS-1:0] Oper; // Operation type
    input                       invA; // Signal to invert A
    input                       invB; // Signal to invert B
    input                       sign; // Signal for signed operation
    output [OPERAND_WIDTH -1:0] Out ; // Result of computation
    output                      Ofl ; // Signal if overflow occured
    output                      Zero; // Signal if Out is 0


	// All operations
	parameter rll = 3'b000;
	parameter sll = 3'b001;
	parameter rr = 3'b010;
	parameter srl = 3'b011;
	parameter add = 3'b100;
	parameter bitwise_and = 3'b101;
	parameter bitwise_or = 3'b110;
	parameter bitwise_xor = 3'b111;
	parameter btr = 4'b1000;
	parameter seq = 4'b1001;
	parameter slt = 4'b1010;
	parameter sle = 4'b1011;
	parameter sco = 4'b1100;
	parameter beqz = 4'b1101;
	parameter bnez = 4'b1110;
	parameter bltz = 4'b1111;
	parameter bgez = 5'b10000;
	
	wire [OPERAND_WIDTH -1:0] A, B, RL, SL, RR, SRL, Sum, BTR;
	wire SEQ, SLT, SLE, SCO;
	wire ltl, gtl, eql;
	wire BEQZ, BNEZ, BLTZ, BGEZ;

	// Check if A or B needs to be inverted
	assign A = (invA == 1'b1) ? ~InA : InA;
	assign B = (invB == 1'b1) ? ~InB : InB;

	// Calculate all shift possibilities
	rotate_left f0(.Out(RL), .A(A), .s(B[3:0]));
	shift_left f1(.Out(SL), .A(A), .s(B[3:0]));
	rotate_right f2(.Out(RR), .A(A), .s(B[3:0]));
	shift_right_log f3(.Out(SRL), .A(A), .s(B[3:0]));

	// Bitwise reverse
	assign BTR = {A[0], A[1], A[2], A[3], A[4], A[5], A[6], A[7], A[8], A[9], A[10], A[11], A[12], A[13], A[14], A[15]};

	wire c_out;
	cla_16b f4(.sum(Sum), .c_out(c_out), .a(A), .b(B), .c_in(Cin));

	assign SEQ = (A == B) ? 1'b1 : 1'b0;

	less_than ls0(.A(A), .B(B), .A_is_less(ltl));
	
	assign SLT = (ltl == 1'b1) ? 1'b1: 1'b0;

	// assign SLE = (eql | ltl) ? 1'b1: 1'b0;
	assign SLE = ((ltl == 1'b1) | (A == B)) ? 1'b1: 1'b0;

	assign SCO = (c_out == 1'b1) ? 1'b1 : 1'b0;

	// Branches 
	assign BEQZ = (A == 16'h0000) ? 1'b1: 1'b0;
	assign BNEZ = (~(A == 16'h0000)) ? 1'b1: 1'b0;
	assign BLTZ = (A[15] == 1'b1) ? 1'b1: 1'b0;
	assign BGEZ = ((A[15] == 1'b0) | (A == 16'h0000)) ? 1'b1: 1'b0;
	

	assign Out = 
	(Oper == rll) ? RL : 
	(Oper == sll) ? SL : 
	(Oper == rr)? RR : 
	(Oper == srl)? SRL :
	(Oper == add)? Sum :
	(Oper == bitwise_and)? (A & B):
	(Oper == bitwise_or)? (A | B): 
	(Oper == bitwise_xor) ? (A ^ B):
	(Oper == btr) ? BTR :
	(Oper == seq) ? SEQ :
	(Oper == slt) ? SLT :
	(Oper == sle) ? SLE : 
	(Oper == sco) ? SCO : 
	(Oper == beqz) ? BEQZ:
	(Oper == bnez) ? BNEZ: 
	(Oper == bltz) ? BLTZ : BGEZ;


	// Is Out zero
	assign Zero = (Out == 16'b0000_0000_0000_0000) ? 1'b1 : 1'b0;

	assign Ofl = 
	(sign == 1'b0 & c_out == 1'b1) | 
	(sign == 1'b1 & A[15] == 1'b0 & B[15] == 1'b0 & Sum[15] == 1'b1) | 
	(sign == 1'b0 & A[15] == 1'b1 & B[15] == 1'b1 & Sum[15] == 1'b0) |
	(sign == 1'b1 & A[15] == 1'b1 & B[15] == 1'b1 & Sum[15] == 1'b0) 
	? 1'b1: 1'b0;

	

    
endmodule
