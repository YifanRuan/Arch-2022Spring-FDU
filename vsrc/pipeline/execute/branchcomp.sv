`ifndef __BRANCHCOMP_SV
`define __BRANCHCOMP_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`endif

module branchcomp
    import common::*;
    import pipes::*;(
    input u64 rd1, rd2,
    input u1 BrUn,
    output u1 BrEq, BrLT
);
    assign BrEq = rd1 == rd2 ? 1 : 0;
    assign BrLT = BrUn ? (rd1 < rd2 ? 1 : 0) : ($signed(rd1) < $signed(rd2) ? 1 : 0);
    
endmodule

`endif
