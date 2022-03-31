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
            dataD.valid <= '0;
            dataD.ctl.wa <= '0;
            dataD.ctl.MemRW <= '0;
            dataD.ctl.PCSel <= '0;
            dataD.ctl.RegWEn <= '0;
            dataD.ctl.BrEq <= '0;
        end else begin
            dataD <= dataD_nxt;
        end
    end
    
endmodule

`endif
