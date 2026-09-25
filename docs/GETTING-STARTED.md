# Getting started

This repository holds the commented disassembly of Konami's **Magical Tree**
for the MSX (RC-713, 1984). It does not hold the cartridge: the ROM image is
not distributed.

## What you need

- `pasmo` — the assembler that reproduces the ROM
- `python3` — the tools in `tools/`
- `make`
- Your own copy of the cartridge, in the root and named `magicaltree.rom`

It is **exactly 16,384 bytes** and its fingerprint is:

    sha256  a3f3ad0d8f5cda0f04bf917fbd9d796e9dc66d071bd30a2fde8d06260c7ec9f7

To check it:

    make comprueba

## Reproducing all of it

| command | what it does | what it proves |
|---|---|---|
| `make listado` | traces the flow and generates `src/magicaltree.asm` with the notes | that the listing comes from the cartridge and `src/magicaltree.notes`, not hand-edited |
| `make verify` | reassembles with `pasmo` and compares | that the listing IS the ROM, byte for byte |
| `make sanity` | splits the 16,384 bytes into code and data | that not one byte is left unassigned |
| `make test` | 39 tests | that the numbers on this site are the listing's |
| `make imagenes` | draws everything in `docs/imagenes/` from the ROM, the nine stages included | that the formats are read right |
| `make coteja_fases` | compares the nine stages with 156 openMSX dumps | zero cells different |
| `make coteja_decorados` | compares the between-stages tree and the castle with nine dumps | zero bytes different |

The check needs the dumps first: `tools/omsx_fases.tcl`, one stage per run,
with the number in `work/fase.txt`. See [In the emulator](IN-THE-EMULATOR.html).
