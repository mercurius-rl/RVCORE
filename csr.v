`timescale 1ns / 1ps
module csr #(
	parameter		VLEN = 128,
	parameter		CORE_ID = 1
)(
	input			clk,
	input			rst,

	input	[31:0]	i_datain,
	output	[31:0]	o_dataout,
	input	[1:0]	i_csr_op,
	input	[11:0]	i_csr_addr,

	output	[10:0]	o_sew,
	output	[3:0]	o_lmul,

	input	[31:0]	i_int_cause,
	input	[31:0]	i_int_pc,
	input	[31:0]	i_int_mtval,

	output	[31:0]	o_int_pc,
	output			o_int_jump,

	input			i_interrupt_enter,
	input			i_interrupt_exit,

	output			o_interrupt,
	output	[31:0]	o_interrupt_data
);

	reg		[31:0]	r_out_crs;

	/*
		mstatus	: status of processor
		mie		: Indicate ablable interrupt
		mtvec	: Jump destination I-mem address when interrupt
		mepc	: Current I-mem address when interrupt
		mcause	: Cause of interrupt
		mtval	: Value depending on the exception
		mip		: Interrupt wait state
	*/
	reg		[31:0]	mstatus;
	reg		[31:0]	mie;
	reg		[31:0]	mtvec;
	reg		[31:0]	mepc;
	reg		[31:0]	mcause;
	reg		[31:0]	mtval;
	reg		[31:0]	mip;

	/*
		vstart	: Specify vector start position
		vxsat	: Floating or Fixed point saturation flag
		xvrm	: Floating point rounding mode
		vl		: Vector length
		vtype	: Vector data type (vill[XLEN-1]-> illigal flag, 
									vediv[6:5]	-> EDIV extention, 
									vsaw[4:2]	-> Standard-Element-Width, 
									vlmul[1:0]	-> group multiplication)
		vlenb	: VLEN/8 -- Length in bytes of vector register
	*/
	reg		[31:0]	vstart;
	reg		[31:0]	vxsat;
	reg		[31:0]	vxrm;
	reg		[31:0]	vcsr;
	//reg		[31:0]	vl;
	reg		[31:0]	vtype;
	//reg	[31:0]	vlenb;

	wire	[10:0]	sew;
	wire	[3:0]	lmul;
	wire			vill;

	wire	[31:0]	vl;
	wire	[31:0]	vlenb;

	assign	sew = (11'h8 << vtype[4:2]);
	assign	lmul = (4'h1 << vtype[1:0]);
	assign	vill = (VLEN < sew);

	assign	o_sew = sew;
	assign	o_lmul = lmul;

	assign	vl = (VLEN << vtype[1:0]) >> (vtype[4:2] + 3'h3); // LMUL*VLEN/SEW
	assign	vlenb = VLEN/8;

	localparam	WRITE	=	2'b01,
				BSET	=	2'b10,
				BCLR	=	2'b11;

	always @(posedge clk) begin
		if (rst) begin
			vstart	<=	32'h0;
			vxsat	<=	32'h0;
			vxrm	<=	32'h0;
			vcsr	<=	32'h0;

			mstatus	<=	32'h0;
			mie		<=	32'h0;
			mtvec	<=	32'h0;
			mepc	<=	32'h0;
			mcause	<=	32'h0;
			mtval	<=	32'h0;
			mip		<=	32'h0;
		end else if (i_interrupt_enter) begin
			if ((mie[0] && i_int_cause[31]) || !i_int_cause[31]) begin
				mstatus[7]		<=	mstatus[3];
				mstatus[3]		<=	0;
				mstatus[12:11]	<=	2'b11;

				mcause			<=	i_int_cause;
				mepc			<=	i_int_pc;
				mtval			<=	i_int_mtval;
			end 
		end else if (i_interrupt_exit) begin
			mstatus[3]		<=	mstatus[7];
			mstatus[7]		<=	1;
			mstatus[12:11]	<=	2'b00;
		end else begin
			case(i_csr_op)
				WRITE: begin
					case (i_csr_addr)
						12'h008: vstart		<=	i_datain;
						12'h009: vxsat		<=	i_datain;
						12'h00A: vxrm		<=	i_datain;
						12'h00F: vcsr		<=	i_datain;

						12'hC21: vtype		<=	{vtype[31], 26'h0, i_datain[4:0]};

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
						12'h008: vstart		<=	vstart | i_datain;
						12'h009: vxsat		<=	vxsat | i_datain;
						12'h00A: vxrm		<=	vxrm | i_datain;
						12'h00F: vcsr		<=	vcsr | i_datain;

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
						12'h008: vstart		<=	vstart & (~i_datain);
						12'h009: vxsat		<=	vxsat & (~i_datain);
						12'h00A: vxrm		<=	vxrm & (~i_datain);
						12'h00F: vcsr		<=	vcsr & (~i_datain);

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
					12'h008: r_out_crs	<=	vstart;
					12'h009: r_out_crs	<=	vxsat;
					12'h00A: r_out_crs	<=	vxrm;
					12'h00F: r_out_crs	<=	vcsr;

					12'hC20: r_out_crs	<=	vl;
					12'hC21: r_out_crs	<=	vtype;
					12'hC22: r_out_crs	<=	vlenb;

					12'h300: r_out_crs	<=	mstatus;
					12'h304: r_out_crs	<=	mie;
					12'h305: r_out_crs	<=	mtvec;
					12'h341: r_out_crs	<=	mepc;
					12'h342: r_out_crs	<=	mcause;
					12'h343: r_out_crs	<=	mtval;
					12'h344: r_out_crs	<=	mip;

					// Machine Information
					12'hF11: r_out_crs	<=	32'h0000BEEF;	// Vendor ID
					12'hF11: r_out_crs	<=	32'h00000001;	// Architecture ID
					12'hF11: r_out_crs	<=	32'h00000001;	// Implementation ID
					12'hF11: r_out_crs	<=	CORE_ID;		// Hardware thread ID
					default: r_out_crs	<=	r_out_crs;
				endcase
			end
		end
	end
	assign	o_dataout = r_out_crs;
	assign	o_int_pc =	(i_interrupt_enter && ((mie[0] && i_int_cause[31]) || !i_int_cause[31]))
						?	mtvec
						:	mepc	;

	assign	o_int_jump = (i_interrupt_enter && ((mie[0] && i_int_cause[31]) || !i_int_cause[31])) || i_interrupt_exit;

endmodule
