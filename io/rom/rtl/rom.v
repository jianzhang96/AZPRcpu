/*
 -- ============================================================================
 -- FILE NAME	: rom.v
 -- DESCRIPTION : Read Only Memory
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by	 Comment
 -- 1.0.0	  2011/06/27  suito		 新規作成
 -- ============================================================================
*/

/********** 通用头文件 **********/
`include "nettype.h"
`include "stddef.h"
`include "global_config.h"

/********** 单个头文件 **********/
`include "rom.h"

/********** 模块 **********/
module rom (
	/********** 时钟 & 复位 **********/
	input  wire				   clk,		// 时钟
	input  wire				   reset,	// 异步复位
	/********** 总线接口 **********/
	input  wire				   cs_,		// 片选信号
	input  wire				   as_,		// 地址选通
	input  wire [`RomAddrBus]  addr,	// 地址
	output wire [`WordDataBus] rd_data, // 读取的数据
	output reg				   rdy_		// 就绪信号
);

	/********** Xilinx FPGA Block RAM : 单端口ROM **********/
	x_s3e_sprom x_s3e_sprom (
		.clka  (clk),					// 时钟
		.addra (addr),					// 地址
		.douta (rd_data)				// 读取的数据
	);

	/********** 生成就绪信号 **********/
	always @(posedge clk or `RESET_EDGE reset) begin
		if (reset == `RESET_ENABLE) begin
			/* 异步复位 */
			rdy_ <= #1 `DISABLE_;
		end else begin
			/* 生成就绪信号 */
			if ((cs_ == `ENABLE_) && (as_ == `ENABLE_)) begin
				rdy_ <= #1 `ENABLE_;
			end else begin
				rdy_ <= #1 `DISABLE_;
			end
		end
	end

endmodule
