/*
 -- ============================================================================
 -- FILE NAME	: spm.v
 -- DESCRIPTION : 便笺式存储器
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
`include "spm.h"

/********** 模块 **********/
module spm (
	/********** 时钟 **********/
	input  wire				   clk,				// 时钟
	/********** A端口 : IF阶段 **********/
	input  wire [`SpmAddrBus]  if_spm_addr,		// 地址
	input  wire				   if_spm_as_,		// 地址选通
	input  wire				   if_spm_rw,		// 读/写
	input  wire [`WordDataBus] if_spm_wr_data,	// 写入的数据
	output wire [`WordDataBus] if_spm_rd_data,	// 读取的数据
	/********** B端口 : MEM阶段 **********/
	input  wire [`SpmAddrBus]  mem_spm_addr,	// 地址
	input  wire				   mem_spm_as_,		// 地址选通
	input  wire				   mem_spm_rw,		// 读/写
	input  wire [`WordDataBus] mem_spm_wr_data, // 写入的数据
	output wire [`WordDataBus] mem_spm_rd_data	// 读取的数据
);

	/********** 写入有效 **********/
	reg						   wea;			// A端口
	reg						   web;			// B端口

	/********** 写入有效信号的生成 **********/
	always @(*) begin
		/* A端口 */
		if ((if_spm_as_ == `ENABLE_) && (if_spm_rw == `WRITE)) begin   
			wea = `MEM_ENABLE;	// 写入有效
		end else begin
			wea = `MEM_DISABLE; // 写入无效
		end
		/* B端口 */
		if ((mem_spm_as_ == `ENABLE_) && (mem_spm_rw == `WRITE)) begin
			web = `MEM_ENABLE;	// 写入有效
		end else begin
			web = `MEM_DISABLE; // 写入无效
		end
	end

	/********** Xilinx FPGA Block RAM : 双端口RAM **********/
	x_s3e_dpram x_s3e_dpram (
		/********** A端口 : IF阶段 **********/
		.clka  (clk),			  // 时钟
		.addra (if_spm_addr),	  // 地址
		.dina  (if_spm_wr_data),  // 写入的数据（未连接）
		.wea   (wea),			  // 写入有效（无效）
		.douta (if_spm_rd_data),  // 读取的数据
		/********** B端口 : MEM阶段 **********/
		.clkb  (clk),			  // 时钟
		.addrb (mem_spm_addr),	  // 地址
		.dinb  (mem_spm_wr_data), // 写入的数据
		.web   (web),			  // 写入有效
		.doutb (mem_spm_rd_data)  // 读取的数据
	);
  
endmodule
