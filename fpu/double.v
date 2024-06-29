module dadd(
	input	[63:0]	a,
	input	[63:0]	b,
	output	[63:0]	out	
);
	wire	[10:0]	w_ex_l, w_ex_s;
	wire	[51:0]	w_fr_l, w_fr_s;
	wire			w_sg_l, w_sg_s;

	wire	comp = (a[62:0] > b[62:0]);

	assign	{w_sg_l, w_ex_l, w_fr_l} = ( comp) ? a : b;
	assign	{w_sg_s, w_ex_s, w_fr_s} = (!comp) ? a : b;

	wire	[52:0]	w_fr_l1, w_fr_s1;
	assign	w_fr_l1 = {1'b1, w_fr_l};
	assign	w_fr_s1 = {1'b1, w_fr_s};

	// shift
	wire	[52:0]	w_sh, w_rem;
	wire	[10:0]	w_ex_sub = w_ex_l - w_ex_s;
	assign	{w_sh, w_rem} = (w_ex_sub >= 11'd52) ? {52'h0, w_fr_s1[51:2]} : {w_fr_s1, 52'h0} >> w_ex_sub;

	// fract calc
	wire			w_xnor = w_sg_l ~^ w_sg_s;
	wire	[52:0]	w_fr_add = w_fr_l1 + w_sh;
	wire	[52:0]	w_fr_sub = w_fr_l1 - w_sh;
	wire	[52:0]	w_fr_res = w_xnor ? w_fr_add : w_fr_sub;

	// normalize
	function [5:0] shc;
	input [51:0] f;
	begin
		if(f[51])		shc = 6'b000000;
		else if(f[50])	shc = 6'b000001;
		else if(f[49])	shc = 6'b000010;
		else if(f[48])	shc = 6'b000011;
		else if(f[47])	shc = 6'b000100;
		else if(f[46])	shc = 6'b000101;
		else if(f[45])	shc = 6'b000110;
		else if(f[44])	shc = 6'b000111;
		else if(f[43])	shc = 6'b001000;
		else if(f[42])	shc = 6'b001001;
		else if(f[41])	shc = 6'b001010;
		else if(f[40])	shc = 6'b001011;
		else if(f[39])	shc = 6'b001100;
		else if(f[38])	shc = 6'b001101;
		else if(f[37])	shc = 6'b001110;
		else if(f[36])	shc = 6'b001111;
		else if(f[35])	shc = 6'b010000;
		else if(f[34])	shc = 6'b010001;
		else if(f[33])	shc = 6'b010010;
		else if(f[32])	shc = 6'b010011;
		else if(f[31])	shc = 6'b010100;
		else if(f[30])	shc = 6'b010101;
		else if(f[29])	shc = 6'b010110;
		else if(f[28])	shc = 6'b010111;
		else if(f[27])	shc = 6'b011000;
		else if(f[26])	shc = 6'b011001;
		else if(f[25])	shc = 6'b011010;
		else if(f[24])	shc = 6'b011011;
		else if(f[23])	shc = 6'b011100;
		else if(f[22])	shc = 6'b011101;
		else if(f[21])	shc = 6'b011110;
		else if(f[20])	shc = 6'b011111;
		else if(f[19])	shc = 6'b100000;
		else if(f[18])	shc = 6'b100001;
		else if(f[17])	shc = 6'b100010;
		else if(f[16])	shc = 6'b100011;
		else if(f[15])	shc = 6'b100100;
		else if(f[14])	shc = 6'b100101;
		else if(f[13])	shc = 6'b100110;
		else if(f[12])	shc = 6'b100111;
		else if(f[11])	shc = 6'b101000;
		else if(f[10])	shc = 6'b101001;
		else if(f[9])	shc = 6'b101010;
		else if(f[8])	shc = 6'b101011;
		else if(f[7])	shc = 6'b101100;
		else if(f[6])	shc = 6'b101101;
		else if(f[5])	shc = 6'b101110;
		else if(f[4])	shc = 6'b101111;
		else if(f[3])	shc = 6'b110000;
		else if(f[2])	shc = 6'b110001;
		else if(f[1])	shc = 6'b110010;
		else			shc = 6'b110011;
	end
	endfunction

	wire	[5:0]	w_sh_count = shc(w_fr_res[51:0]);

	wire	[51:0]	w_norm_fr = (w_xnor) ? (w_fr_res >> w_fr_res[10]) : (w_fr_res << w_sh_count);
	wire	[10:0]	w_norm_ex = (w_xnor) ? (w_ex_l + w_fr_res[10]) : (w_ex_l - w_sh_count);

	// round
	wire	guard, round, stiky;
	assign	{guard, round, stiky} = {w_rem[10], w_rem[9], |w_rem[8:0]};

	wire	[51:0]	w_round_fr = w_norm_fr + (guard & (round | stiky | w_norm_fr[0]));

	// exception
	function [1:0] exception;
	input	[10:0]	ex_l, ex_s;
	input	[51:0]	fr_l, fr_s;
	begin
		casex ( {ex_l,1'b0,fr_l,   ex_s,1'b0,fr_s} )
			128'h000xxxxxxx_000xxxxxxx: exception = 2'b01;	// zero
			128'h000xxxxxxx_ffe0000000: exception = 2'b10;	// inf
			128'h000xxxxxxx_ffexxxxxxx: exception = 2'b11;	// NaN
			128'h000xxxxxxx_xxxxxxxxxx: exception = 2'b00;	// Number
			128'hffe0000000_000xxx0000: exception = 2'b10;
			128'hffe0000000_ffe0000000: exception = 2'b10;
			128'hffe0000000_ffexxxxxxx: exception = 2'b11;
			128'hffe0000000_xxxxxxxxxx: exception = 2'b10;
			128'hffexxxxxxx_xxxxxxxxxx: exception = 2'b11;
			128'hxxxxxxxxxx_000xxxxxxx: exception = 2'b00;
			128'hxxxxxxxxxx_ffe0000000: exception = 2'b10;
			128'hxxxxxxxxxx_ffexxxxxxx: exception = 2'b11;
			128'hxxxxxxxxxx_xxxxxxxxxx: exception = 2'b00;
			default: exception = 2'b00;
		endcase
	end
	endfunction

	wire	[1:0]	w_exc		= exception(w_ex_l, w_ex_s, w_fr_l, w_fr_s);
	wire	[10:0]	w_exc_ex	= (w_exc == 2'b00) ?	w_norm_ex
								: (w_exc == 2'b01) ?	11'h000 
								:						11'h7ff;
	wire	[51:0]	w_exc_fr	= (w_exc == 2'b00) ?	w_round_fr
								: (w_exc == 2'b11) ?	52'h8000000000000 
								:						52'h0000000000000;
	wire			w_exc_sg	= w_sg_l;

	assign	out = {w_exc_sg, w_exc_ex, w_exc_fr};

endmodule

module dmul(
	input	[63:0]	a,
	input	[63:0]	b,
	output	[63:0]	out	
);

	// multiply
	wire			w_sg		= a[63] ^ b[63];
	wire	[105:0]	w_fr_mul	= {1'b1, a[51:0]} * {1'b1, b[51:0]};
	wire	[11:0]	w_ex_tmp	= a[62:52] + b[62:52] - 'd1023 + w_fr_mul[105];

	// normalize
	wire	[55:0]	w_fr_tmp	= {w_fr_mul[105:51], (|w_fr_mul[50:0])};
	wire	[55:0]	w_norm_fr	= (w_fr_mul[105]) ? w_fr_tmp : {w_fr_tmp[54:0], 1'b0};
	
	// round
	wire	least, guard, round, stiky;
	assign	{least, guard, round, stiky} = {w_norm_fr[3], w_norm_fr[2], w_norm_fr[1], w_norm_fr[0]};
	wire	[52:0]	w_round_fr = w_norm_fr[54:3] + (guard & (least | round | stiky));

	// Exceptions
	function [1:0] exception;
	input [10:0] ex_a, ex_b;
	input [51:0] fr_a, fr_b;
	begin
		casex ({ex_a,1'b0,fr_a, ex_b,1'b0,fr_b})
			128'h000xxxxxxx_000xxxxxxx: exception = 2'b01;	// zero
			128'h000xxxxxxx_ffe0000000: exception = 2'b10;	// inf
			128'h000xxxxxxx_ffexxxxxxx: exception = 2'b11;	// NaN
			128'h000xxxxxxx_xxxxxxxxxx: exception = 2'b00;	// Number
			128'hffe0000000_000xxx0000: exception = 2'b10;
			128'hffe0000000_ffe0000000: exception = 2'b10;
			128'hffe0000000_ffexxxxxxx: exception = 2'b11;
			128'hffe0000000_xxxxxxxxxx: exception = 2'b10;
			128'hffexxxxxxx_xxxxxxxxxx: exception = 2'b11;
			128'hxxxxxxxxxx_000xxxxxxx: exception = 2'b00;
			128'hxxxxxxxxxx_ffe0000000: exception = 2'b10;
			128'hxxxxxxxxxx_ffexxxxxxx: exception = 2'b11;
			128'hxxxxxxxxxx_xxxxxxxxxx: exception = 2'b00;
			default: exception = 2'b00;
		endcase
	end
	endfunction

	wire	[1:0]	w_exc		= exception(a[63:53], b[63:53], a[52:0], b[52:0]);
	wire	[10:0]	w_exc_ex	= (w_exc == 2'b00) ?	(w_ex_tmp[11])?	(w_ex_tmp[10])?	11'h000	:	11'h7FF	:	w_ex_tmp[10:0]
								: (w_exc == 2'b01) ?	11'h000
								:						11'h7ff;
	wire	[51:0]	w_exc_fr	= (w_exc == 2'b00) ?	(w_ex_tmp[11] || w_exc_ex == 11'h7FF || w_exc_ex == 11'h000)?	52'h00000	:	w_round_fr
								: (w_exc == 2'b11) ?	52'h8000000000000
								:                    	52'h0000000000000;
	wire			w_exc_sg	= ({w_exc_ex, w_exc_fr} == 63'b0) ?	1'b0	:	w_sg;

	assign	out = {w_exc_sg, w_exc_ex, w_exc_fr};

endmodule

module ddiv(
	input	[63:0]	a,
	input	[63:0]	b,
	output	[63:0]	out	
);

	// divide
	wire			w_sg		= a[63] ^ b[63];
	wire	[107:0]	w_div_fr	= ( {1'b1, a[51:0]} << 54 ) / {1'b1, b[51:0]};
	wire	[11:0]	w_ex_tmp	= a[62:52] - b[62:52] + 'd1023 - !w_div_fr[55];

	// normalize
	wire	[55:0]	w_norm_fr	= (w_div_fr[54]) ? {w_div_fr[54:0], 1'b1} : {w_div_fr[53:0], 2'b11};

	// round
	wire	least, guard, round, stiky;
	assign	{least, guard, round, stiky} = {w_norm_fr[3], w_norm_fr[2], w_norm_fr[1], w_norm_fr[0]};
	wire	[52:0]	w_round_fr = w_norm_fr[54:3] + (guard & (least | round | stiky));

	// Exceptions
	function [1:0] exception;
	input [10:0] ex_a, ex_b;
	input [51:0] fr_a, fr_b;
	begin
		casex ({ex_a,1'b0,fr_a, ex_b,1'b0,fr_b})
			128'h000xxxxxxx_000xxxxxxx: exception = 2'b01;	// zero
			128'h000xxxxxxx_ffe0000000: exception = 2'b10;	// inf
			128'h000xxxxxxx_ffexxxxxxx: exception = 2'b11;	// NaN
			128'h000xxxxxxx_xxxxxxxxxx: exception = 2'b00;	// Number
			128'hffe0000000_000xxx0000: exception = 2'b10;
			128'hffe0000000_ffe0000000: exception = 2'b10;
			128'hffe0000000_ffexxxxxxx: exception = 2'b11;
			128'hffe0000000_xxxxxxxxxx: exception = 2'b10;
			128'hffexxxxxxx_xxxxxxxxxx: exception = 2'b11;
			128'hxxxxxxxxxx_000xxxxxxx: exception = 2'b00;
			128'hxxxxxxxxxx_ffe0000000: exception = 2'b10;
			128'hxxxxxxxxxx_ffexxxxxxx: exception = 2'b11;
			128'hxxxxxxxxxx_xxxxxxxxxx: exception = 2'b00;
			default: exception = 2'b00;
		endcase
	end
	endfunction

	wire	[1:0]	w_exc		= exception(a[63:53], b[63:53], a[52:0], b[52:0]);
	wire	[10:0]	w_exc_ex	= (w_exc == 2'b00) ?	(w_ex_tmp[11])?	(w_ex_tmp[10])?	11'h000	:	11'h7FF	:	w_ex_tmp[10:0]
								: (w_exc == 2'b01) ?	11'h000
								:						11'h7ff;
	wire	[51:0]	w_exc_fr	= (w_exc == 2'b00) ?	(w_ex_tmp[11] || w_exc_ex == 11'h7FF || w_exc_ex == 11'h000)?	52'h00000	:	w_round_fr
								: (w_exc == 2'b11) ?	52'h8000000000000
								:                    	52'h0000000000000;
	wire			w_exc_sg	= ({w_exc_ex, w_exc_fr} == 63'b0) ?	1'b0	:	w_sg;

	assign	out = {w_exc_sg, w_exc_ex, w_exc_fr};
endmodule

module dsqrt(
	input wire [63:0]	a,
	output reg [63:0]	out	
);
	// Extract fields of the input
	wire		sign_a = a[63];
	wire [10:0]	ex_a = a[62:52];
	wire [51:0]	fr_a = a[51:0];

	// Special case: if input is zero or negative
	wire w_zero = (a[62:0] == 63'b0);
	wire w_neg = sign_a;

	// Normalize the mantissa with an implicit leading 1
	wire [52:0] fr_tmp = {1'b1, fr_a};

	// Adjust the exponent for sqrt
	// sqrt(2^E * M) = 2^(E/2) * sqrt(M)
	wire [10:0] ex_a_adj = ex_a - 11'd2047;  // Unbias the exponent
	wire [10:0] ex_h = ex_a_adj >> 1;   // Divide by 2
	wire [10:0] ex_result = ex_h + 11'd2047; // Re-bias the exponent

	// Binary square root algorithm for the mantissa
	reg [52:0] fr_result;
	reg [53:0] rem;
	reg [52:0] root;
	integer i;

	always @(*) begin
		if (w_zero || w_neg) begin
			out = 64'b0;
		end else begin
			rem = 0;
			root = 0;
			for (i = 52; i >= 0; i = i - 1) begin
				rem = {rem[51:0], fr_tmp[i], 1'b0};
				if (rem >= {root, 2'b01}) begin
					rem = rem - {root, 2'b01};
					root = {root[51:0], 1'b1};
				end else begin
					root = {root[51:0], 1'b0};
				end
			end
			fr_result = root;

			// Combine the fields to form the result
			out = {1'b0, ex_result, fr_result[51:0]};
		end
	end

endmodule

module fcvt_d2i(
	input			s_signed,
	input	[63:0]	a,
	output	[31:0]	out
);
	// Extract fields of the input
	wire sign_a = a[63];
	wire [10:0] ex_a = a[62:52];
	wire [52:0] fr_a = {1'b1, a[51:0]};

	// Compute the effective exponent by subtracting the bias
	wire [10:0] eff_ex;
	assign eff_ex = ex_a - 1023;

	wire [31:0] int_value;
	assign int_value =	(eff_ex < 0    ) ? 32'b0 : 
						(eff_ex < 11'd52) ? fr_a >> (11'd52 - eff_ex) : fr_a << (eff_ex - 11'd52);

	assign	out	= sign_a ? -a : a;
endmodule

module fcvt_i2d(
	input			s_signed,
	input	[31:0]	a,
	output	[63:0]	out
);
	// Temporary variables for calculation
	reg [31:0] temp;
	reg [10:0] ex;
	reg [52:0] fr;
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
				ex = i + 1023; // Exponent is the position of MSB plus the bias (127)
				temp = temp << (31 - i); // Shift left to align MSB with the leading bit position
				break;
			end
		end

		// Extract the mantissa
		fr = {temp, 21'b0};
	end

	assign	out = {sign & s_signed, ex, fr};
endmodule

module fcvt_f2d(
	input	[31:0]	a,
	output	[63:0]	out
);
	// Extract fields of the input
	wire sign_a = a[63];
	wire [10:0] ex_a = a[62:52];
	wire [51:0] fr_a = a[51:0];

	// Extract fields of the input
	wire sign_o = sign_a;
	wire [7:0] ex_o = ex_a[10:3];
	wire [22:0] fr_o = fr_a[51:29];

endmodule

module fcvt_d2f(
	input	[64:0]	a,
	output	[31:0]	out
);
	// Extract fields of the input
	wire sign_a = a[31];
	wire [7:0] ex_a = a[30:23];
	wire [22:0] fr_a = a[22:0];

	// Extract fields of the input
	wire sign_o = sign_a;
	wire [10:0] ex_o = {ex_a, 3'b000};
	wire [51:0] fr_o = {fr_a, 29'b0};
endmodule

module dalu(
	input	[3:0]	dops,

	input	[63:0]	rs1,
	input	[63:0]	rs2,
	output	[63:0]	out	
);

	wire	[31:0]	w_add, w_mul, w_div, w_sqrt, w_sgnj, w_mnx, w_comp;

	wire			w_sub_en = (dops == 4'h1);

	dadd dadd(
		.a(rs1),
		.b(w_sub_en ? {~rs2[63], rs2[62:0]} : rs2),
		.out(w_add)
	);

	dmul dmul(
		.a(rs1),
		.b(rs2),
		.out(w_mul)
	);

	ddiv ddiv(
		.a(rs1),
		.b(rs2),
		.out(w_div)
	);

	dsqrt dsqrt(
		.a(rs1),
		.out(w_sqrt)
	);

	assign	w_sgnj =	(dops == 4'h5) ? {rs2[63], rs1[62:0]}	:
						(dops == 4'h6) ? {~rs2[63], rs1[62:0]}	:
						(dops == 4'h7) ? {rs1[63] ^ rs2[63], rs1[62:0]}	:
						64'h0;
	
	assign	w_mnx  =	(dops == 4'h8) ? (w_add[63] ? rs2 : rs1) :
						(dops == 4'h9) ? (w_add[63] ? rs1 : rs2) :
						64'h0;
						
	assign	w_comp =	(dops == 4'hA) ? (w_add == 0 ? 64'b1 : 64'b0) :
						(dops == 4'hB) ? (w_add[63] ? 64'b0 : 64'b1) :
						(dops == 4'hC) ? (w_add[63] | w_add == 0 ? 64'b0 : 64'b1) :
						64'h0;

	assign	out	=		(dops == 4'h0 || dops == 4'h1)
										?	w_add	:
						(dops == 4'h2)	?	w_mul	:
						(dops == 4'h3)	?	w_div	:
						(dops == 4'h4)	?	w_sqrt	:
						(dops == 4'h5 || dops == 4'h6 || dops == 4'h7) 
										?	w_sgnj	:
						(dops == 4'h8 || dops == 4'h9) 
										?	w_mnx	:
						(dops == 4'hA || dops == 4'hB || dops == 4'hC) 
										?	w_comp	:	32'b0;
endmodule