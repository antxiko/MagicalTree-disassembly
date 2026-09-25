# The code

## Everything in the interrupt

INIT (`0x4077`) sets interrupt mode 1, hooks H.KEYI with a jump to `0x402C`,
puts the stack at `0xE400`, clears the kilobyte of RAM and sits on the
`jr $` at `0x40A5`. Everything else happens in the hook, once per frame:
sound first, the controls, and the scene. The sixteen scenes are in the table
at `0x40C3`, stuck right behind the `call` of the dispatcher at `0x404A`,
which finds it with a `pop hl`.

The game frame (`0x51F5`) is eleven calls in a row, one for each thing that
moves.

## Climbing the tree

- `0x52BB` uploads the stage script to `0x3B80`.
- `0x6749` takes a step: it counts and, when it reaches the steps of the next
  entry, pulls it out into the forty objects at `0xE132`. Spiders (type
  `0xE0`) go to their three records at `0xE1DE`.
- `0x6889` moves each object eight pixels down, erases the row it leaves
  —only if its type does not have bit 7 set— and redraws it; `0x68F8` redraws
  on top the ones with bit 6, and `0x6C32` moves the spiders.
- `0x4A0E` picks the piece from one of four tables —46 pieces; the nine
  scripts use 35 types— and `0x49B8` draws it.
- `0x5363` takes twenty-six steps in a row to build the first screen.

## The screen is the map

There is no map in RAM. `0x61A3` reads the two cells under the player's feet
from VRAM and `0x6465` checks whether they are pattern `0x9B`. `0x6251` looks
for an object on the screen to erase it, and the creatures check the cell
ahead before moving: `0x6EB4` wants index 3, `0x7167` one between `0xCD` and
`0xD0`.

## Randomness

Nine `ld a,r`: the Z80's refresh counter.

## The tools

- `tools/arbol.py`: the script, the pieces and the scenery step; it draws the
  nine stages.
- `tools/graficos.py`: the stage VRAM and the menu screens, with the
  cartridge's set-up chain.
- `tools/guiones.py` and `tools/rle.py`: they measure the labels and the
  compressed blocks by running their interpreters.
- `tools/coteja_fases.py` and `tools/omsx_fases.tcl`: the check against
  openMSX.
