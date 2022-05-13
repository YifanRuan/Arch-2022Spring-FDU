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
    input u2 DWrite,
    input decode_data_t dataD_nxt,
    output decode_data_t dataD
);
    always_ff @(posedge clk) begin
        if (reset || DWrite == 2'b01) begin
            dataD <= '0;
        end else if (DWrite == 2'b00) begin
            dataD <= dataD_nxt;
        end else if (DWrite == 2'b11) begin
            dataD.stalled <= '1;
        end
    end
    
endmodule

`endif
