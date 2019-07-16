/*
 -- ============================================================================
 -- FILE NAME	: ex_stage.v
 -- DESCRIPTION : EX阶段顶层模块。连接ALU和EX阶段流水线寄存器。
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by	 Comment
 -- 1.0.0	  2011/06/27  suito		 新规作成
 -- ============================================================================
*/

/********** 通用头文件 **********/
`include "nettype.h"
`include "global_config.h"
`include "stddef.h"

/********** 单个头文件 **********/
`include "isa.h"
`include "cpu.h"

/********** 模块 **********/
module ex_stage (
	/********** 时钟 & 复位 **********/
	input  wire				   clk,			   // 
	input  wire				   reset,		   // 
	/********** 流水线控制信号 **********/
	input  wire				   stall,		   // 
	input  wire				   flush,		   // 
	input  wire				   int_detect,	   // 
	/********** 数据直通 **********/
	output wire [`WordDataBus] fwd_data,	   // 
	/********** ID/EX流水线寄存器 **********/
	input  wire [`WordAddrBus] id_pc,		   // 
	input  wire				   id_en,		   // 
	input  wire [`AluOpBus]	   id_alu_op,	   // 
	input  wire [`WordDataBus] id_alu_in_0,	   // 
	input  wire [`WordDataBus] id_alu_in_1,	   // 
	input  wire				   id_br_flag,	   // 
	input  wire [`MemOpBus]	   id_mem_op,	   // 
	input  wire [`WordDataBus] id_mem_wr_data, // 
	input  wire [`CtrlOpBus]   id_ctrl_op,	   // 
	input  wire [`RegAddrBus]  id_dst_addr,	   // 
	input  wire				   id_gpr_we_,	   // 
	input  wire [`IsaExpBus]   id_exp_code,	   // 
	/********** EX/MEM流水线寄存器 **********/
	output wire [`WordAddrBus] ex_pc,		   // 
	output wire				   ex_en,		   // 
	output wire				   ex_br_flag,	   // 
	output wire [`MemOpBus]	   ex_mem_op,	   // 
	output wire [`WordDataBus] ex_mem_wr_data, // 
	output wire [`CtrlOpBus]   ex_ctrl_op,	   // 
	output wire [`RegAddrBus]  ex_dst_addr,	   // 
	output wire				   ex_gpr_we_,	   // 
	output wire [`IsaExpBus]   ex_exp_code,	   // 
	output wire [`WordDataBus] ex_out		   // 
);

	/********** ALU的输出 **********/
	wire [`WordDataBus]		   alu_out;		   // 
	wire					   alu_of;		   // 

	/********** 数据直通运算结果 **********/
	assign fwd_data = alu_out;

	/********** ALU **********/
	alu alu (
		.in_0			(id_alu_in_0),	  // 
		.in_1			(id_alu_in_1),	  // 
		.op				(id_alu_op),	  // 
		.out			(alu_out),		  // 
		.of				(alu_of)		  // 
	);

	/********** 流水线寄存器 **********/
	ex_reg ex_reg (
		/********** 时钟 & 复位 **********/
		.clk			(clk),			  // 
		.reset			(reset),		  // 
		/********** ALU的输出 **********/
		.alu_out		(alu_out),		  // 
		.alu_of			(alu_of),		  // 
		/********** 流水线控制信号 **********/
		.stall			(stall),		  // 
		.flush			(flush),		  // 
		.int_detect		(int_detect),	  // 
		/********** ID/EX流水线寄存器 **********/
		.id_pc			(id_pc),		  // 
		.id_en			(id_en),		  // 
		.id_br_flag		(id_br_flag),	  // 
		.id_mem_op		(id_mem_op),	  // 
		.id_mem_wr_data (id_mem_wr_data), // 
		.id_ctrl_op		(id_ctrl_op),	  // 
		.id_dst_addr	(id_dst_addr),	  // 
		.id_gpr_we_		(id_gpr_we_),	  // 
		.id_exp_code	(id_exp_code),	  // 
		/********** EX/MEM流水线寄存器 **********/
		.ex_pc			(ex_pc),		  // 
		.ex_en			(ex_en),		  //
		.ex_br_flag		(ex_br_flag),	  // 
		.ex_mem_op		(ex_mem_op),	  // 
		.ex_mem_wr_data (ex_mem_wr_data), // 
		.ex_ctrl_op		(ex_ctrl_op),	  // 
		.ex_dst_addr	(ex_dst_addr),	  // 
		.ex_gpr_we_		(ex_gpr_we_),	  // 通用寄存器写入有效
		.ex_exp_code	(ex_exp_code),	  // 异常代码
		.ex_out			(ex_out)		  // 处理结果
	);

endmodule
