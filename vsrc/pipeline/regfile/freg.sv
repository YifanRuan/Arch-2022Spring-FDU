`ifndef __FREG_SV
`define __FREG_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module freg
    import common::*;
    import pipes::*;(
    input logic clk, reset,
    input fetch_data_t dataF_nxt,
    output fetch_data_t dataF
);
    always_ff @(posedge clk) begin
        if (reset) begin
            dataF <= '0;
        end else begin
            dataF <= dataF_nxt;
        end
    end
    
endmodule

`endif