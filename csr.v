`timescale 1ns / 1ps
module csr(
	input			clk,
	input			rst,

	input	[31:0]	i_datain,
	output	[31:0]	o_dataout,
	input	[1:0]	i_csr_op,
	input	[11:0]	i_csr_addr,

	input	[31:0]	i_int_cause,
	input	[31:0]	i_int_pc,
	input	[31:0]	i_int_mtval,

	input			i_inst_retired,
	input			i_interrupt_enter,
	input			i_interrupt_exit,

	output			o_interrupt,
	output	[31:0]	o_interrupt_data
);

	reg		[31:0]	r_out_crs;

	reg		[31:0]	mstatus;
	reg		[31:0]	mie;
	reg		[31:0]	mtvec;
	reg		[31:0]	mepc;
	reg		[31:0]	mcause;
	reg		[31:0]	mtval;
	reg		[31:0]	mip;

	localparam	WRITE	=	2'b01,
				BSET	=	2'b10,
				BCLR	=	2'b11;

	always @(posedge clk) begin
		if (rst) begin
			mstatus	<=	32'h0;
			mie		<=	32'h0;
			mtvec	<=	32'h0;
			mepc	<=	32'h0;
			mcause	<=	32'h0;
			mtval	<=	32'h0;
			mip		<=	32'h0;
		end else if (i_interrupt_enter) begin
			mstatus[7]		<=	mstatus[3];
			mstatus[3]		<=	0;
			mstatus[12:11]	<=	2'b11;

			mcause			<=	i_int_cause;
			mepc			<=	i_int_pc;
			mtval			<=	i_int_mtval;
		end else if (i_interrupt_exit) begin
			mstatus[3]		<=	mstatus[7];
			mstatus[7]		<=	1;
			mstatus[12:11]	<=	2'b00;
		end else begin
			case(i_csr_op)
				WRITE: begin
					case (i_csr_addr)
						12'h300: mstatus	<=	i_datain;
						12'h304: mie		<=	i_datain;
						12'h305: mtvec		<=	i_datain;
						12'h341: mepc		<=	i_datain;
						12'h342: mcause		<=	i_datain;
						12'h343: mtval		<=	i_datain;
						12'h344: mip		<=	i_datain;
					endcase
				end
				BSET: begin
					case (i_csr_addr)
						12'h300: mstatus	<=	mstatus | i_datain;
						12'h304: mie		<=	mie | i_datain;
						12'h305: mtvec		<=	mtvec | i_datain;
						12'h341: mepc		<=	mepc | i_datain;
						12'h342: mcause		<=	mcause | i_datain;
						12'h343: mtval		<=	mtval | i_datain;
						12'h344: mip		<=	mip | i_datain;
					endcase
				end
				BCLR: begin
					case (i_csr_addr)
						12'h300: mstatus	<=	mstatus & (~i_datain);
						12'h304: mie		<=	mie & (~i_datain);
						12'h305: mtvec		<=	mtvec & (~i_datain);
						12'h341: mepc		<=	mepc & (~i_datain);
						12'h342: mcause		<=	mcause & (~i_datain);
						12'h343: mtval		<=	mtval & (~i_datain);
						12'h344: mip		<=	mip & (~i_datain);
					endcase
				end
			endcase
		end
	end

	always @(posedge clk) begin
		if (rst) begin
			r_out_crs	<=	32'h0;
		end else begin
			if (i_csr_op == WRITE || i_csr_op == BSET || i_csr_op == BCLR) begin
				case (i_csr_addr)
					12'h300: r_out_crs	<=	mstatus;
					12'h304: r_out_crs	<=	mie;
					12'h305: r_out_crs	<=	mtvec;
					12'h341: r_out_crs	<=	mepc;
					12'h342: r_out_crs	<=	mcause;
					12'h343: r_out_crs	<=	mtval;
					12'h344: r_out_crs	<=	mip;
					default: r_out_crs	<=	r_out_crs;
				endcase
			end
		end
	end
	assign	o_dataout = r_out_crs;

endmodule
