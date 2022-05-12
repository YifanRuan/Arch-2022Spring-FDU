`ifndef __EXECUTE_SV
`define __EXECUTE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "pipeline/execute/alu.sv"
`else

`endif

module execute
    import common::*;
    import pipes::*;(
    input decode_data_t dataD,
    output execute_data_t dataE_nxt,
    output u1 exe_wait
);
    wire BrLT = dataD.BrLT;
    u64 a, b;
    assign a = dataD.ctl.ASel ? dataD.pc : dataD.rs1;
    assign b = dataD.ctl.SltEn ? (BrLT ? 1 : 0) : (dataD.ctl.BSel ? dataD.imm : dataD.rs2);
    alu alu(
        .a,
        .b,
        .alufunc(dataD.ctl.ALUSel),
        .c(dataE_nxt.alu)
    );
    assign dataE_nxt.pc = dataD.pc;
    assign dataE_nxt.ctl = dataD.ctl;
    assign dataE_nxt.rs2 = dataD.rs2;
    assign dataE_nxt.valid = dataD.valid;

    assign exe_wait = '0;
    
endmodule

`endif
