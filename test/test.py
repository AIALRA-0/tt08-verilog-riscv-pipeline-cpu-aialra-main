# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles
import re

@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")
    
    # Set instruction memory size
    INSTR_MEM_SIZE = 64

    # Set clock period to 10 nanoseconds (100 MHz)
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    # Initialize
    dut._log.info("Reset")
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    dut.ena.value = 0
    
    # Reset
    await ClockCycles(dut.clk, 2)
    dut.ena.value = 1 
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 2)

    # Initialize instruction memory to nop
    instruction_memory = [0x00000013] * INSTR_MEM_SIZE

    # Read instructions from .mem file and overwrite instruction_memory
    with open("program.mem", "r") as f:
        address = 0
        for line in f:
            line = line.strip()
            if line.startswith("@"):
                address = int(line[1:], 16)
            elif line and not line.startswith("//"):
                # Extract the hexadecimal instruction part of the line, ignoring comments
                instruction_str = line.split()[0]
                if re.match(r'^[0-9a-fA-F]+$', instruction_str):
                    instruction = int(instruction_str, 16)
                    instruction_memory[address] = instruction
                    dut._log.info(f"Read instruction @ {address:04x}: {instruction:08x}")
                    address += 1

    # UART write function
    async def uart_write(target_mem, target_addr, data):
        handshake_packet = (1 << 11) | (1 << 10) | (target_mem << 9) | target_addr
        await send_packet(handshake_packet)
        for _ in range(4):
            data_packet = (data >> 24) & 0x3FF
            await send_packet(data_packet)
            data <<= 8

    # UART read function
    async def uart_read(target_mem, target_addr):
        # Construct handshake packet
        handshake_packet = (0 << 11) | (1 << 10) | (target_mem << 9) | target_addr
        await send_packet(handshake_packet)
    
        # Receive the handshake packet
        received_packet = await receive_packet()
        dut._log.info(f"Received handshake packet: {received_packet:012b}")
    
        # Check the handshake packet
        if (received_packet >> 11 == 0 and
            (received_packet >> 10) & 1 == 1 and
            (received_packet >> 9) & 1 == target_mem and
            received_packet & 0x1FF == target_addr):
            dut._log.info(f"Handshake packet verified: Memory type = {'Instruction Memory' if target_mem else 'Data Memory'}, Address = {target_addr}")
    
            # Receive the data packet
            received_data = 0
            for _ in range(4):
                data_packet = await receive_packet()
                received_data = ((received_data >> 8) & 0x00FFFFFF) | (data_packet << 24)
            dut._log.info(f"Received data: 0x{received_data:X}")
        else:
            dut._log.info("Handshake packet mismatch")

    # Send packet
    async def send_packet(packet):
        dut.ui_in[1].value = 0  # Start bit
        await ClockCycles(dut.clk, 1)
        for i in range(12):
            dut.ui_in[1].value = (packet >> i) & 1  # Use ui_in[1] as the transmit pin
            await ClockCycles(dut.clk, 1)
        dut.ui_in[1].value = 1  # Stop bit
        await ClockCycles(dut.clk, 2)  # Interval bit

    # Receive packet
    async def receive_packet():
        # Wait for start bit
        while dut.uio_out[0].value == 1:
            await ClockCycles(dut.clk, 1)
        # Receive handshake packet
        packet = 0
        for i in range(12):
            await ClockCycles(dut.clk, 1)
            packet |= (dut.uio_out[0].value << i)
        # Skip stop bit
        await ClockCycles(dut.clk, 2)
        return packet
    
    async def cpu_pause():
        await ClockCycles(dut.clk, 1)
        dut.ui_in[0].value = 0
        await ClockCycles(dut.clk, 1)
        
    async def cpu_start():
        await ClockCycles(dut.clk, 1)
        dut.ui_in[0].value = 1
        await ClockCycles(dut.clk, 1)

    # Initialize
    dut._log.info("Initializing instruction memory")
    for i, instruction in enumerate(instruction_memory[:INSTR_MEM_SIZE-1]):
        dut._log.info(f"Writing instruction {i}: {instruction:X}")
        await uart_write(1, i, instruction)

    await uart_write(0, 14, 0xCA54FE03)
    await uart_read(1, 1)
    await uart_read(0, 14)

    await ClockCycles(dut.clk, 2)

    # Enable CPU
    await cpu_start()
    await ClockCycles(dut.clk, 1000)
    
    '''
    # Pause while running
    dut.ui_in[0].value = 0
    await ClockCycles(dut.clk, 2)
    await uart_read(1, 13)
    await uart_write(0, 1, 0xCA54FE03)
    await uart_write(1, 99, 0xCA54FE03)
    await uart_read(1, 14)
    await ClockCycles(dut.clk, 2)
    dut.ui_in[0].value = 1

    await ClockCycles(dut.clk, 1000)

    dut.ui_in[0].value = 0
    await ClockCycles(dut.clk, 2)
    await uart_read(1, 11)
    await uart_write(0, 1, 0xC329840D)
    await uart_write(1, 99, 0xC329840D)
    await uart_read(1, 16)
    await ClockCycles(dut.clk, 2)
    dut.ui_in[0].value = 1
    '''
    
    for _ in range(20):
        await ClockCycles(dut.clk, 100)  # Wait for 1,000,000 clock cycles
        await cpu_pause()
        await uart_read(0, 0)  # Perform uart_read for address data_mem[0]
        await cpu_start()

    await ClockCycles(dut.clk, 1000)  # Wait for 1,000 clock cycles
    cocotb.log.info("Test completed")
