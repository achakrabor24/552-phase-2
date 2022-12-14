/*
   CS/ECE 552 Spring '20
  
   Filename        : memory.v
   Description     : This module contains all components in the Memory stage of the 
                     processor.
*/
module memory (
	// Inputs
	ALU_result, read_data_in, MemRead, MemWrite, clk, rst, createdump,
	// Outputs
	read_data_out, Done, Stall, CacheHit, err);

	input [15:0] ALU_result, read_data_in;
	input MemRead, MemWrite, clk, rst;
	input createdump;

	output [15:0] read_data_out;
	output Done, CacheHit;
	output Stall;
	output err;

	wire memReadorWrite;

	assign memReadorWrite = MemWrite | MemRead;

	memory2c_align mem0(.data_out(read_data_out), .data_in(read_data_in), .addr(ALU_result), .enable(memReadorWrite), .wr(MemWrite), 
		.createdump(createdump), .clk(clk), .rst(rst), .err(err));
   
	/*
	mem_system mem0( 
		// Inputs
		.Addr(ALU_result), .DataIn(read_data_in), .Rd(MemRead), .Wr(MemWrite), .createdump(createdump), .clk(clk), .rst(rst),
		// Outputs
		.DataOut(read_data_out), .Done(Done), .Stall(Stall), .CacheHit(CacheHit), .err(err)
		);
	*/


    

endmodule
