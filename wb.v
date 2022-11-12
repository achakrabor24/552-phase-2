/*
   CS/ECE 552 Spring '20
  
   Filename        : wb.v
   Description     : This is the module for the overall Write Back stage of the processor.
*/
module wb(ALU_result, read_data, MemtoReg, write_data, err);

	input [15:0] ALU_result, read_data;
	input MemtoReg;
	output [15:0] write_data;
	output err;

	assign write_data = (MemtoReg == 1'b0) ? read_data : ALU_result;
	
	// For now
	assign err = 1'b0;
   
endmodule
