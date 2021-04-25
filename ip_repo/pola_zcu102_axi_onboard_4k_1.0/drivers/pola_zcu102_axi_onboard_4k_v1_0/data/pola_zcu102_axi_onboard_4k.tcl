

proc generate {drv_handle} {
	xdefine_include_file $drv_handle "xparameters.h" "pola_zcu102_axi_onboard_4k" "NUM_INSTANCES" "DEVICE_ID"  "C_S00_AXI_BASEADDR" "C_S00_AXI_HIGHADDR"
}
