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
    always_comb begin
        if (pc > 0) begin
            ireq.addr = pc;
            ireq.valid = '1;
            imem_wait = ~iresp.data_ok;
            dataF_nxt.pc = pc;
            dataF_nxt.raw_instr = iresp.data;
            dataF_nxt.valid = iresp.data_ok;
        end else begin
            ireq = '0;
            imem_wait = '0;
            dataF_nxt = '0;
        end
    end

    predictpc predictpc(
        .pc,
        .raw_instr(dataF_nxt.raw_instr),
        .predPC
    );
    
endmodule

`endif
