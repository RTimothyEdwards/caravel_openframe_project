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

`default_nettype wire

`timescale 1 ns / 1 ps

`include "openframe_project_netlists.v"
`include "openframe_netlists.v"
`include "spiflash.v"
`include "tbuart.v"

module gpio_vector_tb;
    // Signals declaration
    reg clock;
    reg RSTB;
    reg CSB;
    reg power1, power2;

    wire HIGH;
    wire LOW;
    wire TRI;
    assign HIGH = 1'b1;
    assign LOW = 1'b0;
    assign TRI = 1'bz;

    wire [43:0] gpio;
    wire [7:0] checkbits;

    // Signals Assignment
    assign gpio[3] = (CSB == 1'b1) ? 1'b1 : 1'bz;
    assign gpio[38] = clock;

    // Readback from GPIO vector
    assign checkbits = gpio[23:16];

    always #12.5 clock <= (clock === 1'b0);

    initial begin
        clock = 0;
    end

    initial begin
        $dumpfile("gpio_vector.vcd");
        $dumpvars(0, gpio_vector_tb);

        // Repeat cycles of 1000 clock edges as needed to complete testbench
        repeat (24) begin
            repeat (1000) @(posedge clock);
        end
        $display("%c[1;31m",27);
        $display ("Monitor: Timeout, Test Project IO Stimulus (RTL) Failed");
        $display("%c[0m",27);
        $finish;
    end

    initial begin
        wait(checkbits == 8'h0);
        $display("Monitor: gpio_vector test started");
	// These GPIO values are counting up in sequence.  Wait on a few
	// arbitrary values to check that the sequence is progressing and
	// being seen on the output.
        wait(checkbits == 8'd1);
        $display("Monitor: gpio_vector test looking good. . .");
        wait(checkbits == 8'd2);
        wait(checkbits == 8'd3);
        wait(checkbits == 8'd4);
        wait(checkbits == 8'd5);
        wait(checkbits == 8'd6);
        wait(checkbits == 8'd7);
        wait(checkbits == 8'd8);
        $display("Monitor: gpio_vector test still going. . .");
        wait(checkbits == 8'd9);
        wait(checkbits == 8'd10);
        wait(checkbits == 8'd11);
        wait(checkbits == 8'd12);
        wait(checkbits == 8'd13);
        wait(checkbits == 8'd14);
        wait(checkbits == 8'd15);
        wait(checkbits == 8'd16);
	// ...  No real need to check every single one of these.
        wait(checkbits == 8'd29);
        $display("Monitor: gpio_vector test almost done. . .");
        wait(checkbits == 8'd30);
        wait(checkbits == 8'd31);
        wait(checkbits == 8'd32);
        wait(checkbits == 8'd33);
        $display("Monitor: gpio_vector test Passed");
        #10000;
        $finish;
    end

    // Reset Operation
    initial begin
        RSTB <= 1'b0;
        CSB  <= 1'b1;       // Force CSB high
        #2000;
        RSTB <= 1'b1;       // Release reset
    end

    initial begin		// Power-up sequence
        power1 <= 1'b0;
        power2 <= 1'b0;
        #200;
        power1 <= 1'b1;
        #200;
        power2 <= 1'b1;
    end

    wire flash_csb;
    wire flash_clk;
    wire flash_io0;
    wire flash_io1;

    wire VDD3V3 = power1;
    wire VDD1V8 = power2;
    wire VSS = 1'b0;

    caravel_openframe uut (
        .vddio	  (VDD3V3),
        .vssio	  (VSS),
        .vdda	  (VDD3V3),
        .vssa	  (VSS),
        .vccd	  (VDD1V8),
        .vssd	  (VSS),
        .vdda1    (VDD3V3),
        .vdda2    (VDD3V3),
        .vssa1	  (VSS),
        .vssa2	  (VSS),
        .vccd1	  (VDD1V8),
        .vccd2	  (VDD1V8),
        .vssd1	  (VSS),
        .vssd2	  (VSS),
        .gpio     (gpio),
        .resetb	  (RSTB)
    );

    /*
     *-----------------------------------------------
     * GPIO signal assignments
     *
     * gpio[1]  = Housekeeping SDO
     * gpio[2]  = Housekeeping SDI
     * gpio[3]  = Housekeeping CSB
     * gpio[4]  = Housekeeping SCK
     * gpio[5]  = UART Rx
     * gpio[6]  = UART Tx
     * gpio[38] = system external clock
     * gpio[39] = SPI flash CSB
     * gpio[40] = SPI flash clock
     * gpio[41] = SPI flash IO0
     * gpio[42] = SPI flash IO1
     * gpio[36] = SPI flash IO2
     * gpio[37] = SPI flash IO3
     *-----------------------------------------------
     */

    spiflash #(
        .FILENAME("gpio_vector.hex")
    ) spiflash (
        .csb(gpio[39]),
        .clk(gpio[40]),
        .io0(gpio[41]),
        .io1(gpio[42]),
        .io2(gpio[36]),
        .io3(gpio[37])
    );

    // Testbench UART
    tbuart tbuart (
        .ser_rx(gpio[6])
    );

endmodule
`default_nettype wire
