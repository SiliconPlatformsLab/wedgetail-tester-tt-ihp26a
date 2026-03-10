// This file is part of "Wedgetail".
// Copyright (c) 2026 M. L. Young. All rights reserved.

// An inverter with an enable signal
module inv_en_ihp130 (
    input logic i_sig,

    input logic i_en,

    output logic o_sig
);
    logic inverted;

    // This is required otherwise the results suck (see SPICE), we gotta use x4 drive current
    (* keep *) (* dont_touch *) sg13g2_inv_4 inv(
        .Y(inverted),
        .A(i_sig)
    );

    assign o_sig = i_en ? inverted : i_sig;
endmodule
