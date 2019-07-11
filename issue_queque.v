`timescale 1ns / 1ns
//`define 64bit 63:0
//`define 32bit 31:0
`include "isa.h"
`include "cpu.h"
`include "each_module.h"
`define ITEM_NUMBER 32 

/*
`define INSN_ALU_TYPE 2'b00
`define INSN_MULT_TYPE 2'b01
`define INSN_DIV_TYPE 2'b10
`define INSN_NOP_TYPE 2'b11

`define INSN_ADD		6'h00
`define	INSN_ADDI		6'h01
`define	INSN_ADDU		6'h02
`define	INSN_ADDIU		6'h03
`define	INSN_SUB		6'h04
`define	INSN_SUBU		6'h05
`define	INSN_SLT		6'h06
`define	INSN_SLTI		6'h07
`define	INSN_SLTU		6'h08
`define	INSN_SLTIU		6'h09
`define	INSN_DIV		6'h0a
`define	INSN_DIVU		6'h0b
`define INSN_MULT		6'h0c
`define	INSN_MULTU		6'h0d
`define	INSN_AND		6'h0e
`define	INSN_ANDI		6'h0f
`define	INSN_LUI		6'h10
`define	INSN_NOR		6'h11
`define	INSN_OR			6'h12
`define	INSN_ORI		6'h13
`define	INSN_XOR		6'h14
`define	INSN_XORI		6'h15
`define	INSN_SLL		6'h16
`define INSN_SLLV		6'h17
`define	INSN_SRA		6'h18
`define	INSN_SRAV		6'h19
`define	INSN_SRL		6'h1a
`define	INSN_SRLV		6'h1b
`define	INSN_BEQ		6'h1c
`define	INSN_BNE		6'h1d
`define	INSN_BGEZ		6'h1e
`define	INSN_BGTZ		6'h1f
`define	INSN_BLEZ		6'h20
`define	INSN_BLTZ		6'h21
`define	INSN_BLTZAL		6'h22
`define	INSN_BGEZAL		6'h23
`define	INSN_J			6'h24
`define	INSN_JAL		6'h25
`define	INSN_JR			6'h26
`define	INSN_JALR		6'h27
`define	INSN_MFHI		6'h28
`define INSN_MFLO		6'h29
`define	INSN_MTHI		6'h2a
`define	INSN_MTLO		6'h2b
`define	INSN_BREAK		6'h2c
`define	INSN_SYSCALL	6'h2d
`define	INSN_LB			6'h2e
`define	INSN_LBU		6'h2f
`define	INSN_LH			6'h30
`define	INSN_LHU		6'h31
`define	INSN_LW			6'h32
`define	INSN_SB			6'h33
`define	INSN_SH			6'h34
`define	INSN_SW			6'h35
`define	INSN_ERET		6'h36
`define	INSN_MFC0		6'h37
`define	INSN_MTC0		6'h38
`define	INSN_RI			6'h39
`define	INSN_NOP		6'h3a
*/

module issue_queque(
input clk,
input rst_,
input flush,
//----------- input from Decoder -----------//
input id_valid_ns,
input [63:0] is_pc,
input [9:0]   is_ptab_addr,
input [54:0] is_decode_info_0,
input [54:0] is_decode_info_1,
input [5:0]   is_decode_valid_0,
input [5:0]   is_decode_valid_1,
input [9:0]   is_exe_code,

//----------- input from Register File -----------//
input [31:0] read_regfile_data0,
input [31:0] read_regfile_data1,
input [31:0] read_regfile_data2,
input [31:0] read_regfile_data3,

//input fu0_busy,// reserved
//input fu1_busy,// reserved
//input fu2_busy,// reserved
//input fu3_busy,// reserved
//----------- input from EX -----------//
input ex_allow_in,
input [4:0] ex_dst0,
input [4:0] ex_dst1,
input ex_dst0_valid,
input ex_dst1_valid,
input [32:0] ex_dst0_data,
input [32:0] ex_dst1_data,
input ex_dst0_data_valid,
input ex_dst1_data_valid,


//----------- input from MEM -----------//
input [4:0] mem_dst0,// reserved
input [4:0] mem_dst1,// reserved
input mem_dst0_valid,// reserved
input mem_dst1_valid,// reserved

//----------- input from WB -----------//
input [4:0] wb_dst0,
input [4:0] wb_dst1,
input wb_dst0_valid,
input wb_dst1_valid,
input [32:0] wb_dst0_data,
input [32:0] wb_dst1_data,
input wb_dst0_data_valid,
input wb_dst1_data_valid,

//----------- output to EX -----------//
output reg [4:0]  inst0_to_fu_dst,
output reg [4:0]  inst1_to_fu_dst,
output reg [5:0]  inst0_to_fu_meaning,
output reg [5:0]  inst1_to_fu_meaning,
output reg [4:0]  inst0_error_code,
output reg [4:0]  inst1_error_code,
output reg [4:0]  inst0_to_fu_ptab_addr,
output reg [4:0]  inst1_to_fu_ptab_addr,
output reg [4:0]  inst0_to_fu_src0,
output reg [4:0]  inst0_to_fu_src1,
output reg [4:0]  inst1_to_fu_src0,
output reg [4:0]  inst1_to_fu_src1,
output reg [31:0] inst0_to_fu_pc,
output reg [31:0] inst1_to_fu_pc,
output reg [31:0] inst0_to_fu_imme,
output reg [31:0] inst1_to_fu_imme,
output reg inst0_valid,
output reg inst1_valid,
output reg is_to_next_stage_valid,

output reg [31:0] inst0_to_fu_data0,// reserved
output reg [31:0] inst0_to_fu_data1,// reserved
output reg [31:0] inst1_to_fu_data0,// reserved
output reg [31:0] inst1_to_fu_data1,// reserved

//----------- output to Register File  -----------//
output reg  [4:0]  read_regfile_addr0,
output reg  [4:0]  read_regfile_addr1,
output reg  [4:0]  read_regfile_addr2,
output reg  [4:0]  read_regfile_addr3,
output reg  read_regfile_addr0_valid,
output reg  read_regfile_addr1_valid,
output reg  read_regfile_addr2_valid,
output reg  read_regfile_addr3_valid,

//----------- output to Decoder -----------//
output wire  is_allow_in

);



reg [31:0]   pc                      [0:`ITEM_NUMBER-1];
reg [4:0]     src0                  [0:`ITEM_NUMBER-1];
reg [4:0]     src1                  [0:`ITEM_NUMBER-1];
reg [31:0]   imme                  [0:`ITEM_NUMBER-1];
reg [3:0]     inst_type        [0:`ITEM_NUMBER-1];
reg [5:0]     inst_meaning  [0:`ITEM_NUMBER-1];
reg [4:0]     dst                    [0:`ITEM_NUMBER-1];
reg [5:0]     data_valid      [0:`ITEM_NUMBER-1];
reg [4:0]     ptab_addr        [0:`ITEM_NUMBER-1];
reg [4:0]     exe_code          [0:`ITEM_NUMBER-1];
reg item_busy                       [0:`ITEM_NUMBER-1];

/*
reg [31:0] pc_buffer;// reserved
reg [4:0]  src0_buffer;// reserved
reg [4:0]  src1_buffer;// reserved
reg [31:0] imme_buffer;// reserved
reg [3:0]  inst_type_buffer;// reserved
reg [5:0]  inst_meaning_buffer;// reserved
reg [4:0]  dst_buffer;// reserved
reg inst_buffer_valid;// reserved
*/

/*
reg  fu0_dst;// reserved
reg  fu1_dst;// reserved
reg  to_fu0_data0;// reserved
reg  to_fu0_data1;// reserved
reg  to_fu1_data0;// reserved
reg  to_fu1_data1;// reserved
*/

reg  [5:0] current_item;
reg  [1:0] issue_enable;
reg  [1:0] issue_queue_is_free;
reg  issue_queque_is_full;

wire  [31:0] inst0_pc;
wire  [31:0] inst1_pc;
wire  [4:0]   inst0_dst;
wire  [4:0]   inst1_dst;
wire  [4:0]   inst0_src0;
wire  [4:0]   inst0_src1;
wire  [4:0]   inst1_src0;
wire  [4:0]   inst1_src1;
wire  [31:0] inst0_imme;
wire  [31:0] inst1_imme;
wire  [3:0]   inst0_type;
wire  [3:0]   inst1_type;
wire  [5:0]   inst0_meaning;
wire  [5:0]   inst1_meaning;

reg [2:0]   inst0_to_fu;
reg [2:0]   inst1_to_fu;
wire [5:0] inst0_data_valid;
wire [5:0] inst1_data_valid;

wire [4:0] inst0_ptab_addr;
wire [4:0] inst0_exe_code;
wire [4:0] inst1_ptab_addr;
wire [4:0] inst1_exe_code;

reg [4:0] inst0_src0_conflict_detect;
reg [4:0] inst0_src1_conflict_detect;
reg [4:0] inst1_src0_conflict_detect;
reg [4:0] inst1_src1_conflict_detect;

reg inst0_conflict_detect;
reg inst1_conflict_detect;
reg inst0_issue_enable;
reg inst1_issue_enable;

wire  [5:0]inst0_data_valiad;
wire  [5:0]inst1_data_valiad;
reg [5:0] inst0_data_valiad_next;
reg [5:0] inst1_data_valiad_next;
wire fu0_busy;
wire fu1_busy;
wire fu2_busy;
wire fu3_busy;

integer i;

assign  inst0_pc               = is_pc                       [63:32];
assign  inst0_dst             = is_decode_info_0 [54:50];
assign  inst0_src0           = is_decode_info_0 [49:45];
assign  inst0_src1           = is_decode_info_0 [44:40];
assign  inst0_imme           = is_decode_info_0 [39:8];
assign  inst0_type           = is_decode_info_0 [7:6];
assign  inst0_meaning     = is_decode_info_0 [5:0];
assign  inst0_ptab_addr = is_ptab_addr         [9:5];
assign  inst0_exe_code   = is_exe_code           [9:5];

assign  inst1_pc               = is_pc                       [31:0];
assign  inst1_dst             = is_decode_info_1 [54:50];
assign  inst1_src0           = is_decode_info_1 [49:45];
assign  inst1_src1           = is_decode_info_1 [44:40];
assign  inst1_imme           = is_decode_info_1 [39:8];
assign  inst1_type           = is_decode_info_1 [7:6];
assign  inst1_meaning     = is_decode_info_1 [5:0];
assign  inst1_ptab_addr = is_ptab_addr         [4:0];
assign  inst1_exe_code   = is_exe_code           [4:0];

assign  fu0_busy = ~ex_allow_in;
assign  fu1_busy = ~ex_allow_in;
assign  fu2_busy = ~ex_allow_in;
assign  fu3_busy = ~ex_allow_in;

always @(posedge clk)begin
	if(!rst_ | flush)begin
		for (i=0; i<=`ITEM_NUMBER; i=i+1)begin
			item_busy       [i] <= 1'b0;
			pc                     [i] <= 32'b0;
			dst                   [i] <= 5'b0;
			src0                 [i] <= 5'b0;
			src1                 [i] <= 5'b0;
			imme                 [i] <= 32'b0;
			inst_type       [i] <= 4'b0;
			inst_meaning [i] <= 6'b0;
			data_valid     [i] <= 6'b0;
			ptab_addr       [i] <= 5'b0;
			exe_code         [i] <= 5'b0;
		end
	end
	else if(issue_enable == 2'b00)begin
		if((issue_queue_is_free == 2'b10)&&(id_valid_ns))begin
			item_busy       [current_item] <= 1'b1;
			pc                     [current_item] <= inst0_pc;
			dst                   [current_item] <= inst0_dst;
			src0                 [current_item] <= inst0_src0;
			src1                 [current_item] <= inst0_src1;
			imme                 [current_item] <= inst0_imme;
			inst_type       [current_item] <= inst0_type;
			inst_meaning [current_item] <= inst0_meaning;
			data_valid     [current_item] <= is_decode_valid_0;
			ptab_addr       [current_item] <= inst0_ptab_addr;
			exe_code         [current_item] <= inst0_exe_code;
			
			item_busy       [current_item+1] <= 1'b1;
			pc                     [current_item+1] <= inst1_pc;
			dst                   [current_item+1] <= inst1_dst;
			src0                 [current_item+1] <= inst1_src0;
			src1                 [current_item+1] <= inst1_src1;
			imme                 [current_item+1] <= inst1_imme;
			inst_type       [current_item+1] <= inst1_type;
			inst_meaning [current_item+1] <= inst1_meaning;	
			data_valid     [current_item+1] <= is_decode_valid_1;
			ptab_addr       [current_item+1] <= inst1_ptab_addr;
			exe_code         [current_item+1] <= inst1_exe_code;
			for (i=0; i<=`ITEM_NUMBER-1; i=i+1)begin
				if((i!=current_item)&&(i!=current_item+1))begin
					item_busy       [i] <= item_busy       [i];
					pc                     [i] <= pc                     [i];
					dst                   [i] <= dst                   [i];
					src0                 [i] <= src0                 [i];
					src1                 [i] <= src1                 [i];
					imme                 [i] <= imme                 [i];
					inst_type       [i] <= inst_type       [i];
					inst_meaning [i] <= inst_meaning [i];
					data_valid     [i] <= data_valid     [i];
					ptab_addr       [i] <= ptab_addr       [i];
					exe_code         [i] <= exe_code         [i];
				end
			end			
		end
		else if((issue_queue_is_free == 2'b01)&&(id_valid_ns))begin
			item_busy       [current_item] <= 1'b1;
			pc                     [current_item] <= inst0_pc;
			dst                   [current_item] <= inst0_dst;
			src0                 [current_item] <= inst0_src0;
			src1                 [current_item] <= inst0_src1;
			imme                 [current_item] <= inst0_imme;
			inst_type       [current_item] <= inst0_type;
			inst_meaning [current_item] <= inst0_meaning;
			data_valid     [current_item] <= is_decode_valid_0;
			ptab_addr       [current_item] <= inst0_ptab_addr;
			exe_code         [current_item] <= inst0_exe_code;
			for (i=0; i<=`ITEM_NUMBER-1; i=i+1)begin
				if(i!=current_item)begin
					item_busy       [i] <= item_busy       [i];
					pc                     [i] <= pc                     [i];
					dst                   [i] <= dst                   [i];
					src0                 [i] <= src0                 [i];
					src1                 [i] <= src1                 [i];
					imme                 [i] <= imme                 [i];
					inst_type       [i] <= inst_type       [i];
					inst_meaning [i] <= inst_meaning [i];
					data_valid     [i] <= data_valid     [i];
					ptab_addr       [i] <= ptab_addr       [i];
					exe_code         [i] <= exe_code         [i];
				end
			end					
		end
	end
	else if(issue_enable == 2'b01)begin
		if((issue_queue_is_free == 2'b10)&&(id_valid_ns))begin
			item_busy       [current_item-1] <= 1'b1;
			pc                     [current_item-1] <= inst0_pc;
			dst                   [current_item-1] <= inst0_dst;
			src0                 [current_item-1] <= inst0_src0;
			src1                 [current_item-1] <= inst0_src1;
			imme                 [current_item-1] <= inst0_imme;
			inst_type       [current_item-1] <= inst0_type;
			inst_meaning [current_item-1] <= inst0_meaning;
			data_valid     [current_item-1] <= is_decode_valid_0;
			ptab_addr       [current_item-1] <= inst0_ptab_addr;
			exe_code         [current_item-1] <= inst0_exe_code;
			
			item_busy       [current_item] <= 1'b1;
			pc                     [current_item] <= inst1_pc;
			dst                   [current_item] <= inst1_dst;
			src0                 [current_item] <= inst1_src0;
			src1                 [current_item] <= inst1_src1;
			imme                 [current_item] <= inst1_imme;
			inst_type       [current_item] <= inst1_type;
			inst_meaning [current_item] <= inst1_meaning;	
			data_valid     [current_item] <= is_decode_valid_1;
			ptab_addr       [current_item] <= inst1_ptab_addr;
			exe_code         [current_item] <= inst1_exe_code;
			
			for (i=0; i<=`ITEM_NUMBER-1; i=i+1)begin
				if((i!=current_item)&&(i!=current_item-1)&&(i<=`ITEM_NUMBER-2))begin
					item_busy       [i] <= item_busy       [i+1];
					pc                     [i] <= pc                     [i+1];
					dst                   [i] <= dst                   [i+1];
					src0                 [i] <= src0                 [i+1];
					src1                 [i] <= src1                 [i+1];
					imme                 [i] <= imme                 [i+1];
					inst_type       [i] <= inst_type       [i+1];
					inst_meaning [i] <= inst_meaning [i+1];
					data_valid     [i] <= data_valid     [i+1];
					ptab_addr       [i] <= ptab_addr       [i+1];
					exe_code         [i] <= exe_code         [i+1];					
				end
				if(i==`ITEM_NUMBER-1)begin
					item_busy       [i] <= 1'b0;
					pc                     [i] <= 32'b0;
					dst                   [i] <= 5'b0;
					src0                 [i] <= 5'b0;
					src1                 [i] <= 5'b0;
					imme                 [i] <= 32'b0;
					inst_type       [i] <= 4'b0;
					inst_meaning [i] <= 6'b0;	
					data_valid     [i] <= 6'b0;
					ptab_addr       [i] <=  5'b0;
					exe_code         [i] <=  5'b0;			
				end
			end				
		end
		else if((issue_queue_is_free == 2'b01)&&(id_valid_ns))begin
			item_busy       [current_item-1] <= 1'b1;
			pc                     [current_item-1] <= inst0_pc;
			dst                   [current_item-1] <= inst0_dst;
			src0                 [current_item-1] <= inst0_src0;
			src1                 [current_item-1] <= inst0_src1;
			imme                 [current_item-1] <= inst0_imme;
			inst_type       [current_item-1] <= inst0_type;
			inst_meaning [current_item-1] <= inst0_meaning;		
			data_valid     [current_item-1] <= is_decode_valid_0;
			ptab_addr       [current_item-1] <= inst0_ptab_addr;
			exe_code         [current_item-1] <= inst0_exe_code;
			
			item_busy       [current_item] <= 1'b1;
			pc                     [current_item] <= inst1_pc;
			dst                   [current_item] <= inst1_dst;
			src0                 [current_item] <= inst1_src0;
			src1                 [current_item] <= inst1_src1;
			imme                 [current_item] <= inst1_imme;
			inst_type       [current_item] <= inst1_type;
			inst_meaning [current_item] <= inst1_meaning;	
			data_valid     [current_item] <= is_decode_valid_1;
			ptab_addr       [current_item] <= inst1_ptab_addr;
			exe_code         [current_item] <= inst1_exe_code;
			
			for (i=0; i<=`ITEM_NUMBER-1; i=i+1)begin 
				if((i!=current_item)&&(i!=current_item-1))begin
					item_busy       [i] <= item_busy       [i+1];
					pc                     [i] <= pc                     [i+1];
					dst                   [i] <= dst                   [i+1];
					src0                 [i] <= src0                 [i+1];
					src1                 [i] <= src1                 [i+1];
					imme                 [i] <= imme                 [i+1];
					inst_type       [i] <= inst_type       [i+1];
					inst_meaning [i] <= inst_meaning [i+1];
					data_valid     [i] <= data_valid     [i+1];
					ptab_addr       [i] <= ptab_addr       [i+1];
					exe_code         [i] <= exe_code         [i+1];	
				end
			end					
		end	
		else if((issue_queue_is_free == 2'b00)&&(id_valid_ns))begin
			item_busy       [current_item-1] <= 1'b1;
			pc                     [current_item-1] <= inst0_pc;
			dst                   [current_item-1] <= inst0_dst;
			src0                 [current_item-1] <= inst0_src0;
			src1                 [current_item-1] <= inst0_src1;
			imme                 [current_item-1] <= inst0_imme;
			inst_type       [current_item-1] <= inst0_type;
			inst_meaning [current_item-1] <= inst0_meaning;		
			data_valid     [current_item-1] <= is_decode_valid_0;
			ptab_addr       [current_item-1] <= inst0_ptab_addr;
			exe_code         [current_item-1] <= inst0_exe_code;							
		end	
		else begin
			for (i=0; i<=`ITEM_NUMBER-1; i=i+1)begin 
				if(i<=`ITEM_NUMBER-2)begin
					item_busy       [i] <= item_busy       [i+1];
					pc                    [i] <= pc                     [i+1];
					dst                  [i] <= dst                   [i+1];
					src0                [i] <= src0                 [i+1];
					src1                [i] <= src1                 [i+1];
					imme                [i] <= imme                 [i+1];
					inst_type       [i] <= inst_type       [i+1];
					inst_meaning [i] <= inst_meaning [i+1];
					data_valid     [i] <= data_valid     [i+1];
					ptab_addr       [i] <= ptab_addr       [i+1];
					exe_code         [i] <= exe_code         [i+1];
				end
				else begin
					item_busy       [i] <= 1'b0;
					pc                     [i] <= 32'b0;
					dst                   [i] <= 5'b0;
					src0                 [i] <= 5'b0;
					src1                 [i] <= 5'b0;
					imme                 [i] <= 32'b0;
					inst_type       [i] <= 4'b0;
					inst_meaning  [i] <= 6'b0;
					data_valid     [i] <= 6'b0;
					ptab_addr       [i] <=  5'b0;
					exe_code         [i] <=  5'b0;
				end
			end			
		end		
	end
	else if(issue_enable == 2'b10)begin
		if((issue_queue_is_free == 2'b10)&&(id_valid_ns))begin
			item_busy       [current_item-2] <= 1'b1;
			pc                     [current_item-2] <= inst0_pc;
			dst                   [current_item-2] <= inst0_dst;
			src0                 [current_item-2] <= inst0_src0;
			src1                 [current_item-2] <= inst0_src1;
			imme                 [current_item-2] <= inst0_imme;
			inst_type       [current_item-2] <= inst0_type;
			inst_meaning [current_item-2] <= inst0_meaning;
			data_valid     [current_item-2] <= is_decode_valid_0;
			ptab_addr       [current_item-2] <= inst0_ptab_addr;
			exe_code         [current_item-2] <= inst0_exe_code;
			
			item_busy       [current_item-1] <= 1'b1;
			pc                     [current_item-1] <= inst1_pc;
			dst                   [current_item-1] <= inst1_dst;
			src0                 [current_item-1] <= inst1_src0;
			src1                 [current_item-1] <= inst1_src1;
			imme                 [current_item-1] <= inst1_imme;
			inst_type       [current_item-1] <= inst1_type;
			inst_meaning [current_item-1] <= inst1_meaning;	
			data_valid     [current_item-1] <= is_decode_valid_1;
			ptab_addr       [current_item-1] <= inst0_ptab_addr;
			exe_code         [current_item-1] <= inst0_exe_code;

			for (i=0; i<=`ITEM_NUMBER-1; i=i+1)begin 
				if((i!=current_item-2)&&(i!=current_item-1)&&(i<=`ITEM_NUMBER-3))begin
					item_busy       [i] <= item_busy       [i+2];
					pc                     [i] <= pc                     [i+2];
					dst                   [i] <= dst                   [i+2];
					src0                 [i] <= src0                 [i+2];
					src1                 [i] <= src1                 [i+2];
					imme                 [i] <= imme                 [i+2];
					inst_type       [i] <= inst_type       [i+2];
					inst_meaning [i] <= inst_meaning [i+2];
					data_valid     [i] <= data_valid     [i+2];
					ptab_addr       [i] <= ptab_addr       [i+2];
					exe_code         [i] <= exe_code         [i+2];
				end
				if((i!=current_item-2)&&(i!=current_item-1)&&(i>`ITEM_NUMBER-3))begin
					item_busy       [i] <= 1'b0;
					pc                     [i] <= 32'b0;
					dst                   [i] <= 5'b0;
					src0                 [i] <= 5'b0;
					src1                 [i] <= 5'b0;
					imme                 [i] <= 32'b0;
					inst_type       [i] <= 4'b0;
					inst_meaning  [i] <= 6'b0;
					data_valid     [i] <= 6'b0;
					ptab_addr       [i] <=  5'b0;
					exe_code         [i] <=  5'b0;
				end
			end	
			
		end	
		else if((issue_queue_is_free == 2'b01)&&(id_valid_ns))begin
			item_busy       [current_item-2] <= 1'b1;
			pc                     [current_item-2] <= inst0_pc;
			dst                   [current_item-2] <= inst0_dst;
			src0                 [current_item-2] <= inst0_src0;
			src1                 [current_item-2] <= inst0_src1;
			imme                 [current_item-2] <= inst0_imme;
			inst_type       [current_item-2] <= inst0_type;
			inst_meaning [current_item-2] <= inst0_meaning;
			data_valid     [current_item-2] <= is_decode_valid_0;
			ptab_addr       [current_item-2] <= inst0_ptab_addr;
			exe_code         [current_item-2] <= inst0_exe_code;			
			
			item_busy       [current_item-1] <= 1'b1;
			pc                     [current_item-1] <= inst1_pc;
			dst                   [current_item-1] <= inst1_dst;
			src0                 [current_item-1] <= inst1_src0;
			src1                 [current_item-1] <= inst1_src1;
			imme                 [current_item-1] <= inst1_imme;
			inst_type       [current_item-1] <= inst1_type;
			inst_meaning [current_item-1] <= inst1_meaning;	
			data_valid     [current_item-1] <= is_decode_valid_1;
			ptab_addr       [current_item-1] <= inst1_ptab_addr;
			exe_code         [current_item-1] <= inst1_exe_code;			
			for (i=0; i<=`ITEM_NUMBER-1; i=i+1)begin 
				if((i!=current_item-2)&&(i!=current_item-1)&&(i<=`ITEM_NUMBER-3))begin
					item_busy       [i] <= item_busy       [i+2];
					pc                     [i] <= pc                     [i+2];
					dst                   [i] <= dst                   [i+2];
					src0                 [i] <= src0                 [i+2];
					src1                 [i] <= src1                 [i+2];
					imme                 [i] <= imme                 [i+2];
					inst_type       [i] <= inst_type       [i+2];
					inst_meaning [i] <= inst_meaning [i+2];
					data_valid     [i] <= data_valid     [i+2];
					ptab_addr       [i] <= ptab_addr       [i+2];
					exe_code         [i] <= exe_code         [i+2];					
				end
				if((i!=current_item-2)&&(i!=current_item-1)&&(i>`ITEM_NUMBER-3))begin
					item_busy       [i] <= 1'b0;
					pc                     [i] <= 32'b0;
					dst                   [i] <= 5'b0;
					src0                 [i] <= 5'b0;
					src1                 [i] <= 5'b0;
					imme                 [i] <= 32'b0;
					inst_type       [i] <= 4'b0;
					inst_meaning [i] <= 6'b0;
					data_valid     [i] <= 6'b0;
					ptab_addr       [i] <=  5'b0;
					exe_code         [i] <=  5'b0;					
				end
			end
		end
		else if((issue_queue_is_free == 2'b00)&&(id_valid_ns))begin
			item_busy       [current_item-2] <= 1'b1;
			pc                     [current_item-2] <= inst0_pc;
			dst                   [current_item-2] <= inst0_dst;
			src0                 [current_item-2] <= inst0_src0;
			src1                 [current_item-2] <= inst0_src1;
			imme                 [current_item-2] <= inst0_imme;
			inst_type       [current_item-2] <= inst0_type;
			inst_meaning [current_item-2] <= inst0_meaning;
			data_valid     [current_item-2] <= is_decode_valid_0;
			ptab_addr       [current_item-2] <= inst0_ptab_addr;
			exe_code         [current_item-2] <= inst0_exe_code;	
			
			item_busy       [current_item-1] <= 1'b1;
			pc                     [current_item-1] <= inst1_pc;
			dst                   [current_item-1] <= inst1_dst;
			src0                 [current_item-1] <= inst1_src0;
			src1                 [current_item-1] <= inst1_src1;
			imme                 [current_item-1] <= inst1_imme;
			inst_type       [current_item-1] <= inst1_type;
			inst_meaning [current_item-1] <= inst1_meaning;		
			data_valid     [current_item-1] <= is_decode_valid_1;
			ptab_addr       [current_item-1] <= inst1_ptab_addr;
			exe_code         [current_item-1] <= inst1_exe_code;	
		end
		else begin
			for (i=0; i<=`ITEM_NUMBER-1; i=i+1)begin 
				if(i<=`ITEM_NUMBER-3)begin
					item_busy       [i] <= item_busy       [i+2];
					pc                    [i] <= pc                     [i+2];
					dst                  [i] <= dst                   [i+2];
					src0                [i] <= src0                 [i+2];
					src1                [i] <= src1                 [i+2];
					imme                [i] <= imme                 [i+2];
					inst_type       [i] <= inst_type       [i+2];
					inst_meaning [i] <= inst_meaning [i+2];
					data_valid     [i] <= data_valid     [i+2];
					ptab_addr       [i] <= ptab_addr       [i+2];
					exe_code         [i] <= exe_code         [i+2];
				end
				else begin
					item_busy       [i] <= 1'b0;
					pc                     [i] <= 32'b0;
					dst                   [i] <= 5'b0;
					src0                 [i] <= 5'b0;
					src1                 [i] <= 5'b0;
					imme                 [i] <= 32'b0;
					inst_type       [i] <= 4'b0;
					inst_meaning  [i] <= 6'b0;
					data_valid     [i] <= 6'b0;
					ptab_addr       [i] <=  5'b0;
					exe_code         [i] <=  5'b0;
				end
			end			
		end
				
	end

end



assign inst0_data_valid = data_valid[0];
assign inst1_data_valid = data_valid[1];

`define INST0_SRC0_CONFLICT_WITH_EX_DST0        5'b00010
`define INST0_SRC0_CONFLICT_WITH_EX_DST1        5'b00011
`define INST0_SRC0_CONFLICT_WITH_WB_DST0	       5'b00100
`define INST0_SRC0_CONFLICT_WITH_WB_DST1	       5'b00101
`define INST0_SRC0_CONFLICT_WITH_NOTHING        5'b00000

`define INST0_SRC1_CONFLICT_WITH_EX_DST0        5'b10010
`define INST0_SRC1_CONFLICT_WITH_EX_DST1        5'b10011
`define INST0_SRC1_CONFLICT_WITH_WB_DST0	       5'b10100
`define INST0_SRC1_CONFLICT_WITH_WB_DST1	       5'b10101
`define INST0_SRC1_CONFLICT_WITH_NOTHING        5'b10000

`define INST1_SRC0_CONFLICT_WITH_EX_DST0        5'b00010
`define INST1_SRC0_CONFLICT_WITH_EX_DST1        5'b00011
`define INST1_SRC0_CONFLICT_WITH_WB_DST0	       5'b00100
`define INST1_SRC0_CONFLICT_WITH_WB_DST1	       5'b00101
`define INST1_SRC0_CONFLICT_WITH_NOTHING        5'b00000
`define INST1_SRC0_CONFLICT_WITH_INST0      5'b01000

`define INST1_SRC1_CONFLICT_WITH_EX_DST0        5'b10010
`define INST1_SRC1_CONFLICT_WITH_EX_DST1        5'b10011
`define INST1_SRC1_CONFLICT_WITH_WB_DST0	       5'b10100
`define INST1_SRC1_CONFLICT_WITH_WB_DST1	       5'b10101
`define INST1_SRC1_CONFLICT_WITH_NOTHING        5'b10000
`define INST1_SRC1_CONFLICT_WITH_INST0      5'b11000
`define INST1_LOAD_STORE_CONFLICT			5'B11111

reg inst0_load_store_detect;
reg inst1_load_store_detect;
reg inst0_src0_data_ready;
reg inst0_src1_data_ready;
reg inst1_src0_data_ready;
reg inst1_src1_data_ready;
reg [31:0] regfile_data0;
reg [31:0] regfile_data1;
reg [31:0] regfile_data2;
reg [31:0] regfile_data3;

always @ (*)begin
	if(item_busy[0])begin
		case(inst_meaning[0])
			`INSN_LB : inst0_load_store_detect = 1'b1;
			`INSN_LBU: inst0_load_store_detect = 1'b1;
			`INSN_LH : inst0_load_store_detect = 1'b1;
			`INSN_LHU: inst0_load_store_detect = 1'b1;
			`INSN_LW : inst0_load_store_detect = 1'b1;
			`INSN_SB : inst0_load_store_detect = 1'b1;
			`INSN_SH : inst0_load_store_detect = 1'b1;
			`INSN_SW : inst0_load_store_detect = 1'b1;
			default  : inst0_load_store_detect = 1'b0;
		endcase
	end
	else begin
		inst0_load_store_detect = 1'b0;
	end
	
	if(item_busy[1])begin
		case(inst_meaning[1])
			`INSN_LB : inst1_load_store_detect = 1'b1;
			`INSN_LBU: inst1_load_store_detect = 1'b1;
			`INSN_LH : inst1_load_store_detect = 1'b1;
			`INSN_LHU: inst1_load_store_detect = 1'b1;
			`INSN_LW : inst1_load_store_detect = 1'b1;
			`INSN_SB : inst1_load_store_detect = 1'b1;
			`INSN_SH : inst1_load_store_detect = 1'b1;
			`INSN_SW : inst1_load_store_detect = 1'b1;
			default  : inst1_load_store_detect = 1'b0;
		endcase
	end
	else begin
		inst1_load_store_detect = 1'b0;
	end

	if(item_busy[0])begin
		if((src0[0] == ex_dst1)&&(ex_dst1_valid))begin
			inst0_src0_conflict_detect = `INST0_SRC0_CONFLICT_WITH_EX_DST1;
			inst0_src0_data_ready      = (ex_dst1_data_valid)? 1'b1 : 1'b0;
		end
		else if((src0[0] == ex_dst0)&&(ex_dst0_valid))begin
			inst0_src0_conflict_detect = `INST0_SRC0_CONFLICT_WITH_EX_DST0;
			inst0_src0_data_ready      = (ex_dst0_data_valid)? 1'b1 : 1'b0;
		end
		else if((src0[0] == wb_dst1)&&(wb_dst1_valid))begin
			inst0_src0_conflict_detect = `INST0_SRC0_CONFLICT_WITH_WB_DST1;
			inst0_src0_data_ready      = (wb_dst1_data_valid)? 1'b1 : 1'b0;
		end
		else if((src0[0] == wb_dst0)&&(wb_dst0_valid))begin
			inst0_src0_conflict_detect = `INST0_SRC0_CONFLICT_WITH_WB_DST0;
			inst0_src0_data_ready      = (wb_dst0_data_valid)? 1'b1 : 1'b0;
		end
		else begin
			inst0_src0_conflict_detect = `INST0_SRC0_CONFLICT_WITH_NOTHING;
			inst0_src0_data_ready      = 1'b1;
		end


		if((src1[0] == ex_dst1)&&(ex_dst1_valid))begin
			inst0_src1_conflict_detect = `INST0_SRC1_CONFLICT_WITH_EX_DST1;
			inst0_src1_data_ready      = (ex_dst1_data_valid)? 1'b1 : 1'b0;
		end
		else if((src1[0] == ex_dst0)&&(ex_dst0_valid))begin
			inst0_src1_conflict_detect = `INST0_SRC1_CONFLICT_WITH_EX_DST0;
			inst0_src1_data_ready      = (ex_dst0_data_valid)? 1'b1 : 1'b0;
		end
		else if((src1[0] == wb_dst1)&&(wb_dst1_valid))begin
			inst0_src1_conflict_detect = `INST0_SRC1_CONFLICT_WITH_WB_DST1;
			inst0_src1_data_ready      = (wb_dst1_data_valid)? 1'b1 : 1'b0;
		end
		else if((src1[0] == wb_dst0)&&(wb_dst0_valid))begin
			inst0_src1_conflict_detect = `INST0_SRC1_CONFLICT_WITH_WB_DST0;
			inst0_src1_data_ready      = (wb_dst0_data_valid)? 1'b1 : 1'b0;
		end
		else begin
			inst0_src1_conflict_detect = `INST0_SRC1_CONFLICT_WITH_NOTHING;
			inst0_src1_data_ready      = 1'b1;
		end	
	
		if(inst0_src0_data_ready && inst0_src1_data_ready)begin
			inst0_conflict_detect = 1'b0;
		end
		else begin
			inst0_conflict_detect = 1'b1;
		end
	end	
	else begin
		inst0_conflict_detect = 1'b1;
	end	
		
		
	if(item_busy[1])begin	
		if((inst0_data_valid[5] == 1)&&(inst1_data_valid[5] == 1)&&(item_busy[0])&&(src0[1] == dst[0] ))begin
			inst1_src0_conflict_detect = `INST1_SRC0_CONFLICT_WITH_INST0;
			inst1_src0_data_ready      = 1'b0;
		end
		else if((src0[1] == ex_dst1)&&(ex_dst1_valid))begin
			inst1_src0_conflict_detect = `INST1_SRC0_CONFLICT_WITH_EX_DST1;
			inst1_src0_data_ready      = (ex_dst1_data_valid)? 1'b1 : 1'b0;
		end
		else if((src0[1] == ex_dst0)&&(ex_dst0_valid))begin
			inst1_src0_conflict_detect = `INST1_SRC0_CONFLICT_WITH_EX_DST0;
			inst1_src0_data_ready      = (ex_dst0_data_valid)? 1'b1 : 1'b0;
		end
		else if((src0[1] == wb_dst1)&&(wb_dst1_valid))begin
			inst1_src0_conflict_detect = `INST1_SRC0_CONFLICT_WITH_WB_DST1;
			inst1_src0_data_ready      = (wb_dst1_data_valid)? 1'b1 : 1'b0;
		end
		else if((src0[1] == wb_dst0)&&(wb_dst0_valid))begin
			inst1_src0_conflict_detect = `INST1_SRC0_CONFLICT_WITH_WB_DST0;
			inst1_src0_data_ready      = (wb_dst0_data_valid)? 1'b1 : 1'b0;
		end
		else begin
			inst1_src0_conflict_detect = `INST1_SRC0_CONFLICT_WITH_NOTHING;
			inst1_src0_data_ready      = 1'b1;
		end

		if((inst0_data_valid[5] == 1)&&(inst1_data_valid[5] == 1)&&(item_busy[0])&&(src1[1] == dst[0]))begin
			inst1_src1_conflict_detect = `INST1_SRC1_CONFLICT_WITH_INST0;
			inst1_src1_data_ready      = 1'b0;
		end
		else if((src1[1] == ex_dst1)&&(ex_dst1_valid))begin
			inst1_src1_conflict_detect = `INST1_SRC1_CONFLICT_WITH_EX_DST1;
			inst1_src1_data_ready      = (ex_dst1_data_valid)? 1'b1 : 1'b0;
		end
		else if((src1[1] == ex_dst0)&&(ex_dst0_valid))begin
			inst1_src1_conflict_detect = `INST1_SRC1_CONFLICT_WITH_EX_DST0;
			inst1_src1_data_ready      = (ex_dst0_data_valid)? 1'b1 : 1'b0;
		end
		else if((src1[1] == wb_dst1)&&(wb_dst1_valid))begin
			inst1_src1_conflict_detect = `INST1_SRC1_CONFLICT_WITH_WB_DST1;
			inst1_src1_data_ready      = (wb_dst1_data_valid)? 1'b1 : 1'b0;
		end
		else if((src1[1] == wb_dst0)&&(wb_dst0_valid))begin
			inst1_src1_conflict_detect = `INST1_SRC1_CONFLICT_WITH_WB_DST0;
			inst1_src1_data_ready      = (wb_dst0_data_valid)? 1'b1 : 1'b0;
		end
		else begin
			inst1_src1_conflict_detect = `INST1_SRC1_CONFLICT_WITH_NOTHING;
			inst1_src1_data_ready      = 1'b1;
		end	
		
		if(inst0_load_store_detect & inst1_load_store_detect)begin
			inst1_conflict_detect = 1'b1;
		end		
		else if(inst1_src0_data_ready & inst1_src1_data_ready)begin
			inst1_conflict_detect = 1'b0;
		end
		else begin
			inst1_conflict_detect = 1'b1;
		end		
	end
	else begin
		inst1_conflict_detect = 1'b1;
	end
	
	inst0_issue_enable = (!inst0_conflict_detect)? 1'b1 : 1'b0;
	inst1_issue_enable = (!inst1_conflict_detect)? 1'b1 : 1'b0;


/*
	if((item_busy[0])&&(inst0_conflict_detect == 1'b0))begin
		inst0_issue_enable = 1'b1;
	end
	else if((item_busy[0])&&(inst0_conflict_detect == 1'b1))begin
		case (inst0_src0_conflict_detect)
			`INST0_SRC0_CONFLICT_WITH_EX_DST1:begin
				inst0_issue_enable = (inst0_src0_data_ready)? 1'b1 ï¼?1'b0;
			end
			`INST0_SRC0_CONFLICT_WITH_EX_DST0:begin
				inst0_issue_enable = (inst0_src0_data_ready)? 1'b1 ï¼?1'b0;
			end			
			`INST0_SRC0_CONFLICT_WITH_WB_DST1,`INST0_SRC0_CONFLICT_WITH_WB_DST0,`INST0_SRC0_CONFLICT_WITH_NOTHING:begin
				case (inst0_src1_conflict_detect)
					`INST0_SRC1_CONFLICT_WITH_EX_DST1:begin
						inst0_issue_enable = (inst0_src1_data_ready)? 1'b1 ï¼?1'b0;
					end
					`INST0_SRC1_CONFLICT_WITH_EX_DST0:begin
						inst0_issue_enable = (inst0_src1_data_ready)? 1'b1 ï¼?1'b0;
					end	
					`INST0_SRC0_CONFLICT_WITH_WB_DST1,`INST0_SRC0_CONFLICT_WITH_WB_DST0,`INST0_SRC0_CONFLICT_WITH_NOTHING:begin
						inst0_issue_enable = (inst0_src1_data_ready)? 1'b1 ï¼?1'b0;
		 			end
	
				endcase
			end
		endcase
	end
	else begin
		inst0_issue_enable = 1'b0;
	end
	
	if(inst0_issue_enable)begin
		if((item_busy[1])&&(inst1_conflict_detect == 1'b0))begin
			inst1_issue_enable  = 1'b1;
		end
		else if((item_busy[1])&&(inst1_conflict_detect == 1'b1))begin
			case (inst1_src0_conflict_detect)
				`INST1_SRC0_CONFLICT_WITH_EX_DST1:begin
					inst1_issue_enable = (inst1_src0_data_ready)? 1'b1 ï¼?1'b0;
				end
				`INST1_SRC0_CONFLICT_WITH_EX_DST0:begin
					inst1_issue_enable = (inst1_src0_data_ready)? 1'b1 ï¼?1'b0;
				end		
				`INST1_SRC0_CONFLICT_WITH_INST0:begin
					inst1_issue_enable = (inst1_src0_data_ready)? 1'b1 ï¼?1'b0;
				end	
				`INST1_SRC0_CONFLICT_WITH_WB_DST1,`INST1_SRC0_CONFLICT_WITH_WB_DST0,`INST1_SRC0_CONFLICT_WITH_NOTHING:begin
					case (inst1_src1_conflict_detect)
						`INST1_SRC1_CONFLICT_WITH_EX_DST1:begin
							inst1_issue_enable = (inst1_src1_data_ready)? 1'b1 ï¼?1'b0;
						end
						`INST1_SRC1_CONFLICT_WITH_EX_DST0:begin
							inst1_issue_enable = (inst1_src1_data_ready)? 1'b1 ï¼?1'b0;
						end		
						`INST1_SRC1_CONFLICT_WITH_INST0:begin
							inst1_issue_enable = (inst1_src1_data_ready)? 1'b1 ï¼?1'b0;
						end	
						`INST1_SRC0_CONFLICT_WITH_WB_DST1,`INST1_SRC0_CONFLICT_WITH_WB_DST0,`INST1_SRC0_CONFLICT_WITH_NOTHING:begin
							inst1_issue_enable = (inst1_src1_data_ready)? 1'b1 ï¼?1'b0;
						end
					endcase
				end
			endcase
		end
	end
	else begin
		inst1_issue_enable = 1'b0;
	end
*/	

	
	
	if(inst0_issue_enable)begin
		case (inst_type[0])
			`INSN_ALU_TYPE: begin
				if(!fu0_busy)begin
					inst0_to_fu = 3'b000;
				end	
				else if (!fu1_busy)begin
					inst0_to_fu = 3'b001;
				end
				else begin
					inst0_to_fu = 3'b111;
				end
			end
			`INSN_MULT_TYPE: begin
				if(!fu2_busy)begin
					inst0_to_fu = 3'b010;
				end	
				else begin
					inst0_to_fu = 3'b111;
				end
			end
			`INSN_DIV_TYPE: begin
				if(!fu3_busy)begin
					inst0_to_fu = 3'b011;
				end	
				else begin
					inst0_to_fu = 3'b111;
				end
			end	
			`INSN_NOP_TYPE: begin
					inst0_to_fu = 3'b100;
			end
			default: begin
					inst0_to_fu = 3'b111;
			end			
		endcase	
	end
	else begin
		inst0_to_fu = 3'b111;
	end
	
	if((inst1_issue_enable)&&(inst0_to_fu != 3'b111))begin
		case (inst_type[1])
			`INSN_ALU_TYPE: begin
				if((!fu0_busy)&&(inst0_to_fu != 3'b000))begin
					inst1_to_fu = 3'b000;
				end	
				else if ((!fu1_busy)&&(inst0_to_fu != 3'b001))begin
					inst1_to_fu = 3'b001;
				end
				else begin
					inst1_to_fu = 3'b111;
				end
			end
			`INSN_MULT_TYPE: begin
				if((!fu2_busy)&&(inst0_to_fu != 3'b010))begin
					inst1_to_fu = 3'b010;
				end	
				else begin
					inst1_to_fu = 3'b111;
				end
			end
			`INSN_DIV_TYPE: begin
				if((!fu3_busy)&&(inst0_to_fu != 3'b011))begin
					inst1_to_fu = 3'b011;
				end	
				else begin
					inst1_to_fu = 3'b111;
				end
			end	
			`INSN_NOP_TYPE: begin
					inst1_to_fu = 3'b100;
			end
			default: begin
					inst1_to_fu = 3'b111;
			end
		endcase	
	end
	else begin
		inst1_to_fu = 3'b111;
	end
	
	
	if((inst0_to_fu !=3'b111)&&(inst1_to_fu !=3'b111))begin
		issue_enable = 2'b10;
		is_to_next_stage_valid = 1'b1;
	end
	else if((inst0_to_fu !=3'b111)&&(inst1_to_fu ==3'b111))begin
		issue_enable = 2'b01;
		is_to_next_stage_valid = 1'b1;
	end
	else begin
		issue_enable = 2'b00;
		is_to_next_stage_valid = 1'b0;
	end
	
end



assign inst0_data_valiad = data_valid [0];
assign inst1_data_valiad = data_valid [1];


always @(posedge clk )begin
	if(inst0_to_fu != 3'b111)begin
		if(inst0_data_valiad[4])begin
			read_regfile_addr0		  <= src0[0];
			read_regfile_addr0_valid  <= 1'b1;
		end
		else begin
			read_regfile_addr0		  <= 5'b00000;
			read_regfile_addr0_valid  <= 1'b0;		
		end
		
		if(inst0_data_valiad[3])begin
			read_regfile_addr1		 <= src1[0];
			read_regfile_addr1_valid <= 1'b1;
		end
		else begin
			read_regfile_addr1 		 <= 5'b00000;
			read_regfile_addr1_valid <= 1'b0;		
		end				
		inst0_to_fu_pc 				 <= pc[0];
		inst0_to_fu_ptab_addr               <= ptab_addr [0];
		inst0_to_fu_dst				 <= dst [0];
		inst0_error_code                         <= exe_code [0];
		inst0_to_fu_imme			 <= imme [0];
		inst0_to_fu_meaning                   <= inst_meaning [0];
		inst0_to_fu_src0			 <= src0 [0];
		inst0_to_fu_src1                         <= src1 [0];
		inst0_data_valiad_next              <= data_valid[0];
		inst0_valid                                  <=1'b1;
	end
	else begin
		read_regfile_addr0		  <= 5'b00000;
		read_regfile_addr0_valid  <= 1'b0;	
		read_regfile_addr1 		  <= 5'b00000;
		read_regfile_addr1_valid  <= 1'b0;	
		inst0_to_fu_pc 			  <= 32'b0;
		inst0_to_fu_ptab_addr        <= 5'b00000;
		inst0_to_fu_dst		          <= 5'b00000;
		inst0_error_code                  <= 5'b00000;
		inst0_to_fu_imme	          <= 32'b0;
		inst0_to_fu_meaning            <= 6'b00000;
		inst0_to_fu_src0		  <= 5'b00000;
		inst0_to_fu_src1                  <= 5'b00000;
		inst0_data_valiad_next       <= 6'b00000;
		inst0_valid                            <=1'b0;
	end
	if(inst1_to_fu != 3'b111)begin
		if(inst1_data_valiad[4])begin
			read_regfile_addr2		  <= src0[1];
			read_regfile_addr2_valid  <= 1'b1;
		end
		else begin
			read_regfile_addr2		  <= 5'b00000;
			read_regfile_addr2_valid  <= 1'b0;		
		end
		
		if(inst1_data_valiad[3])begin
			read_regfile_addr3		 <= src1[1];
			read_regfile_addr3_valid <= 1'b1;
		end
		else begin
			read_regfile_addr3 		 <= 5'b00000;
			read_regfile_addr3_valid <= 1'b0;		
		end				
		inst1_to_fu_pc 				 <= pc[1];
		inst1_to_fu_ptab_addr               <= ptab_addr [1];
		inst1_to_fu_dst				 <= dst [1];
		inst1_error_code                         <= exe_code [1];
		inst1_to_fu_imme			 <= imme [1];
		inst1_to_fu_meaning                   <= inst_meaning [1];
		inst1_to_fu_src0			 <= src0 [1];
		inst1_to_fu_src1                         <= src1 [1];
		inst1_data_valiad_next              <= data_valid[1];
		inst1_valid                                  <=1'b1;
	end
	else begin
		read_regfile_addr2		  <= 5'b00000;
		read_regfile_addr2_valid  <= 1'b0;	
		read_regfile_addr3		  <= 5'b00000;
		read_regfile_addr3_valid  <= 1'b0;	
		inst1_to_fu_pc 			  <= 32'b0;
		inst1_to_fu_ptab_addr        <= 5'b00000;
		inst1_to_fu_dst		          <= 5'b00000;
		inst1_error_code                  <= 5'b00000;
		inst1_to_fu_imme	          <= 32'b0;
		inst1_to_fu_meaning            <= 6'b00000;
		inst1_to_fu_src0		  <= 5'b00000;
		inst1_to_fu_src1                  <= 5'b00000;
		inst1_data_valiad_next       <= 6'b00000;
		inst1_valid                            <=1'b0;
	end	
end


always @ (*)begin
	case (inst0_src0_conflict_detect)
		`INST0_SRC0_CONFLICT_WITH_EX_DST1: regfile_data0 = (ex_dst1_data_valid)? ex_dst1_data : 32'b0;
		`INST0_SRC0_CONFLICT_WITH_EX_DST0: regfile_data0 = (ex_dst0_data_valid)? ex_dst0_data : 32'b0;
		`INST0_SRC0_CONFLICT_WITH_WB_DST1: regfile_data0 = (wb_dst1_data_valid)? ex_dst1_data : 32'b0;
		`INST0_SRC0_CONFLICT_WITH_WB_DST0: regfile_data0 = (wb_dst0_data_valid)? ex_dst0_data : 32'b0;
		`INST0_SRC0_CONFLICT_WITH_NOTHING: regfile_data0 = read_regfile_data0;
		default:                           regfile_data0 = read_regfile_data0;
	endcase

	case (inst0_src1_conflict_detect)
		`INST0_SRC1_CONFLICT_WITH_EX_DST1: regfile_data1 = (ex_dst1_data_valid)? ex_dst1_data : 32'b0;
		`INST0_SRC1_CONFLICT_WITH_EX_DST0: regfile_data1 = (ex_dst0_data_valid)? ex_dst0_data : 32'b0;
		`INST0_SRC1_CONFLICT_WITH_WB_DST1: regfile_data1 = (wb_dst1_data_valid)? ex_dst1_data : 32'b0;
		`INST0_SRC1_CONFLICT_WITH_WB_DST0: regfile_data1 = (wb_dst0_data_valid)? ex_dst0_data : 32'b0;
		`INST0_SRC1_CONFLICT_WITH_NOTHING: regfile_data1 = read_regfile_data1;
		default:                           regfile_data1 = read_regfile_data1;
	endcase	
	
	case (inst1_src0_conflict_detect)
		`INST1_SRC0_CONFLICT_WITH_INST0  : regfile_data2 = 32'b0;
		`INST1_SRC0_CONFLICT_WITH_EX_DST1: regfile_data2 = (ex_dst1_data_valid)? ex_dst1_data : 32'b0;
		`INST1_SRC0_CONFLICT_WITH_EX_DST0: regfile_data2 = (ex_dst0_data_valid)? ex_dst0_data : 32'b0;
		`INST1_SRC0_CONFLICT_WITH_WB_DST1: regfile_data2 = (wb_dst1_data_valid)? ex_dst1_data : 32'b0;
		`INST1_SRC0_CONFLICT_WITH_WB_DST0: regfile_data2 = (wb_dst0_data_valid)? ex_dst0_data : 32'b0;
		`INST1_SRC0_CONFLICT_WITH_NOTHING: regfile_data2 = read_regfile_data2;
		default:                           regfile_data2 = read_regfile_data2;		
	endcase
	
	case (inst1_src1_conflict_detect)
		`INST1_SRC1_CONFLICT_WITH_INST0  : regfile_data3 = 32'b0;
		`INST1_SRC1_CONFLICT_WITH_EX_DST1: regfile_data3 = (ex_dst1_data_valid)? ex_dst1_data : 32'b0;
		`INST1_SRC1_CONFLICT_WITH_EX_DST0: regfile_data3 = (ex_dst0_data_valid)? ex_dst0_data : 32'b0;
		`INST1_SRC1_CONFLICT_WITH_WB_DST1: regfile_data3 = (wb_dst1_data_valid)? ex_dst1_data : 32'b0;
		`INST1_SRC1_CONFLICT_WITH_WB_DST0: regfile_data3 = (wb_dst0_data_valid)? ex_dst0_data : 32'b0;
		`INST1_SRC1_CONFLICT_WITH_NOTHING: regfile_data3 = read_regfile_data3;
		default:                           regfile_data3 = read_regfile_data3;		
	endcase
		
	case (inst0_data_valiad_next[3:2])
		2'b00:     inst0_to_fu_data1 = 32'b0;
		2'b01:     inst0_to_fu_data1 = imme[0];
		2'b10:     inst0_to_fu_data1 = regfile_data1;
		default: inst0_to_fu_data1 = 32'b0;
	endcase

	case (inst1_data_valiad_next[3:2])
		2'b00:     inst1_to_fu_data1 = 32'b0;
		2'b01:     inst1_to_fu_data1 = imme[1];
		2'b10:     inst1_to_fu_data1 = regfile_data3;
		default: inst1_to_fu_data1 = 32'b0;
	endcase	
	
	if(inst0_data_valiad_next[4])begin	
		inst0_to_fu_data0 = regfile_data0;
	end
	else begin
		inst0_to_fu_data0 = 32'b0;
	end
	
	if(inst1_data_valiad_next[4])begin	
		inst1_to_fu_data0 = regfile_data2;
	end
	else begin
		inst1_to_fu_data0 = 32'b0;
	end	
end



always @ (*)begin
	if(!item_busy[0])begin
		current_item = 6'd00;
	end
	else  if(!item_busy[1])begin
		current_item = 6'd01;
	end
	else  if(!item_busy[2])begin
		current_item = 6'd02;
	end
	else  if(!item_busy[3])begin
		current_item = 6'd03;
	end
	else  if(!item_busy[4])begin
		current_item = 6'd04;
	end
	else  if(!item_busy[5])begin
		current_item = 6'd05;
	end
	else  if(!item_busy[6])begin
		current_item = 6'd06;
	end
	else  if(!item_busy[7])begin
		current_item = 6'd07;
	end
	else  if(!item_busy[8])begin
		current_item = 6'd08;
	end
	else  if(!item_busy[9])begin
		current_item = 6'd09;
	end
	else  if(!item_busy[10])begin
		current_item = 6'd10;
	end
	else  if(!item_busy[11])begin
		current_item = 6'd11;
	end
	else  if(!item_busy[12])begin
		current_item = 6'd12;
	end
	else  if(!item_busy[13])begin
		current_item = 6'd13;
	end
	else  if(!item_busy[14])begin
		current_item = 6'd14;
	end
	else  if(!item_busy[15])begin
		current_item = 6'd15;
	end
	else  if(!item_busy[16])begin
		current_item = 6'd16;
	end
	else  if(!item_busy[17])begin
		current_item = 6'd17;
	end
	else  if(!item_busy[18])begin
		current_item = 6'd18;
	end
	else  if(!item_busy[19])begin
		current_item = 6'd19;
	end
	else  if(!item_busy[20])begin
		current_item = 6'd20;
	end
	else  if(!item_busy[21])begin
		current_item = 6'd21;
	end
	else  if(!item_busy[22])begin
		current_item = 6'd22;
	end
	else  if(!item_busy[23])begin
		current_item = 6'd23;
	end
	else  if(!item_busy[24])begin
		current_item = 6'd24;
	end
	else  if(!item_busy[25])begin
		current_item = 6'd25;
	end
	else  if(!item_busy[26])begin
		current_item = 6'd26;
	end
	else  if(!item_busy[27])begin
		current_item = 6'd27;
	end
	else  if(!item_busy[28])begin
		current_item = 6'd28;
	end
	else  if(!item_busy[29])begin
		current_item = 6'd29;
	end
	else  if(!item_busy[30])begin
		current_item = 6'd30;
	end
	else  if(!item_busy[31])begin
		current_item = 6'd31;
	end
	else  begin
		current_item = 6'd32;
	end
	
	
	if(current_item == 6'd32)begin
		issue_queue_is_free = 2'b00;
		
		if(issue_enable == 2'b10) begin
			issue_queque_is_full = 1'b0;
		end
		else begin
			issue_queque_is_full = 1'b1;
		end
	end
	else if (current_item == 6'd31)begin
		issue_queue_is_free = 2'b01;
		
		if(issue_enable == 2'b00) begin
			issue_queque_is_full = 1'b1;
		end
		else begin
			issue_queque_is_full = 1'b0;
		end
	end
	else begin
		issue_queue_is_free  = 2'b10;
		issue_queque_is_full = 1'b0;
	end
end
	assign is_allow_in = ~issue_queque_is_full;
endmodule
