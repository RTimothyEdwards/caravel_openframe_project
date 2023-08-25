import cocotb 
from cocotb.triggers import RisingEdge, FallingEdge


class SPISlave(object):

    def __init__(self, miso, mosi, sclk, cs, data_width=8, cs_inverted = 0, mode = 0, mlb = 0):
        """
        // mlb:
        //     0 = msb 1st
        //     1 = lsb 1st
        // cs_inverted:
        //     0 = normal CSB (active low)
        //     1 = inverted CSB (active high)
        // mode:
        //     0 = read and change data on opposite SCK edges
        //     1 = read and change data on the same SCK edge
        """

        self.miso = miso
        self.mosi = mosi
        self.sclk = sclk
        self.cs = cs
        self.memory = [0] * 255
        self.data_width = data_width
        self.cs_inverted = cs_inverted
        self.mode = mode
        self.mlb = mlb

    async def wait_assert_csb(self):
        if self.cs_inverted:
            await RisingEdge(self.cs)
        else:
            await FallingEdge(self.cs)
        cocotb.log.info("[SPI slave] CS asserted")

    async def wait_deassert_csb(self):
        if self.cs_inverted:
            await FallingEdge(self.cs)
        else:
            await RisingEdge(self.cs)
        cocotb.log.info("[SPI slave] CS deasserted")

    async def send(self, data):
        cocotb.log.info(f"[SPI slave] start sending {hex(data)} over miso")
        for i in range(self.data_width):
            if self.mlb == 0:
                bit = data & 0x80
                bit >>= 7
                data <<= 1
            else:
                bit = data & 0x01
                data >>= 1
            await self._write_edge()
            self.miso.value = int(bit)
            cocotb.log.debug(f"[SPI slave] write bit drive miso with value {bit}")

    async def recv(self):
        data = []
        for _ in range(self.data_width):
            await self._read_edge()
            data.append(self.mosi.value)
            cocotb.log.debug(f"[SPI slave] read bit {_} = {self.mosi.value}")
        if self.mlb:
            data = data[::-1]
        received = int("".join(str(bit) for bit in data),2)
        cocotb.log.info(f"[SPI slave] received {hex(received)} over mosi")
        return  received

    async def _read_edge(self):
        if self.mode == 0:
            await RisingEdge(self.sclk)
        else:
            await FallingEdge(self.sclk)

    async def _write_edge(self):
        if self.mode == 1:
            await RisingEdge(self.sclk)
        else:
            await FallingEdge(self.sclk)

    def read(self, address):
        if address >= len(self.memory):
            raise ValueError("Address out of range")
        cocotb.log.info(f"[SPI slave] read {hex(self.memory[address])} from address {hex(address)}")
        return self.memory[address]

    def write(self, address, data):
        if address >= len(self.memory):
            raise ValueError("Address out of range")
        cocotb.log.info(f"[SPI slave] write {hex(data)} to address {hex(address)}")
        self.memory[address] = data

    async def start(self):  
        cocotb.log.info("[SPI slave] Starting")      
        while True:
            await self.wait_assert_csb()
            # need to kill the operation waiting if csb deasserted
            op_fork = await cocotb.start(self.op_run())
            # Wait for csb_deasserted to finish.
            await self.wait_deassert_csb()
            # kill op
            op_fork.cancel()


    async def op_run(self):
        cocotb.log.info("[SPI slave] Start runnning operation")
        command = await self.recv()

        if command == 0x01: # Read command
            address = await self.recv()
            data = self.read(address)
            await self.send(data)

        elif command == 0x02: # Write command
            address = await self.recv()
            data = await self.recv()
            self.write(address, data)

        else:
            raise ValueError(f"Unknown command {command}")
