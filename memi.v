module imem #(
	parameter	DELAY = 5
)(
	input				clk,
	input				rst,
	input				i_ren,
	output	reg			o_rvd,
	input		[31:0]	i_addr,
	output	reg	[31:0]	o_inst
);

	reg		[31:0]	mem	[0:255];

	//reg		[31:0]	d;

	integer i; 
	initial for (i=0; i<256; i=i+1) mem[i] = 32'd0;
	initial	$readmemh("data.dat", mem);

	reg	[31:0]	r_c=1, r_pc=0;
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			r_pc	<=	0;
			r_c		<=	0;
			o_rvd	<=	0;
			o_inst	<=	0;
		end else begin
			r_pc	<=	(r_c==1 & i_ren)?i_addr:r_pc;
			r_c		<=	(r_c==1 & i_ren)?2
					:	(r_c==1 | r_c==DELAY)?1:r_c+1;
			o_rvd	<=	(r_c==DELAY-1);
			o_inst	<=	(r_c==DELAY-1)?mem[r_pc[31:2]]:0;
		end
	end

	integer idx; // need integer for loop
	initial begin
		for (idx = 0; idx < 255; idx = idx + 1) $dumpvars(0, mem[idx]);
	end
endmodule