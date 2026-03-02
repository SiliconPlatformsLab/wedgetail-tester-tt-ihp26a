# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

  # # Inputs
  # ui[0]: "ROSC SEL 0" # ring osc mux select
  # ui[1]: "ROSC SEL 1"
  # ui[2]: "ROSC SEL 2"
  # ui[3]: "ROSC SEL 3"
  # ui[4]: "DPLL CLK 300 KHz" # 300 KHz input clock for DPLL
  # ui[5]: "MOSI"
  # ui[6]: "CS" # Chip Select
  # ui[7]: ""
  #
  # # Outputs
  # uo[0]: "ROSC MUX OUT"
  # uo[1]: ""
  # uo[2]: "ROSC 32 NO MUX" # no mux, 32 ROSC
  # uo[3]: "DPLL CLK" # 300 KHz clock through DPLL
  # uo[4]: "DPLL CLK FMULT" # 300 KHz clock through DPLL, with 8x frequency multiplier
  # uo[5]: "MISO"
  # uo[6]: "ROSC SPI OUT" # configurable ring oscillator over SPI
  # uo[7]: ""

def set_bit(signal, index, bit):
    current = signal.value.integer

    if bit:
        current |= (1 << index)
    else:
        current &= ~(1 << index)

    signal.value = current

def get_bit(signal, index):
    value = signal.value.integer
    return (value >> index) & 1


@cocotb.test()
async def test_spi_echo(dut):
    dut._log.info("Start")

    # Set the clock period to 1 MHz
    clock = Clock(dut.clk, 1000, unit="ns")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 1)
    dut.rst_n.value = 1

    dut._log.info("Test SPI echo")

    # shift in that its a write command
    dut._log.info("set write command")
    await ClockCycles(dut.clk, 1)

    # shift in the address (0x00)
    dut._log.info("set addr")
    await ClockCycles(dut.clk, 1)

    # shift in 10101010 to the sys ctrl register via MISO
    bits = [1, 0, 1, 0, 1, 0, 1, 0]
    assert len(bits) == 8
    for bit in bits:
        set_bit(dut.ui_in, 5, bit)
        await ClockCycles(dut.clk, 1)

    # de-assert SS (active low, pull it hi)
    dut._log.info("de-assert CS")
    set_bit(dut.ui_in, 6, 1)
    await ClockCycles(dut.clk, 1)
    set_bit(dut.ui_in, 6, 0)
    await ClockCycles(dut.clk, 1)

    # now, do a read

    # shift in that its a read
    set_bit(dut.ui_in, 5, 1)
    await ClockCycles(dut.clk, 1)

    # shift in addr (0x00)
    set_bit(dut.ui_in, 5, 0)
    await ClockCycles(dut.clk, 1)

    # read out the value
    val_out = []
    for i in range(8):
        await ClockCycles(dut.clk, 1)
        val_out.append(get_bit(dut.uo_out, 5)) # MISO

    assert bits == val_out

    # Set the input values you want to test
    # dut.ui_in.value = 20
    # dut.uio_in.value = 30
    #
    # # Wait for one clock cycle to see the output values
    # await ClockCycles(dut.clk, 1)
    #
    # # The following assersion is just an example of how to check the output values.
    # # Change it to match the actual expected output of your module:
    # assert dut.uo_out.value == 50
    #
    # Keep testing the module by changing the input values, waiting for
    # one or more clock cycles, and asserting the expected output values.
