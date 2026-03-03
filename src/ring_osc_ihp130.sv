// This file is part of "Wedgetail".
// Copyright (c) 2026 M. L. Young. All rights reserved.

// A configurable ring oscillator.
// Version for IHP130
// Loosely based on:
// - https://github.com/litneet64/tt07-RO-based-PUF/blob/main/src/ring_osc.v
module ring_osc_ihp130 # (
    // Number of stages the ring oscillator should have
    parameter int NUM_STAGES = 63
) (
    // Enable
    input logic en,

    // Output oscillator signal
    output logic osc
);
    (* keep *) (* dont_touch *) logic [NUM_STAGES:0] fabric;

    // inverter chain
    generate
        for (genvar i = 0; i < NUM_STAGES; i++) begin : osc_gen
            // connect fabric[i+1] <- fabric[i]
            // we use clock inverter cells here, the flow tends to replace the "inv" cells with clock
            // inverters anyway
            (* keep *) (* dont_touch *) inv_en_ihp130 inv (
                    .i_sig (fabric[i]),
                    .i_en (en),
                    .o_sig (fabric[i+1])
            );
        end
    endgenerate

    // feedback tap
    // this does fabric[0] <- fabric[NUM_STAGES]
    inv_en_ihp130 feedback(
            .i_sig (fabric[NUM_STAGES]),
            .i_en (en),
            .o_sig (fabric[0])
    );

    // tap the output at the start of the inverter chain, this should be sufficient
    assign osc = fabric[0];
endmodule

// A configurable ring oscillator.
// Version for IHP130
// Loosely based on:
// - https://github.com/litneet64/tt07-RO-based-PUF/blob/main/src/ring_osc.v
module ring_osc_drive4_ihp130 # (
    // Number of stages the ring oscillator should have
    parameter int NUM_STAGES = 63
) (
    // Output oscillator signal
    output logic osc
);
    (* keep *) (* dont_touch *) logic [NUM_STAGES:0] fabric;

    // inverter chain
    generate
        for (genvar i = 0; i < NUM_STAGES; i++) begin : osc_gen
            // connect fabric[i+1] <- fabric[i]
            // we use clock inverter cells here, the flow tends to replace the "inv" cells with clock
            // inverters anyway
            (* keep *) (* dont_touch *) sg13g2_inv_4 inv(
                .Y(fabric[i + 1]),
                .A(fabric[i])
            );
        end
    endgenerate

    // feedback tap
    // this does fabric[0] <- fabric[NUM_STAGES]
    (* keep *) (* dont_touch *) sg13g2_inv_4 feedback(
        .Y(fabric[0]),
        .A(fabric[NUM_STAGES])
    );

    // tap the output at the start of the inverter chain, this should be sufficient
    assign osc = fabric[0];
endmodule
