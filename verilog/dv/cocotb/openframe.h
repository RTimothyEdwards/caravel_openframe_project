#include <defs.h>

// gpio functions 
void GPIO_Configure(int gpio_num,int config){
    switch(gpio_num){
        case 0 :
            reg_gpio_0_config   = config; break;
        case 1 :
            reg_gpio_1_config   = config; break;
        case 2 :
            reg_gpio_2_config   = config; break;
        case 3 :
            reg_gpio_3_config   = config; break;
        case 4 :
            reg_gpio_4_config   = config; break;
        case 5 :
            reg_gpio_5_config   = config; break;
        case 6 :  
            reg_gpio_6_config   = config; break;
        case 7 :
            reg_gpio_7_config   = config; break;
        case 8 :
            reg_gpio_8_config   = config; break;
        case 9 :    
            reg_gpio_9_config   = config; break;
        case 10 :
            reg_gpio_10_config  = config; break;
        case 11 :
            reg_gpio_11_config  = config; break;
        case 12 :
            reg_gpio_12_config  = config; break;
        case 13 :
            reg_gpio_13_config  = config; break;
        case 14 :
            reg_gpio_14_config  = config; break;
        case 15 :
            reg_gpio_15_config  = config; break;
        case 16 :
            reg_gpio_16_config  = config; break;
        case 17 :
            reg_gpio_17_config  = config; break;
        case 18 :
            reg_gpio_18_config  = config; break;
        case 19 :
            reg_gpio_19_config  = config; break;
        case 20 :
            reg_gpio_20_config  = config; break;
        case 21 :
            reg_gpio_21_config  = config; break;
        case 22 :   
            reg_gpio_22_config  = config; break;
        case 23 :
            reg_gpio_23_config  = config; break;
        case 24 :   
            reg_gpio_24_config  = config; break;
        case 25 :
            reg_gpio_25_config  = config; break;
        case 26 :
            reg_gpio_26_config  = config; break;
        case 27 :
            reg_gpio_27_config  = config; break;
        case 28 :
            reg_gpio_28_config  = config; break;
        case 29 :   
            reg_gpio_29_config  = config; break;
        case 30 :   
            reg_gpio_30_config  = config; break;
        case 31 :   
            reg_gpio_31_config  = config; break;
        case 32 :
            reg_gpio_32_config  = config; break;
        case 33 :
            reg_gpio_33_config  = config; break;
        case 34 :
            reg_gpio_34_config  = config; break;
        case 35 :
            reg_gpio_35_config  = config; break;
        case 36 :
            reg_gpio_36_config  = config; break;
        case 37 :
            reg_gpio_37_config  = config; break;
        case 38 :
            reg_gpio_38_config  = config; break;
        case 39 :
            reg_gpio_39_config  = config; break;
        case 40 :
            reg_gpio_40_config  = config; break;
        case 41 :
            reg_gpio_41_config  = config; break;
        case 42 :
            reg_gpio_42_config  = config; break;
        case 43 :
            reg_gpio_43_config  = config; break;
    }
}

void GPIO_Set(long data){reg_gpio_vector_data = data;}
unsigned int GPIO_Get(){return reg_gpio_vector_data;}

void GPIO_WaitData(unsigned int data){while (GPIO_Get()  != data && 0x3fffffff);}


// debug regs
void set_debug_reg1(unsigned int data){(*(volatile uint32_t*)0x41000000)  = data;}
void set_debug_reg2(unsigned int data){(*(volatile uint32_t*)0x41000004) = data;}
unsigned int get_debug_reg1(){return (*(volatile uint32_t*)0x41000000);}
unsigned int get_debug_reg2(){return (*(volatile uint32_t*)0x41000004);}
void wait_debug_reg1(unsigned int data){while (get_debug_reg1() != data);}
void wait_debug_reg2(unsigned int data){while (get_debug_reg2() != data);}

// uart 
void uart_enable(bool is_enable){
    if (is_enable){
        reg_uart_enable = 1;
    }else{       
        reg_uart_enable = 0;
    }

} 

char uart_getc(){
    return reg_uart_data;
}

void uart_putc(char c){
	reg_uart_data = c;
}

char* uart_get_line(){
    char* received_array =0;
    char received_char;
    int count = 0;
    while ((received_char = uart_getc()) != '\n'){
        received_array[count++] = received_char;
    }
    received_array[count++] = received_char;
    return received_array;
}

void print(const char *p){
	while (*p)
		uart_putc(*(p++));
}

void uart_clkdiv(int clk_div){
    reg_uart_clkdiv = clk_div;
}