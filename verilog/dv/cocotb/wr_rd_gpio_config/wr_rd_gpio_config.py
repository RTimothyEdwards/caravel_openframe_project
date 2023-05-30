from cocotb_includes import test_configure
from cocotb_includes import report_test
import cocotb
from cocotb.triggers import First, Edge
from openframe import OpenFrame
@cocotb.test()
@report_test
async def wr_rd_gpio_config(dut):
    caravelEnv = await test_configure(dut,timeout_cycles=11188117)
    caravelEnv.drive_gpio_in((38,0),0) # drive all gpios with 0 to made pan_gpio_in =0 rather than x
    openframe = OpenFrame(caravelEnv)
    await openframe.wait_reg1(0xAA) 
    cocotb.log.info("[TEST] finish configuring all gpios with random values")
    # wait  over 0xEE or 0xFF at reg1 
    while True: 
        await openframe.wait_any_change_reg1()
        if openframe.read_debug_reg1() in [0xEE,0xFF]:
            break
    if openframe.read_debug_reg1() == 0xFF:
        cocotb.log.info("[TEST] PASSED")
        return
    cocotb.log.error(f"[TEST] test failed at reading register {openframe.read_debug_reg2()}")
    await openframe.wait_any_change_reg1()
    expected = openframe.read_debug_reg1() & 0xFFFF
    recieved = openframe.read_debug_reg1() >> 16
    cocotb.log.info(f"[TEST] expected {hex(expected)} recieved {hex(recieved)}")

