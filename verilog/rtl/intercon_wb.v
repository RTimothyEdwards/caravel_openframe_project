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

module intercon_wb #(
    parameter DW = 32,     // Data width
    parameter AW = 32,     // Address width
    parameter NI = 6,      // Number of interfaces
    parameter [NI*AW-1:0] ADR_MASK = {      // Page & Sub-page bits
        {8'hFF, {24{1'b0}} },
        {8'hFF, {24{1'b0}} },
        {8'hFF, {24{1'b0}} },
        {8'hFF, {24{1'b0}} },
        {8'hFF, {24{1'b0}} },
        {8'hFF, {24{1'b0}} }
        
    },
    parameter [NI*AW-1:0] IFACE_ADR = {
        { 32'h2800_0000 },    // Flash Configuration Register
        { 32'h2200_0000 },    // System Control
        { 32'h2100_0000 },    // GPIOs
        { 32'h2000_0000 },    // UART 
        { 32'h1000_0000 },    // Flash 
        { 32'h0000_0000 }     // RAM
        
    }
) (
    // Master
    input [AW-1:0] wbm_adr_i,
    input wbm_stb_i,

    output reg [DW-1:0] wbm_dat_o,
    output wbm_ack_o,

    // Interfaces
    input [NI*DW-1:0] wbs_dat_i,
    input [NI-1:0] wbs_ack_i,
    output [NI-1:0] wbs_stb_o
);
    
    wire [NI-1: 0] iface_sel;

    // Address decoder
    genvar iS;
    generate
        for (iS = 0; iS < NI; iS = iS + 1) begin
            assign iface_sel[iS] = 
                ((wbm_adr_i & ADR_MASK[(iS+1)*AW-1:iS*AW]) == IFACE_ADR[(iS+1)*AW-1:iS*AW]);
        end
    endgenerate

    // Data output assignment
    assign wbm_ack_o = |(wbs_ack_i & iface_sel);
    assign wbs_stb_o =  {NI{wbm_stb_i}} & iface_sel;

    integer i;
    always @(*) begin
        wbm_dat_o = {DW{1'b0}};
        for (i=0; i<(NI*DW); i=i+1)
            wbm_dat_o[i%DW] = wbm_dat_o[i%DW] | (iface_sel[i/DW] & wbs_dat_i[i]);
    end
 
endmodule

`default_nettype wire
