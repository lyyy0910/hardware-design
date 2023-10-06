`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/22 10:23:13
// Design Name: 
// Module Name: hazard
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


module hazard(
	//fetch stage
	output wire stallF,
	//decode stage
	input wire[4:0] rsD,rtD,
	input wire branchD,
	output reg[1:0] forwardaD,forwardbD,
	output wire stallD,
	//execute stage
	input wire[4:0] rsE,rtE,
	input wire[4:0] writeregE,
	input wire regwriteE,
	input wire memtoregE,
	output reg[1:0] forwardaE,forwardbE,
	output wire flushE,
	//mem stage
	input wire[4:0] writeregM,
	input wire regwriteM,
	input wire memtoregM,

	//write back stage
	input wire[4:0] writeregW,
	input wire regwriteW,
	input i_stall,
	input d_stall,
	input div_stall,
	input mult_stall,
	output longest_stall
    );

	wire lwstallD,branchstallD;

	//forwarding sources to D stage (branch equality)
	//assign forwardaD = (rsD != 0 & rsD == writeregM & regwriteM);
	//assign forwardbD = (rtD != 0 & rtD == writeregM & regwriteM);
	always @(*) begin
		forwardaD = 2'b00;
		forwardbD = 2'b00;
		if(rsD != 0) begin
			/* code */
			if(rsD == writeregM & regwriteM) begin
				/* code */
				forwardaD = 2'b10;
			end else if(rsD == writeregW & regwriteW) begin
				/* code */
				forwardaD = 2'b01;
			end
		end
		if(rtD != 0) begin
			/* code */
			if(rtD == writeregM & regwriteM) begin
				/* code */
				forwardbD = 2'b10;
			end else if(rtD == writeregW & regwriteW) begin
				/* code */
				forwardbD = 2'b01;
			end
		end
	end
	
	//forwarding sources to E stage (ALU)

	always @(*) begin
		forwardaE = 2'b00;
		forwardbE = 2'b00;
		if(rsE != 0) begin
			/* code */
			if(rsE == writeregM & regwriteM) begin
				/* code */
				forwardaE = 2'b10;
			end else if(rsE == writeregW & regwriteW) begin
				/* code */
				forwardaE = 2'b01;
			end
		end
		if(rtE != 0) begin
			/* code */
			if(rtE == writeregM & regwriteM) begin
				/* code */
				forwardbE = 2'b10;
			end else if(rtE == writeregW & regwriteW) begin
				/* code */
				forwardbE = 2'b01;
			end
		end
	end

	//stalls
	assign  longest_stall=i_stall|d_stall|div_stall;
	assign lwstallD = memtoregE & (rtE == rsD | rtE == rtD);
	assign branchstallD = branchD &(regwriteE &(writeregE == rsD | writeregE == rtD)|memtoregM &(writeregM == rsD | writeregM == rtD));
	assign stallD = lwstallD | branchstallD|longest_stall;
	assign stallF = stallD|longest_stall|branchstallD;
	//assign #1 stallF=1'b0;
		//stalling D stalls all previous stages
	assign flushE = stallD;
		//stalling D flushes next stage
	// Note: not necessary to stall D stage on store
  	//       if source comes from load;
  	//       instead, another bypass network could
  	//       be added from W to M
endmodule
