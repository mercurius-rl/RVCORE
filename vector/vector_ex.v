module vector_ex #(
	parameter	VLEN	=	128
) (
	input		clk,
	input		rst,

	output		busy,

	input	[6:0]		i_ops,
	input	[5:0]		i_funct6,
	input	[2:0]		i_funct3,

	input	[31:0]		i_rs1,		// register file 1
	input	[31:0]		i_rs2,		// register file 2

	input	[4:0]		i_vs1a,		// vector reg 1 
	input	[4:0]		i_vs2a,		// vector reg 2 
	input	[4:0]		i_vs3a,		// vector reg 3 | d

	// Read/Write length and other parameter
	input	[10:0]		i_sew,
	input	[3:0]		i_lmul,
	input	[31:0]		i_venum,

	// Memory interface access
	output				o_write_en,
	output	[31:0]		o_write_data,

	output				o_read_en,
	input				i_read_vd,
	input	[31:0]		i_read_data,
	output	[31:0]		o_memaddr
);

	parameter	IDLE	=	4'h0,
				VALU	=	4'h1,
				VMA		=	4'h2,

				ENDS	=	4'hf;

	wire	w_vma_done;
	wire	w_alu_done;

	reg		[3:0]	r_vmstate;
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			r_vmstate	<=	IDLE;
		end else begin
			case (r_vmstate)
				IDLE: begin
					if (i_ops == 7'h07 || i_ops == 7'h27) begin
						r_vmstate	<=	VMA;
					end else if (i_ops == 7'h57) begin
						r_vmstate	<=	VALU;
					end
				end
				VMA: begin
					if (w_vma_done) begin
						r_vmstate	<=	ENDS;
					end
				end
				VALU: begin
					if (w_alu_done) begin
						r_vmstate	<=	ENDS;
					end
				end

				ENDS: begin
					r_vmstate	<=	IDLE;
				end
				default: r_vmstate	<=	r_vmstate;
			endcase
		end
	end

	wire	[VLEN-1:0]	w_vs1, w_vs2, w_vsd;
	wire	[4:0]		w_vs1a, w_vs2a, w_vsda;
	wire				w_vsa_en;

	wire	[VLEN-1:0]	w_vs1_mem, w_vs1_alu;
	wire	[VLEN-1:0]	w_vs2_mem, w_vs2_alu;
	wire	[4:0]		w_vs1a_mem, w_vs1a_alu;
	wire	[4:0]		w_vs2a_mem, w_vs2a_alu;

	wire	[VLEN-1:0]	w_vsd_mem, w_vsd_alu;
	wire	[4:0]		w_vsda_mem, w_vsda_alu;
	wire				w_vsd_en_mem, w_vsd_en_alu;

	wire	[6:0]		w_ops = i_ops;
	wire	[5:0]		w_funct6;
	wire	[1:0]		w_mop;

	assign	w_funct6 = i_funct6; //temporary signal

	assign	w_mop	=	w_funct6[1:0];

	wire	sel; 				// temporary signal (High is memory access)

	assign	w_vs1a		= (sel) ? w_vs1a_mem	:	w_vs1a_alu;
	assign	w_vs1_mem	= (sel) ? w_vs1			:	0;
	assign	w_vs1_alu	= (sel) ? 0				:	w_vs1;

	assign	w_vs2a		= (sel) ? w_vs2a_mem	:	w_vs2a_alu;
	assign	w_vs2_mem	= (sel) ? w_vs2			:	0;
	assign	w_vs2_alu	= (sel) ? 0				:	w_vs2;

	assign	w_vsd		= (sel) ? w_vsd_mem		:	w_vsd_alu;
	assign	w_vsda		= (sel) ? w_vsda_mem	:	w_vsda_alu;
	assign	w_vsd_en	= (sel) ? w_vsd_en_mem	:	w_vsd_en_alu;

	assign	sel			= (r_vmstate == VMA);

	// Controle VALU Sequence
	reg		[4:0]	r_vs1a, r_vs2a, r_vsda;
	reg		[2:0]	r_vacount;
	reg				r_alu_done;
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			r_vs1a		<=	0;
			r_vs2a		<=	0;
			r_vsda		<=	0;
			r_vacount	<=	0;
			r_alu_done	<=	0;
		end else begin
			if (r_vacount == 0 && i_ops == 7'h57) begin
				r_vs1a		<=	i_vs1a;
				r_vs2a		<=	i_vs2a;
				r_vsda		<=	i_vs3a;
				r_vacount	<=	r_vacount + 1;
				r_alu_done	<=	0;
			end else if (r_vacount >= (i_lmul + 1)) begin
				r_vs1a		<=	0;
				r_vs2a		<=	0;
				r_vsda		<=	r_vsda;
				r_vacount	<=	0;
				r_alu_done	<=	1;
			end else if (r_vmstate == VALU) begin
				r_vs1a		<=	r_vs1a + 1;
				r_vs2a		<=	r_vs2a + 1;
				r_vsda		<=	r_vsda + 1;
				r_vacount	<=	r_vacount + 1;
				r_alu_done	<=	0;
			end else begin
				r_vs1a		<=	0;
				r_vs2a		<=	0;
				r_vsda		<=	0;
				r_vacount	<=	0;
				r_alu_done	<=	0;
			end
		end
	end

	assign	w_vs1a_alu		=	r_vs1a;
	assign	w_vs2a_alu		=	r_vs2a;
	assign	w_vsda_alu		= 	r_vsda;
	assign	w_vsd_en_alu	=	(r_vacount != 0 && r_vmstate == VALU);

	assign	w_alu_done		=	r_alu_done;

	valu #(
		.VLEN		(VLEN)
	) valu (
		.i_sew		(i_sew),

		.i_dataa	(w_vs1_alu),
		.i_datab	(w_vs2_alu),
		.i_ctrl		(w_funct6),

		.o_result	(w_vsd_alu)
	);

	regfile #(
		.DW			(VLEN)
	) vrf (
		.clk		(clk),

		.i_wdata	(w_vsd),
		.i_wad		(w_vsda),
		.i_we		(w_vsd_en),

		.o_rdataa	(w_vs1),	
		.i_rada		(w_vs1a),
		.o_rdatab	(w_vs2),
		.i_radb		(w_vs2a)
	);

	vma #(
		.VLEN		(VLEN)
	) vma (
		.clk		(clk),
		.rst		(rst),

		.busy		(),
		.done		(w_vma_done),
	
		.i_ops		(w_ops),
		.i_mop		(w_mop),	
		.i_width	(i_funct3),	

		.i_rs1		(i_rs1),
		.i_rs2		(i_rs2),

		.i_vs1a		(i_vs3a),
		.i_vs2a		(i_vs2a),

		.i_sew		(i_sew),
		.i_lmul		(i_lmul),
		.i_venum	(i_venum),
	
	// Vector register access
		.o_wraddr		(w_vs1a_mem),
		.i_vwdata		(w_vs1_mem),

		.o_rraddr		(w_vsda_mem),
		.o_vr_en		(w_vsd_en_mem),
		.o_vrdata		(w_vsd_mem),

		.o_idxaddr		(w_vs2a_mem),
		.i_idxdata		(w_vs2_mem),

	// Memory access
		.o_write_en		(o_write_en),
		.o_write_data	(o_write_data),

		.o_read_en		(o_read_en),
		.i_read_vd		(i_read_vd),
		.i_read_data	(i_read_data),
		.o_memaddr		(o_memaddr)
	);

	assign	busy = (r_vmstate != IDLE);
	
endmodule