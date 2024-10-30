# URBANA BOARD CONSTRAINTS V2I1 1/3/2023 
# clk input is from the 100 MHz oscillator on Urbana board
create_clock -period 17.000 [get_ports clk]
set_property -dict {PACKAGE_PIN N15 IOSTANDARD LVCMOS25} [get_ports clk]

# On-board Buttons
set_property -dict {PACKAGE_PIN J2 IOSTANDARD LVCMOS25} [get_ports {reset}]
set_property -dict {PACKAGE_PIN J1 IOSTANDARD LVCMOS25} [get_ports {load}]
set_property -dict {PACKAGE_PIN G2 IOSTANDARD LVCMOS25} [get_ports {run}]

# On-board 7-Segment display 0
set_property -dict {PACKAGE_PIN G6 IOSTANDARD LVCMOS25} [get_ports {hex_grid_left[0]}]
set_property -dict {PACKAGE_PIN H6 IOSTANDARD LVCMOS25} [get_ports {hex_grid_left[1]}]
set_property -dict {PACKAGE_PIN C3 IOSTANDARD LVCMOS25} [get_ports {hex_grid_left[2]}]
set_property -dict {PACKAGE_PIN B3 IOSTANDARD LVCMOS25} [get_ports {hex_grid_left[3]}]
set_property -dict {PACKAGE_PIN E6 IOSTANDARD LVCMOS25} [get_ports {hex_seg_left[0]}]
set_property -dict {PACKAGE_PIN B4 IOSTANDARD LVCMOS25} [get_ports {hex_seg_left[1]}]
set_property -dict {PACKAGE_PIN D5 IOSTANDARD LVCMOS25} [get_ports {hex_seg_left[2]}]
set_property -dict {PACKAGE_PIN C5 IOSTANDARD LVCMOS25} [get_ports {hex_seg_left[3]}]
set_property -dict {PACKAGE_PIN D7 IOSTANDARD LVCMOS25} [get_ports {hex_seg_left[4]}]
set_property -dict {PACKAGE_PIN D6 IOSTANDARD LVCMOS25} [get_ports {hex_seg_left[5]}]
set_property -dict {PACKAGE_PIN C4 IOSTANDARD LVCMOS25} [get_ports {hex_seg_left[6]}]
set_property -dict {PACKAGE_PIN B5 IOSTANDARD LVCMOS25} [get_ports {hex_seg_left[7]}]

# On-board 7-Segment display 1
set_property -dict {PACKAGE_PIN E4 IOSTANDARD LVCMOS25} [get_ports {hex_grid_right[0]}]
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS25} [get_ports {hex_grid_right[1]}]
set_property -dict {PACKAGE_PIN F5 IOSTANDARD LVCMOS25} [get_ports {hex_grid_right[2]}]
set_property -dict {PACKAGE_PIN H5 IOSTANDARD LVCMOS25} [get_ports {hex_grid_right[3]}]
set_property -dict {PACKAGE_PIN F3 IOSTANDARD LVCMOS25} [get_ports {hex_seg_right[0]}]
set_property -dict {PACKAGE_PIN G5 IOSTANDARD LVCMOS25} [get_ports {hex_seg_right[1]}]
set_property -dict {PACKAGE_PIN J3 IOSTANDARD LVCMOS25} [get_ports {hex_seg_right[2]}]
set_property -dict {PACKAGE_PIN H4 IOSTANDARD LVCMOS25} [get_ports {hex_seg_right[3]}]
set_property -dict {PACKAGE_PIN F4 IOSTANDARD LVCMOS25} [get_ports {hex_seg_right[4]}]
set_property -dict {PACKAGE_PIN H3 IOSTANDARD LVCMOS25} [get_ports {hex_seg_right[5]}]
set_property -dict {PACKAGE_PIN E5 IOSTANDARD LVCMOS25} [get_ports {hex_seg_right[6]}]
set_property -dict {PACKAGE_PIN J4 IOSTANDARD LVCMOS25} [get_ports {hex_seg_right[7]}]