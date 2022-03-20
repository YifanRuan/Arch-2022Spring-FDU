`ifndef __FETCH_SV
`define __FETCH_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module fetch
    import common::*;
    import pipes::*;(
    input ibus_resp_t iresp,
    output ibus_req_t ireq,
    input u64 pc,
    output fetch_data_t dataF
);
    assign ireq.addr = pc;
    assign dataF.pc = pc;
    assign dataF.raw_instr = iresp.data;
    
endmodule

`endif
