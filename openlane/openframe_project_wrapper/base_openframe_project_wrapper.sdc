# generated by get_cup_sdc.py
# Date: 2023/03/02
### Note:   - input clock transition and latency are set based on the gpio_in[38] port. 
###           If your design is using the user_clock2, update the constraints to use usr_* variables. 
###         - input delays for wbs_adr_i[0] and wbs_adr_i[1] are assumed to be 0 as they're not reported (constants)
###         - IO ports are assumed to be asynchronous. If they're synchronous to the clock, update the variable IO_SYNC to 1. 
###           As well, update in_ext_delay and out_ext_delay with the required I/O external delays.

#------------------------------------------#
# Pre-defined Constraints
#------------------------------------------#

# Clock network
if {[info exists ::env(CLOCK_PORT)] && $::env(CLOCK_PORT) != ""} {
	set clk_input $::env(CLOCK_PORT)
	create_clock [get_ports $clk_input] -name clk -period $::env(CLOCK_PERIOD)
	puts "\[INFO\]: Creating clock {clk} for port $clk_input with period: $::env(CLOCK_PERIOD)"
} else {
	set clk_input __VIRTUAL_CLK__
	create_clock -name clk -period $::env(CLOCK_PERIOD)
	puts "\[INFO\]: Creating virtual clock with period: $::env(CLOCK_PERIOD)"
}
if { ![info exists ::env(SYNTH_CLK_DRIVING_CELL)] } {
	set ::env(SYNTH_CLK_DRIVING_CELL) $::env(SYNTH_DRIVING_CELL)
}
if { ![info exists ::env(SYNTH_CLK_DRIVING_CELL_PIN)] } {
	set ::env(SYNTH_CLK_DRIVING_CELL_PIN) $::env(SYNTH_DRIVING_CELL_PIN)
}

# Clock non-idealities
set_propagated_clock [get_clocks {clk}]
set_clock_uncertainty $::env(SYNTH_CLOCK_UNCERTAINTY) [get_clocks {clk}]
puts "\[INFO\]: Setting clock uncertainity to: $::env(SYNTH_CLOCK_UNCERTAINTY)"
set_clock_transition $::env(SYNTH_CLOCK_TRANSITION) [get_clocks {clk}]
puts "\[INFO\]: Setting clock transition to: $::env(SYNTH_CLOCK_TRANSITION)"

# Maximum transition time of the design nets
set_max_transition $::env(SYNTH_MAX_TRAN) [current_design]
puts "\[INFO\]: Setting maximum transition to: $::env(SYNTH_MAX_TRAN)"

# Maximum fanout
set_max_fanout $::env(SYNTH_MAX_FANOUT) [current_design]
puts "\[INFO\]: Setting maximum fanout to: $::env(SYNTH_MAX_FANOUT)"

# Timing paths delays derate
set_timing_derate -early [expr {1-$::env(SYNTH_TIMING_DERATE)}]
set_timing_derate -late [expr {1+$::env(SYNTH_TIMING_DERATE)}]
puts "\[INFO\]: Setting timing derate to: [expr {$::env(SYNTH_TIMING_DERATE) * 100}] %"

#------------------------------------------#
# Retrieved Constraints
#------------------------------------------#

# Clock source latency
set usr_clk_max_latency 4.7
set usr_clk_min_latency 4.24
set clk_max_latency 6
set clk_min_latency 4.5
set_clock_latency -source -max $clk_max_latency [get_clocks {clk}]
set_clock_latency -source -min $clk_min_latency [get_clocks {clk}]
puts "\[INFO\]: Setting clock latency range: $clk_min_latency : $clk_max_latency"

# Clock input Transition
set usr_clk_tran 0.11
set clk_tran 0.6
set_input_transition $clk_tran [get_ports $clk_input]
puts "\[INFO\]: Setting clock transition: $clk_tran"

# Input delays
if { $::env(IO_SYNC) } {
	set in_ext_delay 4
	puts "\[INFO\]: Setting input ports external delay to: $in_ext_delay"
	set_input_delay -max [expr $in_ext_delay + 4.22] -clock [get_clocks {clk}] [get_ports {gpio_in[0]}]
	set_input_delay -max [expr $in_ext_delay + 4.22] -clock [get_clocks {clk}] [get_ports {gpio_in[10]}]
	set_input_delay -max [expr $in_ext_delay + 4.22] -clock [get_clocks {clk}] [get_ports {gpio_in[11]}]
	set_input_delay -max [expr $in_ext_delay + 4.22] -clock [get_clocks {clk}] [get_ports {gpio_in[12]}]
	set_input_delay -max [expr $in_ext_delay + 4.22] -clock [get_clocks {clk}] [get_ports {gpio_in[13]}]
	set_input_delay -max [expr $in_ext_delay + 4.22] -clock [get_clocks {clk}] [get_ports {gpio_in[14]}]
	set_input_delay -max [expr $in_ext_delay + 4.22] -clock [get_clocks {clk}] [get_ports {gpio_in[15]}]
	set_input_delay -max [expr $in_ext_delay + 4.22] -clock [get_clocks {clk}] [get_ports {gpio_in[16]}]
	set_input_delay -max [expr $in_ext_delay + 4.22] -clock [get_clocks {clk}] [get_ports {gpio_in[17]}]
	set_input_delay -max [expr $in_ext_delay + 4.22] -clock [get_clocks {clk}] [get_ports {gpio_in[18]}]
	set_input_delay -max [expr $in_ext_delay + 4.22] -clock [get_clocks {clk}] [get_ports {gpio_in[19]}]
	set_input_delay -max [expr $in_ext_delay + 4.22] -clock [get_clocks {clk}] [get_ports {gpio_in[1]}]
	set_input_delay -max [expr $in_ext_delay + 4.22] -clock [get_clocks {clk}] [get_ports {gpio_in[20]}]
	set_input_delay -max [expr $in_ext_delay + 4.22] -clock [get_clocks {clk}] [get_ports {gpio_in[21]}]
	set_input_delay -max [expr $in_ext_delay + 4.22] -clock [get_clocks {clk}] [get_ports {gpio_in[22]}]
	set_input_delay -max [expr $in_ext_delay + 4.22] -clock [get_clocks {clk}] [get_ports {gpio_in[23]}]
	set_input_delay -max [expr $in_ext_delay + 4.22] -clock [get_clocks {clk}] [get_ports {gpio_in[24]}]
	set_input_delay -max [expr $in_ext_delay + 4.22] -clock [get_clocks {clk}] [get_ports {gpio_in[25]}]
	set_input_delay -max [expr $in_ext_delay + 4.22] -clock [get_clocks {clk}] [get_ports {gpio_in[26]}]
	set_input_delay -max [expr $in_ext_delay + 4.22] -clock [get_clocks {clk}] [get_ports {gpio_in[27]}]
	set_input_delay -max [expr $in_ext_delay + 4.22] -clock [get_clocks {clk}] [get_ports {gpio_in[28]}]
	set_input_delay -max [expr $in_ext_delay + 4.22] -clock [get_clocks {clk}] [get_ports {gpio_in[29]}]
	set_input_delay -max [expr $in_ext_delay + 4.22] -clock [get_clocks {clk}] [get_ports {gpio_in[2]}]
	set_input_delay -max [expr $in_ext_delay + 4.22] -clock [get_clocks {clk}] [get_ports {gpio_in[30]}]
	set_input_delay -max [expr $in_ext_delay + 4.22] -clock [get_clocks {clk}] [get_ports {gpio_in[31]}]
	set_input_delay -max [expr $in_ext_delay + 4.22] -clock [get_clocks {clk}] [get_ports {gpio_in[32]}]
	set_input_delay -max [expr $in_ext_delay + 4.22] -clock [get_clocks {clk}] [get_ports {gpio_in[33]}]
	set_input_delay -max [expr $in_ext_delay + 4.22] -clock [get_clocks {clk}] [get_ports {gpio_in[34]}]
	set_input_delay -max [expr $in_ext_delay + 4.22] -clock [get_clocks {clk}] [get_ports {gpio_in[35]}]
	set_input_delay -max [expr $in_ext_delay + 4.22] -clock [get_clocks {clk}] [get_ports {gpio_in[36]}]
	set_input_delay -max [expr $in_ext_delay + 4.22] -clock [get_clocks {clk}] [get_ports {gpio_in[37]}]
	set_input_delay -max [expr $in_ext_delay + 4.22] -clock [get_clocks {clk}] [get_ports {gpio_in[3]}]
	set_input_delay -max [expr $in_ext_delay + 4.22] -clock [get_clocks {clk}] [get_ports {gpio_in[4]}]
	set_input_delay -max [expr $in_ext_delay + 4.22] -clock [get_clocks {clk}] [get_ports {gpio_in[5]}]
	set_input_delay -max [expr $in_ext_delay + 4.22] -clock [get_clocks {clk}] [get_ports {gpio_in[6]}]
	set_input_delay -max [expr $in_ext_delay + 4.22] -clock [get_clocks {clk}] [get_ports {gpio_in[7]}]
	set_input_delay -max [expr $in_ext_delay + 4.22] -clock [get_clocks {clk}] [get_ports {gpio_in[8]}]
	set_input_delay -max [expr $in_ext_delay + 4.22] -clock [get_clocks {clk}] [get_ports {gpio_in[9]}]
	set_input_delay -min [expr $in_ext_delay + 1.58] -clock [get_clocks {clk}] [get_ports {gpio_in[0]}]
	set_input_delay -min [expr $in_ext_delay + 1.58] -clock [get_clocks {clk}] [get_ports {gpio_in[10]}]
	set_input_delay -min [expr $in_ext_delay + 1.58] -clock [get_clocks {clk}] [get_ports {gpio_in[11]}]
	set_input_delay -min [expr $in_ext_delay + 1.58] -clock [get_clocks {clk}] [get_ports {gpio_in[12]}]
	set_input_delay -min [expr $in_ext_delay + 1.58] -clock [get_clocks {clk}] [get_ports {gpio_in[13]}]
	set_input_delay -min [expr $in_ext_delay + 1.58] -clock [get_clocks {clk}] [get_ports {gpio_in[14]}]
	set_input_delay -min [expr $in_ext_delay + 1.58] -clock [get_clocks {clk}] [get_ports {gpio_in[15]}]
	set_input_delay -min [expr $in_ext_delay + 1.58] -clock [get_clocks {clk}] [get_ports {gpio_in[16]}]
	set_input_delay -min [expr $in_ext_delay + 1.58] -clock [get_clocks {clk}] [get_ports {gpio_in[17]}]
	set_input_delay -min [expr $in_ext_delay + 1.58] -clock [get_clocks {clk}] [get_ports {gpio_in[18]}]
	set_input_delay -min [expr $in_ext_delay + 1.58] -clock [get_clocks {clk}] [get_ports {gpio_in[19]}]
	set_input_delay -min [expr $in_ext_delay + 1.58] -clock [get_clocks {clk}] [get_ports {gpio_in[1]}]
	set_input_delay -min [expr $in_ext_delay + 1.58] -clock [get_clocks {clk}] [get_ports {gpio_in[20]}]
	set_input_delay -min [expr $in_ext_delay + 1.58] -clock [get_clocks {clk}] [get_ports {gpio_in[21]}]
	set_input_delay -min [expr $in_ext_delay + 1.58] -clock [get_clocks {clk}] [get_ports {gpio_in[22]}]
	set_input_delay -min [expr $in_ext_delay + 1.58] -clock [get_clocks {clk}] [get_ports {gpio_in[23]}]
	set_input_delay -min [expr $in_ext_delay + 1.58] -clock [get_clocks {clk}] [get_ports {gpio_in[24]}]
	set_input_delay -min [expr $in_ext_delay + 1.58] -clock [get_clocks {clk}] [get_ports {gpio_in[25]}]
	set_input_delay -min [expr $in_ext_delay + 1.58] -clock [get_clocks {clk}] [get_ports {gpio_in[26]}]
	set_input_delay -min [expr $in_ext_delay + 1.58] -clock [get_clocks {clk}] [get_ports {gpio_in[27]}]
	set_input_delay -min [expr $in_ext_delay + 1.58] -clock [get_clocks {clk}] [get_ports {gpio_in[28]}]
	set_input_delay -min [expr $in_ext_delay + 1.58] -clock [get_clocks {clk}] [get_ports {gpio_in[29]}]
	set_input_delay -min [expr $in_ext_delay + 1.58] -clock [get_clocks {clk}] [get_ports {gpio_in[2]}]
	set_input_delay -min [expr $in_ext_delay + 1.58] -clock [get_clocks {clk}] [get_ports {gpio_in[30]}]
	set_input_delay -min [expr $in_ext_delay + 1.58] -clock [get_clocks {clk}] [get_ports {gpio_in[31]}]
	set_input_delay -min [expr $in_ext_delay + 1.58] -clock [get_clocks {clk}] [get_ports {gpio_in[32]}]
	set_input_delay -min [expr $in_ext_delay + 1.58] -clock [get_clocks {clk}] [get_ports {gpio_in[33]}]
	set_input_delay -min [expr $in_ext_delay + 1.58] -clock [get_clocks {clk}] [get_ports {gpio_in[34]}]
	set_input_delay -min [expr $in_ext_delay + 1.58] -clock [get_clocks {clk}] [get_ports {gpio_in[35]}]
	set_input_delay -min [expr $in_ext_delay + 1.58] -clock [get_clocks {clk}] [get_ports {gpio_in[36]}]
	set_input_delay -min [expr $in_ext_delay + 1.58] -clock [get_clocks {clk}] [get_ports {gpio_in[37]}]
	set_input_delay -min [expr $in_ext_delay + 1.58] -clock [get_clocks {clk}] [get_ports {gpio_in[38]}]
	set_input_delay -min [expr $in_ext_delay + 1.58] -clock [get_clocks {clk}] [get_ports {gpio_in[39]}]
	set_input_delay -min [expr $in_ext_delay + 1.58] -clock [get_clocks {clk}] [get_ports {gpio_in[3]}]
	set_input_delay -min [expr $in_ext_delay + 1.58] -clock [get_clocks {clk}] [get_ports {gpio_in[40]}]
	set_input_delay -min [expr $in_ext_delay + 1.58] -clock [get_clocks {clk}] [get_ports {gpio_in[41]}]
	set_input_delay -min [expr $in_ext_delay + 1.58] -clock [get_clocks {clk}] [get_ports {gpio_in[42]}]
	set_input_delay -min [expr $in_ext_delay + 1.58] -clock [get_clocks {clk}] [get_ports {gpio_in[43]}]
	set_input_delay -min [expr $in_ext_delay + 1.58] -clock [get_clocks {clk}] [get_ports {gpio_in[4]}]
	set_input_delay -min [expr $in_ext_delay + 1.58] -clock [get_clocks {clk}] [get_ports {gpio_in[5]}]
	set_input_delay -min [expr $in_ext_delay + 1.58] -clock [get_clocks {clk}] [get_ports {gpio_in[6]}]
	set_input_delay -min [expr $in_ext_delay + 1.58] -clock [get_clocks {clk}] [get_ports {gpio_in[7]}]
	set_input_delay -min [expr $in_ext_delay + 1.58] -clock [get_clocks {clk}] [get_ports {gpio_in[8]}]
	set_input_delay -min [expr $in_ext_delay + 1.58] -clock [get_clocks {clk}] [get_ports {gpio_in[9]}]
}

# Input Transition
set_input_transition -max 0.44  [get_ports {gpio_in[0]}]
set_input_transition -max 0.44  [get_ports {gpio_in[10]}]
set_input_transition -max 0.44  [get_ports {gpio_in[11]}]
set_input_transition -max 0.44  [get_ports {gpio_in[12]}]
set_input_transition -max 0.44  [get_ports {gpio_in[13]}]
set_input_transition -max 0.44  [get_ports {gpio_in[14]}]
set_input_transition -max 0.44  [get_ports {gpio_in[15]}]
set_input_transition -max 0.44  [get_ports {gpio_in[16]}]
set_input_transition -max 0.44  [get_ports {gpio_in[17]}]
set_input_transition -max 0.44  [get_ports {gpio_in[18]}]
set_input_transition -max 0.44  [get_ports {gpio_in[19]}]
set_input_transition -max 0.44  [get_ports {gpio_in[1]}]
set_input_transition -max 0.44  [get_ports {gpio_in[20]}]
set_input_transition -max 0.44  [get_ports {gpio_in[21]}]
set_input_transition -max 0.44  [get_ports {gpio_in[22]}]
set_input_transition -max 0.44  [get_ports {gpio_in[23]}]
set_input_transition -max 0.44  [get_ports {gpio_in[24]}]
set_input_transition -max 0.44  [get_ports {gpio_in[25]}]
set_input_transition -max 0.44  [get_ports {gpio_in[26]}]
set_input_transition -max 0.44  [get_ports {gpio_in[27]}]
set_input_transition -max 0.44  [get_ports {gpio_in[28]}]
set_input_transition -max 0.44  [get_ports {gpio_in[29]}]
set_input_transition -max 0.44  [get_ports {gpio_in[2]}]
set_input_transition -max 0.44  [get_ports {gpio_in[30]}]
set_input_transition -max 0.44  [get_ports {gpio_in[31]}]
set_input_transition -max 0.44  [get_ports {gpio_in[32]}]
set_input_transition -max 0.44  [get_ports {gpio_in[33]}]
set_input_transition -max 0.44  [get_ports {gpio_in[34]}]
set_input_transition -max 0.44  [get_ports {gpio_in[35]}]
set_input_transition -max 0.44  [get_ports {gpio_in[36]}]
set_input_transition -max 0.44  [get_ports {gpio_in[37]}]
set_input_transition -max 0.44  [get_ports {gpio_in[38]}]
set_input_transition -max 0.44  [get_ports {gpio_in[39]}]
set_input_transition -max 0.44  [get_ports {gpio_in[3]}]
set_input_transition -max 0.44  [get_ports {gpio_in[40]}]
set_input_transition -max 0.44  [get_ports {gpio_in[41]}]
set_input_transition -max 0.44  [get_ports {gpio_in[42]}]
set_input_transition -max 0.44  [get_ports {gpio_in[43]}]
set_input_transition -max 0.44  [get_ports {gpio_in[4]}]
set_input_transition -max 0.44  [get_ports {gpio_in[5]}]
set_input_transition -max 0.44  [get_ports {gpio_in[6]}]
set_input_transition -max 0.44  [get_ports {gpio_in[7]}]
set_input_transition -max 0.44  [get_ports {gpio_in[8]}]
set_input_transition -max 0.44  [get_ports {gpio_in[9]}]
set_input_transition -min 0.05  [get_ports {gpio_in[0]}]
set_input_transition -min 0.05  [get_ports {gpio_in[10]}]
set_input_transition -min 0.05  [get_ports {gpio_in[11]}]
set_input_transition -min 0.05  [get_ports {gpio_in[12]}]
set_input_transition -min 0.05  [get_ports {gpio_in[13]}]
set_input_transition -min 0.05  [get_ports {gpio_in[14]}]
set_input_transition -min 0.05  [get_ports {gpio_in[15]}]
set_input_transition -min 0.05  [get_ports {gpio_in[16]}]
set_input_transition -min 0.05  [get_ports {gpio_in[17]}]
set_input_transition -min 0.05  [get_ports {gpio_in[18]}]
set_input_transition -min 0.05  [get_ports {gpio_in[19]}]
set_input_transition -min 0.05  [get_ports {gpio_in[1]}]
set_input_transition -min 0.05  [get_ports {gpio_in[20]}]
set_input_transition -min 0.05  [get_ports {gpio_in[21]}]
set_input_transition -min 0.05  [get_ports {gpio_in[22]}]
set_input_transition -min 0.05  [get_ports {gpio_in[23]}]
set_input_transition -min 0.05  [get_ports {gpio_in[24]}]
set_input_transition -min 0.05  [get_ports {gpio_in[25]}]
set_input_transition -min 0.05  [get_ports {gpio_in[26]}]
set_input_transition -min 0.05  [get_ports {gpio_in[27]}]
set_input_transition -min 0.05  [get_ports {gpio_in[28]}]
set_input_transition -min 0.05  [get_ports {gpio_in[29]}]
set_input_transition -min 0.05  [get_ports {gpio_in[2]}]
set_input_transition -min 0.05  [get_ports {gpio_in[30]}]
set_input_transition -min 0.05  [get_ports {gpio_in[31]}]
set_input_transition -min 0.05  [get_ports {gpio_in[32]}]
set_input_transition -min 0.05  [get_ports {gpio_in[33]}]
set_input_transition -min 0.05  [get_ports {gpio_in[34]}]
set_input_transition -min 0.05  [get_ports {gpio_in[35]}]
set_input_transition -min 0.05  [get_ports {gpio_in[36]}]
set_input_transition -min 0.05  [get_ports {gpio_in[37]}]
set_input_transition -min 0.05  [get_ports {gpio_in[38]}]
set_input_transition -min 0.05  [get_ports {gpio_in[39]}]
set_input_transition -min 0.05  [get_ports {gpio_in[3]}]
set_input_transition -min 0.05  [get_ports {gpio_in[40]}]
set_input_transition -min 0.05  [get_ports {gpio_in[41]}]
set_input_transition -min 0.05  [get_ports {gpio_in[42]}]
set_input_transition -min 0.05  [get_ports {gpio_in[43]}]
set_input_transition -min 0.05  [get_ports {gpio_in[4]}]
set_input_transition -min 0.05  [get_ports {gpio_in[5]}]
set_input_transition -min 0.05  [get_ports {gpio_in[6]}]
set_input_transition -min 0.05  [get_ports {gpio_in[7]}]
set_input_transition -min 0.05  [get_ports {gpio_in[8]}]
set_input_transition -min 0.05  [get_ports {gpio_in[9]}]

# Output delays
if { $::env(IO_SYNC) } {
	set out_ext_delay 4
	puts "\[INFO\]: Setting output ports external delay to: $out_ext_delay"
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_oeb[0]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_oeb[10]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_oeb[11]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_oeb[12]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_oeb[13]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_oeb[14]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_oeb[15]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_oeb[16]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_oeb[17]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_oeb[18]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_oeb[19]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_oeb[1]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_oeb[20]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_oeb[21]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_oeb[22]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_oeb[23]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_oeb[24]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_oeb[25]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_oeb[26]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_oeb[27]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_oeb[28]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_oeb[29]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_oeb[2]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_oeb[30]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_oeb[31]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_oeb[32]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_oeb[33]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_oeb[34]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_oeb[35]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_oeb[36]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_oeb[37]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_oeb[38]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_oeb[39]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_oeb[3]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_oeb[40]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_oeb[41]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_oeb[42]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_oeb[43]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_oeb[4]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_oeb[5]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_oeb[6]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_oeb[7]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_oeb[8]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_oeb[9]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_out[0]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_out[10]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_out[11]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_out[12]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_out[13]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_out[14]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_out[15]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_out[16]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_out[17]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_out[18]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_out[19]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_out[1]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_out[20]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_out[21]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_out[22]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_out[23]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_out[24]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_out[25]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_out[26]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_out[27]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_out[28]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_out[29]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_out[2]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_out[30]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_out[31]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_out[32]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_out[33]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_out[34]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_out[35]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_out[36]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_out[37]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_out[38]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_out[39]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_out[3]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_out[40]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_out[41]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_out[42]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_out[43]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_out[4]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_out[5]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_out[6]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_out[7]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_out[8]}]
	set_output_delay -max [expr $out_ext_delay + 9.02]-clock [get_clocks {clk}] [get_ports {gpio_out[9]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_oeb[0]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_oeb[10]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_oeb[11]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_oeb[12]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_oeb[13]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_oeb[14]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_oeb[15]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_oeb[16]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_oeb[17]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_oeb[18]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_oeb[19]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_oeb[1]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_oeb[20]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_oeb[21]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_oeb[22]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_oeb[23]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_oeb[24]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_oeb[25]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_oeb[26]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_oeb[27]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_oeb[28]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_oeb[29]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_oeb[2]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_oeb[30]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_oeb[31]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_oeb[32]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_oeb[33]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_oeb[34]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_oeb[35]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_oeb[36]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_oeb[37]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_oeb[38]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_oeb[39]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_oeb[3]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_oeb[40]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_oeb[41]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_oeb[42]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_oeb[43]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_oeb[4]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_oeb[5]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_oeb[6]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_oeb[7]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_oeb[8]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_oeb[9]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_out[0]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_out[10]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_out[11]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_out[12]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_out[13]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_out[14]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_out[15]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_out[16]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_out[17]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_out[18]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_out[19]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_out[1]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_out[20]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_out[21]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_out[22]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_out[23]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_out[24]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_out[25]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_out[26]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_out[27]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_out[28]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_out[29]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_out[2]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_out[30]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_out[31]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_out[32]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_out[33]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_out[34]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_out[35]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_out[36]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_out[37]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_out[38]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_out[39]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_out[3]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_out[40]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_out[41]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_out[42]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_out[43]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_out[4]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_out[5]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_out[6]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_out[7]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_out[8]}]
	set_output_delay -min [expr $out_ext_delay + 2.74]-clock [get_clocks {clk}] [get_ports {gpio_out[9]}]
}

# Output loads
set_load 0.14  [get_ports {gpio_oeb[0]}]
set_load 0.14  [get_ports {gpio_oeb[10]}]
set_load 0.14  [get_ports {gpio_oeb[11]}]
set_load 0.14  [get_ports {gpio_oeb[12]}]
set_load 0.14  [get_ports {gpio_oeb[13]}]
set_load 0.14  [get_ports {gpio_oeb[14]}]
set_load 0.14  [get_ports {gpio_oeb[15]}]
set_load 0.14  [get_ports {gpio_oeb[16]}]
set_load 0.14  [get_ports {gpio_oeb[17]}]
set_load 0.14  [get_ports {gpio_oeb[18]}]
set_load 0.14  [get_ports {gpio_oeb[19]}]
set_load 0.14  [get_ports {gpio_oeb[1]}]
set_load 0.14  [get_ports {gpio_oeb[20]}]
set_load 0.14  [get_ports {gpio_oeb[21]}]
set_load 0.14  [get_ports {gpio_oeb[22]}]
set_load 0.14  [get_ports {gpio_oeb[23]}]
set_load 0.14  [get_ports {gpio_oeb[24]}]
set_load 0.14  [get_ports {gpio_oeb[25]}]
set_load 0.14  [get_ports {gpio_oeb[26]}]
set_load 0.14  [get_ports {gpio_oeb[27]}]
set_load 0.14  [get_ports {gpio_oeb[28]}]
set_load 0.14  [get_ports {gpio_oeb[29]}]
set_load 0.14  [get_ports {gpio_oeb[2]}]
set_load 0.14  [get_ports {gpio_oeb[30]}]
set_load 0.14  [get_ports {gpio_oeb[31]}]
set_load 0.14  [get_ports {gpio_oeb[32]}]
set_load 0.14  [get_ports {gpio_oeb[33]}]
set_load 0.14  [get_ports {gpio_oeb[34]}]
set_load 0.14  [get_ports {gpio_oeb[35]}]
set_load 0.14  [get_ports {gpio_oeb[36]}]
set_load 0.14  [get_ports {gpio_oeb[37]}]
set_load 0.14  [get_ports {gpio_oeb[38]}]
set_load 0.14  [get_ports {gpio_oeb[39]}]
set_load 0.14  [get_ports {gpio_oeb[3]}]
set_load 0.14  [get_ports {gpio_oeb[40]}]
set_load 0.14  [get_ports {gpio_oeb[41]}]
set_load 0.14  [get_ports {gpio_oeb[42]}]
set_load 0.14  [get_ports {gpio_oeb[43]}]
set_load 0.14  [get_ports {gpio_oeb[4]}]
set_load 0.14  [get_ports {gpio_oeb[5]}]
set_load 0.14  [get_ports {gpio_oeb[6]}]
set_load 0.14  [get_ports {gpio_oeb[7]}]
set_load 0.14  [get_ports {gpio_oeb[8]}]
set_load 0.14  [get_ports {gpio_oeb[9]}]
set_load 0.14  [get_ports {gpio_out[0]}]
set_load 0.14  [get_ports {gpio_out[10]}]
set_load 0.14  [get_ports {gpio_out[11]}]
set_load 0.14  [get_ports {gpio_out[12]}]
set_load 0.14  [get_ports {gpio_out[13]}]
set_load 0.14  [get_ports {gpio_out[14]}]
set_load 0.14  [get_ports {gpio_out[15]}]
set_load 0.14  [get_ports {gpio_out[16]}]
set_load 0.14  [get_ports {gpio_out[17]}]
set_load 0.14  [get_ports {gpio_out[18]}]
set_load 0.14  [get_ports {gpio_out[19]}]
set_load 0.14  [get_ports {gpio_out[1]}]
set_load 0.14  [get_ports {gpio_out[20]}]
set_load 0.14  [get_ports {gpio_out[21]}]
set_load 0.14  [get_ports {gpio_out[22]}]
set_load 0.14  [get_ports {gpio_out[23]}]
set_load 0.14  [get_ports {gpio_out[24]}]
set_load 0.14  [get_ports {gpio_out[25]}]
set_load 0.14  [get_ports {gpio_out[26]}]
set_load 0.14  [get_ports {gpio_out[27]}]
set_load 0.14  [get_ports {gpio_out[28]}]
set_load 0.14  [get_ports {gpio_out[29]}]
set_load 0.14  [get_ports {gpio_out[2]}]
set_load 0.14  [get_ports {gpio_out[30]}]
set_load 0.14  [get_ports {gpio_out[31]}]
set_load 0.14  [get_ports {gpio_out[32]}]
set_load 0.14  [get_ports {gpio_out[33]}]
set_load 0.14  [get_ports {gpio_out[34]}]
set_load 0.14  [get_ports {gpio_out[35]}]
set_load 0.14  [get_ports {gpio_out[36]}]
set_load 0.14  [get_ports {gpio_out[37]}]
set_load 0.14  [get_ports {gpio_out[38]}]
set_load 0.14  [get_ports {gpio_out[39]}]
set_load 0.14  [get_ports {gpio_out[3]}]
set_load 0.14  [get_ports {gpio_out[40]}]
set_load 0.14  [get_ports {gpio_out[41]}]
set_load 0.14  [get_ports {gpio_out[42]}]
set_load 0.14  [get_ports {gpio_out[43]}]
set_load 0.14  [get_ports {gpio_out[4]}]
set_load 0.14  [get_ports {gpio_out[5]}]
set_load 0.14  [get_ports {gpio_out[6]}]
set_load 0.14  [get_ports {gpio_out[7]}]
set_load 0.14  [get_ports {gpio_out[8]}]
set_load 0.14  [get_ports {gpio_out[9]}]