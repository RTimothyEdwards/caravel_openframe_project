from cocotb_includes import test_configure
from cocotb_includes import report_test
import cocotb
from cocotb.triggers import ClockCycles, NextTimeStep
from openframe import OpenFrame

@cocotb.test()
@report_test
async def vector_all_i_0_1(dut):
    caravelEnv = await test_configure(dut,timeout_cycles=231605)
    await caravelEnv.release_csb()
    gpios_order = (16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 0, 43, 2, 5, 4, 3, 10,7,12)

    openframe = OpenFrame(caravelEnv)
    await openframe.wait_reg2(0xAA)
    data_out = int(caravelEnv.monitor_discontinuous_gpios(gpios_order),2)
    if data_out != 0xAAAAAAA:
        cocotb.log.error(f"test failed excepted 0xAAAAAAA received {hex(data_out)}")
    else: 
        cocotb.log.info(f"received {hex(data_out)}")
    await openframe.wait_reg2(0xBB)
    data_out = int(caravelEnv.monitor_discontinuous_gpios(gpios_order),2)
    if data_out != 0x15555555:
        cocotb.log.error(f"test failed excepted 0x5555555 received {hex(data_out)}")
    else:
        cocotb.log.info(f"received {hex(data_out)}")
    