`timescale 1ps/1ps

module tb_dec;

parameter STEP = 2;
parameter MEMDUMP = "TRUE";

reg clk = 0, rst = 0;

// data memory
reg [31:0] mem[0:1024*8-1];

wire	[31:0]	w_imemd;
wire	[31:0]	w_imema;

wire	[31:0]	w_wdata, w_rdata;
wire			w_wen,w_ren;
wire	[31:0]	w_memaddr;

always #(STEP/2) begin
	clk	<=	~clk;
end

icache ic(
	.i_addr	(w_imema),
	.o_inst	(w_imemd)
);

core #(
	.RVM("TRUE"),
	.RVV("TRUE"),
	.VLEN(128)
)cpu(
	.clk(clk),
	.rst(rst),

	.i_exstall(1'b0),

	.i_inst(w_imemd),
	.o_iaddr(w_imema),

	.i_read_data(w_rdata),
	.o_read_en(w_ren),
	.i_read_vd(1),
	.o_write_data(w_wdata),
	.o_write_en(w_wen),
	.o_memaddr(w_memaddr)
);

/*
dmem dmam(
	.clk(clk),
	.i_wen(w_wen),
	.i_wdata(w_wdata),
	.i_addr(w_memaddr),
	.o_rdata(w_rdata)
);
*/
	// dmem model
	assign	w_rdata = mem[w_memaddr[14:2]];

	always @(posedge clk) begin
		if (w_wen) begin
			mem[w_memaddr[14:2]]	<=	w_wdata;
		end
	end

initial begin
	rst		=	1;
	#(STEP*5);
	rst		=	0;
	#(STEP*30);
	$finish;
end

integer idx; // need integer for loop
initial begin
	$monitor ($stime, " inst = %8x", w_imemd);
	$dumpfile("d.vcd");
	$dumpvars(0, tb_dec);
	if (MEMDUMP == "TRUE") begin
		for (idx = 0; idx < 1024; idx = idx + 1) $dumpvars(1, mem[idx]);
	end	
end

endmodule