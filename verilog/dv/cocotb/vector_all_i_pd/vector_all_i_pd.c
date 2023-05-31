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
    for (int i = 0; i < 36; i++){
        GPIO_Configure(i, GPIO_MODE_VECTOR_INPUT_PULLDOWN);
    }
    GPIO_Configure(43, GPIO_MODE_VECTOR_INPUT_PULLDOWN);
    
    // low
    wait_over_input_l(0xAA,0x3FFFFFFF);
    wait_over_input_l(0XBB,0x0);
    wait_over_input_l(0XCC,0x15555555);
    wait_over_input_l(0XDD,0x2AAAAAAA);
    set_debug_reg1(0xFF); // finish tests

}

void wait_over_input_l(unsigned int start_code, unsigned int exp_val){
    set_debug_reg1(start_code); // configuration done wait environment to send exp_val to reg_mprj_datal
    GPIO_WaitData(exp_val);
    set_debug_reg2(GPIO_Get());

}

