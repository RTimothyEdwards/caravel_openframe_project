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
unsigned int xorshift32(unsigned int *state)
{
    unsigned int x = *state;
    x ^= x << 13;
    x ^= x << 17;
    x ^= x >> 5;
    x = x | 0x3C0; // fix bits 6 7 8 for override val fixing and 9 foe disable out enable to 1
    *state = x;
    return x;
}

int main()
{
    unsigned int seed = 17854269; // Initial seed value
    unsigned int state = seed;

    int i;
    for (i = 0; i < 38; i++)
    {
        // Generate a random value between 0 and 16383 (12 bits)
        unsigned int random_value = xorshift32(&state) & 0xFFF; // remove dependency over pad_gpio_in, pad_gpio_out, pad_gpio_oeb, and pad_gpio_ieb
        GPIO_Configure(i, random_value);
    }
    set_debug_reg1(0xAA); // finishing config
    // read from each gpio register
    state = seed;
    for (i = 0; i < 38; i++)
    {
        // Generate a random value between 0 and 16383 (12 bits) 
        unsigned int random_value = xorshift32(&state) & 0xFFF;
        unsigned int config = GPIO_getConfig(i) & 0xFFF; // remove dependency over pad_gpio_in, pad_gpio_out, pad_gpio_oeb, and pad_gpio_ieb
        if (config != random_value)
        {
            set_debug_reg2(i);
            set_debug_reg1(0xEE);
            unsigned int expected_actual = config | random_value << 16;
            set_debug_reg1(expected_actual);
            return 0;
        }
    }
    set_debug_reg1(0xFF);
}
