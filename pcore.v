module core (
	input			clk,
	input			rst,

	input			i_exstall,

	input	[31:0]	i_inst,
	output	[31:0]	o_iaddr,

	input	[31:0]	i_read_data,
	output			o_read_en,
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
	
	// ---------- Fetch ----------

	wire	[31:0]	w_f_pc;

	wire			w_jump;
	wire	[31:0]	w_jump_addr;

	pc pc (
		.clk		(clk),
		.rst		(rst),

		.stall		(i_exstall || w_pstall),

		.jp_en		(w_jump),
		.jp_addr	(w_jump_addr),

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

	wire	[31:0]	w_d_csrid;

	wire	[3:0]	w_d_aluctl;
	wire			w_d_imm_rs;
	wire			w_d_rfwe;

	wire			w_d_write_en, w_d_read_en;

	wire	[31:0]	w_d_imm;
	wire	[31:0]	w_inst;

	wire	[31:0]	w_rs1, w_rs2;

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

		.o_imm		(w_d_imm)
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

	csr csr(
		.clk		(clk),
		.rst		(rst),

		.i_datain	(w_d_csrid),
		.o_dataout	(w_d_csrod),
		.i_csr_op	(w_d_csrop),
		.i_csr_addr	(w_d_csraddr)
	);

	// ---------- Execute ----------

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

	wire	[31:0]	w_m_rs2;
	wire	[31:0]	w_m_result;

	wire			w_m_csrr;
	wire	[31:0]	w_m_csrod;

	wire	[4:0]	w_m_rs2a, w_m_rda;
	wire			w_m_rfwe;

	assign	o_memaddr	=	w_m_result;

	// ---------- Write Back ---------- 

	wire	[31:0]	w_w_result;
	wire	[31:0]	w_w_memdata;

	wire			w_w_csrr;
	wire	[31:0]	w_w_csrod;


	// ※ csr命令の信号をdatapathに接続する
	assign	w_w_rd	=	(w_w_csrr)	?	w_w_csrod :
						(o_read_en)	?	w_w_memdata :
										w_w_result;

	
	datapath dp(
		.clk		(clk),
		.rst		(rst),

		.ex_stall	(i_exstall),

		.i_jump		(w_jump),

		.o_fdm1		(w_forward_dm1),
		.o_fdm2		(w_forward_dm2),
		.o_fem1		(w_forward_em1),
		.o_fem2		(w_forward_em2),
		.o_few1		(w_forward_ew1),
		.o_few2		(w_forward_ew2),
		.o_fmw2		(w_forward_mw2),

		.o_dm_fdata	(w_dm_fdata),
		.o_em_fdata	(w_em_fdata),
		.o_ew_fdata	(w_ew_fdata),
		.o_mw_fdata	(w_mw_fdata),

		.i_f_pc		(w_f_pc),
		.i_f_inst	(i_inst),
		.o_d_pc		(w_d_pc),
		.o_d_inst	(w_inst),

		.i_d_rs1a(w_d_rs1a), .i_d_rs2a(w_d_rs2a), .i_d_rda(w_d_rda),
		.i_d_rs1(w_d_rs1), .i_d_rs2(w_d_rs2), .i_d_imm(w_d_imm),
		.i_d_rfwe(w_d_rfwe),
		.i_d_write_en(w_d_write_en), .i_d_read_en(w_d_read_en),
		.i_d_csrr(w_d_csrr),
		.i_d_csrod(w_d_csrod),
		.o_e_rs1a(w_e_rs1a), .o_e_rs2a(w_e_rs2a), .o_e_rda(w_e_rda),
		.o_e_rs1(w_e_rs1), .o_e_rs2(w_e_rs2), .o_e_imm(w_e_imm),
		.o_e_rfwe(w_e_rfwe),
		.o_e_write_en(w_e_write_en), .o_e_read_en(w_e_read_en),
		.o_e_csrr(w_e_csrr),
		.o_e_csrod(w_e_csrod),

		.i_d_aluctl	(w_d_aluctl),
		.i_d_imm_rs	(w_d_imm_rs),
		.o_e_aluctl	(w_e_aluctl),
		.o_e_imm_rs	(w_e_imm_rs),

		.i_e_rs2a(w_e_rs2a), .i_e_rda(w_e_rda),
		.i_e_rs2(w_eb_rs2), .i_e_result(w_e_result),
		.i_e_rfwe(w_e_rfwe),
		.i_e_write_en(w_e_write_en), .i_e_read_en(w_e_read_en),
		.i_e_csrr(w_e_csrr),
		.i_e_csrod(w_e_csrod),
		.o_m_rs2a(w_m_rs2a), .o_m_rda(w_m_rda),
		.o_m_rs2(w_m_rs2), .o_m_result(w_m_result),
		.o_m_rfwe(w_m_rfwe),
		.o_m_write_en(o_write_en), .o_m_read_en(o_read_en),
		.o_m_csrr(w_m_csrr),
		.o_m_csrod(w_m_csrod),

		.i_m_rda(w_m_rda),
		.i_m_result(w_m_result), .i_m_memdata(i_read_data),
		.i_m_rfwe(w_m_rfwe),
		.i_m_csrr(w_m_csrr),
		.i_m_csrod(w_m_csrod),
		.o_w_rda(w_w_rda),
		.o_w_result(w_w_result), .o_w_memdata(w_w_memdata),
		.o_w_rfwe(w_w_rfwe),
		.o_w_csrr(w_w_csrr),
		.o_w_csrod(w_w_csrod),

		.i_w_rd(w_w_rd),

		.stall(w_pstall)
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

	assign	o_write_data	=	(w_forward_mw2)	?
								w_mw_fdata :
								w_m_rs2;

endmodule