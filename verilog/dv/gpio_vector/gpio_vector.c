/*
 * SPDX-FileCopyrightText: 2020 Efabless Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * SPDX-License-Identifier: Apache-2.0
 */

#include "../firmware/defs.h"

// ---------------------------------------------------------------------
// Testbench gpio_vector.c
//
// Tests the operation of gpio_vector, which drives signals to the GPIOs
// that are not otherwise connected to special functions like an SPI,
// UART, etc.;  gpio[16] to gpio[35] are good candidate channels.
//
// The GPIOs can be controlled manually and individually by configuring
// them to override the special function I/O and force the GPIO to
// operate as an input or an output.  However, these individual controls
// are memory-mapped to separate addresses, which makes it impossible to
// set the value of multiple outputs simultaneously.  But all GPIOs that
// are not otherwise connected to special function outputs can be set up
// to output the value passed to the gpio vector memory map location.
//
// This testbench checks the vector output function by configuring GPIOs
// 16 to 23 to be vector outputs, then writing an incrementing value
// that is detected by the testbench.
//
// To do:  Need to test some of the channels that are connected to
// special functions that use only the input from the GPIO, where
// the GPIO can still be configured for vector output.
//
// Also to do:  Need to test vector input and vector bidirectional
// functions.
//
// ---------------------------------------------------------------------

void main()
{
    int i;

    reg_spimaster_config = 0xa002;	// Enable, prescaler = 2
    reg_gpio_vector_data = 0x00000000;

    /* Set up GPIO 16 to 23 to display vector output */
    reg_gpio_16_config = GPIO_MODE_VECTOR_OUTPUT;
    reg_gpio_17_config = GPIO_MODE_VECTOR_OUTPUT;
    reg_gpio_18_config = GPIO_MODE_VECTOR_OUTPUT;
    reg_gpio_19_config = GPIO_MODE_VECTOR_OUTPUT;
    reg_gpio_20_config = GPIO_MODE_VECTOR_OUTPUT;
    reg_gpio_21_config = GPIO_MODE_VECTOR_OUTPUT;
    reg_gpio_22_config = GPIO_MODE_VECTOR_OUTPUT;
    reg_gpio_23_config = GPIO_MODE_VECTOR_OUTPUT;

    /* Continue changing vector data output until done */
    i = 0;
    while (1) {
	reg_gpio_vector_data = i;
	i++;
    }
}

