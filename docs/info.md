<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

Wedgetail is a project that is part of my PhD thesis. This particular design is for Test, Calibration and
Design Exploration (TCDE), to assess the effectiveness of the project in high-radiation environments.

The design consists of a configurable array of ring oscillators and a Digital Phase Locked Loop (DPLL), both
of which are programmable over a simple SPI protocol generated with SystemRDL.

The intent is to:
- Verify the correctness of all of these components on real silicon; particularly the SPI and ring oscillator
  array
- Design and verify the fun logo-stamping workflow

## How to test

To see the full effectiveness of the design, you will need a high radiation environment, for example a
Cobalt-60 source, a laser, or a heavy ion accelerator; these sources will fundamentally change the behaviour
of the chip. Unfortunately, these tools may be slightly challenging to acquire. Consider building your own
heavy ion accelerator, if appropriate in your area.

## External hardware

- 14 MHz system clock is required
- Radiation source required for full demonstration
