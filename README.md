RISC-V Core (part of RV32I) written in Verilog
===============================

- ver.0.1

There are simple RISC-V cores (single cycle and pipeline).

###Block Diagram of RV32I Pipelined Core
![Pipelined Core](image_rv32i_pipe.png)

License
========================================

Apache License (Version 2.0)  
http://www.apache.org/licenses/LICENSE-2.0  


Sample
========================================

If you want to simulation there cores, you must install Icarus-verilog and gtkwave.

Then you execute this command.


single core simulation
```
./gen.sh n

or

./gen.bat n
```

pipelined core simulation
```
./gen.sh p

or

./gen.bat p
```