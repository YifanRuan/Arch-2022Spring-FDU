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
    input logic clk, reset,
    input decode_data_t dataD_nxt,
    output decode_data_t dataD
);
    always_ff @(posedge clk) begin
        if (reset) begin
            dataD <= '0;
        end else begin
            dataD <= dataD_nxt;
        end
    end
    
endmodule

`endif
