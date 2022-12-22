`timescale 1ps/1ps

module tb_dec;

parameter STEP = 2;

reg clk = 0, rst = 0;

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

core cpu(
	.clk(clk),
	.rst(rst),

	.i_exstall(1'b0),

	.i_inst(w_imemd),
	.o_iaddr(w_imema),

	.i_read_data(w_rdata),
	.o_read_en(w_ren),
	.o_write_data(w_wdata),
	.o_write_en(w_wen),
	.o_memaddr(w_memaddr)
);

dmem dmam(
	.clk(clk),
	.i_wen(w_wen),
	.i_wdata(w_wdata),
	.i_addr(w_memaddr),
	.o_rdata(w_rdata)
);

initial begin
	rst		=	1;
	#(STEP*5);
	rst		=	0;
	#(STEP*30);
	$finish;
end

initial begin
	$monitor ($stime, " inst = %8x", w_imemd);
	$dumpfile("d.vcd");
	$dumpvars(0, tb_dec);
end


endmodule