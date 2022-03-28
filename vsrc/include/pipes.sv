`ifndef __PIPES_SV
`define __PIPES_SV

`ifdef VERILATOR
`include "include/common.sv"
`endif

package pipes;
	import common::*;
/* Define instrucion decoding rules here */

/* lab1a */

parameter OP_RI = 7'b0010011;
parameter F3_ADDI = 3'b000;
parameter F3_XORI = 3'b100;
parameter F3_ORI = 3'b110;
parameter F3_ANDI = 3'b111;

parameter OP_LUI = 7'b0110111;

parameter OP_JAL = 7'b1101111;

parameter OP_B = 7'b1100011;
parameter F3_BEQ = 3'b000;

parameter OP_L = 7'b0000011;
parameter F3_LD = 3'b011;

parameter OP_S = 7'b0100011;
parameter F3_SD = 3'b011;

/* lab1 */

parameter OP_R = 7'b0110011;
parameter F3_ADD = 3'b000;
parameter F7_ADD = 7'b0000000;
parameter F7_SUB = 7'b0100000;
parameter F3_XOR = 3'b100;
parameter F3_OR = 3'b110;
parameter F3_AND = 3'b111;

parameter OP_AUIPC = 7'b0010111;

parameter OP_JALR = 7'b1100111;


/* Define pipeline structures here */

typedef enum logic [4:0] {
	ALU_ADD,
	ALU_XOR,
	ALU_OR,
	ALU_AND,
	ALU_A,
	ALU_B
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
	S,
	B,
	U,
	J
} decode_op_t;

typedef struct packed {
	u32 raw_instr;
	u1 PCSel, RegWEn, BrUn, BrLT, BSel, ASel, MemRW;
	decode_op_t ImmSel;
	alufunc_t ALUSel;
	u2 WBSel;
} control_t;

typedef struct packed {
	control_t ctl;
	u64 pc;
	word_t rs1, rs2;
	u1 valid;
} decode_data_t;

typedef struct packed {
	control_t ctl;
	u64 pc;
	u64 alu;
	word_t rs2;
	u1 valid;
} execute_data_t;

typedef struct packed {
	control_t ctl;
	u64 result;
	u1 valid;
	u64 pc;
} memory_data_t;

endpackage

`endif
