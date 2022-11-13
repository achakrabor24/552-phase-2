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
wire is_branch, RegWrite, SignExt, ImmdSrc, ALUSrc, is_SLBI, MemRead, MemWrite, MemtoReg, sign, invA, invB, Cin, is_LBI, fetch_enable,
createdump;
wire [4:0] ALUOp;
wire [1:0] PCSrc, RegDst;

// Inputs and outputs between sections
wire [15:0] PC_2, next_PC, instruction, write_data, Immd, read_data_1, read_data_2, ALU_Result, read_data, PC_2_I, PC_2_D, PC, 
writeReg, readReg1, readReg2;  

// errors
wire errF, errD, errX, errM, errW;

fetch fetch0(.next_PC(next_PC), .clk(clk), .rst(rst), 
             .PC_2(PC_2), .instruction(instruction), .err(errF), 
            .fetch_enable(fetch_enable), .createdump(createdump), .PC(PC)
            );

///////////////////////////////////////////////////////// F/D pipeline registers ///////////////////////////////////////////////////////
wire [15:0] fd_next_PC, fd_instruction, fd_PC_2, fd_PC;
wire [2:0] fd_readReg1, fd_readReg2;

dff_N #(.N(16)) reg_fd_next_PC (.q(fd_next_PC), .d(next_PC), .clk(clk), .rst(rst));
dff_N #(.N(16)) reg_fd_instruction (.q(fd_instruction), .d(instruction), .clk(clk), .rst(rst));
dff_N #(.N(16)) reg_fd_PC_2 (.q(fd_PC_2), .d(PC_2), .clk(clk), .rst(rst));
dff_N #(.N(16)) reg_fd_PC (.q(fd_PC), .d(PC), .clk(clk), .rst(rst));
dff_N #(.N(16)) reg_fd_readReg1 (.q(fd_readReg1), .d(instruction[10:8]), .clk(clk), .rst(rst));
dff_N #(.N(16)) reg_fd_readReg2 (.q(fd_readReg2), .d(instruction[7:5]), .clk(clk), .rst(rst));

// Set control signals to 0 if FD_NOP = 1

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

decode decode0(.clk(clk), .rst(rst), .instruction(fd_instruction), 
               .PC_2(fd_PC_2), .write_data(write_data), .read_data_1(read_data_1), 
               .read_data_2(read_data_2), .Immd(Immd), .PC_2_I(PC_2_I), 
               .PC_2_D(PC_2_D), .ALUSrc(ALUSrc), .is_SLBI(is_SLBI), 
               .is_LBI(is_LBI), .MemRead(MemRead), .MemWrite(MemWrite), 
               .MemtoReg(MemtoReg), .sign(sign), .invA(invA), 
               .invB(invB), .Cin(Cin), .PCSrc(PCSrc), 
               .ALUOp(ALUOp), .fetch_enable(fetch_enable), .is_branch(is_branch), 
               .createdump(createdump), .err(err), .writeReg(writeReg), .readReg1(readReg1), .readReg2(readReg2), .RegWrite(RegWrite)
               );

//////////////////////////////////////////////////////// D/E pipeline register //////////////////////////////////////////////////////////
wire [15:0] de_next_PC, de_read_data_1, de_read_data_2, de_PC_2, de_PC_2_I, de_PC_2_D;
wire de_Immd, de_ALUSrc, de_invA, de_invB, de_sign, de_Cin, de_is_SLBI, de_is_LBI, de_MemRead, de_MemtoReg, de_RegWrite;
wire [2:0] de_readReg1, de_readReg2, de_writeReg;

dff_N #(.N(16)) reg_de_next_PC (.q(de_next_PC), .d(fd_next_PC), .clk(clk), .rst(rst));
dff_N #(.N(16)) reg_de_read_data_1 (.q(de_read_data_2), .d(read_data_1), .clk(clk), .rst(rst));
dff_N #(.N(16)) reg_de_read_data_2 (.q(de_read_data_2), .d(read_data_2), .clk(clk), .rst(rst));
dff_N #(.N(16)) reg_de_PC_2 (.q(de_PC_2), .d(fd_PC_2), .clk(clk), .rst(rst));
dff_N #(.N(16)) reg_de_PC_2_I (.q(de_PC_2_I), .d(PC_2_I), .clk(clk), .rst(rst));
dff_N #(.N(16)) reg_de_PC_2_D (.q(de_PC_2_D), .d(PC_2_D), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_de_Immd (.q(de_Immd), .d(Immd), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_de_ALUSrc (.q(de_ALUSrc), .d(ALUSrc), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_de_invA(.q(de_invA), .d(invA), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_de_invB(.q(de_invB), .d(invB), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_de_sign(.q(de_sign), .d(sign), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_de_Cin(.q(de_Cin), .d(Cin), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_de_is_SLBI(.q(de_is_SLBI), .d(is_SLBI), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_de_is_LBI(.q(de_is_LBI), .d(is_LBI), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_de_MemRead(.q(de_MemRead), .d(MemRead), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_de_MemWrite(.q(de_MemWrite), .d(MemWrite), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_de_MemtoReg(.q(de_MemtoReg), .d(MemtoReg), .clk(clk), .rst(rst));
dff_N #(.N(16)) reg_de_reg_rs (.q(de_readReg1), .d(fd_readReg1), .clk(clk), .rst(rst));
dff_N #(.N(16)) reg_de_reg_rt (.q(de_readReg2), .d(fd_readReg2), .clk(clk), .rst(rst));
dff_N #(.N(16)) reg_de_reg_rd (.q(de_writeReg), .d(writeReg), .clk(clk), .rst(rst));
dff_N #(.N(16)) reg_de_reg_wr (.q(de_RegWrite), .d(RegWrite), .clk(clk), .rst(rst));
 

// Set control signals to 0 if DE_NOP = 1

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

execute execute0(.Immd(de_Immd), .read_data_1(de_read_data_1), .read_data_2(de_read_data_2), 
                 .PC_2(de_PC_2), .PC_2_I(de_PC_2_I), .PC_2_D(de_PC_2_D), 
                 .ALUSrc(de_ALUSrc), .invA(de_invA), .invB(de_invB), 
                 .sign(de_sign), .Cin(de_Cin), .is_LBI(de_is_LBI), 
                 .is_SLBI(is_SLBI), .PCSrc(PCSrc), .ALUOp(ALUOp), 
                 .next_PC(de_next_PC), .ALU_Result_out(ALU_Result), .err(errX), 
                 .is_branch(is_branch), .PC(PC)
                 );

///////////////////////////////////////////////// E/M pipeline register ///////////////////////////////////////////////////////////////
wire em_MemRead, em_MemWrite, em_read_data_2, em_MemtoReg;
wire [15:0] em_ALU_Result;
wire [2:0] em_readReg1, em_readReg2, em_writeReg;
wire em_RegWrite;

dff_N #(.N(16)) reg_em_ALU_Result(.q(em_ALU_Result), .d(ALU_Result), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_em_MemRead(.q(em_MemRead), .d(de_MemRead), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_em_MemWrite(.q(em_MemWrite), .d(de_MemWrite), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_em_read_data_2(.q(em_read_data_2), .d(de_read_data_2), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_em_MemtoReg(.q(em_MemtoReg), .d(de_MemtoReg), .clk(clk), .rst(rst));
dff_N #(.N(16)) reg_em_reg_rs (.q(em_readReg1), .d(de_readReg1), .clk(clk), .rst(rst));
dff_N #(.N(16)) reg__em_reg_rt (.q(em_readReg2), .d(de_readReg2), .clk(clk), .rst(rst));
dff_N #(.N(16)) reg_em_reg_rd (.q(em_writeReg), .d(de_writeReg), .clk(clk), .rst(rst));
dff_N #(.N(16)) reg_em_reg_wr (.q(em_RegWrite), .d(de_RegWrite), .clk(clk), .rst(rst));

// Set control signals to 0 if EM_NOP = 1

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

memory memory0(.ALU_result(em_ALU_Result), .read_data_in(em_read_data_2), .MemRead(em_MemRead), 
               .MemWrite(em_MemWrite), .read_data_out(read_data), .clk(clk), 
               .rst(rst), .createdump(createdump), .err(errM)
               );

//////////////////////////////////////////////////////// M/W pipeline register /////////////////////////////////////////////////////////
wire [15:0] mw_read_data, mw_ALU_Result, mw_MemtoReg;
wire [2:0] mw_readReg1, mw_readReg2, mw_writeReg;
wire mw_RegWrite;

dff_N #(.N(16)) reg_mw_ALU_Result(.q(mw_ALU_Result), .d(em_ALU_Result), .clk(clk), .rst(rst));
dff_N #(.N(16)) reg_mw_read_data(.q(mw_read_data), .d(read_data), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_mw_MemtoReg(.q(mw_MemtoReg), .d(em_MemtoReg), .clk(clk), .rst(rst));
dff_N #(.N(16)) reg_mw_reg_rs (.q(mw_readReg1), .d(em_readReg1), .clk(clk), .rst(rst));
dff_N #(.N(16)) reg__mw_reg_rt (.q(mw_readReg2), .d(em_readReg2), .clk(clk), .rst(rst));
dff_N #(.N(16)) reg_mw_reg_rd (.q(mw_writeReg), .d(em_writeReg), .clk(clk), .rst(rst));
dff_N #(.N(16)) reg_mw_reg_wr (.q(mw_RegWrite), .d(em_RegWrite), .clk(clk), .rst(rst));

// Set control signals to 0 if MW_NOP = 1

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

wb wb0(.ALU_result(mw_ALU_Result), .read_data(mw_read_data), .MemtoReg(mw_MemtoReg), 
       .write_data(write_data), .err(errW)
       );

// Errors for all the stages
assign err = errF | errD | errX | errM | errW;

///////////////////////////////////////////////////////////////// Hazard Unit ///////////////////////////////////////////////////////////

wire FD_NOP, DE_NOP, EM_NOP, MW_NOP;

hazard h0(.clk(clk), .rst(rst), .PCSrc(PCSrc), .stall(createdump), .FD_NOP(FD_NOP), .DE_NOP(DE_NOP), .EM_NOP(EM_NOP), .MW_NOP(MW_NOP), 
.ID_EX_MemRead(de_MemRead), .IF_ID_RegisterRs(fd_readReg1), .IF_ID_RegisterRt(fd_readReg2), .ID_EX_RegisterRs(de_readReg1), .ID_EX_RegisterRt(de_readReg2), 
.EX_MEM_RegWrite(em_RegWrite), .EX_MEM_RegisterRd(em_writeReg), .MEM_WB_RegWrite(), .MEM_WB_RegisterRd(mw_writeReg));
   
endmodule // proc
// DUMMY LINE FOR REV CONTROL :0:
