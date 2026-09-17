#!/usr/bin/env python3
"""Rehace la VRAM de Magical Tree y la DIBUJA. Aqui no hay ni una captura.

Cada imagen sale de correr en Python los MISMOS pasos que da el Z80, y cada
paso cita la direccion de donde sale. Si el dibujo esta mal, lo que esta mal es
la lectura del cartucho, no el dibujo: por eso sirve de comprobacion.

EL REPARTO DE LA VRAM, QUE VA AL REVES DE LO QUE PARECE
------------------------------------------------------
Los ocho registros los baja 0x44EE leyendolos de 0x44FF, que vale
`02 E2 0E 7F 07 76 03 E1`. En SCREEN 2 el R3 y el R4 no son direcciones sino
BASE y MASCARA, y ahi esta la trampa:

    R0 = 0x02   SCREEN 2
    R1 = 0xE2   16K, pantalla encendida, interrupcion, sprites de 16x16
    R2 = 0x0E   tabla de NOMBRES en 0x0E * 0x400 = 0x3800
    R3 = 0x7F   COLOR: el bit 7 esta a CERO, o sea base 0x0000 (y mascara 0x7F)
    R4 = 0x07   PATRONES: el bit 2 esta puesto, o sea base 0x2000 (mascara 3)
    R5 = 0x76   atributos de sprite en 0x76 * 0x80 = 0x3B00
    R6 = 0x03   patrones de SPRITE en 0x03 * 0x800 = 0x1800
    R7 = 0xE1   tinta 14 sobre borde 1

O sea: **color en 0x0000 y patrones en 0x2000**, no al reves. Se comprueba solo
con la fuente: 0x447E rellena 384 bytes de 0x0180 con 0xF0 -tinta 15 sobre
fondo transparente, que es un byte de COLOR- y suelta los dibujos de la fuente
0x2000 mas alla, en 0x2180. Y 0x0180 es la celda 48, o sea que el primer dibujo
de la fuente cae en el patron 0x30, que es el codigo ASCII del '0': por eso los
rotulos de este cartucho guardan el texto en claro.

LO QUE SALE
-----------
    logotipo.png      el KONAMI que sale antes del titulo, montado como lo
                      monta 0x48D0: tres celdas, once y doce
    fuente.png        los 43 dibujos de 0x45B8, con su reparto ASCII
    titulo-tiles.png  los 32 patrones del rotulo grande (0x47D2), ya coloreados
    tiles-fase.png    la hoja de patrones de la fase, tal como queda en la VRAM
    decorado-A.png    las 32 columnas del primer decorado (tabla de 0x76CE)
    decorado-B.png    las del segundo (tabla de 0x778A), el de la novena tanda
    sprites.png       los patrones de sprite de 0x1800
    sprites-espejo.png   los de 0x1940, que el cartucho fabrica DANDO LA VUELTA
                         a los de arriba al arrancar

Uso: graficos.py <rom> <org> <salida>
"""
import os
import struct
import sys
import zlib

ORG = 0x4000

# Los quince colores del TMS9918, mas el transparente.
PALETA = [
    (0, 0, 0), (0, 0, 0), (33, 200, 66), (94, 220, 120),
    (84, 85, 237), (125, 118, 252), (212, 82, 77), (66, 235, 245),
    (252, 85, 84), (255, 121, 120), (212, 193, 84), (230, 206, 128),
    (33, 176, 59), (201, 91, 186), (204, 204, 204), (255, 255, 255),
]

# Los ocho valores que 0x44EE baja al VDP desde 0x44FF.
VDP = [0x02, 0xE2, 0x0E, 0x7F, 0x07, 0x76, 0x03, 0xE1]
NOMBRES = VDP[2] * 0x400          # 0x3800
COLOR = (VDP[3] & 0x80) << 6      # 0x0000
PATRONES = (VDP[4] & 0x04) << 11  # 0x2000
SPRITES = VDP[6] * 0x800          # 0x1800


# ----------------------------------------------------------------- PNG
def png(w, h, px, fn):
    raw = b"".join(b"\0" + bytes(px[y * w * 3:(y + 1) * w * 3]) for y in range(h))

    def chunk(t, d):
        return (struct.pack(">I", len(d)) + t + d
                + struct.pack(">I", zlib.crc32(t + d) & 0xFFFFFFFF))
    open(fn, "wb").write(b"\x89PNG\r\n\x1a\n"
                         + chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 2, 0, 0, 0))
                         + chunk(b"IDAT", zlib.compress(raw, 9)) + chunk(b"IEND", b""))


def lienzo(w, h, c=(24, 24, 24)):
    return bytearray(bytes(c) * (w * h))


def punto(px, w, x, y, c):
    i = (y * w + x) * 3
    px[i], px[i + 1], px[i + 2] = c


# ------------------------------------------------- las maquinas del cartucho
def descomprime_en(vram, rom, ini, destino=None, mascara=None):
    """El descompresor de 0x449B, escribiendo en la VRAM de verdad.

    Con `destino` a None lee los dos bytes de cabecera, que es la puerta de
    0x449B; con destino dado entra por 0x449F. `mascara` activa la variante de
    0x612C: donde el nibble alto vale 3 se pone el alto de la mascara, y donde
    el bajo vale 3, el bajo. Es lo que hace que cada tanda tenga otro color.
    """
    p = ini - ORG
    de = destino
    if de is None:
        de = rom[p] | (rom[p + 1] << 8)
        p += 2
    alto = (mascara & 0xF0) if mascara is not None else None
    bajo = (mascara & 0x0F) if mascara is not None else None

    def escribe(b):
        nonlocal de
        if mascara is not None:
            if b & 0xF0 == 0x30:
                b = alto | (b & 0x0F)
            if b & 0x0F == 0x03:
                b = (b & 0xF0) | bajo
        vram[de & 0x3FFF] = b
        de += 1

    while True:
        ctrl = rom[p]
        p += 1
        cuenta = ctrl & 0x7F
        if cuenta == 0:
            if ctrl == 0x00:
                return ORG + p
            de = rom[p] | (rom[p + 1] << 8)   # 0x80: otro destino
            p += 2
            continue
        if ctrl & 0x80:
            for i in range(cuenta):
                escribe(rom[p + i])
            p += cuenta
        else:
            for _ in range(cuenta):
                escribe(rom[p])
            p += 1


def vuelca(vram, rom, ini, destino, n):
    """vuelca_bloque de 0x4441: n bytes de la ROM a la VRAM, tal cual."""
    for i in range(n):
        vram[(destino + i) & 0x3FFF] = rom[ini - ORG + i]


def rellena(vram, destino, n, valor):
    for i in range(n):
        vram[(destino + i) & 0x3FFF] = valor


def rellena_una_franja(vram, rom, de, a):
    """0x4488: 384 bytes de color y la fuente 0x2000 mas alla."""
    rellena(vram, de, 0x180, a)
    vuelca(vram, rom, 0x45B8, de + 0x2000, 0x180)


def duplica_las_dos_tablas(vram):
    """0x4473: el primer tercio de patrones y el de color, a los otros dos."""
    for base in (PATRONES, COLOR):
        vram[base + 0x800:base + 0x1000] = vram[base:base + 0x800]
        vram[base + 0x1000:base + 0x1800] = vram[base:base + 0x800]


def espeja(rom):
    """El bucle de 0x60F0: coge los sprites de 0x5BCD y los DA LA VUELTA.

    Diez tandas de 0x20 bytes, o sea diez sprites de 16x16. De cada fila junta
    el byte izquierdo y el derecho en un registro de dieciseis bits, lo corre
    a la izquierda dieciseis veces y va metiendo el bit que sale por la
    izquierda de otro registro de dieciseis bits repartido en dos bytes de la
    salida. El primer bit que entra acaba el ultimo: la fila sale DEL REVES,
    que es un espejo horizontal y no un giro.

    Tres cosas lo demuestran, y las tres estan en tests/test_espejo.py:
    aplicarla dos veces devuelve el original clavado; los bits encendidos son
    los mismos antes y despues; y 0x665B suma 0x28 al numero de patron cuando
    el personaje mira al otro lado, que son los cuarenta patrones -320 bytes-
    que separan 0x1800 de 0x1940, donde queda esta copia.
    """
    sal = bytearray(0x140)
    for tanda in range(10):
        # El paso entre tandas es 0x20 y no 0x10: el bucle interior ya avanza
        # dieciseis con sus `inc hl / inc de / inc ix`, y al salir 0x6110 suma
        # otros dieciseis. Con el paso de 0x10 la salida sale corrida UNA tanda
        # -se caza contando los bits encendidos, que girar no cambia-, y ademas
        # los 0x20 x 10 son los 320 bytes justos del bloque, de 0x5BCD a 0x5D0D.
        b_de = 0x5BCD + tanda * 0x20
        b_hl = 0x5BDD + tanda * 0x20
        b_ix = tanda * 0x20
        for k in range(0x10):
            hl = (rom[b_de + k - ORG] << 8) | rom[b_hl + k - ORG]
            i0, i1 = b_ix + k, b_ix + k + 0x10
            for _ in range(0x10):
                hl <<= 1
                acarreo = (hl >> 16) & 1
                hl &= 0xFFFF
                # los dos `rr` seguidos son UN registro de 16 bits: lo que sale
                # por la derecha de (ix+0) entra por la izquierda de (ix+0x10)
                nuevo0 = ((sal[i0] >> 1) | (acarreo << 7)) & 0xFF
                sale0 = sal[i0] & 1
                sal[i0] = nuevo0
                sal[i1] = ((sal[i1] >> 1) | (sale0 << 7)) & 0xFF
    return sal


# ------------------------------------------------------- montar cada pantalla
def vram_de_la_fase(rom, mascara):
    """Lo que hace monta_los_graficos (0x60C9) mas la fuente de 0x447E."""
    v = bytearray(0x4000)
    rellena_una_franja(v, rom, 0x0180, 0xF0)      # 0x447E
    duplica_las_dos_tablas(v)                     # 0x4473
    descomprime_en(v, rom, 0x5445)                # 0x60C9
    descomprime_en(v, rom, 0x5937, mascara=mascara)   # 0x60CF, con la mascara
    duplica_las_dos_tablas(v)                     # 0x60D5
    vuelca(v, rom, 0x5BCD, 0x1800, 0x140)         # 0x60D8
    sal = espeja(rom)
    for i, b in enumerate(sal):
        v[0x1940 + i] = b                         # 0x6119
    descomprime_en(v, rom, 0x5D0D)                # 0x6125
    return v


def vram_del_titulo(rom):
    """Lo que hace carga_los_graficos_del_titulo (0x425A)."""
    v = bytearray(0x4000)
    rellena_una_franja(v, rom, 0x0180, 0xF0)      # 0x425A -> 0x447E
    duplica_las_dos_tablas(v)
    rellena_una_franja(v, rom, 0x1600, 0x70)      # 0x425D: el tercer tercio
    descomprime_en(v, rom, 0x47D2)                # 0x4265: los patrones del titulo
    de = 0x0600                                   # 0x426B: dieciseis veces
    for _ in range(0x10):
        descomprime_en(v, rom, 0x4894, destino=de)
        de += 0x10
    return v


# --------------------------------------------------------------- dibujar
def pinta_celda(px, w, x0, y0, patron, color, esc=1):
    for f in range(8):
        p, c = patron[f], color[f]
        tinta, fondo = PALETA[c >> 4], PALETA[c & 0x0F]
        for b in range(8):
            col = tinta if p & (0x80 >> b) else fondo
            for dy in range(esc):
                for dx in range(esc):
                    punto(px, w, x0 + b * esc + dx, y0 + f * esc + dy, col)


def hoja(v, tercio, fn, titulo_cols=16, esc=2):
    """Los 256 patrones de un tercio, con su color."""
    filas = 256 // titulo_cols
    w, h = titulo_cols * 8 * esc, filas * 8 * esc
    px = lienzo(w, h)
    for t in range(256):
        pa = v[PATRONES + tercio * 0x800 + t * 8: PATRONES + tercio * 0x800 + t * 8 + 8]
        co = v[COLOR + tercio * 0x800 + t * 8: COLOR + tercio * 0x800 + t * 8 + 8]
        pinta_celda(px, w, (t % titulo_cols) * 8 * esc, (t // titulo_cols) * 8 * esc,
                    pa, co, esc)
    png(w, h, px, fn)


def rango(v, t0, n, fn, cols=8, esc=4):
    filas = (n + cols - 1) // cols
    w, h = cols * 8 * esc, filas * 8 * esc
    px = lienzo(w, h)
    for i in range(n):
        t = t0 + i
        pa = v[PATRONES + t * 8: PATRONES + t * 8 + 8]
        co = v[COLOR + t * 8: COLOR + t * 8 + 8]
        pinta_celda(px, w, (i % cols) * 8 * esc, (i // cols) * 8 * esc, pa, co, esc)
    png(w, h, px, fn)


def columna(rom, p):
    """Una columna del decorado: el interprete de 0x7629, veinte celdas."""
    out = []
    while True:
        c = rom[p - ORG]
        n = c & 0x7F
        if n == 0:
            return out
        p += 1
        if c & 0x80:
            out += [rom[p - ORG + i] for i in range(n)]
            p += n
        else:
            out += [rom[p - ORG]] * n
            p += 1


def decorado(rom, v, tabla, fn, esc=2):
    """Las 32 columnas de veinte celdas que 0x7629 pinta desde la fila 3."""
    cols = []
    for i in range(32):
        a = tabla + 2 * i
        cols.append(columna(rom, rom[a - ORG] | (rom[a + 1 - ORG] << 8)))
    w, h = 32 * 8 * esc, 20 * 8 * esc
    px = lienzo(w, h)
    for x, col in enumerate(cols):
        for y, t in enumerate(col):
            # la fila 3 + y de la pantalla cae en el tercio que le toque
            tercio = (3 + y) // 8
            base_p = PATRONES + tercio * 0x800 + t * 8
            base_c = COLOR + tercio * 0x800 + t * 8
            pinta_celda(px, w, x * 8 * esc, y * 8 * esc,
                        v[base_p:base_p + 8], v[base_c:base_c + 8], esc)
    png(w, h, px, fn)


def sprites(v, base, fn, n=32, cols=8, esc=3):
    """Patrones de sprite de 16x16: cuatro cuartos en el orden del VDP."""
    filas = (n + cols - 1) // cols
    w, h = cols * 16 * esc, filas * 16 * esc
    px = lienzo(w, h)
    for i in range(n):
        d = base + i * 32
        x0, y0 = (i % cols) * 16 * esc, (i // cols) * 16 * esc
        for cuarto in range(4):
            cx, cy = (cuarto // 2) * 8 * esc, (cuarto % 2) * 8 * esc
            pat = v[d + cuarto * 8: d + cuarto * 8 + 8]
            pinta_celda(px, w, x0 + cx, y0 + cy, pat, b"\xf0" * 8, esc)
    png(w, h, px, fn)


def logotipo(rom, fn, esc=6):
    """El logotipo de KONAMI, montado como lo monta 0x48D0.

    0x48AA suelta los veintiseis dibujos en 0x2300 -el patron 0x60- y 0x48B3
    les pone el color. Luego se pintan CORRELATIVOS (el `inc a` de 0x48EF) en
    tres filas seguidas: tres celdas, once y doce. Puesto asi se lee.
    """
    v = bytearray(0x4000)
    descomprime_en(v, rom, 0x48F9, destino=0x2300)   # 0x48AA
    rellena(v, 0x0300, 0xD0, 0xF0)                   # 0x48B3
    filas = [(0x60, 3), (0x63, 11), (0x6E, 12)]
    w, h = 12 * 8 * esc, 3 * 8 * esc
    px = lienzo(w, h)
    for r, (t0, n) in enumerate(filas):
        for i in range(n):
            tl = t0 + i
            pinta_celda(px, w, i * 8 * esc, r * 8 * esc,
                        v[PATRONES + tl * 8:PATRONES + tl * 8 + 8],
                        v[COLOR + tl * 8:COLOR + tl * 8 + 8], esc)
    png(w, h, px, fn)


def main():
    rom = open(sys.argv[1], "rb").read()
    global ORG
    ORG = int(sys.argv[2], 0)
    sal = sys.argv[3]
    os.makedirs(sal, exist_ok=True)

    # La mascara de color de la primera tanda sale de 0x741F, que 0x73F9
    # indexa con tres bits del contador de tandas.
    mascara = rom[0x741F - ORG]

    v = vram_de_la_fase(rom, mascara)
    hoja(v, 0, os.path.join(sal, "tiles-fase.png"))
    rango(v, 0x30, 43, os.path.join(sal, "fuente.png"))
    decorado(rom, v, 0x76CE, os.path.join(sal, "decorado-A.png"))
    decorado(rom, v, 0x778A, os.path.join(sal, "decorado-B.png"))
    sprites(v, 0x1800, os.path.join(sal, "sprites.png"), n=10)
    sprites(v, 0x1940, os.path.join(sal, "sprites-espejo.png"), n=10)

    logotipo(rom, os.path.join(sal, "logotipo.png"))

    t = vram_del_titulo(rom)
    rango(t, 0xC0, 32, os.path.join(sal, "titulo-tiles.png"))

    print(f"mascara de color de la primera tanda: 0x{mascara:02X} (de 0x741F)")
    for f in sorted(os.listdir(sal)):
        print("  ", os.path.join(sal, f))


if __name__ == "__main__":
    main()
