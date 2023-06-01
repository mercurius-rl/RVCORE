module lsunit (
	input	[6:0]	i_op,
	input	[2:0]	i_funct3,

	input	[31:0]	i_wdata,
	output	[31:0]	o_rdata,

	output	[31:0]	o_wdata,
	input	[31:0]	i_rdata
);

	function [31:0]	load (
		input	[6:0]	f_op,
		input	[2:0]	f_funct3,

		input	[31:0]	f_rdata
	);
		if ( f_op == 7'b0000011 ) begin
			case (f_funct3)
				3'b000:		load = {{24{f_rdata[7]}},f_rdata[7:0]};	// lb : load byte
				3'b001:		load = {{16{f_rdata[15]}},f_rdata[15:0]};	// lh : load half
				3'b010:		load = f_rdata;							// lw : load word
				3'b100:		load = {24'h0,f_rdata[7:0]};			// lbu: load byte unsigned
				3'b101:		load = {16'h0,f_rdata[15:0]};			// lhu: load half unsigned
				default:	load = 32'h00000000;
			endcase
		end
	endfunction

	function [31:0]	store (
		input	[6:0]	f_op,
		input	[2:0]	f_funct3,

		input	[31:0]	f_wdata
	);
		if ( f_op == 7'b0100011 ) begin
			case (f_funct3)
				3'b000:		store = {24'h0,f_wdata[7:0]};	// sb: store byte
				3'b001:		store = {16'h0,f_wdata[15:0]};	// sh: store half
				3'b010:		store = f_wdata;				// sw: store word
				default:	store = 32'h00000000;
			endcase
		end
	endfunction

	assign	o_wdata = store(i_op, i_funct3, i_wdata);	// store wired
	assign	o_rdata = load(i_op, i_funct3, i_rdata);	// load wired
	
endmodule