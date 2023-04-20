module valu #(
	parameter	VLEN	=   128
) (
	input	[2:0]		i_sew,

	input	[VLEN-1:0]	i_dataa,
	input	[VLEN-1:0]	i_datab,
	input	[5:0]		i_ctrl,

	output	[VLEN-1:0]	o_result
);
	parameter	VAND	=	6'b000100,
				VOR		=	6'b000101,
				VXOR	=	6'b000110,
				VADD	=	6'b000000,
				VSUB	=	6'b000001,
				VSLT	=	6'b000010,
				VSLTU	=	6'b000011,
				VSLL	=	6'b011000,
				VSRL	=	6'b011001,
				VSRA	=	6'b011010;

	reg	[VLEN-1:0]	r_result;

	assign	o_result = r_result;
	
	integer i;
	always @(*) begin
		case (i_sew)
			3'h0: begin
				case (i_ctrl)
					VAND : begin
						for (i = 0; i <= VLEN; i = i + 8) begin
							r_result[i+:8]	<=	i_dataa[i+:8] & i_datab[i+:8];
						end
					end
					VOR : begin
						for (i = 0; i <= VLEN; i = i + 8) begin
							r_result[i+:8]	<=	i_dataa[i+:8] | i_datab[i+:8];
						end
					end
					VXOR : begin
						for (i = 0; i <= VLEN; i = i + 8) begin
							r_result[i+:8]	<=	i_dataa[i+:8] ^ i_datab[i+:8];
						end
					end
					VADD : begin
						for (i = 0; i <= VLEN; i = i + 8) begin
							r_result[i+:8]	<=	i_dataa[i+:8] + i_datab[i+:8];
						end
					end
					VSUB : begin
						for (i = 0; i <= VLEN; i = i + 8) begin
							r_result[i+:8]	<=	i_dataa[i+:8] - i_datab[i+:8];
						end
					end
					VSLT : begin
						for (i = 0; i <= VLEN; i = i + 8) begin
							r_result[i+:8]	<=	$signed(i_dataa[i+:8]) < $signed(i_datab[i+:8]);
						end
					end
					VSLTU : begin
						for (i = 0; i <= VLEN; i = i + 8) begin
							r_result[i+:8]	<=	i_dataa[i+:8] < i_datab[i+:8];
						end
					end
					VSLL : begin
						for (i = 0; i <= VLEN; i = i + 8) begin
							r_result[i+:8]	<=	i_dataa[i+:8] << i_datab[i+:8];
						end
					end
					VSRL : begin
						for (i = 0; i <= VLEN; i = i + 8) begin
							r_result[i+:8]	<=	i_dataa[i+:8] >> i_datab[i+:8];
						end
					end
					VSRA : begin
						for (i = 0; i <= VLEN; i = i + 8) begin
							r_result[i+:8]	<=	$signed(i_dataa[i+:8]) >>> $signed(i_datab[i+:8]);
						end
					end
					default: begin
						r_result[i+:8]	<=	i_dataa[i+:8];
					end
				endcase
			end
			3'h1: begin
				case (i_ctrl)
					VAND : begin
						for (i = 0; i <= VLEN; i = i + 16) begin
							r_result[i+:16]	<=	i_dataa[i+:16] & i_datab[i+:16];
						end
					end
					VOR : begin
						for (i = 0; i <= VLEN; i = i + 16) begin
							r_result[i+:16]	<=	i_dataa[i+:16] | i_datab[i+:16];
						end
					end
					VXOR : begin
						for (i = 0; i <= VLEN; i = i + 16) begin
							r_result[i+:16]	<=	i_dataa[i+:16] ^ i_datab[i+:16];
						end
					end
					VADD : begin
						for (i = 0; i <= VLEN; i = i + 16) begin
							r_result[i+:16]	<=	i_dataa[i+:16] + i_datab[i+:16];
						end
					end
					VSUB : begin
						for (i = 0; i <= VLEN; i = i + 16) begin
							r_result[i+:16]	<=	i_dataa[i+:16] - i_datab[i+:16];
						end
					end
					VSLT : begin
						for (i = 0; i <= VLEN; i = i + 16) begin
							r_result[i+:16]	<=	$signed(i_dataa[i+:16]) < $signed(i_datab[i+:16]);
						end
					end
					VSLTU : begin
						for (i = 0; i <= VLEN; i = i + 16) begin
							r_result[i+:16]	<=	i_dataa[i+:16] < i_datab[i+:16];
						end
					end
					VSLL : begin
						for (i = 0; i <= VLEN; i = i + 16) begin
							r_result[i+:16]	<=	i_dataa[i+:16] << i_datab[i+:16];
						end
					end
					VSRL : begin
						for (i = 0; i <= VLEN; i = i + 16) begin
							r_result[i+:16]	<=	i_dataa[i+:16] >> i_datab[i+:16];
						end
					end
					VSRA : begin
						for (i = 0; i <= VLEN; i = i + 16) begin
							r_result[i+:16]	<=	$signed(i_dataa[i+:16]) >>> $signed(i_datab[i+:16]);
						end
					end
					default: begin
						r_result[i+:16]	<=	i_dataa[i+:16];
					end
				endcase
			end
			3'h2: begin
				case (i_ctrl)
					VAND : begin
						for (i = 0; i <= VLEN; i = i + 32) begin
							r_result[i+:32]	<=	i_dataa[i+:32] & i_datab[i+:32];
						end
					end
					VOR : begin
						for (i = 0; i <= VLEN; i = i + 32) begin
							r_result[i+:32]	<=	i_dataa[i+:32] | i_datab[i+:32];
						end
					end
					VXOR : begin
						for (i = 0; i <= VLEN; i = i + 32) begin
							r_result[i+:32]	<=	i_dataa[i+:32] ^ i_datab[i+:32];
						end
					end
					VADD : begin
						for (i = 0; i <= VLEN; i = i + 32) begin
							r_result[i+:32]	<=	i_dataa[i+:32] + i_datab[i+:32];
						end
					end
					VSUB : begin
						for (i = 0; i <= VLEN; i = i + 32) begin
							r_result[i+:32]	<=	i_dataa[i+:32] - i_datab[i+:32];
						end
					end
					VSLT : begin
						for (i = 0; i <= VLEN; i = i + 32) begin
							r_result[i+:32]	<=	$signed(i_dataa[i+:32]) < $signed(i_datab[i+:32]);
						end
					end
					VSLTU : begin
						for (i = 0; i <= VLEN; i = i + 32) begin
							r_result[i+:32]	<=	i_dataa[i+:32] < i_datab[i+:32];
						end
					end
					VSLL : begin
						for (i = 0; i <= VLEN; i = i + 32) begin
							r_result[i+:32]	<=	i_dataa[i+:32] << i_datab[i+:32];
						end
					end
					VSRL : begin
						for (i = 0; i <= VLEN; i = i + 32) begin
							r_result[i+:32]	<=	i_dataa[i+:32] >> i_datab[i+:32];
						end
					end
					VSRA : begin
						for (i = 0; i <= VLEN; i = i + 32) begin
							r_result[i+:32]	<=	$signed(i_dataa[i+:32]) >>> $signed(i_datab[i+:32]);
						end
					end
					default: begin
						r_result[i+:32]	<=	i_dataa[i+:32];
					end
				endcase
			end
			3'h3: begin
				case (i_ctrl)
					VAND : begin
						for (i = 0; i <= VLEN; i = i + 64) begin
							r_result[i+:64]	<=	i_dataa[i+:64] & i_datab[i+:64];
						end
					end
					VOR : begin
						for (i = 0; i <= VLEN; i = i + 64) begin
							r_result[i+:64]	<=	i_dataa[i+:64] | i_datab[i+:64];
						end
					end
					VXOR : begin
						for (i = 0; i <= VLEN; i = i + 64) begin
							r_result[i+:64]	<=	i_dataa[i+:64] ^ i_datab[i+:64];
						end
					end
					VADD : begin
						for (i = 0; i <= VLEN; i = i + 64) begin
							r_result[i+:64]	<=	i_dataa[i+:64] + i_datab[i+:64];
						end
					end
					VSUB : begin
						for (i = 0; i <= VLEN; i = i + 64) begin
							r_result[i+:64]	<=	i_dataa[i+:64] - i_datab[i+:64];
						end
					end
					VSLT : begin
						for (i = 0; i <= VLEN; i = i + 64) begin
							r_result[i+:64]	<=	$signed(i_dataa[i+:64]) < $signed(i_datab[i+:64]);
						end
					end
					VSLTU : begin
						for (i = 0; i <= VLEN; i = i + 64) begin
							r_result[i+:64]	<=	i_dataa[i+:64] < i_datab[i+:64];
						end
					end
					VSLL : begin
						for (i = 0; i <= VLEN; i = i + 64) begin
							r_result[i+:64]	<=	i_dataa[i+:64] << i_datab[i+:64];
						end
					end
					VSRL : begin
						for (i = 0; i <= VLEN; i = i + 64) begin
							r_result[i+:64]	<=	i_dataa[i+:64] >> i_datab[i+:64];
						end
					end
					VSRA : begin
						for (i = 0; i <= VLEN; i = i + 64) begin
							r_result[i+:64]	<=	$signed(i_dataa[i+:64]) >>> $signed(i_datab[i+:64]);
						end
					end
					default: begin
						r_result[i+:64]	<=	i_dataa[i+:64];
					end
				endcase
			end
			3'h4: begin
				case (i_ctrl)
					VAND : begin
						for (i = 0; i <= VLEN; i = i + 128) begin
							r_result[i+:128]	<=	i_dataa[i+:128] & i_datab[i+:128];
						end
					end
					VOR : begin
						for (i = 0; i <= VLEN; i = i + 128) begin
							r_result[i+:128]	<=	i_dataa[i+:128] | i_datab[i+:128];
						end
					end
					VXOR : begin
						for (i = 0; i <= VLEN; i = i + 128) begin
							r_result[i+:128]	<=	i_dataa[i+:128] ^ i_datab[i+:128];
						end
					end
					VADD : begin
						for (i = 0; i <= VLEN; i = i + 128) begin
							r_result[i+:128]	<=	i_dataa[i+:128] + i_datab[i+:128];
						end
					end
					VSUB : begin
						for (i = 0; i <= VLEN; i = i + 128) begin
							r_result[i+:128]	<=	i_dataa[i+:128] - i_datab[i+:128];
						end
					end
					VSLT : begin
						for (i = 0; i <= VLEN; i = i + 128) begin
							r_result[i+:128]	<=	$signed(i_dataa[i+:128]) < $signed(i_datab[i+:128]);
						end
					end
					VSLTU : begin
						for (i = 0; i <= VLEN; i = i + 128) begin
							r_result[i+:128]	<=	i_dataa[i+:128] < i_datab[i+:128];
						end
					end
					VSLL : begin
						for (i = 0; i <= VLEN; i = i + 128) begin
							r_result[i+:128]	<=	i_dataa[i+:128] << i_datab[i+:128];
						end
					end
					VSRL : begin
						for (i = 0; i <= VLEN; i = i + 128) begin
							r_result[i+:128]	<=	i_dataa[i+:128] >> i_datab[i+:128];
						end
					end
					VSRA : begin
						for (i = 0; i <= VLEN; i = i + 128) begin
							r_result[i+:128]	<=	$signed(i_dataa[i+:128]) >>> $signed(i_datab[i+:128]);
						end
					end
					default: begin
						r_result[i+:128]	<=	i_dataa[i+:128];
					end
				endcase
			end
			default: r_result	<=	r_result;
		endcase
	end
endmodule