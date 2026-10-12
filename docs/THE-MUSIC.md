# The music

Everything you hear here comes from running the cartridge's own sound engine (`suena_un_cuadro`, 0x7AC0, and `pide_un_sonido`, 0x7A13, which hands it the voices; the interrupt calls it at 0x4030) on an emulated Z80, frame by frame at 60 per second, just as the game calls it. What the engine writes to the PSG is turned into sound with an AY-3-8910 (`tools/musica.py`). Each MP3 is the whole piece up to where it starts again, plus 8 seconds of the repeat fading out; those that do not repeat end where the engine ends.

## Checked against openMSX

The PSG writes have been compared frame by frame with those of openMSX (C-BIOS MSX1 japonés). In every frame the PSG ends up the same:

- the stage tune (0x8C), whole, 962 frames, with its repeat, just as the game asks for it at the start;
- game over (0x96), its first 291 frames of 292;
- track 0x8D, its first 384 frames, up to where the game asks for something else.

The timbre is not checked: it is a textbook AY-3-8910, not a recording of the emulator. The probes are `tools/omsx_psg.tcl` and `tools/coteja_psg.py`.

## How a piece is asked for

`pide_un_sonido` takes the number in A. Below 0x8C it is an effect; from there up it uses more voices. The voices take 11 bytes each from 0xE010 and 0xE031 holds the copy of PSG register 7 (the mixer), which the engine writes every frame and start-up leaves at 0xB8. The tracks marked «in the table» are in the track table but no routine asks for them with an `ld a`. So are 0x97 and 0x98, left out for being very long and nearly without notes.

## The tunes

**The stage tune** (0x8C)

Asked for by `arranca_la_fase` (0x7434) y `espera_a_que_pare_el_sonido` (0x416B): una de las dos, según el sentido de la fase; lasts 16.0 s and starts again at second 8.0.

<audio controls preload="none" src="audio/musica_8C.mp3?v=0c2bbbff"></audio>

**The ending sound** (0x93)

Asked for by la rutina de 0x41A0, cuando no quedan vidas; lasts 2.4 s.

<audio controls preload="none" src="audio/musica_93.mp3?v=5f21d513"></audio>

**Game over** (0x96)

Asked for by `fin_de_partida` (0x4214); lasts 4.9 s.

<audio controls preload="none" src="audio/musica_96.mp3?v=24d78edb"></audio>

**The tune at 0x7400** (0x90)

Asked for by `L_7400`; lasts 5.4 s.

<audio controls preload="none" src="audio/musica_90.mp3?v=a899a48f"></audio>

**A track in the table** (0x8D)

Asked for by ninguna llamada directa: está en la tabla de pistas; lasts 3.8 s and starts again at second 0.0.

<audio controls preload="none" src="audio/musica_8D.mp3?v=6f2de7a4"></audio>

**Another track in the table** (0x8E)

Asked for by ninguna llamada directa: está en la tabla de pistas; lasts 7.5 s.

<audio controls preload="none" src="audio/musica_8E.mp3?v=5b79a043"></audio>

**A third track in the table** (0x8F)

Asked for by ninguna llamada directa: está en la tabla de pistas; lasts 5.4 s.

<audio controls preload="none" src="audio/musica_8F.mp3?v=1277bc48"></audio>

**A fourth track in the table** (0x91)

Asked for by ninguna llamada directa: está en la tabla de pistas; lasts 5.4 s.

<audio controls preload="none" src="audio/musica_91.mp3?v=d743bb80"></audio>

**A fifth track in the table** (0x92)

Asked for by ninguna llamada directa: está en la tabla de pistas; lasts 5.4 s.

<audio controls preload="none" src="audio/musica_92.mp3?v=7436b954"></audio>

**A sixth track in the table** (0x94)

Asked for by ninguna llamada directa: está en la tabla de pistas; lasts 4.9 s.

<audio controls preload="none" src="audio/musica_94.mp3?v=586f32d2"></audio>

**A seventh track in the table** (0x95)

Asked for by ninguna llamada directa: está en la tabla de pistas; lasts 4.9 s.

<audio controls preload="none" src="audio/musica_95.mp3?v=3c036146"></audio>
