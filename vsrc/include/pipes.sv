`ifndef __PIPES_SV
`define __PIPES_SV

`ifdef VERILATOR
`include "include/common.sv"
`endif

package pipes;
	import common::*;
/* Define instrucion decoding rules here */

/* rv64i */

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
parameter F3_SLL = 3'b001;
parameter F3_SLT = 3'b010;
parameter F3_SLTU = 3'b011;
parameter F3_XOR = 3'b100;
parameter F3_SRL = 3'b101;
	parameter F7_SRL = 7'b0000000;
	parameter F7_SRA = 7'b0100000;
parameter F3_OR = 3'b110;
parameter F3_AND = 3'b111;

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
parameter F3_SLLW = 3'b001;
parameter F3_SRLW = 3'b101;
	parameter F7_SRLW = 7'b0000000;
	parameter F7_SRAW = 7'b0100000;


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
	ALU_ADD_CLEAR,
	ALU_LT,
	ALU_LT_U,
	ALU_LEFT6,
	ALU_LEFT32,
	ALU_RIGHT6,
	ALU_RIGHT6_SEXT,
	ALU_RIGHT32,
	ALU_RIGHT32_SEXT
} alufunc_t;

typedef struct packed {
	u32 raw_instr;
	u64 pc;
	u1 valid;
} fetch_data_t;

typedef enum logic [5:0] {
	UNKNOWN,
	R,
	I,
	SHAMT6,
	SHAMT5,
	S,
	B,
	U,
	J
} decode_op_t;

typedef struct packed {
	u32 raw_instr;
	u1 PCSel, RegWEn, BrUn, BSel, ASel, ra1En, ra2En, SltEn, EqEn, LTEn, EqSel, LTSel, mem_unsigned;
	decode_op_t ImmSel;
	alufunc_t ALUSel;
	msize_t msize;
	u2 WBSel, MemRW;
	creg_addr_t wa;
} control_t;

typedef struct packed {
	control_t ctl;
	u64 pc;
	word_t rs1, rs2;
	u1 valid;
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

endpackage

`endif
