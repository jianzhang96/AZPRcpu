/* 
 -- ============================================================================
 -- FILE NAME	: chip_top.v
 -- DESCRIPTION : 顶层模块
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
`include "gpio.h"

/********** 模块 **********/
module chip_top (
	/********** 时钟 & 复位 **********/
	input wire				   clk_ref,		  // 主时钟
	input wire				   reset_sw		  // 复位按钮
	/********** UART **********/
`ifdef IMPLEMENT_UART // UART实现
	, input wire			   uart_rx		  // UART接收信号
	, output wire			   uart_tx		  // UART发送信号
`endif
	/********** 通用输入/输出端口 **********/
`ifdef IMPLEMENT_GPIO // GPIO实现
`ifdef GPIO_IN_CH	 // 输入端口的实现
	, input wire [`GPIO_IN_CH-1:0]	 gpio_in  // 输入端口
`endif
`ifdef GPIO_OUT_CH	 // 输出端口实现
	, output wire [`GPIO_OUT_CH-1:0] gpio_out // 输出端口
`endif
`ifdef GPIO_IO_CH	 // 输入/输出端口的实现
	, inout wire [`GPIO_IO_CH-1:0]	 gpio_io  // 输入输出端口
`endif
`endif
);

	/********** 时钟 & 复位 **********/
	wire					   clk;			  // 时钟
	wire					   clk_;		  // 反相时钟
	wire					   chip_reset;	  // 复芯片位
   
	/********** 时钟モジュール **********/
	clk_gen clk_gen (
		/********** 时钟 & 复位 **********/
		.clk_ref	  (clk_ref),			  // 主时钟
		.reset_sw	  (reset_sw),			  // 复位按钮
		/********** 生成时钟 **********/
		.clk		  (clk),				  // 时钟
		.clk_		  (clk_),				  // 反相时钟
		/********** 复芯片位 **********/
		.chip_reset	  (chip_reset)			  // 复芯片位
	);

	/********** 芯片 **********/
	chip chip (
		/********** 时钟 & 复位 **********/
		.clk	  (clk),					  // 时钟
		.clk_	  (clk_),					  // 反相时钟
		.reset	  (chip_reset)				  // 复位
		/********** UART **********/
`ifdef IMPLEMENT_UART
		, .uart_rx	(uart_rx)				  // UART接收波形
		, .uart_tx	(uart_tx)				  // UART发送波形
`endif
		/********** 通用输入/输出端口 **********/
`ifdef IMPLEMENT_GPIO
`ifdef GPIO_IN_CH  // 输入端口的实现
		, .gpio_in (gpio_in)				  // 输入端口
`endif
`ifdef GPIO_OUT_CH // 输出端口实现
		, .gpio_out (gpio_out)				  // 输出端口
`endif
`ifdef GPIO_IO_CH  // 输入/输出端口的实现
		, .gpio_io	(gpio_io)				  // 输入输出端口
`endif
`endif
	);

endmodule
