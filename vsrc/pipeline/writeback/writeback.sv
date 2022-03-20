`ifndef __WRITEBACK_SV
`define __WRITEBACK_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module writeback
    import common::*;
    import pipes::*;(
    input memory_data_t dataM,
    output creg_addr_t rd,
    output u64 result
);
    assign rd = dataM.ctl.raw_instr[11:7];
    assign result = dataM.result;
    
endmodule

`endif
