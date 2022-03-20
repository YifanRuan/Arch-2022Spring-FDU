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
    input logic clk,
    input execute_data_t dataE,
    output execute_data_t dataE_nxt
);
    always_ff @(posedge clk) begin
        dataE_nxt <= dataE;
    end
    
endmodule

`endif
