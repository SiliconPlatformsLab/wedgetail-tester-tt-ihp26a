// This file is part of "Wedgetail"
// Copyright (c) 2026 M. L. Young. All rights reserved.

// A runtime programmable ring oscillator ring oscillator.
module ring_osc_prog_ihp130 # (
    // Number of total stages the ring oscillator should have
    parameter int NUM_STAGES = 63
) (
    // One-hot programming for the stages. 1 = this stage is enabled, 0 = pass-through.
    input logic[NUM_STAGES-1:0] coding,

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
            (* keep *) (* dont_touch *) inv_en_ihp130 inv(
                .o_sig(fabric[i + 1]),
                .i_sig(fabric[i]),
                .i_en(coding[i])
            );
        end
    endgenerate

    // feedback tap
    // this does fabric[0] <- fabric[NUM_STAGES]
    (* keep *) (* dont_touch *) sg13g2_inv_1 feedback(
        .Y(fabric[0]),
        .A(fabric[NUM_STAGES])
    );

    // tap the output at the start of the inverter chain, this should be sufficient
    assign osc = fabric[0];
endmodule
