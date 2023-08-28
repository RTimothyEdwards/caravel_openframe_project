from cocotb_includes import test_configure
from cocotb_includes import report_test
import cocotb
from cocotb.triggers import ClockCycles
from openframe import OpenFrame
import random
import queue


@cocotb.test()
@report_test
async def timer1(dut):
    caravelEnv = await test_configure(dut,timeout_cycles=1188117)
    await caravelEnv.release_csb()
    openframe = OpenFrame(caravelEnv)
    gpios_order = (16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 0, 43, 2, 5, 4, 3, 10,7,12)
    await openframe.wait_reg1(0xAA) 
    # start monitor timer oneshot count down
    old_received = int(caravelEnv.monitor_discontinuous_gpios(gpios_order[::-1]),2)
    while True:
        received = int(caravelEnv.monitor_discontinuous_gpios(gpios_order[::-1]),2)
        if received != old_received:
            if received > old_received and old_received != 0:
                cocotb.log.error(f"[TEST] timer doesn't count down at oneshot count down config {hex(received)} > {hex(old_received)}")
            else:
                cocotb.log.info(f"[TEST] timer value {hex(received)} ")
            old_received = received
            if received == 0:
                cocotb.log.info(f"[TEST] timer reaches 0 at oneshot count down config")
                break
        await ClockCycles(caravelEnv.clk,1)
    # wait for random number of clock cycles and check if timer still 0
    await ClockCycles(caravelEnv.clk,random.randint(100,1000))
    received = int(caravelEnv.monitor_discontinuous_gpios(gpios_order[::-1]),2)
    if received != 0:
        cocotb.log.error(f"[TEST] timer doesn't stays at 0 at oneshot count down config {hex(received)}")
    else: 
        cocotb.log.info(f"[TEST] finsh testing oneshot count down config")
    openframe.write_debug_reg2_backdoor(0xA1) 

    # start monitor timer oneshot count up
    old_received = int(caravelEnv.monitor_discontinuous_gpios(gpios_order[::-1]),2)
    while True:
        received = int(caravelEnv.monitor_discontinuous_gpios(gpios_order[::-1]),2)
        if received != old_received:
            if received < old_received and old_received != 0:
                cocotb.log.error(f"[TEST] timer doesn't count up at oneshot count up config {hex(received)} > {hex(old_received)}")
            else:
                cocotb.log.info(f"[TEST] timer value {hex(received)} ")
            old_received = received
            if received == 0x5FFF:
                cocotb.log.info(f"[TEST] timer reaches 0 at oneshot count up config")
                break
        await ClockCycles(caravelEnv.clk,1)
    # wait for random number of clock cycles and check if timer still 0
    await ClockCycles(caravelEnv.clk,random.randint(100,1000))
    received = int(caravelEnv.monitor_discontinuous_gpios(gpios_order[::-1]),2)
    if received != 0x5FFF:
        cocotb.log.error(f"[TEST] timer doesn't stays at 0x5FFF at oneshot count up config {hex(received)}")
    else: 
        cocotb.log.info(f"[TEST] finsh testing oneshot count up config")
    openframe.write_debug_reg2_backdoor(0xA2)

    # start monitor timer periodic count down
    last_3_Seq = queue.Queue() # 1 means count up and 0 means count down
    for i in range(3):
        last_3_Seq.put(0)
    cocotb.log.info(f"[TEST] Start monitoring timer periodic count down")
    old_received = int(caravelEnv.monitor_discontinuous_gpios(gpios_order[::-1]),2)
    rollover_count = 0
    while True:
        received = int(caravelEnv.monitor_discontinuous_gpios(gpios_order[::-1]),2)
        if received != old_received:
            if received > old_received:
                last_3_Seq.get()
                last_3_Seq.put(1)
            else:
                last_3_Seq.get()
                last_3_Seq.put(0)
            seq_list = list(last_3_Seq.queue)
            if (seq_list == [0,1,0]):
                cocotb.log.info("[TEST] timer rollover at periodic count down config")
                rollover_count += 1
                if rollover_count == 3:
                    break
            # check if illegal sequence happened 
            for i in range(len(seq_list) - 1):
                if seq_list[i] == 1 and seq_list[i + 1] == 1:
                    cocotb.log.error("[TEST] value increase 2 times at periodic count down config")
            cocotb.log.info(f"[TEST] timer value {hex(received)} ")
            old_received = received
            
        await ClockCycles(caravelEnv.clk,1)
   
    openframe.write_debug_reg2_backdoor(0xA3)

    # start monitor timer periodic count up
    last_3_Seq = queue.Queue() # 1 means count up and 0 means count down
    for i in range(3):
        last_3_Seq.put(1)
    cocotb.log.info(f"[TEST] Start monitoring timer periodic count up")
    old_received = int(caravelEnv.monitor_discontinuous_gpios(gpios_order[::-1]),2)
    rollover_count = 0
    while True:
        received = int(caravelEnv.monitor_discontinuous_gpios(gpios_order[::-1]),2)
        if received != old_received:
            if received > old_received:
                last_3_Seq.get()
                last_3_Seq.put(1)
            else:
                last_3_Seq.get()
                last_3_Seq.put(0)
            seq_list = list(last_3_Seq.queue)
            if (seq_list == [1,0,1]):
                cocotb.log.info("[TEST] timer rollover at periodic count up config")
                rollover_count += 1
                if rollover_count == 3:
                    break
            # check if illegal sequence happened 
            for i in range(len(seq_list) - 1):
                if seq_list[i] == 0 and seq_list[i + 1] == 0:
                    cocotb.log.error("[TEST] value increase 2 times at periodic count up config")
            cocotb.log.info(f"[TEST] timer value {hex(received)} ")
            old_received = received
            
        await ClockCycles(caravelEnv.clk,1)
   
    openframe.write_debug_reg2_backdoor(0xA3)