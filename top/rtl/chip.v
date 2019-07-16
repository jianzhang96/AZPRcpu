/* 
 -- ============================================================================
 -- FILE NAME	: chip.v
 -- DESCRIPTION : 芯片
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
`include "cpu.h"
`include "bus.h"
`include "rom.h"
`include "timer.h"
`include "uart.h"
`include "gpio.h"

/********** 模块 **********/
module chip (
	/********** 时钟 & 复位 **********/
	input  wire						 clk,		  // 时钟
	input  wire						 clk_,		  // 反相时钟
	input  wire						 reset		  // 复位
	/********** UART  **********/
`ifdef IMPLEMENT_UART // UART实现
	, input	 wire					 uart_rx	  // UART接收信号
	, output wire					 uart_tx	  // UART发送信号
`endif
	/********** 通用输入/输出端口 **********/
`ifdef IMPLEMENT_GPIO // GPIO实现
`ifdef GPIO_IN_CH	 // 输入端口的实现
	, input wire [`GPIO_IN_CH-1:0]	 gpio_in	  // 输入端口
`endif
`ifdef GPIO_OUT_CH	 // 输出端口实现
	, output wire [`GPIO_OUT_CH-1:0] gpio_out	  // 输出端口
`endif
`ifdef GPIO_IO_CH	 // 输入/输出端口的实现
	, inout wire [`GPIO_IO_CH-1:0]	 gpio_io	  // 输入输出端口
`endif
`endif
);

	/********** バスマスタ信号 **********/
	// 全マスタ共通信号~
	wire [`WordDataBus] m_rd_data;				  // 読み出しデータ
	wire				m_rdy_;					  // レディ
	// バスマスタ0
	wire				m0_req_;				  // バスリクエスト
	wire [`WordAddrBus] m0_addr;				  // アドレス
	wire				m0_as_;					  // アドレスストローブ
	wire				m0_rw;					  // 読み／書き
	wire [`WordDataBus] m0_wr_data;				  // 書き込みデータ
	wire				m0_grnt_;				  // バスグラント
	// バスマスタ1
	wire				m1_req_;				  // バスリクエスト
	wire [`WordAddrBus] m1_addr;				  // アドレス
	wire				m1_as_;					  // アドレスストローブ
	wire				m1_rw;					  // 読み／書き
	wire [`WordDataBus] m1_wr_data;				  // 書き込みデータ
	wire				m1_grnt_;				  // バスグラント
	// バスマスタ2
	wire				m2_req_;				  // バスリクエスト
	wire [`WordAddrBus] m2_addr;				  // アドレス
	wire				m2_as_;					  // アドレスストローブ
	wire				m2_rw;					  // 読み／書き
	wire [`WordDataBus] m2_wr_data;				  // 書き込みデータ
	wire				m2_grnt_;				  // バスグラント
	// バスマスタ3
	wire				m3_req_;				  // バスリクエスト
	wire [`WordAddrBus] m3_addr;				  // アドレス
	wire				m3_as_;					  // アドレスストローブ
	wire				m3_rw;					  // 読み／書き
	wire [`WordDataBus] m3_wr_data;				  // 書き込みデータ
	wire				m3_grnt_;				  // バスグラント
	/********** バススレーブ信号 **********/
	// 全スレーブ共通信号
	wire [`WordAddrBus] s_addr;					  // アドレス
	wire				s_as_;					  // アドレスストローブ
	wire				s_rw;					  // 読み／書き
	wire [`WordDataBus] s_wr_data;				  // 書き込みデータ
	// バススレーブ0番
	wire [`WordDataBus] s0_rd_data;				  // 読み出しデータ
	wire				s0_rdy_;				  // レディ
	wire				s0_cs_;					  // チップセレクト
	// バススレーブ1番
	wire [`WordDataBus] s1_rd_data;				  // 読み出しデータ
	wire				s1_rdy_;				  // レディ
	wire				s1_cs_;					  // チップセレクト
	// バススレーブ2番
	wire [`WordDataBus] s2_rd_data;				  // 読み出しデータ
	wire				s2_rdy_;				  // レディ
	wire				s2_cs_;					  // チップセレクト
	// バススレーブ3番
	wire [`WordDataBus] s3_rd_data;				  // 読み出しデータ
	wire				s3_rdy_;				  // レディ
	wire				s3_cs_;					  // チップセレクト
	// バススレーブ4番
	wire [`WordDataBus] s4_rd_data;				  // 読み出しデータ
	wire				s4_rdy_;				  // レディ
	wire				s4_cs_;					  // チップセレクト
	// バススレーブ5番
	wire [`WordDataBus] s5_rd_data;				  // 読み出しデータ
	wire				s5_rdy_;				  // レディ
	wire				s5_cs_;					  // チップセレクト
	// バススレーブ6番
	wire [`WordDataBus] s6_rd_data;				  // 読み出しデータ
	wire				s6_rdy_;				  // レディ
	wire				s6_cs_;					  // チップセレクト
	// バススレーブ7番
	wire [`WordDataBus] s7_rd_data;				  // 読み出しデータ
	wire				s7_rdy_;				  // レディ
	wire				s7_cs_;					  // チップセレクト
	/********** 割り込み要求信号 **********/
	wire				   irq_timer;			  // タイマIRQ
	wire				   irq_uart_rx;			  // UART IRQ（受信）
	wire				   irq_uart_tx;			  // UART IRQ（送信）
	wire [`CPU_IRQ_CH-1:0] cpu_irq;				  // CPU IRQ

	assign cpu_irq = {{`CPU_IRQ_CH-3{`LOW}}, 
					  irq_uart_rx, irq_uart_tx, irq_timer};

	/********** CPU **********/
	cpu cpu (
		/********** クロック & リセット **********/
		.clk			 (clk),					  // クロック
		.clk_			 (clk_),				  // 反転クロック
		.reset			 (reset),				  // 非同期リセット
		/********** バスインタフェース **********/
		// IF Stage
		.if_bus_rd_data	 (m_rd_data),			  // 読み出しデータ
		.if_bus_rdy_	 (m_rdy_),				  // レディ
		.if_bus_grnt_	 (m0_grnt_),			  // バスグラント
		.if_bus_req_	 (m0_req_),				  // バスリクエスト
		.if_bus_addr	 (m0_addr),				  // アドレス
		.if_bus_as_		 (m0_as_),				  // アドレスストローブ
		.if_bus_rw		 (m0_rw),				  // 読み／書き
		.if_bus_wr_data	 (m0_wr_data),			  // 書き込みデータ
		// MEM Stage
		.mem_bus_rd_data (m_rd_data),			  // 読み出しデータ
		.mem_bus_rdy_	 (m_rdy_),				  // レディ
		.mem_bus_grnt_	 (m1_grnt_),			  // バスグラント
		.mem_bus_req_	 (m1_req_),				  // バスリクエスト
		.mem_bus_addr	 (m1_addr),				  // アドレス
		.mem_bus_as_	 (m1_as_),				  // アドレスストローブ
		.mem_bus_rw		 (m1_rw),				  // 読み／書き
		.mem_bus_wr_data (m1_wr_data),			  // 書き込みデータ
		/********** 割り込み **********/
		.cpu_irq		 (cpu_irq)				  // 割り込み要求
	);

	/********** バスマスタ 2 : 未実装 **********/
	assign m2_addr	  = `WORD_ADDR_W'h0;
	assign m2_as_	  = `DISABLE_;
	assign m2_rw	  = `READ;
	assign m2_wr_data = `WORD_DATA_W'h0;
	assign m2_req_	  = `DISABLE_;

	/********** バスマスタ 3 : 未実装 **********/
	assign m3_addr	  = `WORD_ADDR_W'h0;
	assign m3_as_	  = `DISABLE_;
	assign m3_rw	  = `READ;
	assign m3_wr_data = `WORD_DATA_W'h0;
	assign m3_req_	  = `DISABLE_;
   
	/********** バススレーブ 0 : ROM **********/
	rom rom (
		/********** Clock & Reset **********/
		.clk			 (clk),					  // クロック
		.reset			 (reset),				  // 非同期リセット
		/********** Bus Interface **********/
		.cs_			 (s0_cs_),				  // チップセレクト
		.as_			 (s_as_),				  // アドレスストローブ
		.addr			 (s_addr[`RomAddrLoc]),	  // アドレス
		.rd_data		 (s0_rd_data),			  // 読み出しデータ
		.rdy_			 (s0_rdy_)				  // レディ
	);

	/********** バススレーブ 1 : Scratch Pad Memory **********/
	assign s1_rd_data = `WORD_DATA_W'h0;
	assign s1_rdy_	  = `DISABLE_;

	/********** バススレーブ 2 : タイマ **********/
`ifdef IMPLEMENT_TIMER // タイマ実装
	timer timer (
		/********** クロック & リセット **********/
		.clk			 (clk),					  // クロック
		.reset			 (reset),				  // リセット
		/********** バスインタフェース **********/
		.cs_			 (s2_cs_),				  // チップセレクト
		.as_			 (s_as_),				  // アドレスストローブ
		.addr			 (s_addr[`TimerAddrLoc]), // アドレス
		.rw				 (s_rw),				  // Read / Write
		.wr_data		 (s_wr_data),			  // 書き込みデータ
		.rd_data		 (s2_rd_data),			  // 読み出しデータ
		.rdy_			 (s2_rdy_),				  // レディ
		/********** 割り込み **********/
		.irq			 (irq_timer)			  // 割り込み要求
	 );
`else				   // タイマ未実
	assign s2_rd_data = `WORD_DATA_W'h0;
	assign s2_rdy_	  = `DISABLE_;
	assign irq_timer  = `DISABLE;
`endif

	/********** バススレーブ 3 : UART **********/
`ifdef IMPLEMENT_UART // UART実装
	uart uart (
		/********** クロック & リセット **********/
		.clk			 (clk),					  // クロック
		.reset			 (reset),				  // 非同期リセット
		/********** バスインタフェース **********/
		.cs_			 (s3_cs_),				  // チップセレクト
		.as_			 (s_as_),				  // アドレスストローブ
		.rw				 (s_rw),				  // Read / Write
		.addr			 (s_addr[`UartAddrLoc]),  // アドレス
		.wr_data		 (s_wr_data),			  // 書き込みデータ
		.rd_data		 (s3_rd_data),			  // 読み出しデータ
		.rdy_			 (s3_rdy_),				  // レディ
		/********** 割り込み **********/
		.irq_rx			 (irq_uart_rx),			  // 受信完了割り込み
		.irq_tx			 (irq_uart_tx),			  // 送信完了割り込み
		/********** UART送受信信号	**********/
		.rx				 (uart_rx),				  // UART受信信号
		.tx				 (uart_tx)				  // UART送信信号
	);
`else				  // UART未実装
	assign s3_rd_data  = `WORD_DATA_W'h0;
	assign s3_rdy_	   = `DISABLE_;
	assign irq_uart_rx = `DISABLE;
	assign irq_uart_tx = `DISABLE;
`endif

	/********** バススレーブ 4 : GPIO **********/
`ifdef IMPLEMENT_GPIO // GPIO実装
	gpio gpio (
		/********** クロック & リセット **********/
		.clk			 (clk),					 // クロック
		.reset			 (reset),				 // リセット
		/********** バスインタフェース **********/
		.cs_			 (s4_cs_),				 // チップセレクト
		.as_			 (s_as_),				 // アドレスストローブ
		.rw				 (s_rw),				 // Read / Write
		.addr			 (s_addr[`GpioAddrLoc]), // アドレス
		.wr_data		 (s_wr_data),			 // 書き込みデータ
		.rd_data		 (s4_rd_data),			 // 読み出しデータ
		.rdy_			 (s4_rdy_)				 // レディ
		/********** 汎用入出力ポート **********/
`ifdef GPIO_IN_CH	 // 入力ポートの実装
		, .gpio_in		 (gpio_in)				 // 入力ポート
`endif
`ifdef GPIO_OUT_CH	 // 出力ポートの実装
		, .gpio_out		 (gpio_out)				 // 出力ポート
`endif
`ifdef GPIO_IO_CH	 // 入出力ポートの実装
		, .gpio_io		 (gpio_io)				 // 入出力ポート
`endif
	);
`else				  // GPIO未実装
	assign s4_rd_data = `WORD_DATA_W'h0;
	assign s4_rdy_	  = `DISABLE_;
`endif

	/********** バススレーブ 5 : 未実装 **********/
	assign s5_rd_data = `WORD_DATA_W'h0;
	assign s5_rdy_	  = `DISABLE_;
  
	/********** バススレーブ 6 : 未実装 **********/
	assign s6_rd_data = `WORD_DATA_W'h0;
	assign s6_rdy_	  = `DISABLE_;
  
	/********** バススレーブ 7 : 未実装 **********/
	assign s7_rd_data = `WORD_DATA_W'h0;
	assign s7_rdy_	  = `DISABLE_;

	/********** バス **********/
	bus bus (
		/********** クロック & リセット **********/
		.clk			 (clk),					 // クロック
		.reset			 (reset),				 // 非同期リセット
		/********** バスマスタ信号 **********/
		// 全マスタ共通信号
		.m_rd_data		 (m_rd_data),			 // 読み出しデータ
		.m_rdy_			 (m_rdy_),				 // レディ
		// バスマスタ0
		.m0_req_		 (m0_req_),				 // バスリクエスト
		.m0_addr		 (m0_addr),				 // アドレス
		.m0_as_			 (m0_as_),				 // アドレスストローブ
		.m0_rw			 (m0_rw),				 // 読み／書き
		.m0_wr_data		 (m0_wr_data),			 // 書き込みデータ
		.m0_grnt_		 (m0_grnt_),			 // バスグラント
		// バスマスタ1
		.m1_req_		 (m1_req_),				 // バスリクエスト
		.m1_addr		 (m1_addr),				 // アドレス
		.m1_as_			 (m1_as_),				 // アドレスストローブ
		.m1_rw			 (m1_rw),				 // 読み／書き
		.m1_wr_data		 (m1_wr_data),			 // 書き込みデータ
		.m1_grnt_		 (m1_grnt_),			 // バスグラント
		// バスマスタ2
		.m2_req_		 (m2_req_),				 // バスリクエスト
		.m2_addr		 (m2_addr),				 // アドレス
		.m2_as_			 (m2_as_),				 // アドレスストローブ
		.m2_rw			 (m2_rw),				 // 読み／書き
		.m2_wr_data		 (m2_wr_data),			 // 書き込みデータ
		.m2_grnt_		 (m2_grnt_),			 // バスグラント
		// バスマスタ3
		.m3_req_		 (m3_req_),				 // バスリクエスト
		.m3_addr		 (m3_addr),				 // アドレス
		.m3_as_			 (m3_as_),				 // アドレスストローブ
		.m3_rw			 (m3_rw),				 // 読み／書き
		.m3_wr_data		 (m3_wr_data),			 // 書き込みデータ
		.m3_grnt_		 (m3_grnt_),			 // バスグラント
		/********** バススレーブ信号 **********/
		// 全スレーブ共通信号
		.s_addr			 (s_addr),				 // アドレス
		.s_as_			 (s_as_),				 // アドレスストローブ
		.s_rw			 (s_rw),				 // 読み／書き
		.s_wr_data		 (s_wr_data),			 // 書き込みデータ
		// バススレーブ0番
		.s0_rd_data		 (s0_rd_data),			 // 読み出しデータ
		.s0_rdy_		 (s0_rdy_),				 // レディ
		.s0_cs_			 (s0_cs_),				 // チップセレクト
		// バススレーブ1番
		.s1_rd_data		 (s1_rd_data),			 // 読み出しデータ
		.s1_rdy_		 (s1_rdy_),				 // レディ
		.s1_cs_			 (s1_cs_),				 // チップセレクト
		// バススレーブ2番
		.s2_rd_data		 (s2_rd_data),			 // 読み出しデータ
		.s2_rdy_		 (s2_rdy_),				 // レディ
		.s2_cs_			 (s2_cs_),				 // チップセレクト
		// バススレーブ3番
		.s3_rd_data		 (s3_rd_data),			 // 読み出しデータ
		.s3_rdy_		 (s3_rdy_),				 // レディ
		.s3_cs_			 (s3_cs_),				 // チップセレクト
		// バススレーブ4番
		.s4_rd_data		 (s4_rd_data),			 // 読み出しデータ
		.s4_rdy_		 (s4_rdy_),				 // レディ
		.s4_cs_			 (s4_cs_),				 // チップセレクト
		// バススレーブ5番
		.s5_rd_data		 (s5_rd_data),			 // 読み出しデータ
		.s5_rdy_		 (s5_rdy_),				 // レディ
		.s5_cs_			 (s5_cs_),				 // チップセレクト
		// バススレーブ6番
		.s6_rd_data		 (s6_rd_data),			 // 読み出しデータ
		.s6_rdy_		 (s6_rdy_),				 // レディ
		.s6_cs_			 (s6_cs_),				 // チップセレクト
		// バススレーブ7番
		.s7_rd_data		 (s7_rd_data),			 // 読み出しデータ
		.s7_rdy_		 (s7_rdy_),				 // レディ
		.s7_cs_			 (s7_cs_)				 // チップセレクト
	);

endmodule
