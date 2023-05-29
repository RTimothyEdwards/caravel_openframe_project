from cocotb_includes import test_configure
from cocotb_includes import report_test
import cocotb
from cocotb.triggers import ClockCycles
from openframe import OpenFrame
@cocotb.test()
@report_test
async def vector_all_o(dut):
    caravelEnv = await test_configure(dut,timeout_cycles=188117)
    await caravelEnv.release_csb()
    openframe = OpenFrame(caravelEnv)
    await openframe.wait_reg1(0xAA)
    cocotb.log.info("finish configuring")
    old_value = 0
    gpios_order = (16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 0, 43, 2, 5, 4, 3, 10,7,12)
    zeros = "00000000000000000000000000000"
    for i in range(len(gpios_order)):
        await openframe.wait_reg2(i)
        excepted = zeros[:i] + "1" + zeros[i+1:]
        received = caravelEnv.monitor_discontinuous_gpios(gpios_order)
        if excepted != received:
            cocotb.log.error(f"Mismatch at iteration {i} received {received} excepted {excepted} high gpio {gpios_order[i]}")
        else:
            cocotb.log.info(f"iteration {i} received {received} high gpio {gpios_order[i]}")
