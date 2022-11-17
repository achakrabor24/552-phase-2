/*
   CS/ECE 552 Spring '20
  
   Filename        : execute.v
   Description     : This is the overall module for the execute stage of the processor.
*/
module execute(Immd, read_data_1, read_data_2, PC, PC_2, PC_2_I, PC_2_D, ALUSrc, invA, invB, sign, Cin, is_LBI, is_SLBI, PCSrc, ALUOp, next_PC, 
	ALU_Result_out, err, is_branch, branch);

	input [15:0] Immd, read_data_1, read_data_2, PC_2, PC_2_I, PC_2_D, PC;
	input ALUSrc, invA, invB, sign, Cin, is_LBI, is_SLBI, is_branch; // Control signals
	input [2:0] PCSrc;
	input [4:0] ALUOp;

	output [15:0] next_PC, ALU_Result_out, branch;
	output err;

	wire [15:0] InB, ALU_Result;
	wire Ofl, Zero;

assign InB = (ALUSrc == 1'b1) ? read_data_2 : Immd;

// alu
alu alu0(.InA(read_data_1), .InB(InB), .Cin(Cin), .Oper(ALUOp), .invA(invA), .invB(invB), .sign(sign), .Out(ALU_Result), 
	.Zero(Zero), .Ofl(Ofl));

// Go to next instruction or branch
assign branch = (is_branch == 1'b1 & ALU_Result == 1'b1) ? PC_2_I: PC_2;


// Load or shift load immediate
assign ALU_Result_out = (is_LBI == 1'b1) ? InB : (is_SLBI == 1'b1) ? ((read_data_1 << 8) | Immd) : ALU_Result;

// For now
assign err = 1'b0;
   
endmodule
