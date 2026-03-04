`default_nettype none
`timescale 1ns / 1ns

integer i;
integer reg_num;
integer bit_num;

module tb ();

    // Wire up the inputs and outputs:
    logic clk;
    logic rst_n;
    logic ena;
    logic [7:0] ui_in;
    logic [7:0] uio_in;
    logic [7:0] uo_out;
    logic [7:0] uio_out;
    logic [7:0] uio_oe;

    // # Inputs
    // ui[0]: "ROSC SEL 0" # ring osc mux select
    // ui[1]: "ROSC SEL 1"
    // ui[2]: "ROSC SEL 2"
    // ui[3]: "ROSC SEL 3"
    // ui[4]: "DPLL CLK 300 KHz" # 300 KHz input clock for DPLL
    // ui[5]: "MOSI"
    // ui[6]: "CS" # Chip Select
    // ui[7]: ""
    //
    // # Outputs
    // uo[0]: "ROSC MUX OUT"
    // uo[1]: ""
    // uo[2]: "ROSC 32 NO MUX" # no mux, 32 ROSC
    // uo[3]: "DPLL CLK" # 300 KHz clock through DPLL
    // uo[4]: "DPLL CLK FMULT" # 300 KHz clock through DPLL, with 8x frequency multiplier
    // uo[5]: "MISO"
    // uo[6]: "ROSC SPI OUT" # configurable ring oscillator over SPI
    // uo[7]: ""

    tt_um_mlyoung_wedgetail top (
        .ui_in(ui_in),
        .uo_out(uo_out),
        .uio_in(uio_in),
        .uio_out(uio_out),
        .uio_oe(uio_oe),
        .ena(ena),
        .clk(clk),
        .rst_n(rst_n)
    );

    localparam SSN = 6;
    localparam MOSI = 5;
    localparam MISO = 5;

    logic [7:0] CMD_WRITE = 8'd0;
    logic [7:0] CMD_READ = 8'd1;

    logic [7:0] rdata;

    task spi_write;
        input [7:0] addr;
        input [7:0] data;

        begin
            integer i;

            ui_in[SSN] = 0;

            for (i = 0; i < 24; i = i + 1) begin
                if (i < 8)
                  ui_in[MOSI] = CMD_WRITE[7-i];
                else if (i < 16)
                  ui_in[MOSI] = addr[15-i];
                else
                  ui_in[MOSI] = data[23-i];

                #10;
                clk = 1;
                #10;
                clk = 0;
            end

            ui_in[SSN] = 1;
        end
    endtask  // spi_write

    task spi_read;
        input [7:0] addr;
        output logic [7:0] rdata;

        begin
            integer i;

            ui_in[SSN] = 0;
            rdata = 8'd0;

            for (i = 0; i < 24; i = i + 1) begin
                if (i < 8) ui_in[MOSI] = CMD_READ[7-i];
                else if (i < 16) ui_in[MOSI] = addr[15-i];

                #10;
                // latch read data on rising edge of clk
                if (i >= 16) rdata = {rdata[6:0], uo_out[MISO]};
                clk = 1;
                #10;
                clk = 0;

            end  // for (i = 0; i < 24; i = i + 1)

            ui_in[SSN] = 1;
        end
    endtask  // spi_read

    // Dump the signals to a FST file. You can view it with gtkwave or surfer.
    initial begin
        $dumpfile("tb.fst");
        $dumpvars(0, tb);
        $display("SIM START");

        // enable, but keep SSN held high
        ena = 1;
        ui_in[SSN] = 1;
        #10;

        // trigger system reset
        rst_n = 0;
        #10;
        rst_n = 1;
        #10;

        for (logic[7:0] i = 0; i < 8'd3; i++) begin
            $display("WRITE TRANSACTION 0x%X", i);
            spi_write(i, 8'h3F);

            #10;
            clk = 1;
            #10;
            clk = 0;

            #50;

            $display("READ TRANSACTION 0x00");
            spi_read(i, rdata);
            $display("rdata: 0x%X", rdata);

            assert (rdata == 8'h3F);

            #100;
        end

        // readback
    end

endmodule
