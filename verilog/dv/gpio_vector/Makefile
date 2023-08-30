# SPDX-FileCopyrightText: 2020 Efabless Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0

## PDK 
PDK_ROOT ?= /usr/share/pdk
PDK ?= sky130A
PDK_PATH = $(PDK_ROOT)/$(PDK)

## Caravel Pointers
# CARAVEL_ROOT ?= /home/tim/gits/caravel_redesign_2
CARAVEL_ROOT ?= /home/tim/gits/caravel
CARAVEL_PATH ?= $(CARAVEL_ROOT)
CARAVEL_VERILOG_PATH  = $(CARAVEL_PATH)/verilog
CARAVEL_RTL_PATH = $(CARAVEL_VERILOG_PATH)/rtl
CARAVEL_BEHAVIORAL_MODELS = $(CARAVEL_VERILOG_PATH)/dv/caravel

## Openframe Project Pointers
OPENFRAME_FIRMWARE_PATH = ../firmware
OPENFRAME_VERILOG_PATH ?= ../../../verilog
OPENFRAME_RTL_PATH = $(OPENFRAME_VERILOG_PATH)/rtl
OPENFRAME_GL_PATH = $(OPENFRAME_VERILOG_PATH)/gl

## RISCV GCC 
GCC_PATH ?= /opt/riscv32imc/bin
GCC_PREFIX ?= riscv32-unknown-elf

## Simulation mode: RTL/GL
SIM_DEFINES = -DFUNCTIONAL -DSIM
SIM ?= RTL

.SUFFIXES:

PATTERN = gpio_vector

all:  ${PATTERN:=.vcd}

hex:  ${PATTERN:=.hex}

%.vvp: %_tb.v %.hex
ifeq ($(SIM),RTL)
	iverilog $(SIM_DEFINES) -I $(PDK_PATH) \
	-I $(OPENFRAME_RTL_PATH) \
	-I $(CARAVEL_RTL_PATH) \
	-I $(CARAVEL_BEHAVIORAL_MODELS) \
	$< -o $@ 
else  
	iverilog $(SIM_DEFINES) -DGL -I $(PDK_PATH) \
	-I $(OPENFRAME_GL_PATH) \
	-I $(CARAVEL_RTL_PATH) \
	-I $(CARAVEL_VERILOG_PATH) \
	-I $(CARAVEL_BEHAVIORAL_MODELS) \
	$< -o $@ 
endif

%.vcd: %.vvp
	vvp $<

%.elf: %.c $(OPENFRAME_FIRMWARE_PATH)/sections.lds \
		$(OPENFRAME_FIRMWARE_PATH)/start.s check-env
	${GCC_PATH}/${GCC_PREFIX}-gcc -march=rv32imc -mabi=ilp32 \
		-Wl,-Bstatic,-T,$(OPENFRAME_FIRMWARE_PATH)/sections.lds,--strip-debug \
		-ffreestanding -nostdlib -o $@ $(OPENFRAME_FIRMWARE_PATH)/start.s $<

%.hex: %.elf
	${GCC_PATH}/${GCC_PREFIX}-objcopy -O verilog $< $@ 
	# to fix flash base address
	sed -i 's/@10000000/@00000000/g' $@

%.bin: %.elf
	${GCC_PATH}/${GCC_PREFIX}-objcopy -O binary $< /dev/stdout \
		| tail -c +1048577 > $@

%.lst: %.elf
	${GCC_PATH}/${GCC_PREFIX}-objdump -D $< > $@

check-env:
ifndef PDK_ROOT
	$(error PDK_ROOT is undefined, please export it before running make)
endif
ifeq (,$(wildcard $(PDK_ROOT)/$(PDK)))
	$(error $(PDK_ROOT)/$(PDK) not found, please install pdk before running make)
endif
ifeq (,$(wildcard $(GCC_PATH)/$(GCC_PREFIX)-gcc ))
	$(error $(GCC_PATH)/$(GCC_PREFIX)-gcc is not found, please export GCC_PATH and GCC_PREFIX before running make)
endif

# ---- Clean ----

clean:
	rm -f *.elf *.hex *.bin *.vvp *.vcd *.lst *.log

.PHONY: clean hex all
