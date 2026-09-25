# Magical Tree (Konami, MSX) — a commented disassembly

*(También [en castellano](README.es.md).)*

An **RC-713** 16 KB cartridge from 1984. The listing in `src/magicaltree.asm`
reassembles the ROM **byte for byte** with `pasmo`, and every one of its
16,384 bytes is accounted for: **8,537 of code and 7,847 of data**. That is
**628 routines, none below 10% commented**, and the density is **47.4%**.

The tree's nine stages are drawn from the ROM, with each stage's script and
the cartridge's scenery step rewritten in Python, and checked against openMSX:
**156 dumps, 104,832 cells, zero different**.

The ROM is not distributed.

- Website: https://antxiko.github.io/MagicalTree-disassembly/
- Getting started: [docs/GETTING-STARTED.md](docs/GETTING-STARTED.md)
- Legal notice: [LEGAL-NOTICE.md](LEGAL-NOTICE.md)
