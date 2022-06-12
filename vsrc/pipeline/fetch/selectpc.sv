`ifndef __SELECTPC_SV
`define __SELECTPC_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module selectpc
    import common::*;
    import pipes::*;(
    input u64 predPC,
    input u64 pc_address,
    input u1 PCSel,
    output u64 pc_selected,
    input u64 pc_csr,
    input u1 csr_flush
);
    assign pc_selected = csr_flush ? pc_csr : (PCSel ? pc_address : predPC);

endmodule

`endif
