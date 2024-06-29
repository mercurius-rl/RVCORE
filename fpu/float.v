module fadd(
	input	[31:0]	a,
	input	[31:0]	b,
	output	[31:0]	out	
);
	wire	[7:0]	w_ex_l, w_ex_s;
	wire	[22:0]	w_fr_l, w_fr_s;
	wire			w_sg_l, w_sg_s;

	wire	comp = (a[30:0] > b[30:0]);

	assign	{w_sg_l, w_ex_l, w_fr_l} = ( comp) ? a : b;
	assign	{w_sg_s, w_ex_s, w_fr_s} = (!comp) ? a : b;

	wire	[23:0]	w_fr_l1, w_fr_s1;
	assign	w_fr_l1 = {1'b1, w_fr_l};
	assign	w_fr_s1 = {1'b1, w_fr_s};

	// shift
	wire	[23:0]	w_sh, w_rem;
	wire	[7:0]	w_ex_sub = w_ex_l - w_ex_s;
	assign	{w_sh, w_rem} = (w_ex_sub >= 8'd26) ? {26'h0, w_fr_s1[23:2]} : {w_fr_s1, 23'h0} >> w_ex_sub;

	// fract calc
	wire			w_xnor = w_sg_l ~^ w_sg_s;
	wire	[23:0]	w_fr_add = w_fr_l1 + w_sh;
	wire	[23:0]	w_fr_sub = w_fr_l1 - w_sh;
	wire	[23:0]	w_fr_res = w_xnor ? w_fr_add : w_fr_sub;

	// normalize
	function [4:0] shc;
	input [22:0] f;
	begin
		if(f[22])		shc = 5'b00000;
		else if(f[21])	shc = 5'b00001;
		else if(f[20])	shc = 5'b00010;
		else if(f[19])	shc = 5'b00011;
		else if(f[18])	shc = 5'b00100;
		else if(f[17])	shc = 5'b00101;
		else if(f[16])	shc = 5'b00111;
		else if(f[15])	shc = 5'b01000;
		else if(f[14])	shc = 5'b01001;
		else if(f[13])	shc = 5'b01010;
		else if(f[12])	shc = 5'b01011;
		else if(f[11])	shc = 5'b01100;
		else if(f[10])	shc = 5'b01101;
		else if(f[9])	shc = 5'b01110;
		else if(f[8])	shc = 5'b01111;
		else if(f[7])	shc = 5'b10000;
		else if(f[6])	shc = 5'b10001;
		else if(f[5])	shc = 5'b10010;
		else if(f[4])	shc = 5'b10011;
		else if(f[3])	shc = 5'b10100;
		else if(f[2])	shc = 5'b10101;
		else if(f[1])	shc = 5'b10110;
		else			shc = 5'b10111;
	end
	endfunction

	wire	[4:0]	w_sh_count = shc(w_fr_res[22:0]);

	wire	[22:0]	w_norm_fr = (w_xnor) ? (w_fr_res >> w_fr_res[8]) : (w_fr_res << w_sh_count);
	wire	[7:0]	w_norm_ex = (w_xnor) ? (w_ex_l + w_fr_res[8]) : (w_ex_l - w_sh_count);

	// round
	wire	guard, round, stiky;
	assign	{guard, round, stiky} = {w_rem[7], w_rem[6], |w_rem[5:0]};

	wire	[22:0]	w_round_fr = w_norm_fr + (guard & (round | stiky | w_norm_fr[0]));

	// exception
	function [1:0] exception;
	input	[7:0]	ex_l, ex_s;
	input	[22:0]	fr_l, fr_s;
	begin
		casex ( {ex_l,1'b0,fr_l,   ex_s,1'b0,fr_s} )
			64'h00xxxx_00xxxx: exception = 2'b01;	// zero
			64'h00xxxx_ff0000: exception = 2'b10;	// inf
			64'h00xxxx_ffxxxx: exception = 2'b11;	// NaN
			64'h00xxxx_xxxxxx: exception = 2'b00;	// Number
			64'hFF0000_00xxxx: exception = 2'b10;
			64'hFF0000_FF0000: exception = 2'b10;
			64'hFF0000_FFxxxx: exception = 2'b11;
			64'hFF0000_xxxxxx: exception = 2'b10;
			64'hFFxxxx_xxxxxx: exception = 2'b11;
			64'hxxxxxx_00xxxx: exception = 2'b00;
			64'hxxxxxx_FF0000: exception = 2'b10;
			64'hxxxxxx_FFxxxx: exception = 2'b11;
			64'hxxxxxx_xxxxxx: exception = 2'b00;
			default: exception = 2'b00;
		endcase
	end
	endfunction

	wire	[1:0]	w_exc		= exception(w_ex_l, w_ex_s, w_fr_l, w_fr_s);
	wire	[7:0]	w_exc_ex	= (w_exc == 2'b00) ?	w_norm_ex
								: (w_exc == 2'b01) ?	8'h00 
								:						8'hFF;
	wire	[22:0]	w_exc_fr	= (w_exc == 2'b00) ?	w_round_fr
								: (w_exc == 2'b11) ?	23'h400000 
								:						23'h000000;
	wire			w_exc_sg	= w_sg_l;

	assign	out = {w_exc_sg, w_exc_ex, w_exc_fr};
endmodule

module fmul(
	input	[31:0]	a,
	input	[31:0]	b,
	output	[31:0]	out
);

	// multiply
	wire			w_sg		= a[31] ^ b[31];
	wire	[47:0]	w_fr_mul	= {1'b1, a[22:0]} * {1'b1, b[22:0]};
	wire	[8:0]	w_ex_tmp	= a[30:23] + b[30:23] - 'd127 + w_fr_mul[47];

	// normalize
	wire	[26:0]	w_fr_tmp	= {w_fr_mul[47:22], (|w_fr_mul[21:0])};
	wire	[26:0]	w_norm_fr	= (w_fr_mul[47]) ? w_fr_tmp : {w_fr_tmp[25:0], 1'b0};
	
	// round
	wire	least, guard, round, stiky;
	assign	{least, guard, round, stiky} = {w_norm_fr[3], w_norm_fr[2], w_norm_fr[1], w_norm_fr[0]};
	wire	[23:0]	w_round_fr = w_norm_fr[25:3] + (guard & (least | round | stiky));

	// exception
	function [1:0] exception;
	input	[7:0]	ex_l, ex_s;
	input	[22:0]	fr_l, fr_s;
	begin
		casex ( {ex_l,1'b0,fr_l,   ex_s,1'b0,fr_s} )
			64'h00xxxx_00xxxx: exception = 2'b01;	// zero
			64'h00xxxx_ff0000: exception = 2'b10;	// inf
			64'h00xxxx_ffxxxx: exception = 2'b11;	// NaN
			64'h00xxxx_xxxxxx: exception = 2'b00;	// Number
			64'hFF0000_00xxxx: exception = 2'b10;
			64'hFF0000_FF0000: exception = 2'b10;
			64'hFF0000_FFxxxx: exception = 2'b11;
			64'hFF0000_xxxxxx: exception = 2'b10;
			64'hFFxxxx_xxxxxx: exception = 2'b11;
			64'hxxxxxx_00xxxx: exception = 2'b00;
			64'hxxxxxx_FF0000: exception = 2'b10;
			64'hxxxxxx_FFxxxx: exception = 2'b11;
			64'hxxxxxx_xxxxxx: exception = 2'b00;
			default: exception = 2'b00;
		endcase
	end
	endfunction

	wire	[1:0]	w_exc		= exception(a[30:23], b[30:23], a[22:0], b[22:0]);
	wire	[7:0]	w_exc_ex	= (w_exc == 2'b00) ?	(w_ex_tmp[8])?	(w_ex_tmp[7])?	8'h00	:	8'hFF	:	w_ex_tmp[7:0]
								: (w_exc == 2'b01) ?	8'h00 
								:						8'hFF;
	wire	[22:0]	w_exc_fr	= (w_exc == 2'b00) ?	(w_ex_tmp[8] || w_exc_ex == 8'hFF || w_exc_ex == 8'h00)?	23'h00000	:	w_round_fr
								: (w_exc == 2'b11) ?	23'h40000 
								:						23'h00000;
	wire			w_exc_sg	= ({w_exc_ex, w_exc_fr} == 31'b0) ?	1'b0	:	w_sg;

	assign	out = {w_exc_sg, w_exc_ex, w_exc_fr};

endmodule

module fdiv(
	input	[31:0]	a,
	input	[31:0]	b,
	output	[31:0]	out
);
	// divide
	wire			w_sg		= a[31] ^ b[31];
	wire	[49:0]	w_div_fr	= ( {1'b1, a[22:0]} << 25 ) / {1'b1, b[22:0]};
	wire	[8:0]	w_ex_tmp	= a[30:23] - b[30:23] + 'd127 - !w_div_fr[26];

	// normalize
	wire	[26:0]	w_norm_fr	= (w_div_fr[25]) ? {w_div_fr[25:0], 1'b1} : {w_div_fr[24:0], 2'b11};

	// round
	wire	least, guard, round, stiky;
	assign	{least, guard, round, stiky} = {w_norm_fr[3], w_norm_fr[2], w_norm_fr[1], w_norm_fr[0]};
	wire	[23:0]	w_round_fr = w_norm_fr[25:3] + (guard & (least | round | stiky));

	// exception
	function [1:0] exception;
	input	[7:0]	ex_l, ex_s;
	input	[22:0]	fr_l, fr_s;
	begin
		casex ( {ex_l,1'b0,fr_l,   ex_s,1'b0,fr_s} )
			64'h00xxxx_00xxxx: exception = 2'b01;	// zero
			64'h00xxxx_ff0000: exception = 2'b10;	// inf
			64'h00xxxx_ffxxxx: exception = 2'b11;	// NaN
			64'h00xxxx_xxxxxx: exception = 2'b00;	// Number
			64'hFF0000_00xxxx: exception = 2'b10;
			64'hFF0000_FF0000: exception = 2'b10;
			64'hFF0000_FFxxxx: exception = 2'b11;
			64'hFF0000_xxxxxx: exception = 2'b10;
			64'hFFxxxx_xxxxxx: exception = 2'b11;
			64'hxxxxxx_00xxxx: exception = 2'b00;
			64'hxxxxxx_FF0000: exception = 2'b10;
			64'hxxxxxx_FFxxxx: exception = 2'b11;
			64'hxxxxxx_xxxxxx: exception = 2'b00;
			default: exception = 2'b00;
		endcase
	end
	endfunction

	wire	[1:0]	w_exc		= exception(a[30:23], b[30:23], a[22:0], b[22:0]);
	wire	[7:0]	w_exc_ex	= (w_exc == 2'b00) ?	(w_ex_tmp[8])?	(w_ex_tmp[7])?	8'h00	:	8'hFF	:	w_ex_tmp[7:0]
								: (w_exc == 2'b01) ?	8'h00 
								:						8'hFF;
	wire	[22:0]	w_exc_fr	= (w_exc == 2'b00) ?	(w_ex_tmp[8] || w_exc_ex == 8'hFF || w_exc_ex == 8'h00)?	23'h00000	:	w_round_fr
								: (w_exc == 2'b11) ?	23'h40000 
								:						23'h00000;
	wire			w_exc_sg	= ({w_exc_ex, w_exc_fr} == 31'b0) ?	1'b0	:	w_sg;

	assign	out = {w_exc_sg, w_exc_ex, w_exc_fr};
endmodule

module fsqrt (
	input wire [31:0] a,      
	output reg [31:0] out
);
	// Extract fields of the input
	wire		sign_a = a[31];
	wire [7:0]	ex_a = a[30:23];
	wire [22:0]	fr_a = a[22:0];

	// Special case: if input is zero or negative
	wire w_zero = (a[30:0] == 31'b0);
	wire w_neg = sign_a;

	// Normalize the mantissa with an implicit leading 1
	wire [23:0] fr_tmp = {1'b1, fr_a};

	// Adjust the exponent for sqrt
	// sqrt(2^E * M) = 2^(E/2) * sqrt(M)
	wire [7:0] ex_a_adj = ex_a - 8'd127;  // Unbias the exponent
	wire [7:0] ex_h = ex_a_adj >> 1;   // Divide by 2
	wire [7:0] ex_result = ex_h + 8'd127; // Re-bias the exponent

	// Binary square root algorithm for the mantissa
	reg [23:0] fr_result;
	reg [24:0] rem;
	reg [23:0] root;
	integer i;

	always @(*) begin
		if (w_zero || w_neg) begin
			out = 32'b0;
		end else begin
			rem = 0;
			root = 0;
			for (i = 23; i >= 0; i = i - 1) begin
				rem = {rem[22:0], fr_tmp[i], 1'b0};
				if (rem >= {root, 2'b01}) begin
					rem = rem - {root, 2'b01};
					root = {root[22:0], 1'b1};
				end else begin
					root = {root[22:0], 1'b0};
				end
			end
			fr_result = root;

			// Combine the fields to form the result
			out = {1'b0, ex_result, fr_result[22:0]};
		end
	end

endmodule

module fcvt_f2i(
	input			s_signed,
	input	[31:0]	a,
	output	[31:0]	out
);
	// Extract fields of the input
	wire sign_a = a[31];
	wire [7:0] ex_a = a[30:23];
	wire [23:0] fr_a = {1'b1, a[22:0]};

	// Compute the effective exponent by subtracting the bias
	wire [7:0] eff_ex;
	assign eff_ex = ex_a - 127;

	wire [31:0] int_value;
	assign int_value =	(eff_ex < 0    ) ? 32'b0 : 
						(eff_ex < 8'd23) ? fr_a >> (8'd23 - eff_ex) : fr_a << (eff_ex - 8'd23);

	assign	out	= sign_a ? -a : a;
endmodule

module fcvt_i2f(
	input			s_signed,
	input	[31:0]	a,
	output	[31:0]	out
);
	// Temporary variables for calculation
	reg [31:0] temp;
	reg [7:0] ex;
	reg [22:0] fr;
	reg sign;

	integer i;

	always @(*) begin
		// Determine sign bit
		sign = a[31];

		// Work with the absolute value of the integer
		if (sign & s_signed) begin
			temp = -a;
		end else begin
			temp = a;
		end

		// Initialize exponent and mantissa
		ex = 0;
		fr = 0;

		// Normalize the input integer and calculate exponent and mantissa
		for (i = 31; i >= 0; i = i - 1) begin
			if (temp[i] == 1) begin
				ex = i + 127; // Exponent is the position of MSB plus the bias (127)
				temp = temp << (31 - i); // Shift left to align MSB with the leading bit position
				break;
			end
		end

		// Extract the mantissa (23 bits)
		fr = temp[30:8];
	end

	assign	out = {sign & s_signed, ex, fr};
endmodule

module falu(
	input	[3:0]	fops,

	input	[31:0]	rs1,
	input	[31:0]	rs2,
	output	[31:0]	out	
);

	wire	[31:0]	w_add, w_mul, w_div, w_sqrt, w_sgnj, w_mnx, w_comp;

	wire			w_sub_en = (fops == 4'h1);

	fadd fadd(
		.a(rs1),
		.b(w_sub_en ? {~rs2[31], rs2[30:0]} : rs2),
		.out(w_add)
	);

	fmul fmul(
		.a(rs1),
		.b(rs2),
		.out(w_mul)
	);

	fdiv fdiv(
		.a(rs1),
		.b(rs2),
		.out(w_div)
	);

	fsqrt fsqrt(
		.a(rs1),
		.out(w_sqrt)
	);

	assign	w_sgnj =	(fops == 4'h5) ? {rs2[31], rs1[30:0]}	:
						(fops == 4'h6) ? {~rs2[31], rs1[30:0]}	:
						(fops == 4'h7) ? {rs1[31] ^ rs2[31], rs1[30:0]}	:
						32'h0;
	
	assign	w_mnx  =	(fops == 4'h8) ? (w_add[31] ? rs2 : rs1) :
						(fops == 4'h9) ? (w_add[31] ? rs1 : rs2) :
						32'h0;
						
	assign	w_comp =	(fops == 4'hA) ? (w_add == 0 ? 32'b1 : 32'b0) :
						(fops == 4'hB) ? (w_add[31] ? 32'b0 : 32'b1) :
						(fops == 4'hC) ? (w_add[31] | w_add == 0 ? 32'b0 : 32'b1) :
						32'h0;

	assign	out	=		(fops == 4'h0 || fops == 4'h1)
										?	w_add	:
						(fops == 4'h2)	?	w_mul	:
						(fops == 4'h3)	?	w_div	:
						(fops == 4'h4)	?	w_sqrt	:
						(fops == 4'h5 || fops == 4'h6 || fops == 4'h7) 
										?	w_sgnj	:
						(fops == 4'h8 || fops == 4'h9) 
										?	w_mnx	:
						(fops == 4'hA || fops == 4'hB || fops == 4'hC) 
										?	w_comp	:	32'b0;
endmodule