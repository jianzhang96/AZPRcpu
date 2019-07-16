/*
 -- ============================================================================
 -- FILE NAME	: x_s3e_dcm.v
 -- DESCRIPTION : Xilinx Spartan-3E DCM 伪模型
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by	 Comment
 -- 1.0.0	  2011/06/27  suito		 新規作成
 -- ============================================================================
*/

/********** 通用头文件 **********/
`include "nettype.h"

/********** 模块 **********/
module x_s3e_dcm (
	input  wire CLKIN_IN,		 // 主时钟
	input  wire RST_IN,			 // 异步复位
	output wire CLK0_OUT,		 // 与CLKIN_IN相同频率的输出（φ0）
	output wire CLK180_OUT,		 // 与CLKIN_IN相同频率的输出（φ180）
	output wire LOCKED_OUT		 // 锁频信号（高电平有效）
);

	/********** 输出时钟 **********/
	assign CLK0_OUT	  = CLKIN_IN;
	assign CLK180_OUT = ~CLKIN_IN;
	assign LOCKED_OUT = ~RST_IN;
   
endmodule
