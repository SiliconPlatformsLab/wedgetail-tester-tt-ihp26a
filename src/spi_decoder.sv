// Copyright (c) 2026 Silicon Platforms Lab. All rights reserved.

// This is a SPI slave interface module that interfaces to an 8-bit
// bank of 64 registers.
//
// TODO: update this description
//
// The SPI protocol follows the convention used for accessing SPI flash memory
// where the first byte is the command byte, 2nd byte is the address byte, 3rd + bytes
// are the data bytes.
// The CPOL, CPHA mode is mode 0. SPI clock is 0 when SPI_SSN is 0.
// Data in sampled on the rising edge of SPI_CLK.
// Data out driven on the falling edge of SPI_CLK.

// verilator lint_off IMPORTSTAR

// SPI Decoder States. Don't specify values - let the compiler decide the optimal encoding.
typedef enum logic [1:0] {
  ST_IDLE,
  ST_CMD     ,  // Receiving and decoding the Opcode and Chip Address
  ST_REG_ADDR,  // Receiving and storing the Register Address, if it's a Read or Write
  ST_DATA       // Transferring data bytes between the SPI Master and the regbank
} spi_state_e;

// SPI Opcodes
typedef enum logic [7:0] {
  SPI_OP_WRITE      = 8'd0,  // Write byte(s) to a register
  SPI_OP_READ       = 8'd1  // Read bytes(s) from a register
} spi_op_e;

parameter int unsigned OPCODE_W       = 1; // {Read, Write}

// Width of command byte (in our case, this is just the opcode)
parameter int unsigned CMD_W          = 8;

// Width of address bus
parameter int unsigned SPI_REG_ADDR_W = 8;

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

module spi_decoder (
  input  logic rst_n,
  input  logic i_spi_clk,
  input  logic i_spi_ssn,
  input  logic i_spi_mosi,
  output logic o_spi_miso,
  output logic o_reg_wr_en,
  output logic o_reg_rd_en,
  output logic [REGBANK_ADDR_W-1:0] o_reg_addr,
  output logic [DATA_W-1:0] o_reg_wdata,
  input  logic [DATA_W-1:0] i_reg_rdata
);

  // SPI Decoder FSM signals
  spi_state_e spi_state;
  spi_state_e last_state;
  logic did_just_change_state;
  logic start;
  logic write;
  logic rd_pulse;

  // SPI addr and data signals
  logic [SHIFT_CNT_W-1:0]    shift_cnt;
  logic [SPI_REG_ADDR_W-1:0] spi_addr;  // The logical register address, received on the SPI interface
  logic [SHIFT_REG_W-1:0]    shift_in_reg;
  logic [SHIFT_REG_W-1:0]    shift_out_reg;

  logic reg_wr_en;
  logic reg_rd_en;
  logic miso_en;

  logic  [7:0]  opcode;

  // SPI Decoder State Machine
  always_ff @(posedge i_spi_clk or posedge i_spi_ssn) begin : spi_fsm
    if (i_spi_ssn == 1'b1) begin
      $display("SPI: Reset");
      spi_state      <= ST_CMD;
      start          <= 1'b0;
      write          <= 1'b0;
      rd_pulse       <= 1'b0;
      spi_addr       <= '0;
    end else begin
      last_state <= spi_state;
      unique case (spi_state)
        ST_IDLE : begin
          if (start == 1'b0) begin
            // Only leave IDLE if this is the first SCLK after Chip Select asserts
            start     <= 1'b1;
            spi_state <= ST_CMD;
            $display("ST_IDLE: Leave idle");
          end
        end  // ST_IDLE

        ST_CMD : begin
            if (shift_cnt == CMD_W_MAX) begin
              spi_state <= ST_REG_ADDR;  // Register Address will be received next

              if (opcode == SPI_OP_WRITE) begin
                $display("ST_CMD: Write op");
                write <= 1'b1;
              end else if (opcode == SPI_OP_READ) begin  // opcode == SPI_OP_READ
                $display("ST_CMD: Read op");
                rd_pulse <= 1'b1;  // Pulse when there's a read to enable the status registers' HW write
              end // opcode check
            end // CMD_W_MAX

            $display("ST_CMD: Reading command");
        end  // ST_CMD

        ST_REG_ADDR : begin
          rd_pulse <= 1'b0;  // Clear the read pulse
          $strobe("ST_REG_ADDR: Waiting");
          if (shift_cnt == ADDR_W_MAX) begin
            // Capture the starting Register Address and go to DATA
            spi_addr  <= {shift_in_reg[6:0], i_spi_mosi};
            spi_state <= ST_DATA;
            $strobe("ST_REG_ADDR: Reg addr 0x%X", spi_addr);
          end
        end  // ST_REG_ADDR

        ST_DATA : begin
          // TODO this doesn't seem right
          $strobe("ST_DATA: Idx %d", shift_cnt);
        end  // ST_DATA
      endcase
    end
  end : spi_fsm

  // Input Shift Register
  always_ff @(posedge i_spi_clk or posedge i_spi_ssn) begin : p_shift_in_reg
    if (i_spi_ssn == 1'b1) begin
      shift_cnt    <= 3'h0;
      shift_in_reg <= 8'h00;
    end else begin
      // Keep count of the number of bits shifted in
      shift_cnt    <= shift_cnt + 1'b1;
      shift_in_reg <= {shift_in_reg[6:0], i_spi_mosi};
    end
  end : p_shift_in_reg

  // Output Shift Register
  always_ff @(negedge i_spi_clk or posedge i_spi_ssn) begin : p_shift_out_reg
    if (i_spi_ssn == 1'b1) begin
      shift_out_reg <= 8'h00;
    end else begin
      if (reg_rd_en == 1'b1) begin
	      shift_out_reg <= i_reg_rdata;
      end else begin
	      shift_out_reg <= {shift_out_reg[6:0], 1'b0};
      end
    end
  end : p_shift_out_reg

  // Assign reg write and reg read enable pulses
  assign reg_wr_en = (write == 1'b1 && shift_cnt == DATA_W_MAX && spi_state == ST_DATA) ? 1'b1 : 1'b0;
  // Enable the MISO output (for tristate buffer) in the READ DATA state
  assign miso_en     = (write == 1'b0 && spi_state == ST_DATA) ? 1'b1 : 1'b0;
  // Read from the registers and load the output shift before the next DATA byte
  assign reg_rd_en   = (miso_en == 1'b1 && shift_cnt == 0) ? 1'b1 : 1'b0;

  // Assign outputs
  assign o_reg_rd_en         = reg_rd_en;
  assign o_reg_wr_en         = reg_wr_en;
  assign o_reg_addr          = spi_addr; // in our design, reg_addr == spi_addr
  assign o_reg_wdata         = {shift_in_reg[6:0], i_spi_mosi};
  assign o_spi_miso          = shift_out_reg[7];

endmodule

