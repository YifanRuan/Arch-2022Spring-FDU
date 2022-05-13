`ifndef __EXECUTE_SV
`define __EXECUTE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "pipeline/execute/alu.sv"
`include "pipeline/execute/multiplier.sv"
`include "pipeline/execute/divider.sv"
`else

`endif

module execute
    import common::*;
    import pipes::*;(
    input decode_data_t dataD,
    output execute_data_t dataE_nxt,
    output u1 exe_wait,

    input logic clk, reset
);
    wire BrLT = dataD.BrLT;
    u64 a, b, c;
    assign a = dataD.ctl.ASel ? dataD.pc : dataD.rs1;
    assign b = dataD.ctl.SltEn ? (BrLT ? 1 : 0) : (dataD.ctl.BSel ? dataD.imm : dataD.rs2);
    alu alu(
        .a,
        .b,
        .alufunc(dataD.ctl.ALUSel),
        .c
    );

    u128 cm;
    logic done_multiply;
    multiplier multiplier(
        .clk,
        .reset,
        .valid(dataD.ctl.multiplyEn[0] & ~dataD.stalled),
        .a,
        .b,
        .done(done_multiply),
        .c(cm)
    );
    u64 ans_m;
    always_comb begin
        if (dataD.ctl.multiplyEn[1]) begin
            ans_m = {{32{cm[31]}}, cm[31:0]};
        end else begin
            ans_m = cm[63:0];
        end
    end

    u128 cd, cd_tmp;
    logic done_divide;
    u64 ca, cb;
    u32 comp_a, comp_b;
    always_comb begin
        unique case ({dataD.ctl.divideEn[3], dataD.ctl.divideEn[0]})
            2'b00: begin
                ca = (a[63] == 1'b1) ? -a : a;
                cb = (b[63] == 1'b1) ? -b : b;
            end
            2'b01: begin
                ca = a;
                cb = b;
            end
            2'b10: begin
                ca = (a[31] == 1'b1) ? {32'b0, -a[31:0]} : {32'b0, a[31:0]};
                cb = (b[31] == 1'b1) ? {32'b0, -b[31:0]} : {32'b0, b[31:0]};
            end
            2'b11: begin
                ca = {32'b0, a[31:0]};
                cb = {32'b0, b[31:0]};
            end
            default: begin
                
            end
        endcase
    end
    divider divider(
        .clk,
        .reset(reset),
        .valid(dataD.ctl.divideEn[2] && ~dataD.stalled && cb != 0),
        .wordEn(dataD.ctl.divideEn[3]),
        .a(ca),
        .b(cb),
        .done(done_divide),
        .c(cd_tmp)
    );
    u32 qw, rw;
    u64 ninf;
    always_comb begin
        qw = '0;
        rw = '0;
        ninf = '1;
        unique case ({dataD.ctl.divideEn[3], dataD.ctl.divideEn[0]})
            2'b00: begin
                if (cb == 0) begin
                    cd = {a, ninf};
                end else if (a[63] & ~b[63]) begin
                    if (b == 0) begin
                        cd = -cd_tmp;
                    end else begin
                        cd = {-cd_tmp[127:64], -cd_tmp[63:0]};
                    end
                end else if (~a[63] && b[63]) begin
                    cd = {cd_tmp[127:64], -cd_tmp[63:0]};
                end else if (a[63] & b[63]) begin
                    cd = {-cd_tmp[127:64], cd_tmp[63:0]};
                end else begin
                    cd = cd_tmp;
                end
            end
            2'b01: begin
                if (cb == 0) begin
                    cd = {a, ninf};
                end else begin
                    cd = cd_tmp;
                end
            end
            2'b10: begin
                if (cb == 0) begin
                    cd = {{32{a[31]}}, a[31:0], ninf};
                end else if (a[31] & ~b[31]) begin
                    rw = -cd_tmp[95:64];
                    qw = -cd_tmp[31:0];
                    cd = {{32{rw[31]}}, rw, {32{qw[31]}}, qw[31:0]};
                end else if (~a[31] & b[31]) begin
                    rw = cd_tmp[95:64];
                    qw = -cd_tmp[31:0];
                    cd = {{32{rw[31]}}, rw, {32{qw[31]}}, qw[31:0]};
                end else if (a[31] & b[31]) begin
                    rw = -cd_tmp[95:64];
                    qw = cd_tmp[31:0];
                    cd = {{32{rw[31]}}, rw, {32{qw[31]}}, qw[31:0]};
                end else begin
                    cd = cd_tmp;
                end
            end
            2'b11: begin
                if (cb == 0) begin
                    cd = {{32{a[31]}}, a[31:0], ninf};
                end else begin
                    cd = cd_tmp;
                end
            end
            default: begin
                
            end
        endcase
    end

    u64 ans_d;
    always_comb begin
        if (dataD.ctl.divideEn[1]) begin
            ans_d = cd[127:64];
        end else begin
            ans_d = cd[63:0];
        end
    end

    wire mul_ok = dataD.ctl.multiplyEn[0] & done_multiply;
    wire div_ok = dataD.ctl.divideEn[2] & done_divide;

    always_comb begin
        if (mul_ok) begin
            dataE_nxt.alu = ans_m;
        end else if (div_ok) begin
            dataE_nxt.alu = ans_d;
        end else begin
            dataE_nxt.alu = c;
        end
    end

    assign dataE_nxt.pc = dataD.pc;
    assign dataE_nxt.ctl = dataD.ctl;
    assign dataE_nxt.rs2 = dataD.rs2;
    assign dataE_nxt.valid = dataD.valid;

    assign exe_wait = (dataD.ctl.multiplyEn[0] & ~done_multiply) | (dataD.ctl.divideEn[2] & ~done_divide);
    
endmodule

`endif
