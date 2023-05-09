// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
// This routine synchronizes the 

`include "clock_div.v"

module clock_routing (
`ifdef USE_POWER_PINS
    input VPWR,
    input VGND,
`endif
    input resetb, 	// Master (negative sense) reset
    input ext_clk_sel,	// 0=use DLL clock, 1=use external (pad) clock
    input ext_clk,	// External pad (slow) clock
    input dll_clk,	// Internal DLL (fast) clock
    input dll_clk90,	// Internal DLL (fast) clock, phase shifted
    input [2:0] sel,	// Select clock divider value (0=thru, 1=divide-by-2, etc.)
    input [2:0] sel2,	// Select aux clock divider value (0=thru, 1=divide-by-2, etc.)
    input [7:0] auxdiv, // Staged divider for auxiliary clock
    input [7:0] primdiv, // Staged divider for primary clock monitor
    input ext_reset,	// Positive sense reset from housekeeping SPI.
    output core_clk,	// Output core clock
    output aux_clk,	// Output auxiliary clock
    output mon_clk,	// Output core clock monitor
    output resetb_sync	// Output propagated and buffered reset
);

    wire dll_clk_sel;
    wire dll_clk_divided;
    wire dll_clk_monitor;
    wire dll_clk90_staged;
    wire dll_clk90_divided;
    wire core_ext_clk;
    reg  use_dll_first;
    reg  use_dll_second;
    reg	 ext_clk_syncd_pre;
    reg	 ext_clk_syncd;

    assign dll_clk_sel = ~ext_clk_sel;

    // Note that this implementation does not guard against switching to
    // the DLL clock if the DLL clock is not present.

    always @(posedge dll_clk or negedge resetb) begin
	if (resetb == 1'b0) begin
	    use_dll_first <= 1'b0;
	    use_dll_second <= 1'b0;
	    ext_clk_syncd <= 1'b0;
	end else begin
	    use_dll_first <= dll_clk_sel;
	    use_dll_second <= use_dll_first;
	    ext_clk_syncd_pre <= ext_clk;	// Sync ext_clk to dll_clk
	    ext_clk_syncd <= ext_clk_syncd_pre;	// Do this twice (resolve metastability)
	end
    end

    // Apply DLL clock divider

    clock_div #(
	.SIZE(3)
    ) core_first_divider (
	.in(dll_clk),
	.out(dll_clk_divided),
	.N(sel),
	.resetb(resetb)
    ); 

    // Apply primary clock monitor divider (up to 256x)
    clock_div #(
	.SIZE(8)
    ) core_second_divider (
	.in(core_clk),
	.out(mon_clk),
	.N(primdiv),
	.resetb(resetb)
    ); 

    // Apply auxiliary clock primary divider

    clock_div #(
	.SIZE(3)
    ) aux_first_divider (
	.in(dll_clk90),
	.out(dll_clk90_staged),
	.N(sel2),
	.resetb(resetb)
    ); 

    // Apply auxiliary clock secondary divider (up to 256x)
    clock_div #(
	.SIZE(8)
    ) aux_second_divider (
	.in(dll_clk90_staged),
	.out(aux_clk),
	.N(auxdiv),
	.resetb(resetb)
    ); 

    // Multiplex the clock output

    assign core_ext_clk = (use_dll_first) ? ext_clk_syncd : ext_clk;
    assign core_clk = (use_dll_second) ? dll_clk_divided : core_ext_clk;

    // Reset assignment.  "reset" comes from POR, while "ext_reset"
    // comes from standalone SPI (and is normally zero unless
    // activated from the SPI).

    // Staged-delay reset
    reg [2:0] reset_delay;

    always @(posedge core_clk or negedge resetb) begin
        if (resetb == 1'b0) begin
            reset_delay <= 3'b111;
        end else begin
            reset_delay <= {1'b0, reset_delay[2:1]};
        end
    end

    assign resetb_sync = ~(reset_delay[0] | ext_reset);

endmodule
`default_nettype wire
