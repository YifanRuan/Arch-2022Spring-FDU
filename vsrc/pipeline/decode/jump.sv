`ifndef __JUMP_SV
`define __JUMP_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "pipeline/decode/branchcomp.sv"
`endif

module jump
    import common::*;
    import pipes::*;(
    input u64 rs1, rs2,
    input control_t ctl,
    input u64 d_pc,
    input u1 d_valid,
    input u64 imm,
    output decode_data_t dataD_nxt,
    input u64 last_pc,
    output u1 PCSel,
    output u64 pc_address
);
    assign dataD_nxt.ctl = ctl;
    assign dataD_nxt.pc = d_pc;
    assign dataD_nxt.imm = imm;
    assign dataD_nxt.rs1 = rs1;
    assign dataD_nxt.rs2 = rs2;
    assign dataD_nxt.valid = d_valid;

    u1 BrLT, BrEq;
    branchcomp branchcomp(
        .rd1(rs1),
        .rd2((ctl.SltEn && ctl.BSel) ? imm : rs2),
        .BrUn(ctl.BrUn),
        .BrLT,
        .BrEq
    );
    always_comb begin
        pc_address = '0;
        PCSel = '0;
        if (ctl.EqEn || ctl.LTEn) begin
            if ((ctl.EqEn && ~(BrEq ^ ctl.EqSel)) || (ctl.LTEn && ~(BrLT ^ ctl.LTSel))) begin
                pc_address = d_pc + dataD_nxt.imm;
            end else begin
                pc_address = d_pc + 4;
            end
            if (pc_address != last_pc) begin
                PCSel = '1;
            end
        end else if (ctl.PCSel) begin
            PCSel = '1;
            pc_address = (rs1 + dataD_nxt.imm) & ~1;
        end else if (ctl.MemRW[1]) begin
            PCSel = '1;
            pc_address = d_pc + 4;
        end
    end
    
endmodule

`endif
