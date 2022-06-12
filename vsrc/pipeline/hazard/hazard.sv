`ifndef __HAZARD_SV
`define __HAZARD_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`endif

module hazard
    import common::*;
    import pipes::*;(
    input u1 PCSel, imem_wait, dmem_wait, decode_wait, exe_wait, csr_flush,
    output u1 is_stall,
    output u2 PCWrite, FWrite, DWrite, EWrite, MWrite // 2'b00: stream; 2'b01: flush; others: keep
);
    always_comb begin
        MWrite = '0;
        EWrite = '0;
        DWrite = '0;
        FWrite = '0;
        PCWrite = '0;
        is_stall = '0;
        if (dmem_wait) begin
            MWrite = 2'b01;
            EWrite = 2'b11;
            DWrite = 2'b11;
            FWrite = 2'b11;
            PCWrite = 2'b11;
        end else if (exe_wait) begin
            EWrite = 2'b01;
            DWrite = 2'b11;
            FWrite = 2'b11;
            PCWrite = 2'b11;
        end else if (decode_wait) begin
            DWrite = 2'b01;
            FWrite = 2'b11;
            PCWrite = 2'b11;
        end else if (imem_wait) begin
            PCWrite = 2'b11;
            if (PCSel) begin
                DWrite = 2'b01;
                FWrite = 2'b11;
            end else begin
                FWrite = 2'b01;
            end
        end else if (PCSel) begin
            FWrite = 2'b01;
        end
        if (csr_flush) begin
            if (dmem_wait) begin
                MWrite = 2'b11;
                EWrite = 2'b11;
                DWrite = 2'b01;
                FWrite = 2'b01;
                PCWrite = 2'b11;
                is_stall = 1'b1;
            end else if (imem_wait) begin
                MWrite = 2'b11;
                EWrite = 2'b01;
                DWrite = 2'b01;
                FWrite = 2'b01;
                PCWrite = 2'b11;
                is_stall = 1'b1;
            end else begin
                MWrite = 2'b01;
                EWrite = 2'b01;
                DWrite = 2'b01;
                FWrite = 2'b01;
                PCWrite = 2'b00;
            end
        end
    end
    
endmodule

`endif
