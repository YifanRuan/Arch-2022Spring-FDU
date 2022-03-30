`ifndef __BRANCHCOMP_SV
`define __BRANCHCOMP_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`endif

module branchcomp
    import common::*;
    import pipes::*;(
    input u64 rd1, rd2, BrEq, PCSel_nxt,
    output u1 PCSel
);
    always_comb begin
        if (BrEq) begin
            PCSel = rd1 == rd2? 1 : 0;
        end else begin
            PCSel = PCSel_nxt;
        end
    end
    
endmodule

`endif
