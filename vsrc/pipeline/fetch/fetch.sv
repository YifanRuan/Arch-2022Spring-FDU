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
    output u64 predPC,

    input logic clk, reset
);
    assign ireq.addr = (pc > 0) ? pc : '0;
    assign ireq.valid = (pc > 0) ? '1 : '0;
    assign imem_wait = (pc > 0) ? ~iresp.data_ok : '0;
    assign dataF_nxt.pc = pc;
    assign dataF_nxt.raw_instr = (pc > 0) ? iresp.data : '0;
    assign dataF_nxt.valid = (pc > 0) ? iresp.data_ok : '0;

    predictpc predictpc(
        .pc,
        .raw_instr(dataF_nxt.raw_instr),
        .predPC
    );
    
endmodule

`endif
