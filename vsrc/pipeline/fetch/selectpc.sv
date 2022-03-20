`ifndef __SELECT_PC
`define __SELECT_PC

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module selectpc
    import common::*;
    import pipes::*;(
    input u64 pcplus4,
    output u64 pc_selected
);
    assign pc_selected = pcplus4;

endmodule

`endif
