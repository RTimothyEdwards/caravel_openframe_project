import cocotb
import re
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, Timer
from cocotb_includes import UART

class OpenFrame:
    def __init__(self, caravelEnv):
        self.caravelEnv = caravelEnv
        self.debug_hdl = caravelEnv.dut.uut.user_project.openframe_example.debug_regs

    async def wait_reg1(self, data):
        while True:
            if self.read_debug_reg1() == data:
                return
            await ClockCycles(self.caravelEnv.clk, 1)

    async def wait_reg2(self, data):
        while True:
            if self.read_debug_reg2() == data:
                return
            await ClockCycles(self.caravelEnv.clk, 1)

    def read_debug_reg1(self):
        return self.debug_hdl.debug_reg_1.value.integer

    def read_debug_reg2(self):
        return self.debug_hdl.debug_reg_2.value.integer

    def read_debug_reg1_str(self):
        return self.debug_hdl.debug_reg_1.value.binstr

    def read_debug_reg2_str(self):
        return self.debug_hdl.debug_reg_2.value.binstr

    # writing debug registers using backdoor because in GL
    # cpu can't be disabled for now because of different netlist names
    def write_debug_reg1_backdoor(self, data):
        self.debug_hdl.debug_reg_1.value = data

    def write_debug_reg2_backdoor(self, data):
        self.debug_hdl.debug_reg_2.value = data


class OpenFrameUART(UART):
    
    def __init__(self, openFrame: OpenFrame,clk_div=1, uart_pins={"tx": 6, "rx": 5}) -> None:
        super().__init__(openFrame.caravelEnv,uart_pins=uart_pins)
        self.openFrame = openFrame
        self.bit_time_ns = round(self.period *(2 + clk_div))  
        cocotb.log.info(f"[OpenFrameUART] configure UART bit_time_ns = {self.bit_time_ns}ns")
        self.uart_pins = uart_pins

    def change_clk_div(self, new_clk_div):
        self.bit_time_ns = round(self.period *(2 + new_clk_div))  
        cocotb.log.info(f"[OpenFrameUART] configure UART with new clk div {new_clk_div} bit_time_ns = {self.bit_time_ns}ns")

    