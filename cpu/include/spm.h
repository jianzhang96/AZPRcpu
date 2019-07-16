/*
 -- ============================================================================
 -- FILE NAME	: spm.h
 -- DESCRIPTION : 便笺式内存头文件
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by	 Comment
 -- 1.0.0	  2011/06/27  suito		 新规作成
 -- ============================================================================
*/

`ifndef __SPM_HEADER__
	`define __SPM_HEADER__			  // 包含文件防范

/*
 * 【关于SPM的大小】
 * 更改SPM的大小
 *	 更改SPM_SIZE，SPM_DEPTH，SPM_ADDR_W，SpmAddrBus和SpmAddrLoc。
 * SPM_SIZE定义SPM的大小。
 * SPM_DEPTH定义SPM的深度。
 *	 由于SPM的宽度基本上固定为32位（4字节），
 *	 SPM_DEPTH是SPM_SIZE除以4。
 * SPM_ADDR_W定义SPM地址宽度，
 *	 该值是SPM_DEPTH的log2。
 * SpmAddrBus和SpmAddrLoc是SPM_ADDR_W的总线。
 *	 SPM_ADDR_W-1:请将其设置为0。
 *
 * 【SPM尺寸示例】
 * 当SPM的大小为16384字节（16 KB）时，
 *	 SPM_DEPTH是16384/4 4096
 *	 SPM_ADDR_W在log2（4096）中为12。
 */

	`define SPM_SIZE   16384 // SPM的容量
	`define SPM_DEPTH  4096	 // SPM的深度
	`define SPM_ADDR_W 12	 // 地址宽
	`define SpmAddrBus 11:0	 // 地址总线
	`define SpmAddrLoc 11:0	 // 地址的位置

`endif
