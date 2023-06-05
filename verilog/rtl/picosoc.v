`default_nettype none
/*
 *  SPDX-FileCopyrightText: 2015 Clifford Wolf
 *  PicoSoC - A simple example SoC using PicoRV32
 *
 *  Copyright (C) 2017  Clifford Wolf <clifford@clifford.at>
 *
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 *  Revision 1,  July 2019:  Added signals to drive flash_clk and flash_csb
 *  output enable (inverted), tied to reset so that the flash is completely
 *  isolated from the processor when the processor is in reset.
 *
 *  Also: Made ram_wenb a 4-bit bus so that the memory access can be made
 *  byte-wide for byte-wide instructions.
 *
 *  SPDX-License-Identifier: ISC
 */

/*----------------------------------------------------------------------*/
/* PicoSoC design for Caravel Openframe					*/
/* Written by Tim Edwards						*/
/* April 26, 2023							*/
/* Efabless Corporation							*/
/*----------------------------------------------------------------------*/

`ifdef PICORV32_V
`error "picosoc.v must be read before picorv32.v!"
`endif

`define PICORV32_REGS picosoc_regs

/* NOTE:  MEM_WORDS must be consistent with the selection of SRAM	*/
/* macro instances in mem_wb.v.	 1024 words = 4kB (2 2kB SRAM modules)	*/
`define MEM_WORDS 1024
`ifndef COCOTB_SIM
`include "picorv32.v"
`include "spimemio.v"
`include "simpleuart.v"
`include "clock_routing.v"
`include "housekeeping.v"
`include "digital_locked_loop.v"
`include "simple_spi_master.v"
`include "counter_timer_high.v"
`include "counter_timer_low.v"
`include "intercon_wb.v"
`include "mem_wb.v"
`include "gpio_wb.v"
`include "gpio_vector_wb.v"
/* From the Sky130 PDK */
`ifdef SIM
`include "libs.ref/sky130_sram_macros/verilog/sky130_sram_2kbyte_1rw1r_32x512_8.v"
`endif
`endif // COCOTB_SIM

/*--------------------------------------------------------------*/
/* picosoc:  Assembly of the picoRV32 core and various modules	*/
/* that use the wishbone bus, such as memory, the GPIO drivers,	*/
/* SPI master, and UART.  This routine maps the SoC functions	*/
/* to the I/Os.							*/
/*								*/
/* This module includes all parts of the system including the	*/
/* clock routing, digital locked loop, and housekeeping SPI	*/
/* interface.							*/
/*								*/
/* GPIO mapping:  This mapping preserves the original Caravel	*/
/* MPW-one pinout in the Openframe layout.  GPIOs along the	*/
/* bottom of the chip are re-mapped back to their original	*/
/* functions for clock, reset, and SPI flash communication.	*/
/*								*/
/* GPIO[1]  = Housekeeping SDO					*/
/* GPIO[2]  = Housekeeping SDI					*/
/* GPIO[3]  = Housekeeping CSB					*/
/* GPIO[4]  = Housekeeping SCK					*/
/* GPIO[5]  = UART Rx						*/
/* GPIO[6]  = UART Tx						*/
/* GPIO[7]  = IRQ1 input					*/
/* GPIO[8]  = SPI master CSB					*/
/* GPIO[9]  = SPI master SCK					*/
/* GPIO[10] = SPI master SDI					*/
/* GPIO[11] = SPI master SDO					*/
/* GPIO[12] = IRQ2 input					*/
/* GPIO[13] = Trap monitor					*/
/* GPIO[14] = Clock1 monitor					*/
/* GPIO[15] = Clock2 monitor					*/
/*								*/
/* GPIO[36] = flash IO2						*/
/* GPIO[37] = flash IO3						*/
/* GPIO[38] = clock						*/
/* GPIO[39] = flash CSB						*/
/* GPIO[40] = flash clock					*/
/* GPIO[41] = flash IO0						*/
/* GPIO[42] = flash IO1						*/
/*								*/
/* GPIO 16 through 35 have no special purpose function and	*/
/* operate only through manual control from the CPU.		*/
/*--------------------------------------------------------------*/

module picosoc (
    `ifdef USE_POWER_PINS
	inout VPWR,		/* 1.8V domain */
	inout VGND,
    `endif
    input  porb,		/* Power-on-reset (inverted)	 */
    input  por,			/* Power-on-reset (non-inverted) */
    input  resetb,		/* Master (pin) reset (inverted) */
    input  [31:0] mask_rev,	/* Mask revision (via programmed ROM) */
    input  [`OPENFRAME_IO_PADS-1:0] gpio_in,	/* Input from GPIO */
    output [`OPENFRAME_IO_PADS-1:0] gpio_out,	/* Output to GPIO */
    output [`OPENFRAME_IO_PADS-1:0] gpio_oeb,	/* GPIO output enable (inverted) */
    output [`OPENFRAME_IO_PADS-1:0] gpio_ieb,	/* GPIO input enable (inverted) */
    output [`OPENFRAME_IO_PADS-1:0] gpio_ib_mode_sel,	/* GPIO mode */
    output [`OPENFRAME_IO_PADS-1:0] gpio_vtrip_sel,	/* GPIO threshold */
    output [`OPENFRAME_IO_PADS-1:0] gpio_slow_sel,	/* GPIO slew rate */
    output [`OPENFRAME_IO_PADS-1:0] gpio_dm2,		/* GPIO digital mode */
    output [`OPENFRAME_IO_PADS-1:0] gpio_dm1,		/* GPIO digital mode */
    output [`OPENFRAME_IO_PADS-1:0] gpio_dm0,		/* GPIO digital mode */
    input  [`OPENFRAME_IO_PADS-1:0] gpio_loopback_one,	/* Value 1 for loopback */
    input  [`OPENFRAME_IO_PADS-1:0] gpio_loopback_zero	/* Value 0 for loopback */
);

    /* PicoRV32 configuration */
    parameter [31:0] STACKADDR = (4*(`MEM_WORDS));       // end of memory
    parameter [31:0] PROGADDR_RESET = 32'h 1000_0000; 
    parameter [31:0] PROGADDR_IRQ   = 32'h 0000_0000;

    // Wishbone base addresses
    parameter RAM_BASE_ADR    = 32'h0000_0000;
    parameter FLASH_BASE_ADR  = 32'h1000_0000;
    parameter UART_BASE_ADR   = 32'h2000_0000;
    parameter GPIO_BASE_ADR   = 32'h2100_0000;
    parameter COUNTER_TIMER0_BASE_ADR = 32'h2200_0000;
    parameter COUNTER_TIMER1_BASE_ADR = 32'h2300_0000;
    parameter SPI_MASTER_BASE_ADR = 32'h2400_0000;
    parameter GPIO_VECTOR_BASE_ADR  = 32'h2500_0000;
    parameter FLASH_CTRL_CFG  = 32'h2D00_0000;
    parameter DEBUG_REGS_CFG  = 32'h4100_0000;
    
    // Wishbone Interconnect 
    localparam ADR_WIDTH = 32;
    localparam DAT_WIDTH = 32;
    localparam NUM_IFACE = 10;

    parameter [NUM_IFACE*ADR_WIDTH-1: 0] ADR_MASK = {
        {8'hFF, {ADR_WIDTH-8{1'b0}}},
        {8'hFF, {ADR_WIDTH-8{1'b0}}},
        {8'hFF, {ADR_WIDTH-8{1'b0}}},
        {8'hFF, {ADR_WIDTH-8{1'b0}}},
        {8'hFF, {ADR_WIDTH-8{1'b0}}},
        {8'hFF, {ADR_WIDTH-8{1'b0}}},
        {8'hFF, {ADR_WIDTH-8{1'b0}}},
        {8'hFF, {ADR_WIDTH-8{1'b0}}},
        {8'hFF, {ADR_WIDTH-8{1'b0}}},
        {8'hFF, {ADR_WIDTH-8{1'b0}}}
    };

    parameter [NUM_IFACE*ADR_WIDTH-1: 0] IFACE_ADR = {
        {DEBUG_REGS_CFG},
        {FLASH_CTRL_CFG},
	{SPI_MASTER_BASE_ADR},
	{COUNTER_TIMER1_BASE_ADR},
	{COUNTER_TIMER0_BASE_ADR},
        {GPIO_BASE_ADR},
        {GPIO_VECTOR_BASE_ADR},
        {UART_BASE_ADR},
        {FLASH_BASE_ADR},
        {RAM_BASE_ADR}
    };

    // memory-mapped I/O control registers

    reg [31:0] irq;
    wire irq_7;
    wire irq_8;
    wire irq_stall;
    wire irq_uart;
    wire irq_spi_master;
    wire irq_counter_timer0;
    wire irq_counter_timer1;

    wire wb_clk_i;
    wire wb_rst_i;

    wire [`OPENFRAME_IO_PADS-1:0] cpu_gpio_in;
    wire [`OPENFRAME_IO_PADS-1:0] cpu_gpio_out;
    wire [`OPENFRAME_IO_PADS-1:0] cpu_gpio_oeb;
    wire [`OPENFRAME_IO_PADS-1:0] cpu_gpio_ieb;

    wire irq_spi;
    wire core_clk;
    wire trap;
    wire pass_thru;
    wire pass_thru_csb;
    wire pass_thru_sck;
    wire pass_thru_sdi;
    wire pass_thru_sdo;
    wire hk_connect;
    wire aux_clk;
    wire mon_clk;
    wire ext_clk_sel;
    wire dll_clk;
    wire dll_clk90;
    wire ext_reset;
    wire core_rstn;
    wire spi_dll_ena;
    wire spi_dll_dco_ena;

    /* Interrupt channel assignments */

    assign irq_stall = 0;
    assign irq_7 = cpu_gpio_in[7];
    assign irq_8 = cpu_gpio_in[12];

    assign irq_uart = 0;	// Needs to be generated by UART receive

    always @* begin
        irq = 0;
        irq[3] = irq_stall;
        irq[4] = irq_uart;
        irq[6] = irq_spi;
        irq[7] = irq_7;
        irq[8] = irq_8;
        irq[9] = irq_spi_master;
        irq[10] = irq_counter_timer0;
        irq[11] = irq_counter_timer1;
    end

    assign wb_clk_i = core_clk;
    // assign wb_rst_i = ~resetb;
    assign wb_rst_i = ~core_rstn;

    // Wishbone Master
    wire [31:0] cpu_adr_o;
    wire [31:0] cpu_dat_i;
    wire [3:0] cpu_sel_o;
    wire cpu_we_o;
    wire cpu_cyc_o;
    wire cpu_stb_o;
    wire [31:0] cpu_dat_o;
    wire cpu_ack_i;
    wire mem_instr;
    
    picorv32_wb #(
        .STACKADDR(STACKADDR),
        .PROGADDR_RESET(PROGADDR_RESET),
        .PROGADDR_IRQ(PROGADDR_IRQ),
        .BARREL_SHIFTER(1),
        .COMPRESSED_ISA(1),
        .ENABLE_MUL(1),
        .ENABLE_DIV(1),
        .ENABLE_IRQ(1),
        .ENABLE_IRQ_QREGS(0)
    ) cpu (
        .wb_clk_i (wb_clk_i),
        .wb_rst_i (wb_rst_i),
        .trap     (trap),
        .irq      (irq),
        .mem_instr(mem_instr),
        .wbm_adr_o(cpu_adr_o),     
        .wbm_dat_i(cpu_dat_i),    
        .wbm_stb_o(cpu_stb_o),    
        .wbm_ack_i(cpu_ack_i),    
        .wbm_cyc_o(cpu_cyc_o),    
        .wbm_dat_o(cpu_dat_o),    
        .wbm_we_o(cpu_we_o),      
        .wbm_sel_o(cpu_sel_o)     
    );

    // Wishbone SPI flash controller
    wire spimemio_flash_stb_i;
    wire spimemio_flash_ack_o;
    wire [31:0] spimemio_flash_dat_o;

    wire spimemio_cfg_stb_i;
    wire spimemio_cfg_ack_o;
    wire [31:0] spimemio_cfg_dat_o;
    wire spimemio_quad_mode;

    spimemio_wb spimemio (
        .wb_clk_i(wb_clk_i),
        .wb_rst_i(wb_rst_i),

        .wb_adr_i(cpu_adr_o), 
        .wb_dat_i(cpu_dat_o),
        .wb_sel_i(cpu_sel_o),
        .wb_we_i(cpu_we_o),
        .wb_cyc_i(cpu_cyc_o),

        // Flash Controller
        .wb_flash_stb_i(spimemio_flash_stb_i),
        .wb_flash_ack_o(spimemio_flash_ack_o),
        .wb_flash_dat_o(spimemio_flash_dat_o),
        
        // Flash Config Register
        .wb_cfg_stb_i(spimemio_cfg_stb_i),
        .wb_cfg_ack_o(spimemio_cfg_ack_o),
        .wb_cfg_dat_o(spimemio_cfg_dat_o),

        .quad_mode(spimemio_quad_mode),
        .pass_thru(pass_thru),
        .pass_thru_csb(pass_thru_csb),
        .pass_thru_sck(pass_thru_sck),
        .pass_thru_sdi(pass_thru_sdi),
        .pass_thru_sdo(pass_thru_sdo),

        .flash_csb (cpu_gpio_out[39]),
        .flash_clk (cpu_gpio_out[40]),

        .flash_csb_oeb (cpu_gpio_oeb[39]),
        .flash_clk_oeb (cpu_gpio_oeb[40]),

        .flash_io0_oeb (cpu_gpio_oeb[41]),
        .flash_io1_oeb (cpu_gpio_oeb[42]),
        .flash_io2_oeb (cpu_gpio_oeb[36]),
        .flash_io3_oeb (cpu_gpio_oeb[37]),

        .flash_io0_ieb (cpu_gpio_ieb[41]),
        .flash_io1_ieb (cpu_gpio_ieb[42]),
        .flash_io2_ieb (cpu_gpio_ieb[36]),
        .flash_io3_ieb (cpu_gpio_ieb[37]),

        .flash_io0_do (cpu_gpio_out[41]),
        .flash_io1_do (cpu_gpio_out[42]),
        .flash_io2_do (cpu_gpio_out[36]),
        .flash_io3_do (cpu_gpio_out[37]),

        .flash_io0_di (cpu_gpio_in[41]),
        .flash_io1_di (cpu_gpio_in[42]),
        .flash_io2_di (cpu_gpio_in[36]),
        .flash_io3_di (cpu_gpio_in[37])
    );

    // Wishbone Slave uart	
    wire uart_stb_i;
    wire uart_ack_o;
    wire [31:0] uart_dat_o;
    wire uart_enabled;

    simpleuart_wb #(
        .BASE_ADR(UART_BASE_ADR)
    ) simpleuart (
        // Wishbone Interface
        .wb_clk_i(wb_clk_i),
        .wb_rst_i(wb_rst_i),

        .wb_adr_i(cpu_adr_o),      
        .wb_dat_i(cpu_dat_o),
        .wb_sel_i(cpu_sel_o),
        .wb_we_i(cpu_we_o),
        .wb_cyc_i(cpu_cyc_o),

        .wb_stb_i(uart_stb_i),
        .wb_ack_o(uart_ack_o),
        .wb_dat_o(uart_dat_o),

	.uart_enabled(uart_enabled),
        .ser_tx(cpu_gpio_out[6]),
        .ser_rx(cpu_gpio_in[5])
    );

    // Wishbone SPI master
    wire spi_master_stb_i;
    wire spi_master_ack_o;
    wire [31:0] spi_master_dat_o;
    wire spi_enabled;
    wire spi_csb, spi_sck, spi_sdo;

    simple_spi_master_wb #(
        .BASE_ADR(SPI_MASTER_BASE_ADR)
    ) simple_spi_master_inst (
        // Wishbone Interface
        .wb_clk_i(wb_clk_i),
        .wb_rst_i(wb_rst_i),

        .wb_adr_i(cpu_adr_o),      
        .wb_dat_i(cpu_dat_o),
        .wb_sel_i(cpu_sel_o),
        .wb_we_i(cpu_we_o),
        .wb_cyc_i(cpu_cyc_o),

        .wb_stb_i(spi_master_stb_i),
        .wb_ack_o(spi_master_ack_o),
        .wb_dat_o(spi_master_dat_o),

	.hk_connect(hk_connect),
	.spi_enabled(spi_enabled),
        .csb(cpu_gpio_out[8]),
        .sck(cpu_gpio_out[9]),
        .sdi((hk_connect) ? cpu_gpio_out[1] : cpu_gpio_in[10]),
        .sdo(cpu_gpio_out[11]),
        .sdoenb(cpu_gpio_oeb[11]),
	.irq(irq_spi_master)
    );

    wire counter_timer_strobe, counter_timer_offset;
    wire counter_timer0_enable, counter_timer1_enable;
    wire counter_timer0_stop, counter_timer1_stop;

    // Wishbone Counter-timer 0
    wire counter_timer0_stb_i;
    wire counter_timer0_ack_o;
    wire [31:0] counter_timer0_dat_o;

    counter_timer_low_wb #(
        .BASE_ADR(COUNTER_TIMER0_BASE_ADR)
    ) counter_timer_0 (
        // Wishbone Interface
        .wb_clk_i(wb_clk_i),
        .wb_rst_i(wb_rst_i),

        .wb_adr_i(cpu_adr_o),      
        .wb_dat_i(cpu_dat_o),
        .wb_sel_i(cpu_sel_o),
        .wb_we_i(cpu_we_o),
        .wb_cyc_i(cpu_cyc_o),

        .wb_stb_i(counter_timer0_stb_i),
        .wb_ack_o(counter_timer0_ack_o),
        .wb_dat_o(counter_timer0_dat_o),

	.enable_in(counter_timer1_enable),
	.stop_in(counter_timer1_stop),
	.strobe(counter_timer_strobe),
	.is_offset(counter_timer_offset),
	.enable_out(counter_timer0_enable),
	.stop_out(counter_timer0_stop),
	.irq(irq_counter_timer0)
    );

    // Wishbone Counter-timer 1
    wire counter_timer1_stb_i;
    wire counter_timer1_ack_o;
    wire [31:0] counter_timer1_dat_o;

    counter_timer_high_wb #(
        .BASE_ADR(COUNTER_TIMER1_BASE_ADR)
    ) counter_timer_1 (
        // Wishbone Interface
        .wb_clk_i(wb_clk_i),
        .wb_rst_i(wb_rst_i),

        .wb_adr_i(cpu_adr_o),      
        .wb_dat_i(cpu_dat_o),
        .wb_sel_i(cpu_sel_o),
        .wb_we_i(cpu_we_o),
        .wb_cyc_i(cpu_cyc_o),

        .wb_stb_i(counter_timer1_stb_i),
        .wb_ack_o(counter_timer1_ack_o),
        .wb_dat_o(counter_timer1_dat_o),

	.enable_in(counter_timer0_enable),
	.strobe(counter_timer_strobe),
	.stop_in(counter_timer0_stop),
	.is_offset(counter_timer_offset),
	.enable_out(counter_timer1_enable),
	.stop_out(counter_timer1_stop),
	.irq(irq_counter_timer1)
    );

    // Wishbone GPIO Registers
    wire gpio_stb_i;
    wire [`OPENFRAME_IO_PADS-1:0] gpio_ack_o;
    wire [31:0] gpio_dat_o [`OPENFRAME_IO_PADS-1:0];

    wire gpio_all_ack_o;		// Combined output
    reg [31:0] gpio_all_dat_o;		// Combined output

    // GPIO default configurations for each pad
    // bit 11	fixed output value
    // bit 10   fixed output enable value
    // bit 9	fixed input enable value
    // bit 8	override output
    // bit 7	override output enable
    // bit 6	override input enable
    // bit 5	slow slew
    // bit 4	TTL trip point
    // bit 3	I-B mode
    // bits 2-0 digital mode

    // b a 9 8 7 6 5 4 3 2 1 0
    //-------------------------
    // 0 0 1 0 1 1 0 0 0 1 1 0	(12'h2c6) vector mode output
    // 0 1 0 0 1 1 0 0 0 0 0 1  (12'h4c1) vector mode input
    // 1 0 0 1 1 1 0 0 0 0 1 0  (12'h9c2) vector mode input, weak pull-up
    // 0 0 0 1 1 1 0 0 0 0 1 1  (12'h1c3) vector mode input, weak pull-down
    // 0 0 0 0 0 0 0 0 0 1 1 0  (12'h006) bidirectional controlled mode
    // 0 0 1 1 1 0 0 0 0 1 1 0  (12'h386) force zero output
    // 1 0 1 1 1 0 0 0 0 1 1 0  (12'hb86) force one output


    parameter [(`OPENFRAME_IO_PADS*12)-1:0] CONFIG_GPIO_INIT = {
        {12'h4c1},	// GPIO[43] General purpose	input
        {12'h006},	// GPIO[42] Flash IO1		bidirectional
        {12'h006},	// GPIO[41] Flash IO0		bidirectional
        {12'h2c6},	// GPIO[40] Flash clock		output
        {12'h2c6},	// GPIO[39] Flash CSB		output
        {12'h4c1},	// GPIO[38] clock		input
        {12'h006},	// GPIO[37] Flash IO3		bidirectional
        {12'h006},	// GPIO[36] Flash IO2		bidirectional
        {12'h4c1},	// GPIO[35] General purpose	input
        {12'h4c1},	// GPIO[34] General purpose	input
        {12'h4c1},	// GPIO[33] General purpose	input
        {12'h4c1},	// GPIO[32] General purpose	input
        {12'h4c1},	// GPIO[31] General purpose	input
        {12'h4c1},	// GPIO[30] General purpose	input
        {12'h4c1},	// GPIO[29] General purpose	input
        {12'h4c1},	// GPIO[28] General purpose	input
        {12'h4c1},	// GPIO[27] General purpose	input
        {12'h4c1},	// GPIO[26] General purpose	input
        {12'h4c1},	// GPIO[25] General purpose	input
        {12'h4c1},	// GPIO[24] General purpose	input
        {12'h4c1},	// GPIO[23] General purpose	input
        {12'h4c1},	// GPIO[22] General purpose	input
        {12'h4c1},	// GPIO[21] General purpose	input
        {12'h4c1},	// GPIO[20] General purpose	input
        {12'h4c1},	// GPIO[19] General purpose	input
        {12'h4c1},	// GPIO[18] General purpose	input
        {12'h4c1},	// GPIO[17] General purpose	input
        {12'h4c1},	// GPIO[16] General purpose	input
        {12'h2c6},	// GPIO[15] Clock2 monitor	output
        {12'h2c6},	// GPIO[14] Clock1 monitor	output
        {12'h2c6},	// GPIO[13] Trap monitor	output
        {12'h1c3},	// GPIO[12] IRQ2 input		input, pulldown
        {12'h006},	// GPIO[11] SPI master SDO	bidirectional
        {12'h4c1},	// GPIO[10] SPI master SDI	input
        {12'h2c6},	// GPIO[9] SPI master SCK	output
        {12'h2c6},	// GPIO[8] SPI master CSB	output
        {12'h1c3},	// GPIO[7] IRQ1 input		input, pulldown
        {12'h2c6},	// GPIO[6] UART Tx		output
        {12'h4c1},	// GPIO[5] UART Rx	 	input
        {12'h4c1},	// GPIO[4] Housekeeping SCK	input
        {12'h4c1},	// GPIO[3] Housekeeping CSB	input
        {12'h4c1},	// GPIO[2] Housekeeping SDI	input
        {12'h006},	// GPIO[1] Housekeeping SDO	bidirectional
        {12'h4c1}	// GPIO[0] General purpose	input
    };

    genvar i;
    generate
	for (i = 0; i < `OPENFRAME_IO_PADS; i = i + 1) begin
	    gpio_wb #(
		.GPIO_DEFAULTS(CONFIG_GPIO_INIT[((i+1)*12)-1:i*12]),
        	.BASE_ADR(GPIO_BASE_ADR + 4 * i)
	    ) gpio_wb (
		.wb_clk_i(wb_clk_i),
		.wb_rst_i(wb_rst_i),
		.wb_adr_i(cpu_adr_o), 
		.wb_dat_i(cpu_dat_o),
		.wb_sel_i(cpu_sel_o),
		.wb_we_i(cpu_we_o),
		.wb_cyc_i(cpu_cyc_o),
		.wb_stb_i(gpio_stb_i),
		.wb_ack_o(gpio_ack_o[i]),
		.wb_dat_o(gpio_dat_o[i]),

		.cpu_gpio_in(cpu_gpio_in[i]),
		.cpu_gpio_out(cpu_gpio_out[i]),
		.cpu_gpio_oeb(cpu_gpio_oeb[i]),
		.cpu_gpio_ieb(cpu_gpio_ieb[i]),

		.pad_gpio_in(gpio_in[i]),
		.pad_gpio_out(gpio_out[i]),
		.pad_gpio_oeb(gpio_oeb[i]),
		.pad_gpio_ieb(gpio_ieb[i]),

		.pad_gpio_slow_sel(gpio_slow_sel[i]),
		.pad_gpio_vtrip_sel(gpio_vtrip_sel[i]),
		.pad_gpio_ib_mode_sel(gpio_ib_mode_sel[i]),
		.pad_gpio_dm({gpio_dm2[i], gpio_dm1[i], gpio_dm0[i]})
	    );

	end

	/* Combine bits from all GPIO wishbone data outputs so that they
	 * can be handled in one wishbone interface.
	 */
	integer k, j;

    always @(*) begin
        for (k = 0; k < 32; k = k + 1) begin
            gpio_all_dat_o[k] = 1'b0;
            for (j = 0; j < `OPENFRAME_IO_PADS; j = j + 1) begin
                gpio_all_dat_o[k] = gpio_all_dat_o[k] | gpio_dat_o[j][k];
            end
        end
    end
	assign gpio_all_ack_o = |(gpio_ack_o[`OPENFRAME_IO_PADS-1:0]);

	/* GPIOs with dedicated functions that have no output
	 * should have OEB should be tied high and IEB tied low.
	 * The output is connected to the GPIO vector but due to
	 * the OEB setting, can only be used by forcing OEB override.
	 */

	assign cpu_gpio_oeb[2] = gpio_loopback_one[2];   /* SDI */
	assign cpu_gpio_oeb[3] = gpio_loopback_one[3];   /* CSB */
	assign cpu_gpio_oeb[4] = gpio_loopback_one[4];	  /* SCK */
	assign cpu_gpio_oeb[5] = gpio_loopback_one[5];   /* Rx */
	assign cpu_gpio_oeb[7] = gpio_loopback_one[7];   /* IRQ1 */
	assign cpu_gpio_oeb[8] = gpio_loopback_one[8];   /* mCSB */
	assign cpu_gpio_oeb[9] = gpio_loopback_one[9];   /* mSCK */
	assign cpu_gpio_oeb[10] = gpio_loopback_one[10]; /* mSDI */
	assign cpu_gpio_oeb[12] = gpio_loopback_one[12]; /* IRQ2 */
	assign cpu_gpio_oeb[38] = gpio_loopback_one[38]; /* clock */

	assign cpu_gpio_ieb[1] = gpio_loopback_one[1];    /* SDO */
	assign cpu_gpio_ieb[2] = gpio_loopback_zero[2];   /* SDI */
	assign cpu_gpio_ieb[3] = gpio_loopback_zero[3];   /* CSB */
	assign cpu_gpio_ieb[4] = gpio_loopback_zero[4];	  /* SCK */
	assign cpu_gpio_ieb[5] = gpio_loopback_zero[5];   /* Rx */
	assign cpu_gpio_ieb[7] = gpio_loopback_zero[7];   /* IRQ1 */
	assign cpu_gpio_ieb[8] = gpio_loopback_zero[8];   /* mCSB */
	assign cpu_gpio_ieb[9] = gpio_loopback_zero[9];   /* mSCK */
	assign cpu_gpio_ieb[10] = gpio_loopback_zero[10]; /* mSDI */
	assign cpu_gpio_ieb[11] = gpio_loopback_one[11];  /* mSDO */
	assign cpu_gpio_ieb[12] = gpio_loopback_zero[12]; /* IRQ2 */
	assign cpu_gpio_ieb[38] = gpio_loopback_zero[38]; /* clock */

	/* GPIOs with dedicated functions that are output only
	 * should have OEB set to zero and IEB set to one.
	 */
	assign cpu_gpio_oeb[6] = gpio_loopback_zero[6];   /* Tx */
	assign cpu_gpio_oeb[13] = gpio_loopback_zero[13]; /* Trap monitor */
	assign cpu_gpio_oeb[14] = gpio_loopback_zero[14]; /* Clock1 monitor */
	assign cpu_gpio_oeb[15] = gpio_loopback_zero[15]; /* Clock2 monitor */

	assign cpu_gpio_ieb[6] = gpio_loopback_one[6];   /* Tx */
	assign cpu_gpio_ieb[13] = gpio_loopback_one[13]; /* Trap monitor */
	assign cpu_gpio_ieb[14] = gpio_loopback_one[14]; /* Clock1 monitor */
	assign cpu_gpio_ieb[15] = gpio_loopback_one[15]; /* Clock2 monitor */

	assign cpu_gpio_ieb[39] = gpio_loopback_one[39]; /* Flash CSB */
	assign cpu_gpio_ieb[40] = gpio_loopback_one[40]; /* Flash clock */
    
    endgenerate

    /* gpio_vector_wb ---
     * Wishbone interface for applying vector data to all GPIO not
     * being used for any other special function.
     */
    wire gpio_vector_stb_i;
    wire gpio_vector_ack_o;
    wire [31:0] gpio_vector_dat_o;
    wire nc1, nc2;

    gpio_vector_wb #(
        .BASE_ADR(GPIO_VECTOR_BASE_ADR)
    ) gpio_vector_io (
	`ifdef USE_POWER_PINS
	    .VPWR(VPWR),
	    .VGND(VGND),
	`endif
	.wb_clk_i(wb_clk_i),
	.wb_rst_i(wb_rst_i),

	.wb_adr_i(cpu_adr_o), 
	.wb_dat_i(cpu_dat_o),
	.wb_sel_i(cpu_sel_o),
	.wb_we_i(cpu_we_o),
	.wb_cyc_i(cpu_cyc_o),

	.wb_stb_i(gpio_vector_stb_i),
	.wb_ack_o(gpio_vector_ack_o), 
	.wb_dat_o(gpio_vector_dat_o),

	/* For an explanation of the mapping of the upper bits of
	 * the vector, see gpio_vector_wb.v.
	 */
	.gpio_vector_in({cpu_gpio_in[40:39], cpu_gpio_in[15:13],
		cpu_gpio_in[11], cpu_gpio_in[8], cpu_gpio_in[9],
		cpu_gpio_in[6], cpu_gpio_in[1],
		cpu_gpio_in[43], cpu_gpio_in[0],
		cpu_gpio_in[35:16]}),
	.gpio_vector_out({nc1, nc2, cpu_gpio_out[38], cpu_gpio_out[12],
		cpu_gpio_out[7], cpu_gpio_out[10], cpu_gpio_out[3],
		cpu_gpio_out[4], cpu_gpio_out[5], cpu_gpio_out[2],
		cpu_gpio_out[43], cpu_gpio_out[0],
		cpu_gpio_out[35:16]}),
	.gpio_vector_oeb({cpu_gpio_oeb[43], cpu_gpio_oeb[0], cpu_gpio_oeb[35:16]}),
	.gpio_vector_ieb({cpu_gpio_ieb[43], cpu_gpio_ieb[0], cpu_gpio_ieb[35:16]})
    );

    /* Routing of output monitors (trap, mon_clk, aux_clk) */

    assign cpu_gpio_out[15] = aux_clk;
    assign cpu_gpio_out[14] = mon_clk;
    assign cpu_gpio_out[13] = trap;

    // Wishbone RAM interface
    wire mem_stb_i;
    wire mem_ack_o;
    wire [31:0] mem_dat_o;

    mem_wb soc_mem (
    `ifdef USE_POWER_PINS
        .VPWR(VPWR),
        .VGND(VGND),
    `endif
        .wb_clk_i(wb_clk_i),
        .wb_rst_i(wb_rst_i),

        .wb_adr_i(cpu_adr_o), 
        .wb_dat_i(cpu_dat_o),
        .wb_sel_i(cpu_sel_o),
        .wb_we_i(cpu_we_o),
        .wb_cyc_i(cpu_cyc_o),

        .wb_stb_i(mem_stb_i),
        .wb_ack_o(mem_ack_o), 
        .wb_dat_o(mem_dat_o)
    );
    
    wire debug_stb_i;
    wire debug_ack_o;
    wire [31:0] debug_dat_o;
    debug_regs debug_regs (
        .wb_clk_i(wb_clk_i),
        .wb_rst_i(wb_rst_i),
        .wbs_stb_i(debug_stb_i),
        .wbs_cyc_i(cpu_cyc_o),
        .wbs_we_i(cpu_we_o),
        .wbs_sel_i(cpu_sel_o),
        .wbs_dat_i(cpu_dat_o),
        .wbs_adr_i(cpu_adr_o),
        .wbs_ack_o(debug_ack_o), 
        .wbs_dat_o(debug_dat_o));
    // Wishbone interconnection logic
    intercon_wb #(
        .AW(ADR_WIDTH),
        .DW(DAT_WIDTH),
        .NI(NUM_IFACE),
        .ADR_MASK(ADR_MASK),
        .IFACE_ADR(IFACE_ADR)
    ) intercon (
        .wbm_adr_i(cpu_adr_o),
        .wbm_stb_i(cpu_stb_o),
        .wbm_dat_o(cpu_dat_i),
        .wbm_ack_o(cpu_ack_i),

        .wbs_stb_o({
        debug_stb_i, 
		spimemio_cfg_stb_i,
		spi_master_stb_i,
		counter_timer1_stb_i,
		counter_timer0_stb_i,
		gpio_stb_i,
		gpio_vector_stb_i,
		uart_stb_i,
		spimemio_flash_stb_i,
		mem_stb_i }), 
        .wbs_dat_i({
        debug_dat_o,
		spimemio_cfg_dat_o,
		spi_master_dat_o,
		counter_timer1_dat_o,
		counter_timer0_dat_o,
		gpio_all_dat_o,
		gpio_vector_dat_o,
		uart_dat_o,
		spimemio_flash_dat_o,
		mem_dat_o }),
        .wbs_ack_i({
        debug_ack_o,
		spimemio_cfg_ack_o,
		spi_master_ack_o,
		counter_timer1_ack_o,
		counter_timer0_ack_o,
		gpio_all_ack_o,
		gpio_vector_ack_o,
		uart_ack_o,
		spimemio_flash_ack_o,
		mem_ack_o })
    );

    /* Clock routing module */

    wire [2:0] spi_dll_sel;
    wire [2:0] spi_dll90_sel;
    wire [4:0] spi_dll_div;
    wire [7:0] spi_prim_div;
    wire [7:0] spi_aux_div;
    wire [25:0] spi_dll_trim;

    clock_routing openframe_clocking (
	`ifdef USE_POWER_PINS
	    .VPWR(VPWR),
	    .VGND(VGND),
	`endif		
	.ext_clk_sel(ext_clk_sel),
	.ext_clk(cpu_gpio_in[38]),
	.dll_clk(dll_clk),
	.dll_clk90(dll_clk90),
	.resetb(resetb), 
	.sel(spi_dll_sel),
	.sel2(spi_dll90_sel),
	.primdiv(spi_prim_div),
	.auxdiv(spi_aux_div),
	.ext_reset(ext_reset),	// From housekeeping SPI
	.core_clk(core_clk),
	.aux_clk(aux_clk),
	.mon_clk(mon_clk),
	.resetb_sync(core_rstn)
    );

    /* Internally generated clock */

    digital_locked_loop dll (
	`ifdef USE_POWER_PINS
	    .VPWR(VPWR),
	    .VGND(VGND),
	`endif
	.resetb(resetb),
	.enable(spi_dll_ena),
	.osc(cpu_gpio_in[38]),
	.clockp({dll_clk, dll_clk90}),
	.div(spi_dll_div),
	.dco(spi_dll_dco_ena),
	.ext_trim(spi_dll_trim)
    );

    // Housekeeping module (SPI interface)

    housekeeping hkspi (
	`ifdef USE_POWER_PINS
	    .VPWR(VPWR),
	    .VGND(VGND),
	`endif
	.RSTB(porb),
	.SCK((hk_connect) ? cpu_gpio_out[9] : cpu_gpio_in[4]),
	.SDI((hk_connect) ? cpu_gpio_out[11] : cpu_gpio_in[2]),
	.CSB((hk_connect) ? cpu_gpio_out[8] : cpu_gpio_in[3]),
	.SDO(cpu_gpio_out[1]),
	.sdo_enb(cpu_gpio_oeb[1]),
	.dll_dco_ena(spi_dll_dco_ena),
	.dll_sel(spi_dll_sel),
	.dll90_sel(spi_dll90_sel),
	.dll_div(spi_dll_div),
	.dll_ena(spi_dll_ena),
        .dll_trim(spi_dll_trim),
	.dll_bypass(ext_clk_sel),
	.mon_div(spi_prim_div),
	.aux_div(spi_aux_div),
	.irq(irq_spi),
	.reset(ext_reset),
	.trap(trap),
	.mask_rev_in(mask_rev),
    	.pass_thru_reset(pass_thru),
    	.pass_thru_sck(pass_thru_sck),
    	.pass_thru_csb(pass_thru_csb),
    	.pass_thru_sdi(pass_thru_sdi),
    	.pass_thru_sdo(pass_thru_sdo)
    );

endmodule

/*----------------------------------------------*/
/* RISC-V Register bank				*/
/* Registers implemented in synthesized logic.	*/
/*----------------------------------------------*/

module picosoc_regs (
    input clk, wen,
    input [5:0] waddr,
    input [5:0] raddr1,
    input [5:0] raddr2,
    input [31:0] wdata,
    output [31:0] rdata1,
    output [31:0] rdata2
);
    reg [31:0] regs [0:31];

    always @(posedge clk)
        if (wen) regs[waddr[4:0]] <= wdata;

    assign rdata1 = regs[raddr1[4:0]];
    assign rdata2 = regs[raddr2[4:0]];
endmodule
`default_nettype wire
