# Findings

1. **The stage script lives in VRAM.** `0x52BB` uploads it to `0x3B80`,
   behind the sprite attributes, and the scenery step reads it back from there
   with `lee_de_vram` as you climb.
2. **Pieces with bit 7 do not erase** the row they leave when moving down
   (`0x68CC`). Hence the spiders' threads and the ground ladder, which reaches
   all the way to its upper section.
3. **Spiders are kept apart.** Type `0xE0` entries go to three records with a
   16-bit row, drawn while they are between −16 and 191 (`0x6C8E`) and erased
   when they leave (`0x6D41`, with a zero dragged along by `lddr`). If no
   record is free, the spider stays as one more object (`0x682C`).
4. **The screen doubles as the map**: `0x61A3`, `0x6465`, `0x6251`, `0x6EB4`
   and `0x7167` ask VRAM what another game would keep in RAM.
5. **Randomness comes from the R register**: nine `ld a,r`.
6. **Nine skies.** The first stage's mask comes from `0x51CE` and not from
   `0x741F`; with the table's first value, `0x11`, the check drifts by 1,809
   bytes of colour.
7. **Piece group `0x16` reads itself.** It closes all nine scripts, declares
   sixteen entries and has fifteen: the sixteenth is the first two bytes of the
   group table. It goes unnoticed because the `0xFF` that ends the climb comes
   first.
8. **Two players, 32 bytes.** Scene 13 (`0x41CF`) swaps the 32 bytes at
   `0xE050` with the ones at `0xE080`: the player in turn is always in the same
   place.
9. **Binary to BCD without dividing.** `0x66F5` doubles the result with
   `adc a,a / daa` for each bit.
10. **The same code as Circus Charlie.** The decompressor's fourteen-byte
    signature, the twelve bytes of the chromatic scale and the extra life rule
    are the same in the RC-712.
11. **Ten mirrored sprites.** `0x60C9` flips the 320 bytes at `0x5BCD` and
    leaves them at `0x1940`.
12. **Two swapped comments** at `0x52F1` and `0x52F3`: the first loads the
    pointer's high byte and the second the entry count.
