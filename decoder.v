module decoder (
	input	[31:0]	i_inst,

	output			o_mwen,
	output			o_mren,

	output			o_imm_rs,
	output			o_rfwe,

	output	[3:0]	o_ctrl,

	output			o_csri,
	output	[1:0]	o_csrop,
	output	[11:0]	o_csraddr,
	output			o_csrr,

	output	[6:0]	o_op,
	output	[4:0]	o_rd, o_rs1, o_rs2,
	output	[2:0]	o_funct3,
	output	[6:0]	o_funct7,

	output	[31:0]	o_imm
);

	assign	o_op	=	i_inst[6:0];
	assign	o_rd	=	i_inst[11:7];
	assign	o_rs1	=	i_inst[19:15];
	assign	o_rs2	=	i_inst[24:20];
	assign	o_funct3=	i_inst[14:12];
	assign	o_funct7=	i_inst[31:25];

						// R Instruction
	assign	o_imm	=	(o_op == 7'b0110011)	?	32'h00000000	:	
						// I Instruction
						(o_op == 7'b0010011)	?	(o_funct3[1:0] == 2'b01)	
												?	{27'h0, i_inst[24:20]}	:	{20'h0, i_inst[31:20]}	:	
						(o_op == 7'b0000011)	?	{20'h0, i_inst[31:20]}	:	
						// S Instruction
						(o_op == 7'b0100011)	?	{20'h0, i_inst[31:25],i_inst[11:7]}	:	
						// B Instruction
						(o_op == 7'b1100011)	?	{19'h0, i_inst[31], i_inst[7], i_inst[30:25], i_inst[11:8], 1'b0}	:	
						// U Instruction
						(o_op == 7'b0010111 ||
						o_op == 7'b0110111)		?	{i_inst[31:12], 12'h0}	:	
						// J Instruction
						(o_op == 7'b1101111)	?	{11'h0, i_inst[31],i_inst[19:12],i_inst[20],i_inst[30:21],1'b0}:	
						(o_op == 7'b1100111)	?	{20'h0, i_inst[31:20]}	:
						// CSR Instruction
						(o_op == 7'b1110011)	?	{27'h0, i_inst[19:15]}	:
													32'h00000000;

	assign	o_imm_rs=	(  o_op == 7'b0000011
						|| o_op == 7'b0100011
						|| o_op == 7'b0010011 
						|| o_op == 7'b1100011 
						|| o_op == 7'b1100111 
						|| o_op == 7'b1101011 
						|| o_op == 7'b1101111)	?	1 : 0;
	assign	o_pc_rs	=	(o_op == 7'b0010111 || o_op == 7'b1100111)	?	1 : 0;
	assign	o_rfwe	= 	(o_op[5:0] != 6'b100011) ? 1 : 0;

	assign	o_mwen	=	(o_op == 7'b0100011) ? 1 : 0;
	assign	o_mren	=	(o_op == 7'b0000011) ? 1 : 0;

	assign	o_csri	=	(o_op == 7'b1110011) ? i_inst[14] : 0;
	assign	o_csrop	=	(o_op == 7'b1110011) ? i_inst[13:12] : 0;
	assign	o_csraddr =	(o_op == 7'b1110011) ? i_inst[31:20] : 0;
	assign	o_csrr	=	o_op == 7'b1110011;

	aludec ad(
        .i_op		(o_op			),
		.i_funct	(o_funct3		),
		.i_sflag	(i_inst[30]		),

		.o_ctrl		(o_ctrl			)
	);
    
endmodule