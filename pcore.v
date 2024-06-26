module core #(
	parameter RVM = "FALSE",
	parameter RVF = "FALSE",
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
	
	wire	[4:0]	w_w_rda;
	wire	[31:0]	w_w_rd;
	wire			w_w_rfwe;

	wire			w_forward_dm1, w_forward_dm2, 
					w_forward_em1, w_forward_em2,
					w_forward_ew1, w_forward_ew2, 
					w_forward_mw2;
	wire	[31:0]	w_dm_fdata, w_em_fdata, w_ew_fdata, w_mw_fdata;

	wire			w_pstall;

	wire			w_vec_exec;

	wire			w_load_wait;

	wire			w_icache_hit, w_dcache_hit;
	
	// ---------- Fetch ----------

	wire	[31:0]	w_f_pc;
	wire	[31:0]	w_f_inst;

	wire			w_jump;
	wire	[31:0]	w_jump_addr;

	wire	[31:0]	w_excp;
	wire			w_excp_en;

	wire	[31:0]	w_csr_pc;
	wire			w_csr_jump;

	wire	[31:0]	w_jump_pc = (w_excp_en) ? w_csr_pc : w_jump_addr;

	pc pc (
		.clk		(clk),
		.rst		(rst),

		.stall		(i_exstall || w_pstall || w_vec_exec || w_load_wait || !w_icache_hit),

		.jp_en		(w_jump || w_csr_jump),
		.jp_addr	(w_jump_pc),

		.addr		(w_f_pc)
	);

	assign	o_iaddr = w_f_pc;

	// ---------- Decode ----------

	wire	[31:0]	w_d_pc;

	wire	[4:0]	w_d_rs1a, w_d_rs2a, w_d_rda;
	wire	[31:0]	w_d_rs1, w_d_rs2;
	wire	[2:0]	w_d_funct3;
	wire	[6:0]	w_d_funct7;
	wire	[6:0]	w_d_op;

	wire			w_d_csri;
	wire	[1:0]	w_d_csrop;
	wire	[11:0]	w_d_csraddr;
	wire			w_d_csrr;

	wire	[10:0]	w_sew;
	wire	[3:0]	w_lmul;
	wire	[31:0]	w_venum;

	assign	w_venum =	(w_sew == 11'h08)	? (VLEN /   8) *  w_lmul	:	// 8bit
						(w_sew == 11'h10)	? (VLEN /  16) *  w_lmul	:	// 16bit
						(w_sew == 11'h20)	? (VLEN /  32) *  w_lmul	:	// 32bit
						(w_sew == 11'h40)	? (VLEN /  64) *  w_lmul	:	// 64bit
						(w_sew == 11'h80)	? (VLEN / 128) *  w_lmul	:	// 128bit
						0;

	wire	[31:0]	w_d_csrid;

	wire	[3:0]	w_d_aluctl;
	wire			w_d_imm_rs;
	wire			w_d_rfwe;

	wire			w_d_write_en, w_d_read_en;

	wire	[31:0]	w_d_imm;
	wire	[31:0]	w_inst;

	wire	[31:0]	w_rs1, w_rs2;

	wire			w_return;

	assign	w_d_rs1 = (w_forward_dm1) ? w_dm_fdata : w_rs1;
	assign	w_d_rs2 = (w_forward_dm2) ? w_dm_fdata : w_rs2;

	assign	w_d_csrid = (w_d_csri) ? w_d_imm : w_d_rs1;
	
	decoder dc(
		.i_inst		(w_inst),

		.o_mwen		(w_d_write_en),
		.o_mren		(w_d_read_en),

		.o_imm_rs	(w_d_imm_rs),
		.o_rfwe		(w_d_rfwe),
		.o_ctrl		(w_d_aluctl),
		
		.o_csri		(w_d_csri),
		.o_csrop	(w_d_csrop),
		.o_csraddr	(w_d_csraddr),
		.o_csrr		(w_d_csrr),

		.o_op		(w_d_op),
		.o_rd		(w_d_rda), 
		.o_rs1		(w_d_rs1a), 
		.o_rs2		(w_d_rs2a),
		.o_funct3	(w_d_funct3),
		.o_funct7	(w_d_funct7),

		.o_imm		(w_d_imm),

		.o_return	(w_return),
		.o_excp_en	(w_excp_en),
		.o_excp		(w_excp)
	);

	regfile rf(
		.clk		(clk),

		.i_wdata	(w_w_rd),
		.i_wad		(w_w_rda),
		.i_we		(w_w_rfwe),

		.o_rdataa	(w_rs1),
		.i_rada		(w_d_rs1a),
		.o_rdatab	(w_rs2),
		.i_radb		(w_d_rs2a)
	);

	comp comp(
		.i_funct3	(w_d_funct3),
		.i_op		(w_d_op),
		.i_dataa	(w_d_rs1),
		.i_datab	(w_d_rs2),

		.o_result	(w_jump)
	);

	branch branch(
		.i_op		(w_d_op),

		.i_pc		(w_d_pc),
		.i_imm		(w_d_imm),
		.i_rs1		(w_d_rs1),

		.o_npc		(w_jump_addr)
	);

	wire	[31:0]	w_d_csrod;

	wire	[31:0]	w_d_csr_mtval	=	(i_interrupt)	?	w_d_pc+4	: // set address of external interrupt (provisional)
										(w_excp_en)		?	w_d_pc+4	: // set address of exception
															0			;

	wire	[31:0]	w_d_csr_cause	=	(i_interrupt)	?	{1'b1, 31'hb}	: // set address of external interrupt (provisional)
										(w_excp_en)		?	w_excp			: // set address of exception
															0				; 

	csr csr(
		.clk		(clk),
		.rst		(rst),

		.o_sew		(w_sew),
		.o_lmul		(w_lmul),

		.i_int_cause(w_d_csr_cause),
		.i_int_pc	(w_d_pc+4),	
		.i_int_mtval(w_d_csr_mtval),

		.o_int_jump	(w_csr_jump),
		.o_int_pc	(w_csr_pc),

		.i_interrupt_enter(w_excp_en || i_interrupt),
		.i_interrupt_exit(w_return),

		.o_interrupt(),
		.o_interrupt_data(),

		.i_datain	(w_d_csrid),
		.o_dataout	(w_d_csrod),
		.i_csr_op	(w_d_csrop),
		.i_csr_addr	(w_d_csraddr)
	);

	// ---------- Execute ----------
	wire	[2:0]	w_e_funct3;
	wire	[6:0]	w_e_funct7;
	wire	[6:0]	w_e_op;

	wire	[31:0]	w_da, w_db;

	wire			w_e_csrr;
	wire	[31:0]	w_e_csrod;

	wire	[3:0]	w_e_aluctl;
	wire			w_e_imm_rs;
	wire			w_e_rfwe;

	wire			w_e_write_en, w_e_read_en;

	wire	[31:0]	w_e_imm;

	wire	[31:0]	w_eb_rs2;
	wire	[4:0]	w_e_rs1a, w_e_rs2a, w_e_rda;
	wire	[31:0]	w_e_rs1, w_e_rs2;

	wire	[31:0]	w_e_result;

	alu alu(
		.i_dataa	(w_da),
		.i_datab	(w_db),
		.i_ctrl		(w_e_aluctl),

		.o_of		(),
		.o_result	(w_e_result)
	);

	// ---------- Memory Access ----------
	wire	[2:0]	w_m_funct3;
	wire	[6:0]	w_m_funct7;
	wire	[6:0]	w_m_op;

	wire	[31:0]	w_m_rs2;
	wire	[31:0]	w_m_result;

	wire			w_m_csrr;
	wire	[31:0]	w_m_csrod;

	wire	[4:0]	w_m_rs2a, w_m_rda;
	wire			w_m_rfwe, w_m_rfwe_reg;

	wire	[31:0]	w_m_write_data, w_lswrite_data, w_m_read_data, w_lsread_data;
	wire			w_m_write_en, w_m_read_en;
	wire	[31:0]	w_m_alu_result, w_m_int_result;

	lsunit lsunit(
		.i_op		(w_m_op),
		.i_funct3	(w_m_funct3),

		.i_wdata	(w_m_write_data),
		.o_rdata	(w_m_read_data),

		.o_wdata	(w_lswrite_data),
		.i_rdata	(w_lsread_data)
	);

	// ---------- Write Back ---------- 

	wire	[31:0]	w_w_result;
	wire	[31:0]	w_w_memdata;

	wire			w_w_csrr;
	wire	[31:0]	w_w_csrod;

	wire			w_read_en;

	assign	w_w_rd	=	(w_w_csrr)	?	w_w_csrod :
						(w_read_en)	?	w_w_memdata :
										w_w_result;


	datapath dp(
		.clk			(clk),
		.rst			(rst),

		.ex_stall		(i_exstall),
		.ex_mod_stall	(w_vec_exec),

		.i_jump			(w_jump || w_csr_jump),

		.o_fdm1			(w_forward_dm1),
		.o_fdm2			(w_forward_dm2),
		.o_fem1			(w_forward_em1),
		.o_fem2			(w_forward_em2),
		.o_few1			(w_forward_ew1),
		.o_few2			(w_forward_ew2),
		.o_fmw2			(w_forward_mw2),

		.o_dm_fdata		(w_dm_fdata),
		.o_em_fdata		(w_em_fdata),
		.o_ew_fdata		(w_ew_fdata),
		.o_mw_fdata		(w_mw_fdata),

		.i_f_pc			(w_f_pc),
		.i_f_inst		(w_f_inst),
		.o_d_pc			(w_d_pc),
		.o_d_inst		(w_inst),

		.i_d_op(w_d_op),
		.i_d_funct3(w_d_funct3),
		.i_d_funct7(w_d_funct7),
		.i_d_rs1a(w_d_rs1a), .i_d_rs2a(w_d_rs2a), .i_d_rda(w_d_rda),
		.i_d_rs1(w_d_rs1), .i_d_rs2(w_d_rs2), .i_d_imm(w_d_imm),
		.i_d_rfwe(w_d_rfwe),
		.i_d_write_en(w_d_write_en), .i_d_read_en(w_d_read_en),
		.i_d_csrr(w_d_csrr),
		.i_d_csrod(w_d_csrod),
		.o_e_op(w_e_op),
		.o_e_funct3(w_e_funct3),
		.o_e_funct7(w_e_funct7),
		.o_e_rs1a(w_e_rs1a), .o_e_rs2a(w_e_rs2a), .o_e_rda(w_e_rda),
		.o_e_rs1(w_e_rs1), .o_e_rs2(w_e_rs2), .o_e_imm(w_e_imm),
		.o_e_rfwe(w_e_rfwe),
		.o_e_write_en(w_e_write_en), .o_e_read_en(w_e_read_en),
		.o_e_csrr(w_e_csrr),
		.o_e_csrod(w_e_csrod),

		.i_d_aluctl		(w_d_aluctl),
		.i_d_imm_rs		(w_d_imm_rs),
		.o_e_aluctl		(w_e_aluctl),
		.o_e_imm_rs		(w_e_imm_rs),

		.i_e_op(w_e_op),
		.i_e_funct3(w_e_funct3),
		.i_e_funct7(w_e_funct7),
		.i_e_rs2a(w_e_rs2a), .i_e_rda(w_e_rda),
		.i_e_rs2(w_eb_rs2), .i_e_result(w_e_result),
		.i_e_rfwe(w_e_rfwe),
		.i_e_write_en(w_e_write_en), .i_e_read_en(w_e_read_en),
		.i_e_csrr(w_e_csrr),
		.i_e_csrod(w_e_csrod),
		.o_m_op(w_m_op),
		.o_m_funct3(w_m_funct3),
		.o_m_funct7(w_m_funct7),
		.o_m_rs2a(w_m_rs2a), .o_m_rda(w_m_rda),
		.o_m_rs2(w_m_rs2), .o_m_result(w_m_alu_result),
		.o_m_rfwe(w_m_rfwe),
		.o_m_write_en(w_m_write_en), .o_m_read_en(w_m_read_en),
		.o_m_csrr(w_m_csrr),
		.o_m_csrod(w_m_csrod),

		.i_m_op(w_m_op),
		.i_m_read_en(w_m_read_en),
		.i_m_read_vd(i_read_vd),
		.i_m_rda(w_m_rda),
		.i_m_result(w_m_alu_result), .i_m_memdata(w_m_read_data),
		.i_m_rfwe(w_m_rfwe_reg),
		.i_m_csrr(w_m_csrr),
		.i_m_csrod(w_m_csrod),
		.o_w_rda(w_w_rda),
		.o_w_result(w_w_result), .o_w_memdata(w_w_memdata),
		.o_w_rfwe(w_w_rfwe),
		.o_w_csrr(w_w_csrr),
		.o_w_csrod(w_w_csrod),

		.i_w_rd			(w_w_rd),

		.load_wait		(w_load_wait),
		.stall			(w_pstall)
	);


	// Execute stage forward
	assign	w_da =		(w_forward_em1)	? w_em_fdata :
						(w_forward_ew1)	? w_ew_fdata :
						w_e_rs1;

	assign	w_db =		(w_e_imm_rs)	? w_e_imm :
						w_eb_rs2;

	assign	w_eb_rs2 =	(w_forward_em2)	? w_em_fdata :
						(w_forward_ew2)	? w_ew_fdata :
						w_e_rs2;
	
	// Memory Access stage forward
	// -- o_write_data

	generate
		if (RVM == "TRUE") begin
			wire	[31:0]	w_m_mul_result;
			malu #(
				.CYCLE(2)
			) malu (
				.clk		(clk),
				.i_dataa	(w_da),
				.i_datab	(w_db),
				.i_ctrl		(w_e_aluctl),

				.o_result	(w_m_mul_result)
			);
			assign	w_m_int_result = (w_m_funct7 == 7'h1 && w_m_op == 7'b0110011) ?	w_m_mul_result : w_m_alu_result;
		end else begin
			assign	w_m_int_result = w_m_alu_result;
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

				.i_ops			(w_d_op),		// operation
				.i_funct6		(w_d_funct7[6:1]),
				.i_funct3		(w_d_funct3),

				.i_rs1			(w_d_rs1),
				.i_rs2			(w_d_rs2),
				.i_vs1a			(w_d_rs1a),
				.i_vs2a			(w_d_rs2a),
				.i_vs3a			(w_d_rda),

				// Read/Write length and other parameter
				.i_sew			(w_sew),	// element width of vector
				.i_lmul			(w_lmul),	// using register length
				.i_venum		(w_venum),	// number of vector element

				// Memory interface access
				.o_write_en		(w_vwrite_en),
				.o_write_data	(w_vwrite_data),

				.o_read_en		(w_vread_en),
				.i_read_vd		(!w_load_wait),
				.i_read_data	(w_lsread_data),
				.o_memaddr		(w_vmemaddr)
			);

			assign	o_memaddr		=	(w_vec_exec)	?	w_vmemaddr	:	w_m_alu_result;
	
			assign	o_write_en		=	(w_vec_exec)	?	w_vwrite_en	:	w_m_write_en;
			assign	w_read_en		=	(w_vec_exec)	?	w_vread_en	:	w_m_read_en;

			assign	o_write_data	=	(w_vec_exec)	? w_vwrite_data :
										w_lswrite_data;
			assign	w_m_write_data	=	(w_forward_mw2)	? w_mw_fdata :
										w_m_rs2;
		end else begin

			assign	o_memaddr		=	w_m_alu_result;
	
			assign	o_write_en		=	w_m_write_en;
			assign	w_read_en		=	w_m_read_en;

			assign	w_m_write_data	=	(w_forward_mw2)	? w_mw_fdata :
										w_m_rs2;
			assign	o_write_data	=	w_lswrite_data;

			assign	w_vec_exec	=	0;
		end
	endgenerate

	generate
		if (RVF == "TRUE") begin
			wire	[31:0]	w_m_float_result, w_m_fdata;
			wire			w_m_rfwe_float;
			fpu fpu(
				.clk		(clk),
				.rst		(rst),

				.i_ops		(w_e_op),
				.i_funct7	(w_e_funct7),
				.i_funct3	(w_e_funct3),

				.rs1_a		(w_e_rs1a),
				.rs2_a		(w_e_rs2a),
				.rd_a		(w_w_rda),

				.rs1_d		(w_e_rs1),

				.out		(w_m_float_result),

				.rd_en		(w_m_rfwe_float),
				.rd_data	(w_m_fdata)
			);

			assign	w_m_rfwe_reg	=	(w_op != 7'b0000111) ? w_m_rfwe : 1'b0;
			assign	w_m_rfwe_float	=	(w_op == 7'b0000111) ? w_m_rfwe : 1'b0;

			assign	w_m_result	=	(w_m_op == 7'b1010011) ? w_m_float_result : w_m_int_result;
			assign	w_m_fdata 	=	w_m_read_en ? w_m_read_data : w_m_result;

		end else begin
			assign	w_m_rfwe_reg	=	w_rfwe;

			assign	w_m_result	=	w_m_int_result;
		end
	endgenerate

	icache icache (
		.clk		(clk), 
		.rst		(rst),

		.o_hit		(w_icache_hit),

		.o_rdata	(w_f_inst),
		.i_addr		(w_f_pc),

		.i_wen		(i_iread_vd),
		.i_waddr	(w_f_pc),
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

	assign	o_read_en	=	!w_dcache_hit && w_read_en;

endmodule