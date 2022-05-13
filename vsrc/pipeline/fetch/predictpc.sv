`ifndef __PREDICTPC_SV
`define __PREDICTPC_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`endif

module predictpc 
    import common::*;
    import pipes::*;(
    input u64 pcjump,
    input u64 pcplus4,
    output u64 predPC
);
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
