module comp (
	input	[2:0]	i_funct3,
	input	[6:0]	i_op,
	input	[31:0]	i_dataa,
	input	[31:0]	i_datab,

	output			o_result
);

	reg	r_result = 1'b0;
	always @(*) begin
		if (i_op[6:4] == 3'b110) begin
			if (i_op[2:0] == 3'b111) begin
				r_result = 1'b1;
			end else begin
				case (i_funct3)
					3'b000: r_result <= (i_dataa == i_datab) ? 1'b1 : 1'b0;
					3'b001: r_result <= (i_dataa != i_datab) ? 1'b1 : 1'b0;
					3'b010: r_result <= 1'b0;
					3'b011: r_result <= 1'b0;
					3'b100: r_result <=  ($signed(i_dataa) <  $signed(i_datab)) ? 1'b1 : 1'b0;
					3'b101: r_result <= ($signed(i_dataa) >= $signed(i_datab)) ? 1'b1 : 1'b0;
					3'b110: r_result <= (i_dataa < i_datab) ? 1'b1 : 1'b0;
					3'b111: r_result <= (i_dataa >= i_datab) ? 1'b1 : 1'b0;
					default: r_result <= 1'b0;
				endcase
			end
		end else begin
			r_result <= 1'b0;
		end
	end

	assign o_result = r_result;

endmodule