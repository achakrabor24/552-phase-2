module FD(instruction, PC_2, clk, rst);

	input[15:0] instruction, PC_2;
	input clk, rst;

	regFile FD_reg(.read1Data(), .read2Data(), .err(err), .clk(clk), .rst(rst), .read1RegSel(),
	 .read2RegSel(), .writeRegSel(), .writeData(), .writeEn());



endmodule