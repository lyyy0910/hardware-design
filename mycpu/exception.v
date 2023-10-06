`timescale 1ns / 1ps
`include "defines2.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/30 11:54:32
// Design Name: 
// Module Name: exception
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

module exception(
   input rst,
   input [5:0] ext_int,
   input ri, breakM, syscall, overflow, addrErrorSw, addrErrorLw, pcError, eretM,
   input [31:0] cp0_status, cp0_cause, cp0_epc,
   input [31:0] pcM,
   input [31:0] alu_outM,

   output reg [31:0] except_type,
   output flush_exception,
   output [31:0] pc_exception,
   output pc_trap,
   output [31:0] badvaddrM
);

   //INTERUPT
   wire int_en;        
   assign int_en =   cp0_status[0] && ~cp0_status[1] && (( |(cp0_status[9:8] & cp0_cause[9:8]) )||( |(cp0_status[15:10] & ext_int) ));
   // ȫ���жϿ���,��û�������ڴ���,ʶ�������жϻ���Ӳ���ж�;

     always @(*) begin
            if(rst) begin
                except_type <= 32'b0;
            end
            else begin
                except_type <= 32'b0;
                if (int_en) begin
    
                    except_type <= 32'h0000_0001;
                    end
                else if(addrErrorLw | pcError) begin
                    except_type <= 32'h0000_0004;//ȡָ��ȡ���ݵ�ַ������,adel,
                end
                else if(addrErrorSw) begin
                    except_type <= 32'h0000_0005;//д���ݵ�ַ�����⣬ades
                end
                else if(syscall) begin
                    except_type <= 32'h0000_0008;//ϵͳ��������
                end
                else if (breakM) begin
                    except_type <= 32'h0000_0009;//�ϵ�����,break
                end
                else if (eretM) begin
                    except_type <= 32'h0000_000e;//ereturn
                end
                else if (ri) begin//RI(Invalid)
                    except_type <= 32'h0000_000a;//����ָ������
                end
                else if (overflow) begin//overflow
                    except_type <= 32'h0000_000c;//�����������
                end    
                else begin except_type <= 32'h0000_0000; end
            end
        end
   //interupt pc address
   assign pc_exception =      (except_type == 32'h0000_0000) ? `ZeroWord:
                           (except_type == 32'h0000_000e)? cp0_epc :
                           32'hbfc0_0380;
   assign pc_trap =        (except_type == 32'h0000_0000) ? 1'b0:
                           1'b1;
   assign flush_exception =   (except_type == 32'h0000_0000) ? 1'b0:
                           1'b1;
   assign badvaddrM =      (pcError==1) ? pcM : alu_outM;  
endmodule
