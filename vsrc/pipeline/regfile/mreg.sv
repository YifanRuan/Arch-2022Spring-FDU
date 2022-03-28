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
    input logic clk, reset,
    input memory_data_t dataM_nxt,
    output memory_data_t dataM
);
    always_ff @(posedge clk) begin
        if (reset) begin
            dataM <= '0;
        end else begin
            dataM <= dataM_nxt;
        end
    end
    
endmodule

`endif
