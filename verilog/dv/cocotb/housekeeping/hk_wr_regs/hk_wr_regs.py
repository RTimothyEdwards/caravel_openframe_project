from cocotb_includes import test_configure
from cocotb_includes import report_test
import cocotb
from openframe import OpenFrame
from openframe import OpenFrameSPI
from housekeeping.housekeeping_regs import HousekeepingRegs
import random
@cocotb.test()
@report_test
async def hk_wr_regs(dut):
    caravelEnv = await test_configure(dut,timeout_cycles=188117)
    openframe = OpenFrame(caravelEnv)
    housekeeping_regs = HousekeepingRegs()
    spi_master = OpenFrameSPI(caravelEnv)
    # loop over all the registers
    await openframe.wait_reg1(0xAA)

    for address in housekeeping_regs.memory.keys():
        rand_val = random.randint(0, 255)
        # write register through SPI
        await spi_master.write_reg_spi(address, rand_val)
        # write RAL model
        housekeeping_regs.write(address, rand_val)

    for address in housekeeping_regs.memory.keys():
        recieve_val = await spi_master.read_reg_spi(address)
        expected_val = housekeeping_regs.read(address)
        if recieve_val != expected_val:
            cocotb.log.error(f"[TEST] Mismatch at register {housekeeping_regs.memory[address].name} address {hex(address)}   recieved {recieve_val} expected {expected_val}")
        else:
            cocotb.log.info(f"[TEST] read correct after write from register {housekeeping_regs.memory[address].name} address {hex(address)}   recieved {recieve_val}")
        
