# The cartridge

16 KB in page 1 (`0x4000-0x7FFF`), an `AB` header with INIT at `0x4077` and
no BASIC. The screen is SCREEN 2.

## VRAM, the other way round

The eight registers are loaded by `0x44EE` from `0x44FF`:
`02 E2 0E 7F 07 76 03 E1`. In SCREEN 2, R3 and R4 are base and mask, so
**the colour table is at `0x0000` and the patterns at `0x2000`**.

| area | what is there |
|---|---|
| `0x0000` | the colour table |
| `0x1800` | the sprite patterns |
| `0x2000` | the patterns |
| `0x3800` | the name table |
| `0x3B00` | the sprite attributes |
| `0x3B80` | **the stage script**: between 723 and 918 bytes |

## RAM

**The game's whole RAM is 1 KB**: `0xE000-0xE3FF`, cleared by INIT. The stack
is at `0xE400`.

| area | what is there |
|---|---|
| `0xE000` | the current scene |
| `0xE003` | the frame counter |
| `0xE005` | the interrupt lock, one bit |
| `0xE010` | the three sound voices, eleven bytes each |
| `0xE050` | the player in turn, 32 bytes; the other one at `0xE080` |
| `0xE051` | the stage number, in BCD |
| `0xE05C` / `0xE05D` | the stage counted from zero and its colour mask |
| `0xE0B0` | the sprite buffer |
| `0xE132` | the forty objects: row, column and type |
| `0xE1DE` | the three spiders, nine bytes each |

## The BIOS

It uses eight routines: RDVDP, RDVRM, SETRD, SETWRT, WRTVDP, WRTPSG, RDPSG and
SNSMAT.

## The two menu screens

Both are drawn from the ROM and checked against openMSX down to **0 bytes**.

![The company screen](imagenes/pantalla-presentacion.png)

![The title screen](imagenes/pantalla-titulo.png)
