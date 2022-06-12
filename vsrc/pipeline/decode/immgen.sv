`ifndef __IMMGEN_SV
`define __IMMGEN_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module immgen
    import common::*;
    import pipes::*;(
    input u32 raw_instr,
    input decode_op_t ImmSel,
    output u64 imm
);
    always_comb begin
        imm = '0;
        unique case (ImmSel)
            I: begin
                imm = {{52{raw_instr[31]}}, raw_instr[31:20]};
            end
            B: begin
                imm = {{52{raw_instr[31]}}, raw_instr[7], raw_instr[30:25], raw_instr[11:8], 1'b0};
            end
            U: begin
                imm = {{32{raw_instr[31]}}, raw_instr[31:12], 12'b0};
            end
            S: begin
                imm = {{52{raw_instr[31]}}, raw_instr[31:25], raw_instr[11:7]};
            end
            J: begin
                imm = {{44{raw_instr[31]}}, raw_instr[19:12], raw_instr[20], raw_instr[30:21], 1'b0};
            end
            CSR: begin
                imm = {59'b0, raw_instr[19:15]};
            end
            default: begin
                
            end
        endcase
    end
    
endmodule

`endif
