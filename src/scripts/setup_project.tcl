set_param board.repoPaths RFSoC4x2-BSP-2020.2/board_files/rfsoc4x2/1.0/
xhub::refresh_catalog [xhub::get_xstores xilinx_board_store]
create_project Simple_RFSoC ./build -part xczu48dr-ffvg1517-2-e
set_property board_part realdigital.org:rfsoc4x2:part0:1.0 [current_project]

create_bd_design "main"
update_compile_order -fileset sources_1
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:zynq_ultra_ps_e:3.4 zynq_ultra_ps_e_0
endgroup

apply_bd_automation -rule xilinx.com:bd_rule:zynq_ultra_ps_e -config {apply_board_preset "1" } \
                                                                     [get_bd_cells zynq_ultra_ps_e_0]
set_property location {1 140 -248} [get_bd_cells zynq_ultra_ps_e_0]


#setting up the dataconverter

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:usp_rf_data_converter:2.6 usp_rf_data_converter_0
endgroup

startgroup
set_property -dict [list CONFIG.ADC0_Enable {0} \
                         CONFIG.ADC0_Fabric_Freq {0.0} \
                         CONFIG.ADC_Slice00_Enable {false} \
                         CONFIG.ADC_Decimation_Mode00 {0} \
                         CONFIG.ADC_Mixer_Type00 {3} \
                         CONFIG.ADC_RESERVED_1_00 {0} \
                         CONFIG.ADC_Slice01_Enable {false} \
                         CONFIG.ADC_Decimation_Mode01 {0} \
                         CONFIG.ADC_Mixer_Type01 {3} \
                         CONFIG.ADC_RESERVED_1_02 {0} \
                         CONFIG.ADC_OBS02 {0} \
                         CONFIG.DAC0_Enable {1} \
                         CONFIG.DAC0_PLL_Enable {true} \
                         CONFIG.DAC0_Sampling_Rate {9.8304} \
                         CONFIG.DAC0_Refclk_Freq {491.520} \
                         CONFIG.DAC0_Outclk_Freq {614.400} \
                         CONFIG.DAC0_Fabric_Freq {614.400} \
                         CONFIG.DAC_Slice00_Enable {true} \
                         CONFIG.DAC_Interpolation_Mode00 {1} \
                         CONFIG.DAC_Mixer_Type00 {1} \
                         CONFIG.DAC_Coarse_Mixer_Freq00 {3} \
                         CONFIG.DAC_Mode00 {3} \
                         CONFIG.DAC_RESERVED_1_00 {0} \
                         CONFIG.DAC_RESERVED_1_01 {0} \
                         CONFIG.DAC_RESERVED_1_02 {0} \
                         CONFIG.DAC_RESERVED_1_03 {0}] [get_bd_cells usp_rf_data_converter_0]

endgroup




apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {Auto} Clk_xbar {Auto}
                                                          Master {/zynq_ultra_ps_e_0/M_AXI_HPM0_FPD}
                                                          Slave {/usp_rf_data_converter_0/s_axi} 
                                                          ddr_seg {Auto} 
                                                          intc_ip {New AXI Interconnect} 
                                                          master_apm {0}}  [get_bd_intf_pins usp_rf_data_converter_0/s_axi]

apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {/zynq_ultra_ps_e_0/pl_clk0 (99 MHz)}
                                                            Clk_xbar {/zynq_ultra_ps_e_0/pl_clk0 (99 MHz)} 
                                                            Master {/zynq_ultra_ps_e_0/M_AXI_HPM1_FPD} 
                                                            Slave {/usp_rf_data_converter_0/s_axi}
                                                            ddr_seg {Auto} 
                                                            intc_ip {/ps8_0_axi_periph}
                                                            master_apm {0}}  [get_bd_intf_pins zynq_ultra_ps_e_0/M_AXI_HPM1_FPD]
apply_bd_automation -rule xilinx.com:bd_rule:rf_converter_usp -config {ADC0_AXIS_SOURCE "Custom"
                                                                       DAC0_AXIS_SOURCE "Custom" }  [get_bd_cells usp_rf_data_converter_0]
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0
endgroup
set_property -dict [list CONFIG.C_IS_DUAL {1} CONFIG.C_ALL_INPUTS {0} CONFIG.C_ALL_OUTPUTS {1} CONFIG.C_ALL_OUTPUTS_2 {1}] [get_bd_cells axi_gpio_0]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/zynq_ultra_ps_e_0/pl_clk0 (99 MHz)}
                                                            Clk_slave {Auto}
                                                            Clk_xbar {/zynq_ultra_ps_e_0/pl_clk0 (99 MHz)}
                                                            Master {/zynq_ultra_ps_e_0/M_AXI_HPM0_FPD}
                                                            Slave {/axi_gpio_0/S_AXI}
                                                            ddr_seg {Auto}
                                                            intc_ip {/ps8_0_axi_periph}
                                                            master_apm {0}}  [get_bd_intf_pins axi_gpio_0/S_AXI]
add_files ./hdl/rampgen.v
update_compile_order -fileset sources_1
set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 ./sim/rampgen_tb.v
update_compile_order -fileset sim_1


startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0
endgroup



connect_bd_net [get_bd_pins usp_rf_data_converter_0/clk_dac0] [get_bd_pins usp_rf_data_converter_0/s0_axis_aclk]

update_compile_order -fileset sources_1
create_bd_cell -type module -reference rampgen rampgen_0
connect_bd_net [get_bd_pins axi_gpio_0/gpio_io_o] [get_bd_pins rampgen_0/frequency]
connect_bd_net [get_bd_pins axi_gpio_0/gpio2_io_o] [get_bd_pins rampgen_0/amplitude]
connect_bd_net [get_bd_pins rampgen_0/M_AXIS_ARESETN] [get_bd_pins rst_ps8_0_99M/peripheral_aresetn]
connect_bd_net [get_bd_pins rampgen_0/M_AXIS_ACLK] [get_bd_pins usp_rf_data_converter_0/clk_dac0]
connect_bd_net [get_bd_pins rampgen_0/M_AXIS_TDATA] [get_bd_pins usp_rf_data_converter_0/s00_axis_tdata]
connect_bd_net [get_bd_pins rampgen_0/M_AXIS_TVALID] [get_bd_pins usp_rf_data_converter_0/s00_axis_tvalid]
connect_bd_net [get_bd_pins rampgen_0/M_AXIS_TREADY] [get_bd_pins usp_rf_data_converter_0/s00_axis_tready]
connect_bd_net [get_bd_pins proc_sys_reset_0/slowest_sync_clk] [get_bd_pins usp_rf_data_converter_0/clk_dac0]
connect_bd_net [get_bd_pins proc_sys_reset_0/peripheral_aresetn] [get_bd_pins usp_rf_data_converter_0/s0_axis_aresetn]
connect_bd_net [get_bd_pins proc_sys_reset_0/ext_reset_in] [get_bd_pins zynq_ultra_ps_e_0/pl_resetn0]

set_property name ramp_params [get_bd_cells axi_gpio_0]

save_bd_design
update_compile_order -fileset sources_1

disconnect_bd_net /rst_ps8_0_99M_peripheral_aresetn [get_bd_pins rampgen_0/M_AXIS_ARESETN]
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0
endgroup
connect_bd_net [get_bd_pins xlconstant_0/dout] [get_bd_pins rampgen_0/M_AXIS_ARESETN]

make_wrapper -files [get_files ./build/Simple_RFSoC.srcs/sources_1/bd/main/main.bd] -top
add_files -norecurse ./build/Simple_RFSoC.gen/sources_1/bd/main/hdl/main_wrapper.v
update_compile_order -fileset sources_1

validate_bd_design

save_bd_design
