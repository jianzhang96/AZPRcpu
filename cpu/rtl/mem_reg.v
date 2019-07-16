/*
 -- ============================================================================
 -- FILE NAME	: mem_reg.v
 -- DESCRIPTION : MEM阶段流水线寄存器
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
module mem_reg (
	/********** 时钟 & 复位 **********/
	input  wire				   clk,			 // 时钟 
	input  wire				   reset,		 // 异步复位
	/********** 内存访问结果 **********/
	input  wire [`WordDataBus] out,			 // 结果
	input  wire				   miss_align,	 // 未对齐
	/********** 流水线控制信号 **********/
	input  wire				   stall,		 // 延迟
	input  wire				   flush,		 // 刷新
	/********** EX/MEM流水线寄存器 **********/
	input  wire [`WordAddrBus] ex_pc,		 // 程序计数器
	input  wire				   ex_en,		 // 流水线数据是否有效
	input  wire				   ex_br_flag,	 // 分支标志位
	input  wire [`CtrlOpBus]   ex_ctrl_op,	 // 控制寄存器操作
	input  wire [`RegAddrBus]  ex_dst_addr,	 // 通用寄存器写入地址
	input  wire				   ex_gpr_we_,	 // 通用寄存器写入有效
	input  wire [`IsaExpBus]   ex_exp_code,	 // 异常代码
	/********** MEM/WB流水线寄存器 **********/
	output reg	[`WordAddrBus] mem_pc,		 // 程序计数器
	output reg				   mem_en,		 // 流水线数据是否有效
	output reg				   mem_br_flag,	 // 分支标志位
	output reg	[`CtrlOpBus]   mem_ctrl_op,	 // 控制寄存器操作
	output reg	[`RegAddrBus]  mem_dst_addr, // 通用寄存器写入地址
	output reg				   mem_gpr_we_,	 // 通用寄存器写入有效
	output reg	[`IsaExpBus]   mem_exp_code, // 异常代码
	output reg	[`WordDataBus] mem_out		 // 处理结果
);

	/********** 流水线寄存器 **********/
	always @(posedge clk or `RESET_EDGE reset) begin
		if (reset == `RESET_ENABLE) begin	 
			/* 异步复位 */
			mem_pc		 <= #1 `WORD_ADDR_W'h0;
			mem_en		 <= #1 `DISABLE;
			mem_br_flag	 <= #1 `DISABLE;
			mem_ctrl_op	 <= #1 `CTRL_OP_NOP;
			mem_dst_addr <= #1 `REG_ADDR_W'h0;
			mem_gpr_we_	 <= #1 `DISABLE_;
			mem_exp_code <= #1 `ISA_EXP_NO_EXP;
			mem_out		 <= #1 `WORD_DATA_W'h0;
		end else begin
			if (stall == `DISABLE) begin 
				/* 流水线寄存器的更新 */
				if (flush == `ENABLE) begin				  // 刷新
					mem_pc		 <= #1 `WORD_ADDR_W'h0;
					mem_en		 <= #1 `DISABLE;
					mem_br_flag	 <= #1 `DISABLE;
					mem_ctrl_op	 <= #1 `CTRL_OP_NOP;
					mem_dst_addr <= #1 `REG_ADDR_W'h0;
					mem_gpr_we_	 <= #1 `DISABLE_;
					mem_exp_code <= #1 `ISA_EXP_NO_EXP;
					mem_out		 <= #1 `WORD_DATA_W'h0;
				end else if (miss_align == `ENABLE) begin // 未对齐异常
					mem_pc		 <= #1 ex_pc;
					mem_en		 <= #1 ex_en;
					mem_br_flag	 <= #1 ex_br_flag;
					mem_ctrl_op	 <= #1 `CTRL_OP_NOP;
					mem_dst_addr <= #1 `REG_ADDR_W'h0;
					mem_gpr_we_	 <= #1 `DISABLE_;
					mem_exp_code <= #1 `ISA_EXP_MISS_ALIGN;
					mem_out		 <= #1 `WORD_DATA_W'h0;
				end else begin							  // 下一个数据
					mem_pc		 <= #1 ex_pc;
					mem_en		 <= #1 ex_en;
					mem_br_flag	 <= #1 ex_br_flag;
					mem_ctrl_op	 <= #1 ex_ctrl_op;
					mem_dst_addr <= #1 ex_dst_addr;
					mem_gpr_we_	 <= #1 ex_gpr_we_;
					mem_exp_code <= #1 ex_exp_code;
					mem_out		 <= #1 out;
				end
			end
		end
	end

endmodule
