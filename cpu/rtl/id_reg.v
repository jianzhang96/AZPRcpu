/* 
 -- ============================================================================
 -- FILE NAME	: id_reg.v
 -- DESCRIPTION : ID阶段流水线寄存器
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
module id_reg (
	/********** 时钟 & 复位 **********/
	input  wire				   clk,			   // 时钟
	input  wire				   reset,		   // 异步复位
	/********** 解码结果 **********/
	input  wire [`AluOpBus]	   alu_op,		   // ALU操作
	input  wire [`WordDataBus] alu_in_0,	   // ALU输入 0
	input  wire [`WordDataBus] alu_in_1,	   // ALU输入 1
	input  wire				   br_flag,		   // 分支符号位
	input  wire [`MemOpBus]	   mem_op,		   // 内存操作
	input  wire [`WordDataBus] mem_wr_data,	   // 内存写入数据
	input  wire [`CtrlOpBus]   ctrl_op,		   // 控制操作
	input  wire [`RegAddrBus]  dst_addr,	   // 通用寄存器写入地址
	input  wire				   gpr_we_,		   // 通用寄存器写入有效
	input  wire [`IsaExpBus]   exp_code,	   // 异常代码
	/********** 流水线控制信号 **********/
	input  wire				   stall,		   // 延迟
	input  wire				   flush,		   // 刷新
	/********** IF/ID流水线寄存器 **********/
	input  wire [`WordAddrBus] if_pc,		   // 程序计数器
	input  wire				   if_en,		   // 流水线数据是否有效
	/********** ID/EX流水线寄存器 **********/
	output reg	[`WordAddrBus] id_pc,		   // 程序计数器
	output reg				   id_en,		   // 流水线数据是否有效
	output reg	[`AluOpBus]	   id_alu_op,	   // ALU操作
	output reg	[`WordDataBus] id_alu_in_0,	   // ALU输入 0
	output reg	[`WordDataBus] id_alu_in_1,	   // ALU输入 1
	output reg				   id_br_flag,	   // 分支符号位
	output reg	[`MemOpBus]	   id_mem_op,	   // 内存操作
	output reg	[`WordDataBus] id_mem_wr_data, // 内存写入数据
	output reg	[`CtrlOpBus]   id_ctrl_op,	   // 控制操作
	output reg	[`RegAddrBus]  id_dst_addr,	   // 通用寄存器写入地址
	output reg				   id_gpr_we_,	   // 通用寄存器写入有效
	output reg [`IsaExpBus]	   id_exp_code	   // 异常代码
);

	/********** 流水线寄存器 **********/
	always @(posedge clk or `RESET_EDGE reset) begin
		if (reset == `RESET_ENABLE) begin 
			/* 异步复位 */
			id_pc		   <= #1 `WORD_ADDR_W'h0;
			id_en		   <= #1 `DISABLE;
			id_alu_op	   <= #1 `ALU_OP_NOP;
			id_alu_in_0	   <= #1 `WORD_DATA_W'h0;
			id_alu_in_1	   <= #1 `WORD_DATA_W'h0;
			id_br_flag	   <= #1 `DISABLE;
			id_mem_op	   <= #1 `MEM_OP_NOP;
			id_mem_wr_data <= #1 `WORD_DATA_W'h0;
			id_ctrl_op	   <= #1 `CTRL_OP_NOP;
			id_dst_addr	   <= #1 `REG_ADDR_W'd0;
			id_gpr_we_	   <= #1 `DISABLE_;
			id_exp_code	   <= #1 `ISA_EXP_NO_EXP;
		end else begin
			/* 流水线寄存器的更新 */
			if (stall == `DISABLE) begin 
				if (flush == `ENABLE) begin // 刷新
				   id_pc		  <= #1 `WORD_ADDR_W'h0;
				   id_en		  <= #1 `DISABLE;
				   id_alu_op	  <= #1 `ALU_OP_NOP;
				   id_alu_in_0	  <= #1 `WORD_DATA_W'h0;
				   id_alu_in_1	  <= #1 `WORD_DATA_W'h0;
				   id_br_flag	  <= #1 `DISABLE;
				   id_mem_op	  <= #1 `MEM_OP_NOP;
				   id_mem_wr_data <= #1 `WORD_DATA_W'h0;
				   id_ctrl_op	  <= #1 `CTRL_OP_NOP;
				   id_dst_addr	  <= #1 `REG_ADDR_W'd0;
				   id_gpr_we_	  <= #1 `DISABLE_;
				   id_exp_code	  <= #1 `ISA_EXP_NO_EXP;
				end else begin				// 下一个数据
				   id_pc		  <= #1 if_pc;
				   id_en		  <= #1 if_en;
				   id_alu_op	  <= #1 alu_op;
				   id_alu_in_0	  <= #1 alu_in_0;
				   id_alu_in_1	  <= #1 alu_in_1;
				   id_br_flag	  <= #1 br_flag;
				   id_mem_op	  <= #1 mem_op;
				   id_mem_wr_data <= #1 mem_wr_data;
				   id_ctrl_op	  <= #1 ctrl_op;
				   id_dst_addr	  <= #1 dst_addr;
				   id_gpr_we_	  <= #1 gpr_we_;
				   id_exp_code	  <= #1 exp_code;
				end
			end
		end
	end

endmodule
