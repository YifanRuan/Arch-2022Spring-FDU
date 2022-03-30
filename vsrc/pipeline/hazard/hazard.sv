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
    input creg_addr_t ra1, ra2, ewa, mwa, wa,
    output u2 PCWrite, FWrite, DWrite // 2'b00: stream; 2'b01: flush; others: keep
);
    always_comb begin
        if (PCSel) begin
            PCWrite = 2'b00;
            FWrite = 2'b01;
            DWrite = 2'b01;
        end else if (ra1 != 0 && (ra1 == ewa || ra1 == mwa || ra1 == wa) || 
                    ra2 != 0 && (ra2 == ewa || ra2 == mwa || ra2 == wa)) begin
            PCWrite = 2'b11;
            FWrite = 2'b11;
            DWrite = 2'b01;
        end else begin
            PCWrite = '0;
            FWrite = '0;
            DWrite = '0;
        end
    end
    
endmodule

`endif
