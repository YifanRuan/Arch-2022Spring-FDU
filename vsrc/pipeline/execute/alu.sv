`ifndef __ALU_SV
`define __ALU_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module alu
	import common::*;
	import pipes::*;(
	input u64 a, b,
	input alufunc_t alufunc,
	output u64 c
);
	u64 d;
	always_comb begin
		c = '0;
		d = '0;
		unique case(alufunc)
			ALU_ZERO: c = '0;
			ALU_ADD: c = a + b;
			ALU_ADD32: begin
				d = a + b;
				c = {{32{d[31]}}, d[31:0]};
			end
			ALU_SUB: c = a - b;
			ALU_SUB32: begin
				d = a - b;
				c = {{32{d[31]}}, d[31:0]};
			end
			ALU_XOR: c = a ^ b;
			ALU_OR: c = a | b;
			ALU_AND: c = a & b;
			ALU_A: c = a;
			ALU_B: c = b;
			ALU_ADD_CLEAR: c = (a + b) & ~1;
			ALU_LEFT6: c = a << b[5:0];
			ALU_LEFT32: begin
				d = a << b[4:0];
				c = {{32{d[31]}}, d[31:0]};
			end
			ALU_RIGHT6: c = a >> b[5:0];
			ALU_RIGHT6_SEXT: c = $signed(a) >>> b[5:0];
			ALU_RIGHT32: begin
				d = {32'b0, a[31:0]} >> b[4:0];
				c = {{32{d[31]}}, d[31:0]};
			end
			ALU_RIGHT32_SEXT: begin
				d = $signed({{32{a[31]}}, a[31:0]}) >>> b[4:0];
				c = {{32{d[31]}}, d[31:0]};
			end
			default: begin
				
			end
		endcase
	end
	
endmodule

`endif
