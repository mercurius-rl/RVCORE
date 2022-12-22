module icache (
	input	[31:0]	i_addr,
	output	[31:0]	o_inst
);

	reg		[31:0]	mem	[0:255];

	//reg		[31:0]	d;

	// 16進数に変換した命令を読み込む
	initial	$readmemh("data.dat", mem);

	//always @(*) begin
	//	#1;
	//	d	<=	mem[i_addr[31:2]];
	//end
	assign	o_inst	=	mem[i_addr[31:2]];
endmodule