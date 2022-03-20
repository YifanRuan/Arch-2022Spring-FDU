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
    input logic clk,
    input fetch_data_t dataF,
    output fetch_data_t dataF_nxt
);
    always_ff @(posedge clk) begin
        dataF_nxt <= dataF;
    end
    
endmodule

`endif
