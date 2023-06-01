#include <openframe.h>

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

unsigned char xorshift8(unsigned int *state){
    unsigned int x = *state;
    x ^= x << 3;
    x ^= x >> 5;
    // x = (x & 0xFF);
    *state = x;
    return (unsigned char)x;
}

void main(){
    // configure them as output pins
    GPIO_Configure(8, GPIO_MODE_VECTOR_OUTPUT);
    GPIO_Configure(9, GPIO_MODE_VECTOR_OUTPUT);
    GPIO_Configure(10, GPIO_MODE_VECTOR_INPUT_PULLDOWN);
    GPIO_Configure(11, GPIO_MODE_VECTOR_OUTPUT);

    spi_stream(1);
    spi_enable(1);
    unsigned int seed = SEED; 
    unsigned int state = seed;
    // write F at address 
    char address = xorshift8(&state);
    char data = xorshift8(&state);
    spi_write(0x02);
    spi_write(address);
    spi_write(data);
    // read back
    spi_stream(0);
    spi_enable(0);
    spi_stream(1);
    spi_enable(1);
    spi_write(0x01);
    spi_write(address);
    int val = spi_read();
    set_debug_reg1(val);
    if (val != data){
        set_debug_reg2(0XE0);
        
    }else{
        set_debug_reg2(0XA0);
    }

    // change all configs 
    spi_stream(0);
    spi_enable(0);
    spi_mlb(1);
    spi_invCSB(1);
    spi_mode(1);
    spi_stream(1);
    spi_enable(1);
    address = xorshift8(&state);
    data = xorshift8(&state);
    spi_write(0x02);
    spi_write(address);
    spi_write(data);
    // read back
    spi_stream(0);
    spi_enable(0);
    spi_stream(1);
    spi_enable(1);
    spi_write(0x01);
    spi_write(address);
    val = spi_read();
    set_debug_reg1(val);
    if (val != data){
        set_debug_reg2(0XE1);
        
    }else{
        set_debug_reg2(0XA1);
    }
}
