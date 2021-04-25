`define period 10.0
`include "settings.svh"
`include "File.sv"
`include "DRAM_Slave.sv"

`timescale 1ns / 1ns

`define LAYER_1_IN_TILE_NUM 4
`define LAYER_2_IN_TILE_NUM 2
`define LAYER_3_IN_TILE_NUM 1
`define LAYER_4_IN_TILE_NUM 1
`define LAYER_5_IN_TILE_NUM 1
`define LAYER_6_IN_TILE_NUM 1
`define LAYER_7_IN_TILE_NUM 1
`define LAYER_8_IN_TILE_NUM 1
`define LAYER_9_IN_TILE_NUM 1
`define LAYER_10_IN_TILE_NUM 1
`define LAYER_11_IN_TILE_NUM 1
`define LAYER_12_IN_TILE_NUM 1
`define LAYER_13_IN_TILE_NUM 1
`define TILE_NUM 4
`define TILE_SIZE 34
`define LAYER4_TILE_SIZE 18
`define LAYER5_TILE_SIZE 10
`define LAYER5_TILE_SIZE_NO_POOL 18
`define LAYER6_TILE_SIZE 10
`define LAYER7_TILE_SIZE 8
`define LAYER8_OUT_TILE_SIZE 10
`define LAYER8_OUT_TILE_SIZE_NO_PAD 8
`define LAYER9_OUT_TILE_SIZE 8
`define LAYER10_OUT_TILE_SIZE 8
`define LAYER11_OUT_TILE_SIZE 18
`define LAYER12_OUT_TILE_SIZE 16
`define LAYER13_OUT_TILE_SIZE 16
`define OUT_TILE_SIZE 16
`define PAD_SIZE 1
`define LAYER_1_OCH 16
`define LAYER_2_OCH 32
`define LAYER_3_OCH 64
`define LAYER_4_OCH 128
`define LAYER_5_OCH 256
`define LAYER_6_OCH 256
`define LAYER_7_OCH 256
`define LAYER_8_OCH 64
`define LAYER_9_OCH 128
`define LAYER_10_OCH 24  //18
`define LAYER_11_OCH 32
`define LAYER_12_OCH 128
`define LAYER_13_OCH 24  //18
module TB_Top;
    parameter C_S_AXI_DATA_WIDTH = 32;
    parameter C_M_AXI_DATA_WIDTH = 128;
    parameter DATA_WIDTH = 2;// DATA_WIDTH_OFFSET
    integer addr_tmp;
    integer weight_addr;
    logic                               S_AXI_ACLK = 1;
    logic                               S_AXI_ARESETN;
    logic                               IRQ;

    logic                               s_axi_start;
    logic                               s_axi_inst_valid;
    logic  [C_S_AXI_DATA_WIDTH-1:0]     s_axi_inst_0;
    logic  [C_S_AXI_DATA_WIDTH-1:0]     s_axi_inst_1;
    logic  [C_S_AXI_DATA_WIDTH-1:0]     s_axi_inst_2;
    logic  [C_S_AXI_DATA_WIDTH-1:0]     s_axi_inst_3;
    logic  [C_S_AXI_DATA_WIDTH-1:0]     s_axi_inst_4;
    logic  [C_S_AXI_DATA_WIDTH-1:0]     s_axi_inst_number;
    logic  [C_S_AXI_DATA_WIDTH-1:0]     s_axi_error;            //Trigger IRQ if error
    logic  [C_S_AXI_DATA_WIDTH-1:0]     s_axi_Rerror_addr;
    logic  [0:0]                        s_axi_Rerror;
    logic  [C_S_AXI_DATA_WIDTH-1:0]     s_axi_Werror_addr;
    logic  [1:0]                        s_axi_Werror;

    logic  [C_S_AXI_DATA_WIDTH-1:0]     s_axi_dram_addr_inst;   //Instruction
    logic  [C_S_AXI_DATA_WIDTH-1:0]		s_axi_leaky_factor;
    
    logic  [C_S_AXI_DATA_WIDTH-1:0]    s_axi_img_size;     ////////
    logic  [C_S_AXI_DATA_WIDTH-1:0]    s_axi_dram_raddr;   ///////
    /*
    logic  [15:0] weight_0_1 [0:8];
    logic  [15:0] weight_1_1 [0:8];
    logic  [15:0] weight_2_1 [0:8];
    logic  [15:0] weight_3_1 [0:8];
    logic  [15:0] weight_4_1 [0:8];
    logic  [15:0] weight_5_1 [0:8];
    logic  [15:0] weight_6_1 [0:8];
    logic  [15:0] weight_7_1 [0:8];
    logic  [15:0] weight_8_1 [0:8];
    logic  [15:0] weight_9_1 [0:8];
    logic  [15:0] weight_10_1 [0:8];
    logic  [15:0] weight_11_1 [0:8];
    logic  [15:0] weight_12_1 [0:8];
    logic  [15:0] weight_13_1 [0:8];
    logic  [15:0] weight_14_1 [0:8];
    logic  [15:0] weight_15_1 [0:8];
    logic  [15:0] data_0 [0:8];
    logic  [15:0] data_1 [0:8];
    logic  [15:0] data_2 [0:8];
    logic  [15:0] data_3 [0:8];
    logic  [15:0] data_4 [0:8];
    logic  [15:0] data_5 [0:8];
    logic  [15:0] data_6 [0:8];
    logic  [15:0] data_7 [0:8];
    */
    
    
    integer addr_test;
    string filename, num;
    //Interface declaration
    AXI_FULL axi_if (S_AXI_ACLK, S_AXI_ARESETN);
    /*
    always@(*)
        for(int i = 0; i < 9; i+=1)begin
            weight_0_1[i]  = u_DUT.u_CNN.uobuf_chip.weight_arrary_och0.weight_buffer_chi0.wbuf_a[i*16+:16];
            weight_1_1[i]  = u_DUT.u_CNN.uobuf_chip.weight_arrary_och0.weight_buffer_chi1.wbuf_a[i*16+:16];
            weight_2_1[i]  = u_DUT.u_CNN.uobuf_chip.weight_arrary_och0.weight_buffer_chi2.wbuf_a[i*16+:16];
            weight_3_1[i]  = u_DUT.u_CNN.uobuf_chip.weight_arrary_och0.weight_buffer_chi3.wbuf_a[i*16+:16];
            
            weight_4_1[i]  = u_DUT.u_CNN.uobuf_chip.weight_arrary_och0.weight_buffer_chi4.wbuf_a[i*16+:16];
            weight_5_1[i]  = u_DUT.u_CNN.uobuf_chip.weight_arrary_och0.weight_buffer_chi5.wbuf_a[i*16+:16];
            weight_6_1[i]  = u_DUT.u_CNN.uobuf_chip.weight_arrary_och0.weight_buffer_chi6.wbuf_a[i*16+:16];
            weight_7_1[i]  = u_DUT.u_CNN.uobuf_chip.weight_arrary_och0.weight_buffer_chi7.wbuf_a[i*16+:16];

            weight_8_1[i]  = u_DUT.u_CNN.uobuf_chip.weight_arrary_och0.weight_buffer_chi0.wbuf_b[i*16+:16];
            weight_9_1[i]  = u_DUT.u_CNN.uobuf_chip.weight_arrary_och0.weight_buffer_chi1.wbuf_b[i*16+:16];
            weight_10_1[i] = u_DUT.u_CNN.uobuf_chip.weight_arrary_och0.weight_buffer_chi2.wbuf_b[i*16+:16];
            weight_11_1[i] = u_DUT.u_CNN.uobuf_chip.weight_arrary_och0.weight_buffer_chi3.wbuf_b[i*16+:16];

            weight_12_1[i] = u_DUT.u_CNN.uobuf_chip.weight_arrary_och0.weight_buffer_chi4.wbuf_b[i*16+:16];
            weight_13_1[i] = u_DUT.u_CNN.uobuf_chip.weight_arrary_och0.weight_buffer_chi5.wbuf_b[i*16+:16];
            weight_14_1[i] = u_DUT.u_CNN.uobuf_chip.weight_arrary_och0.weight_buffer_chi6.wbuf_b[i*16+:16];
            weight_15_1[i] = u_DUT.u_CNN.uobuf_chip.weight_arrary_och0.weight_buffer_chi7.wbuf_b[i*16+:16];

            data_0[i]      = u_DUT.u_CNN.uobuf_chip.Data_in_ich0[i*16+:16];
            data_1[i]      = u_DUT.u_CNN.uobuf_chip.Data_in_ich1[i*16+:16];
            data_2[i]      = u_DUT.u_CNN.uobuf_chip.Data_in_ich2[i*16+:16];
            data_3[i]      = u_DUT.u_CNN.uobuf_chip.Data_in_ich3[i*16+:16];

            data_4[i]      = u_DUT.u_CNN.uobuf_chip.Data_in_ich4[i*16+:16];
            data_5[i]      = u_DUT.u_CNN.uobuf_chip.Data_in_ich5[i*16+:16];
            data_6[i]      = u_DUT.u_CNN.uobuf_chip.Data_in_ich6[i*16+:16];
            data_7[i]      = u_DUT.u_CNN.uobuf_chip.Data_in_ich7[i*16+:16];

        end
        */
    //Design Under Test declaration
   DUT_wrapper u_DUT(
       //S_AXI-Lite
       .S_AXI_ACLK             (S_AXI_ACLK),
       .S_AXI_ARESETN          (S_AXI_ARESETN),
       .IRQ                    (IRQ),
       .s_axi_inst_0           (s_axi_inst_0),
       .s_axi_inst_1           (s_axi_inst_1),
       .s_axi_inst_2           (s_axi_inst_2),
       .s_axi_inst_3           (s_axi_inst_3),
       .s_axi_inst_4           (s_axi_inst_4),
       .s_axi_start(s_axi_start),
   
       .s_axi_Rerror(s_axi_Rerror),            //Trigger IRQ if error
       .s_axi_Rerror_addr(s_axi_Rerror_addr),
       .s_axi_Werror(s_axi_Werror),            //Trigger IRQ if error
       .s_axi_Werror_addr(s_axi_Werror_addr),
       
       .mif                    (axi_if)
   );

    //Class declaration
    DRAM DRAM = new(axi_if);
    File File = new;
    
    default clocking cb@(posedge S_AXI_ACLK);
    endclocking

    always #(`period / 2.0) S_AXI_ACLK <= ~S_AXI_ACLK;



    always@(cb) begin
            DRAM.b_handle();
            DRAM.w_handle();
            DRAM.r_handle_seq();
            //Must used r_handle_comb at bottom?
            DRAM.r_handle_comb();
            
            DRAM.ar_handle();
            DRAM.aw_handle();
    end

    initial begin  
        @(cb)    
//        File.load_inst(`addr_inst, 128, `path_inst, DRAM);                C:/Users/Derek/Desktop/Zedboard_Data
        //File.load_inst(32'h00010000, 19392,         "C:/Users/Derek/Desktop/Zedboard_Data/total_tile_info.txt", DRAM);
       File.load_inst(`addr_inst, 51076,             "./data.txt", DRAM);//Fix it Inst addr
        /*
        File.load_inst(32'h00010000, 256,         "/home/f5009/Desktop/test/gen_info/Info_Gen/Tile_Info/conv2d_1.txt", DRAM);//Fix it Inst addr
        File.load_inst(32'h00012000, 512,         "/home/f5009/Desktop/test/gen_info/Info_Gen/Tile_Info/conv2d_2.txt", DRAM);
        File.load_inst(32'h00016000, 512,         "/home/f5009/Desktop/test/gen_info/Info_Gen/Tile_Info/conv2d_3.txt", DRAM);
        File.load_inst(32'h0001a000, 512,         "/home/f5009/Desktop/test/gen_info/Info_Gen/Tile_Info/conv2d_4.txt", DRAM);
        File.load_inst(32'h0001e000, 2048,        "/home/f5009/Desktop/test/gen_info/Info_Gen/Tile_Info/conv2d_5.txt", DRAM);
        File.load_inst(32'h0002e000, 4096,        "/home/f5009/Desktop/test/gen_info/Info_Gen/Tile_Info/conv2d_6.txt", DRAM);
        File.load_inst(32'h0004e000, 4096,        "/home/f5009/Desktop/test/gen_info/Info_Gen/Tile_Info/conv2d_7.txt", DRAM);
        File.load_inst(32'h0006e000, 1024,        "/home/f5009/Desktop/test/gen_info/Info_Gen/Tile_Info/conv2d_8.txt", DRAM);
        File.load_inst(32'h00076000, 512,         "/home/f5009/Desktop/test/gen_info/Info_Gen/Tile_Info/conv2d_9.txt", DRAM);
        File.load_inst(32'h0007a000, 160,         "/home/f5009/Desktop/test/gen_info/Info_Gen/Tile_Info/conv2d_10.txt", DRAM);
        File.load_inst(32'h0007b400, 1024,        "/home/f5009/Desktop/test/gen_info/Info_Gen/Tile_Info/conv2d_8_2.txt", DRAM);
        File.load_inst(32'h00083400, 128,         "/home/f5009/Desktop/test/gen_info/Info_Gen/Tile_Info/conv2d_11.txt", DRAM);
        File.load_inst(32'h00084400, 2048,        "/home/f5009/Desktop/test/gen_info/Info_Gen/Tile_Info/conv2d_5_2.txt", DRAM);
        File.load_inst(32'h00094400, 2304,        "/home/f5009/Desktop/test/gen_info/Info_Gen/Tile_Info/conv2d_12.txt", DRAM);
        File.load_inst(32'h000a6400, 160,         "/home/f5009/Desktop/test/gen_info/Info_Gen/Tile_Info/conv2d_13.txt", DRAM);
        */
        
        //File.load_act ("C:/Users/Derek/Desktop/Zedboard_Data/layer1_4x4.txt",32'h0200_1000, 128, DRAM);
      //  File.load_act ("C:/Users/Derek/Desktop/Zedboard_Data/layer1_4x4.txt",32'h0200_1000, 128, DRAM);
//        File.load_feature(32'h0218e600, "./Output_data/Hex/", 4, `LAYER_4_OCH, `LAYER4_TILE_SIZE, `LAYER_4_IN_TILE_NUM, "Layer4", DRAM);
//        File.load_feature(32'h021bba00, "./Output_data/Hex/", 4, `LAYER_7_OCH, `LAYER7_TILE_SIZE, `LAYER_7_IN_TILE_NUM, "Layer7", DRAM);
        // File.load_feature(32'h02091800, "./Output_data/Hex/", 4, `LAYER_1_OCH, `TILE_SIZE, `LAYER_1_IN_TILE_NUM, "Layer1", DRAM);
        // File.load_feature(32'h02122000, "./Output_data/Hex/", 4, `LAYER_2_OCH, `TILE_SIZE, `LAYER_2_IN_TILE_NUM, "Layer2", DRAM);
        
      //  weight_addr = 32'h0100_2000;
        //File.load_wgt("C:/Users/bboga/Desktop/new_info/Weight/weight_1.txt", 9*8*16+16*2, weight_addr, DRAM);
        //File.load_wgt("C:/Users/Derek/Desktop/Zedboard_Data/total_weight.txt", 2311008, weight_addr, DRAM);
      //  File.load_wgt("C:/Users/Derek/Desktop/Zedboard_Data/total_weight.txt", 2311008, weight_addr, DRAM);
        
        /*
        weight_addr += (152)*1*4*DATA_WIDTH;
        File.load_wgt("/home/f5009/Desktop/Vivado/Yolo_20200727_4in4out_Layer2_working/Weight/weight_2.txt", (152)*4*8, weight_addr, DRAM);
        weight_addr += (152)*4*8*DATA_WIDTH;
        File.load_wgt("/home/f5009/Desktop/Vivado/Yolo_20200727_4in4out_Layer2_working/Weight/weight_3.txt", (152)*8*16, weight_addr, DRAM);
        weight_addr += (152)*8*16*DATA_WIDTH;
        File.load_wgt("/home/f5009/Desktop/Vivado/Yolo_20200727_4in4out_Layer2_working/Weight/weight_4.txt", (152)*16*32, weight_addr, DRAM);
        weight_addr += (152)*16*32*DATA_WIDTH;
        File.load_wgt("/home/f5009/Desktop/Vivado/Yolo_20200727_4in4out_Layer2_working/Weight/weight_5.txt", (152)*32*64, weight_addr, DRAM);
        weight_addr += (152)*32*64*DATA_WIDTH;
        File.load_wgt("/home/f5009/Desktop/Vivado/Yolo_20200727_4in4out_Layer2_working/Weight/weight_6.txt", (152)*64*64, weight_addr, DRAM);
        weight_addr += (152)*64*64*DATA_WIDTH;
        File.load_wgt("/home/f5009/Desktop/Vivado/Yolo_20200727_4in4out_Layer2_working/Weight/weight_7.txt", (152)*64*64, weight_addr, DRAM);
        weight_addr += (152)*64*64*DATA_WIDTH;
        File.load_wgt("/home/f5009/Desktop/Vivado/Yolo_20200727_4in4out_Layer2_working/Weight/weight_8.txt", (152)*64*16, weight_addr, DRAM);
        weight_addr += (152)*64*16*DATA_WIDTH;
        File.load_wgt("/home/f5009/Desktop/Vivado/Yolo_20200727_4in4out_Layer2_working/Weight/weight_9.txt", (152)*16*32, weight_addr, DRAM);
        weight_addr += (152)*16*32*DATA_WIDTH;
        File.load_wgt("/home/f5009/Desktop/Vivado/Yolo_20200727_4in4out_Layer2_working/Weight/weight_10.txt", (152)*32*5, weight_addr, DRAM);
        weight_addr += (152)*32*5*DATA_WIDTH;
        File.load_wgt("/home/f5009/Desktop/Vivado/Yolo_20200727_4in4out_Layer2_working/Weight/weight_11.txt", (152)*16*8, weight_addr, DRAM);
        weight_addr += (152)*16*8*DATA_WIDTH;
        File.load_wgt("/home/f5009/Desktop/Vivado/Yolo_20200727_4in4out_Layer2_working/Weight/weight_12.txt", (152)*72*32, weight_addr, DRAM);
        weight_addr += (152)*72*32*DATA_WIDTH;
        File.load_wgt("/home/f5009/Desktop/Vivado/Yolo_20200727_4in4out_Layer2_working/Weight/weight_13.txt", (152)*32*5, weight_addr, DRAM);
        */
//        File.load_bias(DRAM);
//       File.load_inst(DRAM);
       @(cb)
        
        S_AXI_ARESETN        = 1'b0;

        s_axi_start          = {C_S_AXI_DATA_WIDTH{1'b0}};
        s_axi_dram_addr_inst = 32'h0100_0000;
        s_axi_leaky_factor   = 32'h000000_0d;

        @(cb)
        S_AXI_ARESETN = 1;

        @(cb)
        for(int loop=0; loop<1; loop=loop+1) begin
        #10
        s_axi_start          = {C_S_AXI_DATA_WIDTH{1'b0}};
        
      
        //Layer1
        {s_axi_inst_4, s_axi_inst_3,s_axi_inst_2,s_axi_inst_1,s_axi_inst_0} = 160'h00000000_00000001_0000c3ff_00080000_00010000;
        #10
        s_axi_start         = 32'd1;
        wait(IRQ);
       // #100
            
        
        //conv2d_2        
     /*   s_axi_start         = 32'd0;
        {s_axi_inst_4, s_axi_inst_3,s_axi_inst_2,s_axi_inst_1,s_axi_inst_0} = 160'h000000003322000120007ff2802be280a2435a1f;
        #(`period * 10.0)
        s_axi_start         = 32'd1;
        wait(IRQ);
        #100

        //conv2d_3
        s_axi_start         = 32'd0;

        {s_axi_inst_4, s_axi_inst_3,s_axi_inst_2,s_axi_inst_1,s_axi_inst_0} = 160'h00000000cca2000160007ff30030030062435a1f;
        #(`period * 10.0)
        s_axi_start         = 32'd1;
        wait(IRQ);
        #100

        //conv2d_4
        s_axi_start         = 32'd0;
        {s_axi_inst_4, s_axi_inst_3,s_axi_inst_2,s_axi_inst_1,s_axi_inst_0} = 160'h00000000cc920001a0007ff30030030062435a1f;
        #(`period * 10.0)
        s_axi_start         = 32'd1;
        wait(IRQ);
        #100
        
        //conv2d_5
        s_axi_start         = 32'd0;
        {s_axi_inst_4, s_axi_inst_3,s_axi_inst_2,s_axi_inst_1,s_axi_inst_0} = 160'h00000000cc8a0001e0007ff30030030052235a1f;
        #(`period * 10.0)
        s_axi_start         = 32'd1;
        wait(IRQ);
        #100
        
        s_axi_start         = 32'd0;
        {s_axi_inst_4, s_axi_inst_3,s_axi_inst_2,s_axi_inst_1,s_axi_inst_0} = 160'h00000000cc8a000220007ff30030030052235a1f;
        #(`period * 10.0)
        s_axi_start         = 32'd1;
        wait(IRQ);
        #100
        
        s_axi_start         = 32'd0;
        {s_axi_inst_4, s_axi_inst_3,s_axi_inst_2,s_axi_inst_1,s_axi_inst_0} = 160'h00000000cc8a000260007ff30030030052235a1f;
        #(`period * 10.0)
        s_axi_start         = 32'd1;
        wait(IRQ);
        #100
        
        s_axi_start         = 32'd0;
        {s_axi_inst_4, s_axi_inst_3,s_axi_inst_2,s_axi_inst_1,s_axi_inst_0} = 160'h00000000cc8a0002a0007ff30030030052235a1f;
        #(`period * 10.0)
        s_axi_start         = 32'd1;
        wait(IRQ);
        #100
        
        //conv2d_6
        s_axi_start         = 32'd0;
        {s_axi_inst_4, s_axi_inst_3,s_axi_inst_2,s_axi_inst_1,s_axi_inst_0} = 160'h00000000cc8a0002e0007ff3003003004a235017;
        #(`period * 10.0)
        s_axi_start         = 32'd1;
        wait(IRQ);
        #100
        
        s_axi_start         = 32'd0;
        {s_axi_inst_4, s_axi_inst_3,s_axi_inst_2,s_axi_inst_1,s_axi_inst_0} = 160'h00000000cc8a000320007ff3003003004a235017;
        #(`period * 10.0)
        s_axi_start         = 32'd1;
        wait(IRQ);
        #100
        
        s_axi_start         = 32'd0;
        {s_axi_inst_4, s_axi_inst_3,s_axi_inst_2,s_axi_inst_1,s_axi_inst_0} = 160'h00000000cc8a000360007ff3003003004a235017;
        #(`period * 10.0)
        s_axi_start         = 32'd1;
        wait(IRQ);
        #100
        
        s_axi_start         = 32'd0;
        {s_axi_inst_4, s_axi_inst_3,s_axi_inst_2,s_axi_inst_1,s_axi_inst_0} = 160'h00000000cc8a0003a0007ff3003003004a235017;
        #(`period * 10.0)
        s_axi_start         = 32'd1;
        wait(IRQ);
        #100
        
        s_axi_start         = 32'd0;
        {s_axi_inst_4, s_axi_inst_3,s_axi_inst_2,s_axi_inst_1,s_axi_inst_0} = 160'h00000000cc8a0003e0007ff3003003004a235017;
        #(`period * 10.0)
        s_axi_start         = 32'd1;
        wait(IRQ);
        #100
        
        s_axi_start         = 32'd0;
        {s_axi_inst_4, s_axi_inst_3,s_axi_inst_2,s_axi_inst_1,s_axi_inst_0} = 160'h00000000cc8a000420007ff3003003004a235017;
        #(`period * 10.0)
        s_axi_start         = 32'd1;
        wait(IRQ);
        #100
        
        s_axi_start         = 32'd0;
        {s_axi_inst_4, s_axi_inst_3,s_axi_inst_2,s_axi_inst_1,s_axi_inst_0} = 160'h00000000cc8a000460007ff3003003004a235017;
        #(`period * 10.0)
        s_axi_start         = 32'd1;
        wait(IRQ);
        #100
        
        s_axi_start         = 32'd0;
        {s_axi_inst_4, s_axi_inst_3,s_axi_inst_2,s_axi_inst_1,s_axi_inst_0} = 160'h00000000cc8a0004a0007ff3003003004a235017;
        #(`period * 10.0)
        s_axi_start         = 32'd1;
        wait(IRQ);
        #100
        
        //conv2d_7
        s_axi_start         = 32'd0;
        {s_axi_inst_4, s_axi_inst_3,s_axi_inst_2,s_axi_inst_1,s_axi_inst_0} = 160'h00000000cc880004e0007ff3003003004a234017;
        #(`period * 10.0)
        s_axi_start         = 32'd1;
        wait(IRQ);
        #100
        
        s_axi_start         = 32'd0;
        {s_axi_inst_4, s_axi_inst_3,s_axi_inst_2,s_axi_inst_1,s_axi_inst_0} = 160'h00000000cc88000520007ff3003003004a234017;
        #(`period * 10.0)
        s_axi_start         = 32'd1;
        wait(IRQ);
        #100
        
        s_axi_start         = 32'd0;
        {s_axi_inst_4, s_axi_inst_3,s_axi_inst_2,s_axi_inst_1,s_axi_inst_0} = 160'h00000000cc88000560007ff3003003004a234017;
        #(`period * 10.0)
        s_axi_start         = 32'd1;
        wait(IRQ);
        #100
        
        s_axi_start         = 32'd0;
        {s_axi_inst_4, s_axi_inst_3,s_axi_inst_2,s_axi_inst_1,s_axi_inst_0} = 160'h00000000cc880005a0007ff3003003004a234017;
        #(`period * 10.0)
        s_axi_start         = 32'd1;
        wait(IRQ);
        #100
        
        s_axi_start         = 32'd0;
        {s_axi_inst_4, s_axi_inst_3,s_axi_inst_2,s_axi_inst_1,s_axi_inst_0} = 160'h00000000cc880005e0007ff3003003004a234017;
        #(`period * 10.0)
        s_axi_start         = 32'd1;
        wait(IRQ);
        #100
        
        s_axi_start         = 32'd0;
        {s_axi_inst_4, s_axi_inst_3,s_axi_inst_2,s_axi_inst_1,s_axi_inst_0} = 160'h00000000cc88000620007ff3003003004a234017;
        #(`period * 10.0)
        s_axi_start         = 32'd1;
        wait(IRQ);
        #100
        
        s_axi_start         = 32'd0;
        {s_axi_inst_4, s_axi_inst_3,s_axi_inst_2,s_axi_inst_1,s_axi_inst_0} = 160'h00000000cc88000660007ff3003003004a234017;
        #(`period * 10.0)
        s_axi_start         = 32'd1;
        wait(IRQ);
        #100
        
        s_axi_start         = 32'd0;
        {s_axi_inst_4, s_axi_inst_3,s_axi_inst_2,s_axi_inst_1,s_axi_inst_0} = 160'h00000000cc880006a0007ff3003003004a234017;
        #(`period * 10.0)
        s_axi_start         = 32'd1;
        wait(IRQ);
        #100
        
        //conv2d_8
        s_axi_start         = 32'd0;
        {s_axi_inst_4, s_axi_inst_3,s_axi_inst_2,s_axi_inst_1,s_axi_inst_0} = 160'h00000000cc8a0006e0007ff30030030048215017;
        #(`period * 10.0)
        s_axi_start         = 32'd1;
        wait(IRQ);
        #100
        
        s_axi_start         = 32'd0;
        {s_axi_inst_4, s_axi_inst_3,s_axi_inst_2,s_axi_inst_1,s_axi_inst_0} = 160'h00000000cc8a000720007ff30030030048215017;
        #(`period * 10.0)
        s_axi_start         = 32'd1;
        wait(IRQ);
        #100
        
        //conv2d_9
        s_axi_start         = 32'd0;
        {s_axi_inst_4, s_axi_inst_3,s_axi_inst_2,s_axi_inst_1,s_axi_inst_0} = 160'h00000000cc88000760007ff3003023004a234017;
        #(`period * 10.0)
        s_axi_start         = 32'd1;
        wait(IRQ);
        #100
        
        
        //conv2d_10
        s_axi_start         = 32'd0;
        {s_axi_inst_4, s_axi_inst_3,s_axi_inst_2,s_axi_inst_1,s_axi_inst_0} = 160'h0000000000080007a00027f28028028048214004;
        #(`period * 10.0)
        s_axi_start         = 32'd1;
        wait(IRQ);
        #100
        
        //conv2d_8_2
        s_axi_start         = 32'd0;
        {s_axi_inst_4, s_axi_inst_3,s_axi_inst_2,s_axi_inst_1,s_axi_inst_0} = 160'h00000000cc880007b4007ff30030030048214017;
        #(`period * 10.0)
        s_axi_start         = 32'd1;
        wait(IRQ);
        #100
        
        s_axi_start         = 32'd0;
        {s_axi_inst_4, s_axi_inst_3,s_axi_inst_2,s_axi_inst_1,s_axi_inst_0} = 160'h00000000cc880007f4007ff30030030048214017;
        #(`period * 10.0)
        s_axi_start         = 32'd1;
        wait(IRQ);
        #100
        
        //conv2d_11
        s_axi_start         = 32'd0;
        {s_axi_inst_4, s_axi_inst_3,s_axi_inst_2,s_axi_inst_1,s_axi_inst_0} = 160'h00000000ccd2000834001ff30030130048415017;
        #(`period * 10.0)
        s_axi_start         = 32'd1;
        wait(IRQ);
        #100
        
        //conv2d_5_2
        s_axi_start         = 32'd0;
        {s_axi_inst_4, s_axi_inst_3,s_axi_inst_2,s_axi_inst_1,s_axi_inst_0} = 160'h00000000cc92000844007ff30030130052435217;
        #(`period * 10.0)
        s_axi_start         = 32'd1;
        wait(IRQ);
        #100
        
        s_axi_start         = 32'd0;
        {s_axi_inst_4, s_axi_inst_3,s_axi_inst_2,s_axi_inst_1,s_axi_inst_0} = 160'h00000000cc92000884007ff30030130052435217;
        #(`period * 10.0)
        s_axi_start         = 32'd1;
        wait(IRQ);
        #100
        
        s_axi_start         = 32'd0;
        {s_axi_inst_4, s_axi_inst_3,s_axi_inst_2,s_axi_inst_1,s_axi_inst_0} = 160'h00000000cc920008c4007ff30030130052435217;
        #(`period * 10.0)
        s_axi_start         = 32'd1;
        wait(IRQ);
        #100
        
        s_axi_start         = 32'd0;
        {s_axi_inst_4, s_axi_inst_3,s_axi_inst_2,s_axi_inst_1,s_axi_inst_0} = 160'h00000000cc92000904007ff30030130052435217;
        #(`period * 10.0)
        s_axi_start         = 32'd1;
        wait(IRQ);
        #100
        
        //conv2d_12
        s_axi_start         = 32'd0;
        {s_axi_inst_4,s_axi_inst_3,s_axi_inst_2,s_axi_inst_1,s_axi_inst_0} = 160'h000000006610000944007df2c02c02c052434017;
        #(`period * 10.0)
        s_axi_start         = 32'd1;
        wait(IRQ);
        #100
        
        s_axi_start         = 32'd0;
        {s_axi_inst_4,s_axi_inst_3,s_axi_inst_2,s_axi_inst_1,s_axi_inst_0} = 160'h000000006610000983007df2c02c02c052434017;
        #(`period * 10.0)
        s_axi_start         = 32'd1;
        wait(IRQ);
        #100
        
        s_axi_start         = 32'd0;
        {s_axi_inst_4,s_axi_inst_3,s_axi_inst_2,s_axi_inst_1,s_axi_inst_0} = 160'h0000000066100009c2007df2c02c02c052434017;
        #(`period * 10.0)
        s_axi_start         = 32'd1;
        wait(IRQ);
        #100
        
        s_axi_start         = 32'd0;
        {s_axi_inst_4,s_axi_inst_3,s_axi_inst_2,s_axi_inst_1,s_axi_inst_0} = 160'h000000006610000a01007df2c02c02c052434017;
        #(`period * 10.0)
        s_axi_start         = 32'd1;
        wait(IRQ);
        #100
        
        s_axi_start         = 32'd0;
        {s_axi_inst_4,s_axi_inst_3,s_axi_inst_2,s_axi_inst_1,s_axi_inst_0} = 160'h000000006610000a400047f2c02c02c052434017;
        #(`period * 10.0)
        s_axi_start         = 32'd1;
        wait(IRQ);
        #100
        
        //conv2d_13
        s_axi_start         = 32'd0;
        {s_axi_inst_4,s_axi_inst_3,s_axi_inst_2,s_axi_inst_1,s_axi_inst_0} = 160'h000000000010000a640027f2c02c12c050414004;
        #(`period * 10.0)
        s_axi_start         = 32'd1;
        wait(IRQ);
        #100*/
            s_axi_start         = 32'd0;
        
        end
        @(cb)
        for(int test_count = 0; test_count < 1 ; test_count+=1)begin
            addr_test = 32'h00080000 + 224*224*8*test_count;
            #10
            File.store_mem(addr_test, 224, 1, test_count, 224*224, 1.0, "Layer1", DRAM);
        end
      /*  @(cb)
        for(int test_count = 0; test_count <  `LAYER_1_IN_TILE_NUM*`LAYER_1_IN_TILE_NUM*(`LAYER_1_OCH>>2); test_count+=1)begin
            addr_test = 32'h02091800 + `TILE_SIZE*`TILE_SIZE*8*test_count;
            #10
            File.store_mem(addr_test, `TILE_SIZE, 4, test_count, `LAYER_1_IN_TILE_NUM*`LAYER_1_IN_TILE_NUM, 1024.0, "Layer1", DRAM);
        end
   
        @(cb)
        for(int test_count = 0; test_count <  `LAYER_2_IN_TILE_NUM*`LAYER_2_IN_TILE_NUM*(`LAYER_2_OCH>>2); test_count+=1)begin
            addr_test = 32'h02122000 + `TILE_SIZE*`TILE_SIZE*8*test_count;
            #10
            File.store_mem(addr_test, `TILE_SIZE, 4, test_count, `LAYER_2_IN_TILE_NUM*`LAYER_2_IN_TILE_NUM, 4096.0, "Layer2", DRAM);
        end

        
        @(cb)
        for(int test_count = 0; test_count <  `LAYER_3_IN_TILE_NUM*`LAYER_3_IN_TILE_NUM*(`LAYER_3_OCH>>2); test_count+=1)begin
            addr_test = 32'h0216a400 + `TILE_SIZE*`TILE_SIZE*8*test_count;
            #10
            File.store_mem(addr_test, `TILE_SIZE, 4, test_count, `LAYER_3_IN_TILE_NUM*`LAYER_3_IN_TILE_NUM, 4096.0, "Layer3", DRAM);
        end
        
       @(cb)
        for(int test_count = 0; test_count <  `LAYER_4_IN_TILE_NUM*`LAYER_4_IN_TILE_NUM*(`LAYER_4_OCH>>2); test_count+=1)begin
            addr_test = 32'h0218e600 + `LAYER4_TILE_SIZE*`LAYER4_TILE_SIZE*8*test_count;
            #10
            File.store_mem(addr_test, `LAYER4_TILE_SIZE, 4, test_count, `LAYER_4_IN_TILE_NUM*`LAYER_4_IN_TILE_NUM, 4096.0, "Layer4", DRAM);
        end
        @(cb)
        for(int test_count = 0; test_count <  `LAYER_5_IN_TILE_NUM*`LAYER_5_IN_TILE_NUM*(`LAYER_5_OCH>>2); test_count+=1)begin
            addr_test = 32'h021a2a00 + `LAYER5_TILE_SIZE*`LAYER5_TILE_SIZE*8*test_count;
            #10
            File.store_mem(addr_test, `LAYER5_TILE_SIZE, 4, test_count, `LAYER_5_IN_TILE_NUM*`LAYER_5_IN_TILE_NUM, 4096.0, "Layer5", DRAM);
        end
        @(cb)
        for(int test_count = 0; test_count <  `LAYER_6_IN_TILE_NUM*`LAYER_6_IN_TILE_NUM*(`LAYER_6_OCH>>2); test_count+=1)begin
            addr_test = 32'h021af200 + `LAYER6_TILE_SIZE*`LAYER6_TILE_SIZE*8*test_count;
            #10
            File.store_mem(addr_test, `LAYER6_TILE_SIZE, 4, test_count, `LAYER_6_IN_TILE_NUM*`LAYER_6_IN_TILE_NUM, 4096.0, "Layer6", DRAM);
        end
    
        @(cb)
        for(int test_count = 0; test_count <  `LAYER_7_IN_TILE_NUM*`LAYER_7_IN_TILE_NUM*(`LAYER_7_OCH>>2); test_count+=1)begin
            addr_test = 32'h021bba00 + `LAYER7_TILE_SIZE*`LAYER7_TILE_SIZE*8*test_count;
            #10
            File.store_mem(addr_test, `LAYER7_TILE_SIZE, 4, test_count, `LAYER_7_IN_TILE_NUM*`LAYER_7_IN_TILE_NUM, 4096.0, "Layer7", DRAM);
        end
        @(cb)
        for(int test_count = 0; test_count <  `LAYER_8_IN_TILE_NUM*`LAYER_8_IN_TILE_NUM*(`LAYER_8_OCH>>2); test_count+=1)begin
            addr_test = 32'h021c3a00 + `LAYER8_OUT_TILE_SIZE*`LAYER8_OUT_TILE_SIZE*8*test_count;
            #10
            File.store_mem(addr_test, `LAYER8_OUT_TILE_SIZE, 4, test_count, `LAYER_8_IN_TILE_NUM*`LAYER_8_IN_TILE_NUM, 4096.0, "Layer8", DRAM);
        end
        
        @(cb)
        for(int test_count = 0; test_count <  `LAYER_9_IN_TILE_NUM*`LAYER_9_IN_TILE_NUM*(`LAYER_9_OCH>>2); test_count+=1)begin
            addr_test = 32'h021c6c00 + `LAYER9_OUT_TILE_SIZE*`LAYER9_OUT_TILE_SIZE*8*test_count;
            #10
            File.store_mem(addr_test, `LAYER9_OUT_TILE_SIZE, 4, test_count, `LAYER_9_IN_TILE_NUM*`LAYER_9_IN_TILE_NUM, 1024.0, "Layer9", DRAM);
        end
        @(cb)
        for(int test_count = 0; test_count <  `LAYER_10_IN_TILE_NUM*`LAYER_10_IN_TILE_NUM*(`LAYER_10_OCH>>2); test_count+=1)begin
            addr_test = 32'h021cac00 + `LAYER10_OUT_TILE_SIZE*`LAYER10_OUT_TILE_SIZE*8*test_count;
            #10
            File.store_mem(addr_test, `LAYER10_OUT_TILE_SIZE, 4, test_count, `LAYER_10_IN_TILE_NUM*`LAYER_10_IN_TILE_NUM, 1024.0, "Layer10", DRAM);
        end
        
        
        @(cb)
        for(int test_count = 0; test_count <  `LAYER_8_IN_TILE_NUM*`LAYER_8_IN_TILE_NUM*(`LAYER_8_OCH>>2); test_count+=1)begin
            addr_test = 32'h021d2c00 + `LAYER8_OUT_TILE_SIZE_NO_PAD*`LAYER8_OUT_TILE_SIZE_NO_PAD*8*test_count;
            #10
            File.store_mem(addr_test, `LAYER8_OUT_TILE_SIZE_NO_PAD, 4, test_count, `LAYER_8_IN_TILE_NUM*`LAYER_8_IN_TILE_NUM, 4096.0, "Layer8_no_pad", DRAM);
        end
        @(cb)
        for(int test_count = 0; test_count <  `LAYER_11_IN_TILE_NUM*`LAYER_11_IN_TILE_NUM*(`LAYER_11_OCH>>2); test_count+=1)begin
            addr_test = 32'h021d4c00 + `LAYER11_OUT_TILE_SIZE*`LAYER11_OUT_TILE_SIZE*8*test_count;
            #10
            File.store_mem(addr_test, `LAYER11_OUT_TILE_SIZE, 4, test_count, `LAYER_11_IN_TILE_NUM*`LAYER_11_IN_TILE_NUM, 2048.0, "Layer11", DRAM);
        end
        @(cb)
          for(int test_count = 0; test_count <  `LAYER_5_IN_TILE_NUM*`LAYER_5_IN_TILE_NUM*(`LAYER_5_OCH>>2); test_count+=1)begin
              addr_test = 32'h021e9000 + `LAYER5_TILE_SIZE_NO_POOL*`LAYER5_TILE_SIZE_NO_POOL*8*test_count;
              #10
              File.store_mem(addr_test, `LAYER5_TILE_SIZE_NO_POOL, 4, test_count, `LAYER_5_IN_TILE_NUM*`LAYER_5_IN_TILE_NUM, 2048.0, "Layer5_no_pool", DRAM);
          end
        @(cb)
        for(int test_count = 0; test_count <  `LAYER_12_IN_TILE_NUM*`LAYER_12_IN_TILE_NUM*(`LAYER_12_OCH>>2); test_count+=1)begin
            addr_test = 32'h02216900 + `LAYER12_OUT_TILE_SIZE*`LAYER12_OUT_TILE_SIZE*8*test_count;
            #10
            File.store_mem(addr_test, `LAYER12_OUT_TILE_SIZE, 4, test_count, `LAYER_12_IN_TILE_NUM*`LAYER_12_IN_TILE_NUM, 2048.0, "Layer12", DRAM);
        end
        @(cb)
        for(int test_count = 0; test_count <  `LAYER_13_IN_TILE_NUM*`LAYER_13_IN_TILE_NUM*(`LAYER_13_OCH>>2); test_count+=1)begin
            addr_test = 32'h02226900 + `LAYER13_OUT_TILE_SIZE*`LAYER13_OUT_TILE_SIZE*8*test_count;
            #10
            File.store_mem(addr_test, `LAYER13_OUT_TILE_SIZE, 4, test_count, `LAYER_13_IN_TILE_NUM*`LAYER_13_IN_TILE_NUM, 1024.0, "Layer13", DRAM);
        end*/
      
        
//        @(cb)
        
//        File.dump_feature(32'h02091800, "./Output_data/Hex/", 4, `LAYER_1_OCH, `TILE_SIZE, `LAYER_1_IN_TILE_NUM, "Layer1", DRAM);
//        File.dump_feature(32'h02122000, "./Output_data/Hex/", 4, `LAYER_2_OCH, `TILE_SIZE, `LAYER_2_IN_TILE_NUM, "Layer2", DRAM);
//        File.dump_feature(32'h0216a400, "./Output_data/Hex/", 4, `LAYER_3_OCH, `TILE_SIZE, `LAYER_3_IN_TILE_NUM, "Layer3", DRAM);
//        File.dump_feature(32'h0218e600, "./Output_data/Hex/", 4, `LAYER_4_OCH, `LAYER4_TILE_SIZE, `LAYER_4_IN_TILE_NUM, "Layer4", DRAM);
//        File.dump_feature(32'h021a2a00, "./Output_data/Hex/", 4, `LAYER_5_OCH, `LAYER5_TILE_SIZE, `LAYER_5_IN_TILE_NUM, "Layer5", DRAM);
//        File.dump_feature(32'h021af200, "./Output_data/Hex/", 4, `LAYER_6_OCH, `LAYER6_TILE_SIZE, `LAYER_6_IN_TILE_NUM, "Layer6", DRAM);
//        File.dump_feature(32'h021bba00, "./Output_data/Hex/", 4, `LAYER_7_OCH, `LAYER7_TILE_SIZE, `LAYER_7_IN_TILE_NUM, "Layer7", DRAM);
//        File.dump_feature(32'h021c3a00, "./Output_data/Hex/", 4, `LAYER_8_OCH, `LAYER8_OUT_TILE_SIZE, `LAYER_8_IN_TILE_NUM, "Layer8", DRAM);
        #100
        ##100 $stop;
    end
endmodule