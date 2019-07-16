/*
 -- ============================================================================
 -- FILE NAME	: ctrl.v
 -- DESCRIPTION : CPU控制模块
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
`include "rom.h"
`include "spm.h"

/********** 模块 **********/
module ctrl (
	/********** 时钟 & 复位 **********/
	input  wire					  clk,			// 时钟
	input  wire					  reset,		// 异步复位
	/********** 控制寄存器接口 **********/
	input  wire [`RegAddrBus]	  creg_rd_addr, // 读取地址
	output reg	[`WordDataBus]	  creg_rd_data, // 读取数据
	output reg	[`CpuExeModeBus]  exe_mode,		// 执行模式
	/********** 中断 **********/
	input  wire [`CPU_IRQ_CH-1:0] irq,			// 中断请求
	output reg					  int_detect,	// 中断检测
	/********** ID/EX流水线寄存器 **********/
	input  wire [`WordAddrBus]	  id_pc,		// ID阶段的程序计数器
	/********** MEM/WB流水线寄存器 **********/
	input  wire [`WordAddrBus]	  mem_pc,		// MEM阶段的程序计数器
	input  wire					  mem_en,		// 流水线数据是否有效
	input  wire					  mem_br_flag,	// 分支标志位
	input  wire [`CtrlOpBus]	  mem_ctrl_op,	// 控制寄存器操作
	input  wire [`RegAddrBus]	  mem_dst_addr, // 通用寄存器写入地址
	input  wire [`IsaExpBus]	  mem_exp_code, // 异常代码
	input  wire [`WordDataBus]	  mem_out,		// 处理结果
	/********** 流水线控制信号 **********/
	// 流水线的状态
	input  wire					  if_busy,		// IF阶段忙信号
	input  wire					  ld_hazard,	// Load冒险
	input  wire					  mem_busy,		// MEM阶段忙信号
	// 延迟信号
	output wire					  if_stall,		// IF阶段延迟
	output wire					  id_stall,		// ID阶段延迟
	output wire					  ex_stall,		// EX阶段延迟
	output wire					  mem_stall,	// MEM阶段延迟
	// 刷新信号
	output wire					  if_flush,		// IF阶段刷新
	output wire					  id_flush,		// ID阶段刷新
	output wire					  ex_flush,		// EX阶段刷新
	output wire					  mem_flush,	// MEM阶段刷新
	output reg	[`WordAddrBus]	  new_pc		// 新程序计数器
);

	/********** 控制寄存器 **********/
	reg							 int_en;		// 0号控制寄存器 : 中断有效
	reg	 [`CpuExeModeBus]		 pre_exe_mode;	// 1号控制寄存器 : 执行模式
	reg							 pre_int_en;	// 1号控制寄存器 : 中断有效
	reg	 [`WordAddrBus]			 epc;			// 3号控制寄存器 : 异常程序计数器
	reg	 [`WordAddrBus]			 exp_vector;	// 4号控制寄存器 : 异常向量
	reg	 [`IsaExpBus]			 exp_code;		// 5号控制寄存器 : 异常代码
	reg							 dly_flag;		// 6号控制寄存器 : 延迟间隙标志位
	reg	 [`CPU_IRQ_CH-1:0]		 mask;			// 7号控制寄存器 : 中断屏蔽

	/********** 内部信号 **********/
	reg [`WordAddrBus]		  pre_pc;			// 前一个程序寄存器
	reg						  br_flag;			// 分支标志位

	/********** 流水线控制信号 **********/
	// 延迟信号
	wire   stall	 = if_busy | mem_busy;
	assign if_stall	 = stall | ld_hazard;
	assign id_stall	 = stall;
	assign ex_stall	 = stall;
	assign mem_stall = stall;
	// 刷新信号
	reg	   flush;
	assign if_flush	 = flush;
	assign id_flush	 = flush | ld_hazard;
	assign ex_flush	 = flush;
	assign mem_flush = flush;

	/********** 流水线刷新控制 **********/
	always @(*) begin
		/* 默认值 */
		new_pc = `WORD_ADDR_W'h0;
		flush  = `DISABLE;
		/* 流水线刷新 */
		if (mem_en == `ENABLE) begin // 流水线数据有效
			if (mem_exp_code != `ISA_EXP_NO_EXP) begin		 // 发生异常
				new_pc = exp_vector;
				flush  = `ENABLE;
			end else if (mem_ctrl_op == `CTRL_OP_EXRT) begin // EXRT指令
				new_pc = epc;
				flush  = `ENABLE;
			end else if (mem_ctrl_op == `CTRL_OP_WRCR) begin // WRCR指令
				new_pc = mem_pc;
				flush  = `ENABLE;
			end
		end
	end

	/********** 中断检测 **********/
	always @(*) begin
		if ((int_en == `ENABLE) && ((|((~mask) & irq)) == `ENABLE)) begin
			int_detect = `ENABLE;
		end else begin
			int_detect = `DISABLE;
		end
	end
   
	/********** 读取访问 **********/
	always @(*) begin
		case (creg_rd_addr)
		   `CREG_ADDR_STATUS	 : begin // 0号 :状态
			   creg_rd_data = {{`WORD_DATA_W-2{1'b0}}, int_en, exe_mode};
		   end
		   `CREG_ADDR_PRE_STATUS : begin // 1号 :异常发生前的状态
			   creg_rd_data = {{`WORD_DATA_W-2{1'b0}}, 
							   pre_int_en, pre_exe_mode};
		   end
		   `CREG_ADDR_PC		 : begin // 2号 :程序计数器
			   creg_rd_data = {id_pc, `BYTE_OFFSET_W'h0};
		   end
		   `CREG_ADDR_EPC		 : begin // 3号 :异常程序计数器
			   creg_rd_data = {epc, `BYTE_OFFSET_W'h0};
		   end
		   `CREG_ADDR_EXP_VECTOR : begin // 4号:异常向量
			   creg_rd_data = {exp_vector, `BYTE_OFFSET_W'h0};
		   end
		   `CREG_ADDR_CAUSE		 : begin // 5号 :异常原因
			   creg_rd_data = {{`WORD_DATA_W-1-`ISA_EXP_W{1'b0}}, 
							   dly_flag, exp_code};
		   end
		   `CREG_ADDR_INT_MASK	 : begin // 6号 :中断屏蔽
			   creg_rd_data = {{`WORD_DATA_W-`CPU_IRQ_CH{1'b0}}, mask};
		   end
		   `CREG_ADDR_IRQ		 : begin // 6号:中断原因
			   creg_rd_data = {{`WORD_DATA_W-`CPU_IRQ_CH{1'b0}}, irq};
		   end
		   `CREG_ADDR_ROM_SIZE	 : begin // 7号:ROM容量
			   creg_rd_data = $unsigned(`ROM_SIZE);
		   end
		   `CREG_ADDR_SPM_SIZE	 : begin // 8号:SPM容量
			   creg_rd_data = $unsigned(`SPM_SIZE);
		   end
		   `CREG_ADDR_CPU_INFO	 : begin // 9号:CPU信息
			   creg_rd_data = {`RELEASE_YEAR, `RELEASE_MONTH, 
							   `RELEASE_VERSION, `RELEASE_REVISION};
		   end
		   default				 : begin // 默认值
			   creg_rd_data = `WORD_DATA_W'h0;
		   end
		endcase
	end

	/********** CPU的控制 **********/
	always @(posedge clk or `RESET_EDGE reset) begin
		if (reset == `RESET_ENABLE) begin
			/* 异步复位 */
			exe_mode	 <= #1 `CPU_KERNEL_MODE;
			int_en		 <= #1 `DISABLE;
			pre_exe_mode <= #1 `CPU_KERNEL_MODE;
			pre_int_en	 <= #1 `DISABLE;
			exp_code	 <= #1 `ISA_EXP_NO_EXP;
			mask		 <= #1 {`CPU_IRQ_CH{`ENABLE}};
			dly_flag	 <= #1 `DISABLE;
			epc			 <= #1 `WORD_ADDR_W'h0;
			exp_vector	 <= #1 `WORD_ADDR_W'h0;
			pre_pc		 <= #1 `WORD_ADDR_W'h0;
			br_flag		 <= #1 `DISABLE;
		end else begin
			/* 更新CPU的状态 */
			if ((mem_en == `ENABLE) && (stall == `DISABLE)) begin
				/* PC和分支标志位的保存 */
				pre_pc		 <= #1 mem_pc;
				br_flag		 <= #1 mem_br_flag;
				/* CPU状态控制 */
				if (mem_exp_code != `ISA_EXP_NO_EXP) begin		 // 发生异常
					exe_mode	 <= #1 `CPU_KERNEL_MODE;
					int_en		 <= #1 `DISABLE;
					pre_exe_mode <= #1 exe_mode;
					pre_int_en	 <= #1 int_en;
					exp_code	 <= #1 mem_exp_code;
					dly_flag	 <= #1 br_flag;
					epc			 <= #1 pre_pc;
				end else if (mem_ctrl_op == `CTRL_OP_EXRT) begin // EXRT命令
					exe_mode	 <= #1 pre_exe_mode;
					int_en		 <= #1 pre_int_en;
				end else if (mem_ctrl_op == `CTRL_OP_WRCR) begin // WRCR命令
				   /* 写入控制寄存器 */
					case (mem_dst_addr)
						`CREG_ADDR_STATUS	  : begin // 状态
							exe_mode	 <= #1 mem_out[`CregExeModeLoc];
							int_en		 <= #1 mem_out[`CregIntEnableLoc];
						end
						`CREG_ADDR_PRE_STATUS : begin // 异常发生前的状态
							pre_exe_mode <= #1 mem_out[`CregExeModeLoc];
							pre_int_en	 <= #1 mem_out[`CregIntEnableLoc];
						end
						`CREG_ADDR_EPC		  : begin // 异常程序计数器
							epc			 <= #1 mem_out[`WordAddrLoc];
						end
						`CREG_ADDR_EXP_VECTOR : begin // 异常向量
							exp_vector	 <= #1 mem_out[`WordAddrLoc];
						end
						`CREG_ADDR_CAUSE	  : begin // 异常原因
							dly_flag	 <= #1 mem_out[`CregDlyFlagLoc];
							exp_code	 <= #1 mem_out[`CregExpCodeLoc];
						end
						`CREG_ADDR_INT_MASK	  : begin // 中断屏蔽
							mask		 <= #1 mem_out[`CPU_IRQ_CH-1:0];
						end
					endcase
				end
			end
		end
	end

endmodule
