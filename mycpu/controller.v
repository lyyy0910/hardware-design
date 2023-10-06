`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/23 15:21:30
// Design Name: 
// Module Name: controller
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


module controller(
	input wire clk,rst,
	//decode stage
	input wire flush_exceptionM,
	input wire flush_exceptionW,
	input wire[5:0] opD,functD,
	input wire[31:0] instrD,
	output wire pcsrcD,branchD,equalD,jumpD,
	
	//execute stage
	input wire flushE,stall_div,
	output wire memtoregE,alusrcE,
	output wire regdstE,regwriteE,	
	output wire[4:0] alucontrolE,

	//mem stage
	output wire memtoregM,memwriteM,
				regwriteM,
	//write back stage
	output wire memtoregW,regwriteW,
	//new
	input wire [3:0]compzeroD,
	input wire [4:0]brartD,
	output wire branchwriteE,
	output wire j_regD,
	output wire j_31D,
	output wire j_pls8,
	output wire wehi,
	output wire welo,
	output wire rehi,
	output wire relo,
	output riD,
	input wire i_stall,
	input wire d_stall,
	input wire longest_stall
    );
	
	//decode stage
	wire[1:0] aluopD;
	wire memtoregD,memwriteD,alusrcD,
		regdstD,regwriteD;
	wire[4:0] alucontrolD;
	//execute stage
	wire memwriteE;
	//yxy branch plus sign
	wire [3:0]branchid;
	wire pcs1,pcs2,pcs3,pcs4,pcs5,pcs6,pcs7,pcs8;
	wire branchwriteD;
	//yxy j plus sign
	wire [2:0]jid;
	//yxy movedata
	wire [3:0]hilosign;
	assign j_regD=(jid==3'b010)|(jid==3'b100);
	assign j_31D=(jid==3'b011);
	assign j_pls8=(jid==3'b011)|(jid==3'b100);
	assign wehi=(hilosign==4'b0010)|(hilosign==4'b1111);
	assign welo=(hilosign==4'b0001)|(hilosign==4'b1111);
	assign rehi=(hilosign==4'b1000);
	assign relo=(hilosign==4'b0100);
	maindec md(
		opD,instrD,
		memtoregD,memwriteD,
		branchD,alusrcD,
		regdstD,regwriteD,
		jumpD,
		aluopD,
		
		branchid,
		brartD,
		jid,
		functD,
		hilosign,
		riD
		);
	//aludec ad(functD,opD,brartD,alucontrolD);
	//yxy branch plus assign
	assign pcs1=branchD&equalD&(branchid==4'b001);
	assign pcs2=branchD&~equalD&(branchid==4'b010);
	assign pcs3=branchD&compzeroD[3]&(branchid==4'b0011);
	assign pcs4=branchD&compzeroD[2]&(branchid==4'b0100);
	assign pcs5=branchD&compzeroD[1]&(branchid==4'b0101);
	assign pcs6=branchD&compzeroD[0]&(branchid==4'b0110);
	assign pcs7=branchD&compzeroD[3]&(branchid==4'b0111);
	assign pcs8=branchD&compzeroD[0]&(branchid==4'b1000);
	assign pcsrcD = pcs1|pcs2|pcs3|pcs4|pcs5|pcs6|pcs7|pcs8;
	assign branchwriteD=(branchid==4'b0111)|(branchid==4'b1000);
	//pipeline registers
	flopenrc #(11) regE(
		clk,
		rst,
		//~i_stall&~d_stall,
		~longest_stall,
		flushE&~longest_stall|flush_exceptionM,
		{branchwriteD,memtoregD,memwriteD,alusrcD,regdstD,regwriteD,alucontrolD},
		{branchwriteE,memtoregE,memwriteE,alusrcE,regdstE,regwriteE,alucontrolE}
		);
	flopenrc #(8) regM(
		clk,rst,
		//~i_stall&~d_stall,
		~longest_stall,
		flush_exceptionM,
		{memtoregE,memwriteE,regwriteE},
		{memtoregM,memwriteM,regwriteM}
		);
	flopenrc #(8) regW(
		clk,rst,
		//~i_stall&~d_stall,
		~longest_stall,
//		1'b0,
		flush_exceptionM,
		{memtoregM,regwriteM},
		{memtoregW,regwriteW}
		);
endmodule
