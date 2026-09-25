#!/usr/bin/env python3
"""Coteja el arbol de tools/arbol.py contra openMSX, fase a fase.

Los volcados los hace tools/omsx_fases.tcl: cada fase forzada al montarse,
subida sin jugarla de treinta en treinta pasos, con RAM y VRAM volcadas en
cada tanda. Aqui se mira, en cada volcado:

  - la tabla de nombres, en la banda util (filas 3 a 23): celda a celda;
  - los cuarenta objetos de 0xE132, hueco a hueco;
  - el guion de la fase en la VRAM, desde 0x3B80;
  - las tablas de color y de patrones, contra las que monta graficos.py con
    la mascara de esa fase.

Sale con 1 si algo difiere, o si falta algun volcado.

Uso: coteja_fases.py <rom> <carpeta de volcados>
"""

import glob
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import arbol as A               # noqa: E402
import graficos as G            # noqa: E402


def main():
    rom = open(sys.argv[1], "rb").read()
    carpeta = sys.argv[2]
    r = A.Rom(rom)
    malo = False
    total_v = total_c = 0
    for fase in range(9):
        fn = sorted(glob.glob(os.path.join(carpeta, "fase%d_p*.vram" % (fase + 1))))
        if not fn:
            print(f"fase {fase + 1}: SIN VOLCADOS (tools/omsx_fases.tcl)")
            malo = True
            continue
        fin = A.paso_final(r, fase)
        vistas = {t: (nt, o) for t, nt, o in A.pantallas(r, fase, fin)}
        guion = bytes(b for e in A.guion(r, fase) for b in e)
        v_fase = G.vram_de_la_fase(rom, A.mascara_de_la_fase(r, fase))
        celdas = objetos = otros = 0
        for f in fn:
            paso = int(f[-9:-5])
            vram = open(f, "rb").read()
            ram = open(f[:-5] + ".ram", "rb").read()
            nt, obj = vistas[paso]
            celdas += sum(vram[0x3800 + i] != nt[i] for i in range(96, 768))
            real = [None if ram[0x132 + 3 * k] == 0xD0 else
                    tuple(ram[0x132 + 3 * k:0x135 + 3 * k]) for k in range(40)]
            objetos += sum(a != b for a, b in zip(real, obj))
            otros += vram[0x3B80:0x3B80 + len(guion)] != guion
            otros += vram[G.COLOR:G.COLOR + 0x1800] != v_fase[G.COLOR:G.COLOR + 0x1800]
            otros += vram[G.PATRONES:G.PATRONES + 0x1800] != v_fase[G.PATRONES:G.PATRONES + 0x1800]
        total_v += len(fn)
        total_c += len(fn) * 672
        estado = "OK" if celdas == objetos == otros == 0 else "DIFIERE"
        print(f"fase {fase + 1}: {len(fn)} volcados hasta el paso {paso} de {fin}: "
              f"{celdas} celdas, {objetos} objetos y {otros} tablas distintas  {estado}")
        malo |= estado != "OK" or paso != fin
    print(f"{total_v} volcados, {total_c} celdas de la banda cotejadas")
    sys.exit(1 if malo else 0)


if __name__ == "__main__":
    main()
