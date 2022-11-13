module less_than(A, B, A_is_less);

input [15:0] A, B;
output A_is_less;

wire [15:0] sum;
wire c_out;

// A - B
cla_16b cla0(.sum(sum), .c_out(c_out), .a(A), .b(~B), .c_in(1'b1));

// If they are equal, you'll have zero for the subtraction result, so you know they are equal

// If they are both positive1, or, if they are both negative2 then
// If the subtraction result is negative, then
// The former (minuend) was less than the latter (subtrahend)
// Otherwise The former was greater than the latter

// Otherwise: one is positive and one is negative, so
// The negative number is smaller than the positive number

wire both, A_neg_B_pos, equal, B_neg_A_pos;

assign both =  ((A[15] == 1'b0 & B[15] == 1'b0) | (A[15] == 1'b1 & B[15] == 1'b1)) & sum[15] == 1'b1 ? 1'b1: 1'b0;
assign equal = (sum == 16'b0) ? 1'b1: 1'b0;
assign A_neg_B_pos = (A[15] == 1'b1 & B[15] == 1'b0) ? 1'b1 : 1'b0;
assign B_neg_A_pos = (A[15] == 1'b0 & B[15] == 1'b1) ? 1'b1 : 1'b0;

assign A_is_less = both | A_neg_B_pos;

endmodule