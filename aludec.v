`timescale 1ns / 1ps

module aludec(
	input	[2:0]	i_funct,
	input	[6:0]	i_op,
	input			i_sflag,

	output	[3:0]	o_ctrl
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

	reg		[3:0]	r_ctrl;

	always @(*) begin
		casex (i_op)
		7'b0X10011: begin
			case (i_funct)
			3'b000:	r_ctrl	<=	(i_op == 7'b0010011)?	ADD : 
								(i_sflag) ? SUB : ADD ;
			3'b001:	r_ctrl	<=	SLL;
			3'b010:	r_ctrl	<=	SLT;
			3'b011:	r_ctrl	<=	SLTU;
			3'b100:	r_ctrl	<=	XOR;
			3'b101: r_ctrl	<=	(i_sflag) ? SRA : SRL;
			3'b110:	r_ctrl	<=	OR;
			3'b111:	r_ctrl	<=	AND;
			endcase
		end
		7'b1100111: begin
			r_ctrl	<=	ADD;
		end
		7'b0000011: begin
			r_ctrl	<=	ADD;
		end
		7'b0100011: begin
			r_ctrl	<=	ADD;
		end
		default: r_ctrl	<=	0;
		endcase
	end

	assign	o_ctrl = r_ctrl;
endmodule
