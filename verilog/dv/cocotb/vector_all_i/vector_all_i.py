from cocotb_includes import test_configure
from cocotb_includes import report_test
import cocotb
from cocotb.triggers import ClockCycles
from openframe import OpenFrame

@cocotb.test()
@report_test
async def vector_all_i(dut):
    caravelEnv = await test_configure(dut,timeout_cycles=128369)
    openframe = OpenFrame(caravelEnv)
    await openframe.wait_reg1(0xAA)
    cocotb.log.info("finish configuring")
    old_value = 0
    gpios_order = (16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 0, 43, 1, 6, 9, 8, 11 ,13 ,14 ,15 )
    drive_vector_by_order(caravelEnv, gpios_order, old_value)
    data_in = 0x3FFFFFFF
    cocotb.log.info(f"[TEST] drive {hex(data_in)} to vector gpio[31:0]")
    drive_vector_by_order(caravelEnv, gpios_order, data_in)
    await openframe.wait_reg1(0xBB)
    if openframe.read_debug_reg2() == data_in:
        cocotb.log.info(
            f"[TEST] data {hex(data_in)} sent successfully through vector gpio[31:0]"
        )
    else:
        cocotb.log.error(
            f"[TEST] Error: reg_mprj_datal has recieved wrong data {openframe.read_debug_reg2()} instead of {data_in}"
        )
    data_in = 0x2AAAAAAA
    cocotb.log.info(f"[TEST] drive {hex(data_in)} to vector gpio[31:0]")
    drive_vector_by_order(caravelEnv, gpios_order, data_in)
    await openframe.wait_reg1(0xCC)
    if openframe.read_debug_reg2() == data_in:
        cocotb.log.info(
            f"[TEST] data {hex(data_in)} sent successfully through vector gpio[31:0]"
        )
    else:
        cocotb.log.error(
            f"[TEST] Error: reg_mprj_datal has recieved wrong data {openframe.read_debug_reg2()} instead of {data_in}"
        )
    data_in = 0x15555555
    cocotb.log.info(f"[TEST] drive {hex(data_in)} to vector gpio[31:0]")
    drive_vector_by_order(caravelEnv, gpios_order, data_in)
    await openframe.wait_reg1(0xDD)
    if openframe.read_debug_reg2() == data_in:
        cocotb.log.info(
            f"[TEST] data {hex(data_in)} sent successfully through vector gpio[31:0]"
        )
    else:
        cocotb.log.error(
            f"[TEST] Error: reg_mprj_datal has recieved wrong data {openframe.read_debug_reg2()} instead of {data_in}"
        )
    data_in = 0x0
    cocotb.log.info(f"[TEST] drive {hex(data_in)} to vector gpio[31:0]")
    drive_vector_by_order(caravelEnv, gpios_order, data_in)
    await openframe.wait_reg1(0xFF)
    if openframe.read_debug_reg2() == data_in:
        cocotb.log.info(
            f"[TEST] data {hex(data_in)} sent successfully through vector gpio[31:0]"
        )
    else:
        cocotb.log.error(
            f"[TEST] Error: reg_mprj_datal has recieved wrong data {openframe.read_debug_reg2()} instead of {data_in}"
        )
    
def drive_vector_by_order(caravelEnv, gpios_order, data_in):
    for i in range(len(gpios_order)):
        bit_value = get_bit_value(data_in, i)
        caravelEnv.drive_gpio_in(gpios_order[i], bit_value)

def get_bit_value(num, index):
    # Shifting the number to the right by the index
    shifted_num = num >> index

    # Masking the shifted number with 1 to get the bit value
    bit_value = shifted_num & 1

    return bit_value