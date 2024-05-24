`timescale 1ps/1ps

module tb_dec;

parameter STEP = 2;
parameter MEMDUMP = "TRUE";

reg clk = 0, rst = 0;

// data memory
//reg [31:0] mem[0:1024*8-1];
wire 			w_iren;
wire			w_irvd;
wire	[31:0]	w_imemd;
wire	[31:0]	w_imema;

wire	[31:0]	w_wdata, w_rdata;
wire			w_wen,w_ren;
wire	[31:0]	w_memaddr;

always #(STEP/2) begin
	clk	<=	~clk;
end

icache ic(
	.clk	(clk),
	.rst	(rst),
	.i_ren	(w_iren),
	.o_rvd	(w_irvd),
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

	.i_interrupt(1'b0),

	.i_inst(w_imemd),
	.o_iaddr(w_imema),
	.i_iread_vd(w_irvd),
	.o_iread_en(w_iren),

	.i_read_data(w_rdata),
	.o_read_en(w_ren),
	.i_read_vd(w_rvd),
	.o_write_data(w_wdata),
	.o_write_en(w_wen),
	.o_memaddr(w_memaddr)
);


dmem dmam(
	.clk	(clk),
	.rst	(rst),
	.i_ren	(w_ren),
	.o_rvd	(w_rvd),
	.i_wen	(w_wen),
	.i_wdata(w_wdata),
	.i_addr	(w_memaddr),
	.o_rdata(w_rdata)
);

initial begin
	rst		=	1;
	#(STEP*6);
	rst		=	0;
	#(STEP*900);
	$finish;
end

integer idx; // need integer for loop
initial begin
	$monitor ($stime, " inst = %8x", w_imemd);
	//$dumpfile("d.vcd");
	$dumpvars(0, tb_dec);
	//if (MEMDUMP == "TRUE") begin
	//	for (idx = 0; idx < 1024; idx = idx + 1) $dumpvars(0, dmem.mem[idx]);
	//end	
end

endmodule