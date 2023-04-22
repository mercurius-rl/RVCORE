IF %1==n iverilog tb_core.v ncore.v alu.v aludec.v branch.v comp.v csr.v datapath.v decoder.v dmem.v icache.v pc.v regfile.v malu.v vector/valu.v vector/vma.v vector/vector_ex.v 
IF %1==p iverilog tb_core.v pcore.v alu.v aludec.v branch.v comp.v csr.v datapath.v decoder.v dmem.v icache.v pc.v regfile.v malu.v vector/valu.v vector/vma.v vector/vector_ex.v 
vvp a.out
gtkwave d.vcd