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

void main(){
    uart_enable(1);
    print("Hello \n"); // send Hello with the default clk divider
    // getting the new clock divider value from uart
    int val = get_uart_clkdiv();
    set_debug_reg2(val);
    uart_clkdiv(val);
    set_debug_reg1(0xAA);
    set_debug_reg1(0x0);
    print("World \n"); // send Hello with the new clk divider
    val = get_uart_clkdiv();
    set_debug_reg2(val);
    uart_clkdiv(val);
    set_debug_reg1(0xAA);
}

int get_uart_clkdiv(){
    int val=0;
    char str; 
    int count = 0;
    while (1){
        set_debug_reg2(0xAA);
        str = uart_getc();
        if (str == '\n'){
            return val;
        }
        val = val * 10 + str - '0';
        set_debug_reg2(0xBB);
    }
}