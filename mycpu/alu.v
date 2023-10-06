`timescale 1ns / 1ps
`include "defines2.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/02 14:52:16
// Design Name: 
// Module Name: alu
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
//����ʵ�ֵ��ǲ����ϳ˳������߼��������������
//������������λ����32λ
//����

module alu(
    input wire clk,rst,
    input stallD,
    input flushE,
    input flush_exceptionM,
    input longest_stall,
	input wire[31:0] a,b,
	input [5:0] op,
	input [5:0] funct,
	input [4:0]brart,
	input [4:0] sa,
	output [63:0] alu_out,
	output overflow,
	output wire zero,
	output we,
	output stall_div,
	output mult_stall
    );
    wire[63:0] temp_alu_out;
    reg[63:0] temp_alu_out_mul;
    wire[63:0] temp_alu_out_div;
    wire we_div;
    wire we_mul;
    reg[31:0] alu_out_without_mul_div;
    reg catch_bit=0;//�жϼӼ��������Ƿ������
    reg[4:0] alucontrol;
    always @(*) begin
	   case(op)
	       `R_TYPE:
                case (funct)
                  //R??????????
                  `ADD: alucontrol<=`ADD_CONTROL;
                  `ADDU: alucontrol<=`ADDU_CONTROL;
                  `SUB: alucontrol<=`SUB_CONTROL;
                  `SUBU: alucontrol<=`SUBU_CONTROL;
                  `SLT: alucontrol<=`SLT_CONTROL;
                  `SLTU: alucontrol<=`SLTU_CONTROL;
                  `MULT: alucontrol<=`MULT_CONTROL;
                  `MULTU: alucontrol<=`MULTU_CONTROL;
                  `DIV: alucontrol<=`DIV_CONTROL;
                  `DIVU: alucontrol<=`DIVU_CONTROL;
                  //R?????????
                  `AND: alucontrol<=`AND_CONTROL;
                  `OR: alucontrol<=`OR_CONTROL;
                  `XOR: alucontrol<=`XOR_CONTROL;
                  `NOR: alucontrol<=`NOR_CONTROL;
                  //??��???
                  `SLL:alucontrol<=`SLL_CONTROL;
                  `SLLV:alucontrol<=`SLLV_CONTROL;
                  `SRL:alucontrol<=`SRL_CONTROL;
                  `SRLV:alucontrol<=`SRLV_CONTROL;
                  `SRA:alucontrol<=`SRA_CONTROL;
                  `SRAV:alucontrol<=`SRAV_CONTROL;
                  //??????
                  `JR:alucontrol<=`ADD_CONTROL;
                  `JALR:alucontrol<=`ADD_CONTROL;
                  `MFHI:alucontrol<=`MFHI_CONTROL;
                  `MFLO:alucontrol<=`MFLO_CONTROL;
                  `MTHI:alucontrol<=`MTHI_CONTROL;
                  `MTLO:alucontrol<=`MTLO_CONTROL;
                  default:alucontrol<=5'b00000;
              endcase
            //LINK???
           `REGIMM_INST:
                    case(brart)
                    `BGEZ:alucontrol<=`SUB_CONTROL;
                    `BLTZ:alucontrol<=`SUB_CONTROL;
                    `BGEZAL:alucontrol<=`ADD_CONTROL;
                    `BLTZAL:alucontrol<=`ADD_CONTROL;
                    default:alucontrol<=5'b00000;
           endcase
		  //I??????????
		  `ADDI: alucontrol<=`ADD_CONTROL;
		  `ADDIU: alucontrol<=`ADDU_CONTROL;
		  `SLTI: alucontrol<=`SLT_CONTROL;
		  `SLTIU: alucontrol<=`SLTU_CONTROL;
		  //I?????????
		  `ANDI: alucontrol<=`AND_CONTROL;
		  `ORI: alucontrol<=`OR_CONTROL;
		  `XORI: alucontrol<=`XOR_CONTROL;
		  `LUI: alucontrol<=`LUI_CONTROL;
		  //branch??????
		  `BNE:alucontrol<=`SUB_CONTROL;
		  `BGTZ:alucontrol<=`SUB_CONTROL;
		  `BLEZ:alucontrol<=`SUB_CONTROL;
		  `JAL:alucontrol<=`ADD_CONTROL;
          // ??????
        `LW: alucontrol<=`ADD_CONTROL;
        `LH: alucontrol<=`ADD_CONTROL;
        `LHU:alucontrol<=`ADD_CONTROL;
        `LB: alucontrol<=`ADD_CONTROL;
        `LBU:alucontrol<=`ADD_CONTROL;
        `SW: alucontrol<=`ADD_CONTROL;
        `SH: alucontrol<=`ADD_CONTROL;
        `SB: alucontrol<=`ADD_CONTROL;
	  default:
	      alucontrol<=5'b00000;
		endcase
		catch_bit=0;
		case(alucontrol)
                 //�߼�����
                    `AND_CONTROL: alu_out_without_mul_div =a & b;
                    `OR_CONTROL:  alu_out_without_mul_div =a | b;
                    `NOR_CONTROL: alu_out_without_mul_div =~(a | b);
                    `XOR_CONTROL: alu_out_without_mul_div =a ^ b;
                    `LUI_CONTROL: alu_out_without_mul_div = {b[15:0], 16'b0};
                //��������
                    `MFLO_CONTROL,`MFHI_CONTROL,`ADD_CONTROL,
                    `MTHI_CONTROL,`MTLO_CONTROL: 
                    {catch_bit, alu_out_without_mul_div} = {a[31], a} + {b[31], b};
                    `ADDU_CONTROL: alu_out_without_mul_div = a + b;
                    `SUB_CONTROL: {catch_bit, alu_out_without_mul_div} = {a[31], a} - {b[31], b};
                    `SUBU_CONTROL: alu_out_without_mul_div = a - b; 
                    `SLT_CONTROL: alu_out_without_mul_div = $signed(a) < $signed(b);
                    `SLTU_CONTROL: alu_out_without_mul_div = a < b;
                    //��λָ��
                     `SLL_CONTROL:alu_out_without_mul_div = b << sa;
                    `SRL_CONTROL:alu_out_without_mul_div = b >> sa;
                    `SRA_CONTROL:alu_out_without_mul_div = $signed(b) >>> sa;
        
                    `SLLV_CONTROL:alu_out_without_mul_div = b << a[4:0];
                    `SRLV_CONTROL:alu_out_without_mul_div = b >> a[4:0];
                    `SRAV_CONTROL:alu_out_without_mul_div = $signed(b) >>> a[4:0];
                    `MULT_CONTROL:temp_alu_out_mul = $signed(a)*$signed(b);
                    `MULTU_CONTROL:temp_alu_out_mul = {32'b0,a}*{32'b0,b};
                endcase
	end
	//��������������洦��
	wire div_sign;//�ж����з��ų��������޷��ų���
	wire div_v;//�ж��Ƿ�Ϊ����
	assign div_v=(alucontrol==`DIV_CONTROL||alucontrol==`DIVU_CONTROL);
	assign div_sign = alucontrol==`DIV_CONTROL;
	wire mul_sign;
	wire mul_v;
    assign mul_v=(alucontrol==`MULT_CONTROL||alucontrol==`MULTU_CONTROL);
    assign we_mul=mul_v;
	assign mul_sign = (alucontrol==`MULT_CONTROL);
	wire div_res_valid;
	wire div_res_ready;

    assign div_res_ready = div_v & ~longest_stall;
	div div(
	   .clk(clk),
	   .rst(rst),
	   .flush(flushE),
	   .flush_exceptionM(flush_exceptionM),
	    .a(a),  //������
		.b(b),  //����
		.valid(div_v),
		.div_res_valid(div_res_valid),
		.div_res_ready(div_res_ready),
		.sign(div_sign),
		.div_va(div_va),
		.stall_div(stall_div),
		.result(temp_alu_out_div),
		.we(we_div));
    reg [3:0] cnt;
    assign temp_alu_out=({64{div_v}} & temp_alu_out_div)
                    | ({64{mul_v}} & temp_alu_out_mul);
		
	assign alu_out = (div_v||mul_v) ? temp_alu_out:{32'b0,alu_out_without_mul_div};
	
	assign zero = (alu_out == 64'b0);
	
	assign we=we_mul|we_div;
	wire debug;
	assign debug=(alucontrol==`ADD_CONTROL || alucontrol==`SUB_CONTROL)&(catch_bit^alu_out[31]);

//	assign overflow = (alucontrol==`ADD_CONTROL || alucontrol==`SUB_CONTROL)&(catch_bit^alu_out[31])&
//	((op==`R_TYPE&&funct!=`JR))&((op==`R_TYPE&&funct!=`JALR))&(op!=`REGIMM_INST)&(op!=`BNE)&(op!=`BGTZ)
//	&(op!=`BLEZ)&(op!=`JAL)&(op!=`BGTZ)&(op!=`LW)&(op!=`LH)&(op!=`LHU)&(op!=`LB)&(op!=`LBU)&(op!=`SW)
//	&(op!=`SH)&(op!=`SB);//����ж�
assign overflow = (alucontrol==`ADD_CONTROL || alucontrol==`SUB_CONTROL)&(catch_bit^alu_out[31])&
	(funct!=`JR)&(funct!=`JALR)&(op!=`REGIMM_INST)&(op!=`BNE)&(op!=`BGTZ)
	&(op!=`BLEZ)&(op!=`JAL)&(op!=`BGTZ)&(op!=`LW)&(op!=`LH)&(op!=`LHU)&(op!=`LB)&(op!=`LBU)&(op!=`SW)
	&(op!=`SH)&(op!=`SB);//����������ָ��������Ҳ��ʹ�õ�ADD_CONTROL��SUB_CONTROL������������Ҫʹ��op��funct��������������ж��Ƿ������
endmodule