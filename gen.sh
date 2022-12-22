#!/bin/bash

T=${1:?}

if [ 'n' = "$T" ]; then
    iverilog tb_core.v ncore.v alu.v aludec.v branch.v comp.v csr.v datapath.v decoder.v dmem.v icache.v pc.v regfile.v
fi

if [ 'p' = "$T" ]; then
    iverilog tb_core.v pcore.v alu.v aludec.v branch.v comp.v csr.v datapath.v decoder.v dmem.v icache.v pc.v regfile.v
fi

vvp a.out
gtkwave d.vcd