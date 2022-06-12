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
    output u1 wvalid,

    output csr_addr_t csr_wa,
    output u64 csr_wd,
    output u1 csr_valid,

    output u1 csr_flush,
    input u1 is_int
);
    always_comb begin
        wa = '0;
        wd = '0;
        wvalid = '0;
        csr_wa = '0;
        csr_wd = '0;
        csr_valid = '0;
        csr_flush = '0;
        if (dataM.ctl.csr.is_csr) begin
            csr_flush = 1;
            if (~dataM.ctl.csr.is_err & ~dataM.ctl.csr.is_mret) begin
                csr_wa = dataM.ctl.csr.csr;
                csr_wd = dataM.result;
                csr_valid = 1;
                wa = dataM.ctl.wa;
                wd = dataM.ctl.csr.csrs;
                wvalid = dataM.ctl.RegWEn;
            end
        end else if (is_int) begin
            csr_flush = 1;
        end else begin
            wa = dataM.ctl.wa;
            wd = dataM.result;
            wvalid = dataM.ctl.RegWEn;
        end
    end
    
endmodule

`endif
