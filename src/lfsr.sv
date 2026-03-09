// This file is part of "Wedgetail"
// Copyright (c) 2026 M. L. Young. All rights reserved.
`default_nettype none

module lfsr (
    input logic clk,
    input logic rst_n,
    output logic osc
);
    // LFSR value
    logic [15:0] lfsr;

    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            lfsr <= 16'hBEEF;
        end else begin
            // uses the Galois representation (see the ZipCPU article), the hex 0xD008 are the maximal period
            // 16-bit taps as listed above
            if (lfsr[0]) begin
                lfsr <= { 1'b0, lfsr[15:1] } ^ 16'hD008;
            end else begin
                lfsr <= { 1'b0, lfsr[15:1] };
            end
        end
    end

    assign osc = lfsr[0] ? 1 : 0;
endmodule
