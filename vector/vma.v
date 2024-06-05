module vma #(
	parameter	VLEN	=	128
) (
	input		clk,
	input		rst,

	output		busy,
	output		done,
	
	input	[6:0]		i_ops,		// operation
	input	[1:0]		i_mop,		// memory access operation
	input	[2:0]		i_width,	// width parameter (not used)

	input	[31:0]		i_rs1,		// register file 1
	input	[31:0]		i_rs2,		// register file 2

	input	[4:0]		i_vs1a,		// vector reg 1 (store or load reg)
	input	[4:0]		i_vs2a,		// vector reg 2 (address offsets: not used)
	
	// Vector register access
	output	[4:0]		o_wraddr,
	input	[VLEN-1:0]	i_vwdata,

	output	[4:0]		o_rraddr,
	output				o_vr_en,
	output	[VLEN-1:0]	o_vrdata,

	output	[4:0]		o_idxaddr,
	input	[VLEN-1:0]	i_idxdata,

	// Read/Write length and other parameter
	input	[10:0]		i_sew,
	input	[3:0]		i_lmul,
	input	[31:0]		i_venum,

	// Memory interface access
	output				o_write_en,
	output	[31:0]		o_write_data,

	output				o_read_en,
	output				i_read_vd,
	input	[31:0]		i_read_data,
	output	[31:0]		o_memaddr
);
	// implement "Unit Stride" and "Stride" instruction
	// Vector masking not implemented (future work)

	parameter	CVLEN	=	$clog2(VLEN/32 - 1);

	wire	[31:0]	w_memlen;
	assign	w_memlen	=	(i_sew == 11'h08)	? i_venum + 1			:	// 8bit
							(i_sew == 11'h10)	? i_venum + 1			:	// 16bit
							(i_sew == 11'h20)	? i_venum + 1			:	// 32bit
							(i_sew == 11'h40)	? (i_venum + 1) << 1	:	// 64bit
							(i_sew == 11'h80)	? (i_venum + 1) << 2	:	// 128bit
							32'h0;


	parameter	IDLE		=	'h00,
				STORE_S		=	'h01,	// Normal Store
				STORE		=	'h02,
				STORE_L		=	'h03,
				LOAD_S		=	'h04,	// Normal Load
				LOAD		=	'h05,
				LOAD_L		=	'h06,
				SSTORE_S	=	'h11,	// Stride Store
				SSTORE		=	'h12,
				SSTORE_L	=	'h13,
				SLOAD_S		=	'h14,	// Stride Load
				SLOAD		=	'h15,
				SLOAD_L		=	'h16,
				ISTORE_S	=	'h21,	// Index Store
				ISTORE		=	'h22,
				ISTORE_L	=	'h23,
				ILOAD_S		=	'h24,	// Index Load
				ILOAD		=	'h25,
				ILOAD_L		=	'h26
				;

	parameter	NOP			=	'h0,
				TRANS_ST	=	'h1,
				TRANS_LD	=	'h2,
				TRANS_SST	=	'h3,
				TRANS_SLD	=	'h4,
				TRANS_IST	=	'h5,
				TRANS_ILD	=	'h6
				;

	wire	[31:0]	w_ops;

	function [2:0] ops_dec(
		input	[6:0]	fi_ops,
		input	[1:0]	fi_mop
	);
		if (fi_ops == 7'h07) begin
			case (fi_mop)
				2'b00:	ops_dec = TRANS_LD;
				2'b01:	ops_dec = NOP;
				2'b10:	ops_dec = TRANS_SLD;
				2'b11:	ops_dec = TRANS_ILD;
			endcase
		end else if (fi_ops == 7'h27) begin
			case (fi_mop)
				2'b00:	ops_dec = TRANS_ST;
				2'b01:	ops_dec = NOP;
				2'b10:	ops_dec = TRANS_SST;
				2'b11:	ops_dec = TRANS_IST;
			endcase
		end else begin
			ops_dec = NOP;
		end
	endfunction

	assign	w_ops		=	ops_dec(i_ops, i_mop);

	// Control Register
	reg		[5:0]	r_state;
	reg		[3:0]	r_addr_count;

	assign	busy		=	(r_state != IDLE);
	
	always @( posedge clk or posedge rst ) begin
		if (rst) begin
			r_state	<=	IDLE;
		end else begin
			case (r_state)
				IDLE: begin // State Machine Start
					case (w_ops)
						TRANS_ST :	r_state	<=	STORE_S;
						TRANS_LD :	r_state	<=	LOAD_S;
						TRANS_SST:	r_state	<=	SSTORE_S;
						TRANS_SLD:	r_state	<=	SLOAD_S;
						default  :	r_state	<=	r_state; 
					endcase
				end
				STORE_S: begin
					if (w_memlen == 1) begin
						r_state	<=	STORE_L;
					end else begin
						r_state	<=	STORE;
					end
				end
				STORE: begin
					if (r_addr_count == 1) begin
						r_state	<=	STORE_L;
					end
				end
				STORE_L: begin
					r_state	<=	IDLE;
				end
				LOAD_S: begin
					if (w_memlen == 1) begin
						r_state	<=	LOAD_L;
					end else begin
						r_state	<=	LOAD;
					end
				end
				LOAD: begin
					if (r_addr_count == 0) begin
						r_state	<=	LOAD_L;
					end
				end
				LOAD_L: begin
					r_state	<=	IDLE;
				end
				SSTORE_S: begin
					if (w_memlen == 1) begin
						r_state	<=	SSTORE_L;
					end else begin
						r_state	<=	SSTORE;
					end
				end
				SSTORE: begin
					if (r_addr_count == 1) begin
						r_state	<=	SSTORE_L;
					end
				end
				SSTORE_L: begin
					r_state	<=	IDLE;
				end
				SLOAD_S: begin
					if (w_memlen == 1) begin
						r_state	<=	SLOAD_L;
					end else begin
						r_state	<=	SLOAD;
					end
				end
				SLOAD: begin
					if (r_addr_count == 0) begin
						r_state	<=	SLOAD_L;
					end
				end
				SLOAD_L: begin
					r_state	<=	IDLE;
				end
				default: r_state	<=	IDLE;
			endcase
		end
	end

	assign	o_read_en		= (r_state[2:0] == LOAD);
	assign	o_write_en		= (r_state[2:0] == STORE);

	assign	done			= (r_state[2:0] == LOAD_L || r_state[2:0] == STORE_L);

	// Memory Address Controller
	reg		[31:0]	r_maddr = 0;
	reg		[31:0]	r_accaddr = 0;

	assign	o_memaddr	= r_maddr;

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			r_maddr			<=	32'h0;
			r_accaddr		<=	32'h0;
			r_addr_count	<=	4'h0;
		end else begin
			if ((r_state == IDLE)) begin
				if (w_ops == TRANS_ST || w_ops == TRANS_LD) begin
					r_maddr			<=	i_rs1;
					r_accaddr		<=	4;
					r_addr_count	<=	w_memlen;
				end else if (w_ops == TRANS_SST || w_ops == TRANS_SLD) begin
					r_maddr			<=	i_rs1;
					r_accaddr		<=	i_rs2;
					r_addr_count	<=	w_memlen;
				end
				
			end else if ((r_state == STORE_S) || (r_state == SSTORE_S) || (r_state == ISTORE_S)) begin
				r_maddr			<=	r_maddr;
			end else begin
				if (r_addr_count > 0) begin
					r_maddr			<=	r_maddr + r_accaddr;
					r_addr_count	<=	r_addr_count - 1;
				end
			end
		end
	end

	// V Register Controller
	reg		[VLEN-1:0]	r_tmp_vreg;

	parameter	VLENMEM = $clog2(VLEN - 1);
	reg		[VLENMEM-1:0]	r_vccount;
	reg		[VLENMEM:0]		r_vc_next_overflow;
	wire	[VLENMEM-1:0]	w_next_vcccount;
	wire					w_vec_load;		// load data to vector register flag
	wire					w_vec_store;	// store data from vector register flag

	wire	[10:0]	w_vccw;
	assign	w_vccw			=	(i_sew >= 11'h20) ? 32 : i_sew;
	assign	w_vec_load		=	(r_state[2:0] == LOAD && r_vc_next_overflow[VLENMEM]) || r_state[2:0] == LOAD_L;
	assign	w_vec_store 	=	(r_state[2:0] == STORE_S) || ((w_next_vcccount == 0) && r_state[2:0] == STORE);

	assign	w_next_vcccount = r_vccount + w_vccw;

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			r_vccount			<=	'h0;
			r_vc_next_overflow	<=	'h0;
		end else begin
			if (r_state == IDLE) begin
				r_vccount			<=	0;
			end else if ((o_read_en & i_read_vd) | o_write_en) begin
				r_vccount			<=	w_next_vcccount;
			end
			r_vc_next_overflow	<= r_vccount + w_vccw;
		end
	end

	// Vector data configurator
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			r_tmp_vreg		<=	'h0;
		end else begin
			if (r_state == IDLE) begin
				r_tmp_vreg	<=	0;
			end else if (o_read_en & i_read_vd) begin
				if (i_sew == 11'h08) begin
					if (w_vec_load) begin
						r_tmp_vreg	<=	'h0 + i_read_data[7:0];
					end else begin
						r_tmp_vreg	<=	(r_tmp_vreg << w_vccw) + i_read_data[7:0];
					end
				end else if (i_sew == 11'h10) begin
					if (w_vec_load) begin
						r_tmp_vreg	<=	'h0 + i_read_data[15:0];
					end else begin
						r_tmp_vreg	<=	(r_tmp_vreg << w_vccw) + i_read_data[15:0];
					end
				end else begin
					if (w_vec_load) begin
						r_tmp_vreg	<=	'h0 + i_read_data;
					end else begin
						r_tmp_vreg	<=	(r_tmp_vreg << w_vccw) + i_read_data;
					end
				end
			end /*else if (w_vec_store) begin
				r_tmp_vreg	<=	i_vwdata;
			end
			*/
		end
	end
	
	assign	o_write_data	=	(r_state == IDLE)		? 32'h0						:
								(r_state[2:0] == LOAD)	? 32'h0						:
								(i_sew == 11'h08)		? i_vwdata[r_vccount+:8]	:	// 8bit
								(i_sew == 11'h10)		? i_vwdata[r_vccount+:16]	:	// 16bit
														  i_vwdata[r_vccount+:32] 	;	// vec element

	assign	o_vrdata		=	(r_state[2:0] == LOAD_S || r_state[2:0] == LOAD || r_state[2:0] == LOAD_L) ? r_tmp_vreg : 'h0;

	// V Register Address Generator
	// Read
	reg		[4:0]	r_rsaddr;
	assign	o_rraddr		=	r_rsaddr;
	assign	o_vr_en			=	w_vec_load;
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			r_rsaddr	<=	0;
		end else begin
			if (r_state == IDLE) begin
				r_rsaddr	<=	0;
			end else if (w_vec_load) begin
				r_rsaddr	<=	r_rsaddr + 1;
			end else if (r_state[2:0] == LOAD_S) begin
				r_rsaddr	<=	i_vs1a;
			end else begin
				r_rsaddr	<=	r_rsaddr;
			end
		end
	end

	// Write
	reg		[4:0]	r_wsaddr;
	assign	o_wraddr		=	r_wsaddr;
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			r_wsaddr	<=	0;
		end else begin
			if (r_state == IDLE) begin
				r_wsaddr	<=	0;
			end else if (r_state[2:0] == STORE_S) begin
				r_wsaddr	<=	i_vs1a;
			end else if (w_vec_store) begin
				r_wsaddr	<=	r_wsaddr + 1;
			end else begin
				r_wsaddr	<=	r_wsaddr;
			end
		end
	end

	assign	o_maskaddr	=	0;
	assign	o_idxaddr	=	0;
endmodule