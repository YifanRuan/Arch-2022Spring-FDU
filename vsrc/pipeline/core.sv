`ifndef __CORE_SV
`define __CORE_SV
`ifdef VERILATOR
`include "include/common.sv"
`include "pipeline/regfile/regfile.sv"
`include "pipeline/regfile/pcreg.sv"
`include "pipeline/regfile/freg.sv"
`include "pipeline/regfile/dreg.sv"
`include "pipeline/regfile/ereg.sv"
`include "pipeline/regfile/mreg.sv"
`include "pipeline/fetch/selectpc.sv"
`include "pipeline/fetch/fetch.sv"
`include "pipeline/decode/decode.sv"
`include "pipeline/decode/jump.sv"
`include "pipeline/execute/execute.sv"
`include "pipeline/memory/memory.sv"
`include "pipeline/writeback/writeback.sv"
`include "pipeline/hazard/hazard.sv"
`include "pipeline/forward/forward.sv"

`else

`endif

module core 
	import common::*;
	import pipes::*;(
	input logic clk, reset,
	output ibus_req_t  ireq,
	input  ibus_resp_t iresp,
	output dbus_req_t  dreq,
	input  dbus_resp_t dresp
);
	/* TODO: Add your pipeline here. */

	u64 pc, pc_nxt;

	fetch_data_t dataF, dataF_nxt;
	decode_data_t dataD, dataD_nxt;
	execute_data_t dataE, dataE_nxt;
	memory_data_t dataM, dataM_nxt;

	creg_addr_t wa;
	u64 wd;
	u1 wvalid;

	creg_addr_t ra1, ra2;
	u64 rd1, rd2;

	u64 rs1, rs2;

	u2 PCWrite, FWrite, DWrite, EWrite, MWrite;
	u1 imem_wait, dmem_wait;
	u1 PCSel;

	creg_addr_t ewa, mwa;
	assign ewa = dataE_nxt.ctl.wa;
	assign mwa = dataM_nxt.ctl.wa;

	u64 pc_address, predPC;

	control_t ctl;
	u64 d_pc, imm;
	u1 d_valid;

	selectpc selectpc(
		.pc_address,
		.PCSel,
		.predPC,
		.pc_selected(pc_nxt)
	);

	pcreg pcreg(
		.clk,
		.reset,
		.pc_nxt,
		.PCWrite,
		.pc
	);

	fetch fetch(
		.iresp,
		.ireq,
		.pc,
		.dataF_nxt,
		.imem_wait,
		.predPC
	);

	freg freg(
		.clk,
		.reset,
		.dataF_nxt,
		.FWrite,
		.dataF
	);

	decode decode(
		.dataF,
		.ra1,
		.ra2,
		.ctl,
		.d_pc,
		.d_valid,
		.imm
	);

	forward forward(
		.ra1,
		.ra2,
		.ewa,
		.mwa,
		.wa,
		.rd1,
		.rd2,
		.alu(dataE_nxt.alu),
		.m_result(dataM_nxt.result),
		.wd,
		.rs1,
		.rs2
	);

	jump jump(
		.rs1,
		.rs2,
		.ctl,
		.d_pc,
		.d_valid,
		.imm,
		.dataD_nxt,
		.last_pc(dataF_nxt.pc),
		.PCSel,
		.pc_address
	);

	hazard hazard(
		.PCSel,
		.imem_wait,
		.dmem_wait,
		.PCWrite,
		.FWrite,
		.DWrite,
		.EWrite,
		.MWrite
	);

	dreg dreg(
		.clk,
		.reset,
		.dataD_nxt,
		.dataD,
		.DWrite
	);

	execute execute(
		.dataD,
		.dataE_nxt
	);

	ereg ereg(
		.clk,
		.reset,
		.dataE_nxt,
		.dataE,
		.EWrite
	);

	memory memory(
		.dresp,
		.dreq,
		.dataE,
		.dataM_nxt,
		.dmem_wait
	);

	mreg mreg(
		.clk,
		.reset,
		.dataM_nxt,
		.dataM,
		.MWrite
	);

	writeback writeback(
		.dataM,
		.wa,
		.wd,
		.wvalid
	);


	regfile regfile(
		.clk, .reset,
		.ra1,
		.ra2,
		.rd1,
		.rd2,
		.wvalid,
		.wa,
		.wd
	);

`ifdef VERILATOR
	DifftestInstrCommit DifftestInstrCommit(
		.clock              (clk),
		.coreid             (0),
		.index              (0),
		.valid              (~reset && dataM.valid),
		.pc                 (dataM.pc),
		.instr              (dataM.ctl.raw_instr),
		.skip               (dataM.ctl.MemRW != 2'b00 && dataM.addr31 == 0),
		.isRVC              (0),
		.scFailed           (0),
		.wen                (wvalid),
		.wdest              ({3'b0, wa}),
		.wdata              (wd)
	);
	      
	DifftestArchIntRegState DifftestArchIntRegState (
		.clock              (clk),
		.coreid             (0),
		.gpr_0              (regfile.regs_nxt[0]),
		.gpr_1              (regfile.regs_nxt[1]),
		.gpr_2              (regfile.regs_nxt[2]),
		.gpr_3              (regfile.regs_nxt[3]),
		.gpr_4              (regfile.regs_nxt[4]),
		.gpr_5              (regfile.regs_nxt[5]),
		.gpr_6              (regfile.regs_nxt[6]),
		.gpr_7              (regfile.regs_nxt[7]),
		.gpr_8              (regfile.regs_nxt[8]),
		.gpr_9              (regfile.regs_nxt[9]),
		.gpr_10             (regfile.regs_nxt[10]),
		.gpr_11             (regfile.regs_nxt[11]),
		.gpr_12             (regfile.regs_nxt[12]),
		.gpr_13             (regfile.regs_nxt[13]),
		.gpr_14             (regfile.regs_nxt[14]),
		.gpr_15             (regfile.regs_nxt[15]),
		.gpr_16             (regfile.regs_nxt[16]),
		.gpr_17             (regfile.regs_nxt[17]),
		.gpr_18             (regfile.regs_nxt[18]),
		.gpr_19             (regfile.regs_nxt[19]),
		.gpr_20             (regfile.regs_nxt[20]),
		.gpr_21             (regfile.regs_nxt[21]),
		.gpr_22             (regfile.regs_nxt[22]),
		.gpr_23             (regfile.regs_nxt[23]),
		.gpr_24             (regfile.regs_nxt[24]),
		.gpr_25             (regfile.regs_nxt[25]),
		.gpr_26             (regfile.regs_nxt[26]),
		.gpr_27             (regfile.regs_nxt[27]),
		.gpr_28             (regfile.regs_nxt[28]),
		.gpr_29             (regfile.regs_nxt[29]),
		.gpr_30             (regfile.regs_nxt[30]),
		.gpr_31             (regfile.regs_nxt[31])
	);
	      
	DifftestTrapEvent DifftestTrapEvent(
		.clock              (clk),
		.coreid             (0),
		.valid              (0),
		.code               (0),
		.pc                 (0),
		.cycleCnt           (0),
		.instrCnt           (0)
	);
	      
	DifftestCSRState DifftestCSRState(
		.clock              (clk),
		.coreid             (0),
		.priviledgeMode     (3),
		.mstatus            (0),
		.sstatus            (0),
		.mepc               (0),
		.sepc               (0),
		.mtval              (0),
		.stval              (0),
		.mtvec              (0),
		.stvec              (0),
		.mcause             (0),
		.scause             (0),
		.satp               (0),
		.mip                (0),
		.mie                (0),
		.mscratch           (0),
		.sscratch           (0),
		.mideleg            (0),
		.medeleg            (0)
	      );
	      
	DifftestArchFpRegState DifftestArchFpRegState(
		.clock              (clk),
		.coreid             (0),
		.fpr_0              (0),
		.fpr_1              (0),
		.fpr_2              (0),
		.fpr_3              (0),
		.fpr_4              (0),
		.fpr_5              (0),
		.fpr_6              (0),
		.fpr_7              (0),
		.fpr_8              (0),
		.fpr_9              (0),
		.fpr_10             (0),
		.fpr_11             (0),
		.fpr_12             (0),
		.fpr_13             (0),
		.fpr_14             (0),
		.fpr_15             (0),
		.fpr_16             (0),
		.fpr_17             (0),
		.fpr_18             (0),
		.fpr_19             (0),
		.fpr_20             (0),
		.fpr_21             (0),
		.fpr_22             (0),
		.fpr_23             (0),
		.fpr_24             (0),
		.fpr_25             (0),
		.fpr_26             (0),
		.fpr_27             (0),
		.fpr_28             (0),
		.fpr_29             (0),
		.fpr_30             (0),
		.fpr_31             (0)
	);
	
`endif
endmodule
`endif
