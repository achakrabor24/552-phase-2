/*
   CS/ECE 552 Spring '20
  
   Filename        : decode.v
   Description     : This is the module for the overall decode stage of the processor.
*/
module decode(clk, rst, instruction, PC_2, write_data, regWrSel, read_data_1, read_data_2, Immd,
 PC_2_I, PC_2_D, ALUSrc, is_SLBI, is_LBI, MemRead, MemWrite, MemtoReg, sign, invA, invB, Cin, PCSrc, ALUOp, fetch_enable, is_branch,
 createdump, err, writeReg, readReg1, readReg2, RegWrite, mw_RegWrite, Stall);

	input clk, rst, mw_RegWrite, Stall;
	input [2:0] regWrSel;
	input [15:0] instruction, PC_2, write_data;

	output [15:0] read_data_1, read_data_2, Immd, PC_2_I, PC_2_D;
	output err;

	// control outputs
	output ALUSrc, is_SLBI, is_LBI, MemRead, MemWrite, MemtoReg, RegWrite, sign, invA, invB, Cin, PCSrc, fetch_enable, is_branch, createdump;
	output [4:0] ALUOp;
	output [2:0] PCSrc;

	// register values
	output [2:0] writeReg, readReg1, readReg2;

	wire [15:0] write_data_temp, I1, I2, J;
	wire [2:0] writeRegSel_temp;
	wire dummy1, dummy2;
	// control wires (outputs from control_unit only used in decode)
	wire [1:0] RegDst;
	wire SignExt, ImmdSrc, is_JAL;

	wire halt;

	control_unit signals(.opcode(instruction[15:11]), .funct(instruction[1:0]), .rst(rst), .RegWrite(RegWrite), .SignExt(SignExt), 
	.ImmdSrc(ImmdSrc), .ALUSrc(ALUSrc), 
	.is_SLBI(is_SLBI), .MemRead(MemRead), .MemWrite(MemWrite), .MemtoReg(MemtoReg), .sign(sign), .invA(invA), .invB(invB), .Cin(Cin), 
	.is_LBI(is_LBI), .is_JAL(is_JAL), .PCSrc(PCSrc), .RegDst(RegDst), .ALUOp(ALUOp), .fetch_enable(fetch_enable), .createdump(halt),
	.is_branch(is_branch));

	// Make sure createdump doesn't go high on a stall 
	assign createdump = (Stall) ? 1'b0 : halt; 

	assign write_data_temp = (is_JAL == 1'b1) ? PC_2 : write_data;
	assign writeRegSel_temp = (RegDst == 2'b00) ? instruction[4:2] 
				: (RegDst == 2'b01) ? instruction[7:5] 
				: (RegDst == 2'b10) ? instruction[10:8] : 3'b111;

	

	regFile_bypass regFile0(.read1Data(read_data_1), .read2Data(read_data_2), .err(err), .clk(clk), .rst(rst), .read1RegSel(instruction[10:8]),
	 .read2RegSel(instruction[7:5]), .writeRegSel(regWrSel), .writeData(write_data_temp), .writeEn(mw_RegWrite));

	assign writeReg = writeRegSel_temp;
	assign readReg1 = instruction[10:8];
	assign readReg2 = instruction[7:5]; 


	// Sign and zero extension
	assign I1 = (SignExt == 1'b1) ? ({{11{instruction[4]}}, instruction[4:0]}) : ({{11{1'b0}}, instruction[4:0]});
	assign I2 = (SignExt == 1'b1) ? ({{8{instruction[7]}}, instruction[7:0]}) : ({{8{1'b0}}, instruction[7:0]});
	assign J = {{5{instruction[10]}}, instruction[10:0]};

	assign Immd = (ImmdSrc == 1'b1) ? I1 : I2;

	// PC options
	cla_16b cla0(.sum(PC_2_I), .c_out(dummy1), .a(PC_2), .b(I2), .c_in(1'b0));
	cla_16b cla1(.sum(PC_2_D), .c_out(dummy2), .a(PC_2), .b(J), .c_in(1'b0));

   
endmodule
