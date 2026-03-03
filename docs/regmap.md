<!---
Markdown description for SystemRDL register map.

Don't override. Generated from: wedgetail_spi
  - regmap/wedgetail_spi.rdl
-->

## wedgetail_spi address map

- Absolute Address: 0x0
- Base Offset: 0x0
- Size: 0x4

<p>Wedgetail SPI interface for Wedgetail TCDE REV01</p>

|Offset| Identifier|             Name            |
|------|-----------|-----------------------------|
|  0x0 |  SYS_CTRL |            Reset            |
|  0x1 |   ECHO1   |            ECHO1            |
|  0x2 |   ECHO2   |            ECHO2            |
|  0x3 |ROSC_EN_SEL|Ring Oscillator Enable Select|

### SYS_CTRL register

- Absolute Address: 0x0
- Base Offset: 0x0
- Size: 0x1

|Bits|Identifier|Access|Reset|Name|
|----|----------|------|-----|----|
| 7:0|   RESET  |   w  | 0x0 |  — |

#### RESET field

<p>When any value is written to this register, a power on reset will be performed on the
entire device</p>

### ECHO1 register

- Absolute Address: 0x1
- Base Offset: 0x1
- Size: 0x1

|Bits|Identifier|Access|Reset|Name|
|----|----------|------|-----|----|
| 7:0|   DATA   |  rw  | 0x0 |  — |

#### DATA field

<p>Read/write echo register, for SPI debugging</p>

### ECHO2 register

- Absolute Address: 0x2
- Base Offset: 0x2
- Size: 0x1

|Bits|Identifier|Access|Reset|Name|
|----|----------|------|-----|----|
| 7:0|   DATA   |  rw  | 0x0 |  — |

#### DATA field

<p>Read/write echo register, for SPI debugging</p>

### ROSC_EN_SEL register

- Absolute Address: 0x3
- Base Offset: 0x3
- Size: 0x1

|Bits|Identifier|Access|Reset|Name|
|----|----------|------|-----|----|
| 7:0|   DATA   |  rw  |  —  |  — |

#### DATA field

<p>Select the bits enabled by the configurable ring oscillator.</p>
