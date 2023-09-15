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

#ifndef _DEFS_H_
#define _DEFS_H_

#include <stdint.h>
#include <stdbool.h>

// A pointer to this is a null pointer, but the compiler does not
// know that because "sram" is a linker symbol from sections.lds.
extern uint32_t sram;

// Pointer to firmware flash routines
extern uint32_t flashio_worker_begin;
extern uint32_t flashio_worker_end;

// Storage area (Read/write: 0x01000000, Read-only: 0x02000000)
#define reg_rw_block0  (*(volatile uint32_t*)0x01000000)
#define reg_ro_block0  (*(volatile uint32_t*)0x02000000)

// UART (0x2000_0000)
#define reg_uart_clkdiv (*(volatile uint32_t*)0x20000000)
#define reg_uart_data   (*(volatile uint32_t*)0x20000004)
#define reg_uart_enable (*(volatile uint32_t*)0x20000008)

// GPIO (0x2100_0000)
#define reg_gpio_0_config (*(volatile uint32_t*)0x21000000)
#define reg_gpio_1_config (*(volatile uint32_t*)0x21000004)
#define reg_gpio_2_config (*(volatile uint32_t*)0x21000008)
#define reg_gpio_3_config (*(volatile uint32_t*)0x2100000c)
#define reg_gpio_4_config (*(volatile uint32_t*)0x21000010)
#define reg_gpio_5_config (*(volatile uint32_t*)0x21000014)
#define reg_gpio_6_config (*(volatile uint32_t*)0x21000018)
#define reg_gpio_7_config (*(volatile uint32_t*)0x2100001c)
#define reg_gpio_8_config (*(volatile uint32_t*)0x21000020)
#define reg_gpio_9_config (*(volatile uint32_t*)0x21000024)
#define reg_gpio_10_config (*(volatile uint32_t*)0x21000028)
#define reg_gpio_11_config (*(volatile uint32_t*)0x2100002c)
#define reg_gpio_12_config (*(volatile uint32_t*)0x21000030)
#define reg_gpio_13_config (*(volatile uint32_t*)0x21000034)
#define reg_gpio_14_config (*(volatile uint32_t*)0x21000038)
#define reg_gpio_15_config (*(volatile uint32_t*)0x2100003c)
#define reg_gpio_16_config (*(volatile uint32_t*)0x21000040)
#define reg_gpio_17_config (*(volatile uint32_t*)0x21000044)
#define reg_gpio_18_config (*(volatile uint32_t*)0x21000048)
#define reg_gpio_19_config (*(volatile uint32_t*)0x2100004c)
#define reg_gpio_20_config (*(volatile uint32_t*)0x21000050)
#define reg_gpio_21_config (*(volatile uint32_t*)0x21000054)
#define reg_gpio_22_config (*(volatile uint32_t*)0x21000058)
#define reg_gpio_23_config (*(volatile uint32_t*)0x2100005c)
#define reg_gpio_24_config (*(volatile uint32_t*)0x21000060)
#define reg_gpio_25_config (*(volatile uint32_t*)0x21000064)
#define reg_gpio_26_config (*(volatile uint32_t*)0x21000068)
#define reg_gpio_27_config (*(volatile uint32_t*)0x2100006c)
#define reg_gpio_28_config (*(volatile uint32_t*)0x21000070)
#define reg_gpio_29_config (*(volatile uint32_t*)0x21000074)
#define reg_gpio_30_config (*(volatile uint32_t*)0x21000078)
#define reg_gpio_31_config (*(volatile uint32_t*)0x2100007c)
#define reg_gpio_32_config (*(volatile uint32_t*)0x21000080)
#define reg_gpio_33_config (*(volatile uint32_t*)0x21000084)
#define reg_gpio_34_config (*(volatile uint32_t*)0x21000088)
#define reg_gpio_35_config (*(volatile uint32_t*)0x2100008c)
#define reg_gpio_36_config (*(volatile uint32_t*)0x21000090)
#define reg_gpio_37_config (*(volatile uint32_t*)0x21000094)
#define reg_gpio_38_config (*(volatile uint32_t*)0x21000098)
#define reg_gpio_39_config (*(volatile uint32_t*)0x2100009c)
#define reg_gpio_40_config (*(volatile uint32_t*)0x210000a0)
#define reg_gpio_41_config (*(volatile uint32_t*)0x210000a4)
#define reg_gpio_42_config (*(volatile uint32_t*)0x210000a8)
#define reg_gpio_43_config (*(volatile uint32_t*)0x210000ac)

// GPIO vector (0x2500_0000)
#define reg_gpio_vector_data (*(volatile uint32_t*)0x25000000)
#define reg_gpio_vector_oeb  (*(volatile uint32_t*)0x25000004)
#define reg_gpio_vector_ieb  (*(volatile uint32_t*)0x25000008)

// Flash Control SPI Configuration (2D00_0000)
#define reg_spictrl (*(volatile uint32_t*)0x2d000000)         

// Bit fields for Flash SPI control
#define FLASH_BITBANG_IO0	0x00000001
#define FLASH_BITBANG_IO1	0x00000002
#define FLASH_BITBANG_CLK	0x00000010
#define FLASH_BITBANG_CSB	0x00000020
#define FLASH_BITBANG_OEB0	0x00000100
#define FLASH_BITBANG_OEB1	0x00000200
#define FLASH_ENABLE		0x80000000

// Counter-Timer 0 Configuration
#define reg_timer0_config (*(volatile uint32_t*)0x22000000)
#define reg_timer0_value  (*(volatile uint32_t*)0x22000004)
#define reg_timer0_data   (*(volatile uint32_t*)0x22000008)

// Counter-Timer 1 Configuration
#define reg_timer1_config (*(volatile uint32_t*)0x23000000)
#define reg_timer1_value  (*(volatile uint32_t*)0x23000004)
#define reg_timer1_data   (*(volatile uint32_t*)0x23000008)

// Bit fields for Counter-timer configuration
#define TIMER_ENABLE		0x01
#define TIMER_ONESHOT		0x02
#define TIMER_UPCOUNT		0x04
#define TIMER_CHAIN		0x08
#define TIMER_IRQ_ENABLE	0x10

// SPI Master Configuration
#define reg_spimaster_config (*(volatile uint32_t*)0x24000000)
#define reg_spimaster_data   (*(volatile uint32_t*)0x24000004)

// Bit fields for SPI master configuration
#define SPI_MASTER_DIV_MASK	0x00ff
#define SPI_MASTER_MLB		0x0100
#define SPI_MASTER_INV_CSB	0x0200
#define SPI_MASTER_INV_CLK	0x0400
#define SPI_MASTER_MODE_1	0x0800
#define SPI_MASTER_STREAM	0x1000
#define SPI_MASTER_ENABLE	0x2000
#define SPI_MASTER_IRQ_ENABLE	0x4000
#define SPI_HOUSEKEEPING_CONN	0x8000

// Debug registers (general-purpose read/write space)
#define reg_debug_first (*(volatile uint32_t*)0x41000000)
#define reg_debug_second (*(volatile uint32_t*)0x41000004)

// Individual bit fields for the GPIO pad control
#define OUTPUT_VALUE	  0x800
#define OEB_VALUE	  0x400
#define IEB_VALUE	  0x200
#define OUTPUT_OVERRIDE	  0x100
#define OEB_OVERRIDE	  0x080
#define IEB_OVERRIDE	  0x040
#define SLOW_SLEW_MODE	  0x020
#define TRIPPOINT_SEL	  0x010
#define IB_MODE_SELECT	  0x008
#define DIGITAL_MODE_MASK 0x007

#define DIGITAL_MODE_OUTPUT   0x006
#define DIGITAL_MODE_INPUT    0x001
#define DIGITAL_MODE_PULLUP   0x002
#define DIGITAL_MODE_PULLDOWN 0x003

// Useful GPIO mode values
#define GPIO_MODE_VECTOR_OUTPUT		0x2c6
#define GPIO_MODE_VECTOR_INPUT		0x4c1
#define GPIO_MODE_VECTOR_INPUT_PULLUP	0x9c2
#define GPIO_MODE_VECTOR_INPUT_PULLDOWN	0x1c3
#define GPIO_MODE_BIDIRECTIONAL		0x006
#define GPIO_MODE_ZERO_OUT		0x386
#define GPIO_MODE_ONE_OUT		0xb86

#define CPU_TYPE RV32imc

// --------------------------------------------------------
#endif	/* _DEFS_H_ */
