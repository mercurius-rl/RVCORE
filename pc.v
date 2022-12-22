module pc (
	input			clk,
	input			rst,
	
	input			stall,

	input			jp_en,
	input	[31:0]	jp_addr,

	output	[31:0]	addr
);

	reg		[31:0]	r_addr;

	always @(posedge clk) begin
		if (rst) begin
			r_addr	<=	32'h0;
		end else begin
			if (stall) begin
				r_addr	<=	r_addr;
			end else if (jp_en) begin
				r_addr	<=	jp_addr;
			end else begin
				r_addr	<=	r_addr + 4;
			end
		end
	end

	assign	addr	=	r_addr;

endmodule