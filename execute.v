/*
   CS/ECE 552 Spring '20
  
   Filename        : execute.v
   Description     : This is the overall module for the execute stage of the processor.
*/
module execute(Immd, read_data_1, read_data_2, ALUSrc, invA, invB, sign, Cin, is_LBI, is_SLBI, ALUOp, ALU_Result_out, err);

	input [15:0] Immd, read_data_1, read_data_2;
	input ALUSrc, invA, invB, sign, Cin, is_LBI, is_SLBI; // Control signals
	input [4:0] ALUOp;

	output [15:0] ALU_Result_out;
	output err;

	wire [15:0] InB, ALU_Result, shift_left_immd, shift_left_8;
	wire Ofl, Zero;

assign InB = (ALUSrc == 1'b1) ? read_data_2 : Immd;

// alu
alu alu0(.InA(read_data_1), .InB(InB), .Cin(Cin), .Oper(ALUOp), .invA(invA), .invB(invB), .sign(sign), .Out(ALU_Result), .Zero(Zero), .Ofl(Ofl));

assign shift_left_8 = (read_data_1 << 8); 
assign shift_left_immd = shift_left_8 | Immd; 

// Load or shift load immediate
assign ALU_Result_out = (is_LBI == 1'b1) ? InB : (is_SLBI == 1'b1) ? shift_left_immd : ALU_Result;

// For now
assign err = 1'b0;
   
endmodule
