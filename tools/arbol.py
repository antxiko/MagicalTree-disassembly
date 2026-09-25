#!/usr/bin/env python3
"""EL ARBOL DE CADA FASE, entero, dibujado desde las tablas del cartucho.

Aqui no se ejecuta el cartucho ni hay capturas: se leen sus tablas y se hacen,
en Python, los MISMOS pasos que da el Z80 para subir el arbol. Cotejado contra
openMSX en tools/coteja_fases.py, con los volcados de tools/omsx_fases.tcl.

LA CADENA, TAL COMO LA HACE EL JUEGO
------------------------------------
1. EL GUION DE LA FASE. 0x52BB indexa con la tanda de (0xE05C) la tabla de
   0x4E1B, que apunta a una tira de numeros de trozo (0x4D7B). Cada trozo sale
   de la tabla de 0x4D30 -puntero y numero de tiras- y cada tira da TRES
   bytes: si su primer byte no es 0xFF, van empaquetados en dos (los tres
   bits de abajo, el byte siguiente, y los cinco de arriba); si lo es, van en
   crudo. El resultado se sube a la VRAM, a 0x3B80, detras de la tabla de
   atributos de los sprites: es la lista de objetos de la fase, entradas de
   tres bytes [pasos desde la anterior, tipo, x]. El trozo 0x16 cierra el
   guion; la entrada con el tipo 0xFF es el final de la subida.

2. EL PASO DEL DECORADO. Cada vez que el jugador sube una celda, 0x6749 cuenta
   un paso y, cuando la cuenta llega a los pasos de la siguiente entrada, la
   saca de la lista -y detras, las que tengan cero pasos- a uno de los
   cuarenta huecos de 0xE132 [y, x, tipo], a y = 0xE8. Las de tipo 0xE0 son
   ARANAS y van a otra lista, las tres fichas de 0xE1DE, con la y en 16 bits;
   si las tres estan ocupadas, la arana se queda en los cuarenta como un
   objeto mas (0x682C).

3. EL MOVIMIENTO. 0x6889 baja cada objeto ocho pixeles, BORRA la fila que deja
   -solo si el tipo NO lleva el bit 7 (0x68CC)- y lo repinta si no es de los
   especiales (0xC0 y arriba); despues 0x68F8 repinta ENCIMA los que llevan el
   bit 6. Luego 0x6C32 baja las tres fichas y las pinta mientras su y este
   entre -16 y 191 (0x6C8E); al salir, 0x6D41 las borra.

   Lo del bit 7 es lo que da forma al arbol: las piezas que no borran dejan su
   primera fila detras al bajar. Asi se alarga el hilo de las aranas y asi la
   escalera del suelo sube hasta su tramo de arriba.

4. LAS PIEZAS. El tipo elige una de cuatro tablas (0x4A0E): bit 7 a cero,
   0x5130; con el bit 5, 0x5188; con el 6, 0x5170; y si no, 0x5146. Cada pieza
   trae sus filas y su ancho, y 0x49B8 las pinta fila a fila saltandose las
   que caen fuera de la banda util (0x18..0xBF). Con siete o mas de ancho, la
   fila viene comprimida en el mismo lenguaje del descompresor (0x449F).

La tira de cada fase es la fila 12 de la pantalla en cada paso, desde el
paso 26 -las veintiseis pasadas de 0x5363 que montan la primera pantalla-
hasta el paso de la entrada 0xFF.

Uso: arbol.py <rom> <org> <carpeta destino>
"""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import graficos as G            # noqa: E402

ORG = 0x4000

# El tronco, en las columnas 14 a 17 de la pantalla vacia: lo que hay antes de
# que el guion ponga nada, y lo que las piezas estrechas dejan sin tocar.
TRONCO = {14: 0x86, 15: 0x88, 16: 0x89, 17: 0x8A}
VACIO = 0x03

# La fila de la pantalla que se va apilando para hacer la tira.
FILA = 12
PRIMER_PASO = 26                # 0x537D: veintiseis pasadas


class Rom:
    def __init__(self, rom):
        self.rom = rom

    def b(self, a):
        return self.rom[a - ORG]

    def w(self, a):
        return self.b(a) | self.b(a + 1) << 8


def mascara_de_la_fase(r, fase):
    """(0xE05D). La primera tanda la trae de los valores iniciales (0x51CE);
    las demas, 0x73F9 la saca de la tabla de 0x741F con tres bits de la tanda."""
    if fase == 0:
        return r.b(0x51CE)
    return r.b(0x741F + (fase & 7))


def guion(r, fase):
    """La lista de 0x3B80 que monta 0x52BB, en entradas de tres bytes."""
    sal = []
    g = r.w(0x4E1B + 2 * fase)
    while True:
        trozo = r.b(g)
        e = 0x4D30 + 3 * trozo
        p, n = r.w(e), r.b(e + 2)
        for _ in range(n):
            x = r.b(p)
            if x == 0xFF:                       # tres celdas en crudo
                sal += [r.b(p + 1), r.b(p + 2), r.b(p + 3)]
                p += 4
            else:                               # 0x52FB: tres en dos bytes
                sal += [x & 0x07, r.b(p + 1), x & 0xF8]
                p += 2
        g += 1
        if trozo == 0x16:                       # 0x52E1
            break
    return [tuple(sal[i:i + 3]) for i in range(0, len(sal), 3)]


def paso_final(r, fase):
    """El paso en que sale la entrada 0xFF: ahi acaba la subida."""
    s = 0
    for k, (pasos, tipo, x) in enumerate(guion(r, fase)):
        s += pasos if k else 1
        if tipo == 0xFF:
            break
    return s


def pieza(r, tipo):
    """Las filas de la pieza: 0x4A0E elige la tabla y 0x49B8 la lee."""
    if not tipo & 0x80:
        tabla, i = 0x5130, tipo
    elif tipo & 0x20:
        tabla, i = 0x5188, tipo & 0x1F
    elif not tipo & 0x40:
        tabla, i = 0x5146, tipo & 0x1F
    else:
        tabla, i = 0x5170, tipo & 0x1F
    p = r.w(tabla + 2 * i)
    filas_, ancho = r.b(p), r.b(p + 1)
    p += 2
    filas = []
    for _ in range(filas_):
        fila = []
        if ancho < 7:
            fila = [r.b(p + k) for k in range(ancho)]
            p += ancho
        else:                                   # 0x49D6: comprimida
            while True:
                x = r.b(p)
                p += 1
                if x == 0:
                    break
                n = x & 0x7F
                if x & 0x80:                    # n tal cual
                    fila += [r.b(p + k) for k in range(n)]
                    p += n
                else:                           # uno, n veces
                    fila += [r.b(p)] * n
                    p += 1
        filas.append(fila)
    return filas


def _en_banda(y):
    return (y - 0x18) & 0xFF < 0xA8


def _pinta(nt, y, x, filas):
    for fila in filas:
        if _en_banda(y):
            d = (y >> 3) * 32 + (x >> 3)
            for k, v in enumerate(fila):
                if d + k < 768:
                    nt[d + k] = v
        y = (y + 8) & 0xFF


def _borra(nt, y, x, ancho):                    # 0x4A00
    if _en_banda(y):
        d = (y >> 3) * 32 + (x >> 3)
        for k in range(ancho):
            if d + k < 768:
                nt[d + k] = VACIO


def pantallas(r, fase, pasos):
    """Los pasos de 0x6749 subiendo. Da (paso, tabla de nombres, objetos)."""
    ent = guion(r, fase)
    nt = bytearray(TRONCO.get(i % 32, VACIO) for i in range(768))
    obj = [None] * 40                           # 0xE132: [y, x, tipo]
    fichas = [None] * 3                         # 0xE1DE: [entrada, y, x, tipo]
    piezas = {}

    def pz(tipo):
        if tipo not in piezas:
            piezas[tipo] = pieza(r, tipo)
        return piezas[tipo]

    i = 0
    cuenta = ent[0][0] - 1                      # 0x5374: uno menos
    fin = False
    for t in range(1, pasos + 1):
        cuenta += 1
        if not fin and i < len(ent) and ent[i][0] == cuenta:
            if ent[i][1] == 0xFF:               # 0x675B: el final
                fin = True
            else:
                cuenta = 0
                while True:
                    _, tipo, x = ent[i]
                    i += 1
                    libres = [k for k in range(40) if obj[k] is None]
                    if (tipo & 0xE0) != 0xE0:
                        if libres:
                            obj[libres[0]] = [0xE8, x, tipo]
                    elif i not in [f[0] for f in fichas if f]:
                        hueco = [k for k in range(3) if fichas[k] is None]
                        if hueco:               # a 0xFFE8
                            fichas[hueco[0]] = [i, -24, x, tipo]
                        elif libres:            # 0x682C: se queda
                            obj[libres[0]] = [0xE8, x, tipo]
                    if i >= len(ent) or ent[i][0] != 0:
                        break
        for k in range(40):                     # 0x6889
            o = obj[k]
            if o is None:
                continue
            viejo, x, tipo = o
            filas = pz(tipo)
            y = (viejo + 8) & 0xFF
            if (y - 0xC0) & 0xFF < 0x30:        # 0x68AB: fuera, retirado
                y = 0xD0
            o[0] = y
            if not tipo & 0x80:                 # 0x68CC
                _borra(nt, viejo, x, len(filas[0]) if filas else 0)
            if (tipo & 0xC0) != 0xC0:           # 0x68DC
                _pinta(nt, y, x, filas)
            if y == 0xD0:
                obj[k] = None
        for k in range(40):                     # 0x68F8: los del bit 6, encima
            o = obj[k]
            if o is not None and o[2] & 0x40:
                _pinta(nt, o[0], o[1], pz(o[2]))
        for k in range(3):                      # 0x6C32: las aranas
            f = fichas[k]
            if f is None:
                continue
            f[1] += 8
            if -16 <= f[1] < 0xC0:              # 0x6C8E
                _pinta(nt, f[1] & 0xFF, f[2], pz(f[3]))
            else:                               # 0x6D41
                fichas[k] = None
        yield t, bytes(nt), [None if o is None else tuple(o) for o in obj]


def tira(r, fase):
    """Las filas de la fase, de ARRIBA abajo: la fila FILA de cada paso."""
    fin = paso_final(r, fase)
    filas = {}
    for t, nt, _ in pantallas(r, fase, fin):
        if t == PRIMER_PASO:                    # lo de debajo, de una vez
            for k in range(FILA, 24):
                filas[t - k] = nt[k * 32:k * 32 + 32]
        if t >= PRIMER_PASO:
            filas[t - FILA] = nt[FILA * 32:FILA * 32 + 32]
        if t == fin:                            # y lo de encima, al final
            for k in range(3, FILA):
                filas[t - k] = nt[k * 32:k * 32 + 32]
    return [filas[w] for w in sorted(filas, reverse=True)]


def dibuja(rom, fase, fn, esc=1):
    r = Rom(rom)
    v = G.vram_de_la_fase(rom, mascara_de_la_fase(r, fase))
    filas = tira(r, fase)
    w, h = 256 * esc, len(filas) * 8 * esc
    px = G.lienzo(w, h)
    for n, fila in enumerate(filas):
        for col, p in enumerate(fila):
            b = 0x0800 + p * 8                  # el tercio del medio
            G.pinta_celda(px, w, col * 8 * esc, n * 8 * esc,
                          v[G.PATRONES + b:G.PATRONES + b + 8],
                          v[G.COLOR + b:G.COLOR + b + 8], esc)
    G.png(w, h, px, fn)
    return len(filas)


def main():
    global ORG
    rom = open(sys.argv[1], "rb").read()
    ORG = int(sys.argv[2], 0)
    G.ORG = ORG
    sal = sys.argv[3]
    os.makedirs(sal, exist_ok=True)
    r = Rom(rom)
    for fase in range(9):
        fn = os.path.join(sal, "arbol-fase-%d.png" % (fase + 1))
        filas = dibuja(rom, fase, fn)
        print(f"   {fn}: {filas} filas, {paso_final(r, fase)} pasos, "
              f"mascara 0x{mascara_de_la_fase(r, fase):02X}")


if __name__ == "__main__":
    main()
