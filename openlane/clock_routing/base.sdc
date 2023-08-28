## MASTER CLOCKS
create_clock [get_ports {"ext_clk"} ] -name "ext_clk"  -period 25
create_clock [get_ports {"pll_clk"} ] -name "pll_clk"  -period 6.6666666666667 
create_clock [get_ports {"pll_clk90"} ] -name "pll_clk90"  -period 6.6666666666667 

# logically exclusive clocks, the generated pll clocks and the ext core clk
set_clock_groups -logically_exclusive -group ext_clk -group {pll_clk90 pll_clk}

set_propagated_clock [all_clocks]

## INPUT/OUTPUT DELAYS
set ext_clk_input_delay_value 5
set ext_clk_output_delay_value 5

set_input_delay $ext_clk_input_delay_value  -clock [get_clocks {ext_clk}] -add_delay [get_ports {ext_clk_sel}]

#set_input_delay $input_delay_value  -clock [get_clocks {ext_clk}] -add_delay [get_ports {resetb}]
set_input_delay $ext_clk_input_delay_value  -clock [get_clocks {ext_clk}] -add_delay [get_ports {sel2[0]}]
set_input_delay $ext_clk_input_delay_value  -clock [get_clocks {ext_clk}] -add_delay [get_ports {sel2[1]}]
set_input_delay $ext_clk_input_delay_value  -clock [get_clocks {ext_clk}] -add_delay [get_ports {sel2[2]}]
set_input_delay $ext_clk_input_delay_value  -clock [get_clocks {ext_clk}] -add_delay [get_ports {sel[0]}]
set_input_delay $ext_clk_input_delay_value  -clock [get_clocks {ext_clk}] -add_delay [get_ports {sel[1]}]
set_input_delay $ext_clk_input_delay_value  -clock [get_clocks {ext_clk}] -add_delay [get_ports {sel[2]}]

set_output_delay $ext_clk_output_delay_value  -clock [get_clocks {ext_clk}] -add_delay [get_ports {resetb_sync}]

set_max_fanout $::env(SYNTH_MAX_FANOUT) [current_design]

# TODO set this as parameter
set cap_load 0.2
set_load  $cap_load [all_outputs]

set_timing_derate -early 0.9500
set_timing_derate -late 1.0500

set_clock_uncertainty 0.2 [get_clocks {ext_clk}]
set_clock_uncertainty 0.2 [get_clocks {pll_clk}]
set_clock_uncertainty 0.2 [get_clocks {pll_clk90}]
set_clock_uncertainty 0.2 [get_clocks {core_clk}]

set_clock_transition 0.15 [get_clocks {ext_clk}]
set_clock_transition 0.1 [get_clocks {pll_clk}]
set_clock_transition 0.1 [get_clocks {pll_clk90}]
set_clock_transition 0.1 [get_clocks {core_clk}]

set_max_transition 0.5 [all_clocks] -clock_path

#set clk_input [get_port serial_clock)]
#set clk_indx [lsearch [all_inputs] $clk_input]
#set all_inputs_wo_clk [lreplace [all_inputs] $clk_indx $clk_indx ""]

set_input_transition 0.3 [all_inputs]
set_max_transition 1.0 [current_design]
