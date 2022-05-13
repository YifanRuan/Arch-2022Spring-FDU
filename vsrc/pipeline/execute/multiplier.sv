`ifndef __MULTIPLIER_SV
`define __MULTIPLIER_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`endif

module multiplier
    import common::*;
    import pipes::*;(
    input logic clk, reset, valid,
    input u64 a, b,
    output logic done,
    output u128 c
);
    logic [9:0][31:0] p, p_nxt;
    assign p_nxt[0] = a[15:0] * b[15:0];
    assign p_nxt[1] = a[15:0] * b[31:16];
    assign p_nxt[2] = a[15:0] * b[47:32];
    assign p_nxt[3] = a[15:0] * b[63:48];
    assign p_nxt[4] = a[31:16] * b[15:0];
    assign p_nxt[5] = a[31:16] * b[31:16];
    assign p_nxt[6] = a[31:16] * b[47:32];
    assign p_nxt[7] = a[47:32] * b[15:0];
    assign p_nxt[8] = a[47:32] * b[31:16];
    assign p_nxt[9] = a[63:48] * b[15:0];

    always_ff @(posedge clk) begin
        if (reset) begin
            p <= '0;
        end else if (~done) begin
            p <= p_nxt;
        end
    end
    logic [9:0][63:0] q;
    assign q[0] = {32'b0, p[0]};
    assign q[1] = {16'b0, p[1], 16'b0};
    assign q[2] = {p[2], 32'b0};
    assign q[3] = {p[3][15:0], 48'b0};
    assign q[4] = {16'b0, p[4], 16'b0};
    assign q[5] = {p[5], 32'b0};
    assign q[6] = {p[6][15:0], 48'b0};
    assign q[7] = {p[7], 32'b0};
    assign q[8] = {p[8][15:0], 48'b0};
    assign q[9] = {p[9][15:0], 48'b0};
    assign c[63:0] = q[0] + q[1] + q[2] + q[3] + q[4] + q[5] + q[6] + q[7] + q[8] + q[9];

    enum logic {INIT, DOING} state, state_nxt;
    always_ff @(posedge clk) begin
        if (reset) begin
            state <= INIT;
        end else begin
            state <= state_nxt;
        end
    end
    always_comb begin
        state_nxt = state;
        if (state == DOING) begin
            state_nxt = INIT;
        end else if (valid) begin
            state_nxt = DOING;
        end
    end
    assign done = state_nxt == INIT;
    
endmodule

`endif
