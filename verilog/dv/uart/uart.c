#include "../firmware/defs.h"

// --------------------------------------------------------
// Support routines
// --------------------------------------------------------

void uart_putc(char c){
    reg_uart_data = c;
}

void print(const char *p){
    while (*p)
        uart_putc(*(p++));
}

// --------------------------------------------------------
// Caravel openframe project --- PicoRV32
//
// Run a basic blink test with UART output.
// --------------------------------------------------------

void main()
{
	int i, j;

	i = 1;

    // Enable GPIO43 (LED) (all output, ena = 0)
    reg_gpio_43_config = GPIO_MODE_VECTOR_OUTPUT;

    // GPIO5 enabled for UART Rx and GPIO6 enabled for UART Tx by default

    // GPIO vector controls an assortment of I/Os, not in order:
    // in:  40, 39, 15, 35, 11, 8, 9, 6, 1, 43, 0, 35, ... 16 
    // out:  -,  -, 12,  7, 10, 3, 4, 5, 2, 43, 0, 35, ... 16 
    // So GPIO43 (LED) is controlled by setting bit 21 in the vector
    reg_gpio_vector_oeb = 0xffdfffff;
    reg_gpio_vector_ieb = 0x00200000;
    reg_gpio_vector_data = 0x0;

    // For clock = 10MHz, UART clkdiv = 1042 for 9600 baud
    reg_uart_clkdiv = 1042;

    // Enable the UART
    reg_uart_enable = 1;

    print("Hello world!\n");

    while(1) {
        reg_gpio_vector_data = 0x00000000;
        for (j = 0; j < 3000; j++);

        reg_gpio_vector_data = 0x00200000;
        for (j = 0; j < 3000; j++);
    }
}

