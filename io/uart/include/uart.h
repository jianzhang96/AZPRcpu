/*
 -- ============================================================================
 -- FILE NAME	: uart.h
 -- DESCRIPTION : UART?文件
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by	 Comment
 -- 1.0.0	  2011/06/27  suito		 新規作成
 -- ============================================================================
*/

`ifndef __UART_HEADER__
	`define __UART_HEADER__			// 包含文件防范

/*
 * 【?于分?】
 * UART根据整个芯片的基?生成波特率。
? *要更改基?或波特率，
? *更改UART_DIV_RATE，UART_DIV_CNT_W和UartDivCntBus。
? * UART_DIV_RATE定?分割率。
? * UART_DIV_RATE是基本?率除以波特率。
? * UART_DIV_CNT_W定?除法?数器的?度。
? * UART_DIV_CNT_W是UART_DIV_RATE的log2?。
? * UartDivCntBus是UART_DIV_CNT_W??。
? *?将其?置?UART_DIV_CNT_W-1：0。
 *
 * 【分?示例】
 *如果UART的波特率?38,400波特，整个芯片的基??10 MHz，
? * UART_DIV_RATE?260，10,000,000÷38,400。
? *?于log2（260），UART_DIV_CNT_W?9。
 */

	/********** 分周カウンタ *********/
	`define UART_DIV_RATE	   9'd260  // 分?比率
	`define UART_DIV_CNT_W	   9	   // 分??数器位?
	`define UartDivCntBus	   8:0	   // 分??数器??
	/********** 地址?? **********/
	`define UartAddrBus		   0:0	// 地址??
	`define UART_ADDR_W		   1	// 地址?
	`define UartAddrLoc		   0:0	// 地址位置
	/********** アドレスマップ **********/
	`define UART_ADDR_STATUS   1'h0 // 控制寄存器0：状?
	`define UART_ADDR_DATA	   1'h1 // 控制寄存器1：收?的数据
	/********** ビットマップ **********/
	`define UartCtrlIrqRx	   0	// 接受完成中断
	`define UartCtrlIrqTx	   1	// ?送完成中断
	`define UartCtrlBusyRx	   2	// 接收中?志位
	`define UartCtrlBusyTx	   3	// ?送中?志位
	/********** ?送/接收状? **********/
	`define UartStateBus	   0:0	// 状???
	`define UART_STATE_IDLE	   1'b0 // 状? : 空?状?
	`define UART_STATE_TX	   1'b1 // 状? : ?送中
	`define UART_STATE_RX	   1'b1 // 状? : 接收中
	/********** 位?数器 **********/
	`define UartBitCntBus	   3:0	// 比特?数器??
	`define UART_BIT_CNT_W	   4	// 比特?数器位?
	`define UART_BIT_CNT_START 4'h0 // ?数器? : 起始位
	`define UART_BIT_CNT_MSB   4'h8 // ?数器? : 数据的MSB
	`define UART_BIT_CNT_STOP  4'h9 // ??器? : 停止位
	/********** 位?? **********/
	`define UART_START_BIT	   1'b0 // 起始位
	`define UART_STOP_BIT	   1'b1 // 停止位

`endif
