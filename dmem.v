`timescale 1ns / 1ps
module dmem(
	input			clk,
	input			i_wen,
	input	[31:0]	i_wdata,
	input	[31:0]	i_addr,
	output	[31:0]	o_rdata
);

	reg [31:0] mem[1024*8-1:0];

	assign	o_rdata = mem[i_addr[14:2]];

	always @(posedge clk) begin
		if (i_wen) begin
			mem[i_addr[14:2]]	<=	i_wdata;
		end
	end
endmodule
