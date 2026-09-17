"""Lo que se afirma del cartucho, comprobado contra sus bytes.

Corre con el cartucho delante y sin el: cuando no esta, la imagen se rehace
desde las filas defb/defw del listado, que si viaja con el repositorio. Aqui no
se comprueba nada del codigo, solo de los datos, que son justamente los que
salen como defb/defw.
"""

import os
import re
import sys
import unittest

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(RAIZ, "tools"))

ROM = os.path.join(RAIZ, "magicaltree.rom")
ASM = os.path.join(RAIZ, "src", "magicaltree.asm")
ORG = 0x4000

FILA = re.compile(r"^\s+def(b|w)\s+([0-9a-fA-F,h ]+)\s*;\s*([0-9a-f]{4})")


def imagen_desde_el_listado():
    img = bytearray(16384)
    with open(ASM, encoding="utf-8") as f:
        for ln in f:
            m = FILA.match(ln)
            if not m:
                continue
            ancho, cuerpo, dirr = m.group(1), m.group(2), int(m.group(3), 16)
            p = dirr - ORG
            for tok in cuerpo.split(","):
                tok = tok.strip().rstrip("h")
                if not tok:
                    continue
                v = int(tok, 16)
                if ancho == "b":
                    img[p] = v
                    p += 1
                else:
                    img[p] = v & 0xFF
                    img[p + 1] = v >> 8
                    p += 2
    return bytes(img)


def lee():
    if os.path.exists(ROM):
        with open(ROM, "rb") as f:
            return f.read()
    return imagen_desde_el_listado()


class Cabecera(unittest.TestCase):
    def test_es_un_cartucho_msx_de_16k(self):
        rom = lee()
        self.assertEqual(rom[:2], b"AB")
        self.assertEqual(len(rom), 16384)

    def test_init_es_4077(self):
        rom = lee()
        self.assertEqual(rom[2] | (rom[3] << 8), 0x4077)

    def test_solo_usa_init(self):
        """STATEMENT, DEVICE y TEXT a cero."""
        self.assertEqual(lee()[4:10], b"\x00" * 6)


class TablasDelDespachador(unittest.TestCase):
    """Las dos tablas pegadas detras de un `call L_404A`.

    Ninguna entrada puede caer dentro de la tabla: la mas baja marca donde
    acaba, porque el codigo al que apunta viene justo detras.
    """

    TABLAS = {0x40C3: 16, 0x617A: 19}

    def entradas(self, ini, n):
        rom = lee()
        p = ini - ORG
        return [rom[p + 2 * i] | (rom[p + 2 * i + 1] << 8) for i in range(n)]

    def test_toda_entrada_cae_dentro_del_cartucho(self):
        for ini, n in self.TABLAS.items():
            for e in self.entradas(ini, n):
                self.assertTrue(ORG <= e < ORG + 16384,
                                f"tabla 0x{ini:04X}: 0x{e:04X} se sale")

    def test_ninguna_entrada_cae_dentro_de_su_tabla(self):
        for ini, n in self.TABLAS.items():
            fin = ini + 2 * n
            for e in self.entradas(ini, n):
                self.assertFalse(ini <= e < fin,
                                 f"tabla 0x{ini:04X}: 0x{e:04X} cae dentro")

    def test_la_de_escenas_cierra_donde_apunta_su_primera_entrada(self):
        """0x40C3 + 16*2 = 0x40E3, y la primera palabra es 0x40E3."""
        self.assertEqual(self.entradas(0x40C3, 16)[0], 0x40C3 + 16 * 2)


class Guiones(unittest.TestCase):
    """El interprete de rotulos de 0x4062, ejecutado.

    Aqui el indice de patron ES el codigo ASCII -cero de desplazamiento-, al
    reves que en Circus Charlie, donde la fuente empieza en el espacio. Lo
    decide el contenido: con 0x20 el ano salia "QYXT".
    """

    def texto(self, tramos):
        """El tile 0 es el espacio en blanco, no el caracter 0."""
        return ["".join(" " if b == 0 else chr(b) for b in cuerpo)
                for _, cuerpo in tramos]

    def test_el_marcador(self):
        from guiones import ejecuta
        fin, tramos = ejecuta(lee(), ORG, 0x4710)
        self.assertEqual(fin, 0x4725)
        self.assertEqual(self.texto(tramos), ["HI@", "STAGE@", "1P@"])

    def test_el_menu_y_la_firma_de_konami(self):
        from guiones import ejecuta
        fin, tramos = ejecuta(lee(), ORG, 0x472B)
        self.assertEqual(fin, 0x47A4)
        t = self.texto(tramos)
        self.assertEqual(t[0], "PLAY SELECT")
        self.assertTrue(t[-1].endswith("KONAMI 1984"), t[-1])

    def test_los_rotulos_de_la_partida(self):
        from guiones import ejecuta
        rom = lee()
        self.assertEqual(self.texto(ejecuta(rom, ORG, 0x7565)[1]),
                         ["STAGE  CLEAR", "BONUS@"])
        self.assertEqual(self.texto(ejecuta(rom, ORG, 0x7595)[1]),
                         ["CONGRATULATIONS"])

    def test_el_cartucho_se_anuncia(self):
        from guiones import ejecuta
        self.assertEqual(self.texto(ejecuta(lee(), ORG, 0x47BC)[1]),
                         ["@ VIDEO CARTRIDGE @"])


class Descompresor(unittest.TestCase):
    """El de 0x449B, que es el mismo codigo que el 0x45C9 de Circus Charlie.

    Lo prueba que los bytes coinciden: la firma de catorce bytes de su bucle
    principal esta en los dos cartuchos.
    """

    def test_el_bucle_es_el_mismo_que_el_de_circus_charlie(self):
        firma = bytes.fromhex("7ee67f4f7e232005b920edfbc906")
        self.assertEqual(lee()[0x44A3 - ORG:0x44A3 - ORG + len(firma)], firma)


if __name__ == "__main__":
    unittest.main()
