`timescale 1ns / 1ps
`include "defines2.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/12 11:26:03
// Design Name: 
// Module Name: hilo_reg
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


module hilo_reg(
    input wire clk,rst,wehi,welo,
	input wire[31:0] hi,lo,
	output reg[31:0] hi_o,lo_o
    );
    always @(posedge clk) begin
		if(rst) begin
			hi_o <= 0;
			lo_o <= 0;
		end else if (wehi||welo) begin
			if(wehi)begin
				hi_o<=hi;
			end
			if(welo)begin
				lo_o<=lo;
			end
		end 
	end
endmodule
