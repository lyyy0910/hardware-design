`timescale 1ns / 1ps
`include "defines2.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/02 14:29:33
// Design Name: 
// Module Name: signext
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


module signext(
	input wire[15:0] a,
	input wire[5:0] op,
	output wire[31:0] y
    );

	assign y = (op==`XORI||op==`ORI||op==`ANDI)?{16'b0,a}:{{16{a[15]}},a};
	//assign y = op==`XORI?{16'b0,a}:{{16{a[15]}},a};
endmodule
