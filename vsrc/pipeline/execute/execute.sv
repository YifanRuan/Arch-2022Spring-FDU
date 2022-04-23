`ifndef __EXECUTE_SV
`define __EXECUTE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "pipeline/execute/alu.sv"
`include "pipeline/execute/immgen.sv"
`include "pipeline/execute/branchcomp.sv"
`else

`endif

module execute
    import common::*;
    import pipes::*;(
    input decode_data_t dataD,
    output execute_data_t dataE_nxt,
    output u1 PCSel
);
    u64 a, b, imm;
    u1 BrLT, BrEq;
    immgen immgen(
        .raw_instr(dataD.ctl.raw_instr),
        .ImmSel(dataD.ctl.ImmSel),
        .imm
    );
    branchcomp branchcomp(
        .rd1(dataD.rs1),
        .rd2((dataD.ctl.SltEn && dataD.ctl.BSel) ? imm : dataD.rs2),
        .BrUn(dataD.ctl.BrUn),
        .BrLT,
        .BrEq
    );
    always_comb begin
        PCSel = dataD.ctl.PCSel;
        if ((dataD.ctl.EqEn && ~(BrEq ^ dataD.ctl.EqSel)) || (dataD.ctl.LTEn && ~(BrLT ^ dataD.ctl.LTSel))) begin
            PCSel = '1;
        end
    end
    assign a = dataD.ctl.ASel ? dataD.pc : dataD.rs1;
    assign b = dataD.ctl.SltEn ? (BrLT ? 1 : 0) : (dataD.ctl.BSel ? imm : dataD.rs2);
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
    
endmodule

`endif
