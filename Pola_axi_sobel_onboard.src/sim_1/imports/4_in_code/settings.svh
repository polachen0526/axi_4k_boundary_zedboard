`ifndef SETTINGS_SVH
`define SETTINGS_SVH
//------------------------------------------
// YoloV3-Tiny MIT 256x256 V2
//------------------------------------------
    //Layer-1 Information
    `define type        3'd0    //Conv.

    `define quant       5'd17
    `define if_bw       5'd16
    `define of_bw       5'd16
    `define wgt_bw      5'd16
    `define MANTISSA    11
    `define batch       5'd0
    `define ts_if       6'd32
    `define ts_of       6'd32
    `define k_size      4'd3
    `define k_strd      3'd1
    `define reshape     2'd2
    `define C_PAD_type  1'd1    //0:Internal 1:External
    `define N_PAD_type  1'd1
    `define C_PAD_value 3'd1
    `define N_PAD_value 3'd1
    `define pool_mode   1'd0
    `define pool_size   2'd2
    `define pool_strd   2'd2
    `define unuse       34'd0


    //Conv          68
    //Conv+Reshape  153
    //Conv+Pooling+Reshape  121
    //Conv + Reshape + IOBTI16 + WBIT8 154
    //Conv + Reshape + IBTI8 + WBIT8 + OBIT16 76
    //Conv + Reshape + IBTI8 + WBIT8 + OBIT8  52
    //Conv + Reshape + Cal 73
    //Conv + Reshape + IBTI16 + WBIT16 + OBIT8  105
    `define inst_num 32'd1024

    `define ich 8
    `define och 16
    `define tile_num    16  //16
    `define ich_offset  32'd2048//32'h0000_1880
    `define pad_offset  32'd272 //32'h0000_01d0
    `define och_offset  32'd2048//32'h0000_1880

    `define path_if_0   "C:/Users/bboga/Desktop/new_info/layer1_4x4.txt"
    `define path_of     "./DNN.dat" //"./tile_ans/0_tile.txt"
    `define path_wgt    "C:/Users/bboga/Desktop/new_info/Weight/weight_1.txt" // ./wgt/conv1_kernel.txt"
    
    `define path_if_1   "/home/m063040083/Desktop/Dataset/Yolo_Benchmark/Bit-Level/feat/fx16/tile_no_pad_1.txt"
    `define path_if_2   "/home/m063040083/Desktop/Dataset/Yolo_Benchmark/Bit-Level/feat/fx16/tile_no_pad_16.txt"
    `define path_if_3   "/home/m063040083/Desktop/Dataset/Yolo_Benchmark/Bit-Level/feat/fx16/tile_no_pad_17.txt"
    `define path_pad    "/home/m063040083/Desktop/Dataset/Yolo_Benchmark/Bit-Level/pad/fx16/conv0_tile0.txt"
    `define path_bias   "/home/m063040083/Desktop/Dataset/Yolo_Benchmark/Bit-Level/bias/0.txt"
    `define path_inst   "/home/f5009/Desktop/Master/Pad/test_inst.txt"
    `define path_concat "/home/m063040083/Desktop/Dataset/Yolo_Benchmark/Bit-Level/hwres/result_concat.txt"

    //Conv + Reshape
    `define addr_inst   32'h0001_0000 //h1000_4000
    `define addr_if     32'h0200_1000 // h0110_2800
    `define addr_of     32'h0136_7f00
    `define addr_wgt    32'h0100_2000
    `define addr_bias   32'h0180_cf60
    `define addr_pad    32'h0156_7a00
`endif