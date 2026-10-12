#!/usr/bin/env python3
"""La musica del cartucho, ejecutando su motor de sonido (ver motor_musica.py).

Pide el sonido con `pide_un_sonido` (0x7A13, A = numero) y corre
`suena_un_cuadro` (0x7AC0), que la interrupcion llama cada cuadro (0x4030). Tres
voces de 11 bytes desde 0xE010; la copia del registro 7 del PSG, en 0xE031.
Uso:  musica.py registros 0x8C [cuadros] | mp3 0x8C f.mp3 | todas docs/audio
      musica.py barrido 0x80 0xFF | emu
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import motor_musica  # noqa: E402
from motor_musica import P  # noqa: E402

TABLA = "ninguna llamada directa: está en la tabla de pistas"

PIEZAS = [
    P(0x8C, "La música de la fase", "The stage tune",
      "`arranca_la_fase` (0x7434) y `espera_a_que_pare_el_sonido` (0x416B): "
      "una de las dos, según el sentido de la fase"),
    P(0x93, "El sonido del final", "The ending sound",
      "la rutina de 0x41A0, cuando no quedan vidas"),
    P(0x96, "El fin de partida", "Game over", "`fin_de_partida` (0x4214)"),
    P(0x90, "La pieza del 0x7400", "The tune at 0x7400", "`L_7400`"),
    P(0x8D, "Una pista de la tabla", "A track in the table", TABLA),
    P(0x8E, "Otra pista de la tabla", "Another track in the table", TABLA),
    P(0x8F, "Una tercera pista de la tabla", "A third track in the table",
      TABLA),
    P(0x91, "Una cuarta pista de la tabla", "A fourth track in the table",
      TABLA),
    P(0x92, "Una quinta pista de la tabla", "A fifth track in the table",
      TABLA),
    P(0x94, "Una sexta pista de la tabla", "A sixth track in the table",
      TABLA),
    P(0x95, "Una séptima pista de la tabla", "A seventh track in the table",
      TABLA),
]

PAGINA = motor_musica.pagina_basica(
    "`suena_un_cuadro`, 0x7AC0, y `pide_un_sonido`, 0x7A13, que le reparte "
    "las voces; lo llama la interrupción en 0x4030",
    "`suena_un_cuadro`, 0x7AC0, and `pide_un_sonido`, 0x7A13, which hands it "
    "the voices; the interrupt calls it at 0x4030",
    "C-BIOS MSX1 japonés",
    [("la música de la fase (0x8C) entera, 962 cuadros, con su vuelta, tal "
      "como el juego la pide al empezar",
      "the stage tune (0x8C), whole, 962 frames, with its repeat, just as the "
      "game asks for it at the start"),
     ("el fin de partida (0x96), sus 291 primeros cuadros de 292",
      "game over (0x96), its first 291 frames of 292"),
     ("la pista 0x8D, sus primeros 384 cuadros, hasta que el juego pide "
      "otra cosa",
      "track 0x8D, its first 384 frames, up to where the game asks for "
      "something else")],
    [("Cómo se pide una pieza",
      "`pide_un_sonido` recibe el número en A. Por debajo de 0x8C es un "
      "efecto; de ahí en adelante usa más voces. Las voces ocupan 11 bytes "
      "cada una desde 0xE010 y 0xE031 guarda la copia del registro 7 del PSG "
      "(el mezclador), que el motor vuelca en cada cuadro y que el arranque "
      "deja en 0xB8. Las pistas de la sección «de la tabla» están en la "
      "tabla de pistas pero ninguna rutina las pide con un `ld a`. Las 0x97 y "
      "0x98 también, y se omiten por ser muy largas y casi sin notas.",
      "How a piece is asked for",
      "`pide_un_sonido` takes the number in A. Below 0x8C it is an effect; "
      "from there up it uses more voices. The voices take 11 bytes each from "
      "0xE010 and 0xE031 holds the copy of PSG register 7 (the mixer), which "
      "the engine writes every frame and start-up leaves at 0xB8. The "
      "tracks marked «in the table» are in the track table but no routine "
      "asks for them with an `ld a`. So are 0x97 and 0x98, left out for "
      "being very long and nearly without notes.")])

CFG = dict(rom="magicaltree.rom", org=0x4000, frame=0x7AC0, pide=0x7A13,
           ram=(0xE010, 0xE034), excluye=[0xE019, 0xE024, 0xE02F],
           ram0=[(0xE031, 0xB8)], hz=60, psg0={7: 0xB8}, piezas=PIEZAS,
           pagina=PAGINA, cotejado=[(0x8C, 962, 481), (0x96, 292, None)])

if __name__ == "__main__":
    sys.exit(motor_musica.main(CFG, sys.argv[1:]))
