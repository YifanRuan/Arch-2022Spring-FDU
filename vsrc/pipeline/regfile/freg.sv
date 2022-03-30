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
    input u2 FWrite,
    output fetch_data_t dataF
);
    always_ff @(posedge clk) begin
        if (reset || FWrite == 2'b01) begin
            dataF <= '0;
        end else if (FWrite == 2'b00) begin
            dataF <= dataF_nxt;
        end
    end
    
endmodule

`endif
