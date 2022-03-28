`ifndef __EXECUTE_SV
`define __EXECUTE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "pipeline/execute/alu.sv"
`include "pipeline/execute/immgen.sv"
`else

`endif

module execute
    import common::*;
    import pipes::*;(
    input decode_data_t dataD,
    output execute_data_t dataE_nxt
);
    u64 a, b, imm, c;
    immgen immgen(
        .raw_instr(dataD.ctl.raw_instr),
        .ImmSel(dataD.ctl.ImmSel),
        .imm
    );
    assign a = dataD.ctl.ASel ? dataD.pc : dataD.rs1;
    assign b = dataD.ctl.BSel ? imm : dataD.rs2;
    alu alu(
        .a,
        .b,
        .alufunc(dataD.ctl.ALUSel),
        .c
    );
    assign dataE_nxt.pc = dataD.pc;
    assign dataE_nxt.ctl = dataD.ctl;
    assign dataE_nxt.rs2 = dataD.rs2;
    assign dataE_nxt.alu = c;
    
endmodule

`endif
