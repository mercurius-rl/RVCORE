`timescale 1ns / 1ps
module branch(
	input	[6:0]	i_op,

	input	[31:0]	i_pc,
	input	[31:0]	i_imm,
	input	[31:0]	i_rs1,

	output	[31:0]	o_npc
);

	reg	[31:0]	r_npc;

	always @(*) begin
		if (i_op == 7'b1100011 || i_op == 7'b1101111) begin
			r_npc	<=	i_pc + i_imm;
		end else if (i_op == 7'b1100111) begin
			r_npc	<=	(i_rs1 + i_imm) & (~32'h3);
		end else begin
			r_npc	<=	0;
		end
	end

	assign	o_npc = r_npc;
endmodule
