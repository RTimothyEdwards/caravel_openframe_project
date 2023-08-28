from cocotb_includes import test_configure
from cocotb_includes import report_test
import cocotb
from cocotb.triggers import ClockCycles
from openframe import OpenFrame
import random
import queue


@cocotb.test()
@report_test
async def timer_chain(dut):
    caravelEnv = await test_configure(dut,timeout_cycles=11188117)
    await caravelEnv.release_csb()
    openframe = OpenFrame(caravelEnv)
    gpios_order = (16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 0, 43, 2, 5, 4, 3, 10,7,12)
    await openframe.wait_reg1(0xAA) 
   