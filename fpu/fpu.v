module fpu (
	input			clk, rst,
	input	[6:0]	i_ops,
	input	[6:0]	i_funct7,
	input	[2:0]	i_funct3,

	input	[4:0]	rs1_a, rs2_a, rd_a,
	input	[31:0]	rs1_d,

	output	[31:0]	out,

	input			rd_en,
	input	[31:0]	rd_data
);
	wire	[63:0]	w_out;
	wire	[3:0]	w_aluops;

	// register write enable
	wire	w_fsd_en =	rd_en ? 1'b1 :
						(i_ops == 7'h53) ? 
							(
								w_aluops < 4'hA || 
								i_funct7[6:2] == 5'h18 || 
								i_funct7 == 7'h50
							) :
						1'b0;

	falu_decoder decoder(
		.ops		(i_ops),
		.funct7		(i_funct7),
		.funct3		(i_funct3),

		.o_ops		(w_aluops)
	);

	wire	[63:0]	w_frs1, w_frs2, w_fsd;

	regfile #(
		.DW			(64)
	) frf (
		.clk		(clk),

		.i_wdata	(w_fsd),
		.i_wad		(rd_a),
		.i_we		(w_fsd_en),

		.o_rdataa	(w_frs1),	
		.i_rada		(rs1_a),
		.o_rdatab	(w_frs2),
		.i_radb		(rs2_a)
	);

	wire	[31:0]	w_ffrd;
	wire	[63:0]	w_fdrd;
	
	falu falu(
		.ops	(w_aluops),

		.rs1	(w_frs1),
		.rs2	(w_frs2),
		.out	(w_ffrd)
	);

	dalu dalu(
		.ops	(w_aluops),

		.rs1	(w_frs1[31:0]),
		.rs2	(w_frs2[31:0]),
		.out	(w_fdrd)
	);

	wire	[31:0]	w_f2i, w_i2f;
	wire	[63:0]	w_d2i, w_i2d;

	fcvt_f2i f2i(
		.s_signed(rs2_a[0]),
		.a(w_frs1[31:0]),
		.out(w_f2i)
	);

	fcvt_i2f i2f(
		.s_signed(rs2_a[0]),
		.a(rs1_d),
		.out(w_i2f)
	);

	fcvt_d2i d2i(
		.s_signed(rs2_a[0]),
		.a(w_frs1),
		.out(w_d2i)
	);

	fcvt_i2d i2d(
		.s_signed(rs2_a[0]),
		.a(rs1_d),
		.out(w_i2d)
	);

	assign	w_fsd	=	rd_en ? rd_data :
						(i_funct7[1:0] == 2'b00 && w_aluops == 4'hF)
									?	{32'h0, w_ffrd}	:
						(i_funct7[1:0] == 2'b01 && w_aluops == 4'hF)
									?	w_fdrd	:
						(i_funct7 == 7'b1101000)
									?	w_i2f	:
						(i_funct7 == 7'b1111000)
									?	{32'b0, rs1_d}	:
						(i_funct7 == 7'b1101001)
									?	w_i2d	:
						64'h0;

	assign	w_out	=	(i_funct7 == 7'b1010000)
									?	{32'h0, w_ffrd}	:
						(i_funct7 == 7'b1010001)
									?	w_fdrd	:
						(i_funct7 == 7'b1100000 && w_aluops == 4'hF)
									?	w_f2i	:
						(i_funct7 == 7'b1100001 && w_aluops == 4'hF)
									?	w_d2i	:
						32'h0;

endmodule

module falu_decoder(
	input	[6:0]	ops,
	input	[6:0]	funct7,
	input	[2:0]	funct3,

	output	[3:0]	o_ops
);
	function [3:0]	dec;
		input	[6:0]	op;
		input	[6:0]	f7;
		input	[2:0]	f3;
	begin
		case (op)
			7'h53: begin
				case (f7)
					7'h00:	dec	=	4'b0;	// Add
					7'h04:	dec	=	4'h1;	// Sub
					7'h08:	dec	=	4'h2;	// Mul
					7'h0C:	dec	=	4'h3;	// Div
					7'h2C:	dec	=	4'h4;	// Sqrt
					7'h10:	begin
						case(f3)
							3'h0:	dec	=	4'h5;	// sgnj
							3'h1:	dec	=	4'h6;	// sgnjn
							3'h2:	dec	=	4'h7;	// sgnjx
							default:dec	=	4'hF;
						endcase
					end
					7'h18:	begin
						case(f3)
							3'h0:	dec	=	4'h8;	// max
							3'h1:	dec	=	4'h9;	// min
							default:dec	=	4'hF;
						endcase
					end
					7'h50:	begin
						case(f3)
							3'h0:	dec	=	4'hA;	// eq
							3'h1:	dec	=	4'hB;	// lt
							3'h2:	dec	=	4'hC;	// le
							default:dec	=	4'hF;
						endcase
					end
					default:dec	=	4'hF;
				endcase
			end
		endcase
	end
	endfunction

	assign	o_ops	=	dec(ops, funct7, funct3);
endmodule