/*
 * Copyright (c) 2025 M. L. Young
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

typedef enum logic [2:0] {
    ROSC_32_1 = 3'd0,
    ROSC_32_2 = 3'd1,
    ROSC_64 = 3'd2,
    ROSC_16 = 3'd3,
    ROSC_32_OR = 3'd4,
    ROSC_31 = 3'd5,
    ROSC_128 = 3'd6
} RingOscType;

module tt_um_wedgetail_tester (
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
    assign uo_out[7:3] = 0;
    assign uio_out = 0; // we don't use inouts
    assign uio_oe  = 0; // we don't enable inouts

    // List all unused inputs to prevent warnings
    wire _unused = &{ena, rst_n, ui_in[7:3], 1'b0};

    // OSCILLATORS

    logic ro_32_1;
    logic ro_32_2;
    logic ro_16;
    logic ro_64;
    logic ro_or;
    logic ro_31;
    logic ro_128;

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
        .osc (uo_out[2])
    );

    (* keep *) ring_osc_ihp130 #(.NUM_STAGES(31)) mod_ro_31 (
        .osc (ro_31)
    );

    (* keep *) ring_osc_ihp130 #(.NUM_STAGES(128)) mod_ro_128 (
        .osc (ro_128)
    );

    assign ro_or = ro_32_1 | ro_32_2;

    // MUX

    logic mux_out;
    RingOscType mux_in;

    assign mux_in = RingOscType'(ui_in[2:0]);

    always_comb begin
        case (mux_in)
            ROSC_32_1 : mux_out = ro_32_1;
            ROSC_32_2 : mux_out = ro_32_2;
            ROSC_64 : mux_out = ro_64;
            ROSC_16 : mux_out = ro_16;
            ROSC_32_OR : mux_out = ro_or;
            ROSC_31 : mux_out = ro_31;
            ROSC_128 : mux_out = ro_128;
            default : mux_out = 0;
        endcase
    end

    assign uo_out[0] = mux_out;

    // This is for the benefit of LibreLane
    assign uo_out[1] = clk;

    logic dpll_clk_fout;
    logic dpll_clk8x_fout;


    // DPLL
    dpll dpll (
        .clk (clk),
        .reset (~rst_n),
        .clk_fin (uio_in[3]),
        .clk_fout (dpll_clk_fout),
        .clk8x_fout (dpll_clk8x_fout)
    );

    assign uo_out[3] = dpll_clk_fout;
    assign uo_out[4] = dpll_clk8x_fout;

endmodule
