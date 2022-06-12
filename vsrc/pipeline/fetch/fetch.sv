`ifndef __FETCH_SV
`define __FETCH_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "pipeline/fetch/predictpc.sv"
`else

`endif

module fetch
    import common::*;
    import pipes::*;(
    input ibus_resp_t iresp,
    output ibus_req_t ireq,

    input u64 pc,
    output fetch_data_t dataF_nxt,
    output u1 imem_wait,
    output u64 predPC
);
    u1 instr_misalign;
    assign instr_misalign = ~(pc[1:0] == 2'b00);
    
    assign ireq.addr = pc;
    assign ireq.valid = ~instr_misalign;
    assign imem_wait = ~iresp.data_ok & ~instr_misalign;
    assign dataF_nxt.pc = pc;
    assign dataF_nxt.raw_instr = iresp.data;
    assign dataF_nxt.valid = iresp.data_ok;
    assign dataF_nxt.instr_misalign = instr_misalign;

    predictpc predictpc(
        .pc,
        .raw_instr(dataF_nxt.raw_instr),
        .predPC
    );
    
endmodule

`endif
