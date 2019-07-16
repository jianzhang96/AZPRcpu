/*
 -- ============================================================================
 -- FILE NAME	: uart.v
 -- DESCRIPTION : Universal Asynchronous Receiver and Transmitter
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by	 Comment
 -- 1.0.0	  2011/06/27  suito		 新規作成
 -- ============================================================================
*/

/********** 共通ヘッダファイル **********/
`include "nettype.h"
`include "stddef.h"
`include "global_config.h"

/********** 個別ヘッダファイル **********/
`include "uart.h"

/********** モジュール **********/
module uart (
	/********** 时钟 & 复位 **********/
	input  wire				   clk,		 // 时钟
	input  wire				   reset,	 // 异步复位
	/********** 总线接口 **********/
	input  wire				   cs_,		 // チップセレクト
	input  wire				   as_,		 // アドレスストローブ
	input  wire				   rw,		 // Read / Write
	input  wire [`UartAddrBus] addr,	 // アドレス
	input  wire [`WordDataBus] wr_data,	 // 書き込みデータ
	output wire [`WordDataBus] rd_data,	 // 読み出しデータ
	output wire				   rdy_,	 // レディ
	/********** 中断 **********/
	output wire				   irq_rx,	 // 接收中断请求信号
	output wire				   irq_tx,	 // 发送中断请求信号
	/********** UART接收发送信号	**********/
	input  wire				   rx,		 // UART接收信号
	output wire				   tx		 // UART发送信号
);

	/********** 控制信号 **********/
	// 接收控制
	wire					   rx_busy;	 // 接收中标志信号
	wire					   rx_end;	 // 接收完成信号
	wire [`ByteDataBus]		   rx_data;	 // 接收的数据
	// 发送控制
	wire					   tx_busy;	 // 发送中标志信号
	wire					   tx_end;	 // 发送完成信号
	wire					   tx_start; // 送信開始信号
	wire [`ByteDataBus]		   tx_data;	 // 送信データ

	/********** UART控制模块 **********/
	uart_ctrl uart_ctrl (
		/********** 时钟 & 复位 **********/
		.clk	  (clk),	   // 时钟
		.reset	  (reset),	   // 异步复位
		/********** Host Interface **********/
		.cs_	  (cs_),	   // チップセレクト
		.as_	  (as_),	   // アドレスストローブ
		.rw		  (rw),		   // Read / Write
		.addr	  (addr),	   // アドレス
		.wr_data  (wr_data),   // 書き込みデータ
		.rd_data  (rd_data),   // 読み出しデータ
		.rdy_	  (rdy_),	   // レディ
		/********** Interrupt  **********/
		.irq_rx	  (irq_rx),	   // 接收中断请求信号
		.irq_tx	  (irq_tx),	   // 发送中断请求信号
		/********** 控制信号 **********/
		// 接收控制
		.rx_busy  (rx_busy),   // 接收中标志信号
		.rx_end	  (rx_end),	   // 接收完成信号
		.rx_data  (rx_data),   // 接收的数据
		// 发送控制
		.tx_busy  (tx_busy),   // 发送中标志信号
		.tx_end	  (tx_end),	   // 发送完成信号
		.tx_start (tx_start),  // 送信開始信号
		.tx_data  (tx_data)	   // 送信データ
	);

	/********** UART发送模块 **********/
	uart_tx uart_tx (
		/********** 时钟 & 复位 **********/
		.clk	  (clk),	   // 时钟
		.reset	  (reset),	   // 异步复位
		/********** 控制信号 **********/
		.tx_start (tx_start),  // 送信開始信号
		.tx_data  (tx_data),   // 送信データ
		.tx_busy  (tx_busy),   // 发送中标志信号
		.tx_end	  (tx_end),	   // 发送完成信号
		/********** Transmit Signal **********/
		.tx		  (tx)		   // UART送信信号
	);

	/********** UART接收模块 **********/
	uart_rx uart_rx (
		/********** 时钟 & 复位 **********/
		.clk	  (clk),	   // 时钟
		.reset	  (reset),	   // 异步复位
		/********** 控制信号 **********/
		.rx_busy  (rx_busy),   // 接收中标志信号
		.rx_end	  (rx_end),	   // 接收完成信号
		.rx_data  (rx_data),   // 接收的数据
		/********** Receive Signal **********/
		.rx		  (rx)		   // UART受信信号
	);

endmodule
