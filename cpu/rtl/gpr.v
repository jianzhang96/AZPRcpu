/* 
 -- ============================================================================
 -- FILE NAME	: gpr.v
 -- DESCRIPTION : 通用寄存器
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
module gpr (
	/********** 时钟 & 异步复位 **********/
	input  wire				   clk,				   // 时钟
	input  wire				   reset,			   // 异步复位
	/********** 读取端口 0 **********/
	input  wire [`RegAddrBus]  rd_addr_0,		   // 读取的地址
	output wire [`WordDataBus] rd_data_0,		   // 读取的数据
	/********** 读取端口 1 **********/
	input  wire [`RegAddrBus]  rd_addr_1,		   // 读取的地址
	output wire [`WordDataBus] rd_data_1,		   // 读取的数据
	/********** 写入端口 **********/
	input  wire				   we_,				   // 写入有效信号
	input  wire [`RegAddrBus]  wr_addr,			   // 写入的地址
	input  wire [`WordDataBus] wr_data			   // 写入的数据
);

	/********** 内部信号 **********/
	reg [`WordDataBus]		   gpr [`REG_NUM-1:0]; // 寄存器序列
	integer					   i;				   // 初始化用迭代器

	/********** 读取访问 (Write After Read) **********/
	// 读取端口 0
	assign rd_data_0 = ((we_ == `ENABLE_) && (wr_addr == rd_addr_0)) ? 
					   wr_data : gpr[rd_addr_0];
	// 读取端口 1
	assign rd_data_1 = ((we_ == `ENABLE_) && (wr_addr == rd_addr_1)) ? 
					   wr_data : gpr[rd_addr_1];
   
	/********** 写入访问 **********/
	always @ (posedge clk or `RESET_EDGE reset) begin
		if (reset == `RESET_ENABLE) begin 
			/* 异步复位 */
			for (i = 0; i < `REG_NUM; i = i + 1) begin
				gpr[i]		 <= #1 `WORD_DATA_W'h0;
			end
		end else begin
			/* 写入访问 */
			if (we_ == `ENABLE_) begin 
				gpr[wr_addr] <= #1 wr_data;
			end
		end
	end

endmodule 
