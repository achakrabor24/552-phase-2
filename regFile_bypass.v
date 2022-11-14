/*
   CS/ECE 552, Fall '22
   Homework #3, Problem #2
  
   This module creates a wrapper around the 8x16b register file, to do
   do the bypassing logic for RF bypassing.
*/
module regFile_bypass (
                       // Outputs
                       read1Data, read2Data, err,
                       // Inputs
                       clk, rst, read1RegSel, read2RegSel, writeRegSel, writeData, writeEn
                       );
   input        clk, rst;
   input [2:0]  read1RegSel;
   input [2:0]  read2RegSel;
   input [2:0]  writeRegSel;
   input [15:0] writeData;
   input        writeEn;

   output [15:0] read1Data;
   output [15:0] read2Data;
   output        err;

wire reg1same, reg2same, bypass1Sel, bypass2Sel;
wire [15:0] read1DataTemp, read2DataTemp;

// If the register being written to is the same as one or both of the registers you are reading from.
assign reg1same = (writeRegSel == read1RegSel) ? 1'b1 : 1'b0;
assign reg2same = (writeRegSel == read2RegSel) ? 1'b1 : 1'b0;

regFile f0(.read1Data(read1DataTemp), .read2Data(read2DataTemp), .err(err), .clk(clk), .rst(rst), .read1RegSel(read1RegSel), .read2RegSel(read2RegSel), .writeRegSel(writeRegSel), .writeData(writeData), .writeEn(writeEn));

// Check if bypass case is true and write enable is high
assign bypass1Sel = writeEn & reg1same;
assign bypass2Sel = writeEn & reg2same;

// If the same registers, read before write 
// mux2_1 f1(.out(read1Data), .inA(read1DataTemp), .inB(writeData), .s(bypass1Sel));

assign read1Data = (bypass1Sel == 1'b1) ? read1DataTemp: writeData;

// mux2_1 f2(.out(read2Data), .inA(read2DataTemp), .inB(writeData), .s(bypass2Sel));
assign read2Data = (bypass2Sel == 1'b1) ? read2DataTemp: writeData;

endmodule
