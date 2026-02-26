/*
 * Copyright (c) 2025 M. L. Young
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

typedef enum logic [3:0] {
    ROSC_32_1 = 4'd0,
    ROSC_32_2 = 4'd1,
    ROSC_64 = 4'd2,
    ROSC_16 = 4'd3,
    ROSC_32_OR = 4'd4,
    ROSC_31 = 4'd5,
    ROSC_128 = 4'd6,
    ROSC_32_AND = 4'd7,
    ROSC_32_DRIVE_4 = 4'd8
} RingOscType;

module tt_um_mlyoung_wedgetail (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
    // All output pins must be assigned. If not used, assign to 0.
    assign uio_out = 0; // we don't use inouts
    assign uio_oe  = 0; // we don't enable inouts

    // List all unused inputs to prevent warnings
    wire _unused = &{ena, rst_n, 1'b0};

    // OUTPUTS
    logic o_rosc_mux_out;
    logic o_rosc_32_no_mux;
    logic o_dpll_clk;
    logic o_dpll_clk_fmult;
    logic o_miso;
    logic o_rosc_spi_out;

    // SPI

    logic spi_decoder_wr_en;
    logic spi_decoder_rd_en;
    logic [7:0] spi_decoder_reg_addr;
    logic [7:0] spi_wdata;
    logic [7:0] spi_rdata;

    logic reg_reset;
    logic [6:0] reg_echo;
    logic [7:0] reg_rosc_en_sel;

    spi_decoder spi_decoder_mod (
        .rst_n (rst_n),
        .i_spi_clk (clk),
        .i_spi_ssn (ui_in[6]),
        .i_spi_mosi (ui_in[5]),
        .o_spi_miso (o_miso),
        .o_reg_wr_en (spi_decoder_wr_en),
        .o_reg_rd_en (spi_decoder_rd_en),
        .o_reg_addr (spi_decoder_reg_addr), // this is a full 8-bit word for ease of transmission
        .o_reg_wdata (spi_wdata),
        .i_reg_rdata (spi_rdata)
    );

    wedgetail_spi_rf spi_regfile_mod (
        .clk (clk),
        .resetn (rst_n),
        .SYS_CTRL_RESET_q (reg_reset),
        .SYS_CTRL_ECHO_q (reg_echo),
        .ROSC_EN_SEL_data_q (reg_rosc_en_sel),
        .valid (spi_decoder_wr_en | spi_decoder_rd_en),
        .read (~spi_decoder_wr_en),
        .addr (spi_decoder_reg_addr[0]), // take lower 1 bit, we only have 2 registers
        .wdata (spi_wdata),
        .wmask (1'b1), // per byte (so we only need one)
        .rdata (spi_rdata)
    );

    // OSCILLATORS

    logic ro_32_1;
    logic ro_32_2;
    logic ro_16;
    logic ro_64;
    logic ro_or;
    logic ro_and;
    logic ro_31;
    logic ro_128;
    logic ro_32_drive4;

    (* keep *) ring_osc_ihp130 #(.NUM_STAGES(32)) mod_ro_32_1 (
        .osc (ro_32_1)
    );

    (* keep *) ring_osc_ihp130 #(.NUM_STAGES(32)) mod_ro_32_2 (
        .osc (ro_32_2)
    );

    (* keep *) ring_osc_ihp130 #(.NUM_STAGES(64)) mod_ro_64 (
        .osc (ro_64)
    );

    (* keep *) ring_osc_ihp130 #(.NUM_STAGES(16)) mod_ro_16 (
        .osc (ro_16)
    );

    (* keep *) ring_osc_ihp130 #(.NUM_STAGES(32)) mod_ro_32_raw (
        .osc (o_rosc_32_no_mux)
    );

    (* keep *) ring_osc_ihp130 #(.NUM_STAGES(31)) mod_ro_31 (
        .osc (ro_31)
    );

    (* keep *) ring_osc_ihp130 #(.NUM_STAGES(128)) mod_ro_128 (
        .osc (ro_128)
    );

    (* keep *) ring_osc_drive4_ihp130 #(.NUM_STAGES(32)) mod_ro_32_drive4 (
        .osc (ro_32_drive4)
    );

    ring_osc_prog_ihp130 #(.NUM_STAGES(8)) mod_ro_prog (
        .coding (reg_rosc_en_sel),
        .osc (o_rosc_spi_out)
    );

    assign ro_or = ro_32_1 | ro_32_2;
    assign ro_and = ro_32_1 & ro_32_2;

    // MUX

    RingOscType mux_in;

    assign mux_in = RingOscType'(ui_in[3:0]);

    always_comb begin
        case (mux_in)
            ROSC_32_1 : o_rosc_mux_out = ro_32_1;
            ROSC_32_2 : o_rosc_mux_out = ro_32_2;
            ROSC_64 : o_rosc_mux_out = ro_64;
            ROSC_16 : o_rosc_mux_out = ro_16;
            ROSC_32_OR : o_rosc_mux_out = ro_or;
            ROSC_31 : o_rosc_mux_out = ro_31;
            ROSC_128 : o_rosc_mux_out = ro_128;
            ROSC_32_AND : o_rosc_mux_out = ro_and;
            ROSC_32_DRIVE_4 : o_rosc_mux_out = ro_32_drive4;
            default : o_rosc_mux_out = 0;
        endcase
    end

    // DPLL

    dpll dpll (
        .clk (clk),
        .reset (~rst_n),
        .clk_fin (uio_in[4]),
        .clk_fout (o_dpll_clk),
        .clk8x_fout (o_dpll_clk_fmult)
    );

    // ASSIGN OUTPUTS

    assign uo_out[0] = o_rosc_mux_out;
    assign uo_out[1] = 0;
    assign uo_out[2] = o_rosc_32_no_mux;
    assign uo_out[3] = o_dpll_clk;
    assign uo_out[4] = o_dpll_clk_fmult;
    assign uo_out[5] = o_miso;
    assign uo_out[6] = o_rosc_spi_out;
    assign uo_out[7] = 0;

endmodule
