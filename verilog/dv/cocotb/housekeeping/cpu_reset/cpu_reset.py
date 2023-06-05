from cocotb_includes import test_configure
from cocotb_includes import report_test
import cocotb
from openframe import OpenFrame
from openframe import OpenFrameSPI
from housekeeping.housekeeping_regs import HousekeepingRegs
from cocotb.triggers import ClockCycles


@cocotb.test()
@report_test
async def cpu_reset(dut):
    caravelEnv = await test_configure(dut,timeout_cycles=9109)
    openframe = OpenFrame(caravelEnv)
    housekeeping_regs = HousekeepingRegs()
    spi_master = OpenFrameSPI(caravelEnv)
    # wait until program finished
    await openframe.wait_reg1(0xBB)
    # reset CPU 
    await spi_master.write_reg_spi(0xb,1)
    await ClockCycles(caravelEnv.clk,10)   
    await spi_master.write_reg_spi(0xb,0)

    # wait until program started over 
    await openframe.wait_reg1(0xAA)


