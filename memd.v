`timescale 1ns / 1ps
module dmem #(
	parameter	DELAY = 5
)(
	input				clk,
	input				rst,
	input				i_wen,
	input		[31:0]	i_wdata,
	input				i_ren,
	output	reg			o_rvd,
	output	reg	[31:0]	o_rdata,
	input		[31:0]	i_addr
);

	reg [31:0] mem[0:1024*8-1];

	reg	[31:0]	r_c=1, r_addr=0;
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			r_addr	<=	0;
			r_c		<=	0;
			o_rvd	<=	0;
			o_rdata	<=	0;
		end else begin
			r_addr	<=	(r_c==1 & i_ren)?i_addr:r_addr;
			r_c		<=	(r_c==1 & i_ren)?2
					:	(r_c==1 | r_c==DELAY)?1:r_c+1;
			o_rvd	<=	(r_c==DELAY-1);
			o_rdata	<=	(r_c==DELAY-1)?mem[r_addr[31:2]]:0;
		end
	end

	always @(posedge clk) begin
		if (i_wen) begin
			mem[i_addr[14:2]]	<=	i_wdata;
		end
	end

	integer idx; // need integer for loop
	initial begin
		for (idx = 0; idx < 255; idx = idx + 1) $dumpvars(0, mem[idx]);
	end
endmodule
