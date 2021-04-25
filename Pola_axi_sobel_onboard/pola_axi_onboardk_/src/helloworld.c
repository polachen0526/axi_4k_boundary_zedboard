/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include <stdint.h>
#include "platform.h"
#include "xil_printf.h"
#include "xil_cache.h"
#include <xil_mmu.h>
#include <xil_io.h>
#include "string.h"
#include "data.h"
#include "16bit_ans_v.h"
#include "16bit_ans_h.h"
    /*
    * Input
    * slv_reg0[1]   s_axi_rst ;
    * slv_reg0[0]   s_axi_start ;
    * slv_reg1      s_axi_inst_0 ;
    * slv_reg2      s_axi_inst_1 ;
    * slv_reg3      s_axi_inst_2 ;
    * slv_reg4      s_axi_inst_3 ;
    * slv_reg5      s_axi_inst_4 ;
    * Output
	* slv_reg6      s_axi_Rerror_addr ;
	* slv_reg7      s_axi_Werror_addr ;
	* slv_reg8      {31'd0, s_axi_Rerror} ;
	* slv_reg9      {30'd0, s_axi_Werror} ;
    * slv_reg10     IRQ ;
	// I/O Connections assignments
    */
#define RST_START 0
#define INST0 1
#define INST1 3
#define INST2 4
#define INST3 5
#define INST4 6
//#define Re_addr
//#define We_addr
//#define axu_Re_addr
//#define axu_We_addr
#define S_IRQ 10

int main()
{
    init_platform();
    //uint64_t array[50176];
    print("Hello World\n\r");
    /** Set Memory From 0x00150000 1MB memory as noncache
    * But 4K boundary ... ?S
    */
    Xil_SetTlbAttributes((unsigned int)0x00200000, NORM_NONCACHE);
    print("Hello World1\n\r");
    /*
    * Put Data In Read_Address
    */
    uint64_t *input_addr = (uint64_t *)0x00200000;
    memcpy(input_addr, DATA_IN_DRAM, sizeof(uint64_t)*51076); // &DATA_IN_DRAM ==  0x00150000
    print("Hello World2\n\r");
    /*
    * Write Data
    */
    uint64_t *output_addr = (uint64_t *)0x00263de0;
    //uint64_t *output_addr1 = (uint64_t *)0x00263de0;
    /*
    for ( int i=0 ; i<50176 ; i++ ){
        printf( "address 0x%x IN_DATA [%d]     =		%08x\n",(int)(&input_addr[i]),i,(int)input_addr[i] );
        array[i] = input_addr[i];
    }
    */
    /*
    * Slave location
    */
    print("Hello World3\n\r");
    int *slave = (int *)0x43c00000;
    /*
    * Send Data To Slave
    */
    print("Hello World4\n\r");
    slave[RST_START] 	= 0x00000002 ;  //{rst , start }
    slave[INST0] 		= (int)(input_addr) ;  // read     addr
    slave[INST1] 		= (int)(output_addr);  // write    addr
    slave[INST2] 		= 0x00000000 ;
    slave[INST3] 		= 0x00000001 ;
    slave[INST4] 		= 0x00000000 ;
    slave[RST_START] 	= 0x00000000 ;
    slave[RST_START] 	= 0x00000001 ;
    print("Hello World5\n\r");
    /*
    * Receive Data From Slave
    */
    while ( slave[S_IRQ] == 0x00000000 ) {

    }
    print("Hello World6\n\r");
    slave[RST_START] 	= 0x00000000 ;
    /*
    for ( int i=0 ; i<12544 ; i++ ){
        printf( "address 0x%x OUT_DATA [%d] =		%08x\n",(int)(&output_addr[i]),i,(int)output_addr[i] );
        if ( array[i] != output_addr[i] ){
        	printf("Error, Number %d data = 0x%08x but get 0x%08x\n",i,(int)array[i],(int)(output_addr[i]));
        }else if ( i==9 ){
        	printf("------Successfully------");
        }
    }
    */
    uint16_t ans[4]={0};
    int Error = 0;
    for(int i=0;i<12544;i++){
    	//
    	xil_printf( "address 0x%x OUT_DATA_top  [%p] =  %08x\n\r",(&output_addr[i]),i,output_addr[i]);
    	ans[0] = output_addr[i]&0x0000FFFF;
    	ans[1] = output_addr[i]>>16;
    	xil_printf( "address 0x%x OUT_DATA_down [%p] =  %08x\n\r",(&output_addr[i]),i,output_addr[i]<<32);
    	ans[2] = (output_addr[i]>>32)&0x0000FFFF;
    	ans[3] = (output_addr[i])>>48;
    	xil_printf("%04x,%04x,%04x,%04x\n",ans[0],ans[1],ans[2],ans[3]);
    	for(int j=0;j<4;j++){
    		if(pola_ans_v[i*4+j]!=ans[j]){
    			printf("Error, Number %d data = 0x%x but get 0x%04x\n\r",i*4+j,pola_ans_v[i*4+j],ans[j]);
    			Error = Error +1;
    		}else{
    			printf("good answer\n\r");
    		}
    	}
    	if(Error>1)break;
    }
    if(Error==0)printf("------Successfully------\n\r");
    else printf("you got %d Error please chek your code\n\r",Error);

    cleanup_platform();
    return 0;
}
