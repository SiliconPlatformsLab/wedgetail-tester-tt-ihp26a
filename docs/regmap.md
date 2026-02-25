<!---
Markdown description for SystemRDL register map.

Don't override. Generated from: wedgetail_spi
  - regmap/wedgetail_spi.rdl
-->

## wedgetail_spi address map

- Absolute Address: 0x0
- Base Offset: 0x0
- Size: 0x2

<p>Wedgetail SPI interface for Wedgetail TCDE REV01</p>

|Offset| Identifier|             Name            |
|------|-----------|-----------------------------|
|  0x0 |  SYS_CTRL |        System Control       |
|  0x1 |ROSC_EN_SEL|Ring Oscillator Enable Select|

### SYS_CTRL register

- Absolute Address: 0x0
- Base Offset: 0x0
- Size: 0x1

|Bits|Identifier|Access|Reset|Name|
|----|----------|------|-----|----|
|  0 |   RESET  |   w  | 0x0 |  — |
| 7:1|   ECHO   |  rw  | 0x3 |  — |

#### RESET field

<p>When any value is written to this register, a power on reset will be performed on the
entire device</p>

#### ECHO field

<p>Read/write echo register, for SPI debugging</p>

### ROSC_EN_SEL register

- Absolute Address: 0x1
- Base Offset: 0x1
- Size: 0x1

|Bits|Identifier|Access|Reset|Name|
|----|----------|------|-----|----|
| 7:0|   data   |  rw  |  —  |  — |

#### data field

<p>Select the bits enabled by the configurable ring oscillator.</p>
