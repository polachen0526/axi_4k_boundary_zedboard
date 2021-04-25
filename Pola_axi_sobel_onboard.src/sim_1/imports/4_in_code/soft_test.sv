`timescale 1ns / 1ns
`define period 10.0
`define data_path "/home/pola/Desktop/Pola_axi_sobel_onboard/Pola_axi_sobel_onboard.srcs/sim_1/imports/8_in_8_out_data/data.txt"

function automatic real SF_CONV(
    input signed [16:0] addr_value_0,
    input signed [16:0] addr_value_1,
    input signed [16:0] addr_value_2,
    input signed [16:0] addr_value_3,
    input signed [16:0] addr_value_4,
    input signed [16:0] addr_value_5,
    input signed [16:0] addr_value_6,
    input signed [16:0] addr_value_7,
    input signed [16:0] addr_value_8,
    input signed [2:0]  weight_0,
    input signed [2:0]  weight_1,
    input signed [2:0]  weight_2,
    input signed [2:0]  weight_3,
    input signed [2:0]  weight_4,
    input signed [2:0]  weight_5,
    input signed [2:0]  weight_6,
    input signed [2:0]  weight_7,
    input signed [2:0]  weight_8
);
    begin
       SF_CONV = (addr_value_0*weight_0) + (addr_value_1*weight_1) + (addr_value_2*weight_2) + (addr_value_3*weight_3) + (addr_value_4*weight_4)+
                 (addr_value_5*weight_5) + (addr_value_6*weight_6) + (addr_value_7*weight_7) + (addr_value_8*weight_8); 
    end
endfunction

module soft_test;
    integer fp;
    integer f_of,f_of1;
    integer i,j;
    integer count;
    real  r,g,b,u,ans;
    real  r1,g1,b1,u1,ans1;
    reg clk ;
    reg [255:0] reg_array [0:12768];
    reg signed [16:0] R_CH_padding [0:51075];
    reg signed [16:0] G_CH_padding [0:51075];
    reg signed [16:0] B_CH_padding [0:51075];
    reg signed [16:0] U_CH_padding [0:51075];
    reg signed [2:0] kernel_weight_v_0 = -1;//v
    reg signed [2:0] kernel_weight_v_1 = 0;
    reg signed [2:0] kernel_weight_v_2 = 1;
    reg signed [2:0] kernel_weight_v_3 = -2;
    reg signed [2:0] kernel_weight_v_4 = 0;
    reg signed [2:0] kernel_weight_v_5 = 2;
    reg signed [2:0] kernel_weight_v_6 = -1;
    reg signed [2:0] kernel_weight_v_7 = 0;
    reg signed [2:0] kernel_weight_v_8 = 1;
    reg signed [2:0] kernel_weight_h_0 = 1;//h
    reg signed [2:0] kernel_weight_h_1 = 2;
    reg signed [2:0] kernel_weight_h_2 = 1;
    reg signed [2:0] kernel_weight_h_3 = 0;
    reg signed [2:0] kernel_weight_h_4 = 0;
    reg signed [2:0] kernel_weight_h_5 = 0;
    reg signed [2:0] kernel_weight_h_6 = -1;
    reg signed [2:0] kernel_weight_h_7 = -2;
    reg signed [2:0] kernel_weight_h_8 = -1;
    initial begin
        count = 0;
        $readmemh(`data_path,reg_array);
        #(`period);
        for(i=0;i<12769;i=i+1)begin
            R_CH_padding[(i*4)+0] = {1'b0,reg_array[i][15:0]};
            G_CH_padding[(i*4)+0] = {1'b0,reg_array[i][31:16]};
            B_CH_padding[(i*4)+0] = {1'b0,reg_array[i][47:32]};
            U_CH_padding[(i*4)+0] = {1'b0,reg_array[i][63:48]};
            R_CH_padding[(i*4)+1] = {1'b0,reg_array[i][79:64]};
            G_CH_padding[(i*4)+1] = {1'b0,reg_array[i][95:80]};
            B_CH_padding[(i*4)+1] = {1'b0,reg_array[i][111:96]};
            U_CH_padding[(i*4)+1] = {1'b0,reg_array[i][127:112]};
            R_CH_padding[(i*4)+2] = {1'b0,reg_array[i][143:128]};
            G_CH_padding[(i*4)+2] = {1'b0,reg_array[i][159:144]};
            B_CH_padding[(i*4)+2] = {1'b0,reg_array[i][175:160]};
            U_CH_padding[(i*4)+2] = {1'b0,reg_array[i][191:176]};
            R_CH_padding[(i*4)+3] = {1'b0,reg_array[i][207:192]};
            G_CH_padding[(i*4)+3] = {1'b0,reg_array[i][223:208]};
            B_CH_padding[(i*4)+3] = {1'b0,reg_array[i][239:224]};
            U_CH_padding[(i*4)+3] = {1'b0,reg_array[i][255:240]};
        end
        f_of  = $fopen("/home/pola/Desktop/Pola_axi_sobel_onboard/Pola_axi_sobel_onboard.sim/sim_1/behav/xsim/Output_data/Layer1/softans_v.csv", "w");
        f_of1 = $fopen("/home/pola/Desktop/Pola_axi_sobel_onboard/Pola_axi_sobel_onboard.sim/sim_1/behav/xsim/Output_data/Layer1/softans_h.csv", "w");
        for(i=0;i<224;i=i+1)begin
            for(j=0;j<224;j=j+1)begin
                r  =  SF_CONV(.addr_value_0(R_CH_padding[(i*226)+j+0]),
                              .addr_value_1(R_CH_padding[(i*226)+j+1]),
                              .addr_value_2(R_CH_padding[(i*226)+j+2]),
                              .addr_value_3(R_CH_padding[(i*226)+j+226]),
                              .addr_value_4(R_CH_padding[(i*226)+j+227]),
                              .addr_value_5(R_CH_padding[(i*226)+j+228]),
                              .addr_value_6(R_CH_padding[(i*226)+j+452]),
                              .addr_value_7(R_CH_padding[(i*226)+j+453]),
                              .addr_value_8(R_CH_padding[(i*226)+j+454]),
                              .weight_0(kernel_weight_v_0),
                              .weight_1(kernel_weight_v_1),
                              .weight_2(kernel_weight_v_2),
                              .weight_3(kernel_weight_v_3),
                              .weight_4(kernel_weight_v_4),
                              .weight_5(kernel_weight_v_5),
                              .weight_6(kernel_weight_v_6),
                              .weight_7(kernel_weight_v_7),
                              .weight_8(kernel_weight_v_8));
                b  =  SF_CONV(.addr_value_0(B_CH_padding[(i*226)+j+0]),
                              .addr_value_1(B_CH_padding[(i*226)+j+1]),
                              .addr_value_2(B_CH_padding[(i*226)+j+2]),
                              .addr_value_3(B_CH_padding[(i*226)+j+226]),
                              .addr_value_4(B_CH_padding[(i*226)+j+227]),
                              .addr_value_5(B_CH_padding[(i*226)+j+228]),
                              .addr_value_6(B_CH_padding[(i*226)+j+452]),
                              .addr_value_7(B_CH_padding[(i*226)+j+453]),
                              .addr_value_8(B_CH_padding[(i*226)+j+454]),
                              .weight_0(kernel_weight_v_0),
                              .weight_1(kernel_weight_v_1),
                              .weight_2(kernel_weight_v_2),
                              .weight_3(kernel_weight_v_3),
                              .weight_4(kernel_weight_v_4),
                              .weight_5(kernel_weight_v_5),
                              .weight_6(kernel_weight_v_6),
                              .weight_7(kernel_weight_v_7),
                              .weight_8(kernel_weight_v_8));
                g  =  SF_CONV(.addr_value_0(G_CH_padding[(i*226)+j+0]),
                              .addr_value_1(G_CH_padding[(i*226)+j+1]),
                              .addr_value_2(G_CH_padding[(i*226)+j+2]),
                              .addr_value_3(G_CH_padding[(i*226)+j+226]),
                              .addr_value_4(G_CH_padding[(i*226)+j+227]),
                              .addr_value_5(G_CH_padding[(i*226)+j+228]),
                              .addr_value_6(G_CH_padding[(i*226)+j+452]),
                              .addr_value_7(G_CH_padding[(i*226)+j+453]),
                              .addr_value_8(G_CH_padding[(i*226)+j+454]),
                              .weight_0(kernel_weight_v_0),
                              .weight_1(kernel_weight_v_1),
                              .weight_2(kernel_weight_v_2),
                              .weight_3(kernel_weight_v_3),
                              .weight_4(kernel_weight_v_4),
                              .weight_5(kernel_weight_v_5),
                              .weight_6(kernel_weight_v_6),
                              .weight_7(kernel_weight_v_7),
                              .weight_8(kernel_weight_v_8));
                u  =  SF_CONV(.addr_value_0(U_CH_padding[(i*226)+j+0]),
                              .addr_value_1(U_CH_padding[(i*226)+j+1]),
                              .addr_value_2(U_CH_padding[(i*226)+j+2]),
                              .addr_value_3(U_CH_padding[(i*226)+j+226]),
                              .addr_value_4(U_CH_padding[(i*226)+j+227]),
                              .addr_value_5(U_CH_padding[(i*226)+j+228]),
                              .addr_value_6(U_CH_padding[(i*226)+j+452]),
                              .addr_value_7(U_CH_padding[(i*226)+j+453]),
                              .addr_value_8(U_CH_padding[(i*226)+j+454]),
                              .weight_0(kernel_weight_v_0),
                              .weight_1(kernel_weight_v_1),
                              .weight_2(kernel_weight_v_2),
                              .weight_3(kernel_weight_v_3),
                              .weight_4(kernel_weight_v_4),
                              .weight_5(kernel_weight_v_5),
                              .weight_6(kernel_weight_v_6),
                              .weight_7(kernel_weight_v_7),
                              .weight_8(kernel_weight_v_8));
                ans = r+b+g+u;
                if(ans>255)begin
                    ans=255;
                end else if(ans<0) begin
                    ans = 0;
                end else begin
                    ans = ans;
                end
                r1 =  SF_CONV(.addr_value_0(R_CH_padding[(i*226)+j+0]),
                              .addr_value_1(R_CH_padding[(i*226)+j+1]),
                              .addr_value_2(R_CH_padding[(i*226)+j+2]),
                              .addr_value_3(R_CH_padding[(i*226)+j+226]),
                              .addr_value_4(R_CH_padding[(i*226)+j+227]),
                              .addr_value_5(R_CH_padding[(i*226)+j+228]),
                              .addr_value_6(R_CH_padding[(i*226)+j+452]),
                              .addr_value_7(R_CH_padding[(i*226)+j+453]),
                              .addr_value_8(R_CH_padding[(i*226)+j+454]),
                              .weight_0(kernel_weight_h_0),
                              .weight_1(kernel_weight_h_1),
                              .weight_2(kernel_weight_h_2),
                              .weight_3(kernel_weight_h_3),
                              .weight_4(kernel_weight_h_4),
                              .weight_5(kernel_weight_h_5),
                              .weight_6(kernel_weight_h_6),
                              .weight_7(kernel_weight_h_7),
                              .weight_8(kernel_weight_h_8));
                b1 =  SF_CONV(.addr_value_0(B_CH_padding[(i*226)+j+0]),
                              .addr_value_1(B_CH_padding[(i*226)+j+1]),
                              .addr_value_2(B_CH_padding[(i*226)+j+2]),
                              .addr_value_3(B_CH_padding[(i*226)+j+226]),
                              .addr_value_4(B_CH_padding[(i*226)+j+227]),
                              .addr_value_5(B_CH_padding[(i*226)+j+228]),
                              .addr_value_6(B_CH_padding[(i*226)+j+452]),
                              .addr_value_7(B_CH_padding[(i*226)+j+453]),
                              .addr_value_8(B_CH_padding[(i*226)+j+454]),
                              .weight_0(kernel_weight_h_0),
                              .weight_1(kernel_weight_h_1),
                              .weight_2(kernel_weight_h_2),
                              .weight_3(kernel_weight_h_3),
                              .weight_4(kernel_weight_h_4),
                              .weight_5(kernel_weight_h_5),
                              .weight_6(kernel_weight_h_6),
                              .weight_7(kernel_weight_h_7),
                              .weight_8(kernel_weight_h_8));
                g1 =  SF_CONV(.addr_value_0(G_CH_padding[(i*226)+j+0]),
                              .addr_value_1(G_CH_padding[(i*226)+j+1]),
                              .addr_value_2(G_CH_padding[(i*226)+j+2]),
                              .addr_value_3(G_CH_padding[(i*226)+j+226]),
                              .addr_value_4(G_CH_padding[(i*226)+j+227]),
                              .addr_value_5(G_CH_padding[(i*226)+j+228]),
                              .addr_value_6(G_CH_padding[(i*226)+j+452]),
                              .addr_value_7(G_CH_padding[(i*226)+j+453]),
                              .addr_value_8(G_CH_padding[(i*226)+j+454]),
                              .weight_0(kernel_weight_h_0),
                              .weight_1(kernel_weight_h_1),
                              .weight_2(kernel_weight_h_2),
                              .weight_3(kernel_weight_h_3),
                              .weight_4(kernel_weight_h_4),
                              .weight_5(kernel_weight_h_5),
                              .weight_6(kernel_weight_h_6),
                              .weight_7(kernel_weight_h_7),
                              .weight_8(kernel_weight_h_8));
                u1 =  SF_CONV(.addr_value_0(U_CH_padding[(i*226)+j+0]),
                              .addr_value_1(U_CH_padding[(i*226)+j+1]),
                              .addr_value_2(U_CH_padding[(i*226)+j+2]),
                              .addr_value_3(U_CH_padding[(i*226)+j+226]),
                              .addr_value_4(U_CH_padding[(i*226)+j+227]),
                              .addr_value_5(U_CH_padding[(i*226)+j+228]),
                              .addr_value_6(U_CH_padding[(i*226)+j+452]),
                              .addr_value_7(U_CH_padding[(i*226)+j+453]),
                              .addr_value_8(U_CH_padding[(i*226)+j+454]),
                              .weight_0(kernel_weight_h_0),
                              .weight_1(kernel_weight_h_1),
                              .weight_2(kernel_weight_h_2),
                              .weight_3(kernel_weight_h_3),
                              .weight_4(kernel_weight_h_4),
                              .weight_5(kernel_weight_h_5),
                              .weight_6(kernel_weight_h_6),
                              .weight_7(kernel_weight_h_7),
                              .weight_8(kernel_weight_h_8));
                ans1 = r1+b1+g1+u1;
                if(ans1>255)begin
                    ans1=255;
                end else if(ans1<0) begin
                    ans1 = 0;
                end else begin
                    ans1 = ans1;
                end
                count = count+1;
                $fwrite(f_of, "%f", ans);
                $fwrite(f_of1, "%f", ans1);
                if(j!=223)begin
                   $fwrite(f_of, ","); 
                   $fwrite(f_of1, ","); 
                end
                $display("count %d ans is",count,ans);
                $display("count %d ans1 is",count,ans1);
            end     
            $fwrite(f_of, "\n");
            $fwrite(f_of1, "\n");
        end
        $fclose(f_of);
        $fclose(f_of1);
        $stop;
    end

    always begin
		#(`period/2.0) clk <= ~clk;
    end

endmodule