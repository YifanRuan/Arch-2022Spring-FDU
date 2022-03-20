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
            default: begin
                
            end
        endcase
    end
    
endmodule

`endif
