module mul (
	input	[1:0]	s,
	input	[31:0]	a,
	input	[31:0]	b,
	output	[63:0]	out
);
	wire	[63:0]	ssout, susout, usout;
	assign	out	=	(s == 2'b00)	?	ssout	:
					(s == 2'b01)	?	ssout	:
					(s == 2'b10)	?	susout	:
					(s == 2'b11)	?	usout	:
										64'h0	;

	// signed * signed
	wire	[63:0]	ss00	=	(b[ 0]) ? ({~a[31], a[30:0]} <<  0) : 64'h0;
	wire	[63:0]	ss01	=	(b[ 1]) ? ({~a[31], a[30:0]} <<  1) : 64'h0;
	wire	[63:0]	ss02	=	(b[ 2]) ? ({~a[31], a[30:0]} <<  2) : 64'h0;
	wire	[63:0]	ss03	=	(b[ 3]) ? ({~a[31], a[30:0]} <<  3) : 64'h0;
	wire	[63:0]	ss04	=	(b[ 4]) ? ({~a[31], a[30:0]} <<  4) : 64'h0;
	wire	[63:0]	ss05	=	(b[ 5]) ? ({~a[31], a[30:0]} <<  5) : 64'h0;
	wire	[63:0]	ss06	=	(b[ 6]) ? ({~a[31], a[30:0]} <<  6) : 64'h0;
	wire	[63:0]	ss07	=	(b[ 7]) ? ({~a[31], a[30:0]} <<  7) : 64'h0;
	wire	[63:0]	ss08	=	(b[ 8]) ? ({~a[31], a[30:0]} <<  8) : 64'h0;
	wire	[63:0]	ss09	=	(b[ 9]) ? ({~a[31], a[30:0]} <<  9) : 64'h0;
	wire	[63:0]	ss10	=	(b[10]) ? ({~a[31], a[30:0]} << 10) : 64'h0;
	wire	[63:0]	ss11	=	(b[11]) ? ({~a[31], a[30:0]} << 11) : 64'h0;
	wire	[63:0]	ss12	=	(b[12]) ? ({~a[31], a[30:0]} << 12) : 64'h0;
	wire	[63:0]	ss13	=	(b[13]) ? ({~a[31], a[30:0]} << 13) : 64'h0;
	wire	[63:0]	ss14	=	(b[14]) ? ({~a[31], a[30:0]} << 14) : 64'h0;
	wire	[63:0]	ss15	=	(b[15]) ? ({~a[31], a[30:0]} << 15) : 64'h0;
	wire	[63:0]	ss16	=	(b[16]) ? ({~a[31], a[30:0]} << 16) : 64'h0;
	wire	[63:0]	ss17	=	(b[17]) ? ({~a[31], a[30:0]} << 17) : 64'h0;
	wire	[63:0]	ss18	=	(b[18]) ? ({~a[31], a[30:0]} << 18) : 64'h0;
	wire	[63:0]	ss19	=	(b[19]) ? ({~a[31], a[30:0]} << 19) : 64'h0;
	wire	[63:0]	ss20	=	(b[20]) ? ({~a[31], a[30:0]} << 20) : 64'h0;
	wire	[63:0]	ss21	=	(b[21]) ? ({~a[31], a[30:0]} << 21) : 64'h0;
	wire	[63:0]	ss22	=	(b[22]) ? ({~a[31], a[30:0]} << 22) : 64'h0;
	wire	[63:0]	ss23	=	(b[23]) ? ({~a[31], a[30:0]} << 23) : 64'h0;
	wire	[63:0]	ss24	=	(b[24]) ? ({~a[31], a[30:0]} << 24) : 64'h0;
	wire	[63:0]	ss25	=	(b[25]) ? ({~a[31], a[30:0]} << 25) : 64'h0;
	wire	[63:0]	ss26	=	(b[26]) ? ({~a[31], a[30:0]} << 26) : 64'h0;
	wire	[63:0]	ss27	=	(b[27]) ? ({~a[31], a[30:0]} << 27) : 64'h0;
	wire	[63:0]	ss28	=	(b[28]) ? ({~a[31], a[30:0]} << 28) : 64'h0;
	wire	[63:0]	ss29	=	(b[29]) ? ({~a[31], a[30:0]} << 29) : 64'h0;
	wire	[63:0]	ss30	=	(b[30]) ? ({~a[31], a[30:0]} << 30) : 64'h0;
	wire	[63:0]	ss31	=	(b[31]) ? ({ a[31],~a[30:0]} << 31) : 64'h0;

	assign	ssout	=	ss00 + ss01 + ss02 + ss03 + ss04 + ss05 + ss06 + ss07 + ss08 + ss09 + ss10 + ss11 + ss12 + ss13 + ss14 + ss15 + ss16 + ss17 + ss18 + ss19 + ss20 + ss21 + ss22 + ss23 + ss24 + ss25 + ss26 + ss27 + ss28 + ss29 + ss30 + ss31 + 64'h8000000100000000;

	// signed * unsigned
	wire	[63:0]	sus00	=	(b[ 0]) ? ({~a[31], a[30:0]} <<  0) : 64'h0;
	wire	[63:0]	sus01	=	(b[ 1]) ? ({~a[31], a[30:0]} <<  1) : 64'h0;
	wire	[63:0]	sus02	=	(b[ 2]) ? ({~a[31], a[30:0]} <<  2) : 64'h0;
	wire	[63:0]	sus03	=	(b[ 3]) ? ({~a[31], a[30:0]} <<  3) : 64'h0;
	wire	[63:0]	sus04	=	(b[ 4]) ? ({~a[31], a[30:0]} <<  4) : 64'h0;
	wire	[63:0]	sus05	=	(b[ 5]) ? ({~a[31], a[30:0]} <<  5) : 64'h0;
	wire	[63:0]	sus06	=	(b[ 6]) ? ({~a[31], a[30:0]} <<  6) : 64'h0;
	wire	[63:0]	sus07	=	(b[ 7]) ? ({~a[31], a[30:0]} <<  7) : 64'h0;
	wire	[63:0]	sus08	=	(b[ 8]) ? ({~a[31], a[30:0]} <<  8) : 64'h0;
	wire	[63:0]	sus09	=	(b[ 9]) ? ({~a[31], a[30:0]} <<  9) : 64'h0;
	wire	[63:0]	sus10	=	(b[10]) ? ({~a[31], a[30:0]} << 10) : 64'h0;
	wire	[63:0]	sus11	=	(b[11]) ? ({~a[31], a[30:0]} << 11) : 64'h0;
	wire	[63:0]	sus12	=	(b[12]) ? ({~a[31], a[30:0]} << 12) : 64'h0;
	wire	[63:0]	sus13	=	(b[13]) ? ({~a[31], a[30:0]} << 13) : 64'h0;
	wire	[63:0]	sus14	=	(b[14]) ? ({~a[31], a[30:0]} << 14) : 64'h0;
	wire	[63:0]	sus15	=	(b[15]) ? ({~a[31], a[30:0]} << 15) : 64'h0;
	wire	[63:0]	sus16	=	(b[16]) ? ({~a[31], a[30:0]} << 16) : 64'h0;
	wire	[63:0]	sus17	=	(b[17]) ? ({~a[31], a[30:0]} << 17) : 64'h0;
	wire	[63:0]	sus18	=	(b[18]) ? ({~a[31], a[30:0]} << 18) : 64'h0;
	wire	[63:0]	sus19	=	(b[19]) ? ({~a[31], a[30:0]} << 19) : 64'h0;
	wire	[63:0]	sus20	=	(b[20]) ? ({~a[31], a[30:0]} << 20) : 64'h0;
	wire	[63:0]	sus21	=	(b[21]) ? ({~a[31], a[30:0]} << 21) : 64'h0;
	wire	[63:0]	sus22	=	(b[22]) ? ({~a[31], a[30:0]} << 22) : 64'h0;
	wire	[63:0]	sus23	=	(b[23]) ? ({~a[31], a[30:0]} << 23) : 64'h0;
	wire	[63:0]	sus24	=	(b[24]) ? ({~a[31], a[30:0]} << 24) : 64'h0;
	wire	[63:0]	sus25	=	(b[25]) ? ({~a[31], a[30:0]} << 25) : 64'h0;
	wire	[63:0]	sus26	=	(b[26]) ? ({~a[31], a[30:0]} << 26) : 64'h0;
	wire	[63:0]	sus27	=	(b[27]) ? ({~a[31], a[30:0]} << 27) : 64'h0;
	wire	[63:0]	sus28	=	(b[28]) ? ({~a[31], a[30:0]} << 28) : 64'h0;
	wire	[63:0]	sus29	=	(b[29]) ? ({~a[31], a[30:0]} << 29) : 64'h0;
	wire	[63:0]	sus30	=	(b[30]) ? ({~a[31], a[30:0]} << 30) : 64'h0;
	wire	[63:0]	sus31	=	(b[31]) ? ({~a[31], a[30:0]} << 31) : 64'h0;

	assign	susout	=	sus00 + sus01 + sus02 + sus03 + sus04 + sus05 + sus06 + sus07 + sus08 + sus09 + sus10 + sus11 + sus12 + sus13 + sus14 + sus15 + sus16 + sus17 + sus18 + sus19 + sus20 + sus21 + sus22 + sus23 + sus24 + sus25 + sus26 + sus27 + sus28 + sus29 + sus30 + sus31 + 64'hC0000000;

	// unsigned * unsigned
	wire	[63:0]	us00	=	(b[ 0]) ? (a <<  0) : 64'h0;
	wire	[63:0]	us01	=	(b[ 1]) ? (a <<  1) : 64'h0;
	wire	[63:0]	us02	=	(b[ 2]) ? (a <<  2) : 64'h0;
	wire	[63:0]	us03	=	(b[ 3]) ? (a <<  3) : 64'h0;
	wire	[63:0]	us04	=	(b[ 4]) ? (a <<  4) : 64'h0;
	wire	[63:0]	us05	=	(b[ 5]) ? (a <<  5) : 64'h0;
	wire	[63:0]	us06	=	(b[ 6]) ? (a <<  6) : 64'h0;
	wire	[63:0]	us07	=	(b[ 7]) ? (a <<  7) : 64'h0;
	wire	[63:0]	us08	=	(b[ 8]) ? (a <<  8) : 64'h0;
	wire	[63:0]	us09	=	(b[ 9]) ? (a <<  9) : 64'h0;
	wire	[63:0]	us10	=	(b[10]) ? (a << 10) : 64'h0;
	wire	[63:0]	us11	=	(b[11]) ? (a << 11) : 64'h0;
	wire	[63:0]	us12	=	(b[12]) ? (a << 12) : 64'h0;
	wire	[63:0]	us13	=	(b[13]) ? (a << 13) : 64'h0;
	wire	[63:0]	us14	=	(b[14]) ? (a << 14) : 64'h0;
	wire	[63:0]	us15	=	(b[15]) ? (a << 15) : 64'h0;
	wire	[63:0]	us16	=	(b[16]) ? (a << 16) : 64'h0;
	wire	[63:0]	us17	=	(b[17]) ? (a << 17) : 64'h0;
	wire	[63:0]	us18	=	(b[18]) ? (a << 18) : 64'h0;
	wire	[63:0]	us19	=	(b[19]) ? (a << 19) : 64'h0;
	wire	[63:0]	us20	=	(b[20]) ? (a << 20) : 64'h0;
	wire	[63:0]	us21	=	(b[21]) ? (a << 21) : 64'h0;
	wire	[63:0]	us22	=	(b[22]) ? (a << 22) : 64'h0;
	wire	[63:0]	us23	=	(b[23]) ? (a << 23) : 64'h0;
	wire	[63:0]	us24	=	(b[24]) ? (a << 24) : 64'h0;
	wire	[63:0]	us25	=	(b[25]) ? (a << 25) : 64'h0;
	wire	[63:0]	us26	=	(b[26]) ? (a << 26) : 64'h0;
	wire	[63:0]	us27	=	(b[27]) ? (a << 27) : 64'h0;
	wire	[63:0]	us28	=	(b[28]) ? (a << 28) : 64'h0;
	wire	[63:0]	us29	=	(b[29]) ? (a << 29) : 64'h0;
	wire	[63:0]	us30	=	(b[30]) ? (a << 30) : 64'h0;
	wire	[63:0]	us31	=	(b[31]) ? (a << 31) : 64'h0;

	assign	uuout	=	us00 + us01 + us02 + us03 + us04 + us05 + us06 + us07 + us08 + us09 + us10 + us11 + us12 + us13 + us14 + us15 + us16 + us17 + us18 + us19 + us20 + us21 + us22 + us23 + us24 + us25 + us26 + us27 + us28 + us29 + us30 + us31;
	
endmodule

module malu #(
	parameter 	W	=	0
)(
	input	[31:0]	i_dataa,
	input	[31:0]	i_datab,
	input	[3:0]	i_ctrl,

	output	[31:0]	o_result
);
	parameter	MUL		=	4'b0000,
				MULH	= 	4'b0001,
				MULHSU	=	4'b0010,
				MULHU	=	4'b0011,
				DIV		=	4'b0100,
				DIVU	=	4'b0101,
				REM		=	4'b0110,
				REMU	=	4'b1011;

	reg	[32:0]	r_result;

	generate
		if (W == 1) begin
			wire	[63:0]	w_mul_result;
			mul mul (
				.s	(i_ctrl),
				.a	(i_dataa),
				.b	(i_datab),
				.out(w_mul_result)
			);

			always @(*) begin
				case (i_ctrl)
					MUL		:	r_result	<= w_mul_result[31:0];
					MULH	:	r_result	<= w_mul_result[63:32];
					MULHSU	:	r_result	<= w_mul_result[63:32];
					MULHU	:	r_result	<= w_mul_result[63:32];
					DIV		:	r_result	<= $signed(i_dataa) / $signed(i_datab);
					DIVU	:	r_result	<= i_dataa / i_datab;
					REM		:	r_result	<= $signed(i_dataa) % $signed(i_datab);
					REMU	:	r_result	<= i_dataa % i_datab;
					default	:	r_result	<=	0;
				endcase	
			end
		end else begin
			always @(*) begin
				case (i_ctrl)
					MUL		:	r_result	<= ($signed(i_dataa) * $signed(i_datab));
					MULH	:	r_result	<= ($signed(i_dataa) * $signed(i_datab)) >> 32;
					MULHSU	:	r_result	<= ($signed(i_dataa) * i_datab) >> 32;
					MULHU	:	r_result	<= (i_dataa * i_datab) >> 32;
					DIV		:	r_result	<= $signed(i_dataa) / $signed(i_datab);
					DIVU	:	r_result	<= i_dataa / i_datab;
					REM		:	r_result	<= $signed(i_dataa) % $signed(i_datab);
					REMU	:	r_result	<= i_dataa % i_datab;
					default	:	r_result	<=	0;
				endcase	
			end
		end
	endgenerate
	
	assign	o_result = r_result;
endmodule
