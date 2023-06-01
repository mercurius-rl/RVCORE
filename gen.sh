#!/bin/bash

T=${1:?}

if [ 'n' = "$T" ]; then
    iverilog iverilog tb_core.v ncore.v alu.v aludec.v branch.v comp.v lsunit.v csr.v decoder.v icache.v pc.v regfile.v malu.v vector/valu.v vector/vma.v vector/vector_ex.v 
fi

if [ 'p' = "$T" ]; then
    iverilog iverilog tb_core.v pcore.v alu.v aludec.v branch.v comp.v lsunit.v csr.v datapath.v decoder.v icache.v pc.v regfile.v malu.v vector/valu.v vector/vma.v vector/vector_ex.v 
fi

vvp a.out
gtkwave d.vcd