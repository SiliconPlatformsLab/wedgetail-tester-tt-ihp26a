// Copyright (c) 2026 Silicon Platforms Lab. All rights reserved.

package spi_decoder_pkg;
  parameter int unsigned OPCODE_W       = 1; // {Read, Write}

  // Width of command byte (in our case, this is just the opcode)
  parameter int unsigned CMD_W          = 8;

  // Width of address bus
  parameter int unsigned SPI_REG_ADDR_W = 8;  // There are 256 logical addresses from the SPI interface perspective

  // Width of the register bank address, which is the same as the SPI_REG_ADDR_W in our case
  parameter int unsigned REGBANK_ADDR_W = SPI_REG_ADDR_W;

  // Width of data words
  parameter int unsigned DATA_W         = 8;  // Data is transferred as bytes

  parameter int unsigned SHIFT_REG_W    = 8;  // Match the largest value out of CMD, ADDR and DATA
  parameter int unsigned SHIFT_CNT_W    = $clog2(SHIFT_REG_W);

  // Get counter values to make comparisons without needing to width-cast every time
  parameter logic [SHIFT_CNT_W-1:0] OPCODE_CNT = SHIFT_CNT_W'(OPCODE_W);
  parameter logic [SHIFT_CNT_W-1:0] CMD_W_MAX  = SHIFT_CNT_W'(CMD_W-1);
  parameter logic [SHIFT_CNT_W-1:0] ADDR_W_MAX = SHIFT_CNT_W'(SPI_REG_ADDR_W-1);
  parameter logic [SHIFT_CNT_W-1:0] DATA_W_MAX = SHIFT_CNT_W'(DATA_W-1);

endpackage

