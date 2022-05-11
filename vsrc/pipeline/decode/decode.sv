`ifndef __DECODE_SV
`define __DECODE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "pipeline/decode/decoder.sv"
`include "pipeline/decode/immgen.sv"
`else

`endif

module decode
    import common::*;
    import pipes::*;(
    input fetch_data_t dataF,
    output creg_addr_t ra1, ra2,
    output control_t ctl,
    output u64 d_pc,
    output u1 d_valid,
    output u64 imm
);
    decoder decoder(
        .raw_instr(dataF.raw_instr),
        .ctl
    );

    assign ra1 = ctl.ra1En ? dataF.raw_instr[19:15] : '0;
    assign ra2 = ctl.ra2En? dataF.raw_instr[24:20] : '0;
    assign d_pc = dataF.pc;
    assign d_valid = dataF.valid;

    immgen immgen(
        .raw_instr(dataF.raw_instr),
        .ImmSel(ctl.ImmSel),
        .imm
    );
    
endmodule

`endif
