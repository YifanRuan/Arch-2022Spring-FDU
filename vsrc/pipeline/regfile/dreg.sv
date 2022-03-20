`ifndef __DREG_SV
`define __DREG_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module dreg
    import common::*;
    import pipes::*;(
    input logic clk,
    input decode_data_t dataD,
    output decode_data_t dataD_nxt
);
    always_ff @(posedge clk) begin
        dataD_nxt <= dataD;
    end
    
endmodule

`endif
