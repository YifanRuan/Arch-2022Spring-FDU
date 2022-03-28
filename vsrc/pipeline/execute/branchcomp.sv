`ifndef __BRANCHCOMP_SV
`define __BRANCHCOMP_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`endif

module branchcomp
    import common::*;
    import pipes::*;(
    input u64 a, b
    output u1 BrEq
);
    assign BrEq = a == b ? 1 : 0;
    
endmodule

`endif
