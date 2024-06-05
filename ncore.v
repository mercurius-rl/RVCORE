module core #(
	parameter RVM = "FALSE",
	parameter RVV = "FALSE",
	parameter VLEN = 128
)(
	input			clk,
	input			rst,

	input			i_exstall,

	input			i_interrupt,

	input	[31:0]	i_inst,
	output	[31:0]	o_iaddr,
	input			i_iread_vd,
	output			o_iread_en,

	input	[31:0]	i_read_data,
	output			o_read_en,
	input			i_read_vd,
	output	[31:0]	o_write_data,
	output			o_write_en,
	output	[31:0]	o_memaddr
);

	wire			w_vec_exec;
	wire			w_load_wait;

	wire			w_icache_hit, w_dcache_hit;

	wire	[31:0]	w_pc;
	wire	[31:0]	w_inst;

	wire			w_jump;
	wire	[31:0]	w_jump_addr;

	wire	[31:0]	w_excp;
	wire			w_excp_en;

	wire	[31:0]	w_csr_pc;
	wire			w_csr_jump;

	wire			w_return;

	wire	[31:0]	w_jump_pc = (w_excp_en) ? w_csr_pc : w_jump_addr;

	pc pc (
		.clk		(clk),
		.rst		(rst),

		.stall		(i_exstall || w_vec_exec || w_load_wait || !w_icache_hit),

		.jp_en		(w_jump || w_csr_jump),
		.jp_addr	(w_jump_pc),

		.addr		(w_pc)
	);

	assign	o_iaddr = w_pc;

	wire	[4:0]	w_rs1a, w_rs2a, w_rda;
	wire	[31:0]	w_rs1, w_rs2, w_rd;
	wire	[2:0]	w_funct3;
	wire	[6:0]	w_funct7;
	wire	[6:0]	w_op;

	wire			w_read_en;
	wire			w_write_en;
	wire			w_dread_en;

	wire	[31:0]	w_lswrite_data, w_lsread_data, w_read_data;

	wire			w_csri;
	wire	[1:0]	w_csrop;
	wire	[11:0]	w_csraddr;
	wire			w_csrr;

	wire	[10:0]	w_sew;
	wire	[3:0]	w_lmul;
	wire	[31:0]	w_venum;

	assign	w_venum =	(w_sew == 11'h08)	? (VLEN /   8) *  w_lmul	:	// 8bit
						(w_sew == 11'h10)	? (VLEN /  16) *  w_lmul	:	// 16bit
						(w_sew == 11'h20)	? (VLEN /  32) *  w_lmul	:	// 32bit
						(w_sew == 11'h40)	? (VLEN /  64) *  w_lmul	:	// 64bit
						(w_sew == 11'h80)	? (VLEN / 128) *  w_lmul	:	// 128bit
						0;

	assign	w_load_wait = (w_op == 7'b0000011 || w_op == 7'b0000111) ? !(o_read_en && i_read_vd) : 0;

	wire	[31:0]	w_csrid;

	wire	[3:0]	w_aluctl;
	wire			w_imm_rs;
	wire			w_rfwe;

	wire	[31:0]	w_imm;

	assign	w_csrid = (w_csri) ? w_imm : w_rs1;
	
	decoder dc(
		.i_inst		(w_inst),

		.o_mwen		(w_write_en),
		.o_mren		(w_read_en),

		.o_imm_rs	(w_imm_rs),
		.o_rfwe		(w_rfwe),
		.o_ctrl		(w_aluctl),
		
		.o_csri		(w_csri),
		.o_csrop	(w_csrop),
		.o_csraddr	(w_csraddr),
		.o_csrr		(w_csrr),

		.o_op		(w_op),
		.o_rd		(w_rda), 
		.o_rs1		(w_rs1a), 
		.o_rs2		(w_rs2a),
		.o_funct3	(w_funct3),
		.o_funct7	(w_funct7),

		.o_imm		(w_imm),

		.o_return	(w_return),
		.o_excp_en	(w_excp_en),
		.o_excp		(w_excp)
	);

	regfile rf(
		.clk		(clk),

		.i_wdata	(w_rd),
		.i_wad		(w_rda),
		.i_we		(w_rfwe),

		.o_rdataa	(w_rs1),
		.i_rada		(w_rs1a),
		.o_rdatab	(w_rs2),
		.i_radb		(w_rs2a)
	);

	comp comp(
		.i_funct3	(w_funct3),
		.i_op		(w_op),
		.i_dataa	(w_rs1),
		.i_datab	(w_rs2),

		.o_result	(w_jump)
	);

	branch branch(
		.i_op		(w_op),

		.i_pc		(w_pc),
		.i_imm		(w_imm),
		.i_rs1		(w_rs1),

		.o_npc		(w_jump_addr)
	);

	wire	[31:0]	w_csrod;

	wire	[31:0]	w_csr_mtval	=	(i_interrupt)	?	w_pc+4	: // set address of external interrupt (provisional)
									(w_excp_en)		?	w_pc+4	: // set address of exception
														0		;

	wire	[31:0]	w_csr_cause	=	(i_interrupt)	?	{1'b1, 31'hb}	: // set address of external interrupt (provisional)
									(w_excp_en)		?	w_excp			: // set address of exception
														0				; 

	csr csr(
		.clk		(clk),
		.rst		(rst),

		.o_sew		(w_sew),
		.o_lmul		(w_lmul),

		.i_int_cause(w_csr_cause),
		.i_int_pc	(w_pc+4),	
		.i_int_mtval(w_csr_mtval),

		.o_int_jump	(w_csr_jump),
		.o_int_pc	(w_csr_pc),

		.i_interrupt_enter(w_excp_en || i_interrupt),
		.i_interrupt_exit(w_return),

		.o_interrupt(),
		.o_interrupt_data(),

		.i_datain	(w_csrid),
		.o_dataout	(w_csrod),
		.i_csr_op	(w_csrop),
		.i_csr_addr	(w_csraddr)
	);

	wire	[31:0]	w_da, w_db;

	wire	[31:0]	w_result;
	wire	[31:0]	w_alu_result;

	alu alu(
		.i_dataa	(w_da),
		.i_datab	(w_db),
		.i_ctrl		(w_aluctl),

		.o_of		(),
		.o_result	(w_alu_result)
	);

	reg	r_csrr;

	always @(posedge clk) begin
		if (rst) begin
			r_csrr	<=	1'b0;
		end else begin
			r_csrr	<=	w_csrr;
		end
	end

	assign	w_rd	=	(r_csrr)	?	w_csrod :
						(w_read_en)	?	w_read_data :
										w_result;

	assign	w_da =		w_rs1;
	assign	w_db =		(w_imm_rs)	? w_imm :	w_rs2;

	lsunit lsunit(
		.i_op		(w_op),
		.i_funct3	(w_funct3),

		.i_wdata	(w_rs2),
		.o_rdata	(w_read_data),

		.o_wdata	(w_lswrite_data),
		.i_rdata	(w_lsread_data)
	);

	generate
		if (RVM == "TRUE") begin
			wire	[31:0]	w_mul_result;
			malu #(
				.CYCLE(1)
			)malu (
				.i_dataa	(w_da),
				.i_datab	(w_db),
				.i_ctrl		(w_aluctl),

				.o_result	(w_mul_result)
			);

			assign	w_result = (w_funct7 == 7'h1 && w_op == 7'b0110011) ? w_mul_result : w_alu_result;
		end else begin
			assign	w_result = w_alu_result;
		end
	endgenerate

	generate
		if (RVV == "TRUE") begin
			wire	[31:0]	w_vmemaddr;
	
			wire			w_vwrite_en;
			wire			w_vread_en;

			wire	[31:0]	w_vwrite_data;

			vector_ex #(
				.VLEN			(VLEN)
			) vector_ex (
				.clk			(clk),
				.rst			(rst),

				.busy			(w_vec_exec),

				.i_ops			(w_op),		// operation
				.i_funct6		(w_funct7[6:1]),
				.i_funct3		(w_funct3),

				.i_rs1			(w_rs1),
				.i_rs2			(w_rs2),
				.i_vs1a			(w_rs1a),
				.i_vs2a			(w_rs2a),
				.i_vs3a			(w_rda),

				// Read/Write length and other parameter
				.i_sew			(w_sew),	// element width of vector
				.i_lmul			(w_lmul),	// using register length
				.i_venum		(w_venum),	// number of vector element

				// Memory interface access
				.o_write_en		(w_vwrite_en),
				.o_write_data	(w_vwrite_data),

				.o_read_en		(w_vread_en),
				.i_read_vd		(!w_load_wait),
				.i_read_data	(i_read_data),
				.o_memaddr		(w_vmemaddr)
			);

			assign	o_memaddr		=	(w_vec_exec)	?	w_vmemaddr		:	w_result;
	
			assign	o_write_en		=	(w_vec_exec)	?	w_vwrite_en		:	w_write_en;
			assign	w_dread_en		=	(w_vec_exec)	?	w_vread_en		:	w_read_en;

			assign	o_write_data	=	(w_vec_exec)	?	w_vwrite_data	:	w_lswrite_data;
		end else begin

			assign	o_memaddr		=	w_result;
	
			assign	o_write_en		=	w_write_en;
			assign	w_dread_en		=	w_read_en;

			assign	o_write_data	=	w_lswrite_data;

			assign	w_vec_exec	=	0;
		end
	endgenerate

	icache icache(
		.clk		(clk), 
		.rst		(rst),

		.o_hit		(w_icache_hit),

		.o_rdata	(w_inst),
		.i_addr		(w_pc),

		.i_wen		(i_iread_vd),
		.i_waddr	(w_pc),
		.i_wdata	(i_inst)
	);

	assign	o_iread_en	=	!w_icache_hit;

	dcache dcache (
		.clk		(clk), 
		.rst		(rst),

		.o_hit		(w_dcache_hit),

		.i_wen		(o_write_en),
		.i_wdata	(o_write_data),
		.o_rdata	(w_lsread_data),
		.i_addr		(o_memaddr),

		.i_mwen		(i_read_vd),
		.i_maddr	(o_memaddr),
		.i_mdata	(i_read_data)
	);

	assign	o_read_en	=	!w_dcache_hit && w_dread_en;

endmodule