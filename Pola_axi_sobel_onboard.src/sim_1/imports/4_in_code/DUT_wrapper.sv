`timescale 1ns / 1ps

module DUT_wrapper #(
    parameter C_S_AXI_DATA_WIDTH    = 32,

    parameter C_M_AXI_ID_WIDTH	    = 1,
    parameter C_M_AXI_ADDR_WIDTH	= 32,
    parameter C_M_AXI_DATA_WIDTH	= 64,
    parameter C_M_AXI_AWUSER_WIDTH	= 1,
    parameter C_M_AXI_ARUSER_WIDTH	= 1,
    parameter C_M_AXI_WUSER_WIDTH	= 1,
    parameter C_M_AXI_RUSER_WIDTH	= 1,
    parameter C_M_AXI_BUSER_WIDTH	= 1
) (
    input                                    S_AXI_ACLK,
    input                                    S_AXI_ARESETN,
    output                                   IRQ,
    
    input                                    s_axi_start,
    input   [C_S_AXI_DATA_WIDTH-1:0]         s_axi_inst_0,
    input   [C_S_AXI_DATA_WIDTH-1:0]         s_axi_inst_1,
    input   [C_S_AXI_DATA_WIDTH-1:0]         s_axi_inst_2,
    input   [C_S_AXI_DATA_WIDTH-1:0]         s_axi_inst_3,
    input   [C_S_AXI_DATA_WIDTH-1:0]         s_axi_inst_4,
   
//    output [C_S_AXI_DATA_WIDTH-1:0]          s_axi_error,            //Trigger IRQ if error
    output [C_S_AXI_DATA_WIDTH-1:0]          s_axi_Rerror_addr,
    output [0:0]                             s_axi_Rerror,
    output [C_S_AXI_DATA_WIDTH-1:0]          s_axi_Werror_addr,
    output [1:0]                             s_axi_Werror,


    AXI_FULL.master mif
);
    /*
//----------------------------------------------------------------------------------
    //  (AW) Channel
    //----------------------------------------------------------------------------------
    logic  [C_M_AXI_ID_WIDTH-1 : 0]         M_AXI_AWID;
    logic  [C_M_AXI_ADDR_WIDTH-1 : 0]       M_AXI_AWADDR;
    logic  [7 : 0]                          M_AXI_AWLEN;
    logic  [2 : 0]                          M_AXI_AWSIZE;
    logic  [1 : 0]                          M_AXI_AWBURST;
    logic                                   M_AXI_AWLOCK;
    logic  [3 : 0]                          M_AXI_AWCACHE;
    logic  [2 : 0]                          M_AXI_AWPROT;
    logic  [3 : 0]                          M_AXI_AWQOS;
    logic  [C_M_AXI_AWUSER_WIDTH-1 : 0]     M_AXI_AWUSER;
    logic                                   M_AXI_AWVALID;

    //----------------------------------------------------------------------------------
    //  (W) Channel
    //----------------------------------------------------------------------------------
    logic  [C_M_AXI_DATA_WIDTH-1 : 0]       M_AXI_WDATA;
    logic  [C_M_AXI_DATA_WIDTH/8-1 : 0]     M_AXI_WSTRB;
    logic                                   M_AXI_WLAST;
    logic  [C_M_AXI_WUSER_WIDTH-1 : 0]      M_AXI_WUSER;
    logic                                   M_AXI_WVALID;

    //----------------------------------------------------------------------------------
    //  (B) Channel
    //----------------------------------------------------------------------------------
    logic                                   M_AXI_BREADY;

    //----------------------------------------------------------------------------------
    //  (AR) Channel
    //----------------------------------------------------------------------------------
    logic  [C_M_AXI_ID_WIDTH-1 : 0]         M_AXI_ARID;
    logic  [C_M_AXI_ADDR_WIDTH-1 : 0]       M_AXI_ARADDR;
    logic  [7 : 0]                          M_AXI_ARLEN;
    logic  [2 : 0]                          M_AXI_ARSIZE;
    logic  [1 : 0]                          M_AXI_ARBURST;
    logic                                   M_AXI_ARLOCK;
    logic  [3 : 0]                          M_AXI_ARCACHE;
    logic  [2 : 0]                          M_AXI_ARPROT;
    logic  [3 : 0]                          M_AXI_ARQOS;
    logic  [C_M_AXI_ARUSER_WIDTH-1 : 0]     M_AXI_ARUSER;
    logic                                   M_AXI_ARVALID;

    //----------------------------------------------------------------------------------
    //  (R) Channel
    //----------------------------------------------------------------------------------
    logic                                   M_AXI_RREADY;

    
    always@(posedge mif.M_AXI_ACLK) begin
        mif.clk_master.M_AXI_AWID      <= M_AXI_AWID;
        mif.clk_master.M_AXI_AWADDR    <= M_AXI_AWADDR;
        mif.clk_master.M_AXI_AWLEN     <= M_AXI_AWLEN;
        mif.clk_master.M_AXI_AWSIZE    <= M_AXI_AWSIZE;
        mif.clk_master.M_AXI_AWBURST   <= M_AXI_AWBURST;
        mif.clk_master.M_AXI_AWLOCK    <= M_AXI_AWLOCK;
        mif.clk_master.M_AXI_AWCACHE   <= M_AXI_AWCACHE;
        mif.clk_master.M_AXI_AWPROT    <= M_AXI_AWPROT;
        mif.clk_master.M_AXI_AWQOS     <= M_AXI_AWQOS;
        mif.clk_master.M_AXI_AWUSER    <= M_AXI_AWUSER;
        mif.clk_master.M_AXI_AWVALID   <= M_AXI_AWVALID;
        mif.clk_master.M_AXI_WDATA     <= M_AXI_WDATA;
        mif.clk_master.M_AXI_WSTRB     <= M_AXI_WSTRB;
        mif.clk_master.M_AXI_WLAST     <= M_AXI_WLAST;
        mif.clk_master.M_AXI_WUSER     <= M_AXI_WUSER;
        mif.clk_master.M_AXI_WVALID    <= M_AXI_WVALID;
        mif.clk_master.M_AXI_BREADY    <= M_AXI_BREADY;
        mif.clk_master.M_AXI_ARID      <= M_AXI_ARID;
        mif.clk_master.M_AXI_ARADDR    <= M_AXI_ARADDR;
        mif.clk_master.M_AXI_ARLEN     <= M_AXI_ARLEN;
        mif.clk_master.M_AXI_ARSIZE    <= M_AXI_ARSIZE;
        mif.clk_master.M_AXI_ARBURST   <= M_AXI_ARBURST;
        mif.clk_master.M_AXI_ARLOCK    <= M_AXI_ARLOCK;
        mif.clk_master.M_AXI_ARCACHE   <= M_AXI_ARCACHE;
        mif.clk_master.M_AXI_ARPROT    <= M_AXI_ARPROT;
        mif.clk_master.M_AXI_ARQOS     <= M_AXI_ARQOS;
        mif.clk_master.M_AXI_ARUSER    <= M_AXI_ARUSER;
        mif.clk_master.M_AXI_ARVALID   <= M_AXI_ARVALID;
        mif.clk_master.M_AXI_RREADY    <= M_AXI_RREADY;
    end
    */

    CNN u_CNN (
        //S_AXI-Lite
        .S_AXI_ACLK             (S_AXI_ACLK),
        .IRQ                    (IRQ),

        .s_axi_start            (s_axi_start),
        .s_axi_inst_0           (s_axi_inst_0),
        .s_axi_inst_1           (s_axi_inst_1),
        .s_axi_inst_2           (s_axi_inst_2),
        .s_axi_inst_3           (s_axi_inst_3),
        .s_axi_inst_4           (s_axi_inst_4),
//        .s_axi_error            (s_axi_error),            //Trigger IRQ if error
        .s_axi_Rerror(s_axi_Rerror),            //Trigger IRQ if error
        .s_axi_Rerror_addr(s_axi_Rerror_addr),
        .s_axi_Werror(s_axi_Werror),            //Trigger IRQ if error
        .s_axi_Werror_addr(s_axi_Werror_addr),        

        // M_AXI-Full
        .M_AXI_ACLK             (S_AXI_ACLK),
        .M_AXI_ARESETN          (S_AXI_ARESETN),
        //----------------------------------------------------------------------------------
        //  (AW) Channel
        //----------------------------------------------------------------------------------
        .M_AXI_AWREADY          (mif.M_AXI_AWREADY),
        .M_AXI_AWID             (mif.M_AXI_AWID),
        .M_AXI_AWADDR           (mif.M_AXI_AWADDR),
        .M_AXI_AWLEN            (mif.M_AXI_AWLEN),
        .M_AXI_AWSIZE           (mif.M_AXI_AWSIZE),
        .M_AXI_AWBURST          (mif.M_AXI_AWBURST),
        .M_AXI_AWLOCK           (mif.M_AXI_AWLOCK),
        .M_AXI_AWCACHE          (mif.M_AXI_AWCACHE),
        .M_AXI_AWPROT           (mif.M_AXI_AWPROT),
        .M_AXI_AWQOS            (mif.M_AXI_AWQOS),
        .M_AXI_AWUSER           (mif.M_AXI_AWUSER),
        .M_AXI_AWVALID          (mif.M_AXI_AWVALID),

        //----------------------------------------------------------------------------------
        //  (W) Channel
        //----------------------------------------------------------------------------------
        .M_AXI_WREADY           (mif.M_AXI_WREADY),
        .M_AXI_WDATA            (mif.M_AXI_WDATA),
        .M_AXI_WSTRB            (mif.M_AXI_WSTRB),
        .M_AXI_WLAST            (mif.M_AXI_WLAST),
        .M_AXI_WUSER            (mif.M_AXI_WUSER),
        .M_AXI_WVALID           (mif.M_AXI_WVALID),

        //----------------------------------------------------------------------------------
        //  (B) Channel
        //----------------------------------------------------------------------------------
        .M_AXI_BID              (mif.M_AXI_BID),
        .M_AXI_BRESP            (mif.M_AXI_BRESP),
        .M_AXI_BUSER            (mif.M_AXI_BUSER),
        .M_AXI_BVALID           (mif.M_AXI_BVALID),
        .M_AXI_BREADY           (mif.M_AXI_BREADY),

        //----------------------------------------------------------------------------------
        //  (AR) Channel
        //----------------------------------------------------------------------------------
        .M_AXI_ARREADY          (mif.M_AXI_ARREADY),
        .M_AXI_ARID             (mif.M_AXI_ARID),
        .M_AXI_ARADDR           (mif.M_AXI_ARADDR),
        .M_AXI_ARLEN            (mif.M_AXI_ARLEN),
        .M_AXI_ARSIZE           (mif.M_AXI_ARSIZE),
        .M_AXI_ARBURST          (mif.M_AXI_ARBURST),
        .M_AXI_ARLOCK           (mif.M_AXI_ARLOCK),
        .M_AXI_ARCACHE          (mif.M_AXI_ARCACHE),
        .M_AXI_ARPROT           (mif.M_AXI_ARPROT),
        .M_AXI_ARQOS            (mif.M_AXI_ARQOS),
        .M_AXI_ARUSER           (mif.M_AXI_ARUSER),
        .M_AXI_ARVALID          (mif.M_AXI_ARVALID),

        //----------------------------------------------------------------------------------
        //  (R) Channel
        //----------------------------------------------------------------------------------
        .M_AXI_RID              (mif.M_AXI_RID),
        .M_AXI_RDATA            (mif.M_AXI_RDATA),
        .M_AXI_RRESP            (mif.M_AXI_RRESP),
        .M_AXI_RLAST            (mif.M_AXI_RLAST),
        .M_AXI_RUSER            (mif.M_AXI_RUSER),
        .M_AXI_RVALID           (mif.M_AXI_RVALID),
        .M_AXI_RREADY           (mif.M_AXI_RREADY)
    );
 
endmodule