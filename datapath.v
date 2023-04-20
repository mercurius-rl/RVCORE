`timescale 1ns / 1ps
module datapath(
	input			clk,
	input			rst,

	input			ex_stall,
	input			ex_mod_stall,

	input			i_jump,

	output			o_fdm1,
	output			o_fdm2,
	output			o_fem1,
	output			o_fem2,
	output			o_few1,
	output			o_few2,
	output			o_fmw2,

	output	[31:0]	o_dm_fdata, o_em_fdata, o_ew_fdata, o_mw_fdata,


	input	[31:0]	i_f_pc,
	input	[31:0]	i_f_inst,
	output	[31:0]	o_d_pc,
	output	[31:0]	o_d_inst,

	input	[4:0]	i_d_rs1a, i_d_rs2a, i_d_rda,
	input	[31:0]	i_d_rs1, i_d_rs2, i_d_imm,
	input			i_d_rfwe,
	input			i_d_write_en, i_d_read_en,
	input			i_d_csrr,
	input	[31:0]	i_d_csrod,
	output	[4:0]	o_e_rs1a, o_e_rs2a, o_e_rda,
	output	[31:0]	o_e_rs1, o_e_rs2, o_e_imm,
	output			o_e_rfwe,
	output			o_e_write_en, o_e_read_en,
	output			o_e_csrr,
	output	[31:0]	o_e_csrod,

	input	[3:0]	i_d_aluctl,
	input			i_d_imm_rs,
	output	[3:0]	o_e_aluctl,
	output			o_e_imm_rs,

	input	[4:0]	i_e_rs2a, i_e_rda,
	input	[31:0]	i_e_rs2, i_e_result,
	input			i_e_rfwe,
	input			i_e_write_en, i_e_read_en,
	input			i_e_csrr,
	input	[31:0]	i_e_csrod,
	output	[4:0]	o_m_rs2a, o_m_rda,
	output	[31:0]	o_m_rs2, o_m_result,
	output			o_m_rfwe,
	output			o_m_write_en, o_m_read_en,
	output			o_m_csrr,
	output	[31:0]	o_m_csrod,

	input	[4:0]	i_m_rda,
	input	[31:0]	i_m_result, i_m_memdata,
	output			i_m_rfwe,
	input			i_m_csrr,
	input	[31:0]	i_m_csrod,
	output	[4:0]	o_w_rda,
	output	[31:0]	o_w_result, o_w_memdata,
	output			o_w_rfwe,
	output			o_w_csrr,
	output	[31:0]	o_w_csrod,

	input	[31:0]	i_w_rd,

	output			stall
);

	// fetch to decode
	reg		[31:0]	r_fd_pc;
	reg		[31:0]	r_fd_inst;

	always @(posedge clk) begin
		if (rst) begin
			r_fd_pc			<=	32'h0;
			r_fd_inst		<=	32'h0;
		end else if (!stall && !ex_stall && !ex_mod_stall) begin
			r_fd_pc			<=	i_f_pc;
			r_fd_inst		<=	i_f_inst;
		end else begin
			r_fd_pc			<=	r_fd_pc;
			r_fd_inst		<=	r_fd_inst;
		end
	end

	assign	o_d_pc		=	r_fd_pc;
	assign	o_d_inst	=	r_fd_inst;

	// decode to execute
	reg		[4:0]	r_de_rs1a, r_de_rs2a, r_de_rda;
	reg		[31:0]	r_de_rs1, r_de_rs2, r_de_rd, r_de_imm;
	reg				r_de_rfwe;
	reg				r_de_write_en, r_de_read_en;

	reg		[3:0]	r_de_aluctl;
	reg				r_de_imm_rs;

	always @(posedge clk) begin
		if (rst) begin
			r_de_rs1a		<=	5'h0;
			r_de_rs2a		<=	5'h0;
			r_de_rda		<=	5'h0;
			r_de_rs1		<=	32'h0;
			r_de_rs2		<=	32'h0;
			r_de_rd			<=	32'h0;
			r_de_imm		<=	32'h0;

			r_de_rfwe		<=	1'b0;

			r_de_write_en	<=	1'b0;
			r_de_read_en	<=	1'b0;

			r_de_aluctl		<=	1'b0;
			r_de_imm_rs		<=	1'b0;
		end else if (!ex_stall) begin
			r_de_rs1a		<=	i_d_rs1a;
			r_de_rs2a		<=	i_d_rs2a;
			r_de_rda		<=	i_d_rda;
			r_de_rs1		<=	i_d_rs1;
			r_de_rs2		<=	i_d_rs2;
			r_de_imm		<=	i_d_imm;

			r_de_rfwe		<=	i_d_rfwe;

			r_de_write_en	<=	i_d_write_en;
			r_de_read_en	<=	i_d_read_en;

			r_de_aluctl		<=	i_d_aluctl;
			r_de_imm_rs		<=	i_d_imm_rs;
		end else if (stall) begin
			r_de_rs1a		<=	5'h0;
			r_de_rs2a		<=	5'h0;
			r_de_rda		<=	5'h0;
			r_de_rs1		<=	32'h0;
			r_de_rs2		<=	32'h0;
			r_de_rd			<=	32'h0;
			r_de_imm		<=	32'h0;

			r_de_rfwe		<=	1'b0;

			r_de_write_en	<=	1'b0;
			r_de_read_en	<=	1'b0;

			r_de_aluctl		<=	1'b0;
			r_de_imm_rs		<=	1'b0;
		end else begin
			r_de_rs1a		<=	r_de_rs1a;
			r_de_rs2a		<=	r_de_rs2a;
			r_de_rda		<=	r_de_rda;
			r_de_rs1		<=	r_de_rs1;
			r_de_rs2		<=	r_de_rs2;
			r_de_imm		<=	r_de_imm;

			r_de_rfwe		<=	r_de_rfwe;

			r_de_write_en	<=	r_de_write_en;
			r_de_read_en	<=	r_de_read_en;

			r_de_aluctl		<=	r_de_aluctl;
			r_de_imm_rs		<=	r_de_imm_rs;
		end
	end

	assign	o_e_rs1a		=	r_de_rs1a;
	assign	o_e_rs2a		=	r_de_rs2a;
	assign	o_e_rda			=	r_de_rda;
	assign	o_e_rs1			=	r_de_rs1;
	assign	o_e_rs2			=	r_de_rs2;
	assign	o_e_imm			=	r_de_imm;
	assign	o_e_rfwe		=	r_de_rfwe;
	assign	o_e_aluctl		=	r_de_aluctl;
	assign	o_e_imm_rs		=	r_de_imm_rs;
	assign	o_e_write_en	=	r_de_write_en;
	assign	o_e_read_en		=	r_de_read_en;

	assign	o_e_csrod		=	i_d_csrod;
	assign	o_e_csrr		=	i_d_csrr;

	// execute to memory access
	reg		[4:0]	r_em_rs2a, r_em_rda;
	reg		[31:0]	r_em_rs2, r_em_result;
	reg				r_em_rfwe;
	reg				r_em_write_en, r_em_read_en;

	reg		[31:0]	r_em_csrod;
	reg				r_em_csrr;

	always @(posedge clk) begin
		if (rst) begin
			r_em_rs2a		<=	5'h0;
			r_em_rda		<=	5'h0;
			r_em_rs2		<=	32'h0;
			r_em_result		<=	32'h0;
			r_em_rfwe		<=	1'b0;
			r_em_write_en	<=	1'b0;
			r_em_read_en	<=	1'b0;

			r_em_csrod		<=	32'h0;
			r_em_csrr		<=	1'b0;
		end else if (!ex_stall) begin
			r_em_rs2a		<=	i_e_rs2a;
			r_em_rda		<=	i_e_rda;
			r_em_rs2		<=	i_e_rs2;
			r_em_result		<=	i_e_result;
			r_em_rfwe		<=	i_e_rfwe;
			r_em_write_en	<=	i_e_write_en;
			r_em_read_en	<=	i_e_read_en;

			r_em_csrod		<=	i_e_csrod;
			r_em_csrr		<=	i_e_csrr;
		end else begin
			r_em_rs2a		<=	r_em_rs2a;
			r_em_rda		<=	r_em_rda;
			r_em_rs2		<=	r_em_rs2;
			r_em_result		<=	r_em_result;
			r_em_rfwe		<=	r_em_rfwe;
			r_em_write_en	<=	r_em_write_en;
			r_em_read_en	<=	r_em_read_en;

			r_em_csrod		<=	r_em_csrod;
			r_em_csrr		<=	r_em_csrr;
		end
	end

	assign	o_m_rs2a		=	r_em_rs2a;
	assign	o_m_rda			=	r_em_rda;
	assign	o_m_rs2			=	r_em_rs2;
	assign	o_m_result		=	r_em_result;
	assign	o_m_rfwe		=	r_em_rfwe;
	assign	o_m_write_en	=	r_em_write_en;
	assign	o_m_read_en		=	r_em_read_en;

	assign	o_m_csrod		=	r_em_csrod;
	assign	o_m_csrr		=	r_em_csrr;

	// memory access to write back
	reg		[4:0]	r_mw_rda;
	reg		[31:0]	r_mw_result, r_mw_memdata;
	reg				r_mw_rfwe;

	reg		[31:0]	r_mw_csrod;
	reg				r_mw_csrr;

	always @(negedge clk) begin
		if (rst) begin
			r_mw_rda		<=	5'h0;
			r_mw_result		<=	32'h0;
			r_mw_memdata	<=	32'h0;
			r_mw_rfwe		<=	1'b0;

			r_mw_csrod		<=	32'h0;
			r_mw_csrr		<=	1'b0;
		end else if (!ex_stall) begin
			r_mw_rda		<=	i_m_rda;
			r_mw_result		<=	i_m_result;
			r_mw_memdata	<=	i_m_memdata;
			r_mw_rfwe		<=	i_m_rfwe;

			r_mw_csrod		<=	i_m_csrod;
			r_mw_csrr		<=	i_m_csrr;
		end else begin
			r_mw_rda		<=	r_mw_rda;
			r_mw_result		<=	r_mw_result;
			r_mw_memdata	<=	r_mw_memdata;
			r_mw_rfwe		<=	r_mw_rfwe;

			r_mw_csrod		<=	r_mw_csrod;
			r_mw_csrr		<=	r_mw_csrr;
		end
	end

	assign	o_w_rda		=	r_mw_rda;
	assign	o_w_result	=	r_mw_result;
	assign	o_w_memdata	=	r_mw_memdata;
	assign	o_w_rfwe	=	r_mw_rfwe;

	assign	o_w_csrod	=	r_mw_csrod;
	assign	o_w_csrr	=	r_mw_csrr;

	assign	o_fdm1		=	(i_d_rs1a == r_em_rda) && r_em_rfwe;
	assign	o_fdm2		=	(i_d_rs2a == r_em_rda) && r_em_rfwe;
	assign	o_fem1		=	(r_de_rs1a == r_em_rda) && r_em_rfwe;
	assign	o_fem2		=	(r_de_rs2a == r_em_rda) && r_em_rfwe;
	assign	o_few1		=	(r_de_rs1a == r_mw_rda) && r_mw_rfwe;
	assign	o_few2		=	(r_de_rs2a == r_mw_rda) && r_mw_rfwe;
	assign	o_fmw2		=	(r_em_rs2a == r_mw_rda) && r_mw_rfwe;

	assign	o_dm_fdata	=	r_em_result;
	assign	o_em_fdata	=	r_em_result;
	assign	o_ew_fdata	=	i_w_rd;
	assign	o_mw_fdata	=	i_w_rd;

	// stall function

	assign	stall 	=	(((i_d_rs1a == r_de_rda) || (i_d_rs2a == r_de_rda)) && r_de_read_en) || // memory load stall
						(i_jump && r_de_rfwe && (r_de_rda == i_d_rs1a || r_de_rda == i_d_rs2a)) || // branch stall
						(i_jump && r_em_read_en && (r_em_rda == i_d_rs1a || r_em_rda == i_d_rs2a));

endmodule
