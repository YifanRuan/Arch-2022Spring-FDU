`ifndef __FORWARD_SV
`define __FORWARD_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`endif

module forward
    import common::*;
    import pipes::*;(
    input creg_addr_t ra1, ra2, ewa, mwa, wa,
    input u64 rd1, rd2, alu, wd,
    output u64 rs1, rs2,

    input u1 is_next_load,
    output u1 decode_wait
);
    always_comb begin
        rs1 = '0;
        rs2 = '0;
        decode_wait = '0;
        if (ra1 != 0) begin
            if (ra1 == ewa) begin
                decode_wait = '1;
            end else if (ra1 == mwa) begin
                if (is_next_load) begin
                    decode_wait = '1;
                end else begin
                    rs1 = alu;
                end
            end else if (ra1 == wa) begin
                rs1 = wd;
            end else begin
                rs1 = rd1;
            end
        end
        if (ra2 != 0) begin
            if (ra2 == ewa) begin
                decode_wait = '1;
            end else if (ra2 == mwa) begin
                if (is_next_load) begin
                    decode_wait = '1;
                end else begin
                    rs2 = alu;
                end
            end else if (ra2 == wa) begin
                rs2 = wd;
            end else begin
                rs2 = rd2;
            end
        end
    end
    
endmodule

`endif
