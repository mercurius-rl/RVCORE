module alu(
	input	[31:0]	i_dataa,
	input	[31:0]	i_datab,
	input	[3:0]	i_ctrl,

	output			o_of,
	output	[31:0]	o_result
);

	parameter	AND	=	4'b0000,
				OR	= 	4'b0001,
				XOR	=	4'b0010,
				NAND=	4'b0011,
				NOR	=	4'b0100,
				ADD	=	4'b0101,
				SUB	=	4'b0110,
				SLT	=	4'b0111,
				SLTU=	4'b1000,
				SLL	=	4'b1001,
				SRL	=	4'b1010,
				SRA	=	4'b1011;

	reg	[32:0]	r_result;
	always @(*) begin
		case (i_ctrl)
			AND		:	r_result	<=	i_dataa & i_datab;
			OR		:	r_result	<=	i_dataa | i_datab;
			XOR		:	r_result	<=	i_dataa ^ i_datab;
			NAND	:	r_result	<=	i_dataa & ~i_datab;
			NOR		:	r_result	<=	i_dataa | ~i_datab;
			ADD		:	r_result	<=	i_dataa + i_datab;
			SUB		:	r_result	<=	i_dataa - i_datab;
			SLT		:	r_result	<=	$signed(i_dataa) < $signed(i_datab);
			SLTU	:	r_result	<=	i_dataa < i_datab;
			SLL		:	r_result	<=	i_dataa << i_datab;
			SRL		:	r_result	<=	i_dataa >> i_datab;
			SRA		:	r_result	<=	$signed(i_dataa) >>> $signed(i_datab);
			default	:	r_result	<=	0;
		endcase	
	end

	assign	o_of = r_result[32] && (i_ctrl == ADD);
	assign	o_result = r_result;
endmodule
