`timescale 1ns / 1ps
`include "defines2.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/02 15:12:22
// Design Name: 
// Module Name: datapath
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


module datapath(
	input wire clk,rst,
	input [5:0] ext_int,
	//fetch stage
	output wire[31:0] pcF,
	input wire[31:0] instrF,
	//decode stage
	input wire pcsrcD,branchD,
	input wire jumpD,
	output wire equalD,
	output wire[5:0] opD,functD,
	output wire [31:0] instrD,
	//execute stage
	input wire memtoregE,
	input wire alusrcE,regdstE,
	input wire regwriteE,
	input wire[4:0] alucontrolE,
	output wire flushE,
	output wire stall_div,
	//mem stage
	input wire memtoregM,
	input wire memwriteM,
	input wire regwriteM,
	output wire[63:0] aluoutM,output wire [31:0]write_data,
	input wire[31:0] readdataM,output wire[3:0] memwrite_byteM,
	//writeback stage
	input wire memtoregW,
	input wire regwriteW,
	//new
	output wire [3:0]compzeroD,
	output wire [4:0]brartD,
	input wire branchwriteE,
	input wire j_regD,
	input wire j_31D,
	input wire j_pls8D,
	input wire wehiD,
	input wire weloD,
	input wire rehiD,
	input wire reloD,
	input wire riD,
	output inst_en,
	output data_en,
	output wire flush_exceptionM,
	output wire flush_exceptionW,
	
	input wire i_stall,
	input wire d_stall,
	output wire longest_stall,
	
	
	output [31:0] debug_wb_pc     ,
    output [3:0] debug_wb_rf_wen  ,
    output [4:0] debug_wb_rf_wnum ,
    output [31:0] debug_wb_rf_wdata
    );
	
	//fetch stage
	wire stallF;
	//FD
	wire [31:0] pcnextFD,pcnextbrFD,pcplus4F,pcbranchD;
	//decode stage
	wire [31:0] pcplus4D;
	wire[1:0] forwardaD,forwardbD;
	wire [4:0] rsD,rtD,rdD;
	wire flushD,stallD; 
	wire [31:0] signimmD,signimmshD;
	wire [31:0] srcaD,srca2D,srcbD,srcb2D;
	//execute stage
	wire [1:0] forwardaE,forwardbE;
	wire [4:0] rsE,rtE,rdE;
	wire [4:0] writeregE;
	wire [31:0] signimmE;
	wire [31:0] srcaE,srca2E,srcbE,srcb2E,srcb3E,srca3E,srcb4E;
	wire [63:0] aluoutE;
	//mem stage
	wire [4:0] writeregM;
	//writeback stage
	wire [4:0] writeregW;
	wire [63:0] aluoutW;wire [31:0]readdataW,resultW;
	
	//ly
	wire[31:0] hi_o,lo_o;
	wire overflowE;
	wire zero;
	wire we;
	wire[4:0] saD,saE;
	
	//yxy new
	wire [31:0]pc_tst;
	//F stage
	
	//D stage 
	wire [31:0]pcD;
	//E stage
	wire [31:0]pcbranchE;
	wire [31:0]pcE;
	wire branchE;
	wire pred_takeE;
	wire j_31E;
	wire j_pls8E;
	wire wehiE,rehiE;
	wire weloE,reloE;
	wire [31:0]hivalE;
	wire [31:0]lovalE;
	wire [5:0]opE;
	//M stage
	wire [31:0]pcbranchM;
	wire branchwriteM;
	wire[31:0] writedataM;
	wire [31:0]hivalM;
	wire [31:0]lovalM;
	wire rehiM,reloM;
	wire [5:0]opM;
	wire [31:0]pcM;
	wire actual_takeM;
	wire branchM;
	wire pred_takeM;
	wire flushM;
	wire [31:0] nextPC ;
	//W stage
	wire [31:0]pcbranchW;
	wire [31:0]pcW;
	wire branchwriteW;
	wire [31:0]hivalW;
	wire [31:0]lovalW;
	wire rehiW,reloW;
	wire [31:0]result2W,result3W;
	wire stall_divE;
	wire[5:0] functE;
	wire[5:0] brartE;
	wire is_in_delayslot_iE;
    wire is_in_delayslot_iD;
    wire is_in_delayslot_iF;
	wire riE,riM;
    wire breakD,breakE,breakM;
    wire syscallD,syscallE,syscallM;
    wire eretD,eretE,eretM;
    wire overflowM;
    wire addrErrorLwM, addrErrorSwM;
    wire pcErrorM;
    wire [31:0] except_typeM;
    wire [31:0] cp0_statusM;
    wire [31:0] cp0_causeM;
    wire [31:0] cp0_epcM;
    //wire flush_exceptionM;
    wire [31:0] pc_exceptionM;
    wire pc_trapM;
    wire [31:0] badvaddrM;
    wire is_in_delayslot_iM;
    wire [4:0] rdM;
    wire cp0_to_regD,cp0_to_regE,cp0_to_regM;
    wire mem_error_enM;
    wire cp0_wenD,cp0_wenE,cp0_wenM;
    wire [31:0] rt_valueM;
	wire [31:0] cp0_statusW, cp0_causeW, cp0_epcW, cp0_data_oW;
	wire flush_jump_confilctE;
	
	
	assign debug_wb_pc          = pcW;
    assign debug_wb_rf_wen      = {4{regwriteW & ~flush_exceptionW & ~longest_stall}};
    assign debug_wb_rf_wnum     = writeregW;
    assign debug_wb_rf_wdata    = result3W;
	
	//hazard detection
	hazard h(
		//fetch stage
		stallF,
		//decode stage
		rsD,rtD,
		branchD,
		forwardaD,forwardbD,
		stallD,
		//execute stage
		rsE,rtE,
		writeregE,
		regwriteE,
		memtoregE,
		forwardaE,forwardbE,
		flushE,
		//mem stage
		writeregM,
		regwriteM,
		memtoregM,
		//write back stage
		writeregW,
		regwriteW,
		i_stall,
		d_stall,
		stall_div,
		mult_stall,
		longest_stall
		);

	//next PC logic (operates in fetch an decode)
	mux2 #(32) pcbrmux(pcplus4F,pcbranchD,pcsrcD,pcnextbrFD);
	mux2 #(32) pcmux(pcnextbrFD,{pcplus4D[31:28],instrD[25:0],2'b00},jumpD,pcnextFD);
	//yxy new
	//mux2 #(32) pcmux2(pcnextFD,srca2D,j_regD,pc_tst);
	wire [31:0] jr_next_pc;wire [63:0]aluout2M,aluout3M;
	wire ce;
	wire[31:0] pc_next;
	wire jr,jump_conflictD;
	wire [31:0]tohi,tolo,result1M,result2M,resultM;
	assign jr = ~(|instrD[31:26]) & ~(|(instrD[5:1] ^ 5'b00100));
	assign jr_next_pc = (rsD != 0 & rsD == writeregE) ? aluoutE : ((rsD != 0 & rsD == writeregM) ? resultM : srcaD);
	assign jump_conflictD = jr &&((regwriteE && rsD == writeregE) ||(regwriteM && rsD == writeregM));
	assign flushD=flush_exceptionM ;//| flush_jump_confilctE;  
	//assign jr_next_pc = (rsD != 0 & rsD == writeregE) ? aluoutE :srcaD;
	// assign forwardaD = (rsD != 0 & rsD == writeregM & regwriteM);
	mux2 #(32) pcmux2(pcnextFD,jr_next_pc,j_regD,pc_tst);
	mux2 #(32) pcmux3(pc_tst,pc_exceptionM,pc_trapM,pc_next);
	//regfile (operates in decode and writeback)
	regfile rf(clk,regwriteW&~flush_exceptionW&~longest_stall,rsD,rtD,writeregW,result3W,srcaD,srcbD);

	//fetch stage logic
	pc #(32) pcreg(clk,rst,(~stallF&~longest_stall)|flush_exceptionM,pc_next,pcF,ce);
	//pc #(32) pcreg(clk,rst,~stallF,pc_next,pcF,ce);
//	adder pcadd1(clk,rst,~longest_stall,pcF,32'b100,pcplus4F);
    adder pcadd1(pcF,32'b100,pcplus4F);
	//decode stage
	flopenrc #(32) r1D(clk,rst,(~stallD&~longest_stall)|flush_exceptionM,flushD,pcplus4F,pcplus4D);
	flopenrc #(32) r2D(clk,rst,(~stallD&~longest_stall)|flush_exceptionM,flushD,instrF,instrD);
	
	//yxy new
	flopenrc #(32) r3D(clk,rst,(~stallD&~longest_stall)|flush_exceptionM,flushD,pcF,pcD);
	flopenrc #(1) r4D(clk,rst,(~stallD&~longest_stall)|flush_exceptionM,flushD,is_in_delayslot_iF,is_in_delayslot_iD);
	wire pcErrorF;
	assign pcErrorF = pcF[1:0]==2'b0 ? 1'b0 : 1'b1;
	assign inst_en=ce&~pcErrorF& ~flush_exceptionM;
	//assign inst_en=ce&~stall_div& ~stallF;
	assign is_in_delayslot_iF = branchD | jumpD;

//	wire [31:0]srcb2DD;
//	assign srcb2DD=(rtD!=0&rtD==writeregM&&regwriteM)?aluout3M[31:0]:srcb2D;
	
	signext se(instrD[15:0],opD,signimmD);
	sl2 immsh(signimmD,signimmshD);
	adder pcadd2(pcplus4D,signimmshD,pcbranchD);
	mux3 #(32) forwardamux(srcaD,result3W,resultM,forwardaD,srca2D);
	mux3 #(32) forwardbmux(srcbD,result3W,resultM,forwardbD,srcb2D);
	eqcmp comp(srca2D,srcb2D,equalD);
	//yxy new input wire [31:0] srca,input wire en,input clk,input wire rst,output reg [3:0]res
	comp_to_zero ctz(srca2D,compzeroD);
	
	//
	assign opD = instrD[31:26];
	assign functD = instrD[5:0];
	assign rsD = instrD[25:21];
	assign rtD = instrD[20:16];
	assign rdD = instrD[15:11];
	//yxy new
	assign brartD=instrD[20:16];
	assign saD=instrD[10:6];
	
	assign cp0_wenD = ~(|(opD ^ `ERET)) & ~(|(rsD ^ `MTC0));
	assign cp0_to_regD = ~(|(opD ^ `ERET)) & ~(|(rsD ^ `MFC0));
	assign breakD = ~(|(opD ^ `R_TYPE)) & ~(|(functD ^ `BREAK));
	assign syscallD = ~(|(opD ^ `R_TYPE)) & ~(|(functD ^ `SYSCALL));
	assign eretD = ~(|(instrD ^ {`ERET, 26'b10000000000000000000011000}));
	
	//execute stage
	flopenrc #(32) r1E(clk,rst,~stall_div&~longest_stall,flushE&~longest_stall|flush_exceptionM,srcaD,srcaE);
	flopenrc #(32) r2E(clk,rst,~stall_div&~longest_stall,flushE&~longest_stall|flush_exceptionM,srcbD,srcbE);
	flopenrc #(32) r3E(clk,rst,~stall_div&~longest_stall,flushE&~longest_stall|flush_exceptionM,signimmD,signimmE);
	flopenrc #(5) r4E(clk,rst,~stall_div&~longest_stall,flushE&~longest_stall|flush_exceptionM,rsD,rsE);
	flopenrc #(5) r5E(clk,rst,~stall_div&~longest_stall,flushE&~longest_stall|flush_exceptionM,rtD,rtE);
	flopenrc #(5) r6E(clk,rst,~stall_div&~longest_stall,flushE&~longest_stall|flush_exceptionM,rdD,rdE);
	flopenrc #(5) r9E(clk,rst,~stall_div&~longest_stall,flushE&~longest_stall|flush_exceptionM,saD,saE);
	//yxy new
	flopenrc #(32)r7E(clk,rst,~stall_div&~longest_stall,flushE&~longest_stall|flush_exceptionM,pcbranchD,pcbranchE);
	flopenrc #(32)r8E(clk,rst,~stall_div&~longest_stall,flushE&~longest_stall|flush_exceptionM,pcD,pcE);
	flopenrc #(1)r10E(clk,rst,~stall_div&~longest_stall,flushE&~longest_stall|flush_exceptionM,j_31D,j_31E);
	flopenrc #(1)r11E(clk,rst,~stall_div&~longest_stall,flushE&~longest_stall|flush_exceptionM,j_pls8D,j_pls8E);
	flopenrc #(1) r12E(clk,rst,~stall_div&~longest_stall,flushE&~longest_stall|flush_exceptionM,wehiD,wehiE);
	flopenrc #(1) r13E(clk,rst,~stall_div&~longest_stall,flushE&~longest_stall|flush_exceptionM,weloD,weloE);
	flopenrc #(1) r14E(clk,rst,~stall_div&~longest_stall,flushE&~longest_stall|flush_exceptionM,rehiD,rehiE);
	flopenrc #(1) r15E(clk,rst,~stall_div&~longest_stall,flushE&~longest_stall|flush_exceptionM,reloD,reloE);
	flopenrc #(6) r16E(clk,rst,~stall_div&~longest_stall,flushE&~longest_stall|flush_exceptionM,opD,opE);
	flopenrc #(6) r17E(clk,rst,~stall_div&~longest_stall,flushE&~longest_stall|flush_exceptionM,functD,functE);
	flopenrc #(5) r18E(clk,rst,~stall_div&~longest_stall,flushE&~longest_stall|flush_exceptionM,brartD,brartE);
	flopenrc #(1)r19E(clk,rst,~stall_div&~longest_stall,flushE&~longest_stall|flush_exceptionM,riD,riE);
	flopenrc #(1)r20E(clk,rst,~stall_div&~longest_stall,flushE&~longest_stall|flush_exceptionM,breakD,breakE);
	flopenrc #(1) r21E(clk,rst,~stall_div&~longest_stall,flushE&~longest_stall|flush_exceptionM,syscallD,syscallE);
	flopenrc #(1) r22E(clk,rst,~stall_div&~longest_stall,flushE&~longest_stall|flush_exceptionM,eretD,eretE);
	flopenrc #(1) r23E(clk,rst,~stall_div&~longest_stall,flushE&~longest_stall|flush_exceptionM,cp0_wenD,cp0_wenE);
	flopenrc #(1) r24E(clk,rst,~stall_div&~longest_stall,flushE&~longest_stall|flush_exceptionM,cp0_to_regD,cp0_to_regE);
	flopenrc #(1) r25E(clk,rst,~stall_div&~longest_stall,flushE&~longest_stall|flush_exceptionM,is_in_delayslot_iD,is_in_delayslot_iE);
	flopenrc #(1) r26E(clk,rst,~stall_div&~longest_stall,flushE&~longest_stall|flush_exceptionM,jump_conflictD,jump_conflictE);
	assign flush_jump_confilctE = jump_conflictE;
	//floprc #(6) r17E(clk,rst,~stall_div,pcD,pcE);
	//flopenr #(32) r17E(clk,rst,~stall_div,pcD,pcE);
	//yxy change
	mux3 #(32) forwardaemux(srcaE,result3W,resultM,forwardaE,srca2E);
	mux3 #(32) forwardbemux(srcbE,result3W,resultM,forwardbE,srcb2E);
	mux2 #(32) srcbmux(srcb2E,signimmE,alusrcE,srcb3E);
	//yxy new
	mux2 #(32) srcamux(srca2E,pcE,j_pls8E|branchwriteE,srca3E);
	mux2 #(32) srcbmux2(srcb3E,32'b1000,j_pls8E|branchwriteE,srcb4E);
//	hilo hlreg(clk,rst,wehiE,weloE,srca2E,srca2E,hivalE,lovalE);

	wire [31:0]read_data;//,write_data;
	wire mult_stall;
	mux2 #(32)hisrcmux(srca2E,aluoutE[63:32],we,tohi);
	mux2 #(32)losrcmux(srca2E,aluoutE[31:0],we,tolo);
	alu alu(clk,rst,stallD,(flushE&~longest_stall)|flush_exceptionM,flush_exceptionM,longest_stall,srca3E,srcb4E,opE,functE,brartE,saE,aluoutE,overflowE,zero,we,stall_div,mult_stall);
	hilo_reg hilomulormove(clk,rst,(we|wehiE)&~flush_exceptionM&~longest_stall,(we|weloE)&~flush_exceptionM&~longest_stall,tohi,tolo,hivalE,lovalE);
	mux2 #(5) wrmux(rtE,rdE,regdstE,writeregE);
	
	mux2 #(64)sb1(aluoutM,hivalM,rehiM,aluout2M);
	mux2 #(64)sb2(aluout2M,lovalM,reloM,aluout3M);//????????????????alu?????
	mux2 #(32)sb3(aluout3M[31:0],read_data,(memtoregM | cp0_to_regM),result1M);
	mux2 #(32)sb4((rehiM==1'b1 ? hivalM:lovalM),cp0_data_oW,(memtoregM | cp0_to_regM),result2M);
	mux2 #(32)sb5(result1M,result2M,(rehiM | reloM | cp0_to_regM),resultM);
	
	//yxy new
	wire [4:0]writereg2E;
	mux2 #(5) wrmux2(writeregE,5'b11111,branchwriteE|j_31E,writereg2E);

	//mem stage
	flopenrc #(32) r1M(clk,rst,~longest_stall,flush_exceptionM,srcb2E,writedataM);
	flopenrc #(64) r2M(clk,rst,~longest_stall,flush_exceptionM,aluoutE,aluoutM);
	flopenrc #(32)r10M(clk,rst,~longest_stall,flush_exceptionM,pcE,pcM);
	flopenrc #(5) r3M(clk,rst,~longest_stall,flush_exceptionM,writereg2E,writeregM);
	//yxy new
	flopenrc #(32) r4M(clk,rst,~longest_stall,flush_exceptionM,pcbranchE,pcbranchM);
	flopenrc #(1) r5M(clk,rst,~longest_stall,flush_exceptionM,rehiE,rehiM);
	flopenrc #(1) r6M(clk,rst,~longest_stall,flush_exceptionM,reloE,reloM);
	flopenrc#(32) r7M(clk,rst,~longest_stall,flush_exceptionM,hivalE,hivalM);
	flopenrc #(32) r8M(clk,rst,~longest_stall,flush_exceptionM,lovalE,lovalM);
	flopenrc #(6) r9M(clk,rst,~longest_stall,flush_exceptionM,opE,opM);
	flopenrc #(1)r11M(clk,rst,~longest_stall,flush_exceptionM,riE,riM);
	flopenrc #(1)r12M(clk,rst,~longest_stall,flush_exceptionM,breakE,breakM);
	flopenrc #(1)r13M(clk,rst,~longest_stall,flush_exceptionM,syscallE,syscallM);
	flopenrc #(1)r14M(clk,rst,~longest_stall,flush_exceptionM,eretE,eretM);
	flopenrc #(1)r15M(clk,rst,~longest_stall,flush_exceptionM,cp0_wenE,cp0_wenM);
	flopenrc #(1)r16M(clk,rst,~longest_stall,flush_exceptionM,cp0_to_regE,cp0_to_regM);
	flopenrc #(1)r17M(clk,rst,~longest_stall,flush_exceptionM,overflowE,overflowM);
	flopenrc #(32)r18M(clk,rst,~longest_stall,flush_exceptionM,is_in_delayslot_iE,is_in_delayslot_iM);
	flopenrc #(5)r19M(clk,rst,~longest_stall,flush_exceptionM,rdE,rdM);
	
	assign pcErrorM=(pcM[1:0] != 2'b00); 
	
	assign data_en = (memtoregM | memwriteM) & ~flush_exceptionM;
	
	mem_dec sd(aluout3M[31:0],opM,readdataM,writedataM,read_data,write_data,memwrite_byteM,addrErrorLwM, addrErrorSwM);
	
	
	//writeback stage
	flopenrc #(64) r1W(clk,rst,~longest_stall,flush_exceptionM,aluout3M,aluoutW);
	flopenrc #(32) r2W(clk,rst,~longest_stall,flush_exceptionM,read_data,readdataW);
	flopenrc #(5) r3W(clk,rst,~longest_stall,flush_exceptionM,writeregM,writeregW);
	flopenrc #(32)r9W(clk,rst,~longest_stall,flush_exceptionM,pcM,pcW);
	
	//yxy new
	flopenrc #(32)r4W(clk,rst,~longest_stall,flush_exceptionM,pcbranchM,pcbranchW);
	flopenrc #(1)r5W(clk,rst,~longest_stall,flush_exceptionM,rehiM,rehiW);
	flopenrc #(1)r6W(clk,rst,~longest_stall,flush_exceptionM,reloM,reloW);
	flopenrc #(32)r7W(clk,rst,~longest_stall,flush_exceptionM,hivalM,hivalW);
	flopenrc #(32)r8W(clk,rst,~longest_stall,flush_exceptionM,lovalM,lovalW);
	flopenrc #(32)r10W(clk,rst,~longest_stall,flush_exceptionM,resultM,result3W);
	flopr #(1)r11W(clk,rst,flush_exceptionM,flush_exceptionW);
	
	
//	mux2 #(32) resmux(aluoutW[31:0],readdataW,memtoregW,resultW);
//	//yxy new
//	mux2 #(32) resmux2(resultW,hivalW,rehiW,result2W);
//	mux2 #(32) resmux3(result2W,lovalW,reloW,result3W);
	
	exception exception(
        .rst(rst),
        .ext_int(ext_int),
        .ri(riM),
        .breakM(breakM), 
        .syscall(syscallM), 
        .overflow(overflowM), 
        .addrErrorSw(addrErrorSwM), 
        .addrErrorLw(addrErrorLwM), 
        .pcError(pcErrorM), 
        .eretM(eretM),
        .cp0_status(cp0_statusW), 
        .cp0_cause(cp0_causeW), 
        .cp0_epc(cp0_epcW),
        .pcM(pcM),
        .alu_outM(aluoutM),

        .except_type(except_typeM),
        .flush_exception(flush_exceptionM),
        .pc_exception(pc_exceptionM),
        .pc_trap(pc_trapM),
        .badvaddrM(badvaddrM)
    );
	
	cp0_reg cp0(
        .clk(clk),
        .rst(rst),
        
        .we_i(cp0_wenM & ~longest_stall),
        .waddr_i(rdM),
        .raddr_i(rdM),
        //.data_i(rt_valueM),
        .data_i(writedataM),
        .en(flush_exceptionM),

        .excepttype_i(except_typeM),
        .current_inst_addr_i(pcM),
        .is_in_delayslot_i(is_in_delayslot_iM),
        .bad_addr_i(badvaddrM),

        .data_o(cp0_data_oW),
        .status_o(cp0_statusW),
        .cause_o(cp0_causeW),
        .epc_o(cp0_epcW)
    );
	
endmodule