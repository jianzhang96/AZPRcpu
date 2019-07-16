/*
 -- ============================================================================
 -- FILE NAME	: x_s3e_sprom.v
 -- DESCRIPTION : Xilinx Spartan-3E Single Port ROM 伪模型
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
module x_s3e_sprom (
	input wire				  clka,	 // 时钟
	input wire [`RomAddrBus]  addra, // 读取地址
	output reg [`WordDataBus] douta	 // 读取的数据
);

	/********** 内存 **********/
	reg [`WordDataBus] mem [0:`ROM_DEPTH-1];

	/********** 读取访问 **********/
	always @(posedge clka) begin
		douta <= #1 mem[addra];
	end

endmodule
