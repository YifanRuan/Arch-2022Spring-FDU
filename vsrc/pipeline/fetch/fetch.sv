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
    fetch_data_t dataF_latch;

    always_comb begin
        ireq = '0;
        if (pc > 0) begin
            if (dataF_latch.pc != pc) begin
                ireq.addr = pc;
                ireq.valid = '1;
                imem_wait = ~iresp.data_ok;
                dataF_nxt.pc = pc;
                dataF_nxt.raw_instr = iresp.data;
                dataF_nxt.valid = iresp.data_ok;
            end else begin
                imem_wait = '0;
                dataF_nxt = dataF_latch;
            end
        end else begin
            imem_wait = '0;
            dataF_nxt = '0;
        end
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            dataF_latch <= '0;
        end else if (~imem_wait) begin
            dataF_latch <= dataF_nxt;
        end
    end

    predictpc predictpc(
        .pc,
        .raw_instr(dataF_nxt.raw_instr),
        .predPC
    );
    
endmodule

`endif
