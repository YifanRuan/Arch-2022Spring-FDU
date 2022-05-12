`ifndef __PCREG_SV
`define __PCREG_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`endif

module pcreg
    import common::*;
    import pipes::*;(
    input logic clk, reset,
    input u64 pc_nxt,
    input u2 PCWrite,
    output u64 pc
);
    always_ff @(posedge clk) begin
        if (reset) begin
            pc <= PCINIT;
        end else if (PCWrite == 0) begin
            pc <= pc_nxt;
        end
    end
    
endmodule

`endif
