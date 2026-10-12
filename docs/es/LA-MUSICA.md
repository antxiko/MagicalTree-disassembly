# La música

Todo lo que suena aquí sale de ejecutar el motor de sonido del cartucho (`suena_un_cuadro`, 0x7AC0, y `pide_un_sonido`, 0x7A13, que le reparte las voces; lo llama la interrupción en 0x4030) en un Z80 emulado, cuadro a cuadro y a 60 por segundo, igual que lo llama el juego. Lo que el motor escribe en el PSG pasa a sonido con un AY-3-8910 (`tools/musica.py`). Cada MP3 es la pieza entera hasta donde vuelve a empezar, más 8 segundos de la vuelta apagándose; las que no se repiten acaban donde acaba el motor.

## Cotejado con openMSX

Las escrituras al PSG se han comparado cuadro a cuadro con las de openMSX (C-BIOS MSX1 japonés). En todos los cuadros el PSG queda igual:

- la música de la fase (0x8C) entera, 962 cuadros, con su vuelta, tal como el juego la pide al empezar;
- el fin de partida (0x96), sus 291 primeros cuadros de 292;
- la pista 0x8D, sus primeros 384 cuadros, hasta que el juego pide otra cosa.

El timbre no está cotejado: es el de un AY-3-8910 de manual, no una grabación del emulador. Las sondas están en `tools/omsx_psg.tcl` y `tools/coteja_psg.py`.

## Cómo se pide una pieza

`pide_un_sonido` recibe el número en A. Por debajo de 0x8C es un efecto; de ahí en adelante usa más voces. Las voces ocupan 11 bytes cada una desde 0xE010 y 0xE031 guarda la copia del registro 7 del PSG (el mezclador), que el motor vuelca en cada cuadro y que el arranque deja en 0xB8. Las pistas de la sección «de la tabla» están en la tabla de pistas pero ninguna rutina las pide con un `ld a`. Las 0x97 y 0x98 también, y se omiten por ser muy largas y casi sin notas.

## Las músicas

**La música de la fase** (0x8C)

Lo pide `arranca_la_fase` (0x7434) y `espera_a_que_pare_el_sonido` (0x416B): una de las dos, según el sentido de la fase; dura 16,0 s y vuelve a empezar en el segundo 8,0.

<audio controls preload="none" src="../audio/musica_8C.mp3?v=0c2bbbff"></audio>

**El sonido del final** (0x93)

Lo pide la rutina de 0x41A0, cuando no quedan vidas; dura 2,4 s.

<audio controls preload="none" src="../audio/musica_93.mp3?v=5f21d513"></audio>

**El fin de partida** (0x96)

Lo pide `fin_de_partida` (0x4214); dura 4,9 s.

<audio controls preload="none" src="../audio/musica_96.mp3?v=24d78edb"></audio>

**La pieza del 0x7400** (0x90)

Lo pide `L_7400`; dura 5,4 s.

<audio controls preload="none" src="../audio/musica_90.mp3?v=a899a48f"></audio>

**Una pista de la tabla** (0x8D)

Lo pide ninguna llamada directa: está en la tabla de pistas; dura 3,8 s y vuelve a empezar en el segundo 0,0.

<audio controls preload="none" src="../audio/musica_8D.mp3?v=6f2de7a4"></audio>

**Otra pista de la tabla** (0x8E)

Lo pide ninguna llamada directa: está en la tabla de pistas; dura 7,5 s.

<audio controls preload="none" src="../audio/musica_8E.mp3?v=5b79a043"></audio>

**Una tercera pista de la tabla** (0x8F)

Lo pide ninguna llamada directa: está en la tabla de pistas; dura 5,4 s.

<audio controls preload="none" src="../audio/musica_8F.mp3?v=1277bc48"></audio>

**Una cuarta pista de la tabla** (0x91)

Lo pide ninguna llamada directa: está en la tabla de pistas; dura 5,4 s.

<audio controls preload="none" src="../audio/musica_91.mp3?v=d743bb80"></audio>

**Una quinta pista de la tabla** (0x92)

Lo pide ninguna llamada directa: está en la tabla de pistas; dura 5,4 s.

<audio controls preload="none" src="../audio/musica_92.mp3?v=7436b954"></audio>

**Una sexta pista de la tabla** (0x94)

Lo pide ninguna llamada directa: está en la tabla de pistas; dura 4,9 s.

<audio controls preload="none" src="../audio/musica_94.mp3?v=586f32d2"></audio>

**Una séptima pista de la tabla** (0x95)

Lo pide ninguna llamada directa: está en la tabla de pistas; dura 4,9 s.

<audio controls preload="none" src="../audio/musica_95.mp3?v=3c036146"></audio>
