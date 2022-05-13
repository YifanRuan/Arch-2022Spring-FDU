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
    wire [5:0] funct6 = raw_instr[31:26];
    

    always_comb begin
        ctl = '0;
        ctl.raw_instr = raw_instr;
        unique case (opcode)
            OP_LUI: begin
                ctl.ImmSel = U;
                ctl.RegWEn = 1'b1;
                ctl.BSel = 1'b1;
                ctl.WBSel = 2'b01;
                ctl.ALUSel = ALU_B;
                ctl.wa = raw_instr[11:7];
            end
            OP_L: begin
                ctl.ImmSel = I;
                ctl.RegWEn = 1'b1;
                ctl.BSel = 1'b1;
                ctl.MemRW = 2'b10;
                ctl.ALUSel = ALU_ADD;
                ctl.wa = raw_instr[11:7];
                ctl.ra1En = 1'b1;
                ctl.loadEn = 1'b1;
                unique case (funct3)
                    F3_LB: begin
                        ctl.msize = MSIZE1;
                    end
                    F3_LH: begin
                        ctl.msize = MSIZE2;
                    end
                    F3_LW: begin
                        ctl.msize = MSIZE4;
                    end
                    F3_LD: begin
                        ctl.msize = MSIZE8;
                    end
                    F3_LBU: begin
                        ctl.msize = MSIZE1;
                        ctl.mem_unsigned = 1'b1;
                    end
                    F3_LHU: begin
                        ctl.msize = MSIZE2;
                        ctl.mem_unsigned = 1'b1;
                    end
                    F3_LWU: begin
                        ctl.msize = MSIZE4;
                        ctl.mem_unsigned = 1'b1;
                    end
                    default: begin
                        
                    end
                endcase
            end
            OP_B: begin
                ctl.ImmSel = B;
                ctl.BSel = 1'b1;
                ctl.ASel = 1'b1;
                ctl.ra1En = 1'b1;
                ctl.ra2En = 1'b1;
                unique case (funct3)
                    F3_BEQ: begin
                        ctl.EqEn = 1'b1;
                        ctl.EqSel = 1'b1;
                    end
                    F3_BNE: begin
                        ctl.EqEn = 1'b1;
                    end
                    F3_BLT: begin
                        ctl.LTEn = 1'b1;
                        ctl.LTSel = 1'b1;
                    end
                    F3_BGE: begin
                        ctl.LTEn = 1'b1;
                    end
                    F3_BLTU: begin
                        ctl.BrUn = 1'b1;
                        ctl.LTEn = 1'b1;
                        ctl.LTSel = 1'b1;
                    end
                    F3_BGEU: begin
                        ctl.BrUn = 1'b1;
                        ctl.LTEn = 1'b1;
                    end
                    default: begin
                        
                    end
                endcase
            end
            OP_S: begin
                ctl.ImmSel = S;
                ctl.BSel = 1'b1;
                ctl.ALUSel = ALU_ADD;
                ctl.MemRW = 2'b11;
                ctl.ra1En = 1'b1;
                ctl.ra2En = 1'b1;
                unique case (funct3)
                    F3_SB: begin
                        ctl.msize = MSIZE1;
                    end
                    F3_SH: begin
                        ctl.msize = MSIZE2;
                    end
                    F3_SW: begin
                        ctl.msize = MSIZE4;
                    end
                    F3_SD: begin
                        ctl.msize = MSIZE8;
                    end
                    default: begin
                        
                    end
                endcase
            end
            OP_AUIPC: begin
                ctl.ImmSel = U;
                ctl.RegWEn = 1'b1;
                ctl.BSel = 1'b1;
                ctl.ASel = 1'b1;
                ctl.ALUSel = ALU_ADD;
                ctl.WBSel = 2'b01;
                ctl.wa = raw_instr[11:7];
            end
            OP_RI: begin
                ctl.ImmSel = I;
                ctl.RegWEn = 1'b1;
                ctl.BSel = 1'b1;
                ctl.WBSel = 2'b01;
                ctl.wa = raw_instr[11:7];
                ctl.ra1En = 1'b1;
                unique case (funct3)
                    F3_ADDI: begin
                        ctl.ALUSel = ALU_ADD;
                    end
                    F3_SLLI: begin
                        ctl.ALUSel = ALU_LEFT6;
                    end
                    F3_SLTI: begin
                        ctl.ALUSel = ALU_B;
                        ctl.SltEn = 1'b1;
                    end
                    F3_SLTIU: begin
                        ctl.ALUSel = ALU_B;
                        ctl.SltEn = 1'b1;
                        ctl.BrUn = 1'b1;
                    end
                    F3_XORI: begin
                        ctl.ALUSel = ALU_XOR;
                    end
                    F3_SRLI: begin
                        unique case (funct6)
                            F7_SRLI: begin
                                ctl.ALUSel = ALU_RIGHT6;
                            end
                            F7_SRAI: begin
                                ctl.ALUSel = ALU_RIGHT6_SEXT;
                            end
                            default: begin
                                
                            end
                        endcase
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
            OP_R: begin
                ctl.RegWEn = 1'b1;
                ctl.WBSel = 2'b01;
                ctl.wa = raw_instr[11:7];
                ctl.ra1En = 1'b1;
                ctl.ra2En = 1'b1;
                unique case (funct3)
                    F3_ADD: begin
                        unique case (funct7)
                            F7_ADD: begin
                                ctl.ALUSel = ALU_ADD;
                            end
                            F7_SUB: begin
                                ctl.ALUSel = ALU_SUB;
                            end
                            F7_MUL: begin
                                ctl.multiplyEn = 2'b01;
                            end
                            default: begin
                                
                            end
                        endcase
                    end
                    F3_SLL: begin
                        ctl.ALUSel = ALU_LEFT6;
                    end
                    F3_SLT: begin
                        ctl.ALUSel = ALU_B;
                        ctl.SltEn = 1'b1;
                    end
                    F3_SLTU: begin
                        ctl.ALUSel = ALU_B;
                        ctl.SltEn = 1'b1;
                        ctl.BrUn = 1'b1;
                    end
                    F3_XOR: begin
                        unique case (funct7)
                            F7_XOR: begin
                                ctl.ALUSel = ALU_XOR;
                            end
                            F7_DIV: begin
                                ctl.divideEn = 4'b0100;
                            end
                            default: begin
                                
                            end
                        endcase
                    end
                    F3_SRL: begin
                        unique case (funct7)
                            F7_SRL: begin
                                ctl.ALUSel = ALU_RIGHT6;
                            end
                            F7_SRA: begin
                                ctl.ALUSel = ALU_RIGHT6_SEXT;
                            end
                            F7_DIVU: begin
                                ctl.divideEn = 4'b0101;
                            end
                            default: begin
                                
                            end
                        endcase
                    end
                    F3_OR: begin
                        unique case (funct7)
                            F7_OR: begin
                                ctl.ALUSel = ALU_OR;
                            end
                            F7_REM: begin
                                ctl.divideEn = 4'b0110;
                            end
                            default: begin
                                
                            end
                        endcase
                    end
                    F3_AND: begin
                        unique case (funct7)
                            F7_AND: begin
                                ctl.ALUSel = ALU_AND;
                            end
                            F7_REMU: begin
                                ctl.divideEn = 4'b0111;
                            end
                            default: begin
                                
                            end
                        endcase
                    end
                    default: begin
                        
                    end
                endcase
            end
            OP_RIW: begin
                ctl.ImmSel = I;
                ctl.RegWEn = 1'b1;
                ctl.BSel = 1'b1;
                ctl.WBSel = 2'b01;
                ctl.wa = raw_instr[11:7];
                ctl.ra1En = 1'b1;
                unique case (funct3)
                    F3_ADDIW: begin
                        ctl.ALUSel = ALU_ADD32;
                    end
                    F3_SLLIW: begin
                        ctl.ALUSel = ALU_LEFT32;
                    end
                    F3_SRLIW: begin
                        unique case (funct7)
                            F7_SRLIW: begin
                                ctl.ALUSel = ALU_RIGHT32;
                            end
                            F7_SRAIW: begin
                                ctl.ALUSel = ALU_RIGHT32_SEXT;
                            end
                            default: begin
                                
                            end
                        endcase
                    end
                    default: begin
                        
                    end
                endcase
            end
            OP_RW: begin
                ctl.RegWEn = 1'b1;
                ctl.WBSel = 2'b01;
                ctl.wa = raw_instr[11:7];
                ctl.ra1En = 1'b1;
                ctl.ra2En = 1'b1;
                unique case (funct3)
                    F3_ADDW: begin
                        unique case (funct7)
                            F7_ADDW: begin
                                ctl.ALUSel = ALU_ADD32;
                            end
                            F7_SUBW: begin
                                ctl.ALUSel = ALU_SUB32;
                            end
                            F7_MULW: begin
                                ctl.multiplyEn = 2'b11;
                            end
                            default: begin
                                
                            end
                        endcase
                    end
                    F3_SLLW: begin
                        ctl.ALUSel = ALU_LEFT32;
                    end
                    F3_DIVW: begin
                        ctl.divideEn = 4'b1100;
                    end
                    F3_SRLW: begin
                        unique case (funct7)
                            F7_SRLW: begin
                                ctl.ALUSel = ALU_RIGHT32;
                            end
                            F7_SRAW: begin
                                ctl.ALUSel = ALU_RIGHT32_SEXT;
                            end
                            F7_DIVUW: begin
                                ctl.divideEn = 4'b1101;
                            end
                            default: begin
                                
                            end
                        endcase
                    end
                    F3_REMW: begin
                        ctl.divideEn = 4'b1110;
                    end
                    F3_REMUW: begin
                        ctl.divideEn = 4'b1111;
                    end
                    default: begin
                        
                    end
                endcase
            end
            OP_JAL: begin
                ctl.ImmSel = J;
                ctl.RegWEn = 1'b1;
                ctl.BSel = 1'b1;
                ctl.ASel = 1'b1;
                ctl.WBSel = 2'b10;
                ctl.wa = raw_instr[11:7];
            end
            OP_JALR: begin
                ctl.ImmSel = I;
                ctl.PCSel = 1'b1;
                ctl.RegWEn = 1'b1;
                ctl.BSel = 1'b1;
                ctl.WBSel = 2'b10;
                ctl.wa = raw_instr[11:7];
                ctl.ra1En = 1'b1;
            end
            default: begin
                
            end
        endcase
    end
    
endmodule

`endif
