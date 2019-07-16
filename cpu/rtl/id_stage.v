/*
 -- ============================================================================
 -- FILE NAME	: id_stage.v
 -- DESCRIPTION : ID阶段顶层模块。用来连接指令解码器与ID阶段流水线寄存器。
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by	 Comment
 -- 1.0.0	  2011/06/27  suito		 新规作成
 -- ============================================================================
*/

/**********  **********/
`include "nettype.h"
`include "global_config.h"
`include "stddef.h"

/**********  **********/
`include "isa.h"
`include "cpu.h"

/**********  **********/
module id_stage (
	/********** 时钟 & 复位 **********/
	input  wire					 clk,			 // 时钟
	input  wire					 reset,			 // 异步复位
	/********** GPR接口 **********/
	input  wire [`WordDataBus]	 gpr_rd_data_0,	 // 读取数据 0
	input  wire [`WordDataBus]	 gpr_rd_data_1,	 // 读取数据 1
	output wire [`RegAddrBus]	 gpr_rd_addr_0,	 // 读取地址 0
	output wire [`RegAddrBus]	 gpr_rd_addr_1,	 // 读取地址 1
	/********** 数据直通 **********/
	// 来自EX阶段的数据直通
	input  wire					 ex_en,			// 流水线数据有效
	input  wire [`WordDataBus]	 ex_fwd_data,	 // 数据直通
	input  wire [`RegAddrBus]	 ex_dst_addr,	 // 写入地址
	input  wire					 ex_gpr_we_,	 // 写入有效
	// 来自MEM阶段的数据直通
	input  wire [`WordDataBus]	 mem_fwd_data,	 // 
	/********** 控制寄存器接口 **********/
	input  wire [`CpuExeModeBus] exe_mode,		 // 执行模式
	input  wire [`WordDataBus]	 creg_rd_data,	 // 读取的数据
	output wire [`RegAddrBus]	 creg_rd_addr,	 // 读取的地址
	/********** 流水线控制信号 **********/
	input  wire					 stall,			 // 
	input  wire					 flush,			 // 
	output wire [`WordAddrBus]	 br_addr,		 // 
	output wire					 br_taken,		 // 
	output wire					 ld_hazard,		 // 
	/********** IF/ID流水线寄存器 **********/
	input  wire [`WordAddrBus]	 if_pc,			 // 
	input  wire [`WordDataBus]	 if_insn,		 // 
	input  wire					 if_en,			 // 
	/********** ID/EX流水线寄存器 **********/
	output wire [`WordAddrBus]	 id_pc,			 // 
	output wire					 id_en,			 // 
	output wire [`AluOpBus]		 id_alu_op,		 // ALU操作
	output wire [`WordDataBus]	 id_alu_in_0,	 // ALU输入 0
	output wire [`WordDataBus]	 id_alu_in_1,	 // ALU输入 1
	output wire					 id_br_flag,	 // 
	output wire [`MemOpBus]		 id_mem_op,		 // 
	output wire [`WordDataBus]	 id_mem_wr_data, // 
	output wire [`CtrlOpBus]	 id_ctrl_op,	 // 
	output wire [`RegAddrBus]	 id_dst_addr,	 // GPR写入地址
	output wire					 id_gpr_we_,	 // GPR写入有效
	output wire [`IsaExpBus]	 id_exp_code	 // 
);

	/********** 解码信号 **********/
	wire  [`AluOpBus]			 alu_op;		 // ALU操作
	wire  [`WordDataBus]		 alu_in_0;		 // ALU输入 0
	wire  [`WordDataBus]		 alu_in_1;		 // ALU输入 1
	wire						 br_flag;		 // 
	wire  [`MemOpBus]			 mem_op;		 // 
	wire  [`WordDataBus]		 mem_wr_data;	 // 
	wire  [`CtrlOpBus]			 ctrl_op;		 // 
	wire  [`RegAddrBus]			 dst_addr;		 // GPR写入地址
	wire						 gpr_we_;		 // GPR写入有效
	wire  [`IsaExpBus]			 exp_code;		 // 

	/********** 指令解码器 **********/
	decoder decoder (
		/********** IF/ID流水线寄存器 **********/
		.if_pc			(if_pc),		  // 
		.if_insn		(if_insn),		  // 
		.if_en			(if_en),		  // 
		/********** GPR接口 **********/
		.gpr_rd_data_0	(gpr_rd_data_0),  // 读取数据 0
		.gpr_rd_data_1	(gpr_rd_data_1),  // 读取数据 1
		.gpr_rd_addr_0	(gpr_rd_addr_0),  // 读取地址 0
		.gpr_rd_addr_1	(gpr_rd_addr_1),  // 读取地址 1
		/********** 数据直通 **********/
		// 来自ID阶段的数据直通
		.id_en			(id_en),		  // 
		.id_dst_addr	(id_dst_addr),	  // 
		.id_gpr_we_		(id_gpr_we_),	  // 
		.id_mem_op		(id_mem_op),	  // 
		// 来自EX阶段的数据直通
		.ex_en			(ex_en),		  // 
		.ex_fwd_data	(ex_fwd_data),	  // 
		.ex_dst_addr	(ex_dst_addr),	  // 
		.ex_gpr_we_		(ex_gpr_we_),	  // 
		// 来自MEM阶段的数据直通
		.mem_fwd_data	(mem_fwd_data),	  // 
		/********** 控制寄存器接口 **********/
		.exe_mode		(exe_mode),		  // 
		.creg_rd_data	(creg_rd_data),	  // 
		.creg_rd_addr	(creg_rd_addr),	  // 
		/********** 解码结果 **********/
		.alu_op			(alu_op),		  // ALU操作
		.alu_in_0		(alu_in_0),		  // ALU输入 0
		.alu_in_1		(alu_in_1),		  // ALU输入 1
		.br_addr		(br_addr),		  // 
		.br_taken		(br_taken),		  // 
		.br_flag		(br_flag),		  // 
		.mem_op			(mem_op),		  // 
		.mem_wr_data	(mem_wr_data),	  // 
		.ctrl_op		(ctrl_op),		  // 
		.dst_addr		(dst_addr),		  // 
		.gpr_we_		(gpr_we_),		  // 
		.exp_code		(exp_code),		  // 
		.ld_hazard		(ld_hazard)		  // 
	);

	/********** 流水线寄存器 **********/
	id_reg id_reg (
		/********** 时钟 & 复位 **********/
		.clk			(clk),			  // 时钟
		.reset			(reset),		  // 异步复位
		/********** 解码结果 **********/
		.alu_op			(alu_op),		  // ALU
		.alu_in_0		(alu_in_0),		  // ALU 0
		.alu_in_1		(alu_in_1),		  // ALU 1
		.br_flag		(br_flag),		  // 
		.mem_op			(mem_op),		  // 
		.mem_wr_data	(mem_wr_data),	  // 
		.ctrl_op		(ctrl_op),		  // 
		.dst_addr		(dst_addr),		  // 
		.gpr_we_		(gpr_we_),		  // 
		.exp_code		(exp_code),		  // 
		/********** 流水线控制信号 **********/
		.stall			(stall),		  // 
		.flush			(flush),		  // 
		/********** IF/ID流水线寄存器 **********/
		.if_pc			(if_pc),		  // 
		.if_en			(if_en),		  // 
		/********** ID/EX流水线寄存器 **********/
		.id_pc			(id_pc),		  // 
		.id_en			(id_en),		  // 
		.id_alu_op		(id_alu_op),	  // 
		.id_alu_in_0	(id_alu_in_0),	  // 
		.id_alu_in_1	(id_alu_in_1),	  // 
		.id_br_flag		(id_br_flag),	  // 
		.id_mem_op		(id_mem_op),	  // 
		.id_mem_wr_data (id_mem_wr_data), // 
		.id_ctrl_op		(id_ctrl_op),	  //
		.id_dst_addr	(id_dst_addr),	  // 
		.id_gpr_we_		(id_gpr_we_),	  // 
		.id_exp_code	(id_exp_code)	  // 
	);

endmodule
