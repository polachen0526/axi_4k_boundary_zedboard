import csv
with open('/home/polapc/Desktop/mut_space_HW/Pola_axi_sobel_onboard/Pola_axi_sobel_onboard.sim/sim_1/behav/xsim/Output_data/Layer1/0_0.csv') as f:
    reader = csv.reader(f)
    datahw_v  = list(reader)
with open('/home/polapc/Desktop/mut_space_HW/Pola_axi_sobel_onboard/Pola_axi_sobel_onboard.sim/sim_1/behav/xsim/Output_data/Layer1/softans_v.csv') as f:
    reader = csv.reader(f)
    datasw_v  = list(reader)
with open('/home/polapc/Desktop/mut_space_HW/Pola_axi_sobel_onboard/Pola_axi_sobel_onboard.sim/sim_1/behav/xsim/Output_data/Layer1/0_1.csv') as f:
    reader = csv.reader(f)
    datahw_h  = list(reader)
with open('/home/polapc/Desktop/mut_space_HW/Pola_axi_sobel_onboard/Pola_axi_sobel_onboard.sim/sim_1/behav/xsim/Output_data/Layer1/softans_h.csv') as f:
    reader = csv.reader(f)
    datasw_h  = list(reader)

if(datahw_v == datasw_v):
    print("The test is for your cat_after_sobel_v ")
    print("Congratulations! your data have been generated successfully! The result is PASS!!")
else:
    print("you got some error !!! please check your answer")
    print("---------------wait for anser check per by per----------------------")
    print("---------------wait for anser check per by per----------------------")
    print("---------------wait for anser check per by per----------------------")
    error = 0
    for i in range(224):
        for j in range(224):
            if(datahw_v[i][j]==datasw_v[i][j]):
                print("row %d line %d got problem"%(i,j))
                error = error+1
            else:
                pass
if(datahw_h == datasw_h):
    print("The test is for your cat_after_sobel_h ")
    print("Congratulations! your data have been generated successfully! The result is PASS!!")
else:
    print("you got some error !!! please check your answer")
    print("---------------wait for anser check per by per----------------------")
    print("---------------wait for anser check per by per----------------------")
    print("---------------wait for anser check per by per----------------------")
    error = 0
    for i in range(224):
        for j in range(224):
            if(datahw_h[i][j]==datasw_h[i][j]):
                print("row %s line %s got problem"%(i,j))
                error = error+1
            else:
                pass
#-------------------trans the correct answer-----------------------
with open('16bit_ans_v.txt', 'w') as f:
    for i in datasw_v:
        for j in i:
            ans=str(int(float(j)))
            f.write(ans)
            f.write(",\n")      
with open('16bit_ans_h.txt', 'w') as f:
    #print('This message will be written to a file.', file=f)            
    for i in datasw_h:
        for j in i:
            ans=str(int(float(j)))
            f.write(ans)
            f.write(",\n")                
