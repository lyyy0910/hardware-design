`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/26 21:25:26
// Design Name: 
// Module Name: pc
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


module pc #(parameter WIDTH = 8)(
	input wire clk,rst,en,
	input wire[WIDTH-1:0] d,
	output reg[WIDTH-1:0] q,
	output reg ce
    );
	always @(posedge clk) begin
		if(rst) begin
		    ce<=0;
		end
	    else begin ce<=1;end
	end
	always @(posedge clk) begin
	   if(~ce) begin
			q <= 32'hbfc00000;
		end
        else if(en) begin
                q <= d;
        end
    end
endmodule