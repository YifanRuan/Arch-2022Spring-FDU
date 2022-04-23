`ifndef __MEMORY_SV
`define __MEMORY_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "pipeline/memory/readdata.sv"
`include "pipeline/memory/writedata.sv"
`else

`endif

module memory
    import common::*;
    import pipes::*;(
    input dbus_resp_t dresp,
    output dbus_req_t dreq,
    input execute_data_t dataE,
    output memory_data_t dataM_nxt,
    output u1 dmem_wait
);
    u64 wd;
    strobe_t strobe_write;
    writedata writedata(
        .addr(dataE.alu[2:0]),
        ._wd(dataE.rs2),
        .msize(dataE.ctl.msize),
        .wd,
        .strobe(strobe_write)
    );
    always_comb begin
        dreq = '0;
        unique case (dataE.ctl.MemRW)
            2'b10: begin
                dreq.valid = '1;
                dreq.strobe = '0;
                dreq.addr = dataE.alu;
                dreq.size = dataE.ctl.msize;
            end
            2'b11: begin
                dreq.valid = '1;
                dreq.strobe = strobe_write;
                dreq.addr = dataE.alu;
                dreq.data = wd;
                dreq.size = dataE.ctl.msize;
            end
            default: begin
                dreq.valid = '0;
                dreq.strobe = '0;
            end
        endcase
    end

    assign dmem_wait = dreq.valid && ~dresp.data_ok;

    u64 rd;
    readdata readdata(
        ._rd(dresp.data),
        .rd,
        .addr(dataE.alu[2:0]),
        .msize(dataE.ctl.msize),
        .mem_unsigned(dataE.ctl.mem_unsigned)
    );
    
    
    assign dataM_nxt.ctl = dataE.ctl;
    assign dataM_nxt.pc = dataE.pc;
    assign dataM_nxt.valid = dataE.valid;
    assign dataM_nxt.addr31 = dataE.alu[31];
    always_comb begin
        dataM_nxt.result = '0;
        unique case (dataE.ctl.WBSel)
            2'b00: dataM_nxt.result = rd;
            2'b01: dataM_nxt.result = dataE.alu;
            2'b10: dataM_nxt.result = dataE.pc + 4;
            default: begin
                
            end
        endcase
    end


endmodule

`endif
