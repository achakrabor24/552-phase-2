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
wire insert_nop; 
assign insert_nop = 1'b0;

// errors
wire errF, errD, errX, errM, errW;
wire createdump;

// fetch 
wire [15:0] fout_PC_2, fout_instruction, fout_PC;
wire [15:0] fin_next_PC;
wire [2:0] dout_PCSrc;

///////////////////////////////////////////////////////// FETCH ////////////////////////////////////////////////////////////////////////
// F/D flopped wires
wire [15:0] fd_instruction, fd_PC_2, fd_PC, fd_next_PC, fd_mux_instruction, fd_write_data, write_data, dout_PC_2_I, 
dout_PC_2_D, eout_branch, eout_ALU_Result, de_PC, mw_halt;
wire [2:0] fd_readReg1, fd_readReg2;

fetch f0(.PCSrc(dout_PCSrc), .prev_PC(de_PC), .PC_2_out(fout_PC_2), .clk(clk), .rst(rst), .instruction(fout_instruction), 
	.fetch_enable(1'b1), .createdump(mw_halt), .err(errF),
 	.is_branch(dout_is_branch), .insert_nop(insert_nop), .ALU_Result_in(eout_ALU_Result), .PC_2_I_in(dout_PC_2_I), 
	.PC_2_D_in(dout_PC_2_D), .curr_PC(fout_PC));

// F/D muxes
assign fd_mux_instruction = (insert_nop) ? 16'b0000100000000000 : (rst) ? 16'b0000100000000000 : fout_instruction;

///////////////////////////////////////////////////////// F/D pipeline registers ///////////////////////////////////////////////////////

// F/D registers
dff_N #(.N(16)) reg_fd_instruction (.q(fd_instruction), .d(fd_mux_instruction), .clk(clk), .rst(1'b0));
dff_N #(.N(16)) reg_fd_PC_2 (.q(fd_PC_2), .d(fout_PC_2), .clk(clk), .rst(rst));

// dff_N #(.N(3)) reg_fd_readReg1 (.q(fd_readReg1), .d(fout_instruction[10:8]), .clk(clk), .rst(rst));
// dff_N #(.N(3)) reg_fd_readReg2 (.q(fd_readReg2), .d(fout_instruction[7:5]), .clk(clk), .rst(rst));
// dff_N #(.N(16)) reg_fd_write_data (.q(fd_write_data), .d(write_data), .clk(clk), .rst(rst));
// dff_N #(.N(16)) reg_fd_next_PC (.q(fd_next_PC), .d(fin_next_PC), .clk(clk), .rst(rst));
// dff_N #(.N(16)) reg_fd_PC (.q(fd_PC), .d(fout_PC), .clk(clk), .rst(rst));

// If you figure out you have a HALT in DECODE, there may be 3 other instructions in-flight in the other pipeline stages. 
// You should stop fetching instructions, but you should not tell the testbench your processor is "done" until the HALT 
// flows through WRITEBACK.


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// decode inputs

// decode outputs: Control signals
wire dout_ALUSrc, dout_is_SLBI, dout_is_LBI, dout_MemRead, dout_MemWrite, dout_MemtoReg, dout_sign, dout_invA, dout_invB, dout_Cin, 
dout_fetch_enable, dout_RegWrite;


wire [2:0] dout_writeReg, dout_readReg1, dout_readReg2;
wire [4:0] dout_ALUOp;
wire [15:0] dout_read_data_1, dout_read_data_2, dout_Immd, de_PC_2_I, de_PC_2_D;
wire [2:0] mw_writeReg;

decode decode0(.clk(clk), .rst(rst), .instruction(fd_instruction), 
               .PC_2(fd_PC_2), .write_data(write_data), .regWrSel(mw_writeReg), .read_data_1(dout_read_data_1), 
               .read_data_2(dout_read_data_2), .Immd(dout_Immd), .PC_2_I(dout_PC_2_I), 
               .PC_2_D(dout_PC_2_D), .ALUSrc(dout_ALUSrc), .is_SLBI(dout_is_SLBI), 
               .is_LBI(dout_is_LBI), .MemRead(dout_MemRead), .MemWrite(dout_MemWrite), 
               .MemtoReg(dout_MemtoReg), .sign(dout_sign), .invA(dout_invA), 
               .invB(dout_invB), .Cin(dout_Cin), .PCSrc(dout_PCSrc), 
               .ALUOp(dout_ALUOp), .fetch_enable(dout_fetch_enable), .is_branch(dout_is_branch), 
               .createdump(createdump), .err(errD), .writeReg(dout_writeReg), .readReg1(dout_readReg1), .readReg2(dout_readReg2), 
		.RegWrite(dout_RegWrite)
               );

//////////////////////////////////////////////////////// D/E pipeline register //////////////////////////////////////////////////////////
// D/E flopped wires
wire [15:0] de_read_data_1, de_read_data_2, de_PC_2, de_Immd, de_next_PC;
wire de_ALUSrc, de_invA, de_invB, de_sign, de_Cin, de_is_SLBI, de_is_LBI, de_MemRead, de_MemtoReg, de_RegWrite, de_MemWrite, de_is_branch;
wire [2:0] de_readReg1, de_readReg2, de_writeReg, de_PCSrc;
wire [4:0] de_ALUOp;


// D/E mux wires
wire de_mux_ALUSrc, de_mux_invA, de_mux_invB, de_mux_sign, de_mux_Cin, de_mux_is_SLBI, de_mux_is_LBI, de_mux_MemRead, de_mux_MemtoReg, 
de_mux_RegWrite, de_mux_MemWrite, de_mux_is_branch, de_halt;
wire [2:0] de_mux_PCSrc;
wire [4:0] de_mux_ALUOp;


// Control signals: Set control signals to 0 if insert_nop = 1  
assign de_mux_ALUSrc = (insert_nop) ? 1'b0 : dout_ALUSrc;
assign de_mux_invA = (insert_nop) ? 1'b0 : dout_invA;
assign de_mux_invB = (insert_nop) ? 1'b0  : dout_invB;
assign de_mux_sign = (insert_nop) ? 1'b0  : dout_sign;
assign de_mux_Cin = (insert_nop) ? 1'b0 : dout_Cin; // Is always low
assign de_mux_is_SLBI = (insert_nop) ? 1'b0 : dout_is_SLBI;
assign de_mux_is_LBI = (insert_nop) ? 1'b0 : dout_is_LBI;
assign de_mux_MemRead = (insert_nop) ? 1'b0 : dout_MemRead;
assign de_mux_MemtoReg = (insert_nop) ? 1'b0 : dout_MemtoReg;
assign de_mux_RegWrite = (insert_nop) ? 1'b0 : dout_RegWrite;
assign de_mux_MemWrite = (insert_nop) ? 1'b0 : dout_MemWrite;
assign de_mux_is_branch = (insert_nop) ? 1'b0 : dout_is_branch;
assign de_mux_PCSrc = (insert_nop) ? 2'b00 : dout_PCSrc; // Give next_PC the current PC
assign de_mux_ALUOp = (insert_nop) ? 5'b00000 : dout_ALUOp; // not sure if this should be something else


// D/E registers

// Control signals that are needed in the next stages
dff_N #(.N(1)) reg_de_ALUSrc (.q(de_ALUSrc), .d(de_mux_ALUSrc), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_de_invA(.q(de_invA), .d(de_mux_invA), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_de_invB(.q(de_invB), .d(de_mux_invB), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_de_sign(.q(de_sign), .d(de_mux_sign), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_de_Cin(.q(de_Cin), .d(de_mux_Cin), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_de_is_SLBI(.q(de_is_SLBI), .d(de_mux_is_SLBI), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_de_is_LBI(.q(de_is_LBI), .d(de_mux_is_LBI), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_de_MemRead(.q(de_MemRead), .d(de_mux_MemRead), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_de_MemtoReg(.q(de_MemtoReg), .d(de_mux_MemtoReg), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_de_reg_wr (.q(de_RegWrite), .d(de_mux_RegWrite), .clk(clk), .rst(rst)); // need this but why?
dff_N #(.N(1)) reg_de_MemWrite(.q(de_MemWrite), .d(de_mux_MemWrite), .clk(clk), .rst(rst));
dff_N #(.N(5)) reg_de_ALUOp (.q(de_ALUOp), .d(de_mux_ALUOp), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_de_halt(.q(de_halt), .d(createdump), .clk(clk), .rst(rst));


// Doesn't need to be muxed, just passed through the pipeline
dff_N #(.N(3)) reg_de_reg_rd (.q(de_writeReg), .d(dout_writeReg), .clk(clk), .rst(rst));
dff_N #(.N(16)) reg_de_read_data_2 (.q(de_read_data_2), .d(dout_read_data_2), .clk(clk), .rst(rst));
dff_N #(.N(16)) reg_de_Immd (.q(de_Immd), .d(dout_Immd), .clk(clk), .rst(rst));
dff_N #(.N(16)) reg_de_read_data_1 (.q(de_read_data_1), .d(dout_read_data_1), .clk(clk), .rst(rst));

// dff_N #(.N(3)) reg_de_reg_rs (.q(de_readReg1), .d(dout_readReg1), .clk(clk), .rst(rst));
// dff_N #(.N(3)) reg_de_reg_rt (.q(de_readReg2), .d(dout_readReg2), .clk(clk), .rst(rst));
// dff_N #(.N(16)) reg_de_PC_2 (.q(de_PC_2), .d(fd_PC_2), .clk(clk), .rst(rst));
// dff_N #(.N(16)) reg_de_PC_2_I (.q(de_PC_2_I), .d(dout_PC_2_I), .clk(clk), .rst(rst));
// dff_N #(.N(16)) reg_de_PC_2_D (.q(de_PC_2_D), .d(dout_PC_2_D), .clk(clk), .rst(rst));
// dff_N #(.N(16)) reg_de_PC (.q(de_PC), .d(fd_PC), .clk(clk), .rst(rst));
// dff_N #(.N(1)) reg_de_is_branch(.q(de_is_branch), .d(de_mux_is_branch), .clk(clk), .rst(rst));
// dff_N #(.N(3)) reg_de_PCSrc (.q(de_PCSrc), .d(de_mux_PCSrc), .clk(clk), .rst(rst));
// dff_N #(.N(16)) reg_de_next_PC (.q(de_next_PC), .d(fd_next_PC), .clk(clk), .rst(rst));



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

execute execute0(.Immd(de_Immd), .read_data_1(de_read_data_1), .read_data_2(de_read_data_2), 
                 .ALUSrc(de_ALUSrc), .invA(de_invA), .invB(de_invB), 
                 .sign(de_sign), .Cin(de_Cin), .is_LBI(de_is_LBI), 
                 .is_SLBI(de_is_SLBI), .ALUOp(de_ALUOp), 
                 .ALU_Result_out(eout_ALU_Result), .err(errX)
                 );

///////////////////////////////////////////////// E/M pipeline register ///////////////////////////////////////////////////////////////
// E/M flopped wires
wire em_MemRead, em_MemWrite, em_MemtoReg, em_RegWrite, em_halt;
wire [15:0] em_ALU_Result, em_read_data_2, em_next_PC;
wire [2:0] em_readReg1, em_readReg2, em_writeReg;

// NO NEED TO MUX, nop detected in decode/execute stage

// E/M registers
dff_N #(.N(16)) reg_em_ALU_Result(.q(em_ALU_Result), .d(eout_ALU_Result), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_em_MemRead(.q(em_MemRead), .d(de_MemRead), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_em_MemWrite(.q(em_MemWrite), .d(de_MemWrite), .clk(clk), .rst(rst));
dff_N #(.N(16)) reg_em_read_data_2(.q(em_read_data_2), .d(de_read_data_2), .clk(clk), .rst(rst));

// Needed later
dff_N #(.N(1)) reg_em_MemtoReg(.q(em_MemtoReg), .d(de_MemtoReg), .clk(clk), .rst(rst));
dff_N #(.N(3)) reg_em_reg_rd (.q(em_writeReg), .d(de_writeReg), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_em_halt(.q(em_halt), .d(de_halt), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_em_reg_wr (.q(em_RegWrite), .d(de_RegWrite), .clk(clk), .rst(rst)); // Why do we need this? 

// dff_N #(.N(3)) reg_em_reg_rs (.q(em_readReg1), .d(de_readReg1), .clk(clk), .rst(rst));
// dff_N #(.N(3)) reg__em_reg_rt (.q(em_readReg2), .d(de_readReg2), .clk(clk), .rst(rst));
// dff_N #(.N(16)) reg_em_next_PC(.q(em_next_PC), .d(eout_next_PC), .clk(clk), .rst(rst));

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// memory outputs
wire [15:0] read_data;

memory memory0(.ALU_result(em_ALU_Result), .read_data_in(em_read_data_2), .MemRead(em_MemRead), 
               .MemWrite(em_MemWrite), .read_data_out(read_data), .clk(clk), 
               .rst(rst), .createdump(em_halt), .err(errM)
               );

//////////////////////////////////////////////////////// M/W pipeline register /////////////////////////////////////////////////////////
// M/W flopped wires
wire [15:0] mw_read_data, mw_read_data_2, mw_ALU_Result;
wire [2:0] mw_readReg1, mw_readReg2;
wire mw_RegWrite, mw_MemtoReg, mw_MemRead, mw_MemWrite;

// Nop is propogated from D/E pipeline

// M/W registers
dff_N #(.N(16)) reg_mw_ALU_Result(.q(mw_ALU_Result), .d(em_ALU_Result), .clk(clk), .rst(rst));
dff_N #(.N(16)) reg_mw_read_data(.q(mw_read_data), .d(read_data), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_mw_MemtoReg(.q(mw_MemtoReg), .d(em_MemtoReg), .clk(clk), .rst(rst));
dff_N #(.N(3)) reg_mw_reg_rd (.q(mw_writeReg), .d(em_writeReg), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_mw_halt(.q(mw_halt), .d(em_halt), .clk(clk), .rst(rst));
dff_N #(.N(1)) reg_mw_reg_wr (.q(mw_RegWrite), .d(em_RegWrite), .clk(clk), .rst(rst)); // Why is this needed? 

// dff_N #(.N(16)) reg_mw_read_data2(.q(mw_read_data_2), .d(em_read_data_2), .clk(clk), .rst(rst));
// dff_N #(.N(3)) reg_mw_reg_rs (.q(mw_readReg1), .d(em_readReg1), .clk(clk), .rst(rst));
// dff_N #(.N(3)) reg__mw_reg_rt (.q(mw_readReg2), .d(em_readReg2), .clk(clk), .rst(rst));
// dff_N #(.N(16)) reg_mw_next_PC (.q(fin_next_PC), .d(em_next_PC), .clk(clk), .rst(rst));
// dff_N #(.N(16)) reg_mw_write_data (.q(fd_write_data), .d(write_data), .clk(clk), .rst(rst));
// dff_N #(.N(1)) reg_mw_reg_MemRead(.q(mw_MemRead), .d(em_MemRead), .clk(clk), .rst(rst));
// dff_N #(.N(1)) reg_mw_reg_MemWrite (.q(mw_MemWrite), .d(em_MemWrite), .clk(clk), .rst(rst));

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

wb wb0(.ALU_result(mw_ALU_Result), .read_data(mw_read_data), .MemtoReg(mw_MemtoReg), 
       .write_data(write_data), .err(errW)
       );

// Errors for all the stages
assign err = errF | errD | errX | errM | errW;

// If you figure out you have a HALT in DECODE, there may be 3 other instructions in-flight in the other pipeline stages.  
// You should stop fetching instructions


///////////////////////////////////////////////////////////////// Hazard Unit ///////////////////////////////////////////////////////////

/*
hazard h0(.clk(clk), .rst(rst), .IF_ID_RegisterRs(fd_readReg1), .IF_ID_RegisterRt(fd_readReg2), .ID_EX_RegisterRd(de_writeReg), 
.ID_EX_RegisterRs(de_readReg1), .ID_EX_RegisterRt(de_readReg2), .EX_MEM_RegisterRd(em_writeReg), .EX_MEM_RegisterRs(em_readReg1), 
.EX_MEM_RegisterRt(em_readReg2), .MEM_WB_RegisterRd(mw_writeReg), .MEM_WB_RegisterRs(mw_readReg1), .MEM_WB_RegisterRt(mw_readReg2),  
.ID_EX_wrEn(de_RegWrite), .EX_MEM_wrEn(em_RegWrite), .MEM_WB_wrEn(mw_RegWrite),
.insert_nop(insert_nop), .ID_EX_MemRead(de_MemRead), .PCSrc(dout_PCSrc));
*/





   
endmodule // proc
// DUMMY LINE FOR REV CONTROL :0:
