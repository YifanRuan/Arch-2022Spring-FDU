`ifndef __DIVIDER_SV
`define __DIVIDER_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`endif

module divider
    import common::*;
    import pipes::*;(
    input logic clk, reset, valid, wordEn,
    input u64 a, b, // two unsigned positive number
    output logic done,
    output u128 c // c = {a % b, a / b}
);
    enum i1 {INIT, DOING} state, state_nxt;
    i65 count, count_nxt;
    localparam i65 DIV_DELAY = {1'b1, 64'b0};
    always_ff @(posedge clk) begin
        if (reset) begin
            {state, count} <= '0;
        end else begin
            {state, count} <= {state_nxt, count_nxt};
        end
    end
    assign done = (state_nxt == INIT);
    always_comb begin
        {state_nxt, count_nxt} = {state, count};
        unique case (state)
            INIT: begin
                if (valid) begin
                    state_nxt = DOING;
                    count_nxt = DIV_DELAY;
                end
            end
            DOING: begin
                count_nxt = {1'b0, count_nxt[64:1]};
                if (count_nxt == '0) begin
                    state_nxt = INIT;
                end else if (wordEn && count_nxt[64:32] == '0) begin
                    state_nxt = INIT;
                end
            end
            default: begin
                
            end
        endcase
    end
    u128 p, p_nxt;
    u64 p32, p32_nxt;
    always_comb begin
        p_nxt = p;
        p32_nxt = p32;
        unique case (state)
            INIT: begin
                p_nxt = {64'b0, a};
                p32_nxt = {32'b0, a[31:0]};
            end
            DOING: begin
                p32_nxt = {p32_nxt[62:0], 1'b0};
                if (p32_nxt[63:32] >= b[31:0]) begin
                    p32_nxt[63:32] -= b[31:0];
                    p32_nxt[0] = 1'b1;
                end
                p_nxt = {p_nxt[126:0], 1'b0};
                if (p_nxt[127:64] >= b) begin
                    p_nxt[127:64] -= b;
                    p_nxt[0] = 1'b1;
                end
            end
            default: begin
                
            end
        endcase
    end
    always_ff @(posedge clk) begin
        if (reset) begin
            p <= '0;
            p32 <= '0;
        end else if (~done) begin
            p <= p_nxt;
            p32 <= p32_nxt;
        end
    end
    assign c = wordEn ? {{32{p32[63]}}, p32[63:32], {32{p32[31]}}, p32[31:0]} : p;
    
endmodule

`endif
