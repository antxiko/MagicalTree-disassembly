#!/usr/bin/env python3
"""Coteja el decorado de entre fases y el castillo contra openMSX.

Los volcados los hace tools/omsx_castillo.tcl: cambio1_cK (de la fase 1 a la
2, el arbol de 0x76CE) y cambio9_cK (al acabar la novena, el castillo de
0x778A). Se miran los que ya tienen las 32 columnas pintadas -(0xE250) al
final de su tabla-, y del castillo solo los que siguen en la novena tanda
(despues, 0x7545 repone los valores iniciales y la pantalla es otra). En cada
uno:

  - las filas 3 a 22 de la tabla de nombres contra graficos.monta_el_decorado,
    con las columnas del centro hacia fuera; en el castillo, con las ventanas
    que toquen segun el estado del jugador (0xE1B2): las de 0x75EE mientras
    se pinta (estado 15) y las de 0x7600 con el rotulo en el remate;
  - las tablas de color y de patrones contra graficos.vram_de_la_fase con la
    mascara que tiene el propio volcado en (0xE05D).

Sale con 1 si algo difiere o si no hay volcados.

Uso: coteja_decorados.py <rom> <carpeta de volcados>
"""

import glob
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import graficos as G            # noqa: E402

TABLAS = {"cambio1": 0x76CE, "cambio9": 0x778A}


def main():
    rom = open(sys.argv[1], "rb").read()
    malo = False
    vistos = 0
    for fn in sorted(glob.glob(os.path.join(sys.argv[2], "cambio*_c*.vram"))):
        nombre = os.path.basename(fn)[:-5]
        tabla = TABLAS.get(nombre.split("_")[0])
        vram = open(fn, "rb").read()
        ram = open(fn[:-5] + ".ram", "rb").read()
        puntero = ram[0x250] | ram[0x251] << 8
        if tabla is None or puntero != tabla + 64:
            continue                    # a medio pintar, o de otra escena
        if tabla == 0x778A and ram[0x5C] != 9:
            continue                    # tras el castillo, 0x7545 vuelve a la tanda 0
        estado = ram[0x1B2]
        v = bytearray(G.vram_de_la_fase(rom, ram[0x5D]))
        G.monta_el_decorado(rom, v, tabla)
        if tabla == 0x778A:
            if estado == 15:
                G.pinta_dos_bloques_de_3x3(v, rom, 0x75EE)
            else:
                G.pinta_dos_bloques_de_3x3(v, rom, 0x7600)
                G.pinta_rotulo(v, rom, 0x7595)
        nombres = sum(v[0x3800 + i] != vram[0x3800 + i] for i in range(96, 736))
        tablas = sum(v[i] != vram[i] for i in list(range(0, 0x1800)) +
                     list(range(0x2000, 0x3800)))
        estado_ok = nombres == 0 and tablas == 0
        malo |= not estado_ok
        vistos += 1
        print(f"{nombre}: estado {estado}, mascara 0x{ram[0x5D]:02X}: "
              f"{nombres} celdas y {tablas} bytes de tablas distintos  "
              f"{'OK' if estado_ok else 'DIFIERE'}")
    print(f"{vistos} volcados con el decorado entero")
    sys.exit(1 if malo or not vistos else 0)


if __name__ == "__main__":
    main()
