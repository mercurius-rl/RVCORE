IF %1==n iverilog tb_core.v ncore.v alu.v aludec.v branch.v comp.v lsunit.v csr.v decoder.v icache.v pc.v regfile.v malu.v vector/valu.v vector/vma.v vector/vector_ex.v cache.v dmem.v
IF %1==p iverilog tb_core.v pcore.v alu.v aludec.v branch.v comp.v lsunit.v csr.v datapath.v decoder.v icache.v pc.v regfile.v malu.v vector/valu.v vector/vma.v vector/vector_ex.v cache.v dmem.v
vvp a.out
gtkwave dump.vcd show.gtkw