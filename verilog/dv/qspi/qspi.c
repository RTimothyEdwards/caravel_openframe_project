#include "../firmware/defs.h"

// --------------------------------------------------------
// qspi.c:  Test dual and quad SPI modes, and running code
// from SRAM.  Requires passing the SRAM test first!
// --------------------------------------------------------

// --------------------------------------------------------
// Support routines
// --------------------------------------------------------

//--------------------------------------------------------------
// Basic printing to UART
//--------------------------------------------------------------

void putchar(char c){
    reg_uart_data = c;
}

//--------------------------------------------------------------

void print(const char *p){
    while (*p)
        putchar(*(p++));
}

//--------------------------------------------------------------

void print_hex(uint32_t v, int digits)
{
    for (int i = digits - 1; i >= 0; i--) {
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
        putchar(c);
    }
}

//--------------------------------------------------------------
// Copy the flash worker function to SRAM so that the SPI can be
// managed without having to read program instructions from it.
//--------------------------------------------------------------

void flashio(uint32_t *data, int len, uint8_t wrencmd)
{
    uint32_t func[&flashio_worker_end - &flashio_worker_begin];

    uint32_t *src_ptr = &flashio_worker_begin;
    uint32_t *dst_ptr = func;

    while (src_ptr != &flashio_worker_end)
        *(dst_ptr++) = *(src_ptr++);

    ((void(*)(uint32_t*, uint32_t, uint32_t))func)(data, len, wrencmd);
}

//--------------------------------------------------------------
// NOTE: Volatile write *only* works with command 01, making the
// above routine non-functional.  Must write all four registers
// status, config1, config2, and config3 at once.
//--------------------------------------------------------------
// (NOTE: Forces quad/ddr modes off, since function runs in single data pin mode)
// (NOTE: Also sets quad mode flag, so run this before entering quad mode)
//--------------------------------------------------------------

void set_flash_latency(uint8_t value)
{
    reg_spictrl = (reg_spictrl & ~0x007f0000) | ((value & 15) << 16);

    uint32_t buffer_wr[2] = {0x01000260, ((0x70 | value) << 24)};
    flashio(buffer_wr, 5, 0x50);
}

// ----------------------------------------------------------------------

void cmd_read_flash_regs_print(uint32_t addr, const char *name)
{
    uint32_t buffer[2] = {0x65000000 | addr, 0x0};
    flashio(buffer, 6, 0);

    print("0x");
    print_hex(addr, 6);
    print(" ");
    print(name);
    print(" 0x");
    print_hex(buffer[1], 2);
    print("  ");
}

// ----------------------------------------------------------------------

void cmd_read_flash_regs()
{
    cmd_read_flash_regs_print(0x800000, "SR1V");
    cmd_read_flash_regs_print(0x800002, "CR1V");
    cmd_read_flash_regs_print(0x800003, "CR2V");
    cmd_read_flash_regs_print(0x800004, "CR3V");
}

// --------------------------------------------------------
// Caravel openframe project --- PicoRV32
//
// Run a basic blink test
// Switch through SPI flash options---dual and quad
//
// NOTE:  QSPI operation requires jumpering the following:
// IO[37] <--> !HOLD (D3)
// IO[36] <--> !WP (D2)
// --------------------------------------------------------

void main()
{
    int i, j, k, m;

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

    // Starts off in single mode, latency 8.
    set_flash_latency(8);
    // reg_spictrl = 0x80080000;

    // Start off in DSPI mode
    reg_spictrl = 0x80480000;

    // Set m for speed multiplier 1x:
    m = 0;

    print("Hello world!\n");
    cmd_read_flash_regs();

    k = 0;

    while(1) {
        reg_gpio_vector_data = 0x00000000;
        for (j = 0; j < 3000; j++);

        reg_gpio_vector_data = 0x00200000;
        for (j = 0; j < 3000; j++);

	k++;
	if ((k % 10) == 0) m++;
	if (m == 28) m = 1;
	
	if (m == 1) {
	    reg_spictrl = 0x80080000;
	    print("Single          ");
	}
	else if (m == 2) {
	    reg_spictrl = 0x80480000;
	    print("DSPI            ");
	}
  	else if (m == 4) {
  	    reg_spictrl = 0x80580000;
  	 print("DSPI CRM        ");
  	}
  	else if (m == 6) {
  	    set_flash_latency(4);
  	    reg_spictrl = 0x80540000;
  	    print("DSPI CRM LAT4   ");
  	}
	else if (m == 8) {
	    set_flash_latency(8);
	    reg_spictrl = 0x80280000;
	    print("QSPI            ");
	}
	else if (m == 12) {
	    reg_spictrl = 0x80380000;
	    print("QSPI CRM        ");
	}
	else if (m == 16) {
	    reg_spictrl = 0x80680000;
	    print("QSPI DDR        ");
	}
	else if (m == 20) {
	    reg_spictrl = 0x80780000;
	    print("QSPI DDR CRM    ");
	}
    }
}

