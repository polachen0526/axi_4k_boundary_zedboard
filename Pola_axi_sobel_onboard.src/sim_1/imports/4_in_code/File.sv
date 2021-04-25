`ifndef FILE_SV
`define FILE_SV

`include "DRAM_Slave.sv"
`include "settings.svh"

`define square(a) a*a
`define step_loop(i, bound) for(i=0; i<bound; i=i+1)
`define TILE_SIZE 34
`define OUTPUT_TILE_SIZE 32
`define BYTE_SIZE 8
`define DATA_WIDTH 2
`define BUS_SIZE 64

class File;
    real    tmp_r;
    integer scan;
    integer ptr;
    integer offset;
    integer tmp_i;
    logic [15:0] tmp16b;
    logic [63:0] tmp64b;

    task load_feature(
        input integer addr,
        input string  path_name,
        input integer channel_per_data,
        input integer in_channel_num,
        input integer tile_s, //include pad size
        input integer tile_n, //Input feature map need tile count
        input string  layer,
        ref DRAM DRAM
    );
        integer i, j, k, f_if, addr_index;
        string filename;
        logic [127:0] tmp_128;
        filename = {path_name, layer, ".txt"};
        f_if = $fopen(filename, "r");
        if(f_if == 0)
            $finish;
        
        for(i = 0; i < in_channel_num/channel_per_data; i+=1)begin
            for(j = 0; j < tile_s*tile_s*tile_n*tile_n; j+=1)begin
                $fscanf(f_if, "%h", tmp_128[`BUS_SIZE-1 : 0]);
                for(k = 0; k < channel_per_data*2; k+=1)begin
                    addr_index = addr+(i*tile_s*tile_s*tile_n*tile_n+j)*channel_per_data*2+k;
                    DRAM.mem[addr_index] = tmp_128[k*`BYTE_SIZE+:`BYTE_SIZE];
                end
            end
        end

        $fclose(f_if);
    endtask

    task dump_feature(
        input integer addr,
        input string  path_name,
        input integer channel_per_data,
        input integer out_channel_num,
        input integer tile_s, //include pad size
        input integer tile_n, //Input feature map need tile count
        input string  layer,
        ref DRAM DRAM
    );
  
        integer f_of, addr_index, i, j, k;
        string filename;
        logic [127:0] data_tmp;
        filename = {path_name, layer, ".txt"};
        f_of = $fopen(filename, "w");
        if(f_of == 0)
            $finish;
        
        for(i = 0; i < out_channel_num/channel_per_data; i+=1)begin
            for(j = 0; j < tile_s*tile_s*tile_n*tile_n; j+=1)begin
                for(k = 0; k < channel_per_data*2; k+=1)begin
                    addr_index = addr+(i*tile_s*tile_s*tile_n*tile_n+j)*channel_per_data*2+k;
                    data_tmp[k*`BYTE_SIZE+:`BYTE_SIZE] = DRAM.mem[addr_index];
                end
                $fwrite(f_of, "%h\n", data_tmp[`BUS_SIZE-1:0]);
            end
        end

        $fclose(f_of);
    endtask


    task load_act(
        input string filename,
        input integer addr,
        input integer tile_n,
        ref DRAM DRAM
    );
        integer f_if[`tile_num*`tile_num];
        integer tr; //Row of Tile
        integer tc; //Column of Tile
        integer ic; //Input Channel
        integer tx;
        integer ty;
        integer ich_bound;
        integer count = 0;
        string path_if;
        integer if_offset;
        integer t;
        logic [31:0] tmp32b;

//        path_if = `path_if_0;
        f_if[0] = $fopen(filename, "rb");

        for(t = 0; t < tile_n; t+=1)begin
            for(ty = 0; ty < `TILE_SIZE; ty += 1)begin
                for(tx = 0; tx < `TILE_SIZE ; tx += 1)begin
                    for(ic = 0; ic < 4; ic += 1)begin
                        $fscanf(f_if[0], "%h", tmp32b);
                        if_offset = (count++)*4 + addr;
                        {DRAM.mem[if_offset+3], DRAM.mem[if_offset+2],DRAM.mem[if_offset+1], DRAM.mem[if_offset]} = tmp32b;
                    end
                end
            end
        end
        $fclose(f_if[0]);


        // `step_loop(tr, `reshape)
        //     `step_loop(tc, `reshape)
        //         f_if[tr*`tile_num+tc] = $fopen(path_if[tr*`reshape+tc], "rb");

        // `step_loop(tr, `reshape)
        //     `step_loop(tc, `reshape)
        //         `step_loop(ic, ich_bound)
        //             `step_loop(ptr, `square(`ts_if) / (`square(`reshape))) begin
        //                 offset = `addr_if + ((tr*`tile_num+tc)*ich_bound + ic) * `ich_offset + ptr*2;
        //                 scan  = $fscanf(f_if[tr*`tile_num+tc], "%h", tmp16b);
        //                 {DRAM.mem[offset+1], DRAM.mem[offset]} = tmp16b;
        //                 if(tr==0 && tc == 1)
        //                     $display("%h, data = %h", offset, tmp16b);
        //             end

        // `step_loop(tr, `reshape)
        //     `step_loop(tc, `reshape)
        //         $fclose(f_if[tr*`tile_num+tc]);
    endtask

    task load_pad (
        ref DRAM DRAM
    );
        integer ic;
        integer f_pad;
        integer pad_bound;

        pad_bound = (`ts_if + `C_PAD_value) * `C_PAD_value * 4;

        f_pad = $fopen(`path_pad, "rb");

        `step_loop(ic, `ich)
            `step_loop(ptr, pad_bound) begin
                offset = `addr_pad + ic*`pad_offset + ptr*2;
                scan = $fscanf(f_pad, "%h", tmp16b);
                {DRAM.mem[offset+1], DRAM.mem[offset]} = tmp16b;
            end

        $fclose(f_pad);
    endtask

    task load_wgt (
        input string filename,
        input integer k_num,
        input integer addr,
        ref DRAM DRAM
    );
        integer f_wgt;
        //integer wgt_bound;
        integer count;
        integer index = 0;
        integer wgt_addr = addr;
        logic [15:0] w_tmp;
        
        //wgt_bound = `ich * `och * `square(`k_size);

        f_wgt = $fopen(filename, "rb");

        for(count = 0; count < k_num; count +=1)begin
            $fscanf(f_wgt, "%h", w_tmp);
            {DRAM.mem[wgt_addr+1], DRAM.mem[wgt_addr]} = w_tmp;
            wgt_addr += 2;
        end
        $fclose(f_wgt);
    endtask

    task load_bias (
        ref DRAM DRAM
    );
        integer f_bias;

        f_bias = $fopen(`path_bias, "rb");

        `step_loop(ptr, `och) begin
            offset = `addr_bias + ptr*2;
            scan = $fscanf(f_bias, "%h", tmp16b);
            {DRAM.mem[offset+1], DRAM.mem[offset]} = tmp16b;
        end

        $fclose(f_bias);
    endtask

    task load_inst (
        input integer inst_addr,
        input integer inst_num,
        input string  filename,
        ref DRAM DRAM
    );
        integer f_inst;
        integer offset;
        integer index=0;
        //logic [255:0] tmp256b;
        logic [255:0] tmp256b;
        
        f_inst  = $fopen(filename,  "rb");

        for(ptr=0; ptr < inst_num; ptr+=1)begin
            offset = inst_addr+ptr*32;
            $fscanf(f_inst, "%h", tmp256b);
            for(int index=0; index < 32; index+=1)begin
                DRAM.mem[offset+index] = tmp256b[index*8+:8];
            end
        end

        // `step_loop(ptr, `inst_num) begin
        //     offset = `addr_inst + ptr*8;
        //     scan = $fscanf(f_inst, "%h", tmp64b);
        //     {DRAM.mem[offset+7], DRAM.mem[offset+6],
        //     DRAM.mem[offset+5], DRAM.mem[offset+4],
        //     DRAM.mem[offset+3], DRAM.mem[offset+2],
        //     DRAM.mem[offset+1], DRAM.mem[offset]  } = tmp64b;
        // end

        $fclose(f_inst);
    endtask

    task compareAns(
        ref DRAM DRAM
    );
        integer f_of;
        integer of_c;
        integer of_x;
        integer of_y;
        integer of_offset;
        integer count = 0;

        f_of = $fopen(`path_of, "rb");

        for(of_c = 0; of_c < `och; of_c+=1)
            for(of_y = 0; of_y < `OUTPUT_TILE_SIZE; of_y+=1)
                for(of_x = 0; of_x < `OUTPUT_TILE_SIZE; of_x+=1)begin
                    of_offset = `addr_of + (count++)*2;
                    if(!$fscanf(f_of, "%f", tmp_r))begin
                            $display("Error of_c = %d, of_y = %d, of_x = %d\n",of_c,of_y,of_x);
                            $fclose(f_of);
                            $finish;
                    end
                    tmp_i = {DRAM.mem[of_offset+1], DRAM.mem[of_offset]};
                    if(1-(tmp_i/tmp_r) > 0.1)
                        $display("Output of_c = %d, of_y = %d, of_x = %d,HW Data = %d, Real Data = %f\n",of_c,of_y,of_x,tmp_i,tmp_r);
                    else if(1-(tmp_i/tmp_r) < 0.1)
                        $display("Output of_c = %d, of_y = %d, of_x = %d,HW Data = %d, Real Data = %f\n",of_c,of_y,of_x,tmp_i,tmp_r);
                end
        $fclose(f_of);
    endtask

    task store_act (
        input       mode,
        ref DRAM    DRAM
    );
        integer oc;
        integer toc;
        integer addr_of;

        integer och_bound;
        integer toch_bound;
        integer ts_of_bound;
        integer f_of;

        if(`of_bw == 16) begin
            och_bound  = `och;
            toch_bound = 1;
        end else begin
            och_bound  = `och / 2;
            toch_bound = 2;
        end

        if((`k_strd == 2)/* || (`pool_strd == 2)*/)
            ts_of_bound = `square(`ts_of / 2);
        else
            ts_of_bound = `square(`ts_of);

        if(mode) begin
            addr_of = `addr_of + 32'h0100_0000;
            f_of = $fopen(`path_concat, "w");
        end else begin
            addr_of = `addr_of;
            f_of = $fopen(`path_of, "w");
        end

        `step_loop(oc, och_bound)
            `step_loop(toc, toch_bound)
                `step_loop(ptr, ts_of_bound) begin
                    offset = `addr_of + oc*`och_offset + ptr*2 + toc;
                    if(`of_bw == 16)
                        tmp16b = {DRAM.mem[offset+1], DRAM.mem[offset]};
                    else
                        tmp16b = $signed(DRAM.mem[offset]);
                    $fwrite(f_of, "%f\n", $signed(tmp16b) / 256.0);
                end
        $fclose(f_of);
    endtask

    task check_unknow (
        input integer     addr,
        input integer     tile_size,
        input integer     data_width,
        input integer     out_tile_num,
        output logic      have_unknow,
        ref DRAM    DRAM
    );
        integer index, index_addr;
        integer data_tmp, index_data;
        index_addr = addr;
        for(index = 0; index < tile_size*tile_size*out_tile_num; index+=1)begin
            for(index_data = 0; index_data < data_width; index_data += 1)begin
                if(index_data == 0)
                    data_tmp = DRAM.mem[index_addr++];
                else
                    data_tmp += DRAM.mem[index_addr++] << (8*index_data);
            end
            if(data_tmp === 'x)begin
                $display("Unknow Value\n");
                have_unknow = 1'b1;
                break;
            end
            else
                have_unknow = 1'b0;
        end
    endtask
    
    task set_mem_unknow(
        input integer     addr,
        input integer     tile_size,
        input integer     data_width,
        input integer     out_tile_num,
        ref DRAM    DRAM
    );
        integer index, index_addr;
        integer index_data;
        index_addr = addr;
        for(index = 0; index < tile_size*tile_size*out_tile_num; index+=1)begin
            for(index_data = 0; index_data < data_width; index_data += 1)begin
                DRAM.mem[index_addr++] = 'x;
            end
        end
    endtask

    task store_mem (
        input integer     addr,
        input integer     tile_size,
        input integer     data_depth,
        input integer     index,
        input integer     next_in_tile_num,
        input real        qant,
        input string      dir_name,
        ref DRAM    DRAM
    );
        integer index_x, index_y;
        integer index_data;
        logic signed [15:0] data_tmp;
        integer index_addr = addr;
        integer f_of;
        integer och;
        integer int_tmp;
        string filename, num, och_index;
        real tmp;

        for(och = 0; och < data_depth; och+=1)begin
            num.itoa(index%next_in_tile_num);
            och_index.itoa(och+(index/next_in_tile_num)*data_depth);
            //filename = {"./Output_data/", dir_name, "/", och_index, "_", num, ".csv"};
            filename = {"./Output_data/", dir_name, "/", och_index, "_", "0", ".csv"};
            f_of = $fopen(filename, "w");
            for(index_y = 0; index_y < tile_size; index_y += 1)
                for(index_x = 0; index_x < tile_size; index_x += 1)begin
                    data_tmp = 0;
                    index_addr = addr + och*2 + index_x* `DATA_WIDTH * data_depth + index_y * tile_size * `DATA_WIDTH * data_depth;
                    data_tmp = {DRAM.mem[index_addr+1],DRAM.mem[index_addr]};
                    int_tmp = data_tmp;
                    tmp = int_tmp / qant;
                    //tmp = data_tmp;
                    $fwrite(f_of, "%f", tmp);
                    if(index_x == tile_size - 1)
                        $fwrite(f_of, "\n");
                    else
                        $fwrite(f_of, ",");
                end
            $fclose(f_of);
        end
    endtask


endclass

`endif