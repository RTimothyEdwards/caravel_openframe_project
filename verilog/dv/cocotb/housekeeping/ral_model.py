import cocotb

class RALModel:
    def __init__(self, register_size=8):
        self.register_size = register_size
        self.memory = {}
        self.read_only = {}

    def add_register(self, name, address, writable_mask: int, size: int, reset_val = 0):
        if address in self.memory:
            raise ValueError(f"[RALModel] Trying to add new rigster {name} to address {address} but this address already assigned to register {self.memory[address].name}")
        if size > self.register_size:
            raise ValueError(f"[RALModel] Trying to add register {name} with size {size} but max register size is {self.register_size}")
        self.memory[address] = Register(name, size, writable_mask, reset_val)

    def read(self, address):
        if address in self.memory:
            return self.memory[address].read()
        else:
            cocotb.log.warning(f"[RALModel] Trying to read from unassigned register {address}")
            return None

    def write(self, address, value):
        if address in self.memory:
            self.memory[address].write(value)
        else:
            cocotb.log.warning(f"[RALModel] Trying to write to unassigned register {address}")

    def reset(self):
        for address in self.memory.keys():
            self.memory[address].reset()

class Register:
    def __init__(self, name, num_bits, writable_mask: int, reset_val = 0):
        self.name = name
        self.num_bits = num_bits
        self.writable_mask = writable_mask
        self.bits = {}
        for i in range(num_bits):
            bit_reset = (reset_val & (1 << i)) >> i
            bit_writable = (writable_mask & (1 << i)) >> i
            self.bits[i] = Bit(name, i, bit_writable, bit_reset)
        self.reset_val = reset_val

    def reset(self):
        for i in self.bits.values():
            bit_reset = (self.reset_val & (1 << i)) >> i
            self.bits[i].write(bit_reset)


    def read(self):
        # cocotb.log.debug(f"[Register][read] Reading register {self.name}")
        val = 0
        for bit_num, bit_val in self.bits.items():

            val = val | (bit_val.read() << bit_num)
        return val
    
    def write(self, value):
        # cocotb.log.debug(f"[Register][write] Writing value {value} to register {self.name}")
        for bit_num in self.bits.keys():
            bit_val = (value & (1 << bit_num)) >> bit_num
            self.bits[bit_num].write(bit_val)

class Bit:
    def __init__(self,register_name ,bit_num, is_writable: bool, reset_val = 0):
        self.register_name = register_name
        self.num_bit = bit_num
        self.is_writable = is_writable  
        self.value = reset_val & 0x1
    
    def read (self):
        return self.value & 0x1
    
    def write(self, value):
        if not self.is_writable:
            cocotb.log.warning(f"[Bit][write] Try writing to read-only bit {self.num_bit} at register {self.register_name}")
            return
        self.value = value & 0x1

