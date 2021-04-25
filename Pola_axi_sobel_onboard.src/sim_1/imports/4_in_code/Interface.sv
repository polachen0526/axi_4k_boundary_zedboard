`timescale 1ns / 1ps

interface AXI_FULL (
    input   M_AXI_ACLK,
    input   M_AXI_ARESETN
);
    localparam C_M_AXI_ID_WIDTH	        = 1;
    localparam C_M_AXI_ADDR_WIDTH	    = 32;
    localparam C_M_AXI_DATA_WIDTH	    = 128;
    localparam C_M_AXI_AWUSER_WIDTH	    = 1;
    localparam C_M_AXI_ARUSER_WIDTH	    = 1;
    localparam C_M_AXI_WUSER_WIDTH	    = 1;
    localparam C_M_AXI_RUSER_WIDTH	    = 1;
    localparam C_M_AXI_BUSER_WIDTH	    = 1;

    // M_AXI-Full
    //----------------------------------------------------------------------------------
    //  (AW) Channel
    //----------------------------------------------------------------------------------
    logic                               M_AXI_AWREADY;
    logic  [C_M_AXI_ID_WIDTH-1 : 0]     M_AXI_AWID;
    logic  [C_M_AXI_ADDR_WIDTH-1 : 0]   M_AXI_AWADDR;
    logic  [7 : 0]                      M_AXI_AWLEN;
    logic  [2 : 0]                      M_AXI_AWSIZE;
    logic  [1 : 0]                      M_AXI_AWBURST;
    logic                               M_AXI_AWLOCK;
    logic  [3 : 0]                      M_AXI_AWCACHE;
    logic  [2 : 0]                      M_AXI_AWPROT;
    logic  [3 : 0]                      M_AXI_AWQOS;
    logic  [C_M_AXI_AWUSER_WIDTH-1 : 0] M_AXI_AWUSER;
    logic                               M_AXI_AWVALID;

    //----------------------------------------------------------------------------------
    //  (W) Channel
    //----------------------------------------------------------------------------------
    logic                                   M_AXI_WREADY;
    logic  [C_M_AXI_DATA_WIDTH-1 : 0]       M_AXI_WDATA;
    logic  [C_M_AXI_DATA_WIDTH/8-1 : 0]     M_AXI_WSTRB;
    logic                                   M_AXI_WLAST;
    logic  [C_M_AXI_WUSER_WIDTH-1 : 0]      M_AXI_WUSER;
    logic                                   M_AXI_WVALID;

    //----------------------------------------------------------------------------------
    //  (B) Channel
    //----------------------------------------------------------------------------------
    logic  [C_M_AXI_ID_WIDTH-1 : 0]     M_AXI_BID;
    logic  [1 : 0]                      M_AXI_BRESP;
    logic  [C_M_AXI_BUSER_WIDTH-1 : 0]  M_AXI_BUSER;
    logic                               M_AXI_BVALID;
    logic                               M_AXI_BREADY;

    //----------------------------------------------------------------------------------
    //  (AR) Channel
    //----------------------------------------------------------------------------------
    logic                                   M_AXI_ARREADY;
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
    logic  [C_M_AXI_ID_WIDTH-1 : 0]     M_AXI_RID;
    logic  [C_M_AXI_DATA_WIDTH-1 : 0]   M_AXI_RDATA;
    logic  [1 : 0]                      M_AXI_RRESP;
    logic                               M_AXI_RLAST;
    logic  [C_M_AXI_RUSER_WIDTH-1 : 0]  M_AXI_RUSER;
    logic                               M_AXI_RVALID;
    logic                               M_AXI_RREADY;

    modport master(
        //----------------------------------------------------------------------------------
        //  (AW) Channel
        //----------------------------------------------------------------------------------
        input   M_AXI_AWREADY,
        output  M_AXI_AWID,
        output  M_AXI_AWADDR,
        output  M_AXI_AWLEN,
        output  M_AXI_AWSIZE,
        output  M_AXI_AWBURST,
        output  M_AXI_AWLOCK,
        output  M_AXI_AWCACHE,
        output  M_AXI_AWPROT,
        output  M_AXI_AWQOS,
        output  M_AXI_AWUSER,
        output  M_AXI_AWVALID,

        //----------------------------------------------------------------------------------
        //  (W) Channel
        //----------------------------------------------------------------------------------
        input   M_AXI_WREADY,
        output  M_AXI_WDATA,
        output  M_AXI_WSTRB,
        output  M_AXI_WLAST,
        output  M_AXI_WUSER,
        output  M_AXI_WVALID,

        //----------------------------------------------------------------------------------
        //  (B) Channel
        //----------------------------------------------------------------------------------
        input   M_AXI_BID,
        input   M_AXI_BRESP,
        input   M_AXI_BUSER,
        input   M_AXI_BVALID,
        output  M_AXI_BREADY,

        //----------------------------------------------------------------------------------
        //  (AR) Channel
        //----------------------------------------------------------------------------------
        input   M_AXI_ARREADY,
        output  M_AXI_ARID,
        output  M_AXI_ARADDR,
        output  M_AXI_ARLEN,
        output  M_AXI_ARSIZE,
        output  M_AXI_ARBURST,
        output  M_AXI_ARLOCK,
        output  M_AXI_ARCACHE,
        output  M_AXI_ARPROT,
        output  M_AXI_ARQOS,
        output  M_AXI_ARUSER,
        output  M_AXI_ARVALID,

        //----------------------------------------------------------------------------------
        //  (R) Channel
        //----------------------------------------------------------------------------------
        input   M_AXI_RID,
        input   M_AXI_RDATA,
        input   M_AXI_RRESP,
        input   M_AXI_RLAST,
        input   M_AXI_RUSER,
        input   M_AXI_RVALID,
        output  M_AXI_RREADY
    );
    modport slave(
        input  M_AXI_ACLK,
        //----------------------------------------------------------------------------------
        //  (AW) Channel
        //----------------------------------------------------------------------------------
        output M_AXI_AWREADY,
        input  M_AXI_AWID,
        input  M_AXI_AWADDR,
        input  M_AXI_AWLEN,
        input  M_AXI_AWSIZE,
        input  M_AXI_AWBURST,
        input  M_AXI_AWLOCK,
        input  M_AXI_AWCACHE,
        input  M_AXI_AWPROT,
        input  M_AXI_AWQOS,
        input  M_AXI_AWUSER,
        input  M_AXI_AWVALID,

        //----------------------------------------------------------------------------------
        //  (W) Channel
        //----------------------------------------------------------------------------------
        output  M_AXI_WREADY,
        input   M_AXI_WDATA,
        input   M_AXI_WSTRB,
        input   M_AXI_WLAST,
        input   M_AXI_WUSER,
        input   M_AXI_WVALID,

        //----------------------------------------------------------------------------------
        //  (B) Channel
        //----------------------------------------------------------------------------------
        output  M_AXI_BID,
        output  M_AXI_BRESP,
        output  M_AXI_BUSER,
        output  M_AXI_BVALID,
        input   M_AXI_BREADY,

        //----------------------------------------------------------------------------------
        //  (AR) Channel
        //----------------------------------------------------------------------------------
        output   M_AXI_ARREADY,
        input    M_AXI_ARID,
        input    M_AXI_ARADDR,
        input    M_AXI_ARLEN,
        input    M_AXI_ARSIZE,
        input    M_AXI_ARBURST,
        input    M_AXI_ARLOCK,
        input    M_AXI_ARCACHE,
        input    M_AXI_ARPROT,
        input    M_AXI_ARQOS,
        input    M_AXI_ARUSER,
        input    M_AXI_ARVALID,

        //----------------------------------------------------------------------------------
        //  (R) Channel
        //----------------------------------------------------------------------------------
        input   M_AXI_RREADY,
        output  M_AXI_RID,
        output  M_AXI_RDATA,
        output  M_AXI_RRESP,
        output  M_AXI_RLAST,
        output  M_AXI_RUSER,
        output  M_AXI_RVALID
    );

    //modport master(input M_AXI_ACLK, clocking clk_master);
    //TODO: Need Clocking?
endinterface //interfacename