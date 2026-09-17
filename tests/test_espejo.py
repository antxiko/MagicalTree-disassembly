"""Que el bucle de 0x60F0 es un ESPEJO y no un giro.

Durante un rato estuvo escrito en las notas que ese bucle TRANSPONIA los
patrones, o sea que los volcaba sobre su diagonal. No lo hace: los da la vuelta
de izquierda a derecha. La diferencia importa, porque de ella depende que los
dibujos publicados salgan bien y que el comentario del listado no mienta.

Aqui se fijan las tres comprobaciones que lo zanjaron, para que no se pueda
volver atras sin que algo se ponga rojo.
"""
import os
import sys
import unittest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "tools"))

import graficos  # noqa: E402

ROM = os.path.join(os.path.dirname(__file__), "..", "magicaltree.rom")
ORIGEN = 0x5BCD          # los 320 bytes de patrones de sprite, sin comprimir
LARGO = 0x140
DESTINO = 0x1940         # donde queda la copia dada la vuelta
BASE_SPRITES = 0x1800    # donde estan los originales (R6 = 0x03)


def maquina(fuente):
    """El bucle de 0x60F0 sobre 320 bytes cualesquiera, no solo los de la ROM.

    Hace falta poder aplicarlo a su propia salida para comprobar que es una
    operacion que se deshace a si misma, que es lo que separa un espejo de un
    giro.
    """
    sal = bytearray(LARGO)
    for tanda in range(10):
        de = tanda * 0x20
        hl = tanda * 0x20 + 0x10
        ix = tanda * 0x20
        for k in range(0x10):
            r = (fuente[de + k] << 8) | fuente[hl + k]
            i0, i1 = ix + k, ix + k + 0x10
            for _ in range(0x10):
                r <<= 1
                acarreo = (r >> 16) & 1
                r &= 0xFFFF
                nuevo0 = ((sal[i0] >> 1) | (acarreo << 7)) & 0xFF
                sale0 = sal[i0] & 1
                sal[i0] = nuevo0
                sal[i1] = ((sal[i1] >> 1) | (sale0 << 7)) & 0xFF
    return sal


class ElEspejo(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        with open(ROM, "rb") as f:
            cls.rom = f.read()
        cls.entrada = bytearray(cls.rom[ORIGEN - 0x4000:ORIGEN - 0x4000 + LARGO])

    def test_aplicarla_dos_veces_devuelve_el_original(self):
        """Un espejo se deshace a si mismo; un giro de 90 grados NO."""
        self.assertEqual(bytes(maquina(maquina(self.entrada))), bytes(self.entrada))

    def test_no_cambia_los_bits_encendidos(self):
        """Mover pixeles de sitio no los crea ni los borra.

        Es la comprobacion que caza un desfase: con el paso de tanda mal puesto
        la cuenta se va, aunque el dibujo siga pareciendo un dibujo.
        """
        antes = sum(bin(b).count("1") for b in self.entrada)
        despues = sum(bin(b).count("1") for b in maquina(self.entrada))
        self.assertEqual(antes, despues)

    def test_cada_fila_sale_del_reves_bit_a_bit(self):
        """Lo que define el espejo: la fila de dieciseis pixeles, invertida."""
        sal = maquina(self.entrada)
        for tanda in range(10):
            for k in range(0x10):
                dentro = (self.entrada[tanda * 0x20 + k] << 8) | self.entrada[tanda * 0x20 + 0x10 + k]
                fuera = (sal[tanda * 0x20 + k] << 8) | sal[tanda * 0x20 + 0x10 + k]
                self.assertEqual(format(dentro, "016b")[::-1], format(fuera, "016b"),
                                 f"tanda {tanda}, fila {k}")

    def test_el_pintor_de_sprites_salta_justo_esos_cuarenta_patrones(self):
        """0x665B suma 0x28 al patron cuando la figura mira al otro lado.

        Cuarenta patrones de sprite son 40 * 8 = 320 bytes, que es exactamente
        lo que separa 0x1800 de 0x1940. O sea que el `add a,0x28` del pintor y
        el destino del espejo son la misma cosa dicha de dos maneras, y esto lo
        ata: si alguien mueve uno, el otro deja de cuadrar.
        """
        salto = self.rom[0x665C - 0x4000]      # el operando del `ld a,028h`
        self.assertEqual(salto, 0x28)
        self.assertEqual(DESTINO - BASE_SPRITES, salto * 8)
        self.assertEqual(DESTINO - BASE_SPRITES, LARGO)

    def test_la_maquina_de_graficos_py_hace_lo_mismo(self):
        """Que la herramienta que dibuja y este test no se separen."""
        graficos.ORG = 0x4000
        self.assertEqual(bytes(graficos.espeja(self.rom)), bytes(maquina(self.entrada)))


if __name__ == "__main__":
    unittest.main()
