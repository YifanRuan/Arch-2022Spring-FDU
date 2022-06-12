`ifndef __CSR_SV
`define __CSR_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`endif

module csr 
    import common::*;
    import pipes::*;(
    input logic clk, reset,
    input csr_addr_t csr_ra, csr_wa,
    input u64 csr_wd,
    output u64 csr_rd,
    input u1 csr_valid,

    input csr_control_t csr_control,
    input u64 real_pc,
    output u64 pc_csr,
    input logic trint, swint, exint,
    input u1 is_stall,
    output u1 is_int
);
    csr_regs_t regs, regs_nxt;
    u4 mode, mode_nxt;

    wire tr = trint & regs.mie[7];
    wire sw = swint & regs.mie[3];
    wire ex = exint & regs.mie[11];
    assign is_int = regs.mstatus.mie & (tr | sw | ex);

    always_ff @(posedge clk) begin
        if (reset) begin
            regs <= '0;
            regs.mcause[1] <= 1'b1;
            regs.mepc[31] <= 1'b1;
            mode <= 4'b0011;
        end else if (~is_stall) begin
            regs <= regs_nxt;
            mode <= mode_nxt;
        end
    end

    // read
    always_comb begin
        csr_rd = '0;
        unique case(csr_ra)
			CSR_MIE: csr_rd = regs.mie;
			CSR_MIP: csr_rd = regs.mip;
			CSR_MTVEC: csr_rd = regs.mtvec;
			CSR_MSTATUS: csr_rd = regs.mstatus;
			CSR_MSCRATCH: csr_rd = regs.mscratch;
			CSR_MEPC: csr_rd = regs.mepc;
			CSR_MCAUSE: csr_rd = regs.mcause;
			CSR_MCYCLE: csr_rd = regs.mcycle;
			CSR_MTVAL: csr_rd = regs.mtval;
            default: begin
                
            end
        endcase
    end

    // write
    always_comb begin
        regs_nxt = regs;
        mode_nxt = mode;
        regs_nxt.mcycle = regs.mcycle + 1;
        regs_nxt.mip[7] = trint;
        regs_nxt.mip[3] = swint;
        regs_nxt.mip[11] = exint;
        // Writeback: W stage
        if (csr_control.is_err) begin
            regs_nxt.mepc = real_pc;
            pc_csr = regs.mtvec;
            regs_nxt.mstatus.mpie = regs.mstatus.mie;
            regs_nxt.mstatus.mie = 0;
            regs_nxt.mstatus.mpp = mode[1:0];
            // mcause
            if (csr_control.illegal_instr) begin
                regs_nxt.mcause = 2;
            end else if (csr_control.instr_misalign) begin
                regs_nxt.mcause = 0;
            end else if (csr_control.is_ecall) begin
                regs_nxt.mcause[63] = 0;
                regs_nxt.mcause[3:0] = mode + 8;
            end else if (csr_control.load_misalign) begin
                regs_nxt.mcause = 4;
            end else if (csr_control.store_misalign) begin
                regs_nxt.mcause = 6;
            end
            mode_nxt = 3;
        end else if (is_int) begin
            regs_nxt.mepc = real_pc;
            pc_csr = regs.mtvec;
            regs_nxt.mstatus.mpie = regs.mstatus.mie;
            regs_nxt.mstatus.mie = 0;
            regs_nxt.mstatus.mpp = mode[1:0];
            mode_nxt = 3;
            if (tr) begin
                regs_nxt.mcause = 7;
            end else if (sw) begin
                regs_nxt.mcause = 3;
            end else if (ex) begin
                regs_nxt.mcause = 11;
            end
            regs_nxt.mcause[63] = 1'b1;
        end else if (csr_valid) begin
            unique case(csr_wa)
                CSR_MIE: regs_nxt.mie = csr_wd;
				CSR_MIP:  regs_nxt.mip = csr_wd;
				CSR_MTVEC: regs_nxt.mtvec = csr_wd;
				CSR_MSTATUS: regs_nxt.mstatus = csr_wd;
				CSR_MSCRATCH: regs_nxt.mscratch = csr_wd;
				CSR_MEPC: regs_nxt.mepc = csr_wd;
				CSR_MCAUSE: regs_nxt.mcause = csr_wd;
				CSR_MCYCLE: regs_nxt.mcycle = csr_wd;
				CSR_MTVAL: regs_nxt.mtval = csr_wd;
                default: begin
                    
                end
            endcase
            regs_nxt.mstatus.sd = regs_nxt.mstatus.fs != 0;
            pc_csr = real_pc + 4;
        end else if (csr_control.is_mret) begin
            mode_nxt[1:0] = regs.mstatus.mpp;
            regs_nxt.mstatus.mie = regs_nxt.mstatus.mpie;
            regs_nxt.mstatus.mpie = 1'b1;
            regs_nxt.mstatus.mpp = 2'b0;
            regs_nxt.mstatus.xs = 0;
            pc_csr = regs.mepc;
        end
    end


endmodule

`endif
