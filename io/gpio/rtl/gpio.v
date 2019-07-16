/*
 -- ============================================================================
 -- FILE NAME	: gpio.v
 -- DESCRIPTION :  General Purpose I/O
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
module gpio (
	/********** 时钟 & 复位 **********/
	input  wire						clk,	 // 时钟
	input  wire						reset,	 // 异步复位
	/********** 总线接口 **********/
	input  wire						cs_,	 // 片选信号
	input  wire						as_,	 // 地址选通信号
	input  wire						rw,		 // Read / Write
	input  wire [`GpioAddrBus]		addr,	 // 地址
	input  wire [`WordDataBus]		wr_data, // 写入的数据
	output reg	[`WordDataBus]		rd_data, // 读取的数据
	output reg						rdy_	 // 就绪信号
	/********** 通用输入输出接口 **********/
`ifdef GPIO_IN_CH	 // 输入端口的实现
	, input wire [`GPIO_IN_CH-1:0]	gpio_in	 // 输入端口（控制寄存器0）
`endif
`ifdef GPIO_OUT_CH	 // 输出端口实现
	, output reg [`GPIO_OUT_CH-1:0] gpio_out // 输出端口（控制寄存器1）
`endif
`ifdef GPIO_IO_CH	 // 输入/输出端口的实现
	, inout wire [`GPIO_IO_CH-1:0]	gpio_io	 // I/O端口（控制寄存器2）
`endif
);

`ifdef GPIO_IO_CH	 // 输入输出端口的控制
	/********** 输入输出信号 **********/
	wire [`GPIO_IO_CH-1:0]			io_in;	 // 输入的数据
	reg	 [`GPIO_IO_CH-1:0]			io_out;	 // 输出的数据
	reg	 [`GPIO_IO_CH-1:0]			io_dir;	 // 输入输出方向（控制寄存器3）
	reg	 [`GPIO_IO_CH-1:0]			io;		 // 输入输出
	integer							i;		 // 迭代器
   
	/********** 输入输出信号的连续赋值 **********/
	assign io_in	   = gpio_io;			 // 输入的数据
	assign gpio_io	   = io;				 // 输入输出

	/********** 输入输出方向的控制 **********/
	always @(*) begin
		for (i = 0; i < `GPIO_IO_CH; i = i + 1) begin : IO_DIR
			io[i] = (io_dir[i] == `GPIO_DIR_IN) ? 1'bz : io_out[i];
		end
	end

`endif
   
	/********** GPIO的控制 **********/
	always @(posedge clk or `RESET_EDGE reset) begin
		if (reset == `RESET_ENABLE) begin
			/* 异步复位 */
			rd_data	 <= #1 `WORD_DATA_W'h0;
			rdy_	 <= #1 `DISABLE_;
`ifdef GPIO_OUT_CH	 // 输出端口复位
			gpio_out <= #1 {`GPIO_OUT_CH{`LOW}};
`endif
`ifdef GPIO_IO_CH	 // 输入端口的复位
			io_out	 <= #1 {`GPIO_IO_CH{`LOW}};
			io_dir	 <= #1 {`GPIO_IO_CH{`GPIO_DIR_IN}};
`endif
		end else begin
			/* 就绪信号的生成 */
			if ((cs_ == `ENABLE_) && (as_ == `ENABLE_)) begin
				rdy_	 <= #1 `ENABLE_;
			end else begin
				rdy_	 <= #1 `DISABLE_;
			end 
			/* 读取访问 */
			if ((cs_ == `ENABLE_) && (as_ == `ENABLE_) && (rw == `READ)) begin
				case (addr)
`ifdef GPIO_IN_CH	// 输入端口的读取
					`GPIO_ADDR_IN_DATA	: begin // 控制寄存器 0
						rd_data	 <= #1 {{`WORD_DATA_W-`GPIO_IN_CH{1'b0}}, 
										gpio_in};
					end
`endif
`ifdef GPIO_OUT_CH	// 输出端口的读取
					`GPIO_ADDR_OUT_DATA : begin // 控制寄存器 1
						rd_data	 <= #1 {{`WORD_DATA_W-`GPIO_OUT_CH{1'b0}}, 
										gpio_out};
					end
`endif
`ifdef GPIO_IO_CH	// 输入输出端口的读取
					`GPIO_ADDR_IO_DATA	: begin // 控制寄存器 2
						rd_data	 <= #1 {{`WORD_DATA_W-`GPIO_IO_CH{1'b0}}, 
										io_in};
					 end
					`GPIO_ADDR_IO_DIR	: begin // 控制寄存器 3
						rd_data	 <= #1 {{`WORD_DATA_W-`GPIO_IO_CH{1'b0}}, 
										io_dir};
					end
`endif
				endcase
			end else begin
				rd_data	 <= #1 `WORD_DATA_W'h0;
			end
			/* 写入访问 */
			if ((cs_ == `ENABLE_) && (as_ == `ENABLE_) && (rw == `WRITE)) begin
				case (addr)
`ifdef GPIO_OUT_CH	// 向输出端口写入
					`GPIO_ADDR_OUT_DATA : begin // 控制寄存器 1
						gpio_out <= #1 wr_data[`GPIO_OUT_CH-1:0];
					end
`endif
`ifdef GPIO_IO_CH	// 向输入端口写入
					`GPIO_ADDR_IO_DATA	: begin // 控制寄存器 2
						io_out	 <= #1 wr_data[`GPIO_IO_CH-1:0];
					 end
					`GPIO_ADDR_IO_DIR	: begin // 控制寄存器 3
						io_dir	 <= #1 wr_data[`GPIO_IO_CH-1:0];
					end
`endif
				endcase
			end
		end
	end

endmodule
