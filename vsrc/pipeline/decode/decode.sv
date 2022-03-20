`ifndef __DECODE_SV
`define __DECODE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "pipeline/decode/decoder.sv"
`else

`endif

module decode
    import common::*;
    import pipes::*;(
    input word_t rd1, rd2,
    output creg_addr_t ra1, ra2,
    input fetch_data_t dataF,
    output decode_data_t dataD 
);
    control_t ctl;
    decoder decoder(
        .raw_instr(dataF.raw_instr),
        .ctl
    );

    assign ra1 = dataF.raw_instr[19:15];
    assign ra2 = dataF.raw_instr[24:20];
    assign dataD.rs1 = rd1;
    assign dataD.rs2 = rd2;
    assign dataD.ctl = ctl;
    assign dataD.pc = dataF.pc;
    
endmodule

`endif
