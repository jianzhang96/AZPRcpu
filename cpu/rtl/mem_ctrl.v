/*
 -- ============================================================================
 -- FILE NAME	: mem_ctrl.v
 -- DESCRIPTION : 内存访问控制模块
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
`include "bus.h"

/********** 模块 **********/
module mem_ctrl (
	/********** EX/MEM流水线寄存器 **********/
	input  wire				   ex_en,		   // 流水线数据是否有效
	input  wire [`MemOpBus]	   ex_mem_op,	   // 内存操作
	input  wire [`WordDataBus] ex_mem_wr_data, // 内存写入数据
	input  wire [`WordDataBus] ex_out,		   // 处理结果
	/********** 内存访问接口 **********/
	input  wire [`WordDataBus] rd_data,		   // 读取的数据
	output wire [`WordAddrBus] addr,		   // 地址
	output reg				   as_,			   // 地址选通
	output reg				   rw,			   // 读/写
	output wire [`WordDataBus] wr_data,		   // 写入的数据
	/********** 内存访问结果 **********/
	output reg [`WordDataBus]  out	 ,		   // 内存访问结果
	output reg				   miss_align	   // 未对齐
);

	/********** 内部信号 **********/
	wire [`ByteOffsetBus]	 offset;		   // 字节偏移

	/********** 输出的赋值 **********/
	assign wr_data = ex_mem_wr_data;		   // 写入数据
	assign addr	   = ex_out[`WordAddrLoc];	   // 地址
	assign offset  = ex_out[`ByteOffsetLoc];   // 偏移

	/********** 内存访问控制 **********/
	always @(*) begin
		/* 默认值 */
		miss_align = `DISABLE;
		out		   = `WORD_DATA_W'h0;
		as_		   = `DISABLE_;
		rw		   = `READ;
		/* 内存访问 */
		if (ex_en == `ENABLE) begin
			case (ex_mem_op)
				`MEM_OP_LDW : begin // 字读取
					/* 字节偏移的检测 */
					if (offset == `BYTE_OFFSET_WORD) begin // 对齐
						out			= rd_data;
						as_		   = `ENABLE_;
					end else begin						   // 未对齐
						miss_align	= `ENABLE;
					end
				end
				`MEM_OP_STW : begin // 字写入
					/* 字节偏移的检测 */
					if (offset == `BYTE_OFFSET_WORD) begin // 对齐
						rw			= `WRITE;
						as_		   = `ENABLE_;
					end else begin						   // 未对齐
						miss_align	= `ENABLE;
					end
				end
				default		: begin // 无内存访问
					out			= ex_out;
				end
			endcase
		end
	end

endmodule
