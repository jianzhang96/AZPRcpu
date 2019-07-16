/*
 -- ============================================================================
 -- FILE NAME	: bus_addr_dec.v
 -- DESCRIPTION : 地址解码器
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
module bus_addr_dec (
	/********** 地址 **********/
	input  wire [`WordAddrBus] s_addr, // 地址
	/********** 片选 **********/
	output reg				   s0_cs_, // 0号总线从属
	output reg				   s1_cs_, // 1号总线从属
	output reg				   s2_cs_, // 2号总线从属
	output reg				   s3_cs_, // 3号总线从属
	output reg				   s4_cs_, // 4号总线从属
	output reg				   s5_cs_, // 5号总线从属
	output reg				   s6_cs_, // 6号总线从属
	output reg				   s7_cs_  // 7号总线从属
);

	/********** 总线从属的索引 **********/
	wire [`BusSlaveIndexBus] s_index = s_addr[`BusSlaveIndexLoc];

	/********** 总线从属多路复用器 **********/
	always @(*) begin
		/* 初始化片选信号 */
		s0_cs_ = `DISABLE_;
		s1_cs_ = `DISABLE_;
		s2_cs_ = `DISABLE_;
		s3_cs_ = `DISABLE_;
		s4_cs_ = `DISABLE_;
		s5_cs_ = `DISABLE_;
		s6_cs_ = `DISABLE_;
		s7_cs_ = `DISABLE_;
		/* 选择地址对应的从属 */
		case (s_index)
			`BUS_SLAVE_0 : begin // 0号总线从属
				s0_cs_	= `ENABLE_;
			end
			`BUS_SLAVE_1 : begin // 1号总线从属
				s1_cs_	= `ENABLE_;
			end
			`BUS_SLAVE_2 : begin // 2号总线从属
				s2_cs_	= `ENABLE_;
			end
			`BUS_SLAVE_3 : begin // 3号总线从属
				s3_cs_	= `ENABLE_;
			end
			`BUS_SLAVE_4 : begin // 4号总线从属
				s4_cs_	= `ENABLE_;
			end
			`BUS_SLAVE_5 : begin // 5号总线从属
				s5_cs_	= `ENABLE_;
			end
			`BUS_SLAVE_6 : begin // 6号总线从属
				s6_cs_	= `ENABLE_;
			end
			`BUS_SLAVE_7 : begin // 7号总线从属
				s7_cs_	= `ENABLE_;
			end
		endcase
	end

endmodule
