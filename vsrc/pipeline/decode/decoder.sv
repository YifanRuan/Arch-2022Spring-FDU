`ifndef __DECODER_SV
`define __DECODER_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module decoder
    import common::*;
    import pipes::*;(
    input u32 raw_instr,
    output control_t ctl
);
    wire [6:0] opcode = raw_instr[6:0];
    wire [2:0] funct3 = raw_instr[14:12];
    wire [6:0] funct7 = raw_instr[31:25];

    always_comb begin
        ctl = '0;
        unique case (opcode)
            OP_RI: begin
                ctl.ImmSel = J;
                ctl.RegWEn = 1'b1;
                ctl.BSel = 1'b01;
                ctl.WBSel = 2'b01;
                unique case (funct3)
                    F3_ADDI: begin
                        ctl.ALUSel = ALU_ADD;
                    end
                    F3_XORI: begin
                        ctl.ALUSel = ALU_XOR;
                    end
                    F3_ORI: begin
                        ctl.ALUSel = ALU_OR;
                    end
                    F3_ANDI: begin
                        ctl.ALUSel = ALU_AND;
                    end
                    default: begin
                        
                    end
                endcase
            end
            default: begin
                
            end
        endcase
    end
    
endmodule

`endif
