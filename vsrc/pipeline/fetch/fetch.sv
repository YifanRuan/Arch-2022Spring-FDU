`ifndef __FETCH_SV
`define __FETCH_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "pipeline/fetch/predictpc.sv"
`else

`endif

module fetch
    import common::*;
    import pipes::*;(
    input ibus_resp_t iresp,
    output ibus_req_t ireq,

    input u64 pc,
    output fetch_data_t dataF_nxt,
    output u1 imem_wait,
    output u64 predPC
);
    always_comb begin
        if (pc > 0) begin
            ireq.addr = pc;
            ireq.valid = '1;
            imem_wait = ~iresp.data_ok;
            dataF_nxt.pc = pc;
            dataF_nxt.raw_instr = iresp.data;
            dataF_nxt.valid = iresp.data_ok;
        end else begin
            ireq.valid = '0;
            imem_wait = '0;
            dataF_nxt = '0;
        end
    end

    u64 pcjump, pcplus4;
    wire [6:0] opcode = dataF_nxt.raw_instr[6:0];
    always_comb begin
        pcplus4 = pc + 4;
        pcjump = '1;
        unique case (opcode)
            OP_L: begin
                pcplus4 = '0;
                pcjump = '0;
            end
            OP_S: begin
                pcplus4 = '0;
                pcjump = '0;
            end
            OP_B: begin
                pcjump = pc + {{52{dataF_nxt.raw_instr[31]}}, dataF_nxt.raw_instr[7], dataF_nxt.raw_instr[30:25], dataF_nxt.raw_instr[11:8], 1'b0};
            end
            OP_JAL: begin
                pcplus4 = pc + {{44{dataF_nxt.raw_instr[31]}}, dataF_nxt.raw_instr[19:12], dataF_nxt.raw_instr[20], dataF_nxt.raw_instr[30:21], 1'b0};
            end
            OP_JALR: begin
                pcplus4 = '0;
                pcjump = '0;
            end
            default: begin
                
            end
        endcase
    end
    predictpc predictpc(
        .pcjump,
        .pcplus4,
        .predPC
    );
    
endmodule

`endif
