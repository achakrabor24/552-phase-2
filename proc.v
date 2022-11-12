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
wire [15:0] PC_2, next_PC, instruction, write_data, Immd, read_data_1, read_data_2, ALU_Result, read_data, PC_2_I, PC_2_D;  

// errors
wire errF, errD, errX, errM, errW;

fetch fetch0(.next_PC(next_PC), .clk(clk), .rst(rst), 
             .PC_2(PC_2), .instruction(instruction), .err(errF), 
            .fetch_enable(fetch_enable), .createdump(createdump)
            );

// F/D pipeline registers
wire [15:0] fd_next_PC, fd_instruction, fd_PC_2;
dff_N #(.N(16)) reg_fd_next_PC (.q(fd_next_PC), .d(next_PC), .clk(clk), .rst(rst));
dff_N #(.N(16)) reg_fd_instruction (.q(fd_instruction), .d(instruction), .clk(clk), .rst(rst));
dff_N #(.N(16)) reg_fd_PC_2 (.q(fd_PC_2), .d(PC_2), .clk(clk), .rst(rst));
// TODO: decode->fetch, not sure if how to / if need to pipeline
// wire fd_fetch_enable;
// fetch_enable
// dff_N #(.N(16)) reg_fd_next_PC (.q(fd_fetch_enable), .d(fetch_enable), .clk(clk), .rst(rst));

decode decode0(.clk(clk), .rst(rst), .instruction(fd_instruction), 
               .PC_2(fd_PC_2), .write_data(write_data), .read_data_1(read_data_1), 
               .read_data_2(read_data_2), .Immd(Immd), .PC_2_I(PC_2_I), 
               .PC_2_D(PC_2_D), .ALUSrc(ALUSrc), .is_SLBI(is_SLBI), 
               .is_LBI(is_LBI), .MemRead(MemRead), .MemWrite(MemWrite), 
               .MemtoReg(MemtoReg), .sign(sign), .invA(invA), 
               .invB(invB), .Cin(Cin), .PCSrc(PCSrc), 
               .ALUOp(ALUOp), .fetch_enable(fetch_enable), .is_branch(is_branch), 
               .createdump(createdump), .err(err)
               );

// D/E pipeline register
wire [15:0] de_next_PC, de_read_data_1, de_read_data_2, de_PC_2, de_PC_2_I, de_PC_2_D;
wire de_Immd, de_ALUSrc, de_invA, de_invB, de_sign, Cin, de_is_SLBI, de_is_LBI, de_MemRead, de_MemtoReg;
dff_N #(.N(16)) reg_de_next_PC (.q(de_next_PC), .d(fd_next_PC), .clk(clk), .rst(rst));
dff_N #(.N(16)) reg_de_read_data_1 (.q(de_read_data_2), .d(read_data_1), .clk(clk), .rst(rst));
dff_N #(.N(16)) reg_de_read_data_2 (.q(de_read_data_2), .d(read_data_2), .clk(clk), .rst(rst));
dff_N #(.N(16)) reg_de_PC_2 (.q(de_PC_2), .d(fd_PC_2), .clk(clk), .rst(rst));
dff_N #(.N(16)) reg_de_PC_2_I (.q(de_PC_2_I), .d(PC_2_I), .clk(clk), .rst(rst));
dff_N #(.N(16)) reg_de_PC_2_D (.q(de_PC_2_D), .d(PC_2_D), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_de_Immd (.q(de_Immd), .d(Immd), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_de_ALUSrc (.q(de_ALUSrc), .d(ALUSrc), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_de_invA(.q(de_invA), .d(invA), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_de_invA(.q(de_invB), .d(invB), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_de_sign(.q(de_sign), .d(sign), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_de_Cin(.q(de_Cin), .d(Cin), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_de_is_SLBI(.q(de_is_SLBI), .d(is_SLBI), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_de_is_LBI(.q(de_is_LBI), .d(is_LBI), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_de_MemRead(.q(de_MemRead), .d(MemRead), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_de_MemWrite(.q(de_MemWrite), .d(MemWrite), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_de_MemtoReg(.q(de_MemtoReg), .d(MemtoReg), .clk(clk), .rst(rst));

execute execute0(.Immd(de_Immd), .read_data_1(de_read_data_1), .read_data_2(de_read_data_2), 
                 .PC_2(de_PC_2), .PC_2_I(de_PC_2_I), .PC_2_D(de_PC_2_D), 
                 .ALUSrc(de_ALUSrc), .invA(de_invA), .invB(de_invB), 
                 .sign(de_sign), .Cin(de_Cin), .is_LBI(de_is_LBI), 
                 .is_SLBI(is_SLBI), .PCSrc(PCSrc), .ALUOp(ALUOp), 
                 .next_PC(de_next_PC), .ALU_Result_out(ALU_Result), .err(errX), 
                 .is_branch(is_branch)
                 );

// E/M pipeline register
wire em_MemRead, em_MemWrite, em_read_data_2, em_MemtoReg;
wire [15:0] em_ALU_Result;

dff_N #(.N(16)) reg_em_ALU_Result(.q(em_ALU_Result), .d(ALU_Result), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_em_MemRead(.q(em_MemRead), .d(de_MemRead), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_em_MemWrite(.q(em_MemWrite), .d(de_MemWrite), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_em_read_data_2(.q(em_read_data_2), .d(de_read_data_2), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_em_MemtoReg(.q(em_MemtoReg), .d(de_MemtoReg), .clk(clk), .rst(rst));


memory memory0(.ALU_result(em_ALU_Result), .read_data_in(em_read_data_2), .MemRead(em_MemRead), 
               .MemWrite(em_MemWrite), .read_data_out(read_data), .clk(clk), 
               .rst(rst), .createdump(createdump), .err(errM)
               );

// M/W pipeline register
wire [15:0] mw_read_data, mw_ALU_Result, mw_MemtoReg;

dff_N #(.N(16)) reg_mw_ALU_Result(.q(mw_ALU_Result), .d(em_ALU_Result), .clk(clk), .rst(rst));
dff_N #(.N(16)) reg_mw_read_data(.q(mw_read_data), .d(read_data), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_mw_MemtoReg(.q(mw_MemtoReg), .d(em_MemtoReg), .clk(clk), .rst(rst));

wb wb0(.ALU_result(mw_ALU_Result), .read_data(mw_read_data), .MemtoReg(mw_MemtoReg), 
       .write_data(write_data), .err(errW)
       );

// Errors for all the stages
assign err = errF | errD | errX | errM | errW;
   
endmodule // proc
// DUMMY LINE FOR REV CONTROL :0:
