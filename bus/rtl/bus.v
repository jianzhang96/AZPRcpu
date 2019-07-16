/*
 -- ============================================================================
 -- FILE NAME	: bus.v
 -- DESCRIPTION : 总线顶层模块
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by	 Comment
 -- 1.0.0	  2011/06/27  suito		 新规作成
 -- ============================================================================
*/

/********** 通用头文件 **********/
`include "nettype.h"
`include "stddef.h"
`include "global_config.h"

/********** 单个头文件 **********/
`include "bus.h"

/********** 模块 **********/
module bus (
	/********** 时钟 & 复位 **********/
	input  wire				   clk,		   // 时钟
	input  wire				   reset,	   // 异步复位
	/********** 总线主控信号 **********/
	// 总线主控共享信号
	output wire [`WordDataBus] m_rd_data,  // 读出的数据
	output wire				   m_rdy_,	   // 就绪
	// 0号总线主控
	input  wire				   m0_req_,	   // 请求总线
	input  wire [`WordAddrBus] m0_addr,	   // 地址
	input  wire				   m0_as_,	   // 地址选通
	input  wire				   m0_rw,	   // 读/写
	input  wire [`WordDataBus] m0_wr_data, // 写入的数据
	output wire				   m0_grnt_,   // 赋予总线
	// 1号总线主控
	input  wire				   m1_req_,	   // 请求总线
	input  wire [`WordAddrBus] m1_addr,	   // 地址
	input  wire				   m1_as_,	   // 地址选通
	input  wire				   m1_rw,	   // 读/写
	input  wire [`WordDataBus] m1_wr_data, // 写入的数据
	output wire				   m1_grnt_,   // 赋予总线
	// 2号总线主控
	input  wire				   m2_req_,	   // 请求总线
	input  wire [`WordAddrBus] m2_addr,	   // 地址
	input  wire				   m2_as_,	   // 地址选通
	input  wire				   m2_rw,	   // 读/写
	input  wire [`WordDataBus] m2_wr_data, // 写入的数据
	output wire				   m2_grnt_,   // 赋予总线
	// 3号总线主控
	input  wire				   m3_req_,	   // 请求总线
	input  wire [`WordAddrBus] m3_addr,	   // 地址
	input  wire				   m3_as_,	   // 地址选通
	input  wire				   m3_rw,	   // 读/写
	input  wire [`WordDataBus] m3_wr_data, // 写入的数据
	output wire				   m3_grnt_,   // 赋予总线
	/********** 总线从属信号 **********/
	// 总线从属共享信号
	output wire [`WordAddrBus] s_addr,	   // 地址
	output wire				   s_as_,	   // 地址选通
	output wire				   s_rw,	   // 读/写
	output wire [`WordDataBus] s_wr_data,  // 写入的数据
	// 0号总线从属
	input  wire [`WordDataBus] s0_rd_data, // 读出的数据
	input  wire				   s0_rdy_,	   // 就绪
	output wire				   s0_cs_,	   // 片选
	// 1号总线从属
	input  wire [`WordDataBus] s1_rd_data, // 读出的数据
	input  wire				   s1_rdy_,	   // 就绪
	output wire				   s1_cs_,	   // 片选
	// 2号总线从属
	input  wire [`WordDataBus] s2_rd_data, // 读出的数据
	input  wire				   s2_rdy_,	   // 就绪
	output wire				   s2_cs_,	   // 片选
	// 3号总线从属
	input  wire [`WordDataBus] s3_rd_data, // 读出的数据
	input  wire				   s3_rdy_,	   // 就绪
	output wire				   s3_cs_,	   // 片选
	// 4号总线从属
	input  wire [`WordDataBus] s4_rd_data, // 读出的数据
	input  wire				   s4_rdy_,	   // 就绪
	output wire				   s4_cs_,	   // 片选
	// 5号总线从属
	input  wire [`WordDataBus] s5_rd_data, // 读出的数据
	input  wire				   s5_rdy_,	   // 就绪
	output wire				   s5_cs_,	   // 片选
	// 6号总线从属
	input  wire [`WordDataBus] s6_rd_data, // 读出的数据
	input  wire				   s6_rdy_,	   // 就绪
	output wire				   s6_cs_,	   // 片选
	// 7号总线从属
	input  wire [`WordDataBus] s7_rd_data, // 读出的数据
	input  wire				   s7_rdy_,	   // 就绪
	output wire				   s7_cs_	   // 片选
);

	/********** 总线仲裁器 **********/
	bus_arbiter bus_arbiter (
		/********** 时钟 & 复位 **********/
		.clk		(clk),		  // 时钟
		.reset		(reset),	  // 异步复位
		/********** 仲裁信号 **********/
		// 0号总线主控
		.m0_req_	(m0_req_),	  // 请求总线
		.m0_grnt_	(m0_grnt_),	  // 赋予总线
		// 1号总线主控
		.m1_req_	(m1_req_),	  // 请求总线
		.m1_grnt_	(m1_grnt_),	  // 赋予总线
		// 2号总线主控
		.m2_req_	(m2_req_),	  // 请求总线
		.m2_grnt_	(m2_grnt_),	  // 赋予总线
		// 3号总线主控
		.m3_req_	(m3_req_),	  // 请求总线
		.m3_grnt_	(m3_grnt_)	  // 赋予总线
	);

	/********** 总线主控用多路复用器 **********/
	bus_master_mux bus_master_mux (
		/********** 总线主控信号 **********/
		// 0号总线主控
		.m0_addr	(m0_addr),	  // 地址
		.m0_as_		(m0_as_),	  // 地址选通
		.m0_rw		(m0_rw),	  // 读/写
		.m0_wr_data (m0_wr_data), // 写入的数据
		.m0_grnt_	(m0_grnt_),	  // 赋予总线
		// 1号总线主控
		.m1_addr	(m1_addr),	  // 地址
		.m1_as_		(m1_as_),	  // 地址选通
		.m1_rw		(m1_rw),	  // 读/写
		.m1_wr_data (m1_wr_data), // 写入的数据
		.m1_grnt_	(m1_grnt_),	  // 赋予总线
		// 2号总线主控
		.m2_addr	(m2_addr),	  // 地址
		.m2_as_		(m2_as_),	  // 地址选通
		.m2_rw		(m2_rw),	  // 读/写
		.m2_wr_data (m2_wr_data), // 写入的数据
		.m2_grnt_	(m2_grnt_),	  // 赋予总线
		// 3号总线主控
		.m3_addr	(m3_addr),	  // 地址
		.m3_as_		(m3_as_),	  // 地址选通
		.m3_rw		(m3_rw),	  // 读/写
		.m3_wr_data (m3_wr_data), // 写入的数据
		.m3_grnt_	(m3_grnt_),	  // 赋予总线
		/********** 总线从属共享信号 **********/
		.s_addr		(s_addr),	  // 地址
		.s_as_		(s_as_),	  // 地址选通
		.s_rw		(s_rw),		  // 读/写
		.s_wr_data	(s_wr_data)	  // 写入的数据
	);

	/********** 地址解码器 **********/
	bus_addr_dec bus_addr_dec (
		/********** 地址 **********/
		.s_addr		(s_addr),	  // 地址
		/********** 片选 **********/
		.s0_cs_		(s0_cs_),	  // 0号总线从属
		.s1_cs_		(s1_cs_),	  // 1号总线从属
		.s2_cs_		(s2_cs_),	  // 2号总线从属
		.s3_cs_		(s3_cs_),	  // 3号总线从属
		.s4_cs_		(s4_cs_),	  // 4号总线从属
		.s5_cs_		(s5_cs_),	  // 5号总线从属
		.s6_cs_		(s6_cs_),	  // 6号总线从属
		.s7_cs_		(s7_cs_)	  // 7号总线从属
	);

	/********** 总线从属用多路复用器 **********/
	bus_slave_mux bus_slave_mux (
		/********** 片选 **********/
		.s0_cs_		(s0_cs_),	  // 0号总线从属
		.s1_cs_		(s1_cs_),	  // 1号总线从属
		.s2_cs_		(s2_cs_),	  // 2号总线从属
		.s3_cs_		(s3_cs_),	  // 3号总线从属
		.s4_cs_		(s4_cs_),	  // 4号总线从属
		.s5_cs_		(s5_cs_),	  // 5号总线从属
		.s6_cs_		(s6_cs_),	  // 6号总线从属
		.s7_cs_		(s7_cs_),	  // 7号总线从属
		/********** 总线从属信号 **********/
		// 0号总线从属
		.s0_rd_data (s0_rd_data), // 读出的数据
		.s0_rdy_	(s0_rdy_),	  // 就绪
		// 1号总线从属
		.s1_rd_data (s1_rd_data), // 读出的数据
		.s1_rdy_	(s1_rdy_),	  // 就绪
		// 2号总线从属
		.s2_rd_data (s2_rd_data), // 读出的数据
		.s2_rdy_	(s2_rdy_),	  // 就绪
		// 3号总线从属
		.s3_rd_data (s3_rd_data), // 读出的数据
		.s3_rdy_	(s3_rdy_),	  // 就绪
		// 4号总线从属
		.s4_rd_data (s4_rd_data), // 读出的数据
		.s4_rdy_	(s4_rdy_),	  // 就绪
		// 5号总线从属
		.s5_rd_data (s5_rd_data), // 读出的数据
		.s5_rdy_	(s5_rdy_),	  // 就绪
		// 6号总线从属
		.s6_rd_data (s6_rd_data), // 读出的数据
		.s6_rdy_	(s6_rdy_),	  // 就绪
		// 7号总线从属
		.s7_rd_data (s7_rd_data), // 读出的数据
		.s7_rdy_	(s7_rdy_),	  // 就绪
		/********** 总线主控共享信号 **********/
		.m_rd_data	(m_rd_data),  // 读出的数据
		.m_rdy_		(m_rdy_)	  // 就绪
	);

endmodule
