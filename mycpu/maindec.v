`timescale 1ns / 1ps
`include "defines2.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/23 15:21:30
// Design Name: 
// Module Name: maindec
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
module maindec(
	input wire[5:0] op,
    input wire[31:0] instrD,
	output wire memtoreg,memwrite,
	output wire branch,alusrc,
	output wire regdst,regwrite,
	output wire jump,
	output wire[1:0] aluop,
	
	output reg [3:0]branchid,
	input wire [4:0]brartD,
	output reg[2:0]jid,
	input  wire[5:0]functD,
	output reg [3:0]hilosign,
	output reg riD//����ָ������
    );
	reg[8:0] controls;
	assign {regwrite,regdst,alusrc,branch,memwrite,memtoreg,jump,aluop} = controls;
	always @(*) begin
	   riD=1'b0;
		case (op)
			//`R_TYPE:controls <= 9'b110000010;//R-TYRE
            `R_TYPE:
                case(functD)
                    `JR:begin controls<=9'b000000100;jid<=3'b010;branchid<=4'b0000;hilosign<=4'b0000;end//JR
                    `JALR:begin controls<=9'b110000100;jid<=3'b100;branchid<=4'b0000;hilosign<=4'b0000;end//JALR
                    `MFHI:begin controls<=9'b110000000;hilosign<=4'b1000;jid<=3'b000;branchid<=4'b0000;end//MFHI
                    `MFLO:begin controls<=9'b110000000;hilosign<=4'b0100;jid<=3'b000;branchid<=4'b0000;end//MFLO
                    `MTHI:begin controls<=9'b000000000;hilosign<=4'b0010;jid<=3'b000;branchid<=4'b0000;end//MTHI
                    `MTLO:begin controls<=9'b000000000;hilosign<=4'b0001;jid<=3'b000;branchid<=4'b0000;end//MTLO
                    `SYSCALL:begin controls<=9'b000000000;jid<=3'b000;hilosign<=4'b0000;branchid<=4'b0000;end
                    `BREAK:begin controls<=9'b000000000;jid<=3'b000;hilosign<=4'b0000;branchid<=4'b0000;end
                    `ADD,`ADDU,`SUB,`SUBU,`SLTU,`SLT ,
					`AND,`NOR, `OR, `XOR,`SLLV, `SLL, 
					`SRAV, `SRA, `SRLV, `SRL:begin controls <= 9'b110000010;jid<=3'b000;hilosign<=4'b0000;branchid<=4'b0000;end
					 `MULT, `MULTU, `DIV, `DIVU:begin controls <= 9'b000000010;jid<=3'b000;hilosign<=4'b1111;branchid<=4'b0000;end
                    default:begin riD<=1'b1;controls <= 9'b110000010;jid<=3'b000;hilosign<=4'b0000;branchid<=4'b0000;end//R-TYPE
                endcase
			`ORI:begin controls<=9'b101000000;jid<=3'b000;hilosign<=4'b0000;branchid<=4'b0000;end//ORI
			`ANDI:begin controls<=9'b101000000;jid<=3'b000;hilosign<=4'b0000;branchid<=4'b0000;end//ANDI
			`XORI:begin controls<=9'b101000000;jid<=3'b000;hilosign<=4'b0000;branchid<=4'b0000;end//XORI
			`LUI:begin controls<=9'b101000000;jid<=3'b000;hilosign<=4'b0000;branchid<=4'b0000;end//LUI
			`BEQ:begin controls <= 9'b000100001;branchid <=4'b0001;jid<=3'b000;hilosign<=4'b0000;end//BEQ
			`ADDI:begin controls <= 9'b101000000;jid<=3'b000;hilosign<=4'b0000;branchid<=4'b0000;end//ADDI
			`ADDIU:begin controls <= 9'b101000000;jid<=3'b000;hilosign<=4'b0000;branchid<=4'b0000;end//ADDIU
			`SLTI:begin controls <= 9'b101000000;jid<=3'b000;hilosign<=4'b0000;branchid<=4'b0000;end//SLTI
			`SLTIU:begin controls <= 9'b101000000;jid<=3'b000;hilosign<=4'b0000;branchid<=4'b0000;end//SLTIU
			//`DIV: begin controls <=9'b001000000;jid<=3'b000;hilosign<=4'b0000;branchid<=4'b0000;end//DIV
			//`DIVU: begin controls<= 9'b001000000;jid<=3'b000;hilosign<=4'b0000;branchid<=4'b0000;end//DIVU
			`J:begin controls <= 9'b000000100;jid<=3'b000;hilosign<=4'b0000;branchid<=4'b0000;end//J
			`BNE:begin controls <=9'b000100001; branchid<=4'b0010;jid<=3'b000;hilosign<=4'b0000;end//BNE
			`BGTZ:begin controls <=9'b000100001; branchid<=4'b0100;jid<=3'b000;hilosign<=4'b0000;end//BGTZ
			`BLEZ:begin controls <=9'b000100001; branchid<=4'b0101;jid<=3'b000;hilosign<=4'b0000;end//BLEZ
			`JAL:begin controls <=9'b100000100; jid<=3'b011;branchid<=4'b0000;hilosign<=4'b0000;end//JAL
            `REGIMM_INST:case(brartD)
                `BGEZ:begin controls <=9'b000100001; branchid<=4'b0011;jid<=3'b000;hilosign<=4'b0000;end//BGEZ
                `BLTZ:begin controls <=9'b000100001; branchid<=4'b0110;jid<=3'b000;hilosign<=4'b0000;end//BLTZ
                `BGEZAL:begin controls <=9'b100100001; branchid<=4'b0111;jid<=3'b000;hilosign<=4'b0000;end//BGEZAL
                `BLTZAL:begin controls <=9'b100100001; branchid<=4'b1000;jid<=3'b000;hilosign<=4'b0000;end//BLTZAL
                default:begin riD  <=1'b1; controls<=9'b000000000;branchid<=4'b0000;jid<=3'b000;hilosign<=4'b0000;end//NONE
            endcase
            `ERET:begin
				case(instrD[25:21])
					`MTC0: begin
						controls <= 9'b000000000;jid<=3'b000;hilosign<=4'b0000;branchid<=4'b0000;
					end
					`MFC0: begin
						controls <= 9'b100000000;jid<=3'b000;hilosign<=4'b0000;branchid<=4'b0000;
					end
					default: begin
						riD  <=  |(instrD[25:0] ^ `ERET);
						controls <= 9'b000000000;jid<=3'b000;hilosign<=4'b0000;branchid<=4'b0000;
					end
				endcase
			end

//			 �ô�ָ��
			`LW:   begin controls <= 9'b101001000;branchid<=4'b0000;jid<=3'b000;hilosign<=4'b0000;end  //LW
			`LH:   begin controls <= 9'b101001000; branchid<=4'b0000;jid<=3'b000;hilosign<=4'b0000;end//LH
			`LHU:  begin controls <= 9'b101001000; branchid<=4'b0000;jid<=3'b000;hilosign<=4'b0000;end//LHU
			`LB:   begin controls <= 9'b101001000; branchid<=4'b0000;jid<=3'b000;hilosign<=4'b0000;end//LB
			`LBU:  begin controls <= 9'b101001000; branchid<=4'b0000;jid<=3'b000;hilosign<=4'b0000;end//LBU9
			`SW:   begin controls <= 9'b001010000; branchid<=4'b0000;jid<=3'b000;hilosign<=4'b0000;end//SW
			`SH:   begin controls <= 9'b001010000; branchid<=4'b0000;jid<=3'b000;hilosign<=4'b0000;end//SH
			`SB:   begin controls <= 9'b001010000; branchid<=4'b0000;jid<=3'b000;hilosign<=4'b0000;end//SB
			default:  begin riD  <=1'b1;controls <= 9'b000000000;jid<=3'b000;branchid<=4'b0000;hilosign<=4'b0000;end //illegal op
		endcase
	end
endmodule
