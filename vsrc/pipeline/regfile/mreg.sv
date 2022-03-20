`ifndef __MREG_SV
`define __MREG_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module mreg
    import common::*;
    import pipes::*;(
    input logic clk,
    input memory_data_t dataM,
    output memory_data_t dataM_nxt
);
    always_ff @(posedge clk) begin
        dataM_nxt <= dataM;
    end
    
endmodule

`endif
