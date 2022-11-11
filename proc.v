/* $Author: sinclair $ */
/* $LastChangedDate: 2020-02-09 17:03:45 -0600 (Sun, 09 Feb 2020) $ */
/* $Rev: 46 $ */
module proc (/*AUTOARG*/
   // Outputs
   err, 
   // Inputs
   clk, rst
   );

   input clk;
   input rst;

   output err;

   // None of the above lines can be modified

   // OR all the err ouputs for every sub-module and assign it as this
   // err output
   
   // As desribed in the homeworks, use the err signal to trap corner
   // cases that you think are illegal in your statemachines
   
   
   /* your code here -- should include instantiations of fetch, decode, execute, mem and wb modules */

// Control signals  
wire is_branch, RegWrite, SignExt, ImmdSrc, ALUSrc, is_SLBI, MemRead, MemWrite, MemtoReg, sign, invA, invB, Cin, is_LBI, is_JAL, fetch_enable,
createdump;
wire [4:0] ALUOp;
wire [1:0] PCSrc, RegDst;

// Inputs and outputs between sections
wire [15:0] PC_2, next_PC, instruction, write_data, Immd, read_data_1, read_data_2, ALU_Result, read_data, PC_2_I, PC_2_D;  

// errors
wire errF, errD, errX, errM, errW;

fetch fetch0(.next_PC(next_PC), .clk(clk), .rst(rst), .PC_2(PC_2), .instruction(instruction), .err(errF), .fetch_enable(fetch_enable), 
.createdump(createdump));

// F/D pipeline register

control_unit signals(.opcode(instruction[15:11]), .funct(instruction[1:0]), .rst(rst), .RegWrite(RegWrite), .SignExt(SignExt), .ImmdSrc(ImmdSrc), .ALUSrc(ALUSrc), 
.is_SLBI(is_SLBI), .MemRead(MemRead), .MemWrite(MemWrite), .MemtoReg(MemtoReg), .sign(sign), .invA(invA), .invB(invB), .Cin(Cin), 
.is_LBI(is_LBI), .is_JAL(is_JAL), .PCSrc(PCSrc), .RegDst(RegDst), .ALUOp(ALUOp), .fetch_enable(fetch_enable), .createdump(createdump),
.is_branch(is_branch));

decode decode0(.RegWrite(RegWrite), .is_JAL(is_JAL), .SignExt(SignExt), .ImmdSrc(ImmdSrc), .clk(clk), .rst(rst), .RegDst(RegDst), 
.instruction(instruction), .PC_2(PC_2), .write_data(write_data), .read_data_1(read_data_1), .read_data_2(read_data_2), .Immd(Immd), 
.PC_2_I(PC_2_I), .PC_2_D(PC_2_D), .err(errD));

// D/E pipeline register

execute execute0(.Immd(Immd), .read_data_1(read_data_1), .read_data_2(read_data_2), .PC_2(PC_2), .PC_2_I(PC_2_I), .PC_2_D(PC_2_D), 
.ALUSrc(ALUSrc), .invA(invA), .invB(invB), .sign(sign), .Cin(Cin), .is_LBI(is_LBI), .is_SLBI(is_SLBI), .PCSrc(PCSrc), .ALUOp(ALUOp), 
.next_PC(next_PC), .ALU_Result_out(ALU_Result), .err(errX), .is_branch(is_branch));

// E/M pipeline register

memory memory0(.ALU_result(ALU_Result), .read_data_in(read_data_2), .MemRead(MemRead), .MemWrite(MemWrite), .read_data_out(read_data),
 .clk(clk), .rst(rst), .createdump(createdump), .err(errM));

// M/W pipeline register

wb wb0(.ALU_result(ALU_Result), .read_data(read_data), .MemtoReg(MemtoReg), .write_data(write_data), .err(errW));

// Errors for all the stages
assign err = errF | errD | errX | errM | errW;
   
endmodule // proc
// DUMMY LINE FOR REV CONTROL :0:
