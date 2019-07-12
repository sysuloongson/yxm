`define REGISTER_NUMBER 32
//`define HILO_NUMBER 2

module register_file(
	input clk,
	input rst_,
	input [4:0] read_addr0,
	input [4:0] read_addr1,
	input [4:0] read_addr2,
	input [4:0] read_addr3,
	input read_addr0_valid,
	input read_addr1_valid,
	input read_addr2_valid,
	input read_addr3_valid,
	input read_hilo_hi_enable,
	input read_hilo_lo_enable,
	
	input [4:0] write_addr0,
	input [4:0] write_addr1,
	input write_addr0_valid,
	input write_addr1_valid,
	input [31:0] write_data0,
	input [31:0] write_data1,
	input [31:0] write_hilo_hi_data,
	input [31:0] write_hilo_lo_data,
	input write_hilo_hi_data_valid,
	input write_hilo_lo_data_valid,
	
	output wire [31:0] read_data0,
	output wire [31:0] read_data1,
	output wire [31:0] read_data2,
	output wire [31:0] read_data3,
	output wire read_data0_valid,
	output wire read_data1_valid,
	output wire read_data2_valid,
	output wire read_data3_valid,
	
	output wire [31:0] hilo_hi_data,
	output wire [31:0] hilo_lo_data,
	output wire hilo_hi_data_valid,
	output wire hilo_lo_data_valid
);

	integer i;
	integer j;
	
	reg [31:0] register [0:`REGISTER_NUMBER-1]; 
	reg [31:0] register_hilo_hi;
	reg [31:0] register_hilo_lo;
	
	initial begin
		register[1] <= 32'h0001;
		register[2] <= 32'h0002;
		register[3] <= 32'h0003;
		register[4] <= 32'h0004;
		register[5] <= 32'h0005;
		register[6] <= 32'h0006;
		register[7] <= 32'h0007;
		register[8] <= 32'h0008;
		register[9] <= 32'h0009;
		register[10] <= 32'h000a;
		register[11] <= 32'h000b;
		register[12] <= 32'h000c;
		register[13] <= 32'h000d;
		register[14] <= 32'h000e;
		register[15] <= 32'h000f;
		register[16] <= 32'h0010;
		register[17] <= 32'h0011;
		register[18] <= 32'h0012;
		register[19] <= 32'h0013;
		register[20] <= 32'h0014;
		register[21] <= 32'h0015;
		register[22] <= 32'h0016;
		register[23] <= 32'h0017;
		register[24] <= 32'h0018;
		register[25] <= 32'h0019;
		register[26] <= 32'h001a;
		register[27] <= 32'h001b;
		register[28] <= 32'h001c;
		register[29] <= 32'h001d;
		register[30] <= 32'h001e;
		register[31] <= 32'h001f;	
	end
	
	
	
	
	assign read_data0 = (read_addr0_valid)? register[read_addr0] : 32'b0;
	assign read_data1 = (read_addr1_valid)? register[read_addr1] : 32'b0;
	assign read_data2 = (read_addr2_valid)? register[read_addr2] : 32'b0;
	assign read_data3 = (read_addr3_valid)? register[read_addr3] : 32'b0;
	assign hilo_hi_data = (read_hilo_hi_enable)? register_hilo_hi : 32'b0;
	assign hilo_lo_data = (read_hilo_lo_enable)? register_hilo_lo : 32'b0;
	assign read_data0_valid = (read_addr0_valid)? 1'b1 : 1'b0;
	assign read_data1_valid = (read_addr1_valid)? 1'b1 : 1'b0;
	assign read_data2_valid = (read_addr2_valid)? 1'b1 : 1'b0;
	assign read_data3_valid = (read_addr3_valid)? 1'b1 : 1'b0;	
	assign hilo_hi_data_valid = (read_hilo_hi_enable)? 1'b1 : 1'b0;
	assign hilo_lo_data_valid = (read_hilo_lo_enable)? 1'b1 : 1'b0;
			
	always@(posedge clk)begin
		if(!rst_)begin
/*
			for(i=0;i<`REGISTER_NUMBER;i=i+1)begin
				register[i] <= 32'b0;
			end
*/
			register_hilo_hi <= 32'b0;
			register_hilo_lo <= 32'b0;
			register[1] <= 32'h0001;
			register[2] <= 32'h0002;
			register[3] <= 32'h0003;
			register[4] <= 32'h0004;
			register[5] <= 32'h0005;
			register[6] <= 32'h0006;
			register[7] <= 32'h0007;
			register[8] <= 32'h0008;
			register[9] <= 32'h0009;
			register[10] <= 32'h000a;
			register[11] <= 32'h000b;
			register[12] <= 32'h000c;
			register[13] <= 32'h000d;
			register[14] <= 32'h000e;
			register[15] <= 32'h000f;
			register[16] <= 32'h0010;
			register[17] <= 32'h0011;
			register[18] <= 32'h0012;
			register[19] <= 32'h0013;
			register[20] <= 32'h0014;
			register[21] <= 32'h0015;
			register[22] <= 32'h0016;
			register[23] <= 32'h0017;
			register[24] <= 32'h0018;
			register[25] <= 32'h0019;
			register[26] <= 32'h001a;
			register[27] <= 32'h001b;
			register[28] <= 32'h001c;
			register[29] <= 32'h001d;
			register[30] <= 32'h001e;
			register[31] <= 32'h001f;
		end
		else begin
			if(write_addr0_valid)begin
				register[write_addr0] <= write_data0;
			end
			
			if(write_addr1_valid)begin
				register[write_addr1] <= write_data1;
			end
			
			if(write_hilo_hi_data_valid)begin
				register_hilo_hi <= write_hilo_hi_data;
			end
			
			if(write_hilo_lo_data_valid)begin
				register_hilo_lo <= write_hilo_lo_data;
			end			
		end
	end
endmodule