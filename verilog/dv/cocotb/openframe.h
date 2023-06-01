#include <defs.h>

#define SEED 0x1578015 // changing this seed would change the output of the random number generator of some thets 
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

int GPIO_getConfig(int gpio_num){
    switch(gpio_num){
        case 0 :
            return reg_gpio_0_config;
        case 1 :
            return reg_gpio_1_config;
        case 2 :
            return reg_gpio_2_config;
        case 3 :
            return reg_gpio_3_config;
        case 4 :
            return reg_gpio_4_config;
        case 5 :
            return reg_gpio_5_config;
        case 6 :  
            return reg_gpio_6_config;
        case 7 :
            return reg_gpio_7_config;
        case 8 :
            return reg_gpio_8_config;
        case 9 :    
            return reg_gpio_9_config;
        case 10 :
            return reg_gpio_10_config;
        case 11 :
            return reg_gpio_11_config;
        case 12 :
            return reg_gpio_12_config;
        case 13 :
            return reg_gpio_13_config;
        case 14 :
            return reg_gpio_14_config;
        case 15 :
            return reg_gpio_15_config;
        case 16 :
            return reg_gpio_16_config;
        case 17 :
            return reg_gpio_17_config;
        case 18 :
            return reg_gpio_18_config;
        case 19 :
            return reg_gpio_19_config;
        case 20 :
            return reg_gpio_20_config;
        case 21 :
            return reg_gpio_21_config;
        case 22 :   
            return reg_gpio_22_config;
        case 23 :
            return reg_gpio_23_config;
        case 24 :   
            return reg_gpio_24_config;
        case 25 :
            return reg_gpio_25_config;
        case 26 :
            return reg_gpio_26_config;
        case 27 :
            return reg_gpio_27_config;
        case 28 :
            return reg_gpio_28_config;
        case 29 :   
            return reg_gpio_29_config;
        case 30 :   
            return reg_gpio_30_config;
        case 31 :   
            return reg_gpio_31_config;
        case 32 :
            return reg_gpio_32_config;
        case 33 :
            return reg_gpio_33_config;
        case 34 :
            return reg_gpio_34_config;
        case 35 :
            return reg_gpio_35_config;
        case 36 :
            return reg_gpio_36_config;
        case 37 :
            return reg_gpio_37_config;
        case 38 :
            return reg_gpio_38_config;
        case 39 :
            return reg_gpio_39_config;
        case 40 :
            return reg_gpio_40_config;
        case 41 :
            return reg_gpio_41_config;
        case 42 :
            return reg_gpio_42_config;
        case 43 :
            return reg_gpio_43_config;
    }
    return 0;   
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

// timer0 
void timer0_enable(bool is_enable){
    if (is_enable){
        reg_timer0_config |= 0x1;
    }else{
        reg_timer0_config &= 0xFFFFFFFE;
    }
}
void timer0_oneshot(bool is_oneshot){
    if (is_oneshot){
        reg_timer0_config |= 0x2;
    }
    else{
        reg_timer0_config &= 0xFFFFFFFD;
    }
}
void timer0_upcount(bool is_upcount){
    if (is_upcount){
        reg_timer0_config |= 0x4;
    }else{
        reg_timer0_config &= 0xFFFFFFFB;
    }
}
void timer0_data(int data){
    reg_timer0_data = data;
}
int timer0_get_data(){
    return reg_timer0_data;
}

void timer0_periodic_val(int data){
    reg_timer0_value = data;
}

void timer0_chain(bool is_chained){
    if (is_chained){
        reg_timer0_config |= 0x8;
    }else{
        reg_timer0_config &= 0xFFFFFFF7;
    }
}
void timer0_oneshot_config(bool is_upcount, int data){
    timer0_enable(0);
    timer0_oneshot(1);
    timer0_upcount(is_upcount);
    timer0_enable(1);
    if (is_upcount){
        timer0_periodic_val(data);
    }else{
        timer0_data(data);
    }
}
void timer0_periodic_config(bool is_upcount, int data){
    timer0_enable(0);
    timer0_oneshot(0);
    timer0_upcount(is_upcount);
    timer0_periodic_val(data);
    timer0_enable(1);
}       

// timer1 
void timer1_enable(bool is_enable){
    if (is_enable){
        reg_timer1_config |= 0x1;
    }else{
        reg_timer1_config &= 0xFFFFFFFE;
    }
}
void timer1_oneshot(bool is_oneshot){
    if (is_oneshot){
        reg_timer1_config |= 0x2;
    }
    else{
        reg_timer1_config &= 0xFFFFFFFD;
    }
}
void timer1_upcount(bool is_upcount){
    if (is_upcount){
        reg_timer1_config |= 0x4;
    }else{
        reg_timer1_config &= 0xFFFFFFFB;
    }
}
void timer1_data(int data){
    reg_timer1_data = data;
}
int timer1_get_val(){
    return reg_timer1_value;
}

void timer1_oneshot_config(bool is_upcount, int data){
    timer1_enable(0);
    timer1_oneshot(1);
    timer1_upcount(is_upcount);
    timer1_enable(1);
    if (is_upcount){
        timer0_periodic_val(data);
    }else{
        timer0_data(data);
    }
}
void timer1_periodic_config(bool is_upcount, int data){
    timer1_enable(0);
    timer1_oneshot(0);
    timer1_upcount(is_upcount);
    timer1_data(data);
    timer1_enable(1);
}
void timer1_chain(bool is_chained){
    if (is_chained){
        reg_timer1_config |= 0x8;
    }else{
        reg_timer1_config &= 0xFFFFFFF7;
    }
}

// spi master 
void spi_enable(bool is_enable){
    if (is_enable){
        reg_spimaster_config |= 0x2000; //bit 1
    }else{
        reg_spimaster_config &=  0xFFFFDFFF; //bit 1
    }    
}


void spi_write(char c){
    reg_spimaster_data =  c;
}
char spi_read(){
    spi_write(0);
    return reg_spimaster_data;
}

void spi_stream(bool is_stream){
    if (is_stream){
        reg_spimaster_config |= 0x1000;
    }
    else{
        reg_spimaster_config &= 0xFFFFEFFF;
    }
}

void spi_mlb(bool is_mlb){
    if (is_mlb){
        reg_spimaster_config |= 0x0100;
    }
    else{
        reg_spimaster_config &= 0xFFFFFFEF;
    }
}

void spi_invCSB(bool is_invCSB){
    if (is_invCSB){
        reg_spimaster_config |= 0x0200;
    }
    else{
        reg_spimaster_config &= 0xFFFFFFDF;
    }
}

void spi_mode(bool is_mode){
    if (is_mode){
        reg_spimaster_config |= 0x0800;
    }
    else{
        reg_spimaster_config &= 0xFFFFFFBF;
    }
}

