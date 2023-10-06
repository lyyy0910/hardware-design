`timescale 1ns / 1ps
`include "defines2.vh"

module mem_dec(
    input wire [31:0] addr, //写入内存的地址
	input wire [5:0] op,
	input wire [31:0] origin_read_data,origin_write_data,
	output reg [31:0] read_data,write_data,
	output reg [3:0] memwrite_byteM,
	output wire addrErrorLw, addrErrorSw
);

    assign addrErrorSw=((op==`SW) & (addr[1:0] != 2'b00))| ((op==`SH) & ((addr[1:0] != 2'b00) & (addr[1:0] != 2'b10)));//sw的地址出错
    assign addrErrorLw=((op==`LW) & (addr[1:0] != 2'b00))|(((op==`LH)|(op==`LHU)) & ((addr[1:0]!=2'b00) & (addr[1:0]!=2'b10)));//lw的地址出错

    always @(*) begin
        case (op)
            `LW:
            begin
                if(addr[1:0] == 2'b00)
                    read_data <= origin_read_data;
                else
                    read_data <= 32'b0;
            end
            `LB: // 取出最高位进行有符号扩展
                case (addr[1:0])
                    2'b11:	read_data <= {{24{origin_read_data[31]}},origin_read_data[31:24]};
                    2'b10:	read_data <= {{24{origin_read_data[23]}},origin_read_data[23:16]};
                    2'b01:	read_data <= {{24{origin_read_data[15]}},origin_read_data[15:8]};
                    2'b00:	read_data <= {{24{origin_read_data[7]}},origin_read_data[7:0]};
                endcase
            `LBU: 
                case (addr[1:0])
                    2'b11:	read_data <= {24'b0,origin_read_data[31:24]};
                    2'b10:	read_data <= {24'b0,origin_read_data[23:16]};
                    2'b01:	read_data <= {24'b0,origin_read_data[15:8]};
                    2'b00:	read_data <= {24'b0,origin_read_data[7:0]};
                endcase	
            `LH:
                case (addr[1:0])
                    2'b10:	read_data <= {{16{origin_read_data[31]}},origin_read_data[31:16]};
                    2'b00:	read_data <= {{16{origin_read_data[15]}},origin_read_data[15:0]};
                    default: read_data <=32'b0;
                endcase	
            `LHU:
                case (addr[1:0])
                    2'b10:	read_data <= {16'b0,origin_read_data[31:16]};
                    2'b00:	read_data <= {16'b0,origin_read_data[15:0]};
                    default: read_data <=32'b0;
                endcase
            default:
			    read_data <=32'b0;
        endcase
    end

    always @(*) begin
        case (op)
			`SW:	
				begin
					if(addr[1:0]==2'b00) 	
						begin
							memwrite_byteM <= 4'b1111;
							write_data <= origin_write_data;
						end
					else 
                        begin
                            memwrite_byteM <= 4'b0000;
                            write_data <= 32'b0;
                        end
				end
			`SB:	
				case (addr[1:0])
					2'b11:	begin	memwrite_byteM <= 4'b1000;		write_data <= {4{origin_write_data[7:0]}};	end
					2'b10:	begin	memwrite_byteM <= 4'b0100;		write_data <= {4{origin_write_data[7:0]}};	end
					2'b01:	begin	memwrite_byteM <= 4'b0010;		write_data <= {4{origin_write_data[7:0]}};	end
					2'b00:	begin	memwrite_byteM <= 4'b0001;		write_data <= {4{origin_write_data[7:0]}};	end
				endcase
			`SH:
				case (addr[1:0])
					2'b10:	begin	memwrite_byteM <= 4'b1100;		write_data <= {2{origin_write_data[15:0]}};		end
					2'b00:	begin	memwrite_byteM <= 4'b0011;		write_data <= {2{origin_write_data[15:0]}};		end
					default: begin
					    memwrite_byteM <= 4'b0000;
					    write_data <= 32'b0;
					end
				endcase
			default: begin
			    memwrite_byteM <= 4'b0000;
			    write_data <= 32'b0;
			end
        endcase
    end


endmodule