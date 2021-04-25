`ifndef DRAM_SLAVE_SV
`define DRAM_SLAVE_SV
`include "settings.svh"

`define IN_TILE_SIZE 34*34
`define DATA_WB 8
`define HW_SP_ICH 256 //hardware support input channel
`define SIZE 32'h07a0_0000
`define RANDOM_P 5
//`define RANDOM

class DRAM;
    logic [7:0] mem [0:`SIZE-1];
    logic       areff;
    logic [7:0] arlen;

    logic       aweff;
    logic [7:0] awlen;

    logic       weff;
    logic       wready;
    integer     waddr;

    logic       reff;
    logic [8:0] rcnt;
    integer     raddr;

    //Inteface used in class must add virtual
    virtual AXI_FULL.slave sif;
   
    //Constructor must use function rather than task
    //Virtual interface need to intialize or it's null.
    function new (
        virtual AXI_FULL.slave  siff
    );
        this.sif = siff;
        areff   <= 0;
        arlen   <= 0;

        aweff   <= 0;
        awlen   <= 0;

        weff   = 0;
        wready = 0;
        waddr  <= 0;

        reff   = 0;
        rcnt   <= 0;
        raddr  <= 0;
    endfunction

    task aw_handle;
        sif.M_AXI_AWREADY = 1; //Always True
        if(sif.M_AXI_AWVALID) begin
            aweff = 1;
            awlen = sif.M_AXI_AWLEN;
            waddr = sif.M_AXI_AWADDR;
        end
    endtask

    task ar_handle;
        sif.M_AXI_ARREADY <= 1; //Always True
//        $display( "@%g areff = %d", $time, areff); 

        if(sif.M_AXI_ARVALID) begin
//            #330
            areff <= 1;
            arlen <= sif.M_AXI_ARLEN;
            raddr <= sif.M_AXI_ARADDR;
            rcnt  <= 0;
        end
//        $display( "@%g areff = %d", $time, areff);
    endtask

    task w_handle;
        `ifdef RANDOM
            wready = $random();
        `else
            wready = 1;//($random() % 2 + 1) / 2*/;
        `endif
        weff  = sif.M_AXI_WVALID && wready;

        for(int i=0; i<`DATA_WB; i=i+1) begin
            //if(aweff && weff && sif.M_AXI_WSTRB[i]) 
            if(aweff && sif.M_AXI_WVALID && sif.M_AXI_WREADY && sif.M_AXI_WSTRB[i])begin
                mem[waddr+i] = sif.M_AXI_WDATA[i*8+:8];
                ///$display( "@%g mem[waddr+i] = %d", $time, mem[waddr+i]); it can open 
                //$display( "@%g M_AXI_WDATA = %d", $time, sif.M_AXI_WDATA[i*8+:8]);it can open 
            end
        end
        
        //if(aweff && weff) begin
        if(aweff && sif.M_AXI_WVALID && sif.M_AXI_WREADY) begin
            if(sif.M_AXI_WLAST)
                aweff = 0;
            else
                waddr = waddr + `DATA_WB;
        end
        sif.M_AXI_WREADY = wready;

    endtask

    task r_handle_seq;
        sif.M_AXI_RRESP  <= 0;   //Always OKay
        sif.M_AXI_RID    <= 0;   //Unused
        sif.M_AXI_RUSER  <= 0;   //Unused

        //reff = areff && sif.M_AXI_RREADY;
        //$display( "@%g %d %d", $time, sif.M_AXI_RREADY, raddr); 


        if(areff && sif.M_AXI_RVALID && sif.M_AXI_RREADY) begin
            //$display("areff %d rcnt %d arlen %d",areff,rcnt,arlen);
            if(rcnt == arlen) begin
                areff <= 0;
                rcnt  <= 0;
            end else begin
                raddr <= raddr + `DATA_WB;
                rcnt  <= rcnt  + 1;
            end
        end else begin
            //areff = areff;
            rcnt  <= rcnt;
            raddr <= raddr;
        end
        //$display( "@%g %d %d", $time, sif.M_AXI_RREADY, raddr); 
    endtask

    task r_handle_comb;
        sif.M_AXI_RVALID = areff;
        sif.M_AXI_RLAST  = rcnt == arlen;
        for(int ttt=0; ttt<`DATA_WB; ttt=ttt+1) begin
            //if(areff && reff)
                sif.M_AXI_RDATA[ttt*8+:8] = mem[raddr+ttt];
        end
    endtask

    task b_handle;
        sif.M_AXI_BVALID <= 0;
        sif.M_AXI_BRESP  <= 0;   //Always OKay
        sif.M_AXI_BID    <= 0;   //Unused
        sif.M_AXI_BUSER  <= 0;   //Unused
    endtask
    
endclass

`endif