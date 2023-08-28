from cocotb_includes import test_configure
from cocotb_includes import report_test
import cocotb
from cocotb.triggers import ClockCycles
from openframe import OpenFrame, OpenFrameUART
import random
from spi_master.spi_slave import SPISlave

@cocotb.test()
@report_test
async def spi_master(dut):
    caravelEnv = await test_configure(dut,timeout_cycles=68629)
    openframe = OpenFrame(caravelEnv)
    dut.gpio10_en.value =1 # enable driving of gpio10 
    spi_slave = SPISlave(miso=dut.gpio10, mosi=dut.gpio11_monitor, sclk=dut.gpio9_monitor, cs=dut.gpio8_monitor)
    first_slave = await cocotb.start(spi_slave.start())    
    await openframe.wait_any_change_reg2()
    if openframe.read_debug_reg2() == 0xE0:
        cocotb.log.error(f"[TEST] Read wrong value {hex(openframe.read_debug_reg1())} at the first phase")  
    elif openframe.read_debug_reg2() == 0xA0:
        cocotb.log.info(f"[TEST] Read correct value {hex(openframe.read_debug_reg1())} at the first phase")
    else: 
        cocotb.log.error(f"[TEST] Read illega value {hex(openframe.read_debug_reg1())} at the first phase")

    # make spi_slave with different configurations
    first_slave.kill()
    spi_slave = SPISlave(miso=dut.gpio10, mosi=dut.gpio11_monitor, sclk=dut.gpio9_monitor, cs=dut.gpio8_monitor, cs_inverted=1, mlb=1,mode=1)
    second_slave = await cocotb.start(spi_slave.start())    
    await openframe.wait_any_change_reg2()
    if openframe.read_debug_reg2() == 0xE1:
        cocotb.log.error(f"[TEST] Read wrong value {hex(openframe.read_debug_reg1())} at the second phase")  
    elif openframe.read_debug_reg2() == 0xA1:
        cocotb.log.info(f"[TEST] Read correct value {hex(openframe.read_debug_reg1())} at the second phase")
    else:
        cocotb.log.error(f"[TEST] Read illega value {hex(openframe.read_debug_reg1())} at the second phase")