module icache(
	input			clk, rst,

	output			o_hit,

	output	[31:0]	o_rdata,
	input	[31:0]	i_addr,

	input			i_wen,
	input	[31:0]	i_waddr,
	input	[31:0]	i_wdata
);
	wire			w_v;
	wire	[24:0]	w_tag;
	//wire	[31:0]	w_data;

	reg		[57:0]	buffer	[0:31];

	integer i;
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			for (i = 0; i < 32; i = i + 1) begin
				buffer[i]		<=	58'b0;
			end
		end else if (i_wen & !o_hit) begin
			buffer[i_waddr[6:2]]	<=	{1'b1, i_waddr[31:7], i_wdata};
		end
	end

	assign	{w_v, w_tag, o_rdata} = buffer[i_addr[6:2]];
	assign	o_hit	=	w_v & (w_tag == i_addr[31:7]);

endmodule

module dcache(
	input			clk, rst,

	output			o_hit,

	input			i_wen,
	input	[31:0]	i_wdata,
	output	[31:0]	o_rdata,
	input	[31:0]	i_addr,

	input			i_mwen,
	input	[31:0]	i_maddr,
	input	[31:0]	i_mdata
);
	wire			w_v;
	wire	[24:0]	w_tag;
	//wire	[31:0]	w_data;

	reg		[57:0]	buffer	[0:31];

	integer i;
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			for (i = 0; i < 32; i = i + 1) begin
				buffer[i]		<=	58'b0;
			end
		end else if (i_wen) begin
			buffer[i_addr[6:2]]	<=	{1'b1, i_addr[31:7], i_wdata};
		end else if (i_mwen & !o_hit) begin
			buffer[i_maddr[6:2]]	<=	{1'b1, i_maddr[31:7], i_mdata};
		end
	end

	assign	{w_v, w_tag, o_rdata} = buffer[i_addr[6:2]];
	assign	o_hit	=	w_v & (w_tag == i_addr[31:7]);

endmodule