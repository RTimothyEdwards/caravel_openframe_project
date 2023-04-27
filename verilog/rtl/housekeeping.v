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
//-------------------------------------
// SPI controller for Caravel (PicoSoC)
//-------------------------------------
// Written by Tim Edwards
// efabless, inc. September 27, 2020
//-------------------------------------

//-----------------------------------------------------------
// This is a standalone SPI for the caravel chip that is
// intended to be independent of the picosoc and independent
// of all IP blocks except the power-on-reset.  This SPI has
// register outputs controlling the functions that critically
// affect operation of the picosoc and so cannot be accessed
// from the picosoc itself.  This includes the DLL enables
// and trim, and the crystal oscillator enable.  It also has
// a general reset for the picosoc, an IRQ input, a bypass for
// the entire crystal oscillator and DLL chain, the
// manufacturer and product IDs and product revision number.
// To be independent of the 1.8V regulator, the SPI is
// synthesized with the 3V digital library and runs off of
// the 3V supply.
//
// This module is designed to be decoupled from the chip
// padframe and redirected to the wishbone bus under
// register control from the management SoC, such that the
// contents can be accessed from the management core via the
// SPI master.
//
//-----------------------------------------------------------

`include "housekeeping_spi.v"

//------------------------------------------------------------
// Caravel defined registers:
// Register 0:  SPI status and control (unused & reserved)
// Register 1 and 2:  Manufacturer ID (0x0456) (readonly)
// Register 3:  Product ID (= 20) (readonly)
// Register 4-7: Mask revision (readonly) --- Externally programmed
//	with via programming.  Via programmed with a script to match
//	each customer ID.
//
// Register 10:  IRQ (1 bit)
// Register 11:  reset (1 bit)
// Register 12:  trap (1 bit) (readonly)
// Register 13:  Clock monitor divider (8 bits)
// Register 14:  Auxiliary clock monitor divider (8 bits)
//------------------------------------------------------------

module housekeeping (
`ifdef USE_POWER_PINS
    VPWR, VGND, 
`endif
    RSTB, SCK, SDI, CSB, SDO, sdo_enb,
    dll_ena, dll_dco_ena, dll_div, dll_sel,
    dll90_sel, dll_trim, dll_bypass,
    mon_div, aux_div, irq, reset,
    trap, mask_rev_in, pass_thru_reset,
    pass_thru_sck, pass_thru_csb,
    pass_thru_sdi, pass_thru_sdo
);

`ifdef USE_POWER_PINS
    inout VPWR;	    // 1.8V supply
    inout VGND;	    // common ground
`endif
    
    input RSTB;	    // from padframe

    input SCK;	    // from padframe
    input SDI;	    // from padframe
    input CSB;	    // from padframe
    output SDO;	    // to padframe
    output sdo_enb; // to padframe

    output dll_ena;
    output dll_dco_ena;
    output [4:0] dll_div;
    output [2:0] dll_sel;
    output [2:0] dll90_sel;
    output [25:0] dll_trim;
    output dll_bypass;
    output [7:0] aux_div;
    output [7:0] mon_div;
    output irq;
    output reset;
    input  trap;
    input [31:0] mask_rev_in;	// metal programmed;  3.3V domain

    // Pass-through programming mode for management area SPI flash
    output pass_thru_reset;
    output pass_thru_sck;
    output pass_thru_csb;
    output pass_thru_sdi;
    input  pass_thru_sdo;

    reg [25:0] dll_trim;
    reg [4:0] dll_div;
    reg [2:0] dll_sel;
    reg [2:0] dll90_sel;
    reg [7:0] mon_div;
    reg [7:0] aux_div;
    reg dll_dco_ena;
    reg dll_ena;
    reg dll_bypass;
    reg reset_reg;
    reg irq;

    wire [7:0] odata;
    wire [7:0] idata;
    wire [7:0] iaddr;

    wire trap;
    wire rdstb;
    wire wrstb;
    wire pass_thru;		// Mode detected by spi
    wire pass_thru_delay;
    wire loc_sdo;

    // Pass-through mode handling.  Signals may only be applied when the
    // core processor is in reset.

    assign pass_thru_csb = reset ? ~pass_thru_delay : 1'bz;
    assign pass_thru_sck = reset ? (pass_thru ? SCK : 1'b0) : 1'bz;
    assign pass_thru_sdi = reset ? (pass_thru ? SDI : 1'b0) : 1'bz;

    assign SDO = pass_thru ? pass_thru_sdo : loc_sdo;
    assign reset = pass_thru_reset ? 1'b1 : reset_reg;

    // Instantiate the SPI interface

    housekeeping_spi spi (
	.reset(~RSTB),
    	.SCK(SCK),
    	.SDI(SDI),
    	.CSB(CSB),
    	.SDO(loc_sdo),
    	.sdoenb(sdo_enb),
    	.idata(odata),
    	.odata(idata),
    	.oaddr(iaddr),
    	.rdstb(rdstb),
    	.wrstb(wrstb),
    	.pass_thru(pass_thru),
    	.pass_thru_delay(pass_thru_delay),
    	.pass_thru_reset(pass_thru_reset)
    );

    wire [11:0] mfgr_id;
    wire [7:0]  prod_id;
    wire [31:0] mask_rev;

    assign mfgr_id = 12'h456;		// Hard-coded
    assign prod_id = 8'h14;		// Hard-coded
    assign mask_rev = mask_rev_in;	// Copy in to out.

    // Send register contents to odata on SPI read command
    // All values are 1-4 bits and no shadow registers are required.

    assign odata = 
    (iaddr == 8'h00) ? 8'h00 :	// SPI status (fixed)
    (iaddr == 8'h01) ? {4'h0, mfgr_id[11:8]} :	// Manufacturer ID (fixed)
    (iaddr == 8'h02) ? mfgr_id[7:0] :	// Manufacturer ID (fixed)
    (iaddr == 8'h03) ? prod_id :	// Product ID (fixed)
    (iaddr == 8'h04) ? mask_rev[31:24] :	// Mask rev (metal programmed)
    (iaddr == 8'h05) ? mask_rev[23:16] :	// Mask rev (metal programmed)
    (iaddr == 8'h06) ? mask_rev[15:8] :		// Mask rev (metal programmed)
    (iaddr == 8'h07) ? mask_rev[7:0] :		// Mask rev (metal programmed)

    (iaddr == 8'h08) ? {6'b000000, dll_dco_ena, dll_ena} :
    (iaddr == 8'h09) ? {7'b0000000, dll_bypass} :
    (iaddr == 8'h0a) ? {7'b0000000, irq} :
    (iaddr == 8'h0b) ? {7'b0000000, reset} :
    (iaddr == 8'h0c) ? {7'b0000000, trap} :
    (iaddr == 8'h0d) ? dll_trim[7:0] :
    (iaddr == 8'h0e) ? dll_trim[15:8] :
    (iaddr == 8'h0f) ? dll_trim[23:16] :
    (iaddr == 8'h10) ? {6'b000000, dll_trim[25:24]} :
    (iaddr == 8'h11) ? {2'b00, dll90_sel, dll_sel} :
    (iaddr == 8'h12) ? {3'b000, dll_div} :
    (iaddr == 8'h13) ? mon_div :
    (iaddr == 8'h14) ? aux_div :
               8'h00;	// Default

    // Register mapping and I/O to module

    always @(posedge SCK or negedge RSTB) begin
    if (RSTB == 1'b0) begin
        // Set trim for DLL at (almost) slowest rate (~90MHz).  However,
        // dll_trim[12] must be set to zero for proper startup.
        dll_trim <= 26'b11111111111110111111111111;
        dll_sel <= 3'b010;	// Default output divider divide-by-2
        dll90_sel <= 3'b010;	// Default secondary output divider divide-by-2
        dll_div <= 5'b00100;	// Default feedback divider divide-by-8
        dll_dco_ena <= 1'b1;	// Default free-running DLL
        dll_ena <= 1'b0;	// Default DLL turned off
        dll_bypass <= 1'b1;	// Default bypass mode (don't use DLL)
	mon_div <= 8'd100;	// Clock monitor divider (100x)
	aux_div <= 8'd100;	// Auxiliary clock divider (100x)
        irq <= 1'b0;
        reset_reg <= 1'b0;
    end else if (wrstb == 1'b1) begin
        case (iaddr)
        8'h08: begin
             dll_ena <= idata[0];
             dll_dco_ena <= idata[1];
               end
        8'h09: begin
             dll_bypass <= idata[0];
               end
        8'h0a: begin
             irq <= idata[0];
               end
        8'h0b: begin
             reset_reg <= idata[0];
               end
        // Register 0xc is read-only
        8'h0d: begin
              dll_trim[7:0] <= idata;
               end
        8'h0e: begin
              dll_trim[15:8] <= idata;
               end
        8'h0f: begin
              dll_trim[23:16] <= idata;
               end
        8'h10: begin
              dll_trim[25:24] <= idata[1:0];
               end
        8'h11: begin
             dll_sel <= idata[2:0];
             dll90_sel <= idata[5:3];
               end
        8'h12: begin
             dll_div <= idata[4:0];
               end
        8'h13: begin
             mon_div <= idata;
	       end
        8'h14: begin
             aux_div <= idata;
	       end
        endcase	// (iaddr)
    end
    end
endmodule	// housekeeping

`default_nettype wire
