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

	wire	[31:0]	w_pc;

	wire			w_jump;
	wire	[31:0]	w_jump_addr;

	pc pc (
		.clk		(clk),
		.rst		(rst),

		.stall		(i_exstall),

		.jp_en		(w_jump),
		.jp_addr	(w_jump_addr),

		.addr		(w_pc)
	);

	assign	o_iaddr = w_pc;

	wire	[4:0]	w_rs1a, w_rs2a, w_rda;
	wire	[31:0]	w_rs1, w_rs2, w_rd;
	wire	[2:0]	w_funct3;
	wire	[6:0]	w_funct7;
	wire	[6:0]	w_op;

	wire			w_csri;
	wire	[1:0]	w_csrop;
	wire	[11:0]	w_csraddr;
	wire			w_csrr;

	wire	[31:0]	w_csrid;

	wire	[3:0]	w_aluctl;
	wire			w_imm_rs;
	wire			w_rfwe;

	wire	[31:0]	w_imm;

	assign	w_csrid = (w_csri) ? w_imm : w_rs1;
	
	decoder dc(
		.i_inst		(i_inst),

		.o_mwen		(o_write_en),
		.o_mren		(o_read_en),

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

		.o_imm		(w_imm)
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

	csr csr(
		.clk		(clk),
		.rst		(rst),

		.i_datain	(w_csrid),
		.o_dataout	(w_csrod),
		.i_csr_op	(w_csrop),
		.i_csr_addr	(w_csraddr)
	);

	wire	[31:0]	w_da, w_db;

	wire	[31:0]	w_result;

	alu alu(
		.i_dataa	(w_da),
		.i_datab	(w_db),
		.i_ctrl		(w_aluctl),

		.o_of		(),
		.o_result	(w_result)
	);

	assign	o_memaddr	=	w_result;

	reg	r_csrr;

	always @(posedge clk) begin
		if (rst) begin
			r_csrr	<=	1'b0;
		end else begin
			r_csrr	<=	w_csrr;
		end
	end

	assign	w_rd	=	(r_csrr)	?	w_csrod :
						(o_read_en)	?	i_read_data :
										w_result;

	assign	w_da =		w_rs1;
	assign	w_db =		(w_imm_rs)	? w_imm :	w_rs2;

	assign	o_write_data	=	w_rs2;

endmodule