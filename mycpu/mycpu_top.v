module mycpu_top(
     input [5:0] ext_int,   //high active  //input

    input wire aclk,    
    input wire aresetn,   //low active

    output wire[3:0] arid,
    output wire[31:0] araddr,
    output wire[3:0] arlen,
    output wire[2:0] arsize,
    output wire[1:0] arburst,
    output wire[1:0] arlock,
    output wire[3:0] arcache,
    output wire[2:0] arprot,
    output wire arvalid,
    input wire arready,
                
    input wire[3:0] rid,
    input wire[31:0] rdata,
    input wire[1:0] rresp,
    input wire rlast,
    input wire rvalid,
    output wire rready, 
               
    output wire[3:0] awid,
    output wire[31:0] awaddr,
    output wire[3:0] awlen,
    output wire[2:0] awsize,
    output wire[1:0] awburst,
    output wire[1:0] awlock,
    output wire[3:0] awcache,
    output wire[2:0] awprot,
    output wire awvalid,
    input wire awready,
    
    output wire[3:0] wid,
    output wire[31:0] wdata,
    output wire[3:0] wstrb,
    output wire wlast,
    output wire wvalid,
    input wire wready,
    
    input wire[3:0] bid,
    input wire[1:0] bresp,
    input bvalid,
    output bready,

    //debug interface
    output wire[31:0] debug_wb_pc,
    output wire[3:0] debug_wb_rf_wen,
    output wire[4:0] debug_wb_rf_wnum,
    output wire[31:0] debug_wb_rf_wdata
);
    wire clk, rst;
    assign clk = aclk;
    assign rst = ~aresetn;
// �?个例�?
	wire [31:0] pc;
	wire [31:0] instr;
	wire [3:0] memwrite_byteM;
	wire [63:0] aluout;wire [31:0] writedata, readdata;
	wire[31:0] data_paddr;
	wire[31:0] inst_paddr;
	wire inst_en,data_en;
	
	wire        inst_req  ;
    wire [31:0] inst_addr ;
    wire        inst_wr   ;
    wire [1:0]  inst_size ;
    wire [31:0] inst_wdata;
    wire [31:0] inst_rdata;
    wire        inst_addr_ok;
    wire        inst_data_ok;

    wire        data_req  ;
    wire [31:0] data_addr ;
    wire        data_wr   ;
    wire [1:0]  data_size ;
    wire [31:0] data_wdata;
    wire [31:0] data_rdata;
    wire        data_addr_ok;
    wire        data_data_ok;
    
    wire d_stall;
    wire i_stall;
    wire longest_stall;
    mips mips(
        .clk(clk),
        .rst(rst),
        .ext_int(ext_int),
        //instr
        // .inst_en(inst_en),
        .pcF(pc),                    //pcF
        .instrF(instr),              //instrF
        //data
        // .data_en(data_en),
        .memwrite_byteM(memwrite_byteM),
        .aluoutM(aluout),
        .writedataM(writedata),
        .readdataM(data_sram_rdata),
        .inst_en(inst_en),
        .data_en(data_en),
        
        .i_stall(i_stall),
        .d_stall(d_stall),
        .longest_stall(longest_stall),
        
        .debug_wb_pc       (debug_wb_pc       ),  
        .debug_wb_rf_wen   (debug_wb_rf_wen   ),  
        .debug_wb_rf_wnum  (debug_wb_rf_wnum  ),  
        .debug_wb_rf_wdata (debug_wb_rf_wdata )  
    );
    
    mmu mmu(
        .inst_vaddr(inst_addr),
        .inst_paddr(inst_paddr),
        .data_vaddr(data_addr),
        .data_paddr(data_paddr)
    );

    // sram
    wire inst_sram_en;
    wire [3 :0] inst_sram_wen  ;
    wire [31:0] inst_sram_addr ;
    wire [31:0] inst_sram_wdata;
    wire  [31:0] inst_sram_rdata;
    //cpu data sram
    wire        data_sram_en   ;
    wire [3 :0] data_sram_wen  ;
    wire [31:0] data_sram_addr ;
    wire [31:0] data_sram_wdata;
    wire  [31:0] data_sram_rdata;
    //assign inst_sram_en = 1'b1;     //如果有inst_en，就用inst_en
//    assign inst_sram_en = inst_en;
//    assign inst_sram_wen = 4'b0;
//    assign inst_sram_addr = inst_paddr;
//    assign inst_sram_wdata = 32'b0;
//    assign instr = inst_sram_rdata;

//    //assign data_sram_en = 1'b1;     //如果有data_en，就用data_en
//    assign data_sram_en = data_en; 
//    assign data_sram_wen = {4{memwrite_byteM}};
//    //assign data_sram_addr = aluout;
//    assign data_sram_addr = data_paddr;
//    assign data_sram_wdata = writedata;
//    assign readdata = data_sram_rdata;

//    //ascii
//    instdec instdec(
//        .instr(instr)
//    );

    //inst sram to sram-like
i_sram_to_sram_like i_sram_to_sram_like(
    .clk(clk), .rst(rst),
    //sram
    .inst_sram_en(inst_en),
    .inst_sram_addr(pc),
    .inst_sram_rdata(instr),
    .i_stall(i_stall),
    //sram like
    .inst_req(inst_req), 
    .inst_wr(inst_wr),
    .inst_size(inst_size),
    .inst_addr(inst_addr),   
    .inst_wdata(inst_wdata),
    .inst_addr_ok(inst_addr_ok),
    .inst_data_ok(inst_data_ok),
    .inst_rdata(inst_rdata),

    .longest_stall(longest_stall)
);
//data sram to sram-like
d_sram_to_sram_like d_sram_to_sram_like(
    .clk(clk), .rst(rst),
    //sram
    .data_sram_en(data_en),
    .data_sram_addr(aluout[31:0]),
    .data_sram_rdata(data_sram_rdata),
    .data_sram_wen(memwrite_byteM),
    .data_sram_wdata(writedata),
    .d_stall(d_stall),
    //sram like
    .data_req(data_req),    
    .data_wr(data_wr),
    .data_size(data_size),
    .data_addr(data_addr),   
    .data_wdata(data_wdata),
    .data_addr_ok(data_addr_ok),
    .data_data_ok(data_data_ok),
    .data_rdata(data_rdata),

    .longest_stall(longest_stall)
);
cpu_axi_interface cpu_axi_interface(
    .clk(clk),
    .resetn(~rst),

    .inst_req       (inst_req  ),
    .inst_wr        (inst_wr   ),
    .inst_size      (inst_size ),
    .inst_addr      (inst_paddr ),
    .inst_wdata     (inst_wdata),
    .inst_rdata     (inst_rdata),
    .inst_addr_ok   (inst_addr_ok),
    .inst_data_ok   (inst_data_ok),

    .data_req       (data_req  ),
    .data_wr        (data_wr   ),
    .data_size      (data_size ),
    .data_addr      (data_paddr ),
    .data_wdata     (data_wdata),
    .data_rdata     (data_rdata),
    .data_addr_ok   (data_addr_ok),
    .data_data_ok   (data_data_ok),

    .arid(arid),
    .araddr(araddr),
    .arlen(arlen),
    .arsize(arsize),
    .arburst(arburst),
    .arlock(arlock),
    .arcache(arcache),
    .arprot(arprot),
    .arvalid(arvalid),
    .arready(arready),

    .rid(rid),
    .rdata(rdata),
    .rresp(rresp),
    .rlast(rlast),
    .rvalid(rvalid),
    .rready(rready),

    .awid(awid),
    .awaddr(awaddr),
    .awlen(awlen),
    .awsize(awsize),
    .awburst(awburst),
    .awlock(awlock),
    .awcache(awcache),
    .awprot(awprot),
    .awvalid(awvalid),
    .awready(awready),

    .wid(wid),
    .wdata(wdata),
    .wstrb(wstrb),
    .wlast(wlast),
    .wvalid(wvalid),
    .wready(wready),

    .bid(bid),
    .bresp(bresp),
    .bvalid(bvalid),
    .bready(bready)
);

endmodule