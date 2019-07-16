/* 
 -- ============================================================================
 -- FILE NAME	: clk_gen.v
 -- DESCRIPTION : 时钟生成模块
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by	 Comment
 -- 1.0.0	  2011/06/27  suito		 新規作成
 -- ============================================================================
*/

/********** 通用头文件 **********/
`include "nettype.h"
`include "stddef.h"
`include "global_config.h"

/********** モジュール **********/
module clk_gen (
	/********** 时钟 & 复位 **********/
	input wire	clk_ref,   // 主时钟
	input wire	reset_sw,  // 复位按钮
	/********** 生成时钟 **********/
	output wire clk,	   // 时钟
	output wire clk_,	   // 反相时钟
	/********** 芯片复位 **********/
	output wire chip_reset // 芯片复位
);

	/********** 内部信号 **********/
	wire		locked;	   // 锁
	wire		dcm_reset; // DCM复位

	/********** 复位信号的生成 **********/
	// DCM复位
	assign dcm_reset  = (reset_sw == `RESET_ENABLE) ? `ENABLE : `DISABLE;
	// 芯片复位
	assign chip_reset = ((reset_sw == `RESET_ENABLE) || (locked == `DISABLE)) ?
							`RESET_ENABLE : `RESET_DISABLE;

	/********** Xilinx DCM (Digitl Clock Manager) **********/
	x_s3e_dcm x_s3e_dcm (
		.CLKIN_IN		 (clk_ref),	  // 主时钟
		.RST_IN			 (dcm_reset), // DCM复位
		.CLK0_OUT		 (clk),		  // 时钟
		.CLK180_OUT		 (clk_),	  // 反相时钟
		.LOCKED_OUT		 (locked)	  // 锁频信号
   );

endmodule
