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

void main()
{

    // reg_spimaster_config = 0xa002;	// Enable, prescaler = 2
    // GPIO_Set(0);

    // /* Set up GPIO 0 to 25 to display vector output */
    GPIO_Set(0);
    for (int i = 0; i < 36; i++){
        GPIO_Configure(i, GPIO_MODE_VECTOR_OUTPUT);
    }
    GPIO_Configure(43, GPIO_MODE_VECTOR_OUTPUT);
    set_debug_reg2(0xFF);
    set_debug_reg1(0xAA);

    // /* Continue changing vector data output until done */
    for (int i = 0; i < 32; i++){
       GPIO_Set(0x1 << i); 
       set_debug_reg2(i);
    }

}
