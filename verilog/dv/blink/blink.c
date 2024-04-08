#include "../firmware/defs.h"

// --------------------------------------------------------
// Run basic blink test on the openframe picorv32 project.
// --------------------------------------------------------

void main()
{
	int i, j;

	i = 1;

    // Enable GPIO43 (LED) (all output, ena = 0)
    reg_gpio_43_config = GPIO_MODE_VECTOR_OUTPUT;

    // GPIO vector controls an assortment of I/Os, not in order:
    // in:  40, 39, 15, 35, 11, 8, 9, 6, 1, 43, 0, 35, ... 16 
    // out:  -,  -, 12,  7, 10, 3, 4, 5, 2, 43, 0, 35, ... 16 
    // So GPIO43 (LED) is controlled by setting bit 21 in the vector
    reg_gpio_vector_oeb = 0xffdfffff;
    reg_gpio_vector_ieb = 0x00200000;
    reg_gpio_vector_data = 0x0;

    while(1) {
        reg_gpio_vector_data = 0x00000000;
        for (j = 0; j < 3000; j++);

        reg_gpio_vector_data = 0x00200000;
        for (j = 0; j < 3000; j++);
    }
}

