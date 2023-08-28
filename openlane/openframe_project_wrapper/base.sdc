create_clock -name clk -period $::env(CLOCK_PERIOD) [get_ports {gpio_in[38]}]
create_clock -name clk_hkspi_sck -period $::env(CLOCK_PERIOD) [get_ports {gpio_in[4]}]

set_clock_groups \
   -name clock_group \
   -logically_exclusive \
   -group [get_clocks {clk}]\
   -group [get_clocks {clk_hkspi_sck}]

set_clock_uncertainty 0.8 [all_clocks]
set_propagated_clock [all_clocks]

## INPUT/OUTPUT DELAYS
set input_delay_value 0
set output_delay_value 22
puts "\[INFO\]: Setting output delay to: $output_delay_value"
puts "\[INFO\]: Setting input delay to: $input_delay_value"
set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [all_inputs]
set_input_delay 0  -clock [get_clocks {clk}] [get_ports {gpio_in[38]}]
set_input_delay 0  -clock [get_clocks {clk_hkspi_sck}] [get_ports {gpio_in[4]}]

set_output_delay $output_delay_value  -clock [get_clocks {clk}] -add_delay [all_outputs]

## MAX FANOUT
set_max_fanout $::env(SYNTH_MAX_FANOUT) [current_design]

## FALSE PATHS (ASYNCHRONOUS INPUTS)
set_false_path -from [get_ports {resetb_l}]
set_false_path -from [get_ports {porb_l}]

# add loads for output ports (pads)
set min_cap 0.5
set max_cap 1.0
puts "\[INFO\]: Cap load range: $min_cap : $max_cap"
# set_load 10 [all_outputs]
set_load -min $min_cap [all_outputs]
set_load -max $max_cap [all_outputs]

set min_in_tran 1
set max_in_tran 1.19
puts "\[INFO\]: Input transition range: $min_in_tran : $max_in_tran"
set_input_transition -min $min_in_tran [all_inputs]
set_input_transition -max $max_in_tran [all_inputs]

# derates
set derate 0.15
puts "\[INFO\]: Setting derate factor to: [expr $derate * 100] %"
set_timing_derate -early [expr 1-$derate]
set_timing_derate -late [expr 1+$derate]

## MAX transition/cap
set_max_trans 0.5 [current_design]
# set_max_cap 0.5 [current_design]

# group_path -weight 100 -through [get_pins mprj/la_data_out[0]] -name mprj_floating
