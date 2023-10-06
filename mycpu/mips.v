`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/07 10:58:03
// Design Name: 
// Module Name: mips
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mips(
	input wire clk,rst,
	input [5:0] ext_int,
	output wire[31:0] pcF,
	input wire[31:0] instrF,
	output wire [3:0] memwrite_byteM,
	output wire[63:0] aluoutM,output wire [31:0]writedataM,
	input wire[31:0] readdataM ,
	output inst_en,
	output data_en,
	
	input i_stall,
	input d_stall,
	output longest_stall,
	
	output [31:0] debug_wb_pc     ,
    output [3:0] debug_wb_rf_wen  ,
    output [4:0] debug_wb_rf_wnum ,
    output [31:0] debug_wb_rf_wdata
    );
	
	wire [5:0] opD,functD;
	wire[31:0] instrD;
	wire regdstE,alusrcE,pcsrcD,memtoregE,memtoregM,memtoregW,
			regwriteE,regwriteM,regwriteW;
	wire [4:0] alucontrolE;
	wire flushE,equalD,stall_div;
	//yxy new
	wire [3:0]compzeroD;
	wire [4:0]brartD;
	wire branchwriteE;
	wire j_regD;
	wire j_31D;
	wire j_pls8;
	wire wehiD;
	wire weloD;
	wire rehiD;
	wire reloD;
	wire riD;
	wire flush_exceptionM;
	wire flush_exceptionW;
	controller c(
		clk,rst,
		//decode stage
		flush_exceptionM,
		flush_exceptionW,
		opD,functD,
		instrD,
		pcsrcD,branchD,equalD,jumpD,
		
		//execute stage
		flushE,stall_div,
		memtoregE,alusrcE,
		regdstE,regwriteE,	
		alucontrolE,

		//mem stage
		memtoregM,memwriteM,
		regwriteM,
		//write back stage
		memtoregW,regwriteW,
		
		compzeroD,
		brartD,
		branchwriteE,
		j_regD,
		j_31D,
		j_pls8,
		wehiD,
		weloD,
		rehiD,
		reloD,
		riD,
		i_stall,
		d_stall,
		longest_stall
		);
	datapath dp(
		clk,rst,
		//fetch stage
		ext_int,
		pcF,
		instrF,
		//decode stage
		pcsrcD,branchD,
		jumpD,
		equalD,
		opD,functD,
		instrD,
		//execute stage
		memtoregE,
		alusrcE,regdstE,
		regwriteE,
		alucontrolE,
		flushE,
		stall_div,
		//mem stage
		memtoregM,
		memwriteM,
		regwriteM,
		aluoutM,writedataM,
		readdataM,memwrite_byteM,
		//writeback stage
		memtoregW,
		regwriteW,
		
		compzeroD,
		brartD,
		branchwriteE,
		j_regD,
		j_31D,
		j_pls8,
		wehiD,
		weloD,
		rehiD,
		reloD,
		riD,
		inst_en,
		data_en,
		flush_exceptionM,
		flush_exceptionW,
		
		i_stall,d_stall,longest_stall,
		
		 debug_wb_pc,  
        debug_wb_rf_wen,  
        debug_wb_rf_wnum,  
        debug_wb_rf_wdata  
	    );
	
endmodule
