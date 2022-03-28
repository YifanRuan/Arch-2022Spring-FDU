`ifndef __MEMORY_SV
`define __MEMORY_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module memory
    import common::*;
    import pipes::*;(
    input logic clk,
    input dbus_resp_t dresp,
    output dbus_req_t dreq,
    input execute_data_t dataE,
    output memory_data_t dataM_nxt
);
    word_t DataR;
    always_comb begin
        unique case (dataE.ctl.MemRW)
            2'b10: begin
                dreq.valid = '1;
                dreq.strobe = '0;
                dreq.addr = dataE.alu;
                DataR = dresp.data;
            end
            2'b11: begin
                dreq.valid = '1;
                dreq.strobe = '0;
                dreq.addr = dataE.alu;
                dreq.data = dataE.rs2;
            end
            default: begin
                dreq.valid = '0;
                dreq.strobe = '0;
            end
        endcase
    end
    
    assign dataM_nxt.ctl = dataE.ctl;
    assign dataM_nxt.pc = dataE.pc;
    always_comb begin
        unique case (dataE.ctl.WBSel)
            2'b00: dataM_nxt.result = DataR;
            2'b01: dataM_nxt.result = dataE.alu;
            2'b10: dataM_nxt.result = dataE.pc + 4;
            default: begin
                
            end
        endcase
    end


endmodule

`endif
