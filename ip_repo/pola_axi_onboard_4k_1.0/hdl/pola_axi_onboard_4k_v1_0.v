
`timescale 1 ns / 1 ps

	module pola_axi_onboard_4k_v1_0 #
	(
		// Users to add parameters here
        parameter C_S_AXI_DATA_WIDTH = 32,
        parameter C_M_AXI_ID_WIDTH	    = 1,
        parameter C_M_AXI_ADDR_WIDTH	= 32,
        parameter C_M_AXI_DATA_WIDTH	= 64,
        parameter C_M_AXI_AWUSER_WIDTH	= 1,
        parameter C_M_AXI_ARUSER_WIDTH	= 1,
        parameter C_M_AXI_WUSER_WIDTH	= 1,
        parameter C_M_AXI_RUSER_WIDTH	= 1,
        parameter C_M_AXI_BUSER_WIDTH	= 1,
		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S00_AXI
		parameter integer C_S00_AXI_DATA_WIDTH	= 32,
		parameter integer C_S00_AXI_ADDR_WIDTH	= 6
	)
	(
		// Users to add ports here
        // M_AXI-Full
        input                                    M_AXI_ACLK,
        input                                    M_AXI_ARESETN,
        //----------------------------------------------------------------------------------
        //  (AW) Channel
        //----------------------------------------------------------------------------------
        input                                    M_AXI_AWREADY,
        output  [C_M_AXI_ID_WIDTH-1 : 0]         M_AXI_AWID,     //Unused
        output  [C_M_AXI_ADDR_WIDTH-1 : 0]       M_AXI_AWADDR,   
        output  [7 : 0]                          M_AXI_AWLEN,
        output  [2 : 0]                          M_AXI_AWSIZE,   //Unused
        output  [1 : 0]                          M_AXI_AWBURST,  //Unused
        output                                   M_AXI_AWLOCK,   //Unused
        output  [3 : 0]                          M_AXI_AWCACHE,  //Unused
        output  [2 : 0]                          M_AXI_AWPROT,   //Unused
        output  [3 : 0]                          M_AXI_AWQOS,    //Unused
        output  [C_M_AXI_AWUSER_WIDTH-1 : 0]     M_AXI_AWUSER,   //Unused
        output                                   M_AXI_AWVALID,

        //----------------------------------------------------------------------------------
        //  (W) Channel
        //----------------------------------------------------------------------------------
        input                                    M_AXI_WREADY,
        output  [C_M_AXI_DATA_WIDTH-1 : 0]       M_AXI_WDATA,
        output  [C_M_AXI_DATA_WIDTH/8-1 : 0]     M_AXI_WSTRB,
        output                                   M_AXI_WLAST,
        output  [C_M_AXI_WUSER_WIDTH-1 : 0]      M_AXI_WUSER,    //Unused
        output                                   M_AXI_WVALID,

        //----------------------------------------------------------------------------------
        //  (B) Channel
        //----------------------------------------------------------------------------------
        input  [C_M_AXI_ID_WIDTH-1 : 0]          M_AXI_BID,      //Unused
        input  [1 : 0]                           M_AXI_BRESP,
        input  [C_M_AXI_BUSER_WIDTH-1 : 0]       M_AXI_BUSER,    //Unused
        input                                    M_AXI_BVALID,
        output                                   M_AXI_BREADY,
        
        //----------------------------------------------------------------------------------
        //  (AR) Channel
        //----------------------------------------------------------------------------------
        input                                    M_AXI_ARREADY, // ready
        output  [C_M_AXI_ID_WIDTH-1 : 0]         M_AXI_ARID,    //0
        output  wire [C_M_AXI_ADDR_WIDTH-1 : 0]  M_AXI_ARADDR,  // addr
        output  wire [7 : 0]                     M_AXI_ARLEN,   // 128 bits
        output  [2 : 0]                          M_AXI_ARSIZE,
        output  [1 : 0]                          M_AXI_ARBURST,
        output                                   M_AXI_ARLOCK,
        output  [3 : 0]                          M_AXI_ARCACHE,
        output  [2 : 0]                          M_AXI_ARPROT,
        output  [3 : 0]                          M_AXI_ARQOS,
        output  [C_M_AXI_ARUSER_WIDTH-1 : 0]     M_AXI_ARUSER,
        output  wire                             M_AXI_ARVALID, // same as ready, but just for one cycle

        //----------------------------------------------------------------------------------
        //  (R) Channel
        //----------------------------------------------------------------------------------
        input  [C_M_AXI_ID_WIDTH-1 : 0]          M_AXI_RID,     //
        input  [C_M_AXI_DATA_WIDTH-1 : 0]        M_AXI_RDATA,   //Dram -> Sram Data
        input  [1 : 0]                           M_AXI_RRESP,   // feedback good or bad
        input                                    M_AXI_RLAST,   // last value
        input  [C_M_AXI_RUSER_WIDTH-1 : 0]       M_AXI_RUSER,
        input                                    M_AXI_RVALID,  // when valid is High , read data is effective
        output wire                              M_AXI_RREADY,   // ready to start reading
        output                                   IRQ,
		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface S00_AXI
		input wire  s00_axi_aclk,
		input wire  s00_axi_aresetn,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
		input wire [2 : 0] s00_axi_awprot,
		input wire  s00_axi_awvalid,
		output wire  s00_axi_awready,
		input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
		input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
		input wire  s00_axi_wvalid,
		output wire  s00_axi_wready,
		output wire [1 : 0] s00_axi_bresp,
		output wire  s00_axi_bvalid,
		input wire  s00_axi_bready,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
		input wire [2 : 0] s00_axi_arprot,
		input wire  s00_axi_arvalid,
		output wire  s00_axi_arready,
		output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
		output wire [1 : 0] s00_axi_rresp,
		output wire  s00_axi_rvalid,
		input wire  s00_axi_rready,
		
		output                                   Write_en,
		output                                   Write_en_dff,
        output [1:0]                             main_state_WATCH,
        output [1:0]                             w_state_WATCH,
        output [1:0]                             r_state_WATCH,
        output [63:0]                            w_data_WATCH,
        output [63:0]                            r_data_WATCH,
        output [7:0]                             write_valid_count_56_WATCH,
        output [31:0]                            write_valid_count,
        output                                   START_WATCH,
        output                                   RST_WATCH,
        output [2:0]                             version,
        output [4:0] choose_count,cache_count,lost_count,
        output assert_wready_wvalid,
        output [63:0]output_buffer_0,
        output [63:0]output_buffer_1,
        output [63:0]output_buffer_2,
        output [63:0]output_buffer_3
	);
	assign version = 3'd3;
    wire s_axi_start,s_axi_rst;
    assign START_WATCH = s_axi_start;
    assign RST_WATCH = s_axi_rst;
    wire [C_S00_AXI_DATA_WIDTH-1 : 0] s_axi_inst_0;
    wire [C_S00_AXI_DATA_WIDTH-1 : 0] s_axi_inst_1;
    wire [C_S00_AXI_DATA_WIDTH-1 : 0] s_axi_inst_2;
    wire [C_S00_AXI_DATA_WIDTH-1 : 0] s_axi_inst_3;
    wire [C_S00_AXI_DATA_WIDTH-1 : 0] s_axi_inst_4;
    wire [C_S00_AXI_DATA_WIDTH-1 : 0] s_axi_Rerror_addr;
    wire [C_S00_AXI_DATA_WIDTH-1 : 0] s_axi_Werror_addr;
    wire s_axi_Rerror;
    wire [1 : 0] s_axi_Werror;
// Instantiation of Axi Bus Interface S00_AXI
	pola_axi_onboard_4k_v1_0_S00_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
	) pola_axi_onboard_4k_v1_0_S00_AXI_inst (
.S_AXI_ACLK(s00_axi_aclk),
		.S_AXI_ARESETN(s00_axi_aresetn),
		.S_AXI_AWADDR(s00_axi_awaddr),
		.S_AXI_AWPROT(s00_axi_awprot),
		.S_AXI_AWVALID(s00_axi_awvalid),
		.S_AXI_AWREADY(s00_axi_awready),
		.S_AXI_WDATA(s00_axi_wdata),
		.S_AXI_WSTRB(s00_axi_wstrb),
		.S_AXI_WVALID(s00_axi_wvalid),
		.S_AXI_WREADY(s00_axi_wready),
		.S_AXI_BRESP(s00_axi_bresp),
		.S_AXI_BVALID(s00_axi_bvalid),
		.S_AXI_BREADY(s00_axi_bready),
		.S_AXI_ARADDR(s00_axi_araddr),
		.S_AXI_ARPROT(s00_axi_arprot),
		.S_AXI_ARVALID(s00_axi_arvalid),
		.S_AXI_ARREADY(s00_axi_arready),
		.S_AXI_RDATA(s00_axi_rdata),
		.S_AXI_RRESP(s00_axi_rresp),
		.S_AXI_RVALID(s00_axi_rvalid),
		.S_AXI_RREADY(s00_axi_rready),

        .s_axi_start(s_axi_start),
        .s_axi_rst(s_axi_rst),
        .s_axi_inst_0(s_axi_inst_0),
        .s_axi_inst_1(s_axi_inst_1),
        .s_axi_inst_2(s_axi_inst_2),
        .s_axi_inst_3(s_axi_inst_3),
        .s_axi_inst_4(s_axi_inst_4),
        .s_axi_Rerror_addr(s_axi_Rerror_addr),
        .s_axi_Werror_addr(s_axi_Werror_addr),
        .s_axi_Rerror(s_axi_Rerror),
        .s_axi_Werror(s_axi_Werror),
        .IRQ(IRQ)
	);

	// Add user logic here
    CNN u_CNN (
        //S_AXI-Lite
        .S_AXI_ACLK             (s00_axi_aclk),
        .IRQ                    (IRQ),

        .s_axi_start(s_axi_start),
        .s_axi_inst_0(s_axi_inst_0),
        .s_axi_inst_1(s_axi_inst_1),
        .s_axi_inst_2(s_axi_inst_2),
        .s_axi_inst_3(s_axi_inst_3),
        .s_axi_inst_4(s_axi_inst_4),

        .s_axi_Rerror(s_axi_Rerror),
        .s_axi_Rerror_addr(s_axi_Rerror_addr),
        .s_axi_Werror(s_axi_Werror),
        .s_axi_Werror_addr(s_axi_Werror_addr),

        // M_AXI-Full
        .M_AXI_ACLK             (M_AXI_ACLK),
        .M_AXI_ARESETN          (s_axi_rst),
        //----------------------------------------------------------------------------------
        //  (AW) Channel
        //----------------------------------------------------------------------------------
        .M_AXI_AWREADY          (M_AXI_AWREADY),
        .M_AXI_AWID             (M_AXI_AWID),
        .M_AXI_AWADDR           (M_AXI_AWADDR),
        .M_AXI_AWLEN            (M_AXI_AWLEN),
        .M_AXI_AWSIZE           (M_AXI_AWSIZE),
        .M_AXI_AWBURST          (M_AXI_AWBURST),
        .M_AXI_AWLOCK           (M_AXI_AWLOCK),
        .M_AXI_AWCACHE          (M_AXI_AWCACHE),
        .M_AXI_AWPROT           (M_AXI_AWPROT),
        .M_AXI_AWQOS            (M_AXI_AWQOS),
        .M_AXI_AWUSER           (M_AXI_AWUSER),
        .M_AXI_AWVALID          (M_AXI_AWVALID),

        //----------------------------------------------------------------------------------
        //  (W) Channel
        //----------------------------------------------------------------------------------
        .M_AXI_WREADY           (M_AXI_WREADY),
        .M_AXI_WDATA            (M_AXI_WDATA),
        .M_AXI_WSTRB            (M_AXI_WSTRB),
        .M_AXI_WLAST            (M_AXI_WLAST),
        .M_AXI_WUSER            (M_AXI_WUSER),
        .M_AXI_WVALID           (M_AXI_WVALID),

        //----------------------------------------------------------------------------------
        //  (B) Channel
        //----------------------------------------------------------------------------------
        .M_AXI_BID              (M_AXI_BID),
        .M_AXI_BRESP            (M_AXI_BRESP),
        .M_AXI_BUSER            (M_AXI_BUSER),
        .M_AXI_BVALID           (M_AXI_BVALID),
        .M_AXI_BREADY           (M_AXI_BREADY),

        //----------------------------------------------------------------------------------
        //  (AR) Channel
        //----------------------------------------------------------------------------------
        .M_AXI_ARREADY          (M_AXI_ARREADY),
        .M_AXI_ARID             (M_AXI_ARID),
        .M_AXI_ARADDR           (M_AXI_ARADDR),
        .M_AXI_ARLEN            (M_AXI_ARLEN),
        .M_AXI_ARSIZE           (M_AXI_ARSIZE),
        .M_AXI_ARBURST          (M_AXI_ARBURST),
        .M_AXI_ARLOCK           (M_AXI_ARLOCK),
        .M_AXI_ARCACHE          (M_AXI_ARCACHE),
        .M_AXI_ARPROT           (M_AXI_ARPROT),
        .M_AXI_ARQOS            (M_AXI_ARQOS),
        .M_AXI_ARUSER           (M_AXI_ARUSER),
        .M_AXI_ARVALID          (M_AXI_ARVALID),

        //----------------------------------------------------------------------------------
        //  (R) Channel
        //----------------------------------------------------------------------------------
        .M_AXI_RID              (M_AXI_RID),
        .M_AXI_RDATA            (M_AXI_RDATA),
        .M_AXI_RRESP            (M_AXI_RRESP),
        .M_AXI_RLAST            (M_AXI_RLAST),
        .M_AXI_RUSER            (M_AXI_RUSER),
        .M_AXI_RVALID           (M_AXI_RVALID),
        .M_AXI_RREADY           (M_AXI_RREADY),
        
        .Write_en               (Write_en),
        .Write_en_dff           (Write_en_dff),
        .main_state_WATCH       (main_state_WATCH),    
        .w_state_WATCH          (w_state_WATCH),
        .r_state_WATCH          (r_state_WATCH),
        .w_data_WATCH           (w_data_WATCH),
        .r_data_WATCH           (r_data_WATCH),
        .write_valid_count_56_WATCH (write_valid_count_56_WATCH),
        .choose_count           (choose_count),
        .cache_count            (cache_count),
        .lost_count             (lost_count),
        .assert_wready_wvalid   (assert_wready_wvalid),
        .write_valid_count      (write_valid_count),
        .output_buffer_0        (output_buffer_0),
        .output_buffer_1        (output_buffer_1),
        .output_buffer_2        (output_buffer_2),
        .output_buffer_3        (output_buffer_3)
    );
	// User logic ends

	endmodule
