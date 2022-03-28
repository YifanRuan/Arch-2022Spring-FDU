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
    output creg_addr_t wa,
    output u64 wd,
    output u1 wvalid
);
    assign wa = dataM.ctl.raw_instr[11:7];
    assign wd = dataM.result;
    assign wvalid = dataM.ctl.RegWEn;
    
endmodule

`endif
