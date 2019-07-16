/*
 -- ============================================================================
 -- FILE NAME	: alu.v
 -- DESCRIPTION : 算术逻辑运算单元
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
`include "cpu.h"

/********** 模块 **********/
module alu (
	input  wire [`WordDataBus] in_0,  // 输入 0
	input  wire [`WordDataBus] in_1,  // 输入 1
	input  wire [`AluOpBus]	   op,	  // 操作
	output reg	[`WordDataBus] out,	  // 输出
	output reg				   of	  // 溢出
);

	/********** 内部信号 **********/
	wire signed [`WordDataBus] s_in_0 = $signed(in_0); // 有符号输入 0
	wire signed [`WordDataBus] s_in_1 = $signed(in_1); // 有符号输入 1
	wire signed [`WordDataBus] s_out  = $signed(out);  // 有符号输出

	/********** 算术逻辑运算 **********/
	always @(*) begin
		case (op)
			`ALU_OP_AND	 : begin // 逻辑与（AND）
				out	  = in_0 & in_1;
			end
			`ALU_OP_OR	 : begin // 逻辑或（OR）
				out	  = in_0 | in_1;
			end
			`ALU_OP_XOR	 : begin // 逻辑异或（XOR）
				out	  = in_0 ^ in_1;
			end
			`ALU_OP_ADDS : begin // 有符号加法
				out	  = in_0 + in_1;
			end
			`ALU_OP_ADDU : begin // 无符号加法
				out	  = in_0 + in_1;
			end
			`ALU_OP_SUBS : begin // 有符号减法
				out	  = in_0 - in_1;
			end
			`ALU_OP_SUBU : begin // 无符号减法
				out	  = in_0 - in_1;
			end
			`ALU_OP_SHRL : begin // 逻辑右移
				out	  = in_0 >> in_1[`ShAmountLoc];
			end
			`ALU_OP_SHLL : begin // 逻辑左移
				out	  = in_0 << in_1[`ShAmountLoc];
			end
			default		 : begin // 默认值 (No Operation)
				out	  = in_0;
			end
		endcase
	end

	/********** 溢出检测 **********/
	always @(*) begin
		case (op)
			`ALU_OP_ADDS : begin // 加法溢出检测
				if (((s_in_0 > 0) && (s_in_1 > 0) && (s_out < 0)) ||
					((s_in_0 < 0) && (s_in_1 < 0) && (s_out > 0))) begin
					of = `ENABLE;
				end else begin
					of = `DISABLE;
				end
			end
			`ALU_OP_SUBS : begin // 减法溢出检测
				if (((s_in_0 < 0) && (s_in_1 > 0) && (s_out > 0)) ||
					((s_in_0 > 0) && (s_in_1 < 0) && (s_out < 0))) begin
					of = `ENABLE;
				end else begin
					of = `DISABLE;
				end
			end
			default		: begin // 默认值
				of = `DISABLE;
			end
		endcase
	end

endmodule
