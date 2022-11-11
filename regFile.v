/*
   CS/ECE 552, Fall '22
   Homework #3, Problem #1
  
   This module creates a 16-bit register.  It has 1 write port, 2 read
   ports, 3 register select inputs, a write enable, a reset, and a clock
   input.  All register state changes occur on the rising edge of the
   clock. 
*/
module regFile (
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

// Name registers
parameter reg0 = 3'b000;
parameter reg1 = 3'b001;
parameter reg2 = 3'b010;
parameter reg3 = 3'b011;
parameter reg4 = 3'b100;
parameter reg5 = 3'b101;
parameter reg6 = 3'b110;
parameter reg7 = 3'b111;

parameter num_bits = 16;

wire [num_bits-1:0] R0, R1, R2, R3, R4, R5, R6, R7;
wire [7:0] enableR;
wire [7:0] whichReg;

// #(.N(16))

// Which register to write to 
assign whichReg[0] = (writeRegSel == reg0) ? 1'b1 : 1'b0;
assign whichReg[1] = (writeRegSel == reg1) ? 1'b1 : 1'b0;
assign whichReg[2] = (writeRegSel == reg2) ? 1'b1 : 1'b0;
assign whichReg[3] = (writeRegSel == reg3) ? 1'b1 : 1'b0;
assign whichReg[4] = (writeRegSel == reg4) ? 1'b1 : 1'b0;
assign whichReg[5] = (writeRegSel == reg5) ? 1'b1 : 1'b0;
assign whichReg[6] = (writeRegSel == reg6) ? 1'b1 : 1'b0;
assign whichReg[7] = (writeRegSel == reg7) ? 1'b1 : 1'b0;

// Select register to write to and if to write
assign enableR[0] = writeEn & whichReg[0];
assign enableR[1] = writeEn & whichReg[1];
assign enableR[2] = writeEn & whichReg[2];
assign enableR[3] = writeEn & whichReg[3];
assign enableR[4] = writeEn & whichReg[4];
assign enableR[5] = writeEn & whichReg[5];
assign enableR[6] = writeEn & whichReg[6];
assign enableR[7] = writeEn & whichReg[7];

// Instantiate all 8 registers
reg_16b r0(.Q(R0), .D(writeData), .clk(clk), .rst(rst), .writeEn(enableR[0])); 
reg_16b r1(.Q(R1), .D(writeData), .clk(clk), .rst(rst), .writeEn(enableR[1]));
reg_16b r2(.Q(R2), .D(writeData), .clk(clk), .rst(rst), .writeEn(enableR[2]));
reg_16b r3(.Q(R3), .D(writeData), .clk(clk), .rst(rst), .writeEn(enableR[3]));
reg_16b r4(.Q(R4), .D(writeData), .clk(clk), .rst(rst), .writeEn(enableR[4]));
reg_16b r5(.Q(R5), .D(writeData), .clk(clk), .rst(rst), .writeEn(enableR[5]));
reg_16b r6(.Q(R6), .D(writeData), .clk(clk), .rst(rst), .writeEn(enableR[6]));
reg_16b r7(.Q(R7), .D(writeData), .clk(clk), .rst(rst), .writeEn(enableR[7]));


// if enable is an unknown value, have err be high
assign err = ~(~writeEn | writeEn) ? 1'b1 : 1'b0;

// Choose which register to read from for read1Data
assign read1Data = 
	(read1RegSel == reg0) ? R0: 
	(read1RegSel == reg1) ? R1: 
	(read1RegSel == reg2) ? R2: 
	(read1RegSel == reg3) ? R3: 
	(read1RegSel == reg4) ? R4: 
	(read1RegSel == reg5) ? R5: 
	(read1RegSel == reg6) ? R6: R7; 

// Choose which register to use for read2Data
assign read2Data = 
	(read2RegSel == reg0) ? R0: 
	(read2RegSel == reg1) ? R1: 
	(read2RegSel == reg2) ? R2: 
	(read2RegSel == reg3) ? R3: 
	(read2RegSel == reg4) ? R4: 
	(read2RegSel == reg5) ? R5: 
	(read2RegSel == reg6) ? R6: R7; 
 

endmodule
