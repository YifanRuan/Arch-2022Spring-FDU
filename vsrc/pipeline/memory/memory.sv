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
    output memory_data_t dataM
);
    word_t DataR;
    always_ff @(posedge clk) begin
        dreq.data <= dataE.rs2;
        DataR <= dresp.data;
    end
    
    assign dataM.ctl = dataE.ctl;
    always_comb begin
        unique case (dataE.ctl.WBSel)
            2'b00: dataM.result = DataR;
            2'b01: dataM.result = dataE.alu;
            2'b10: dataM.result = dataE.pc + 4;
            default: begin
                
            end
        endcase
    end


endmodule

`endif
