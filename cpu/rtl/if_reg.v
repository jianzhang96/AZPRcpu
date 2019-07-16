/*
 -- ============================================================================
 -- FILE NAME	: if_reg.v
 -- DESCRIPTION : IF阶段流水线寄存器
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
module if_reg (
	/********** 时钟 & 复位 **********/
	input  wire				   clk,		   // 时钟
	input  wire				   reset,	   // 异步复位
	/********** 读取数据 **********/
	input  wire [`WordDataBus] insn,	   // 读取的指令
	/********** 流水线控制信号 **********/
	input  wire				   stall,	   // 延迟
	input  wire				   flush,	   // 刷新
	input  wire [`WordAddrBus] new_pc,	   // 新程序计数器值
	input  wire				   br_taken,   // 分支成立
	input  wire [`WordAddrBus] br_addr,	   // 分支目标地址
	/********** IF/ID流水线寄存器 **********/
	output reg	[`WordAddrBus] if_pc,	   // 程序计数器
	output reg	[`WordDataBus] if_insn,	   // 指令
	output reg				   if_en	   // 流水线数据有效标志位
);

	/********** 流水线寄存器 **********/
	always @(posedge clk or `RESET_EDGE reset) begin
		if (reset == `RESET_ENABLE) begin 
			/* 异步复位 */
			if_pc	<= #1 `RESET_VECTOR;
			if_insn <= #1 `ISA_NOP;
			if_en	<= #1 `DISABLE;
		end else begin
			/* 更新流水线寄存器 */
			if (stall == `DISABLE) begin 
				if (flush == `ENABLE) begin				// 刷新
					if_pc	<= #1 new_pc;
					if_insn <= #1 `ISA_NOP;
					if_en	<= #1 `DISABLE;
				end else if (br_taken == `ENABLE) begin // 分支成立
					if_pc	<= #1 br_addr;
					if_insn <= #1 insn;
					if_en	<= #1 `ENABLE;
				end else begin							// 下一条地址
					if_pc	<= #1 if_pc + 1'd1;
					if_insn <= #1 insn;
					if_en	<= #1 `ENABLE;
				end
			end
		end
	end

endmodule
