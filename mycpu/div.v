`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/24 12:00:17
// Design Name: 
// Module Name: div
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
//开始使用的是组合逻辑，但是由于组合逻辑耗时太长，现在改成了时序逻辑，暂停32个周期，但是主要逻辑都是移位除法
//刘阳
module div(
    input wire clk, rst,
    input flush,
    input flush_exceptionM,
    input wire[31:0] a,b,
    input valid,
    output reg div_res_valid,
    input div_res_ready,
    input sign,
    output reg div_va,
    output stall_div,
    output[63:0] result,
    output reg we
    );
    reg[31:0] temp_a;
    reg[31:0] temp_b;
    reg[63:0] temp_1;
    reg[63:0] temp_2;
    wire[31:0] qu;
    wire[31:0] re;
    reg[31:0] q;
    reg[31:0] m;
    reg[31:0] i;
    reg start;
    reg a_save;
    reg b_save;
    assign qu=temp_1[31:0];
    assign re=temp_1[63:32];
    //assign m = (sign & a[31]) ? ~re +1 : re;
    //assign q = sign & (a[31] ^ b[31]) ? ~qu + 1 : qu;
    always@(posedge clk)begin
        we<=0;
        div_va<=0;
        if(rst|flush) begin//这里一定要刷新，syscall指令后跟着div，本来应该是直接跳转，如果不刷新就会进入到div的暂停中再跳转
            i <= 0;
            start<=0;
        end
        else if(!start & valid & ~div_res_valid) begin//可能和axi的握手机制有关，需要小小的修改一下
            we<=0;
            i <= 1;
            start <= 1;
            a_save=a[31];
            b_save=b[31];
            temp_a=(sign&a_save)?~a+1:a;//取补码
            temp_b=(sign&b_save)?~b+1:b;//取补码
            div_va<=valid;

            //Register init
            temp_1={31'b0,temp_a,1'b0};
            temp_2={temp_b,32'b0};
        end
        else if(start) begin
            if(i==32) begin
                i <= 0;
                start <= 0;
                we <= 1;
                //Output result
                if(temp_1[63:32]>=temp_b) temp_1=temp_1-temp_2+1;
                m = (sign & a_save) ? ~re +1 : re;
                q = sign & (a_save ^ b_save) ? ~qu + 1 : qu;
            end
            else begin
                i <= i + 1;
                temp_1=temp_1<<1;
                if(temp_1[63:32]>=temp_b) temp_1=temp_1-temp_2+1;
            end
        end
//        if(valid==1)begin
//            temp_a=(sign&a[31])?~a+1:a;//取补码
//            temp_b=(sign&b[31])?~b+1:b;//取补码
//            temp_1={32'b0,temp_a};
//            temp_2={temp_b,32'b0};
//            for(i=0;i<32;i=i+1)begin
//                temp_1=temp_1<<1;
//                if(temp_1[63:32]>=temp_b) temp_1=temp_1-temp_2+1;
//            end
////            if(b==0)begin
////                qu=32'b0;re=32'b0;
////            end
////            else begin
//                qu=temp_1[31:0];
//                re=temp_1[63:32];
// //           end
//        end
        //else begin i = 0; end
    end
    wire data_go;
    assign data_go = div_res_valid & div_res_ready;
    always @(posedge clk) begin
        div_res_valid <= rst     ? 1'b0 :
                     i[5]==1'b1  ? 1'b1 :
                     data_go ? 1'b0 : div_res_valid;
    end
    assign result={m,q};
    assign stall_div=(|i)&~flush_exceptionM;
endmodule

