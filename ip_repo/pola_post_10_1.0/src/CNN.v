`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/10/15 15:06:24
// Design Name: 
// Module Name: CNN
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


module CNN #(
    parameter WORD_SIZE = 16,
    parameter OUT_WORD_SIZE = 36,
    parameter INTEGER = 32,
    parameter EIGHT_WORD_SIZE = 128,
    parameter OFF_TO_ON_ADDRESS_SIZE = 13, // 1156 (Dec) 484(hex) 0100 1000 0100(bin) 
    parameter ON_TO_OFF_ADDRESS_SIZE = 10,
    
    parameter C_S_AXI_DATA_WIDTH = 32,
    parameter C_M_AXI_ID_WIDTH	    = 1,
    parameter C_M_AXI_ADDR_WIDTH	= 32,
    parameter C_M_AXI_DATA_WIDTH	= 64,
    parameter C_M_AXI_AWUSER_WIDTH	= 1,
    parameter C_M_AXI_ARUSER_WIDTH	= 1,
    parameter C_M_AXI_WUSER_WIDTH	= 1,
    parameter C_M_AXI_RUSER_WIDTH	= 1,
    parameter C_M_AXI_BUSER_WIDTH	= 1,
    parameter IDLE         = 2'b00,
    parameter PROCESS_DATA = 2'b01,
    parameter READ_DATA    = 2'b01,
    parameter WRITE_DATA   = 2'b01,
    parameter pipeline_num = 1'b1,
    parameter MAIN_FINISH  = 2'b10
)(
    input                                    S_AXI_ACLK,    // use M_AXI_ACLK
    output                                   IRQ,

    input                                    s_axi_start,
    input   [C_S_AXI_DATA_WIDTH-1:0]         s_axi_inst_0,  //input_addr
    input   [C_S_AXI_DATA_WIDTH-1:0]         s_axi_inst_1,  //output_addr
    input   [C_S_AXI_DATA_WIDTH-1:0]         s_axi_inst_2,  
    input   [C_S_AXI_DATA_WIDTH-1:0]         s_axi_inst_3,
    input   [C_S_AXI_DATA_WIDTH-1:0]         s_axi_inst_4,
    
    output                                   s_axi_Rerror,            //Trigger IRQ if error
    output  [C_S_AXI_DATA_WIDTH-1:0]         s_axi_Rerror_addr,
    output  [1 : 0]                          s_axi_Werror,            //Trigger IRQ if error
    output  [C_S_AXI_DATA_WIDTH-1:0]         s_axi_Werror_addr,
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
        //dispaly the signal to ila;
    output                                   Write_en,
    output reg                               Write_en_dff,
    output [1:0]                             main_state_WATCH,
    output [1:0]                             w_state_WATCH,
    output [1:0]                             r_state_WATCH,
    output [63:0]                            w_data_WATCH,
    output [63:0]                            r_data_WATCH   
    );

    assign s_axi_Rerror = 0;            //Trigger IRQ if error
    assign s_axi_Rerror_addr = 0;
    assign s_axi_Werror = 0;            //Trigger IRQ if error
    assign s_axi_Werror_addr = 0;
    assign M_AXI_BREADY  = 1'b1;

    wire rst = M_AXI_ARESETN;
    /*
        reg s_axi_start_buffer;

        always@(posedge S_AXI_ACLK)begin
            if(!M_AXI_ARESETN)
                s_axi_start_buffer <= 1'b0;
            else
                s_axi_start_buffer <= s_axi_start;
        end

        wire rst = !s_axi_start_buffer || !M_AXI_ARESETN;
    */
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
    reg [7:0] count;

    always@(posedge M_AXI_ACLK)begin 
        if(rst)
            count <= 9'd0;
        else
            count <= count + 1'd1;
    end

    //assign     IRQ = (count == 9'hff) ? 1'd1 : 1'd0; //always be high
//----------------------write your code in here-------------------\\
    reg [1:0]Current_state,Next_state;
    reg [1:0]CREAD_state,NREAD_state;
    reg [1:0]CWRITE_state,NWRITE_state;
    // reg [C_S_AXI_DATA_WIDTH-1:0] input_addr;
    // reg [C_S_AXI_DATA_WIDTH-1:0] output_addr;
    reg [C_M_AXI_DATA_WIDTH-1:0] SRAM [0:9];
    reg [C_M_AXI_DATA_WIDTH-1:0] M_AXI_WDATA_temp;
    // reg [7:0] input_addr_length,output_addr_length;
    reg PROCESS_FINI;
    reg en_axi_arvalid;
    reg en_axi_rcount;
    reg en_axi_awvalid;
    reg en_axi_wcount;
    reg [4:0]Write_count;
    reg [4:0]SRAM_count;
    reg [3:0]p_count;
    //wire Write_en;
    //reg Write_en_dff;


    assign IRQ = (Current_state==MAIN_FINISH && s_axi_start) ? 1 : 0;
    assign M_AXI_ARVALID = en_axi_arvalid; //throw data to init the value;
    assign M_AXI_AWVALID = en_axi_awvalid;

    assign M_AXI_WVALID  = Write_en && Write_en_dff && !M_AXI_AWVALID;
    assign M_AXI_RREADY  = M_AXI_RVALID;
    assign M_AXI_ARADDR  = s_axi_inst_0;
    assign M_AXI_ARLEN   = s_axi_inst_2;
    assign M_AXI_AWADDR  = s_axi_inst_1;
    assign M_AXI_AWLEN   = s_axi_inst_2;
    assign M_AXI_WLAST   = (Write_count == s_axi_inst_2+1 && M_AXI_WVALID) ? 1 : 0; //if the post_number==3 then the write_count = post_number+1,zero is a nubmer
    assign M_AXI_WDATA   = M_AXI_WDATA_temp;
    assign Write_en      = (pipeline_num==p_count && SRAM_count != 0) ? 1 : 0;
    
    assign main_state_WATCH = Current_state;
    assign w_state_WATCH = CWRITE_state;
    assign r_state_WATCH = CREAD_state;
    assign w_data_WATCH = M_AXI_WDATA_temp;
    assign r_data_WATCH = M_AXI_RDATA;
    //-------------------------------r_valid----------------------
    always@(posedge M_AXI_ACLK)begin
        if(rst)
            en_axi_arvalid <= 1'b0;
        else
            en_axi_arvalid <= (en_axi_arvalid) ? 1'b0 : ((CREAD_state==READ_DATA) && (en_axi_rcount < 1) && M_AXI_ARREADY==1);
    end

    always@(posedge M_AXI_ACLK)begin
        if(CREAD_state==IDLE)
            en_axi_rcount <= 0;
        else if(en_axi_arvalid == 1'b1)
            en_axi_rcount <= en_axi_rcount + 1;
        else 
            en_axi_rcount <= en_axi_rcount;
    end
    //-------------------------------w_valid----------------------
    always@(posedge M_AXI_ACLK)begin
        if(rst)
            en_axi_awvalid <= 1'b0;
        else
            en_axi_awvalid <= (en_axi_awvalid) ? 1'b0 : ((CWRITE_state==WRITE_DATA) && (en_axi_wcount < 1) && M_AXI_AWREADY==1);
    end

    always@(posedge M_AXI_ACLK)begin
        if(CWRITE_state==IDLE)
            en_axi_wcount <= 0;
        else if(en_axi_awvalid == 1'b1)
            en_axi_wcount <= en_axi_wcount + 1;
        else 
            en_axi_wcount <= en_axi_wcount;
    end
    //--------------------------main_FSM---------------------------
    always@(posedge M_AXI_ACLK)begin
        if(rst)
            Current_state <= IDLE;
        else
            Current_state <= Next_state;
    end

    always@(posedge M_AXI_ACLK)begin
        if(rst)
            CREAD_state <= IDLE;
        else
            CREAD_state <= NREAD_state;
    end

    always@(posedge M_AXI_ACLK)begin
        if(rst)
            CWRITE_state <= IDLE;
        else
            CWRITE_state <= NWRITE_state; 
    end
    //---------------------------------------------------------------
    always@(*)begin : main_state
        case (Current_state)
            IDLE    :   begin
                if(s_axi_start)   Next_state = PROCESS_DATA;
                else              Next_state = IDLE;
            end
            PROCESS_DATA    :   begin
                if(PROCESS_FINI)  Next_state = MAIN_FINISH;
                else              Next_state = PROCESS_DATA; //keep state
            end
            MAIN_FINISH     :   begin
                Next_state = MAIN_FINISH;
            end
            default: Next_state = IDLE;
        endcase
    end

    always@(posedge M_AXI_ACLK)begin
        case (Current_state)
            IDLE    :   begin
                PROCESS_FINI <= 1'b0;
            end
            PROCESS_DATA    :   begin
                PROCESS_FINI <= Write_count == s_axi_inst_2+1 ? 1 : 0;
            end
            MAIN_FINISH     :   begin
                PROCESS_FINI <= 1'b1;
            end
            default: PROCESS_FINI <= 1'b0;
        endcase
    end
    //-------------------------read_CH--------------------------------------
    always@(*)begin : READ_state
        case (CREAD_state)
            IDLE    :   begin
                if(Current_state==PROCESS_DATA && !IRQ)                   NREAD_state = READ_DATA;
                else                                                      NREAD_state = IDLE;
            end 
            READ_DATA   :   begin
                if(M_AXI_RLAST && M_AXI_RVALID && M_AXI_RREADY)           NREAD_state = IDLE;
                else                                                      NREAD_state = READ_DATA;
            end
            default: NREAD_state = IDLE;
        endcase
    end

    always@(posedge M_AXI_ACLK)begin
        // input_addr             <= (M_AXI_ARREADY /*&& M_AXI_ARVALID*/) ? s_axi_inst_0 : 32'b0;
        // input_addr_length      <= (M_AXI_ARREADY /*&& M_AXI_ARVALID*/) ? s_axi_inst_2 : 8'b0;
        SRAM_count             <= (rst) ? 0 : (Write_count==s_axi_inst_2+1) ? 0 : (M_AXI_RVALID && M_AXI_RREADY) ? SRAM_count + 1  : SRAM_count;
        SRAM[SRAM_count]       <= (M_AXI_RVALID && M_AXI_RREADY) ? M_AXI_RDATA : 64'b0;    
    end
    //--------------------------------write_CH-----------------------------
    always@(*)begin
        case(CWRITE_state)
            IDLE    :   begin
                if(Current_state==PROCESS_DATA && !IRQ) NWRITE_state = WRITE_DATA;
                else                                    NWRITE_state = IDLE;
            end
            WRITE_DATA  :   begin
                if(M_AXI_WLAST)                         NWRITE_state = IDLE;
                else                                    NWRITE_state = WRITE_DATA;
            end
            default:    NWRITE_state = IDLE;
        endcase
    end
    
    always@(posedge M_AXI_ACLK)begin
        // output_addr             <= (M_AXI_AWREADY /*&& M_AXI_ARVALID*/) ? s_axi_inst_1 : 32'b0;
        // output_addr_length      <= (M_AXI_AWREADY /*&& M_AXI_ARVALID*/) ? s_axi_inst_2 : 8'b0;
        Write_en_dff            <= Write_en; // delay one clk
        Write_count             <= (CWRITE_state==IDLE) ? 0 : (Write_en && Write_count<s_axi_inst_2+1) ? Write_count+1 : Write_count;
        M_AXI_WDATA_temp        <= (Write_en && Write_count<s_axi_inst_2+1) ? SRAM[Write_count] : 64'b0;
    end
    //------------------------------p_count----------------------------
    always @(posedge M_AXI_ACLK) begin
        case (CWRITE_state)
            IDLE    :   begin
                p_count <= 0;
            end
            WRITE_DATA  :   begin
                p_count <= (p_count==pipeline_num) ? p_count : p_count+1;
            end
            default: p_count <= 0;
        endcase
    end
//----------------------------------------------------------------\\
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
    
  //  wire rst = !s_axi_start && !M_AXI_ARESETN;
    
        //  (AW) Channel
    assign M_AXI_AWID       = {C_M_AXI_ID_WIDTH{1'b0}};         //Unused
    assign M_AXI_AWSIZE 	= 3'd3;     //clogb2((C_M_AXI_DATA_WIDTH/8)-1);
    assign M_AXI_AWBURST	= 2'd1;     //INCR Mode
    assign M_AXI_AWCACHE	= 4'd0;     //???
	assign M_AXI_AWPROT	    = 3'd0;     //???
    assign M_AXI_AWLOCK     = 1'd0;     //No need to lock bus
    assign M_AXI_AWQOS	    = 4'd0;     //Let QoS be default
    assign M_AXI_AWUSER	    = {C_M_AXI_AWUSER_WIDTH{1'b0}};     //Unused

    //Unused Write
    //  Set AW_CHANNEL
    // assign M_AXI_AWADDR  = {C_M_AXI_ADDR_WIDTH{1'b0}};
    // assign M_AXI_AWVALID = 1'b0;
    // assign M_AXI_AWLEN   = 7'd0;

    //  (W)  Channel
	assign M_AXI_WSTRB	    = {(C_M_AXI_DATA_WIDTH/8){1'b1}};   //All bytes are effectual
    assign M_AXI_WUSER	    = {C_M_AXI_WUSER_WIDTH{1'b0}};      //Unused

    //Unused Write
    //  Set W CHANNEL
    // assign M_AXI_WDATA   = {C_M_AXI_DATA_WIDTH{1'b0}};
    // assign M_AXI_WSTRB   = {(C_M_AXI_DATA_WIDTH/8){1'b0}};
    // assign M_AXI_WLAST   = 1'b0;
    // assign M_AXI_WVALID  = 1'b0;

    //  (B)  Channel 
    //assign M_AXI_BREADY  = 1'b0;

    //  (AR) Channel
    assign M_AXI_ARID	    = {C_M_AXI_ID_WIDTH{1'b0}};         //Unused
    assign M_AXI_ARSIZE 	= 3'd3;     //clogb2((C_M_AXI_DATA_WIDTH/8)-1);
	assign M_AXI_ARBURST	= 2'd1;     //INCR Mode
	assign M_AXI_ARLOCK	    = 1'd0;     //No need to lock bus
	assign M_AXI_ARCACHE	= 4'd0;     //???
	assign M_AXI_ARPROT	    = 3'd0;     //???
	assign M_AXI_ARQOS	    = 4'd0;     //Let QoS be default
	assign M_AXI_ARUSER	    = {C_M_AXI_ARUSER_WIDTH{1'b0}};     //Unused

	
endmodule
