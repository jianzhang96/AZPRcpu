/*
 -- ============================================================================
 -- FILE NAME	: mem_stage.v
 -- DESCRIPTION : MEM阶段顶层模块用来连接内存访问控制模块、MEM流水线寄存器和总线接口
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
module mem_stage (
	/********** 时钟 & 复位 **********/
	input  wire				   clk,			   // 
	input  wire				   reset,		   // 
	/********** 流水线控制信号 **********/
	input  wire				   stall,		   // 
	input  wire				   flush,		   // 
	output wire				   busy,		   // 
	/********** 数据直通 **********/
	output wire [`WordDataBus] fwd_data,	   // 
	/********** SPM接口 **********/
	input  wire [`WordDataBus] spm_rd_data,	   // 
	output wire [`WordAddrBus] spm_addr,	   //
	output wire				   spm_as_,		   // 
	output wire				   spm_rw,		   // 
	output wire [`WordDataBus] spm_wr_data,	   // 
	/********** 总线接口 **********/
	input  wire [`WordDataBus] bus_rd_data,	   // 
	input  wire				   bus_rdy_,	   // 
	input  wire				   bus_grnt_,	   // 
	output wire				   bus_req_,	   // 
	output wire [`WordAddrBus] bus_addr,	   // 
	output wire				   bus_as_,		   // 
	output wire				   bus_rw,		   // 
	output wire [`WordDataBus] bus_wr_data,	   // 
	/********** EX/MEM流水线寄存器 **********/
	input  wire [`WordAddrBus] ex_pc,		   // 
	input  wire				   ex_en,		   // 
	input  wire				   ex_br_flag,	   // 
	input  wire [`MemOpBus]	   ex_mem_op,	   // 
	input  wire [`WordDataBus] ex_mem_wr_data, // 
	input  wire [`CtrlOpBus]   ex_ctrl_op,	   // 
	input  wire [`RegAddrBus]  ex_dst_addr,	   //
	input  wire				   ex_gpr_we_,	   // 
	input  wire [`IsaExpBus]   ex_exp_code,	   // 
	input  wire [`WordDataBus] ex_out,		   // 
	/********** MEM/WB流水线寄存器 **********/
	output wire [`WordAddrBus] mem_pc,		   // 
	output wire				   mem_en,		   // 
	output wire				   mem_br_flag,	   // 
	output wire [`CtrlOpBus]   mem_ctrl_op,	   // 
	output wire [`RegAddrBus]  mem_dst_addr,   // 
	output wire				   mem_gpr_we_,	   // 
	output wire [`IsaExpBus]   mem_exp_code,   // 
	output wire [`WordDataBus] mem_out		   // 
);

	/********** 内部信号 **********/
	wire [`WordDataBus]		   rd_data;		   // 
	wire [`WordAddrBus]		   addr;		   // 
	wire					   as_;			   // 
	wire					   rw;			   // 
	wire [`WordDataBus]		   wr_data;		   // 
	wire [`WordDataBus]		   out;			   // 
	wire					   miss_align;	   // 

	/********** 结果数据直通 **********/
	assign fwd_data	 = out;

	/********** 内存访问控制模块 **********/
	mem_ctrl mem_ctrl (
		/********** EX/MEM流水线寄存器 **********/
		.ex_en			(ex_en),			   // 
		.ex_mem_op		(ex_mem_op),		   // 
		.ex_mem_wr_data (ex_mem_wr_data),	   // 
		.ex_out			(ex_out),			   // 
		/********** 内存访问接口 **********/
		.rd_data		(rd_data),			   // 
		.addr			(addr),				   // 
		.as_			(as_),				   // 
		.rw				(rw),				   // 
		.wr_data		(wr_data),			   // 
		/********** 内存访问结果 **********/
		.out			(out),				   // 
		.miss_align		(miss_align)		   // 
	);

	/********** 总线接口 **********/
	bus_if bus_if (
		/********** 时钟 & 复位 **********/
		.clk		 (clk),					   // 
		.reset		 (reset),				   // 
		/********** 流水线控制信号 **********/
		.stall		 (stall),				   // 
		.flush		 (flush),				   // 
		.busy		 (busy),				   // 
		/********** CPU接口 **********/
		.addr		 (addr),				   // 
		.as_		 (as_),					   // 
		.rw			 (rw),					   // 
		.wr_data	 (wr_data),				   // 
		.rd_data	 (rd_data),				   // 
		/********** 便笺式存储器接口 **********/
		.spm_rd_data (spm_rd_data),			   // 
		.spm_addr	 (spm_addr),			   // 
		.spm_as_	 (spm_as_),				   // 
		.spm_rw		 (spm_rw),				   // 
		.spm_wr_data (spm_wr_data),			   // 
		/********** 总线接口 **********/
		.bus_rd_data (bus_rd_data),			   // 
		.bus_rdy_	 (bus_rdy_),			   // 
		.bus_grnt_	 (bus_grnt_),			   // 
		.bus_req_	 (bus_req_),			   // 
		.bus_addr	 (bus_addr),			   // 
		.bus_as_	 (bus_as_),				   // 
		.bus_rw		 (bus_rw),				   // 
		.bus_wr_data (bus_wr_data)			   // 
	);

	/********** MEM阶段流水线寄存器 **********/
	mem_reg mem_reg (
		/********** 时钟 & 复位 **********/
		.clk		  (clk),				   // 
		.reset		  (reset),				   // 
		/********** 内存访问结果 **********/
		.out		  (out),				   //
		.miss_align	  (miss_align),			   // 
		/********** 流水线控制信号 **********/
		.stall		  (stall),				   // 
		.flush		  (flush),				   // 
		/********** EX/MEM流水线寄存器 **********/
		.ex_pc		  (ex_pc),				   // 
		.ex_en		  (ex_en),				   // 
		.ex_br_flag	  (ex_br_flag),			   // 
		.ex_ctrl_op	  (ex_ctrl_op),			   // 
		.ex_dst_addr  (ex_dst_addr),		   // 
		.ex_gpr_we_	  (ex_gpr_we_),			   // 
		.ex_exp_code  (ex_exp_code),		   // 
		/********** MEM/WB流水线寄存器 **********/
		.mem_pc		  (mem_pc),				   // 
		.mem_en		  (mem_en),				   // 
		.mem_br_flag  (mem_br_flag),		   // 
		.mem_ctrl_op  (mem_ctrl_op),		   // 
		.mem_dst_addr (mem_dst_addr),		   // 
		.mem_gpr_we_  (mem_gpr_we_),		   // 
		.mem_exp_code (mem_exp_code),		   // 
		.mem_out	  (mem_out)				   // 
	);

endmodule
