// This file is part of "Wedgetail".
// Copyright (c) 2026 M. L. Young. All rights reserved.

// Wedgetail top module
module wedgetail_top (
    // Currently only for the benefit of LibreLane
    input logic i_clk,

    // 16-chain ring oscillator
    output logic o_ro_1,

    // 16-chain ring oscillator
    output logic o_ro_2,

    // both ring oscillators OR'd together
    output logic o_ro_or,

    // Only for the benefit of LibreLane
    output logic o_clk_raw
);
    logic ro_1;
    logic ro_2;

    (* keep *) ring_osc_ihp130 #(.NUM_STAGES(32)) mod_ro_1 (
        .osc (ro_1)
    );

    (* keep *) ring_osc_ihp130 #(.NUM_STAGES(32)) mod_ro_2 (
        .osc (ro_2)
    );

    // assign the direct outputs
    assign o_ro_1 = ro_1;
    assign o_ro_2 = ro_2;

    // assign AND/OR tests
    assign o_ro_or = ro_1 | ro_2;

    // this is temporary, for the benefit of LibreLane
    assign o_clk_raw = i_clk;
endmodule
