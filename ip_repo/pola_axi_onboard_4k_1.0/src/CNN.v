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
    parameter WORD_SIZE                 = 16,
    parameter OUT_WORD_SIZE             = 36,
    parameter INTEGER                   = 32,
    parameter EIGHT_WORD_SIZE           = 128,
    parameter OFF_TO_ON_ADDRESS_SIZE    = 13, // 1156 (Dec) 484(hex) 0100 1000 0100(bin) 
    parameter ON_TO_OFF_ADDRESS_SIZE    = 10,
    
    parameter C_S_AXI_DATA_WIDTH        = 32,
    parameter C_M_AXI_ID_WIDTH	        = 1,
    parameter C_M_AXI_ADDR_WIDTH	    = 32,
    parameter C_M_AXI_DATA_WIDTH	    = 64,
    parameter C_M_AXI_AWUSER_WIDTH	    = 1,
    parameter C_M_AXI_ARUSER_WIDTH	    = 1,
    parameter C_M_AXI_WUSER_WIDTH	    = 1,
    parameter C_M_AXI_RUSER_WIDTH	    = 1,
    parameter C_M_AXI_BUSER_WIDTH	    = 1,
    parameter IDLE                      = 2'b00, //current state 4 case
    parameter INST_DATA                 = 2'b01, //current state 4 case
    parameter PROCESS_DATA              = 2'b10, //current state 4 case
    parameter MAIN_FINISH               = 2'b11, //current state 4 case
    parameter READ_DATA                 = 2'b01,
    parameter WRITE_DATA                = 2'b01,
    parameter sram_ctl_1                = 3'b001,
    parameter sram_ctl_2                = 3'b010,
    parameter sram_ctl_3                = 3'b011,
    parameter sram_ctl_keeping          = 3'b100,
    parameter read_sram_reg             = 8'he2,
    parameter write_sram_reg            = 8'h10,
    parameter sram_output_reg           = 8'he0,
    parameter twok_bundary              = 16'h800,
    parameter fourk_bundary             = 16'h1000
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
    output                                   sram_write_signal_en_1,    //new instruction 
    output                                   sram_write_signal_en_2,    //new instruction 
    output                                   sram_write_signal_en_3,    //new instruction 
    output                                   INST_DATA_FINISH,  //new instruction              
    output [1:0]                             main_state_WATCH,
    output [1:0]                             w_state_WATCH,
    output [1:0]                             r_state_WATCH,
    output [63:0]                            w_data_WATCH,
    output [63:0]                            r_data_WATCH,
    output [7:0]                             write_valid_count_56_WATCH,
    output reg [4:0] choose_count,cache_count,lost_count,
    output reg assert_wready_wvalid,
    output reg [31:0]write_valid_count,
    output [63:0]output_buffer_0,
    output [63:0]output_buffer_1,
    output [63:0]output_buffer_2,
    output [63:0]output_buffer_3
    );
    reg  [63:0]output_buffer[0:15];
    assign output_buffer_0  = output_buffer[0];
    assign output_buffer_1  = output_buffer[1];
    assign output_buffer_2  = output_buffer[2];
    assign output_buffer_3  = output_buffer[3];

    assign s_axi_Rerror = 0;            //Trigger IRQ if error
    assign s_axi_Rerror_addr = 0;
    assign s_axi_Werror = 0;            //Trigger IRQ if error
    assign s_axi_Werror_addr = 0;
    assign M_AXI_BREADY  = 1'b1;
    

    //-----------------sram----------------------------
    reg  [7:0]sram_addr,output_sram_addr,output_sram_addr_checkpoint;
    wire signed[15:0]B_third_addr_level_stage,G_third_addr_level_stage,R_third_addr_level_stage,U_third_addr_level_stage;
    wire [15:0]B1_dataout,B2_dataout,B3_dataout;
    wire [15:0]G1_dataout,G2_dataout,G3_dataout;
    wire [15:0]R1_dataout,R2_dataout,R3_dataout;
    wire [15:0]U1_dataout,U2_dataout,U3_dataout;
    wire write_output_sram_en;
    wire [15:0]sram224_write_input_sram_data;
    wire [63:0]M_AXI_WDATA_pre_wire;
    reg  [63:0]M_AXI_WDATA_pre_reg;
    //reg  [63:0]output_buffer[0:15];
    reg  signed [17:0]sram224_write_input_sram_data_pre;
    POLA_SRAM_SINGLE_226  M1_1(.clka(M_AXI_ACLK) , .wea(sram_write_signal_en_1) , .addra(sram_addr) , .dina(M_AXI_RDATA[15:0] ),.douta(B1_dataout));
    POLA_SRAM_SINGLE_226  M1_2(.clka(M_AXI_ACLK) , .wea(sram_write_signal_en_2) , .addra(sram_addr) , .dina(M_AXI_RDATA[15:0] ),.douta(B2_dataout));
    POLA_SRAM_SINGLE_226  M1_3(.clka(M_AXI_ACLK) , .wea(sram_write_signal_en_3) , .addra(sram_addr) , .dina(M_AXI_RDATA[15:0] ),.douta(B3_dataout));
    POLA_SRAM_SINGLE_226  M2_1(.clka(M_AXI_ACLK) , .wea(sram_write_signal_en_1) , .addra(sram_addr) , .dina(M_AXI_RDATA[31:16]),.douta(G1_dataout));
    POLA_SRAM_SINGLE_226  M2_2(.clka(M_AXI_ACLK) , .wea(sram_write_signal_en_2) , .addra(sram_addr) , .dina(M_AXI_RDATA[31:16]),.douta(G2_dataout));
    POLA_SRAM_SINGLE_226  M2_3(.clka(M_AXI_ACLK) , .wea(sram_write_signal_en_3) , .addra(sram_addr) , .dina(M_AXI_RDATA[31:16]),.douta(G3_dataout));
    POLA_SRAM_SINGLE_226  M3_1(.clka(M_AXI_ACLK) , .wea(sram_write_signal_en_1) , .addra(sram_addr) , .dina(M_AXI_RDATA[47:32]),.douta(R1_dataout));
    POLA_SRAM_SINGLE_226  M3_2(.clka(M_AXI_ACLK) , .wea(sram_write_signal_en_2) , .addra(sram_addr) , .dina(M_AXI_RDATA[47:32]),.douta(R2_dataout));
    POLA_SRAM_SINGLE_226  M3_3(.clka(M_AXI_ACLK) , .wea(sram_write_signal_en_3) , .addra(sram_addr) , .dina(M_AXI_RDATA[47:32]),.douta(R3_dataout));
    POLA_SRAM_SINGLE_226  M4_1(.clka(M_AXI_ACLK) , .wea(sram_write_signal_en_1) , .addra(sram_addr) , .dina(M_AXI_RDATA[63:48]),.douta(U1_dataout));
    POLA_SRAM_SINGLE_226  M4_2(.clka(M_AXI_ACLK) , .wea(sram_write_signal_en_2) , .addra(sram_addr) , .dina(M_AXI_RDATA[63:48]),.douta(U2_dataout));
    POLA_SRAM_SINGLE_226  M4_3(.clka(M_AXI_ACLK) , .wea(sram_write_signal_en_3) , .addra(sram_addr) , .dina(M_AXI_RDATA[63:48]),.douta(U3_dataout));
    POLA_OUTPUT_SRAM_SINGLE_224 Mout(.clka(M_AXI_ACLK) , .wea(write_output_sram_en) , .addra(output_sram_addr) , .dina(sram224_write_input_sram_data),.douta(M_AXI_WDATA_pre_wire));
       
    //-------------------------------------------------

    wire rst = M_AXI_ARESETN;//if you want make a ip use this!!
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

//----------------------write your code in here-------------------\\
    reg [1:0]Current_state,Next_state;
    reg [1:0]CREAD_state,NREAD_state;
    reg [1:0]CWRITE_state,NWRITE_state;
    reg [2:0]CSram_write_ctl_state,NSram_write_ctl_state;
    reg PROCESS_FINI;
    reg [8:0]calc_result_counter;
    reg en_axi_arvalid;
    reg en_axi_rcount;
    reg en_axi_awvalid;
    reg en_axi_wcount;
    reg [7:0]Write_count;
    reg [10:0]read_sram_width,write_sram_width,current_wirte_sram_width;
    reg read_sram_width_lock,write_sram_width_lock;
    reg INST_DATA_FINISH_keep;
    reg [7:0] pre_AWLEN;
    reg [7:0] write_valid_count_56;
    reg [31:0]pre_AWADDR;
    //reg assert_wready_wvalid;
    //reg [4:0] choose_count,cache_count,lost_count;
    reg [C_M_AXI_ADDR_WIDTH-1 : 0] pre_M_AXI_ARADDR,pre_M_AXI_AWADDR;
    reg signed [8:0]B_LineBuffer_value_1,G_LineBuffer_value_1,R_LineBuffer_value_1,U_LineBuffer_value_1;
    reg signed [8:0]B_LineBuffer_value_2,G_LineBuffer_value_2,R_LineBuffer_value_2,U_LineBuffer_value_2;
    reg signed [8:0]B_LineBuffer_value_3,G_LineBuffer_value_3,R_LineBuffer_value_3,U_LineBuffer_value_3;
    reg signed [8:0]B_LineBuffer_value_4,G_LineBuffer_value_4,R_LineBuffer_value_4,U_LineBuffer_value_4;
    reg signed [8:0]B_LineBuffer_value_5,G_LineBuffer_value_5,R_LineBuffer_value_5,U_LineBuffer_value_5;
    reg signed [8:0]B_LineBuffer_value_6,G_LineBuffer_value_6,R_LineBuffer_value_6,U_LineBuffer_value_6;
    reg signed [8:0]B_LineBuffer_value_7,G_LineBuffer_value_7,R_LineBuffer_value_7,U_LineBuffer_value_7;
    reg signed [8:0]B_LineBuffer_value_8,G_LineBuffer_value_8,R_LineBuffer_value_8,U_LineBuffer_value_8;
    reg signed [8:0]B_LineBuffer_value_9,G_LineBuffer_value_9,R_LineBuffer_value_9,U_LineBuffer_value_9;
    wire signed[2:0]kernel_weight_v_0,kernel_weight_h_0,kernel_weight_0;
    wire signed[2:0]kernel_weight_v_1,kernel_weight_h_1,kernel_weight_1;
    wire signed[2:0]kernel_weight_v_2,kernel_weight_h_2,kernel_weight_2;
    wire signed[2:0]kernel_weight_v_3,kernel_weight_h_3,kernel_weight_3;
    wire signed[2:0]kernel_weight_v_4,kernel_weight_h_4,kernel_weight_4;
    wire signed[2:0]kernel_weight_v_5,kernel_weight_h_5,kernel_weight_5;
    wire signed[2:0]kernel_weight_v_6,kernel_weight_h_6,kernel_weight_6;
    wire signed[2:0]kernel_weight_v_7,kernel_weight_h_7,kernel_weight_7;
    wire signed[2:0]kernel_weight_v_8,kernel_weight_h_8,kernel_weight_8;
    wire check_raddr_times,check_waddr_times;
    wire wlen_post_finish;
    //integer write_valid_count;
    pipeline_CALC B_CALC(
            .M_AXI_ACLK(M_AXI_ACLK),
            .Current_state(Current_state),
            .LineBuffer_value1(B_LineBuffer_value_1),
            .LineBuffer_value2(B_LineBuffer_value_2),
            .LineBuffer_value3(B_LineBuffer_value_3),
            .LineBuffer_value4(B_LineBuffer_value_4),
            .LineBuffer_value5(B_LineBuffer_value_5),
            .LineBuffer_value6(B_LineBuffer_value_6),
            .LineBuffer_value7(B_LineBuffer_value_7),
            .LineBuffer_value8(B_LineBuffer_value_8),
            .LineBuffer_value9(B_LineBuffer_value_9),
            .kernel_weight_1(kernel_weight_0),
            .kernel_weight_2(kernel_weight_1),
            .kernel_weight_3(kernel_weight_2),
            .kernel_weight_4(kernel_weight_3),
            .kernel_weight_5(kernel_weight_4),
            .kernel_weight_6(kernel_weight_5),
            .kernel_weight_7(kernel_weight_6),
            .kernel_weight_8(kernel_weight_7),
            .kernel_weight_9(kernel_weight_8),
            .third_addr_level_stage(B_third_addr_level_stage)
        ),G_CALC(
            .M_AXI_ACLK(M_AXI_ACLK),
            .Current_state(Current_state),
            .LineBuffer_value1(G_LineBuffer_value_1),
            .LineBuffer_value2(G_LineBuffer_value_2),
            .LineBuffer_value3(G_LineBuffer_value_3),
            .LineBuffer_value4(G_LineBuffer_value_4),
            .LineBuffer_value5(G_LineBuffer_value_5),
            .LineBuffer_value6(G_LineBuffer_value_6),
            .LineBuffer_value7(G_LineBuffer_value_7),
            .LineBuffer_value8(G_LineBuffer_value_8),
            .LineBuffer_value9(G_LineBuffer_value_9),
            .kernel_weight_1(kernel_weight_0),
            .kernel_weight_2(kernel_weight_1),
            .kernel_weight_3(kernel_weight_2),
            .kernel_weight_4(kernel_weight_3),
            .kernel_weight_5(kernel_weight_4),
            .kernel_weight_6(kernel_weight_5),
            .kernel_weight_7(kernel_weight_6),
            .kernel_weight_8(kernel_weight_7),
            .kernel_weight_9(kernel_weight_8),
            .third_addr_level_stage(G_third_addr_level_stage)
        ),R_CALC(
            .M_AXI_ACLK(M_AXI_ACLK),
            .Current_state(Current_state),
            .LineBuffer_value1(R_LineBuffer_value_1),
            .LineBuffer_value2(R_LineBuffer_value_2),
            .LineBuffer_value3(R_LineBuffer_value_3),
            .LineBuffer_value4(R_LineBuffer_value_4),
            .LineBuffer_value5(R_LineBuffer_value_5),
            .LineBuffer_value6(R_LineBuffer_value_6),
            .LineBuffer_value7(R_LineBuffer_value_7),
            .LineBuffer_value8(R_LineBuffer_value_8),
            .LineBuffer_value9(R_LineBuffer_value_9),
            .kernel_weight_1(kernel_weight_0),
            .kernel_weight_2(kernel_weight_1),
            .kernel_weight_3(kernel_weight_2),
            .kernel_weight_4(kernel_weight_3),
            .kernel_weight_5(kernel_weight_4),
            .kernel_weight_6(kernel_weight_5),
            .kernel_weight_7(kernel_weight_6),
            .kernel_weight_8(kernel_weight_7),
            .kernel_weight_9(kernel_weight_8),
            .third_addr_level_stage(R_third_addr_level_stage)
        ),U_CALC(
            .M_AXI_ACLK(M_AXI_ACLK),
            .Current_state(Current_state),
            .LineBuffer_value1(U_LineBuffer_value_1),
            .LineBuffer_value2(U_LineBuffer_value_2),
            .LineBuffer_value3(U_LineBuffer_value_3),
            .LineBuffer_value4(U_LineBuffer_value_4),
            .LineBuffer_value5(U_LineBuffer_value_5),
            .LineBuffer_value6(U_LineBuffer_value_6),
            .LineBuffer_value7(U_LineBuffer_value_7),
            .LineBuffer_value8(U_LineBuffer_value_8),
            .LineBuffer_value9(U_LineBuffer_value_9),
            .kernel_weight_1(kernel_weight_0),
            .kernel_weight_2(kernel_weight_1),
            .kernel_weight_3(kernel_weight_2),
            .kernel_weight_4(kernel_weight_3),
            .kernel_weight_5(kernel_weight_4),
            .kernel_weight_6(kernel_weight_5),
            .kernel_weight_7(kernel_weight_6),
            .kernel_weight_8(kernel_weight_7),
            .kernel_weight_9(kernel_weight_8),
            .third_addr_level_stage(U_third_addr_level_stage)
        );
    //--------------------kernel weight---------------------
    assign kernel_weight_v_0 = -1;//v
    assign kernel_weight_v_1 = 0;
    assign kernel_weight_v_2 = 1;
    assign kernel_weight_v_3 = -2;
    assign kernel_weight_v_4 = 0;
    assign kernel_weight_v_5 = 2;
    assign kernel_weight_v_6 = -1;
    assign kernel_weight_v_7 = 0;
    assign kernel_weight_v_8 = 1;

    assign kernel_weight_h_0 = 1;//h
    assign kernel_weight_h_1 = 2;
    assign kernel_weight_h_2 = 1;
    assign kernel_weight_h_3 = 0;
    assign kernel_weight_h_4 = 0;
    assign kernel_weight_h_5 = 0;
    assign kernel_weight_h_6 = -1;
    assign kernel_weight_h_7 = -2;
    assign kernel_weight_h_8 = -1;

    assign kernel_weight_0 = s_axi_inst_3 ? kernel_weight_v_0 : kernel_weight_h_0; 
    assign kernel_weight_1 = s_axi_inst_3 ? kernel_weight_v_1 : kernel_weight_h_1;
    assign kernel_weight_2 = s_axi_inst_3 ? kernel_weight_v_2 : kernel_weight_h_2;
    assign kernel_weight_3 = s_axi_inst_3 ? kernel_weight_v_3 : kernel_weight_h_3;
    assign kernel_weight_4 = s_axi_inst_3 ? kernel_weight_v_4 : kernel_weight_h_4;
    assign kernel_weight_5 = s_axi_inst_3 ? kernel_weight_v_5 : kernel_weight_h_5;
    assign kernel_weight_6 = s_axi_inst_3 ? kernel_weight_v_6 : kernel_weight_h_6; 
    assign kernel_weight_7 = s_axi_inst_3 ? kernel_weight_v_7 : kernel_weight_h_7; 
    assign kernel_weight_8 = s_axi_inst_3 ? kernel_weight_v_8 : kernel_weight_h_8; 
    //------------------------------------------------------

    assign IRQ                      = (Current_state==MAIN_FINISH) ? 1 : 0;
    assign M_AXI_ARVALID            = en_axi_arvalid && M_AXI_ARREADY; //throw data to init the value;
    assign M_AXI_AWVALID            = en_axi_awvalid && M_AXI_AWREADY;

    assign M_AXI_WVALID             = Write_en && Write_en_dff && !M_AXI_AWVALID;
    assign M_AXI_RREADY             = M_AXI_RVALID;
    assign M_AXI_ARADDR             = pre_M_AXI_ARADDR;  //s_axi_inst_0 + dram_addr_ctl_counter * 16'h710; // to fix
    assign M_AXI_ARLEN              = read_sram_width-1; // to fix
    assign M_AXI_AWADDR             = pre_M_AXI_AWADDR;  //s_axi_inst_1; // to fix
    assign M_AXI_AWLEN              = write_sram_width-1; // to fix
    assign M_AXI_WLAST              = ((Write_count == ((current_wirte_sram_width+lost_count)<<2)) && M_AXI_WVALID && M_AXI_WREADY) ? 1 : 0; //sram will be late one clk
    assign M_AXI_WDATA              = ((M_AXI_WVALID==1 && M_AXI_WREADY==0) || assert_wready_wvalid) ? output_buffer[choose_count] : M_AXI_WDATA_pre_reg;
    assign Write_en                 = (calc_result_counter>232 && (output_sram_addr<=(((current_wirte_sram_width+output_sram_addr_checkpoint+lost_count)<<2)+4))) ? 1 : 0;//65 but the counter+4 so 68
    
    assign main_state_WATCH         = Current_state;
    assign w_state_WATCH            = CWRITE_state;
    assign r_state_WATCH            = CREAD_state;
    assign w_data_WATCH             = M_AXI_WDATA;
    assign r_data_WATCH             = M_AXI_RDATA;
    assign write_valid_count_56_WATCH = write_valid_count_56;
    assign sram_write_signal_en_1   = (CSram_write_ctl_state == sram_ctl_1 && Current_state == INST_DATA && M_AXI_RVALID && M_AXI_RREADY)? 1 : 0; 
    assign sram_write_signal_en_2   = (CSram_write_ctl_state == sram_ctl_2 && Current_state == INST_DATA && M_AXI_RVALID && M_AXI_RREADY)? 1 : 0; 
    assign sram_write_signal_en_3   = (CSram_write_ctl_state == sram_ctl_3 && Current_state == INST_DATA && M_AXI_RVALID && M_AXI_RREADY)? 1 : 0; 
    assign INST_DATA_FINISH         = ((CSram_write_ctl_state == sram_ctl_3) && sram_addr==225) ? 1 : 0;
    assign write_output_sram_en     = (calc_result_counter > 7 && calc_result_counter<=231) ? 1 : 0;
    assign sram224_write_input_sram_data   = (sram224_write_input_sram_data_pre>255) ? 16'd255 : (sram224_write_input_sram_data_pre<0) ? 16'd0 : sram224_write_input_sram_data_pre[15:0];
    assign check_raddr_times        = (M_AXI_ARVALID && M_AXI_ARADDR[7:0]==8'b0) ? 1 : 0;
    assign check_waddr_times        = (M_AXI_AWVALID && M_AXI_AWADDR[7:0]==8'b0) ? 1 : 0;
    assign wlen_post_finish         = (write_valid_count_56==55) ? 1 : 0;
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
        else if(M_AXI_ARVALID && M_AXI_ARREADY)
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
        else if(M_AXI_AWVALID && M_AXI_AWREADY)
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
    
    always @(posedge M_AXI_ACLK) begin
        if(rst)
            CSram_write_ctl_state <= IDLE;
        else
            CSram_write_ctl_state <= NSram_write_ctl_state;
    end
    //---------------------------------------------------------------
    always@(*)begin : main_state
        case (Current_state)
            IDLE    :   begin
                if(s_axi_start)   Next_state = INST_DATA;
                else              Next_state = IDLE;
            end
            INST_DATA       :   begin
                if(INST_DATA_FINISH)    Next_state = PROCESS_DATA;
                else                    Next_state = INST_DATA;
            end
            PROCESS_DATA    :   begin
                if(PROCESS_FINI)                            Next_state = MAIN_FINISH;
                else if (M_AXI_WLAST && wlen_post_finish)   Next_state = INST_DATA; // and w_post_finish
                else                                        Next_state = PROCESS_DATA; //keep state
            end
            MAIN_FINISH     :   begin
                Next_state = IDLE;
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
                PROCESS_FINI <= write_valid_count == 12544 ? 1 : 0;
            end
            MAIN_FINISH     :   begin
                PROCESS_FINI <= 1'b1;
            end
            default: PROCESS_FINI <= 1'b0;
        endcase
    end
    //-------------------------PE calc-------------------------------------
    always @(posedge M_AXI_ACLK) begin
        //-------------------b_linebuffer-----------------
        B_LineBuffer_value_3 <= (Current_state==PROCESS_DATA) ? {1'b0,B1_dataout[7:0]}  :   9'b0;
        B_LineBuffer_value_6 <= (Current_state==PROCESS_DATA) ? {1'b0,B2_dataout[7:0]}  :   9'b0;
        B_LineBuffer_value_9 <= (Current_state==PROCESS_DATA) ? {1'b0,B3_dataout[7:0]}  :   9'b0;
        B_LineBuffer_value_2 <= (Current_state==PROCESS_DATA) ? B_LineBuffer_value_3    :   9'b0;
        B_LineBuffer_value_5 <= (Current_state==PROCESS_DATA) ? B_LineBuffer_value_6    :   9'b0;
        B_LineBuffer_value_8 <= (Current_state==PROCESS_DATA) ? B_LineBuffer_value_9    :   9'b0;
        B_LineBuffer_value_1 <= (Current_state==PROCESS_DATA) ? B_LineBuffer_value_2    :   9'b0;
        B_LineBuffer_value_4 <= (Current_state==PROCESS_DATA) ? B_LineBuffer_value_5    :   9'b0;
        B_LineBuffer_value_7 <= (Current_state==PROCESS_DATA) ? B_LineBuffer_value_8    :   9'b0;
        //-------------------g_linebuffer-----------------
        G_LineBuffer_value_3 <= (Current_state==PROCESS_DATA) ? {1'b0,G1_dataout[7:0]}  :   9'b0;
        G_LineBuffer_value_6 <= (Current_state==PROCESS_DATA) ? {1'b0,G2_dataout[7:0]}  :   9'b0;
        G_LineBuffer_value_9 <= (Current_state==PROCESS_DATA) ? {1'b0,G3_dataout[7:0]}  :   9'b0;
        G_LineBuffer_value_2 <= (Current_state==PROCESS_DATA) ? G_LineBuffer_value_3    :   9'b0;
        G_LineBuffer_value_5 <= (Current_state==PROCESS_DATA) ? G_LineBuffer_value_6    :   9'b0;
        G_LineBuffer_value_8 <= (Current_state==PROCESS_DATA) ? G_LineBuffer_value_9    :   9'b0;
        G_LineBuffer_value_1 <= (Current_state==PROCESS_DATA) ? G_LineBuffer_value_2    :   9'b0;
        G_LineBuffer_value_4 <= (Current_state==PROCESS_DATA) ? G_LineBuffer_value_5    :   9'b0;
        G_LineBuffer_value_7 <= (Current_state==PROCESS_DATA) ? G_LineBuffer_value_8    :   9'b0;
        //-------------------r_linebuffer-----------------
        R_LineBuffer_value_3 <= (Current_state==PROCESS_DATA) ? {1'b0,R1_dataout[7:0]}  :   9'b0;
        R_LineBuffer_value_6 <= (Current_state==PROCESS_DATA) ? {1'b0,R2_dataout[7:0]}  :   9'b0;
        R_LineBuffer_value_9 <= (Current_state==PROCESS_DATA) ? {1'b0,R3_dataout[7:0]}  :   9'b0;
        R_LineBuffer_value_2 <= (Current_state==PROCESS_DATA) ? R_LineBuffer_value_3    :   9'b0;
        R_LineBuffer_value_5 <= (Current_state==PROCESS_DATA) ? R_LineBuffer_value_6    :   9'b0;
        R_LineBuffer_value_8 <= (Current_state==PROCESS_DATA) ? R_LineBuffer_value_9    :   9'b0;
        R_LineBuffer_value_1 <= (Current_state==PROCESS_DATA) ? R_LineBuffer_value_2    :   9'b0;
        R_LineBuffer_value_4 <= (Current_state==PROCESS_DATA) ? R_LineBuffer_value_5    :   9'b0;
        R_LineBuffer_value_7 <= (Current_state==PROCESS_DATA) ? R_LineBuffer_value_8    :   9'b0;
        //-------------------u_linebuffer-----------------
        U_LineBuffer_value_3 <= (Current_state==PROCESS_DATA) ? {1'b0,U1_dataout[7:0]}  :   9'b0;
        U_LineBuffer_value_6 <= (Current_state==PROCESS_DATA) ? {1'b0,U2_dataout[7:0]}  :   9'b0;
        U_LineBuffer_value_9 <= (Current_state==PROCESS_DATA) ? {1'b0,U3_dataout[7:0]}  :   9'b0;
        U_LineBuffer_value_2 <= (Current_state==PROCESS_DATA) ? U_LineBuffer_value_3    :   9'b0;
        U_LineBuffer_value_5 <= (Current_state==PROCESS_DATA) ? U_LineBuffer_value_6    :   9'b0;
        U_LineBuffer_value_8 <= (Current_state==PROCESS_DATA) ? U_LineBuffer_value_9    :   9'b0;
        U_LineBuffer_value_1 <= (Current_state==PROCESS_DATA) ? U_LineBuffer_value_2    :   9'b0;
        U_LineBuffer_value_4 <= (Current_state==PROCESS_DATA) ? U_LineBuffer_value_5    :   9'b0;
        U_LineBuffer_value_7 <= (Current_state==PROCESS_DATA) ? U_LineBuffer_value_8    :   9'b0;
    end
    //-------------------------read_CH--------------------------------------
    always@(*)begin : READ_state
        case (CREAD_state)
            IDLE    :   begin
                if(Current_state==INST_DATA && !IRQ)                      NREAD_state = READ_DATA;
                else                                                      NREAD_state = IDLE;
            end 
            READ_DATA   :   begin
                if(M_AXI_RLAST && M_AXI_RVALID && M_AXI_RREADY)           NREAD_state = IDLE;
                else                                                      NREAD_state = READ_DATA;
            end
            default: NREAD_state = IDLE;
        endcase
    end

    //--------------------------------write_CH-----------------------------
    always@(*)begin
        case(CWRITE_state)
            IDLE    :   begin
                if(Current_state==PROCESS_DATA && !IRQ)                   NWRITE_state = WRITE_DATA;
                else                                                      NWRITE_state = IDLE;
            end
            WRITE_DATA  :   begin
                if(M_AXI_WLAST && M_AXI_WVALID && M_AXI_WREADY)           NWRITE_state = IDLE;
                else                                                      NWRITE_state = WRITE_DATA;
            end
            default:    NWRITE_state = IDLE;
        endcase
    end
    
    always@(posedge M_AXI_ACLK)begin
        Write_en_dff            <= Write_en; // delay one clk
        Write_count             <= (CWRITE_state==IDLE) ? 0 : (Write_en && Write_count<((current_wirte_sram_width+lost_count)<<2)) ? Write_count+4 : 0;//+1
    end
    always @(posedge M_AXI_ACLK) begin
        if(rst)begin
            M_AXI_WDATA_pre_reg <= 64'b0;
        end else begin
            M_AXI_WDATA_pre_reg <= M_AXI_WDATA_pre_wire;
        end
    end
    always @(posedge M_AXI_ACLK) begin
        if(rst)begin
            output_buffer[cache_count] <= 0;    
        end else begin
            output_buffer[cache_count] <= M_AXI_WDATA_pre_reg; // combination circuit 
        end
    end
    always @(posedge M_AXI_ACLK ) begin
        if(rst)begin
            cache_count <= 0;
        end else if(M_AXI_AWVALID && M_AXI_AWREADY)begin
            cache_count <= 0;
        end else if(M_AXI_WVALID)begin
            cache_count <= cache_count + 1;
        end else begin
            cache_count <= cache_count;
        end
    end
    always @(posedge M_AXI_ACLK) begin
        if(rst)begin
            choose_count <= 0;
        end else if(M_AXI_AWVALID && M_AXI_AWREADY)begin
            choose_count <= 0;
        end else if(M_AXI_WREADY && M_AXI_WVALID)begin
            choose_count <= choose_count +1;
        end else begin
            choose_count <= choose_count;
        end
    end
    always @(posedge M_AXI_ACLK) begin
        if(rst)begin
            assert_wready_wvalid <= 0;
        end else if(M_AXI_AWVALID && M_AXI_AWREADY)begin
            assert_wready_wvalid <= 0;
        end else if(M_AXI_WREADY==0 && M_AXI_WVALID==1)begin
            assert_wready_wvalid <= 1;
        end else begin
            assert_wready_wvalid <= assert_wready_wvalid;
        end
    end
    always @(posedge M_AXI_ACLK) begin
        if(rst)begin
            lost_count <= 0;
        end else if(M_AXI_AWVALID && M_AXI_AWREADY)begin
            lost_count <= 0;
        end else if(M_AXI_WREADY==0 && M_AXI_WVALID==1)begin
            lost_count <= lost_count +1;
        end else begin
            lost_count <= lost_count;
        end
    end
    //------------------------------counter----------------------------
    always @(posedge M_AXI_ACLK) begin : counter_sramaddr
        case (Current_state)
            IDLE    :   begin
                sram_addr <= 0;
            end
            INST_DATA   :   begin
                sram_addr <= (M_AXI_RVALID && M_AXI_RREADY) ? ((sram_addr==225) ? 0 : sram_addr+1) : sram_addr;
            end
            PROCESS_DATA    :   begin
                sram_addr <= Write_en ? 0 : (sram_addr==225) ? sram_addr : sram_addr+1;
            end
            MAIN_FINISH :   begin
                sram_addr <= sram_addr;
            end
            default: sram_addr <= sram_addr;
        endcase
    end
    //------------------------------sram_write_ctl_state---------------
    always @(*) begin
        case (Current_state)
            INST_DATA   :   begin
                case (CSram_write_ctl_state)
                    sram_ctl_1   :   begin
                        NSram_write_ctl_state = (sram_addr==225) ? sram_ctl_2 : sram_ctl_1;
                    end
                    sram_ctl_2   :   begin
                        NSram_write_ctl_state = (sram_addr==225) ? sram_ctl_3 : sram_ctl_2;
                    end 
                    sram_ctl_3   :   begin
                        NSram_write_ctl_state = (sram_addr==225) ? sram_ctl_keeping : sram_ctl_3;
                    end
                    sram_ctl_keeping    :   begin
                        NSram_write_ctl_state = sram_ctl_keeping;
                    end
                    default: NSram_write_ctl_state = sram_ctl_1;
                endcase
            end 
            default: NSram_write_ctl_state = IDLE; 
        endcase
    end
    //-----------------------------dram_addr_ctl------------------------
    always @(posedge M_AXI_ACLK) begin
        pre_M_AXI_ARADDR                 <= (rst) ? s_axi_inst_0 : (INST_DATA_FINISH) ? (pre_M_AXI_ARADDR-((read_sram_reg<<1)<<3)) : (M_AXI_ARVALID) ? (pre_M_AXI_ARADDR + (read_sram_width<<3))  : pre_M_AXI_ARADDR;
        pre_M_AXI_AWADDR                 <= (rst) ? s_axi_inst_1 : (M_AXI_AWVALID && M_AXI_AWREADY)    ? (pre_M_AXI_AWADDR + (write_sram_width<<3)) : pre_M_AXI_AWADDR;
        current_wirte_sram_width         <= (rst) ? 0            : (M_AXI_AWVALID && M_AXI_AWREADY)    ? write_sram_width : current_wirte_sram_width;
        read_sram_width_lock             <= (rst) ? 0            : (M_AXI_ARADDR[7:0]==8'b0) ? 1 : 0; //lock for read
        write_sram_width_lock            <= (rst) ? 0            : (M_AXI_AWADDR[11:0]==12'b0) ? 1 : 0; // lock for write
        INST_DATA_FINISH_keep            <= (rst) ? 0            : (INST_DATA_FINISH) ? 1                : (M_AXI_ARVALID) ? 0 : INST_DATA_FINISH_keep; 
        pre_AWADDR                       <= (rst) ? 0            : (M_AXI_AWVALID && M_AXI_AWREADY)    ? M_AXI_AWADDR     :  pre_AWADDR;
        pre_AWLEN                        <= (rst) ? 0            : (M_AXI_AWVALID && M_AXI_AWREADY)    ? M_AXI_AWLEN      :  pre_AWLEN;
        output_sram_addr_checkpoint      <= (rst) ? 0            : (calc_result_counter==232) ? output_sram_addr>>2 : calc_result_counter==0 ? 0 : output_sram_addr_checkpoint;
        sram224_write_input_sram_data_pre<= B_third_addr_level_stage + G_third_addr_level_stage + R_third_addr_level_stage + U_third_addr_level_stage;
    end
    always @(posedge M_AXI_ACLK) begin : read_bundary
        if(rst)begin
            read_sram_width <= read_sram_reg;
        end else begin
            if(M_AXI_ARADDR[7:0]==8'b0 && check_raddr_times!=1 && !INST_DATA_FINISH_keep)begin
                if(read_sram_width_lock==0)begin
                    if(read_sram_reg-read_sram_width==0)begin
                        read_sram_width <= (((fourk_bundary - M_AXI_ARADDR[11:0])>>3)>read_sram_reg) ? read_sram_reg : (fourk_bundary - M_AXI_ARADDR[11:0])>>3;
                    end else begin
                        read_sram_width <= read_sram_reg-read_sram_width;
                    end 
                end else begin
                    read_sram_width <= read_sram_width;     
                end
            end else begin
                if(M_AXI_ARADDR[7:0]==8'b0 && check_raddr_times==1)begin
                    read_sram_width <= (sram_addr+read_sram_width==226) ? read_sram_reg : (read_sram_reg-(sram_addr+read_sram_width));
                end else begin
                    read_sram_width <= (((fourk_bundary - M_AXI_ARADDR[11:0])>>3)>read_sram_reg) ? read_sram_reg : (fourk_bundary - M_AXI_ARADDR[11:0])>>3;
                end
            end
        end
    end
    always @(posedge M_AXI_ACLK) begin : write_bundary
        if(rst)begin
            write_sram_width <= write_sram_reg; 
        end else begin
            if(M_AXI_AWADDR[11:0]==12'b0)begin
                if(write_sram_width_lock==0)begin
                    if(write_sram_reg-write_sram_width==0)begin
                        write_sram_width <= (((fourk_bundary - M_AXI_AWADDR[11:0])>>3)>=write_sram_reg) ? (output_sram_addr_checkpoint>=32) ?  8 : write_sram_reg : (fourk_bundary - M_AXI_AWADDR[11:0])>>3;     
                    end else begin
                        write_sram_width <= (write_sram_width<=4) ? 8-write_sram_width : write_sram_reg-write_sram_width;
                    end
                end else begin
                    write_sram_width <= write_sram_width;
                end
            end else begin
                write_sram_width <= (((fourk_bundary - M_AXI_AWADDR[11:0])>>3)>=write_sram_reg) ? (output_sram_addr_checkpoint>=32) ?  4 : write_sram_reg : (output_sram_addr_checkpoint>=32) ?  4 : (fourk_bundary - M_AXI_AWADDR[11:0])>>3;     
            end
        end
    end
    always @(posedge M_AXI_ACLK) begin
        case (Current_state)
            PROCESS_DATA    :   begin
                calc_result_counter <= (calc_result_counter<=232) ? calc_result_counter+1 : CWRITE_state==IDLE ? 232 : calc_result_counter;
            end
            default: calc_result_counter <= 9'b0;
        endcase
    end
    always @(posedge M_AXI_ACLK) begin
        case (Current_state)
            PROCESS_DATA    :   begin
                output_sram_addr <= (calc_result_counter>231) ? (CWRITE_state==IDLE ? (output_sram_addr-((lost_count+2)<<2)) : output_sram_addr+4) : (write_output_sram_en && output_sram_addr<sram_output_reg-1) ? output_sram_addr+1 : 0;//+1
            end
            default: output_sram_addr <= 0;
        endcase
    end
//----------------------------------------------------------------\\
always @(posedge M_AXI_ACLK) begin
    write_valid_count_56 <= (rst) ? 0 : (M_AXI_WVALID && M_AXI_WREADY) ? (write_valid_count_56>=55) ? 0 : write_valid_count_56+1 : write_valid_count_56;
    write_valid_count    <= (rst) ? 0 : (M_AXI_WVALID && M_AXI_WREADY) ? write_valid_count+1 : write_valid_count;
end
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

module pipeline_CALC#( 
    parameter PROCESS_DATA = 2'b10
)(
    input [1:0]Current_state,
    input M_AXI_ACLK,
    input signed [8:0]LineBuffer_value1, //1bit signal 8bit value
    input signed [8:0]LineBuffer_value2,
    input signed [8:0]LineBuffer_value3,
    input signed [8:0]LineBuffer_value4,
    input signed [8:0]LineBuffer_value5,
    input signed [8:0]LineBuffer_value6,
    input signed [8:0]LineBuffer_value7,
    input signed [8:0]LineBuffer_value8,
    input signed [8:0]LineBuffer_value9,
    input signed [2:0]kernel_weight_1,
    input signed [2:0]kernel_weight_2,
    input signed [2:0]kernel_weight_3,
    input signed [2:0]kernel_weight_4,
    input signed [2:0]kernel_weight_5,
    input signed [2:0]kernel_weight_6,
    input signed [2:0]kernel_weight_7,
    input signed [2:0]kernel_weight_8,
    input signed [2:0]kernel_weight_9,
    output reg signed[15:0]third_addr_level_stage
);
    reg signed [11:0] first_addr_level_stage1,first_addr_level_stage2,first_addr_level_stage3;
    reg signed [11:0] first_addr_level_stage4,first_addr_level_stage5,first_addr_level_stage6;
    reg signed [11:0] first_addr_level_stage7,first_addr_level_stage8,first_addr_level_stage9;
    reg signed [13:0] second_addr_level_stage1,second_addr_level_stage2,second_addr_level_stage3;
    //------------------------ADDR_TREE-------------------------
    always@(posedge M_AXI_ACLK)begin
        case (Current_state)
            PROCESS_DATA    :   begin
                first_addr_level_stage1     <=      LineBuffer_value1 * kernel_weight_1;
                first_addr_level_stage2     <=      LineBuffer_value2 * kernel_weight_2;
                first_addr_level_stage3     <=      LineBuffer_value3 * kernel_weight_3;
                first_addr_level_stage4     <=      LineBuffer_value4 * kernel_weight_4;
                first_addr_level_stage5     <=      LineBuffer_value5 * kernel_weight_5;
                first_addr_level_stage6     <=      LineBuffer_value6 * kernel_weight_6;
                first_addr_level_stage7     <=      LineBuffer_value7 * kernel_weight_7;
                first_addr_level_stage8     <=      LineBuffer_value8 * kernel_weight_8;
                first_addr_level_stage9     <=      LineBuffer_value9 * kernel_weight_9;
                second_addr_level_stage1    <=      first_addr_level_stage1 + first_addr_level_stage2 + first_addr_level_stage3;
                second_addr_level_stage2    <=      first_addr_level_stage4 + first_addr_level_stage5 + first_addr_level_stage6;
                second_addr_level_stage3    <=      first_addr_level_stage7 + first_addr_level_stage8 + first_addr_level_stage9;
                third_addr_level_stage      <=      second_addr_level_stage1 + second_addr_level_stage2 + second_addr_level_stage3; 
            end 
            default: begin
                first_addr_level_stage1     <=      0;
                first_addr_level_stage2     <=      0;
                first_addr_level_stage3     <=      0;
                first_addr_level_stage4     <=      0;
                first_addr_level_stage5     <=      0;
                first_addr_level_stage6     <=      0;
                first_addr_level_stage7     <=      0;
                first_addr_level_stage8     <=      0;
                first_addr_level_stage9     <=      0;
                second_addr_level_stage1    <=      0;
                second_addr_level_stage2    <=      0;
                second_addr_level_stage3    <=      0;
                third_addr_level_stage      <=      0;
            end
        endcase
    end
endmodule