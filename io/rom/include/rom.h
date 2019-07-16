/*
 -- ============================================================================
 -- FILE NAME	: rom.h
 -- DESCRIPTION : ROM 头文件
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by	 Comment
 -- 1.0.0	  2011/06/27  suito		 新規作成
 -- ============================================================================
*/

`ifndef __ROM_HEADER__
	`define __ROM_HEADER__			  // インクルードガード

/*
 * 【关于ROM的大小】
 *改变ROM的大小
  *更改ROM_SIZE，ROM_DEPTH，ROM_ADDR_W，RomAddrBus，RomAddrLoc。
  *·ROM_SIZE定义ROM的大小。
  *·ROM_DEPTH定义ROM的深度。
  * ROM的宽度基本上固定为32位（4字节），所以
  * ROM_DEPTH是ROM_SIZE的值除以4。
  *·ROM_ADDR_W定义ROM地址宽度，
  *这是ROM_DEPTH的log2值。
  * RomAddrBus和RomAddrLoc是ROM_ADDR_W的总线。
  *请设置为ROM_ADDR_W-1：0。
 *
 * 【ROM大小示例】
 *如果ROM的大小是8192字节（4 KB），
  * ROM_DEPTH是8192で4和2048
  * ROM_ADDR_W在log2（2048）中为11。
 */

	`define ROM_SIZE   8192	// ROM的大小
	`define ROM_DEPTH  2048	// ROM的深度
	`define ROM_ADDR_W 11	// 地址宽度
	`define RomAddrBus 10:0 // 地址总线
	`define RomAddrLoc 10:0 // 地址的位置

`endif
