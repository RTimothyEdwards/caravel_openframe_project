#include <openframe.h>


void main(){
    // configure SDO as output
    GPIO_Configure(1, GPIO_MODE_VECTOR_OUTPUT);
    set_debug_reg1(0xAA);
}