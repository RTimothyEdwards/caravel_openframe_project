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
/*
 *---------------------------------------------------------------------
 *
 * This module instantiates a simple extension to the GPIO interface.
 * The GPIO interface defined in gpio_wb.v defines single-bit
 * control of each GPIO independently.  That method does not allow
 * multiple GPIOs to be set or read at the same time.  That function
 * is assigned to GPIOs that are not otherwise being used for special
 * I/O functions.  By writing data to this wishbone address, all GPIOs
 * connected to the vector can be set at once.
 *
 * GPIO assignments for the openframe project example (if also used for
 * a special function in the direction not connected to the GPIO vector
 * data, the special function is indicated in parentheses):
 *
 * GPIO[35] to GPIO[16]  gpio_vector[19:0]	I/O
 *
 * GPIO[0]		 gpio_vector[20]	I/O
 * GPIO[36]		 gpio_vector[21]	I/O
 *
 * GPIO[1] (SDO)	 gpio_vector[22]	input
 * GPIO[2] (SDI)	 gpio_vector[22]	output
 *
 * GPIO[6] (Tx)	 	 gpio_vector[23]	input
 * GPIO[5] (Rx)		 gpio_vector[23]	output
 *
 * GPIO[9] (mSCK)	 gpio_vector[24]	input
 * GPIO[4] (SCK)	 gpio_vector[24]	output
 *
 * GPIO[8] (mCSB)	 gpio_vector[25]	input
 * GPIO[3] (CSB)	 gpio_vector[25]	output
 *
 * GPIO[11] (mSDO)	 gpio_vector[26]	input
 * GPIO[10] (mSDI)	 gpio_vector[26]	output
 *
 * GPIO[13] (Trap mon.)	 gpio_vector[27]	input
 * GPIO[7]  (IRQ1)	 gpio_vector[27]	output
 *
 * GPIO[14] (Clk1 mon.)	 gpio_vector[28]	input
 * GPIO[12] (IRQ2)	 gpio_vector[28]	output
 *
 * GPIO[15] (Clk2 mon.)	 gpio_vector[29]	input
 * GPIO[38] (clock)	 gpio_vector[29]	output
 *
 * GPIO[39] (flash CSB)	 gpio_vector[30]	input
 * GPIO[40] (flash clk)	 gpio_vector[31]	input
 *
 * For special function pins, the IEB and OEB states must be
 * overridden at the pad and cannot be switched instantaneously.
 * Otherwise, the OEB and IEB mappings are as follows:
 *
 * GPIO[35] to GPIO[16]  gpio_oeb_vector[19:0], gpio_ieb_vector[19:0]
 *
 * GPIO[0]		 gpio_oeb_vector[20], gpio_ieb_vector[20]
 * GPIO[36]		 gpio_oeb_vector[21], gpio_ieb_vector[21]
 *
 *---------------------------------------------------------------------
 */

module gpio_vector_wb #(
    parameter BASE_ADR = 32'h2100_0000,
    parameter GPIO_VECTOR_DATA = 8'h00,	// GPIO input/output data
    parameter GPIO_VECTOR_OEB =  8'h04,	// GPIO output disable
    parameter GPIO_VECTOR_IEB =  8'h08	// GPIO input disable
) (
    `ifdef USE_POWER_PINS
         inout VPWR,
         inout VGND,
    `endif

    // Wishbone interface signals
    input wb_clk_i,
    input wb_rst_i,
    input [31:0] wb_adr_i,
    input [31:0] wb_dat_i,
    input [3:0] wb_sel_i,
    input wb_we_i,
    input wb_cyc_i,
    input wb_stb_i,

    output wb_ack_o,
    output [31:0] wb_dat_o,

    output [31:0] gpio_vector_out,	// to GPIO from CPU
    input  [31:0] gpio_vector_in,	// from GPIO to CPU
    output [21:0] gpio_vector_oeb,	// to GPIO from CPU
    output [21:0] gpio_vector_ieb 	// to GPIO from CPU
);

    wire resetn;
    wire valid;
    wire ready;
    wire [3:0] iomem_we;

    assign resetn = ~wb_rst_i;
    assign valid = wb_stb_i && wb_cyc_i;

    assign iomem_we = wb_sel_i & {4{wb_we_i}};
    assign wb_ack_o = ready;

    gpio_vector #(
        .BASE_ADR(BASE_ADR),
        .GPIO_VECTOR_DATA(GPIO_VECTOR_DATA),
        .GPIO_VECTOR_OEB(GPIO_VECTOR_OEB),
        .GPIO_VECTOR_IEB(GPIO_VECTOR_IEB)
    ) gpio_vector_ctrl (
        .clk(wb_clk_i),
        .resetn(resetn),

        .iomem_addr(wb_adr_i),
        .iomem_valid(valid),
        .iomem_wstrb(iomem_we[0]),
        .iomem_wdata(wb_dat_i),
        .iomem_rdata(wb_dat_o),
        .iomem_ready(ready),

	.gpio_vector_out(gpio_vector_out),
	.gpio_vector_in(gpio_vector_in),
	.gpio_vector_ieb(gpio_vector_ieb),
	.gpio_vector_oeb(gpio_vector_oeb)
    );

endmodule

module gpio_vector #(
    parameter BASE_ADR  = 32'h 2100_0000,
    parameter GPIO_VECTOR_DATA = 8'h00,
    parameter GPIO_VECTOR_OEB = 8'h04,
    parameter GPIO_VECTOR_IEB = 8'h08
) (
    input clk,
    input resetn,

    input [31:0] iomem_addr,
    input iomem_valid,
    input iomem_wstrb,
    input [31:0] iomem_wdata,
    output reg [31:0] iomem_rdata,
    output reg iomem_ready,

    output reg [31:0] gpio_vector_out,
    input      [31:0] gpio_vector_in,
    output reg [21:0] gpio_vector_oeb,
    output reg [21:0] gpio_vector_ieb
);
    wire gpio_data_sel;
    wire gpio_oeb_sel;
    wire gpio_ieb_sel;

    assign gpio_data_sel = (iomem_addr[7:0] == GPIO_VECTOR_DATA);
    assign gpio_oeb_sel = (iomem_addr[7:0] == GPIO_VECTOR_OEB);
    assign gpio_ieb_sel = (iomem_addr[7:0] == GPIO_VECTOR_IEB);

    always @(posedge clk or negedge resetn) begin
	if (!resetn) begin
	    gpio_vector_out <= 32'h00000000;

	end else begin
	    iomem_ready <= 0;
	    if (iomem_valid && !iomem_ready && iomem_addr[31:8] == BASE_ADR[31:8]) begin
		iomem_ready <= 1'b 1;

		if (gpio_data_sel) begin
		    iomem_rdata <= gpio_vector_in;
		    if (iomem_wstrb) begin
			gpio_vector_out = iomem_wdata;
		    end
		end else if (gpio_oeb_sel) begin
		    iomem_rdata <= {10'd0, gpio_vector_oeb};
		    if (iomem_wstrb) begin
			gpio_vector_oeb = iomem_wdata[21:0];
		    end
		end else if (gpio_ieb_sel) begin
		    iomem_rdata <= {10'd0, gpio_vector_ieb};
		    if (iomem_wstrb) begin
			gpio_vector_ieb = iomem_wdata[21:0];
		    end
		end
	    end
	end
    end

endmodule
`default_nettype wire
