module control_unit(opcode, funct, rst, RegWrite, SignExt, ImmdSrc, ALUSrc, is_SLBI, MemRead, MemWrite, MemtoReg, sign, 
invA, invB, Cin, is_LBI, is_JAL, PCSrc, RegDst, ALUOp, fetch_enable, createdump, is_branch);

input [4:0] opcode;
input [1:0] funct;
input rst;

// All control unit signals
output RegWrite, SignExt, ImmdSrc, ALUSrc, is_SLBI, MemRead, MemWrite, MemtoReg, sign, invA, invB, Cin, is_LBI, is_JAL, fetch_enable, 
createdump, is_branch;
output [4:0] ALUOp;
output [1:0] PCSrc, RegDst;

// Need reg for case statement
reg RegWrite_temp, SignExt_temp, ImmdSrc_temp, ALUSrc_temp, is_SLBI_temp, MemRead_temp, MemWrite_temp, MemtoReg_temp, sign_temp, invA_temp, 
invB_temp, Cin_temp, is_LBI_temp, is_JAL_temp, fetch_enable_temp, createdump_temp, is_branch_temp;
reg [4:0] ALUOp_temp;
reg [1:0] PCSrc_temp, RegDst_temp;

//////////////////////////////////////////////////////////////////////////// ALU_OP instructions //////////////////////////////////////////////////////////////////////////////////////

parameter rot_lft = 4'b0000;
parameter shift_lft_log = 4'b0001;
parameter rot_rght = 4'b0010;
parameter shift_rght_log = 4'b0011;
parameter add = 4'b0100;
parameter And = 4'b0101;
parameter Or = 4'b0110;
parameter Xor = 4'b0111;
parameter bit_rev = 4'b1000;
parameter seq = 4'b1001;
parameter slt = 4'b1010;
parameter sle = 4'b1011; 
parameter sco = 4'b1100;
parameter beqz = 4'b1101;
parameter bnez = 4'b1110;
parameter bltz = 4'b1111;
parameter bgez = 5'b10000;

//////////////////////////////////////////////////////////////////////////// Name instructions //////////////////////////////////////////////////////////////////////////
parameter HALT = 7'b00000_xx;
parameter NOP = 7'b00001_xx;

// I1-format
parameter ADDI = 7'b01000_xx;
parameter SUBI = 7'b01001_xx;
parameter XORI = 7'b01010_xx;
parameter ANDNI = 7'b01011_xx;
parameter ROLI = 7'b10100_xx;
parameter SLLI = 7'b10101_xx;
parameter RORI = 7'b10110_xx;
parameter SRLI = 7'b10111_xx;
parameter ST = 7'b10000_xx;
parameter LD = 7'b10001_xx;
parameter STU = 7'b10011_xx;

// R-format
parameter BTR = 7'b11001_xx;
parameter ADD = 7'b11011_00;
parameter SUB = 7'b11011_01;
parameter XOR = 7'b11011_10;
parameter ANDN = 7'b11011_11;
parameter ROL = 7'b11010_00;
parameter SLL = 7'b11010_01;
parameter ROR = 7'b11010_10;
parameter SRL = 7'b11010_11;
parameter SEQ = 7'b11100_xx;
parameter SLT = 7'b11101_xx;
parameter SLE = 7'b11110_xx;
parameter SCO = 7'b11111_xx;

// I2-format
parameter BEQZ = 7'b01100_xx;
parameter BNEZ = 7'b01101_xx;
parameter BLTZ = 7'b01110_xx;
parameter BGEZ = 7'b01111_xx;
parameter LBI = 7'b11000_xx;
parameter SLBI = 7'b10010_xx;
parameter JALR = 7'b00111_xx;
parameter JR = 7'b00101_xx;

// J-format
parameter J = 7'b00100_xx;
parameter JAL = 7'b00110_xx;


//////////////////////////////////////////////////////////////////////////// Control Unit //////////////////////////////////////////////////////////////////////////

always@(*) begin

// Initialize all signals

fetch_enable_temp = 1'b1;
createdump_temp = 1'b0;
RegDst_temp = 2'b01;
RegWrite_temp = 1'b1;
SignExt_temp = 1'b0;
ImmdSrc_temp = 1'b0;
ALUSrc_temp = 1'b0;
is_SLBI_temp = 1'b0;
ALUOp_temp = add;
MemRead_temp = 1'b0;
MemWrite_temp = 1'b0;
MemtoReg_temp = 1'b1;
sign_temp = 1'b0;
invA_temp = 1'b0;
invB_temp = 1'b0;
Cin_temp = 1'b0;
is_LBI_temp = 1'b0;
is_JAL_temp = 1'b0;
PCSrc_temp = 2'b00;
is_branch_temp = 1'b0;



casex({opcode, funct}) 

	
// 1. HALT 
HALT: begin

	// dump memory state to file
	// processor just stops
	// Set PC to what
	// only be true is !rst
	createdump_temp = 1'b1; // halt signal
	RegWrite_temp = 1'b0;

end


//////////////////////////////////////////////////////////////////////////////// I1-Format ////////////////////////////////////////////////////////////////////

// 3. ADDI 
ADDI: begin

	SignExt_temp = 1'b1;
	ImmdSrc_temp = 1'b1;

end


// 4. SUBI 
SUBI: begin

	RegDst_temp = 2'b01;
	RegWrite_temp = 1'b1;
	SignExt_temp = 1'b1;
	ImmdSrc_temp = 1'b1;
	ALUSrc_temp = 1'b0;
	is_SLBI_temp = 1'b0;
	ALUOp_temp = add;
	MemRead_temp = 1'b0;
	MemWrite_temp = 1'b0;
	MemtoReg_temp = 1'b1;
	sign_temp = 1'b1;
	invA_temp = 1'b1;
	invB_temp = 1'b0;
	Cin_temp = 1'b1;
	is_LBI_temp = 1'b0;
	is_JAL_temp = 1'b0;
	PCSrc_temp = 2'b00;
	
end


// 5. XORI 
XORI: begin 

	ImmdSrc_temp = 1'b1;
	ALUOp_temp = Xor;

end


// 6. ANDNI 
ANDNI: begin 

	ImmdSrc_temp = 1'b1;
	invB_temp = 1'b1;
	ALUOp_temp = And;

end

// 7. ROLI 
ROLI: begin 

	ImmdSrc_temp = 1'b1;
	ALUOp_temp = 3'b000;

end

// 8. SLLI 
SLLI: begin

	RegDst_temp = 2'b01;
	RegWrite_temp = 1'b1;
	SignExt_temp = 1'b0;
	ImmdSrc_temp = 1'b1;
	ALUSrc_temp = 1'b0;
	is_SLBI_temp = 1'b0;
	ALUOp_temp = shift_lft_log;
	MemRead_temp = 1'b0;
	MemWrite_temp = 1'b0;
	MemtoReg_temp = 1'b1;
	sign_temp = 1'b0;
	invA_temp = 1'b0;
	invB_temp = 1'b0;
	Cin_temp = 1'b0;
	is_LBI_temp = 1'b0;
	is_JAL_temp = 1'b0;
	PCSrc_temp = 2'b00;

end

// 9. RORI 
RORI: begin

	RegDst_temp = 2'b01;
	RegWrite_temp = 1'b1;
	SignExt_temp = 1'b0;
	ImmdSrc_temp = 1'b1;
	ALUSrc_temp = 1'b0;
	is_SLBI_temp = 1'b0;
	ALUOp_temp = rot_rght;
	MemRead_temp = 1'b0;
	MemWrite_temp = 1'b0;
	MemtoReg_temp = 1'b1;
	sign_temp = 1'b0;
	invA_temp = 1'b0;
	invB_temp = 1'b0;
	Cin_temp = 1'b0;
	is_LBI_temp = 1'b0;
	is_JAL_temp = 1'b0;
	PCSrc_temp = 2'b00;

end

// 10. SRLI
SRLI: begin 

	RegDst_temp = 2'b01;
	RegWrite_temp = 1'b1;
	SignExt_temp = 1'b0;
	ImmdSrc_temp = 1'b1;
	ALUSrc_temp = 1'b0;
	is_SLBI_temp = 1'b0;
	ALUOp_temp = shift_rght_log;
	MemRead_temp = 1'b0;
	MemWrite_temp = 1'b0;
	MemtoReg_temp = 1'b1;
	sign_temp = 1'b0;
	invA_temp = 1'b0;
	invB_temp = 1'b0;
	Cin_temp = 1'b0;
	is_LBI_temp = 1'b0;
	is_JAL_temp = 1'b0;
	PCSrc_temp = 2'b00;
end

// 11. ST 
ST: begin

	RegWrite_temp = 1'b0;
	SignExt_temp = 1'b1;
	ImmdSrc_temp = 1'b1;
	MemtoReg_temp = 1'b0;
	MemRead_temp = 1'b0;
	MemWrite_temp = 1'b1;
	RegDst_temp = 2'b01;
	SignExt_temp = 1'b1;
	ALUSrc_temp = 1'b0;
	is_SLBI_temp = 1'b0;
	ALUOp_temp = add;
	sign_temp = 1'b0;
	invA_temp = 1'b0;
	invB_temp = 1'b0;
	Cin_temp = 1'b0;
	is_LBI_temp = 1'b0;
	is_JAL_temp = 1'b0;
	PCSrc_temp = 2'b00;

end

// 12. LD 
LD: begin

	SignExt_temp = 1'b1;
	ImmdSrc_temp = 1'b1;
	MemRead_temp = 1'b1;
	MemtoReg_temp = 1'b0;

end

// 13. STU
STU: begin

	RegWrite_temp = 1'b1;
	SignExt_temp = 1'b1;
	ImmdSrc_temp = 1'b1;
	MemtoReg_temp = 1'b1;
	MemRead_temp = 1'b0;
	MemWrite_temp = 1'b1;
	RegDst_temp = 2'b10;
	SignExt_temp = 1'b1;
	ALUSrc_temp = 1'b0;
	is_SLBI_temp = 1'b0;
	ALUOp_temp = add;
	sign_temp = 1'b0;
	invA_temp = 1'b0;
	invB_temp = 1'b0;
	Cin_temp = 1'b0;
	is_LBI_temp = 1'b0;
	is_JAL_temp = 1'b0;
	PCSrc_temp = 2'b00;

end

//////////////////////////////////////////////////////////////////////////////// R-Format ////////////////////////////////////////////////////////////////////

// 14. BTR
BTR: begin

	RegDst_temp = 2'b00;
	RegWrite_temp = 1'b1;
	SignExt_temp = 1'b0;
	ImmdSrc_temp = 1'b0;
	ALUSrc_temp = 1'b1;
	is_SLBI_temp = 1'b0;
	ALUOp_temp = bit_rev;
	MemRead_temp = 1'b0;
	MemWrite_temp = 1'b0;
	MemtoReg_temp = 1'b1;
	sign_temp = 1'b0;
	invA_temp = 1'b0;
	invB_temp = 1'b0;
	Cin_temp = 1'b0;
	is_LBI_temp = 1'b0;
	is_JAL_temp = 1'b0;
	PCSrc_temp = 2'b00;

end

// 15. ADD 
ADD: begin

	RegDst_temp = 2'b00; 
	ALUSrc_temp = 1'b1;
	

end

// 16. SUB 
SUB: begin

	RegDst_temp = 2'b00;
	RegWrite_temp = 1'b1;
	SignExt_temp = 1'b1;
	ImmdSrc_temp = 1'b0;
	ALUSrc_temp = 1'b1;
	is_SLBI_temp = 1'b0;
	ALUOp_temp = add;
	MemRead_temp = 1'b0;
	MemWrite_temp = 1'b0;
	MemtoReg_temp = 1'b1;
	sign_temp = 1'b1;
	invA_temp = 1'b1;
	invB_temp = 1'b0;
	Cin_temp = 1'b1;
	is_LBI_temp = 1'b0;
	is_JAL_temp = 1'b0;
	PCSrc_temp = 2'b00;
	

end

// 17. XOR 
XOR: begin

	RegDst_temp = 2'b00; 
	ALUSrc_temp = 1'b1;
	ALUOp_temp = 3'b111;
 

end

// 18. ANDN 
ANDN: begin

	RegDst_temp = 2'b00; 
	ALUSrc_temp = 1'b1;
	invB_temp = 1'b1;
	ALUOp_temp = 3'b101;

end

// 19. ROL 
ROL: begin

	RegDst_temp = 2'b00; 
	ALUSrc_temp = 1'b1;
	ALUOp_temp = 3'b000;

end

// 20. SLL 
SLL: begin

	RegDst_temp = 2'b00;
	RegWrite_temp = 1'b1;
	SignExt_temp = 1'b0;
	ImmdSrc_temp = 1'b1;
	ALUSrc_temp = 1'b1;
	is_SLBI_temp = 1'b0;
	ALUOp_temp = shift_lft_log;
	MemRead_temp = 1'b0;
	MemWrite_temp = 1'b0;
	MemtoReg_temp = 1'b1;
	sign_temp = 1'b0;
	invA_temp = 1'b0;
	invB_temp = 1'b0;
	Cin_temp = 1'b0;
	is_LBI_temp = 1'b0;
	is_JAL_temp = 1'b0;
	PCSrc_temp = 2'b00;
	

end

// 21. ROR 
ROR: begin

	RegDst_temp = 2'b00;
	RegWrite_temp = 1'b1;
	SignExt_temp = 1'b0;
	ImmdSrc_temp = 1'b1;
	ALUSrc_temp = 1'b1;
	is_SLBI_temp = 1'b0;
	ALUOp_temp = rot_rght;
	MemRead_temp = 1'b0;
	MemWrite_temp = 1'b0;
	MemtoReg_temp = 1'b1;
	sign_temp = 1'b0;
	invA_temp = 1'b0;
	invB_temp = 1'b0;
	Cin_temp = 1'b0;
	is_LBI_temp = 1'b0;
	is_JAL_temp = 1'b0;
	PCSrc_temp = 2'b00;
	

end

// 22. SRL 
SRL: begin

	RegDst_temp = 2'b00;
	RegWrite_temp = 1'b1;
	SignExt_temp = 1'b0;
	ImmdSrc_temp = 1'b0;
	ALUSrc_temp = 1'b1;
	is_SLBI_temp = 1'b0;
	ALUOp_temp = shift_rght_log;
	MemRead_temp = 1'b0;
	MemWrite_temp = 1'b0;
	MemtoReg_temp = 1'b1;
	sign_temp = 1'b0;
	invA_temp = 1'b0;
	invB_temp = 1'b0;
	Cin_temp = 1'b0;
	is_LBI_temp = 1'b0;
	is_JAL_temp = 1'b0;
	PCSrc_temp = 2'b00;

end

// 23. SEQ 
SEQ: begin

	RegDst_temp = 2'b00;
	RegWrite_temp = 1'b1;
	SignExt_temp = 1'b0;
	ImmdSrc_temp = 1'b0;
	ALUSrc_temp = 1'b1;
	is_SLBI_temp = 1'b0;
	ALUOp_temp = seq;
	MemRead_temp = 1'b0;
	MemWrite_temp = 1'b0;
	MemtoReg_temp = 1'b1;
	sign_temp = 1'b0;
	invA_temp = 1'b0;
	invB_temp = 1'b0;
	Cin_temp = 1'b0;
	is_LBI_temp = 1'b0;
	is_JAL_temp = 1'b0;
	PCSrc_temp = 2'b00;

end

// 24. SLT 
SLT: begin

	RegDst_temp = 2'b00;
	RegWrite_temp = 1'b1;
	SignExt_temp = 1'b0;
	ImmdSrc_temp = 1'b1;
	ALUSrc_temp = 1'b1;
	is_SLBI_temp = 1'b0;
	ALUOp_temp = slt;
	MemRead_temp = 1'b0;
	MemWrite_temp = 1'b0;
	MemtoReg_temp = 1'b1;
	sign_temp = 1'b1;
	invA_temp = 1'b0;
	invB_temp = 1'b0;
	Cin_temp = 1'b0;
	is_LBI_temp = 1'b0;
	is_JAL_temp = 1'b0;
	PCSrc_temp = 2'b00;
	
end

// 25. SLE
SLE: begin

	RegDst_temp = 2'b00;
	RegWrite_temp = 1'b1;
	SignExt_temp = 1'b0;
	ImmdSrc_temp = 1'b0;
	ALUSrc_temp = 1'b1;
	is_SLBI_temp = 1'b0;
	ALUOp_temp = sle;
	MemRead_temp = 1'b0;
	MemWrite_temp = 1'b0;
	MemtoReg_temp = 1'b1;
	sign_temp = 1'b0;
	invA_temp = 1'b0;
	invB_temp = 1'b0;
	Cin_temp = 1'b0;
	is_LBI_temp = 1'b0;
	is_JAL_temp = 1'b0;
	PCSrc_temp = 2'b00;
end

// 26. SCO 
SCO: begin

	RegDst_temp = 2'b00;
	RegWrite_temp = 1'b1;
	SignExt_temp = 1'b0;
	ImmdSrc_temp = 1'b0;
	ALUSrc_temp = 1'b1;
	is_SLBI_temp = 1'b0;
	ALUOp_temp = sco;
	MemRead_temp = 1'b0;
	MemWrite_temp = 1'b0;
	MemtoReg_temp = 1'b1;
	sign_temp = 1'b0;
	invA_temp = 1'b0;
	invB_temp = 1'b0;
	Cin_temp = 1'b0;
	is_LBI_temp = 1'b0;
	is_JAL_temp = 1'b0;
	PCSrc_temp = 2'b00;

end

//////////////////////////////////////////////////////////////////////////////// I2-Format ////////////////////////////////////////////////////////////////////

// 27. BEQZ
BEQZ: begin

	RegDst_temp = 2'b01;
	RegWrite_temp = 1'b0;
	SignExt_temp = 1'b1;
	ImmdSrc_temp = 1'b0;
	ALUSrc_temp = 1'b1;
	is_SLBI_temp = 1'b0;
	ALUOp_temp = beqz;
	MemRead_temp = 1'b0;
	MemWrite_temp = 1'b0;
	MemtoReg_temp = 1'b1;
	sign_temp = 1'b0;
	invA_temp = 1'b0;
	invB_temp = 1'b0;
	Cin_temp = 1'b0;
	is_LBI_temp = 1'b0;
	is_JAL_temp = 1'b0;
	PCSrc_temp = 2'b11;
	is_branch_temp = 1'b1;

end

// 28. BNEZ
BNEZ: begin

	RegDst_temp = 2'b01;
	RegWrite_temp = 1'b0;
	SignExt_temp = 1'b1;
	ImmdSrc_temp = 1'b0;
	ALUSrc_temp = 1'b1;
	is_SLBI_temp = 1'b0;
	ALUOp_temp = bnez;
	MemRead_temp = 1'b0;
	MemWrite_temp = 1'b0;
	MemtoReg_temp = 1'b1;
	sign_temp = 1'b0;
	invA_temp = 1'b0;
	invB_temp = 1'b0;
	Cin_temp = 1'b0;
	is_LBI_temp = 1'b0;
	is_JAL_temp = 1'b0;
	PCSrc_temp = 2'b11;
	is_branch_temp = 1'b1;

end

// 29. BLTZ
BLTZ: begin

	RegDst_temp = 2'b01;
	RegWrite_temp = 1'b0;
	SignExt_temp = 1'b1;
	ImmdSrc_temp = 1'b0;
	ALUSrc_temp = 1'b1;
	is_SLBI_temp = 1'b0;
	ALUOp_temp = bltz;
	MemRead_temp = 1'b0;
	MemWrite_temp = 1'b0;
	MemtoReg_temp = 1'b1;
	sign_temp = 1'b0;
	invA_temp = 1'b0;
	invB_temp = 1'b0;
	Cin_temp = 1'b0;
	is_LBI_temp = 1'b0;
	is_JAL_temp = 1'b0;
	PCSrc_temp = 2'b11;
	is_branch_temp = 1'b1;
	

end

// 30. BGEZ
BGEZ: begin

	RegDst_temp = 2'b01;
	RegWrite_temp = 1'b0;
	SignExt_temp = 1'b1;
	ImmdSrc_temp = 1'b0;
	ALUSrc_temp = 1'b1;
	is_SLBI_temp = 1'b0;
	ALUOp_temp = bgez;
	MemRead_temp = 1'b0;
	MemWrite_temp = 1'b0;
	MemtoReg_temp = 1'b1;
	sign_temp = 1'b0;
	invA_temp = 1'b0;
	invB_temp = 1'b0;
	Cin_temp = 1'b0;
	is_LBI_temp = 1'b0;
	is_JAL_temp = 1'b0;
	PCSrc_temp = 2'b11;
	is_branch_temp = 1'b1;

end

// 31. LBI 
LBI: begin

	is_LBI_temp = 1'b1;
	RegWrite_temp = 1'b1;
	SignExt_temp = 1'b1;
	RegDst_temp = 2'b10;
	fetch_enable_temp = 1'b1;
	createdump_temp = 1'b0;
	ImmdSrc_temp = 1'b0;
	ALUSrc_temp = 1'b0;
	is_SLBI_temp = 1'b0;
	ALUOp_temp = add;
	MemRead_temp = 1'b0;
	MemWrite_temp = 1'b0;
	MemtoReg_temp = 1'b1;
	sign_temp = 1'b0;
	invA_temp = 1'b0;
	invB_temp = 1'b0;
	Cin_temp = 1'b0;
	is_JAL_temp = 1'b0;
	PCSrc_temp = 2'b00;
		
end
	

// 32. SLBI 
SLBI: begin

	is_SLBI_temp = 1'b1;
	RegWrite_temp = 1'b1; 
	RegDst_temp = 2'b10;


end

//////////////////////////////////////////////////////////////////////////////// J-Format //////////////////////////////////////////////////////////////////////

// 33. J displacement 
J: begin

	RegDst_temp = 2'b00;
	RegWrite_temp = 1'b0;
	SignExt_temp = 1'b1;
	ImmdSrc_temp = 1'b0;
	ALUSrc_temp = 1'b0;
	is_SLBI_temp = 1'b0;
	ALUOp_temp = add;
	MemRead_temp = 1'b0;
	MemWrite_temp = 1'b0;
	MemtoReg_temp = 1'b1;
	sign_temp = 1'b0;
	invA_temp = 1'b0;
	invB_temp = 1'b0;
	Cin_temp = 1'b0;
	is_LBI_temp = 1'b0;
	is_JAL_temp = 1'b0;
	PCSrc_temp = 2'b10;

end

// 34. JR 
JR: begin

	RegDst_temp = 2'b11;
	RegWrite_temp = 1'b0;
	SignExt_temp = 1'b1;
	ImmdSrc_temp = 1'b0;
	ALUSrc_temp = 1'b0;
	is_SLBI_temp = 1'b0;
	ALUOp_temp = add;
	MemRead_temp = 1'b0;
	MemWrite_temp = 1'b0;
	MemtoReg_temp = 1'b1;
	sign_temp = 1'b0;
	invA_temp = 1'b0;
	invB_temp = 1'b0;
	Cin_temp = 1'b0;
	is_LBI_temp = 1'b0;
	is_JAL_temp = 1'b0;
	PCSrc_temp = 2'b01;
	
end

// 35. JAL
JAL: begin

	RegDst_temp = 2'b11;
	RegWrite_temp = 1'b1;
	SignExt_temp = 1'b1;
	ImmdSrc_temp = 1'b0;
	ALUSrc_temp = 1'b1;
	is_SLBI_temp = 1'b0;
	ALUOp_temp = add;
	MemRead_temp = 1'b0;
	MemWrite_temp = 1'b0;
	MemtoReg_temp = 1'b1;
	sign_temp = 1'b0;
	invA_temp = 1'b0;
	invB_temp = 1'b0;
	Cin_temp = 1'b0;
	is_LBI_temp = 1'b0;
	is_JAL_temp = 1'b1;
	PCSrc_temp = 2'b10;
end

// 36. JALR
JALR: begin

	RegDst_temp = 2'b11;
	RegWrite_temp = 1'b1;
	SignExt_temp = 1'b1;
	ImmdSrc_temp = 1'b0;
	ALUSrc_temp = 1'b0;
	is_SLBI_temp = 1'b0;
	ALUOp_temp = add;
	MemRead_temp = 1'b0;
	MemWrite_temp = 1'b0;
	MemtoReg_temp = 1'b1;
	sign_temp = 1'b0;
	invA_temp = 1'b0;
	invB_temp = 1'b0;
	Cin_temp = 1'b0;
	is_LBI_temp = 1'b0;
	is_JAL_temp = 1'b1;
	PCSrc_temp = 2'b01;

end

default: begin

// NOP
	RegWrite_temp = 1'b0;

end


endcase

end


assign is_JAL = is_JAL_temp;
assign RegDst = RegDst_temp;
assign PCSrc = PCSrc_temp;
assign SignExt = SignExt_temp;
assign MemtoReg = MemtoReg_temp;
assign RegWrite = RegWrite_temp;
assign ALUSrc = ALUSrc_temp;
assign MemWrite = MemWrite_temp;
assign MemRead = MemRead_temp;
assign ImmdSrc = ImmdSrc_temp;
assign invA = invA_temp;
assign invB = invB_temp;
// assign createdump = createdump_temp & ~rst;
assign createdump = createdump_temp;
assign fetch_enable = fetch_enable_temp;
assign ALUOp = ALUOp_temp;
assign is_LBI = is_LBI_temp;
assign is_SLBI = is_SLBI_temp;
assign Cin = Cin_temp;
assign ALUOp = ALUOp_temp;
assign sign = sign_temp;
assign is_branch = is_branch_temp;


endmodule