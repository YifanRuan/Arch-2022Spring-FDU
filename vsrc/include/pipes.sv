`ifndef __PIPES_SV
`define __PIPES_SV

`ifdef VERILATOR
`include "include/common.sv"
`endif

package pipes;
	import common::*;
/* Define instrucion decoding rules here */

parameter OP_RI = 7'b0010011;
parameter F3_ADDI = 3'b000;
parameter F3_XORI = 3'b100;
parameter F3_ORI = 3'b110;
parameter F3_ANDI = 3'b111;


/* Define pipeline structures here */

typedef enum logic [4:0] {
	ALU_ADD,
	ALU_XOR,
	ALU_OR,
	ALU_AND
} alufunc_t;

typedef struct packed {
	u32 raw_instr;
	u64 pc;
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
} decode_data_t;

typedef struct packed {
	control_t ctl;
	u64 pc;
	u64 alu;
	word_t rs2;
} execute_data_t;

typedef struct packed {
	control_t ctl;
	u64 result;
} memory_data_t;

endpackage

`endif
