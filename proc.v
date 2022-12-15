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

parameter NOP = 16'b0000100000000000;

// Hazard signals
wire insert_nop; 
// assign insert_nop = 1'b0;

// errors
wire errF, errD, errX, errM, errW;
wire d_mem_err, i_mem_err;
wire createdump, Stall;

// fetch signals
wire [15:0] fout_PC_2, fout_instruction, fout_PC;
wire [15:0] fin_next_PC;
wire [2:0] dout_PCSrc;

///////////////////////////////////////////////////////// FETCH ////////////////////////////////////////////////////////////////////////
// F/D flopped wires
wire [15:0] fd_instruction, fd_PC_2, fd_PC, fd_next_PC, fd_mux_instruction, fd_write_data, write_data, dout_PC_2_I, 
dout_PC_2_D, eout_branch, eout_ALU_Result, de_PC;
wire mw_halt;
// wire [2:0] fd_readReg1, fd_readReg2;
wire de_is_branch, branch_is_taken_out; 

fetch f0(.PCSrc(dout_PCSrc), .PC_2_out(fout_PC_2), .clk(clk), .rst(rst), .instruction(fout_instruction), 
	.fetch_enable(1'b1), .createdump(mw_halt), .err(i_mem_err),
 	.is_branch(de_is_branch), .insert_nop(insert_nop), .ALU_Result_in(eout_ALU_Result), .PC_2_I_in(dout_PC_2_I), 
	.PC_2_D_in(dout_PC_2_D), .currPC(fout_PC), .branch_is_taken(branch_is_taken_out), .Stall(Stall)); 

// F/D muxes
// Flushes instructions in fd and de pipeline if branch detected
assign fd_mux_instruction = (insert_nop | branch_is_taken_out) ? NOP : (rst) ? NOP : fout_instruction; // prevents accidental halt

///////////////////////////////////////////////////////// F/D pipeline registers ///////////////////////////////////////////////////////
wire writeEn;
assign writeEn = (~Stall) | (~insert_nop);
// assign writeEn = (~insert_nop);

reg_16b reg_fd_instruction(.Q(fd_instruction), .D(fd_mux_instruction), .clk(clk), .rst(rst), .writeEn(writeEn));
reg_16b reg_fd_PC_2(.Q(fd_PC_2), .D(fout_PC_2), .clk(clk), .rst(rst), .writeEn(writeEn));

wire fd_Stall;
reg_1b reg_I_mem_stall_f(.Q(fd_Stall), .D(Stall), .clk(clk), .rst(rst), .writeEn(writeEn));

// Error pipelined for stall memory
wire fd_i_mem_err, de_i_mem_err, em_i_mem_err, mw_i_mem_err;
reg_1b reg_i_mem_err_f(.Q(fd_i_mem_err), .D(i_mem_err), .clk(clk), .rst(rst), .writeEn(writeEn));

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// decode outputs: Control signals
wire dout_ALUSrc, dout_is_SLBI, dout_is_LBI, dout_MemRead, dout_MemWrite, dout_MemtoReg, dout_sign, dout_invA, dout_invB, dout_Cin, 
dout_fetch_enable, dout_RegWrite;


wire [2:0] dout_writeReg, dout_readReg1, dout_readReg2;
wire [4:0] dout_ALUOp;
wire [15:0] dout_read_data_1, dout_read_data_2, dout_Immd, de_PC_2_I, de_PC_2_D, dout_write_data, mw_write_data;
wire [2:0] mw_writeReg;
wire de_RegWrite, em_RegWrite, mw_RegWrite; 

// Handle relax passing
wire stall_or_write;
assign stall_or_write = (Stall == 1'b1) ? 1'b0 : mw_RegWrite;
// put in mw_RegWrite port of decode

decode decode0(.clk(clk), .rst(rst), .instruction(fd_mux_instruction), 
               .PC_2(fd_PC_2), .write_data(write_data), .regWrSel(mw_writeReg), .read_data_1(dout_read_data_1), 
               .read_data_2(dout_read_data_2), .Immd(dout_Immd), .PC_2_I(dout_PC_2_I), 
               .PC_2_D(dout_PC_2_D), .ALUSrc(dout_ALUSrc), .is_SLBI(dout_is_SLBI), 
               .is_LBI(dout_is_LBI), .MemRead(dout_MemRead), .MemWrite(dout_MemWrite), 
               .MemtoReg(dout_MemtoReg), .sign(dout_sign), .invA(dout_invA), 
               .invB(dout_invB), .Cin(dout_Cin), .PCSrc(dout_PCSrc), 
               .ALUOp(dout_ALUOp), .fetch_enable(dout_fetch_enable), .is_branch(dout_is_branch), 
               .createdump(createdump), .err(errD), .writeReg(dout_writeReg), .readReg1(dout_readReg1), .readReg2(dout_readReg2), 
		.RegWrite(dout_RegWrite), .mw_RegWrite(stall_or_write), .Stall(Stall)
               );

//////////////////////////////////////////////////////// D/E pipeline registers //////////////////////////////////////////////////////////
// D/E flopped wires
wire [15:0] de_read_data_1, de_read_data_2, de_PC_2, de_Immd, de_next_PC, de_write_data;
wire de_ALUSrc, de_invA, de_invB, de_sign, de_Cin, de_is_SLBI, de_is_LBI, de_MemRead, de_MemtoReg, de_MemWrite;
wire [2:0] de_readReg1, de_readReg2, de_writeReg, de_PCSrc;
wire [4:0] de_ALUOp;


// D/E mux wires
wire de_mux_ALUSrc, de_mux_invA, de_mux_invB, de_mux_sign, de_mux_Cin, de_mux_is_SLBI, de_mux_is_LBI, de_mux_MemRead, de_mux_MemtoReg, 
de_mux_RegWrite, de_mux_MemWrite, de_mux_is_branch, de_halt;
wire [2:0] de_mux_PCSrc;
wire [4:0] de_mux_ALUOp;

// Stalling pipelined
wire de_Stall;
reg_1b reg_I_mem_stall_d(.Q(de_Stall), .D(fd_Stall), .clk(clk), .rst(rst), .writeEn(1'b1));


// Control signals: Set control signals to 0 if insert_nop = 1  

wire set_zero;
assign set_zero = rst | insert_nop;
// assign set_zero = rst;
// assign writeEn = (~de_Stall) | (~insert_nop);
// assign writeEn = (~Stall) | (~insert_nop);

// Control signals pipelined
reg_1b reg_de_ALUSrc(.Q(de_ALUSrc), .D(dout_ALUSrc), .clk(clk), .rst(set_zero), .writeEn(writeEn));
reg_1b reg_de_invA(.Q(de_invA), .D(dout_invA), .clk(clk), .rst(set_zero), .writeEn(writeEn)); 
reg_1b reg_de_invB(.Q(de_invB), .D(dout_invB), .clk(clk), .rst(set_zero), .writeEn(writeEn)); 
reg_1b reg_de_sign(.Q(de_sign), .D(dout_sign), .clk(clk), .rst(set_zero), .writeEn(writeEn)); 
reg_1b reg_de_Cin(.Q(de_Cin), .D(dout_Cin), .clk(clk), .rst(set_zero), .writeEn(writeEn)); 
reg_1b reg_de_is_SLBI(.Q(de_is_SLBI), .D(dout_is_SLBI), .clk(clk), .rst(set_zero), .writeEn(writeEn)); 
reg_1b reg_de_is_LBI(.Q(de_is_LBI), .D(dout_is_LBI), .clk(clk), .rst(set_zero), .writeEn(writeEn));
reg_1b reg_de_MemRead(.Q(de_MemRead), .D(dout_MemRead), .clk(clk), .rst(set_zero), .writeEn(writeEn));
reg_1b reg_de_MemtoReg(.Q(de_MemtoReg), .D(dout_MemtoReg), .clk(clk), .rst(set_zero), .writeEn(writeEn));
reg_1b reg_de_RegWrite(.Q(de_RegWrite), .D(dout_RegWrite), .clk(clk), .rst(set_zero), .writeEn(writeEn));
reg_1b reg_de_MemWrite(.Q(de_MemWrite), .D(dout_MemWrite), .clk(clk), .rst(set_zero), .writeEn(writeEn));
reg_5b reg_de_ALUOp(.Q(de_ALUOp), .D(dout_ALUOp), .clk(clk), .rst(set_zero), .writeEn(writeEn));
reg_1b reg_de_halt(.Q(de_halt), .D(createdump), .clk(clk), .rst(set_zero), .writeEn(writeEn));
reg_1b reg_de_is_branch(.Q(de_is_branch), .D(dout_is_branch), .clk(clk), .rst(set_zero), .writeEn(writeEn));

// Registers pipelined
reg_3b reg_de_reg_rd(.Q(de_writeReg), .D(dout_writeReg), .clk(clk), .rst(rst), .writeEn(writeEn));
reg_3b reg_de_reg_rs(.Q(de_readReg1), .D(dout_readReg1), .clk(clk), .rst(rst), .writeEn(writeEn));
reg_3b reg_de_reg_rt(.Q(de_readReg2), .D(dout_readReg2), .clk(clk), .rst(rst), .writeEn(writeEn));

reg_16b reg_de_Immd(.Q(de_Immd), .D(dout_Immd), .clk(clk), .rst(rst), .writeEn(writeEn));
reg_16b reg_de_read_data_2(.Q(de_read_data_2), .D(dout_read_data_2), .clk(clk), .rst(rst), .writeEn(writeEn));
reg_16b reg_de_read_data_1 (.Q(de_read_data_1), .D(dout_read_data_1), .clk(clk), .rst(rst), .writeEn(writeEn));

// Error pipelined
reg_1b reg_i_mem_err_d(.Q(de_i_mem_err), .D(fd_i_mem_err), .clk(clk), .rst(rst), .writeEn(writeEn));

wire [15:0] mw_read_data_1, mw_read_data_2, em_read_data_2, em_read_data_1;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

execute execute0(.Immd(de_Immd), .read_data_1(de_read_data_1), .read_data_2(de_read_data_2), 
                 .ALUSrc(de_ALUSrc), .invA(de_invA), .invB(de_invB), 
                 .sign(de_sign), .Cin(de_Cin), .is_LBI(de_is_LBI), 
                 .is_SLBI(de_is_SLBI), .ALUOp(de_ALUOp), 
                 .ALU_Result_out(eout_ALU_Result), .err(errX)
                 );

// If branch taken, flush the instructions in fd and de

///////////////////////////////////////////////// E/M pipeline registers ///////////////////////////////////////////////////////////////
// E/M flopped wires
wire em_MemRead, em_MemWrite, em_MemtoReg, em_halt;
wire [15:0] em_ALU_Result, em_write_data;
wire [2:0] em_readReg1, em_readReg2, em_writeReg;

// NO NEED TO MUX, nop detected in decode/execute stage

wire em_Stall;
reg_1b reg_I_mem_stall_e(.Q(em_Stall), .D(de_Stall), .clk(clk), .rst(rst), .writeEn(1'b1));

wire writeEn_em; 
// assign writeEn_em = (~em_Stall) | (~insert_nop);
assign writeEn_em = (~Stall) | (~insert_nop); 

// E/M registers
reg_16b reg_em_ALU_Result(.Q(em_ALU_Result), .D(eout_ALU_Result), .clk(clk), .rst(rst), .writeEn(writeEn_em));
reg_1b reg_em_MemRead(.Q(em_MemRead), .D(de_MemRead), .clk(clk), .rst(rst), .writeEn(writeEn_em));
reg_1b reg_em_MemWrite(.Q(em_MemWrite), .D(de_MemWrite), .clk(clk), .rst(rst), .writeEn(writeEn_em));
reg_16b reg_em_read_data_2(.Q(em_read_data_2), .D(de_read_data_2), .clk(clk), .rst(rst), .writeEn(writeEn_em));
reg_16b reg_em_read_data_1(.Q(em_read_data_1), .D(de_read_data_1), .clk(clk), .rst(rst), .writeEn(writeEn_em));

// Needed later
reg_1b reg_em_MemtoReg(.Q(em_MemtoReg), .D(de_MemtoReg), .clk(clk), .rst(rst), .writeEn(writeEn_em));
reg_3b reg_em_reg_rd(.Q(em_writeReg), .D(de_writeReg), .clk(clk), .rst(rst), .writeEn(writeEn_em));
reg_1b reg_em_halt(.Q(em_halt), .D(de_halt), .clk(clk), .rst(rst), .writeEn(writeEn_em));
reg_1b reg_em_reg_wr(.Q(em_RegWrite), .D(de_RegWrite), .clk(clk), .rst(rst), .writeEn(writeEn_em)); 
reg_3b reg_em_reg_rs(.Q(em_readReg1), .D(de_readReg1), .clk(clk), .rst(rst), .writeEn(writeEn_em));
reg_3b reg_em_reg_rt(.Q(em_readReg2), .D(de_readReg2), .clk(clk), .rst(rst), .writeEn(writeEn_em));

wire [15:0] em_instruction;
// dff_N #(.N(16)) reg_em_instruction(.Q(em_instruction), .D(de_instruction), .clk(clk), .rst(rst));
reg_1b reg_i_mem_err_e(.Q(em_i_mem_err), .D(de_i_mem_err), .clk(clk), .rst(rst), .writeEn(writeEn_em));


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// memory outputs
wire [15:0] read_data;
// I-Cache signals
wire i_done /* I sure am*/, i_cacheHit;
wire i_stall;

memory memory0(.ALU_result(em_ALU_Result), .read_data_in(em_read_data_2), .MemRead(em_MemRead), 
               .MemWrite(em_MemWrite), .read_data_out(read_data), .clk(clk), .rst(rst), .createdump(em_halt), .err(errM));                


//////////////////////////////////////////////////////// M/W pipeline register /////////////////////////////////////////////////////////
// M/W flopped wires
wire [15:0] mw_read_data, mw_ALU_Result;
wire [2:0] mw_readReg1, mw_readReg2;
wire mw_MemtoReg, mw_MemRead, mw_MemWrite, mw_d_mem_err;


wire mw_Stall;
reg_1b reg_I_mem_stall_m(.Q(mw_Stall), .D(em_Stall), .clk(clk), .rst(rst), .writeEn(1'b1));

wire writeEn_mw; 
// assign writeEn_mw = (~mw_Stall) | (~insert_nop);
assign writeEn_mw = (~Stall) | (~insert_nop);

// M/W registers
reg_16b reg_mw_ALU_Result(.Q(mw_ALU_Result), .D(em_ALU_Result), .clk(clk), .rst(rst), .writeEn(writeEn_mw));
reg_16b reg_mw_read_data(.Q(mw_read_data), .D(read_data), .clk(clk), .rst(rst), .writeEn(writeEn_mw));
reg_1b reg_mw_MemtoReg(.Q(mw_MemtoReg), .D(em_MemtoReg), .clk(clk), .rst(rst), .writeEn(writeEn_mw));
reg_3b reg_mw_reg_rd(.Q(mw_writeReg), .D(em_writeReg), .clk(clk), .rst(rst), .writeEn(writeEn_mw));
reg_1b reg_mw_halt(.Q(mw_halt), .D(em_halt), .clk(clk), .rst(rst), .writeEn(writeEn_mw));
reg_1b reg_mw_reg_wr(.Q(mw_RegWrite), .D(em_RegWrite), .clk(clk), .rst(rst), .writeEn(writeEn_mw));
reg_16b reg_mw_read_data_2(.Q(mw_read_data_2), .D(em_read_data_2), .clk(clk), .rst(rst), .writeEn(writeEn_mw));
reg_16b reg_mw_read_data_1(.Q(mw_read_data_1), .D(em_read_data_1), .clk(clk), .rst(rst), .writeEn(writeEn_mw));
reg_3b reg_mw_reg_rs(.Q(mw_readReg1), .D(em_readReg1), .clk(clk), .rst(rst), .writeEn(writeEn_mw));
reg_3b reg_mw_reg_rt(.Q(mw_readReg2), .D(em_readReg2), .clk(clk), .rst(rst), .writeEn(writeEn_mw));

// Pipeline error to write back 
reg_1b reg_d_mem_err(.Q(mw_d_mem_err), .D(d_mem_err), .clk(clk), .rst(rst), .writeEn(writeEn_mw));
reg_1b reg_i_mem_err_m(.Q(mw_i_mem_err), .D(em_i_mem_err), .clk(clk), .rst(rst), .writeEn(writeEn_mw));

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

wb wb0(.ALU_result(mw_ALU_Result), .read_data(mw_read_data), .MemtoReg(mw_MemtoReg), 
       .write_data(write_data), .err(errW)
       );


// Pipeline err from fetch and memory
assign err = mw_d_mem_err | mw_i_mem_err; 

wire wb_RegWrite;
wire [2:0] wb_writeReg; 

// Pipeline for hazard unit
dff_N #(.N(1)) reg_wb_reg_wr (.q(wb_RegWrite), .d(mw_RegWrite), .clk(clk), .rst(rst));
dff_N #(.N(3)) reg_wb_reg_rd (.q(wb_writeReg), .d(mw_writeReg), .clk(clk), .rst(rst));

///////////////////////////////////////////////////////////////// Hazard Unit ///////////////////////////////////////////////////////////

hazard h0(.PCSrc(dout_PCSrc), .clk(clk), .rst(rst), .de_MemRead(de_MemRead), .de_rt(de_readReg2), .fd_rs(fd_instruction[10:8]), 
.fd_rt(fd_instruction[7:5]), .insert_nop(insert_nop), .em_rd(em_writeReg), .em_RegWrite(em_RegWrite), .de_rs(de_readReg1),
.mw_rd(mw_writeReg), .mw_RegWrite(mw_RegWrite), .em_rs(em_readReg1), .em_rt(em_readReg2), .wb_RegWrite(wb_RegWrite), .wb_rd(wb_writeReg),
.de_RegWrite(de_RegWrite), .de_rd(de_writeReg), .mw_rs(mw_readReg1), .mw_rt(mw_readReg2), .dout_RegWrite(dout_RegWrite), 
.dout_rd(dout_writeReg), .opcode(fd_instruction[15:11]));


///////////////////////////////////////////////////////////////// Forwarding /////////////////////////////////////////////////////////////
   
endmodule // proc
// DUMMY LINE FOR REV CONTROL :0:
