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

`ifndef MEM_WORDS
`define MEM_WORDS 1024
`endif

`default_nettype none
module mem_wb (
`ifdef USE_POWER_PINS
    input VPWR,
    input VGND,
`endif
    input wb_clk_i,
    input wb_rst_i,

    input [31:0] wb_adr_i,
    input [31:0] wb_dat_i,
    input [3:0] wb_sel_i,
    input wb_we_i,
    input wb_cyc_i,
    input wb_stb_i,

    output wb_ack_o,
    output [31:0] wb_dat_o
    
);

    localparam ADR_WIDTH = $clog2(`MEM_WORDS);

    wire valid;
    wire ram_wen;
    wire [3:0] wen; // write enable

    assign valid = wb_cyc_i & wb_stb_i;
    assign ram_wen = wb_we_i && valid;

    assign wen = wb_sel_i & {4{ram_wen}} ;

    /*
     * Ack Generation
     *     - write transaction: asserted upon receiving adr_i & dat_i 
     *     - read transaction : asserted one clock cycle after receiving the
     *     adr_i & dat_i
     */ 

    reg wb_ack_read;
    reg wb_ack_o;

    always @(posedge wb_clk_i) begin
        if (wb_rst_i == 1'b1) begin
            wb_ack_read <= 1'b0;
            wb_ack_o <= 1'b0;
        end else begin
            // wb_ack_read <= {2{valid}} & {1'b1, wb_ack_read[1]};
            wb_ack_o    <= wb_we_i? (valid & !wb_ack_o): wb_ack_read;
            wb_ack_read <= (valid & !wb_ack_o) & !wb_ack_read;
        end
    end

    soc_mem mem (
    `ifdef USE_POWER_PINS
        .VPWR(VPWR),
        .VGND(VGND),
    `endif
        .clk(wb_clk_i),
        .ena(valid),
        .wen(wen),
        .addr(wb_adr_i[ADR_WIDTH+1:2]),
        .wdata(wb_dat_i),
        .rdata(wb_dat_o)
    );

endmodule

module soc_mem ( 
`ifdef USE_POWER_PINS
    input VPWR,
    input VGND,
`endif
    input clk,
    input ena,
    input [3:0] wen,
    input [9:0] addr,
    input [31:0] wdata,
    output[31:0] rdata
);

    wire [31:0] rdata0;
    wire [31:0] rdata1;

    /* Size: 2KB, 512x32 bits */

    sky130_sram_2kbyte_1rw1r_32x512_8 #(
	.VERBOSE(0)
    ) SRAM_0 (
	`ifdef USE_POWER_PINS
	    .vccd1(VPWR),
	    .vssd1(VGND),
	`endif
            .clk0(clk), 
            .csb0(~ena), 
            .web0(~|wen),
            .wmask0(wen),
            .addr0(addr[8:0]),
            .din0(wdata),
            .dout0(rdata0),

	    .clk1(1'b0),
	    .csb1(1'b1),
	    .addr1(9'b0),
	    .dout1()
      );

    /* Size: 2KB, 512x32 bits */

    sky130_sram_2kbyte_1rw1r_32x512_8 #(
	.VERBOSE(0)
    ) SRAM_1 (
	`ifdef USE_POWER_PINS
	    .vccd1(VPWR),
	    .vssd1(VGND),
	`endif
            .clk0(clk), 
            .csb0(~ena), 
            .web0(~|wen),
            .wmask0(wen),
            .addr0(addr[8:0]),
            .din0(wdata),
            .dout0(rdata1),

	    .clk1(1'b0),
	    .csb1(1'b1),
	    .addr1(9'b0),
	    .dout1()
      );

      // Select bank based on address high bit.
      assign rdata = (addr[9] == 1'b1) ? rdata1 : rdata0;
endmodule
`default_nettype wire
