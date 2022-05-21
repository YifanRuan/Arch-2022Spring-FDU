`ifndef __PREDICTPC_SV
`define __PREDICTPC_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`endif

module predictpc 
    import common::*;
    import pipes::*;(
    input u64 pc,
    input u32 raw_instr,
    output u64 predPC
);
    wire [6:0] opcode = raw_instr[6:0];
    u64 pcplus4, pcjump;
    always_comb begin
        pcplus4 = pc + 4;
        pcjump = '1;
        unique case (opcode)
            OP_B: begin
                pcjump = pc + {{52{raw_instr[31]}}, raw_instr[7], raw_instr[30:25], raw_instr[11:8], 1'b0};
            end
            OP_JAL: begin
                pcplus4 = pc + {{44{raw_instr[31]}}, raw_instr[19:12], raw_instr[20], raw_instr[30:21], 1'b0};
            end
            OP_JALR: begin
                pcplus4 = '0;
                pcjump = '0;
            end
            default: begin
                
            end
        endcase
    end
    always_comb begin
        if (~pcjump == '0) begin
            predPC = pcplus4;
        end else if (pcjump < pcplus4) begin
            predPC = pcjump;
        end else begin
            predPC = pcplus4;
        end
    end
    
endmodule

`endif
