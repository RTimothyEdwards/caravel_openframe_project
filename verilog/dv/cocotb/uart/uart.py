from cocotb_includes import test_configure
from cocotb_includes import report_test
import cocotb
from cocotb.triggers import ClockCycles
from openframe import OpenFrame, OpenFrameUART
import random

@cocotb.test()
@report_test
async def uart(dut):
    caravelEnv = await test_configure(dut,timeout_cycles=68629)
    openframe = OpenFrame(caravelEnv)
    uart = OpenFrameUART(openframe)
    caravelEnv.drive_gpio_in(5, 1)
    
    await uart_test_clock_div(uart,openframe, "Hello")
    await uart_test_clock_div(uart,openframe, "World")

async def uart_test_clock_div(uart,openframe, expected_word):
    line = await uart.get_line()  
    if line == expected_word:
        cocotb.log.info(f"[TEST] received {expected_word}")
    else:
        cocotb.log.error(f"received {line} instead of {expected_word}")
    rand_clk_div = random.randint(1,50)
    await uart_send_line(uart,openframe,str(rand_clk_div))
    await openframe.wait_reg1(0xAA)
    uart.change_clk_div(rand_clk_div)
    sent = openframe.read_debug_reg2()
    if sent != rand_clk_div:
        cocotb.log.error(f"[TEST] UART recieved {sent} instead of {rand_clk_div}")
    else:
        cocotb.log.info(f"[TEST] UART recieved {sent}")

async def uart_send_line(uart,openframe, line):
    for char in line:
        await openframe.wait_reg2(0xAA)
        await uart.uart_send_char(char)
        await openframe.wait_reg2(0xBB)
    # end of line \n
    await uart.uart_send_char("\n")