from housekeeping.ral_model import RALModel

class HousekeepingRegs(RALModel):
    def __init__(self):
        super().__init__()
        self.setup_hk_regs()
    
    def setup_hk_regs(self):
        #fixed registers
        self.add_register(name="SPI status", address=0x00, writable_mask=0x00, size=1, reset_val=0x00)
        self.add_register(name="Manufacturer ID reg1", address=0x01, writable_mask=0x00, size=4, reset_val=0x4)
        self.add_register(name="Manufacturer ID reg0", address=0x02, writable_mask=0x00, size=8, reset_val=0x56)
        self.add_register(name="Product ID", address=0x03, writable_mask=0x00, size=8, reset_val=0x14)
        # TODO: get the user programming number
        self.add_register(name="Mask rev reg3", address=0x04, writable_mask=0x00, size=8, reset_val=0x00)
        self.add_register(name="Mask rev reg2", address=0x05, writable_mask=0x00, size=8, reset_val=0x00)
        self.add_register(name="Mask rev reg1", address=0x06, writable_mask=0x00, size=8, reset_val=0x00)
        self.add_register(name="Mask rev reg0", address=0x07, writable_mask=0x00, size=8, reset_val=0x00)
        # writable registers
        self.add_register(name="DLL enable", address=0x08, writable_mask=0x03, size=2, reset_val=0x2)
        self.add_register(name="Dll bypass", address=0x09, writable_mask=0x01, size=1, reset_val=0x1)
        self.add_register(name="SPI irq", address=0x0a, writable_mask=0x01, size=1, reset_val=0x0)
        self.add_register(name="CPU reset", address=0x0b, writable_mask=0x01, size=1, reset_val=0x0)
        self.add_register(name="CPU trap", address=0x0c, writable_mask=0x00, size=1, reset_val=0x0)
        self.add_register(name="DLL trim reg0", address=0x0d, writable_mask=0xFF, size=8, reset_val=0xFF)
        self.add_register(name="DLL trim reg1", address=0x0e, writable_mask=0xFF, size=8, reset_val=0xEF)
        self.add_register(name="DLL trim reg2", address=0x0f, writable_mask=0xFF, size=8, reset_val=0xFF)
        self.add_register(name="DLL trim reg3", address=0x10, writable_mask=0x03, size=2, reset_val=0x3)
        self.add_register(name="DLL select", address=0x11, writable_mask=0x3F, size=6, reset_val=0x12)
        self.add_register(name="DLL div", address=0x12, writable_mask=0x1F, size=5, reset_val=0x4)
        self.add_register(name="Clock monitor divider", address=0x13, writable_mask=0xFF, size=8, reset_val=100)
        self.add_register(name="Auxiliary clock divider", address=0x14, writable_mask=0xFF, size=8, reset_val=100)
