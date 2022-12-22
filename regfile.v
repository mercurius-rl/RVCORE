`timescale 1ns / 1ps
module regfile #(
	parameter	DW = 32
)(
	input				clk,

	// write
	input	[DW-1:0]	i_wdata,
	input	[4:0]		i_wad,
	input				i_we,
	// read
	output	[DW-1:0]	o_rdataa,
	output	[DW-1:0]	o_rdatab,
	input	[4:0]		i_rada,
	input	[4:0]		i_radb
);

	reg	[DW-1:0]		rf	[0:31];

	always @(posedge clk) begin
		if (i_we) begin
			rf[i_wad] <= i_wdata;
		end
	end

	integer i;
	initial begin
		for(i=0; i < 32; i=i+1)
			rf[i]=0;
	end

	assign o_rdataa = (i_rada == 0) ? 0 : rf[i_rada];
	assign o_rdatab = (i_radb == 0) ? 0 : rf[i_radb];

endmodule
