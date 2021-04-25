#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#define datapath_r "/home/polapc/Desktop/mut_space_HW/Pola_axi_sobel_onboard/Pola_axi_sobel_onboard.sim/sim_1/behav/xsim/data.txt"
#define datapath_w "/home/polapc/Desktop/data_spilt.txt"

int main(){
    FILE* in_file  = fopen(datapath_r, "r"); // read only          
    FILE* out_file = fopen(datapath_w, "w"); // read only          
    if(in_file == NULL){
        printf("Error! could not open file\n");
        exit(-1);
    }else{
        printf("open the file success\n");
    }
    if(out_file == NULL){
        printf("Error! could not open file\n");
        exit(-1);
        return 0;
    }else{
        printf("open the file success\n");
    }
    u_int64_t ans_box[51076]={0};
    char * line = NULL;
    size_t len = 0;
    ssize_t read;
    int decrease;
    int i=0;

    while ((read = getline(&line, &len, in_file)) != -1) {
        printf("Retrieved line of length %zu:\n", read);
        printf("%s", line);
        for(decrease=63;decrease>=0;decrease--){
    		if(decrease>=48){
    			if(line[decrease]>='a')ans_box[i] += ((line[decrease]-'a')+10)*pow(16,(63-decrease));
    			else                   ans_box[i] += (line[decrease]-'0')*pow(16,(63-decrease));
    		}else if(decrease >= 32){
    			if(line[decrease]>='a')ans_box[i] += ((line[decrease]-'a')+10)*pow(16,(47-decrease));
    			else                   ans_box[i] += (line[decrease]-'0')*pow(16,(47-decrease));
    		}else if(decrease >= 16){
    			if(line[decrease]>='a')ans_box[i] += ((line[decrease]-'a')+10)*pow(16,(31-decrease));
    			else                   ans_box[i] += (line[decrease]-'0')*pow(16,(31-decrease));
    		}else{
    			if(line[decrease]>='a')ans_box[i] += ((line[decrease]-'a')+10)*pow(16,(15-decrease));
    			else                   ans_box[i] += (line[decrease]-'0')*pow(16,(15-decrease));
    		}
            if(decrease==48 || decrease==32 || decrease==16 || decrease==0)i=i+1;
    	}
    }
    printf("finish\n");
    for(int i=0;i<51076;i++){
    	printf("0x%016lx\n",ans_box[i]);
        fprintf(out_file,"0x%016lx\n",ans_box[i]);
    }
    fclose(out_file);
    return 0;
}