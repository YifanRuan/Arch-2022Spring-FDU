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
    input logic clk, reset,
    input dbus_resp_t dresp,
    output dbus_req_t dreq,
    input execute_data_t dataE,
    output memory_data_t dataM_nxt,
    output u1 dmem_wait,
    input u1 csr_flush
);
    u64 wd;
    strobe_t strobe_write;

    u1 valid, valid_nxt;
    u1 memory_misalign;

    always_comb begin
        memory_misalign = '0;
        unique case(dataE.ctl.msize)
            MSIZE1: begin
                memory_misalign = '0;
            end
            MSIZE2: begin
                memory_misalign = ~(dataE.alu[0] == '0);
            end
            MSIZE4: begin
                memory_misalign = ~(dataE.alu[1:0] == '0);
            end
            MSIZE8: begin
                memory_misalign = ~(dataE.alu[2:0] == '0);
            end
            default: begin
                
            end
        endcase
    end

    writedata writedata(
        .addr(dataE.alu[2:0]),
        ._wd(dataE.rs2),
        .msize(dataE.ctl.msize),
        .wd,
        .strobe(strobe_write)
    );

    wire flush = csr_flush & ~valid;
    always_comb begin
        dreq = '0;
        unique case (dataE.ctl.MemRW)
            2'b10: begin
                dreq.valid = ~flush & ~memory_misalign;
                dreq.strobe = '0;
                dreq.addr = dataE.alu;
                dreq.size = dataE.ctl.msize;
            end
            2'b11: begin
                dreq.valid = ~flush & ~memory_misalign;
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

    assign valid_nxt = dreq.valid;

    always_ff @(posedge clk) begin
        if (reset) begin
            valid <= '0;
        end else begin
            valid <= valid_nxt;
        end
    end


    u64 rd;
    readdata readdata(
        ._rd(dresp.data),
        .rd,
        .addr(dataE.alu[2:0]),
        .msize(dataE.ctl.msize),
        .mem_unsigned(dataE.ctl.mem_unsigned)
    );

    always_comb begin
        dataM_nxt.ctl = dataE.ctl;
        dmem_wait = dreq.valid & ~dresp.data_ok;
        unique case (dataE.ctl.MemRW)
            2'b10: if (memory_misalign) begin
                dataM_nxt.ctl.csr.is_csr = 1'b1;
                dataM_nxt.ctl.csr.is_err = 1'b1;
                dataM_nxt.ctl.csr.load_misalign = 1'b1;
            end
            2'b11: if (memory_misalign) begin
                dataM_nxt.ctl.csr.is_csr = 1'b1;
                dataM_nxt.ctl.csr.is_err = 1'b1;
                dataM_nxt.ctl.csr.store_misalign = 1'b1;
            end
            default: begin

            end
        endcase
    end

    assign dataM_nxt.pc = dataE.pc;
    assign dataM_nxt.valid = dataE.valid;
    assign dataM_nxt.addr31 = dataE.alu[31];
    assign dataM_nxt.result = dataE.ctl.WBSel ? dataE.alu : rd;

endmodule

`endif
