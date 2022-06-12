`ifndef __PIPES_SV
`define __PIPES_SV

`ifdef VERILATOR
`include "include/common.sv"
`endif

package pipes;
	import common::*;
/* Define instrucion decoding rules here */

/* rv64i + rv64im + csr */

parameter OP_LUI = 7'b0110111;

parameter OP_AUIPC = 7'b0010111;

parameter OP_JAL = 7'b1101111;

parameter OP_JALR = 7'b1100111;

parameter OP_B = 7'b1100011;
parameter F3_BEQ = 3'b000;
parameter F3_BNE = 3'b001;
parameter F3_BLT = 3'b100;
parameter F3_BGE = 3'b101;
parameter F3_BLTU = 3'b110;
parameter F3_BGEU = 3'b111;

parameter OP_L = 7'b0000011;
parameter F3_LB = 3'b000;
parameter F3_LH = 3'b001;
parameter F3_LW = 3'b010;
parameter F3_LD = 3'b011;
parameter F3_LBU = 3'b100;
parameter F3_LHU = 3'b101;
parameter F3_LWU = 3'b110;

parameter OP_S = 7'b0100011;
parameter F3_SB = 3'b000;
parameter F3_SH = 3'b001;
parameter F3_SW = 3'b010;
parameter F3_SD = 3'b011;

parameter OP_RI = 7'b0010011;
parameter F3_ADDI = 3'b000;
parameter F3_SLLI = 3'b001;
parameter F3_SLTI = 3'b010;
parameter F3_SLTIU = 3'b011;
parameter F3_XORI = 3'b100;
parameter F3_SRLI = 3'b101;
	parameter F7_SRLI = 6'b000000;
	parameter F7_SRAI = 6'b010000;
parameter F3_ORI = 3'b110;
parameter F3_ANDI = 3'b111;

parameter OP_R = 7'b0110011;
parameter F3_ADD = 3'b000;
	parameter F7_ADD = 7'b0000000;
	parameter F7_SUB = 7'b0100000;
	parameter F7_MUL = 7'b0000001;
parameter F3_SLL = 3'b001;
parameter F3_SLT = 3'b010;
parameter F3_SLTU = 3'b011;
parameter F3_XOR = 3'b100;
	parameter F7_XOR = 7'b0000000;
	parameter F7_DIV = 7'b0000001;
parameter F3_SRL = 3'b101;
	parameter F7_SRL = 7'b0000000;
	parameter F7_SRA = 7'b0100000;
	parameter F7_DIVU = 7'b0000001;
parameter F3_OR = 3'b110;
	parameter F7_OR = 7'b0000000;
	parameter F7_REM = 7'b0000001;
parameter F3_AND = 3'b111;
	parameter F7_AND = 7'b0000000;
	parameter F7_REMU = 7'b0000001;

parameter OP_RIW = 7'b0011011;
parameter F3_ADDIW = 3'b000;
parameter F3_SLLIW = 3'b001;
parameter F3_SRLIW = 3'b101;
	parameter F7_SRLIW = 7'b0000000;
	parameter F7_SRAIW = 7'b0100000;

parameter OP_RW = 7'b0111011;
parameter F3_ADDW = 3'b000;
	parameter F7_ADDW = 7'b0000000;
	parameter F7_SUBW = 7'b0100000;
	parameter F7_MULW = 7'b0000001;
parameter F3_SLLW = 3'b001;
parameter F3_DIVW = 3'b100;
parameter F3_SRLW = 3'b101;
	parameter F7_SRLW = 7'b0000000;
	parameter F7_SRAW = 7'b0100000;
	parameter F7_DIVUW = 7'b0000001;
parameter F3_REMW = 3'b110;
parameter F3_REMUW = 3'b111;

parameter OP_SYSTEM = 7'b1110011;
parameter F3_PRIV = 3'b000;
	parameter F25_ECALL = 25'b0000000000000000000000000;
	parameter F25_MRET = 25'b0011000000100000000000000;
parameter F3_CSSRW = 3'b001;
parameter F3_CSRRS = 3'b010;
parameter F3_CSRRC = 3'b011;
parameter F3_CSSRWI = 3'b101;
parameter F3_CSRRSI = 3'b110;
parameter F3_CSRRCI = 3'b111;

parameter OP_ZERO = 7'b0000000;

/* Define pipeline structures here */

typedef enum logic [4:0] {
	ALU_ZERO,
	ALU_ADD,
	ALU_ADD32,
	ALU_SUB,
	ALU_SUB32,
	ALU_XOR,
	ALU_OR,
	ALU_AND,
	ALU_A,
	ALU_B,
	ALU_LEFT6,
	ALU_LEFT32,
	ALU_RIGHT6,
	ALU_RIGHT6_SEXT,
	ALU_RIGHT32,
	ALU_RIGHT32_SEXT,
	ALU_NEXT_PC,
	ALU_AND_REV,
	ALU_REV_AND
} alufunc_t;

typedef struct packed {
	u32 raw_instr;
	u64 pc;
	u1 valid, instr_misalign;
} fetch_data_t;

typedef enum logic [2:0] {
	UNKNOWN,
	I,
	B,
	U,
	S,
	J,
	CSR
} decode_op_t;

typedef struct packed {
	u1
	is_csr,
	is_err,
	is_mret,
	illegal_instr,
	instr_misalign,
	is_ecall,
	load_misalign,
	store_misalign,
	csra,
	csrb;
	u64 csrs;
	csr_addr_t csr;
} csr_control_t;

typedef struct packed {
	u32 raw_instr;
	u1 PCSel, RegWEn, BrUn, BSel, ASel, ra1En, ra2En, WBSel, SltEn, EqEn, LTEn, EqSel, LTSel, mem_unsigned, loadEn;
	decode_op_t ImmSel;
	alufunc_t ALUSel;
	msize_t msize;
	u2 MemRW;
	u2 multiplyEn; // {W, is}
	u4 divideEn; // {W, is, type_rem, unsgn}
	creg_addr_t wa;
	csr_control_t csr;
} control_t;

typedef struct packed {
	control_t ctl;
	u64 pc, imm;
	word_t rs1, rs2;
	u1 valid, BrLT, stalled;
} decode_data_t;

typedef struct packed {
	control_t ctl;
	u64 pc, alu;
	word_t rs2;
	u1 valid;
} execute_data_t;

typedef struct packed {
	control_t ctl;
	u64 pc, result;
	u1 valid, addr31;
} memory_data_t;

// csrs
parameter u12 CSR_MHARTID = 12'hf14;
parameter u12 CSR_MIE = 12'h304;
parameter u12 CSR_MIP = 12'h344;
parameter u12 CSR_MTVEC = 12'h305;
parameter u12 CSR_MSTATUS = 12'h300;
parameter u12 CSR_MSCRATCH = 12'h340;
parameter u12 CSR_MEPC = 12'h341;
parameter u12 CSR_SATP = 12'h180;
parameter u12 CSR_MCAUSE = 12'h342;
parameter u12 CSR_MCYCLE = 12'hb00;
parameter u12 CSR_MTVAL = 12'h343;

typedef struct packed {
	u1 sd;
	logic [MXLEN-2-36:0] wpri1;
	u2 sxl;
	u2 uxl;
	u9 wpri2;
	u1 tsr;
	u1 tw;
	u1 tvm;
	u1 mxr;
	u1 sum;
	u1 mprv;
	u2 xs;
	u2 fs;
	u2 mpp;
	u2 wpri3;
	u1 spp;
	u1 mpie;
	u1 wpri4;
	u1 spie;
	u1 upie;
	u1 mie;
	u1 wpri5;
	u1 sie;
	u1 uie;
} mstatus_t;

typedef struct packed {
	u4 mode;
	u16 asid;
	u44 ppn;
} satp_t;

typedef struct packed {
	u64
	mhartid, // Hardware thread Id, read-only as 0 in this work
	mie,	 // Machine interrupt-enable register
	mip,	 // Machine interrupt pending
	mtvec;	 // Machine trap-handler base address
	mstatus_t
	mstatus; // Machine status register
	u64
	mscratch, // Scratch register for machine trap handlers
	mepc,	 // Machine exception program counter
	satp,	 // Supervisor address translation and protection, read-only as 0 in this work
	mcause,  // Machine trap cause
	mcycle,  // Counter
	mtval;
} csr_regs_t;

endpackage

`endif
