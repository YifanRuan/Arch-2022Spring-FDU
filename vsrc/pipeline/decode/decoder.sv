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
        ctl.raw_instr = raw_instr;
        unique case (opcode)
            OP_RI: begin
                ctl.ImmSel = I;
                ctl.RegWEn = 1'b1;
                ctl.BSel = 1'b1;
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
            OP_LUI: begin
                ctl.ImmSel = U;
                ctl.RegWEn = 1'b1;
                ctl.BSel = 1'b1;
                ctl.WBSel = 2'b01;
                ctl.ALUSel = ALU_B;
            end
            OP_R: begin
                ctl.RegWEn = 1'b1;
                ctl.WBSel = 2'b01;
                unique case (funct3)
                    F3_ADD: begin
                        unique case (funct7)
                            F7_ADD: begin
                                ctl.ALUSel = ALU_ADD;
                            end
                            F7_SUB: begin
                                ctl.ALUSel = ALU_SUB;
                            end
                            default: begin
                                
                            end
                        endcase
                    end
                    F3_XOR: begin
                        ctl.ALUSel = ALU_XOR;
                    end
                    F3_OR: begin
                        ctl.ALUSel = ALU_OR;
                    end
                    F3_AND: begin
                        ctl.ALUSel = ALU_AND;
                    end
                    default: begin
                        
                    end
                endcase
            end
            OP_L: begin
                unique case (funct3)
                    F3_LD: begin
                        ctl.ImmSel = I;
                        ctl.RegWEn = 1'b1;
                        ctl.BSel = 1'b1;
                        ctl.MemRW = 2'b10;
                        ctl.ALUSel = ALU_ADD;
                    end
                    default: begin
                        
                    end
                endcase
            end
            OP_S: begin
                unique case (funct3)
                    F3_SD: begin
                        ctl.ImmSel = S;
                        ctl.BSel = 1'b1;
                        ctl.ALUSel = ALU_ADD;
                        ctl.MemRW = 2'b11;
                    end
                    default: begin
                        
                    end
                endcase
            end
            OP_B: begin
                unique case (funct7)
                    F3_BEQ: begin
                        ctl.PCSel = ctl.BrEq;
                        ctl.ImmSel = B;
                        ctl.ALUSel = ALU_ADD;
                        ctl.BSel = 1'b1;
                        ctl.ASel = 1'b1;
                    end
                    default: begin
                        
                    end
                endcase
            end
            OP_AUIPC: begin
                ctl.PCSel = 1'b1;
                ctl.ImmSel = U;
                ctl.RegWEn = 1'b1;
                ctl.BSel = 1'b1;
                ctl.ASel = 1'b1;
                ctl.ALUSel = ALU_ADD;
                ctl.WBSel = 2'b01;
            end
            OP_JAL: begin
                ctl.ImmSel = J;
                ctl.PCSel = 1'b1;
                ctl.RegWEn = 1'b1;
                ctl.BSel = 1'b1;
                ctl.ASel = 1'b1;
                ctl.WBSel = 2'b10;
                ctl.ALUSel = ALU_ADD;
            end
            OP_JALR: begin
                ctl.ImmSel = I;
                ctl.PCSel = 1'b1;
                ctl.RegWEn = 1'b1;
                ctl.BSel = 1'b1;
                ctl.WBSel = 2'b10;
                ctl.ALUSel = ALU_ADD_CLEAR;
            end
            default: begin
                
            end
        endcase
    end
    
endmodule

`endif
