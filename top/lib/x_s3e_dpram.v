/*
 -- ============================================================================
 -- FILE NAME	: x_s3e_dpram.v
 -- DESCRIPTION : Xilinx Spartan-3E Dual Port RAM 伪模型
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
`include "spm.h"

/********** 模块 **********/
module x_s3e_dpram (
	/********** 端口 A **********/
	input  wire				   clka,  // 时钟
	input  wire [`SpmAddrBus]  addra, // 地址
	input  wire [`WordDataBus] dina,  // 写入的数据
	input  wire				   wea,	  // 写入有效
	output reg	[`WordDataBus] douta, // 读取的数据
	/********** 端口 B **********/
	input  wire				   clkb,  // 时钟
	input  wire [`SpmAddrBus]  addrb, // 地址
	input  wire [`WordDataBus] dinb,  // 写入的数据
	input  wire				   web,	  // 写入有效
	output reg	[`WordDataBus] doutb  // 读取的数据
);

	/********** 内存 **********/
	reg [`WordDataBus] mem [0:`SPM_DEPTH-1];

	/********** 内存访问（端口 A） **********/
	always @(posedge clka) begin
		// 读取访问
		if ((web == `ENABLE) && (addra == addrb)) begin
			douta	  <= #1 dinb;
		end else begin
			douta	  <= #1 mem[addra];
		end
		// 写入访问
		if (wea == `ENABLE) begin
			mem[addra]<= #1 dina;
		end
	end

	/********** 内存访问（端口 B） **********/
	always @(posedge clkb) begin
		// 读取访问
		if ((wea == `ENABLE) && (addrb == addra)) begin
			doutb	  <= #1 dina;
		end else begin
			doutb	  <= #1 mem[addrb];
		end
		// 写入访问
		if (web == `ENABLE) begin
			mem[addrb]<= #1 dinb;
		end
	end

endmodule
