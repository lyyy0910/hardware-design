`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/22 15:49:58
// Design Name: 
// Module Name: greater_equal_zero
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


module comp_to_zero(input wire [31:0] srca,output wire [3:0]res);
wire r1,r2,r3,r4;
assign r1=(srca[31]==0);
assign r2=(srca[31]==0)&(srca!=0);
assign r3=(srca[31]==1|srca==0);
assign r4=(srca[31]==1);
assign res={r1,r2,r3,r4};

endmodule
