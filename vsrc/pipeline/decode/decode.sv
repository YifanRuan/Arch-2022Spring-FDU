`ifndef __DECODE_SV
`define __DECODE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "pipeline/decode/decoder.sv"
`include "pipeline/decode/immgen.sv"
`include "pipeline/decode/branchcomp.sv"
`else

`endif

module decode
    import common::*;
    import pipes::*;(
    input u64 rs1, rs2,
    output creg_addr_t ra1, ra2,
    input fetch_data_t dataF,
    output decode_data_t dataD_nxt,
    input u64 last_pc,
    output u1 PCSel,
    output u64 pc_address
);
    control_t ctl;
    decoder decoder(
        .raw_instr(dataF.raw_instr),
        .ctl
    );

    assign ra1 = ctl.ra1En ? dataF.raw_instr[19:15] : '0;
    assign ra2 = ctl.ra2En? dataF.raw_instr[24:20] : '0;
    assign dataD_nxt.pc = dataF.pc;
    assign dataD_nxt.valid = dataF.valid;
    assign dataD_nxt.ctl = ctl;

    u1 BrLT, BrEq;
    immgen immgen(
        .raw_instr(ctl.raw_instr),
        .ImmSel(ctl.ImmSel),
        .imm(dataD_nxt.imm)
    );

    branchcomp branchcomp(
        .rd1(rs1),
        .rd2((ctl.SltEn && ctl.BSel) ? dataD_nxt.imm : rs2),
        .BrUn(ctl.BrUn),
        .BrLT,
        .BrEq
    );
    always_comb begin
        pc_address = '0;
        PCSel = '0;
        if (ctl.EqEn || ctl.LTEn) begin
            if ((ctl.EqEn && ~(BrEq ^ ctl.EqSel)) || (ctl.LTEn && ~(BrLT ^ ctl.LTSel))) begin
                pc_address = dataF.pc + dataD_nxt.imm;
            end else begin
                pc_address = dataF.pc + 4;
            end
            if (pc_address != last_pc) begin
                PCSel = '1;
            end
        end else if (ctl.PCSel) begin
            PCSel = '1;
            pc_address = (rs1 + dataD_nxt.imm) & ~1;
        end else if (ctl.MemRW[1]) begin
            PCSel = '1;
            pc_address = dataF.pc + 4;
        end
    end
    
endmodule

`endif
