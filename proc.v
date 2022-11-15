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


// Hazard signals
wire FD_NOP, DE_NOP, EM_NOP, MW_NOP;

// errors
wire errF, errD, errX, errM, errW;
wire createdump;

// fetch inputs
wire [15:0] fin_next_PC;
wire [15:0] de_next_PC, fd_next_PC;


// fetch outputs
wire [15:0] fout_PC_2, fout_instruction, fout_PC;
// wire createdump_dummy;

// assign createdump_dummy = createdump;
// assign createdump = MW_NOP;

fetch fetch0(.next_PC(fd_next_PC), .clk(clk), .rst(rst), 
             .PC_2(fout_PC_2), .instruction(fout_instruction), .err(errF), 
            .fetch_enable(1'b1), .createdump(createdump), .PC(fout_PC)
            );

///////////////////////////////////////////////////////// F/D pipeline registers ///////////////////////////////////////////////////////
// F/D flopped wires
wire [15:0] fd_instruction, fd_PC_2, fd_PC;
wire [2:0] fd_readReg1, fd_readReg2;


// F/D mux wires
wire [15:0] fd_mux_instruction, fd_mux_PC_2, fd_mux_PC, fd_mux_next_PC;
wire [2:0] fd_mux_readReg1, fd_mux_readReg2;

// F/D muxes
// Set control signals to 0 if FD_NOP = 1
assign fd_mux_instruction = (FD_NOP) ? 16'b0000100000000000 : (rst) ? 16'b0000100000000000 : fout_instruction;
assign fd_mux_PC_2 = (FD_NOP) ? 4'h0000 : fout_PC_2;
assign fd_mux_PC = (FD_NOP) ? 4'h0000 : fout_PC;
assign fd_mux_readReg1 = (FD_NOP) ? 3'b000 : fout_instruction[10:8];
assign fd_mux_readReg2 = (FD_NOP) ? 3'b000 : fout_instruction[7:5];
assign fd_mux_next_PC = FD_NOP ? 3'b000 : de_next_PC;

// F/D registers
dff_N #(.N(16)) reg_fd_instruction (.q(fd_instruction), .d(fd_mux_instruction), .clk(clk), .rst(1'b0));
dff_N #(.N(16)) reg_fd_PC_2 (.q(fd_PC_2), .d(fd_mux_PC_2), .clk(clk), .rst(rst));
dff_N #(.N(16)) reg_fd_PC (.q(fd_PC), .d(fd_mux_PC), .clk(clk), .rst(rst));
dff_N #(.N(16)) reg_fd_next_PC (.q(fd_next_PC), .d(fd_mux_next_PC), .clk(clk), .rst(rst));
dff_N #(.N(3)) reg_fd_readReg1 (.q(fd_readReg1), .d(fd_mux_readReg1), .clk(clk), .rst(rst));
dff_N #(.N(3)) reg_fd_readReg2 (.q(fd_readReg2), .d(fd_mux_readReg2), .clk(clk), .rst(rst));

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// decode inputs
wire [15:0] write_data; // pretty sure needs to be flopped in F/D where input comes from WB instead of F

// decode outputs
wire dout_ALUSrc, dout_is_SLBI, dout_is_LBI, dout_MemRead, dout_MemWrite, dout_MemtoReg, dout_sign, dout_invA, dout_invB, dout_Cin, dout_fetch_enable, dout_is_branch, dout_RegWrite;
wire [2:0] dout_PCSrc, dout_writeReg, dout_readReg1, dout_readReg2;
wire [4:0] dout_ALUOp;
wire [15:0] dout_read_data_1, dout_read_data_2, dout_Immd, dout_PC_2_I, dout_PC_2_D;

decode decode0(.clk(clk), .rst(rst), .instruction(fd_instruction), 
               .PC_2(fd_PC_2), .write_data(write_data), .read_data_1(dout_read_data_1), 
               .read_data_2(dout_read_data_2), .Immd(dout_Immd), .PC_2_I(dout_PC_2_I), 
               .PC_2_D(dout_PC_2_D), .ALUSrc(dout_ALUSrc), .is_SLBI(dout_is_SLBI), 
               .is_LBI(dout_is_LBI), .MemRead(dout_MemRead), .MemWrite(dout_MemWrite), 
               .MemtoReg(dout_MemtoReg), .sign(dout_sign), .invA(dout_invA), 
               .invB(dout_invB), .Cin(dout_Cin), .PCSrc(dout_PCSrc), 
               .ALUOp(dout_ALUOp), .fetch_enable(dout_fetch_enable), .is_branch(dout_is_branch), 
               .createdump(createdump), .err(errD), .writeReg(dout_writeReg), .readReg1(dout_readReg1), .readReg2(dout_readReg2), .RegWrite(dout_RegWrite)
               );

//////////////////////////////////////////////////////// D/E pipeline register //////////////////////////////////////////////////////////
// D/E flopped wires
wire [15:0] de_read_data_1, de_read_data_2, de_PC_2, de_PC_2_I, de_PC_2_D, de_PC, de_Immd;
wire de_ALUSrc, de_invA, de_invB, de_sign, de_Cin, de_is_SLBI, de_is_LBI, de_MemRead, de_MemtoReg, de_RegWrite, de_MemWrite, de_is_branch;
wire [2:0] de_readReg1, de_readReg2, de_writeReg, de_PCSrc;
wire [4:0] de_ALUOp;

wire [15:0] next_PC;

// D/E mux wires
wire [15:0] de_mux_next_PC, de_mux_read_data_1, de_mux_read_data_2, de_mux_PC_2, de_mux_PC_2_I, de_mux_PC_2_D, de_mux_PC, de_mux_Immd;
wire de_mux_ALUSrc, de_mux_invA, de_mux_invB, de_mux_sign, de_mux_Cin, de_mux_is_SLBI, de_mux_is_LBI, de_mux_MemRead, de_mux_MemtoReg, de_mux_RegWrite, de_mux_MemWrite, de_mux_is_branch;
wire [2:0] de_mux_readReg1, de_mux_readReg2, de_mux_writeReg, de_mux_PCSrc;
wire [4:0] de_mux_ALUOp;

// D/E muxes 
// Set control signals to 0 if DE_NOP = 1
assign de_mux_next_PC = (DE_NOP) ? 4'h000 : next_PC;
assign de_mux_read_data_1 = (DE_NOP) ? 4'h000 : dout_read_data_1;
assign de_mux_read_data_2 = (DE_NOP) ? 4'h000 : dout_read_data_2;
assign de_mux_PC_2 = (DE_NOP) ? 4'h000 : fd_PC_2;
assign de_mux_PC_2_I = (DE_NOP) ? 4'h000 : dout_PC_2_I;
assign de_mux_PC_2_D = (DE_NOP) ? 4'h000 : dout_PC_2_D;
assign de_mux_PC = (DE_NOP) ? 4'h000 : fd_PC;
assign de_mux_Immd = (DE_NOP) ? 4'h000 : dout_Immd;
assign de_mux_ALUSrc = (DE_NOP) ? 1'b0 : dout_ALUSrc;
assign de_mux_invA = (DE_NOP) ? 1'b0 : dout_invA;
assign de_mux_invB = (DE_NOP) ? 1'b0 : dout_invB;
assign de_mux_sign = (DE_NOP) ? 1'b0 : dout_sign;
assign de_mux_Cin = (DE_NOP) ? 1'b0 : dout_Cin;
assign de_mux_is_SLBI = (DE_NOP) ? 1'b0 : dout_is_SLBI;
assign de_mux_is_LBI = (DE_NOP) ? 1'b0 : dout_is_LBI;
assign de_mux_MemRead = (DE_NOP) ? 1'b0 : dout_MemRead;
assign de_mux_MemtoReg = (DE_NOP) ? 1'b0 : dout_MemtoReg;
assign de_mux_RegWrite = (DE_NOP) ? 1'b0 : dout_RegWrite;
assign de_mux_MemWrite = (DE_NOP) ? 1'b0 : dout_MemWrite;
assign de_mux_is_branch = (DE_NOP) ? 1'b0 : dout_is_branch;
assign de_mux_readReg1 = (DE_NOP) ? 3'b000 : dout_readReg1;
assign de_mux_readReg2 = (DE_NOP) ? 3'b000 : dout_readReg2;
assign de_mux_writeReg = (DE_NOP) ? 3'b000 : dout_writeReg;
assign de_mux_PCSrc = (DE_NOP) ? 3'b000 : dout_PCSrc;
assign de_mux_ALUOp = (DE_NOP) ? 5'b00000 : dout_ALUOp;

// D/E registers
dff_N #(.N(16)) reg_de_next_PC (.q(de_next_PC), .d(de_mux_next_PC), .clk(clk), .rst(rst));
dff_N #(.N(16)) reg_de_read_data_1 (.q(de_read_data_1), .d(de_mux_read_data_1), .clk(clk), .rst(rst));
dff_N #(.N(16)) reg_de_read_data_2 (.q(de_read_data_2), .d(de_mux_read_data_2), .clk(clk), .rst(rst));
dff_N #(.N(16)) reg_de_PC_2 (.q(de_PC_2), .d(de_mux_PC_2), .clk(clk), .rst(rst));
dff_N #(.N(16)) reg_de_PC_2_I (.q(de_PC_2_I), .d(de_mux_PC_2_I), .clk(clk), .rst(rst));
dff_N #(.N(16)) reg_de_PC_2_D (.q(de_PC_2_D), .d(de_mux_PC_2_D), .clk(clk), .rst(rst));
dff_N #(.N(16)) reg_de_PC (.q(de_PC), .d(de_mux_PC), .clk(clk), .rst(rst));
dff_N #(.N(16)) reg_de_Immd (.q(de_Immd), .d(de_mux_Immd), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_de_ALUSrc (.q(de_ALUSrc), .d(de_mux_ALUSrc), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_de_invA(.q(de_invA), .d(de_mux_invA), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_de_invB(.q(de_invB), .d(de_mux_invB), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_de_sign(.q(de_sign), .d(de_mux_sign), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_de_Cin(.q(de_Cin), .d(de_mux_Cin), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_de_is_SLBI(.q(de_is_SLBI), .d(de_mux_is_SLBI), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_de_is_LBI(.q(de_is_LBI), .d(de_mux_is_LBI), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_de_MemRead(.q(de_MemRead), .d(de_mux_MemRead), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_de_MemtoReg(.q(de_MemtoReg), .d(de_mux_MemtoReg), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_de_reg_wr (.q(de_RegWrite), .d(de_mux_RegWrite), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_de_MemWrite(.q(de_MemWrite), .d(de_mux_MemWrite), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_de_is_branch(.q(de_is_branch), .d(de_mux_is_branch), .clk(clk), .rst(rst));
dff_N #(.N(3)) reg_de_reg_rs (.q(de_readReg1), .d(de_mux_readReg1), .clk(clk), .rst(rst));
dff_N #(.N(3)) reg_de_reg_rt (.q(de_readReg2), .d(de_mux_readReg2), .clk(clk), .rst(rst));
dff_N #(.N(3)) reg_de_reg_rd (.q(de_writeReg), .d(de_mux_writeReg), .clk(clk), .rst(rst));
dff_N #(.N(3)) reg_de_PCSrc (.q(de_PCSrc), .d(de_mux_PCSrc), .clk(clk), .rst(rst));
dff_N #(.N(5)) reg_de_ALUOp (.q(de_ALUOp), .d(de_mux_ALUOp), .clk(clk), .rst(rst));


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// execute output
wire [15:0] ALU_Result;

execute execute0(.Immd(de_Immd), .read_data_1(de_read_data_1), .read_data_2(de_read_data_2), 
                 .PC_2(de_PC_2), .PC_2_I(de_PC_2_I), .PC_2_D(de_PC_2_D), 
                 .ALUSrc(de_ALUSrc), .invA(de_invA), .invB(de_invB), 
                 .sign(de_sign), .Cin(de_Cin), .is_LBI(de_is_LBI), 
                 .is_SLBI(de_is_SLBI), .PCSrc(de_PCSrc), .ALUOp(de_ALUOp), 
                 .next_PC(next_PC), .ALU_Result_out(ALU_Result), .err(errX), 
                 .is_branch(de_is_branch), .PC(de_PC)
                 );

///////////////////////////////////////////////// E/M pipeline register ///////////////////////////////////////////////////////////////
// E/M flopped wires
wire em_MemRead, em_MemWrite, em_MemtoReg, em_RegWrite;
wire [15:0] em_ALU_Result, em_read_data_2;
wire [2:0] em_readReg1, em_readReg2, em_writeReg;

// E/M mux wires
wire em_mux_MemRead, em_mux_MemWrite, em_mux_MemtoReg, em_mux_RegWrite;
wire [15:0] em_mux_ALU_Result, em_mux_read_data_2;
wire [2:0] em_mux_readReg1, em_mux_readReg2, em_mux_writeReg;

// E/M muxes
// Set control signals to 0 if EM_NOP = 1
assign em_mux_MemRead = (EM_NOP) ? 1'b0 : de_MemRead;
assign em_mux_MemWrite = (EM_NOP) ? 1'b0 : de_MemWrite;
assign em_mux_MemtoReg = (EM_NOP) ? 1'b0 : de_MemtoReg;
assign em_mux_RegWrite = (EM_NOP) ? 1'b0 : de_RegWrite;

assign em_mux_ALU_Result = (EM_NOP) ? 4'h0000 : ALU_Result;
assign em_mux_read_data_2 = (EM_NOP) ? 4'h0000 : de_read_data_2;
assign em_mux_readReg1 = (EM_NOP) ? 3'b000 : de_readReg1;
assign em_mux_readReg2 = (EM_NOP) ? 3'b000 : de_readReg2;
assign em_mux_writeReg = (EM_NOP) ? 3'b000 : de_writeReg;

// E/M registers
dff_N #(.N(16)) reg_em_ALU_Result(.q(em_ALU_Result), .d(em_mux_ALU_Result), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_em_MemRead(.q(em_MemRead), .d(em_mux_MemRead), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_em_MemWrite(.q(em_MemWrite), .d(em_mux_MemWrite), .clk(clk), .rst(rst));
dff_N #(.N(16)) reg_em_read_data_2(.q(em_read_data_2), .d(em_mux_read_data_2), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_em_MemtoReg(.q(em_MemtoReg), .d(em_mux_MemtoReg), .clk(clk), .rst(rst));
dff_N #(.N(3)) reg_em_reg_rs (.q(em_readReg1), .d(em_mux_readReg1), .clk(clk), .rst(rst));
dff_N #(.N(3)) reg__em_reg_rt (.q(em_readReg2), .d(em_mux_readReg2), .clk(clk), .rst(rst));
dff_N #(.N(3)) reg_em_reg_rd (.q(em_writeReg), .d(em_mux_writeReg), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_em_reg_wr (.q(em_RegWrite), .d(em_mux_RegWrite), .clk(clk), .rst(rst));

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// memory outputs
wire [15:0] read_data;

memory memory0(.ALU_result(em_ALU_Result), .read_data_in(em_read_data_2), .MemRead(em_MemRead), 
               .MemWrite(em_MemWrite), .read_data_out(read_data), .clk(clk), 
               .rst(rst), .createdump(createdump), .err(errM)
               );

//////////////////////////////////////////////////////// M/W pipeline register /////////////////////////////////////////////////////////
// M/W flopped wires
wire [15:0] mw_read_data, mw_ALU_Result;
wire [2:0] mw_readReg1, mw_readReg2, mw_writeReg;
wire mw_RegWrite, mw_MemtoReg;

// M/W mux wires
wire [15:0] mw_mux_read_data, mw_mux_ALU_Result;
wire mw_mux_MemtoReg;

// M/W muxes
// Set control signals to 0 if MW_NOP = 1
assign mw_mux_ALU_Result = (MW_NOP) ? 4'h0000 : em_ALU_Result;
assign mw_mux_read_data =  (MW_NOP) ? 4'h0000 : read_data;
assign mw_mux_MemtoReg  =  (MW_NOP) ? 1'b0 : em_MemtoReg;

// M/W registers
dff_N #(.N(16)) reg_mw_ALU_Result(.q(mw_ALU_Result), .d(mw_mux_ALU_Result), .clk(clk), .rst(rst));
dff_N #(.N(16)) reg_mw_read_data(.q(mw_read_data), .d(mw_mux_read_data), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_mw_MemtoReg(.q(mw_MemtoReg), .d(mw_mux_MemtoReg), .clk(clk), .rst(rst));
dff_N #(.N(3)) reg_mw_reg_rs (.q(mw_readReg1), .d(em_readReg1), .clk(clk), .rst(rst));
dff_N #(.N(3)) reg__mw_reg_rt (.q(mw_readReg2), .d(em_readReg2), .clk(clk), .rst(rst));
dff_N #(.N(3)) reg_mw_reg_rd (.q(mw_writeReg), .d(em_writeReg), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_mw_reg_wr (.q(mw_RegWrite), .d(em_RegWrite), .clk(clk), .rst(rst));

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

wb wb0(.ALU_result(mw_ALU_Result), .read_data(mw_read_data), .MemtoReg(mw_MemtoReg), 
       .write_data(write_data), .err(errW)
       );

// Errors for all the stages
assign err = errF | errD | errX | errM | errW;

///////////////////////////////////////////////////////////////// Hazard Unit ///////////////////////////////////////////////////////////

hazard h0(.clk(clk), .rst(rst), .PCSrc(de_PCSrc), .stall(createdump), .FD_NOP(FD_NOP), .DE_NOP(DE_NOP), .EM_NOP(EM_NOP), .MW_NOP(MW_NOP), 
.ID_EX_MemRead(de_MemRead), .IF_ID_RegisterRs(fd_readReg1), .IF_ID_RegisterRt(fd_readReg2), .ID_EX_RegisterRs(de_readReg1), .ID_EX_RegisterRt(de_readReg2), 
.EX_MEM_RegWrite(em_RegWrite), .EX_MEM_RegisterRd(em_writeReg), .MEM_WB_RegWrite(mw_RegWrite), .MEM_WB_RegisterRd(mw_writeReg));
   
endmodule // proc
// DUMMY LINE FOR REV CONTROL :0:
