`ifndef __EREG_SV
`define __EREG_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module ereg
    import common::*;
    import pipes::*;(
    input logic clk, reset,
    input execute_data_t dataE_nxt,
    output execute_data_t dataE
);
    always_ff @(posedge clk) begin
        if (reset) begin
            dataE <= '0;
        end else begin
            dataE <= dataE_nxt;
        end
    end
    
endmodule

`endif
