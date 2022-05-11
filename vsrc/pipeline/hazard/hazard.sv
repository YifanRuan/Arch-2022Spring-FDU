`ifndef __HAZARD_SV
`define __HAZARD_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`endif

module hazard
    import common::*;
    import pipes::*;(
    input u1 PCSel,
    input u1 imem_wait, dmem_wait,
    output u2 PCWrite, FWrite, DWrite, EWrite, MWrite // 2'b00: stream; 2'b01: flush; others: keep
);
    always_comb begin
        PCWrite = '0;
        FWrite = '0;
        DWrite = '0;
        EWrite = '0;
        MWrite = '0;
        if (dmem_wait) begin
            MWrite = 2'b01;
            EWrite = 2'b11;
            DWrite = 2'b11;
            FWrite = 2'b11;
            PCWrite = 2'b11;
        end else if (imem_wait) begin
            PCWrite = 2'b11;
            if (PCSel) begin
                FWrite = 2'b11;
                DWrite = 2'b01;
            end else begin
                FWrite = 2'b01;
            end
        end else if (PCSel) begin
            PCWrite = 2'b00;
            FWrite = 2'b01;
        end
    end
    
endmodule

`endif
