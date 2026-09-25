# Empezar

Este repositorio contiene el desensamblado comentado de **Magical Tree** de
Konami para MSX (RC-713, 1984). No contiene el cartucho: la imagen de la ROM no
se distribuye.

## Lo que hace falta

- `pasmo` — el ensamblador que reproduce la ROM
- `python3` — las herramientas de `tools/`
- `make`
- Tu propia copia del cartucho, en la raíz y con el nombre `magicaltree.rom`

Son **16.384 bytes exactos** y su huella es:

    sha256  a3f3ad0d8f5cda0f04bf917fbd9d796e9dc66d071bd30a2fde8d06260c7ec9f7

Para comprobarla:

    make comprueba

## Reproducirlo entero

| orden | qué hace | qué demuestra |
|---|---|---|
| `make listado` | traza el flujo y genera `src/magicaltree.asm` con las notas | que el listado sale del cartucho y de `src/magicaltree.notes`, no se edita a mano |
| `make verify` | reensambla con `pasmo` y compara | que el listado ES la ROM, byte a byte |
| `make sanity` | reparte los 16.384 bytes entre código y datos | que no queda ni un byte sin asignar |
| `make test` | 39 tests | que las cifras de esta web son las del listado |
| `make imagenes` | dibuja todo lo de `docs/imagenes/` desde la ROM, las nueve fases incluidas | que los formatos están bien leídos |
| `make coteja_fases` | compara las nueve fases con 156 volcados de openMSX | cero celdas de diferencia |
| `make coteja_decorados` | compara el árbol de entre fases y el castillo con nueve volcados | cero bytes de diferencia |

El cotejo necesita antes los volcados: `tools/omsx_fases.tcl`, una fase por
arranque, con el número en `work/fase.txt`. Ver [En el emulador](EN-EL-EMULADOR.html).
