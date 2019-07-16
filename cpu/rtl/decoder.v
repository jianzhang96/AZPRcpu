/*
 -- ============================================================================
 -- FILE NAME	: decoder.v
 -- DESCRIPTION : 指令解码器
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
`include "isa.h"
`include "cpu.h"

/********** 模块 **********/
module decoder (
	/********** IF/ID流水线寄存器 **********/
	input  wire [`WordAddrBus]	 if_pc,			 // 程序计数器
	input  wire [`WordDataBus]	 if_insn,		 // 指令
	input  wire					 if_en,			 // 流水线数据的有效标志位
	/********** GPR接口 **********/
	input  wire [`WordDataBus]	 gpr_rd_data_0, // 读取数据 0
	input  wire [`WordDataBus]	 gpr_rd_data_1, // 读取数据 1
	output wire [`RegAddrBus]	 gpr_rd_addr_0, // 读取地址 0
	output wire [`RegAddrBus]	 gpr_rd_addr_1, // 读取地址 1
	/********** 数据直通 **********/
	// 来自ID阶段的数据直通
	input  wire					 id_en,			// 流水线数据有效
	input  wire [`RegAddrBus]	 id_dst_addr,	// 写入地址
	input  wire					 id_gpr_we_,	// 写入有效
	input  wire [`MemOpBus]		 id_mem_op,		// 内存操作
	// 来自EX阶段的数据直通
	input  wire					 ex_en,			// 流水线数据有效
	input  wire [`RegAddrBus]	 ex_dst_addr,	// 写入地址
	input  wire					 ex_gpr_we_,	// 写入有效
	input  wire [`WordDataBus]	 ex_fwd_data,	// 数据直通
	// 来自MEM阶段的数据直通
	input  wire [`WordDataBus]	 mem_fwd_data,	// 数据直通
	/********** 控制寄存器接口 **********/
	input  wire [`CpuExeModeBus] exe_mode,		// 执行模式
	input  wire [`WordDataBus]	 creg_rd_data,	// 读取的数据
	output wire [`RegAddrBus]	 creg_rd_addr,	// 读取的地址
	/********** 解码结果 **********/
	output reg	[`AluOpBus]		 alu_op,		// ALU操作
	output reg	[`WordDataBus]	 alu_in_0,		// ALU输入 0
	output reg	[`WordDataBus]	 alu_in_1,		// ALU输入 1
	output reg	[`WordAddrBus]	 br_addr,		// 分支地址
	output reg					 br_taken,		// 分支成立
	output reg					 br_flag,		// 分支标志位
	output reg	[`MemOpBus]		 mem_op,		// 内存操作
	output wire [`WordDataBus]	 mem_wr_data,	// 内存写入数据
	output reg	[`CtrlOpBus]	 ctrl_op,		// 控制操作
	output reg	[`RegAddrBus]	 dst_addr,		// 通用寄存器写入地址
	output reg					 gpr_we_,		// 通用寄存器写入有效
	output reg	[`IsaExpBus]	 exp_code,		// 异常代码
	output reg					 ld_hazard		// Load冒险
);

	/********** 指令字段 **********/
	wire [`IsaOpBus]	op		= if_insn[`IsaOpLoc];	  // 操作码
	wire [`RegAddrBus]	ra_addr = if_insn[`IsaRaAddrLoc]; // Ra地址
	wire [`RegAddrBus]	rb_addr = if_insn[`IsaRbAddrLoc]; // Rb地址
	wire [`RegAddrBus]	rc_addr = if_insn[`IsaRcAddrLoc]; // Rc地址
	wire [`IsaImmBus]	imm		= if_insn[`IsaImmLoc];	  // 立即数
	/********** 立即数 **********/
	// 符号扩充后的立即数
	wire [`WordDataBus] imm_s = {{`ISA_EXT_W{imm[`ISA_IMM_MSB]}}, imm};
	// 0扩充后的立即数
	wire [`WordDataBus] imm_u = {{`ISA_EXT_W{1'b0}}, imm};
	/********** 寄存器读取地址 **********/
	assign gpr_rd_addr_0 = ra_addr; // 寄存器读取地址 0
	assign gpr_rd_addr_1 = rb_addr; // 寄存器读取地址 1
	assign creg_rd_addr	 = ra_addr; // 控制寄存器读取地址
	/********** 从通用寄存器读取的数据 **********/
	reg			[`WordDataBus]	ra_data;						  // Ra寄存器读取的数据（无符号）
	wire signed [`WordDataBus]	s_ra_data = $signed(ra_data);	  // Ra寄存器读取的数据（有符号）
	reg			[`WordDataBus]	rb_data;						  // Rb寄存器读取的数据（无符号）
	wire signed [`WordDataBus]	s_rb_data = $signed(rb_data);	  // Rb寄存器读取的数据（有符号）
	assign mem_wr_data = rb_data; // 内存写入数据
	/********** 地址 **********/
	wire [`WordAddrBus] ret_addr  = if_pc + 1'b1;					 // 返回地址
	wire [`WordAddrBus] br_target = if_pc + imm_s[`WORD_ADDR_MSB:0]; // 分支目标地址
	wire [`WordAddrBus] jr_target = ra_data[`WordAddrLoc];		   // 跳转目标地址

	/********** 数据直通 **********/
	always @(*) begin
		/* Ra寄存器 */
		if ((id_en == `ENABLE) && (id_gpr_we_ == `ENABLE_) && 
			(id_dst_addr == ra_addr)) begin
			ra_data = ex_fwd_data;	 // 来自EX阶段的数据直通
		end else if ((ex_en == `ENABLE) && (ex_gpr_we_ == `ENABLE_) && 
					 (ex_dst_addr == ra_addr)) begin
			ra_data = mem_fwd_data;	 // 来自MEM阶段的数据直通
		end else begin
			ra_data = gpr_rd_data_0; // 从寄存器堆读取
		end
		/* Rb寄存器 */
		if ((id_en == `ENABLE) && (id_gpr_we_ == `ENABLE_) && 
			(id_dst_addr == rb_addr)) begin
			rb_data = ex_fwd_data;	 // 来自EX阶段的数据直通
		end else if ((ex_en == `ENABLE) && (ex_gpr_we_ == `ENABLE_) && 
					 (ex_dst_addr == rb_addr)) begin
			rb_data = mem_fwd_data;	 // 来自MEM阶段的数据直通
		end else begin
			rb_data = gpr_rd_data_1; // 从寄存器堆读取
		end
	end

	/********** Load冒险检测 **********/
	always @(*) begin
		if ((id_en == `ENABLE) && (id_mem_op == `MEM_OP_LDW) &&
			((id_dst_addr == ra_addr) || (id_dst_addr == rb_addr))) begin
			ld_hazard = `ENABLE;  // Load冒险
		end else begin
			ld_hazard = `DISABLE; // 冒险未发生
		end
	end

	/********** 指令解码 **********/
	always @(*) begin
		/* 默认值 */
		alu_op	 = `ALU_OP_NOP;
		alu_in_0 = ra_data;
		alu_in_1 = rb_data;
		br_taken = `DISABLE;
		br_flag	 = `DISABLE;
		br_addr	 = {`WORD_ADDR_W{1'b0}};
		mem_op	 = `MEM_OP_NOP;
		ctrl_op	 = `CTRL_OP_NOP;
		dst_addr = rb_addr;
		gpr_we_	 = `DISABLE_;
		exp_code = `ISA_EXP_NO_EXP;
		/*  */
		if (if_en == `ENABLE) begin
			case (op)
				/* 逻辑运算指令 */
				`ISA_OP_ANDR  : begin // 寄存器间逻辑与
					alu_op	 = `ALU_OP_AND;
					dst_addr = rc_addr;
					gpr_we_	 = `ENABLE_;
				end
				`ISA_OP_ANDI  : begin // 寄存器与立即数的逻辑与
					alu_op	 = `ALU_OP_AND;
					alu_in_1 = imm_u;
					gpr_we_	 = `ENABLE_;
				end
				`ISA_OP_ORR	  : begin // 寄存器间的逻辑或
					alu_op	 = `ALU_OP_OR;
					dst_addr = rc_addr;
					gpr_we_	 = `ENABLE_;
				end
				`ISA_OP_ORI	  : begin // 寄存器与立即数的逻辑或
					alu_op	 = `ALU_OP_OR;
					alu_in_1 = imm_u;
					gpr_we_	 = `ENABLE_;
				end
				`ISA_OP_XORR  : begin // 寄存器间的逻辑异或
					alu_op	 = `ALU_OP_XOR;
					dst_addr = rc_addr;
					gpr_we_	 = `ENABLE_;
				end
				`ISA_OP_XORI  : begin // 寄存器与立即数的逻辑异或
					alu_op	 = `ALU_OP_XOR;
					alu_in_1 = imm_u;
					gpr_we_	 = `ENABLE_;
				end
				/* 算术运算指令 */
				`ISA_OP_ADDSR : begin // 寄存器间的有符号加法
					alu_op	 = `ALU_OP_ADDS;
					dst_addr = rc_addr;
					gpr_we_	 = `ENABLE_;
				end
				`ISA_OP_ADDSI : begin // 寄存器与立即数间的有符号加法
					alu_op	 = `ALU_OP_ADDS;
					alu_in_1 = imm_s;
					gpr_we_	 = `ENABLE_;
				end
				`ISA_OP_ADDUR : begin // 寄存器间的无符号加法
					alu_op	 = `ALU_OP_ADDU;
					dst_addr = rc_addr;
					gpr_we_	 = `ENABLE_;
				end
				`ISA_OP_ADDUI : begin // 寄存器与立即数的无符号加法
					alu_op	 = `ALU_OP_ADDU;
					alu_in_1 = imm_s;
					gpr_we_	 = `ENABLE_;
				end
				`ISA_OP_SUBSR : begin // 寄存器间的有符号减法
					alu_op	 = `ALU_OP_SUBS;
					dst_addr = rc_addr;
					gpr_we_	 = `ENABLE_;
				end
				`ISA_OP_SUBUR : begin // 寄存器间的无符号减法
					alu_op	 = `ALU_OP_SUBU;
					dst_addr = rc_addr;
					gpr_we_	 = `ENABLE_;
				end
				/* 移位指令 */
				`ISA_OP_SHRLR : begin // 寄存器间的逻辑右移
					alu_op	 = `ALU_OP_SHRL;
					dst_addr = rc_addr;
					gpr_we_	 = `ENABLE_;
				end
				`ISA_OP_SHRLI : begin // 寄存器与立即数间的逻辑右移
					alu_op	 = `ALU_OP_SHRL;
					alu_in_1 = imm_u;
					gpr_we_	 = `ENABLE_;
				end
				`ISA_OP_SHLLR : begin // 寄存器间的逻辑左移
					alu_op	 = `ALU_OP_SHLL;
					dst_addr = rc_addr;
					gpr_we_	 = `ENABLE_;
				end
				`ISA_OP_SHLLI : begin // 寄存器与立即数间的逻辑左移
					alu_op	 = `ALU_OP_SHLL;
					alu_in_1 = imm_u;
					gpr_we_	 = `ENABLE_;
				end
				/* 分支指令 */
				`ISA_OP_BE	  : begin // 寄存器间的有符号比较（Ra==Rb）
					br_addr	 = br_target;
					br_taken = (ra_data == rb_data) ? `ENABLE : `DISABLE;
					br_flag	 = `ENABLE;
				end
				`ISA_OP_BNE	  : begin // 寄存器间的有符号比较（Ra！=Rb）
					br_addr	 = br_target;
					br_taken = (ra_data != rb_data) ? `ENABLE : `DISABLE;
					br_flag	 = `ENABLE;
				end
				`ISA_OP_BSGT  : begin // 寄存器间的有符号比较（Ra < Rb）
					br_addr	 = br_target;
					br_taken = (s_ra_data < s_rb_data) ? `ENABLE : `DISABLE;
					br_flag	 = `ENABLE;
				end
				`ISA_OP_BUGT  : begin // 寄存器间的无符号比较（Ra < Rb）
					br_addr	 = br_target;
					br_taken = (ra_data < rb_data) ? `ENABLE : `DISABLE;
					br_flag	 = `ENABLE;
				end
				`ISA_OP_JMP	  : begin // 无条件分支
					br_addr	 = jr_target;
					br_taken = `ENABLE;
					br_flag	 = `ENABLE;
				end
				`ISA_OP_CALL  : begin // 调用
					alu_in_0 = {ret_addr, {`BYTE_OFFSET_W{1'b0}}};
					br_addr	 = jr_target;
					br_taken = `ENABLE;
					br_flag	 = `ENABLE;
					dst_addr = `REG_ADDR_W'd31;
					gpr_we_	 = `ENABLE_;
				end
				/* 内存访问指令 */
				`ISA_OP_LDW	  : begin // 字读取
					alu_op	 = `ALU_OP_ADDU;
					alu_in_1 = imm_s;
					mem_op	 = `MEM_OP_LDW;
					gpr_we_	 = `ENABLE_;
				end
				`ISA_OP_STW	  : begin // 字写入
					alu_op	 = `ALU_OP_ADDU;
					alu_in_1 = imm_s;
					mem_op	 = `MEM_OP_STW;
				end
				/* 系统调用指令 */
				`ISA_OP_TRAP  : begin // 陷阱
					exp_code = `ISA_EXP_TRAP;
				end
				/* 特权指令 */
				`ISA_OP_RDCR  : begin // 读取控制寄存器
					if (exe_mode == `CPU_KERNEL_MODE) begin
						alu_in_0 = creg_rd_data;
						gpr_we_	 = `ENABLE_;
					end else begin
						exp_code = `ISA_EXP_PRV_VIO;
					end
				end
				`ISA_OP_WRCR  : begin // 写入控制寄存器
					if (exe_mode == `CPU_KERNEL_MODE) begin
						ctrl_op	 = `CTRL_OP_WRCR;
					end else begin
						exp_code = `ISA_EXP_PRV_VIO;
					end
				end
				`ISA_OP_EXRT  : begin // 从异常恢复
					if (exe_mode == `CPU_KERNEL_MODE) begin
						ctrl_op	 = `CTRL_OP_EXRT;
					end else begin
						exp_code = `ISA_EXP_PRV_VIO;
					end
				end
				/* 其他指令 */
				default		  : begin // 未定义指令
					exp_code = `ISA_EXP_UNDEF_INSN;
				end
			endcase
		end
	end

endmodule
