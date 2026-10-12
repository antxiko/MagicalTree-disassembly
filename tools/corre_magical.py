#!/usr/bin/env python3
"""EL CARTUCHO ENTERO, CORRIENDO EN PYTHON: de INIT a la partida sin emulador.

Por que. Los decorados de tools/graficos.py son solo el fondo: el mago, los
bichos y lo que cae del arbol los pone el juego cuadro a cuadro. Reescribir a
mano esa logica seria adivinar; ejecutarla no lo es. Aqui corre el codigo del
propio cartucho sobre el Z80 pequeno de tools/z80run.py.

Como corre. INIT (0x4077) engancha H.KEYI y se queda en el `jr $` de 0x40A5;
TODO el juego pasa en el gancho de 0x402C, una vez por cuadro. Asi que se corre
INIT hasta 0x40A5 y luego se llama al gancho una vez por cuadro.

Las ocho llamadas a la BIOS que hace el cartucho se atienden aqui, antes de
saltar a ellas: RDVDP 0x013E, SETRD 0x0050, SETWRT 0x0053, WRTVDP 0x0047,
RDVRM 0x004A, WRTPSG 0x0093, RDPSG 0x0096 y SNSMAT 0x0141. Ninguna otra: si el
cartucho saltase por debajo de 0x4000 a otro sitio, esto revienta.

El mando: nada pulsado, salvo lo que diga quien maneje esto por `teclas`
(fila -> bits) y el ESPACIO (fila 8, bit 0).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from z80run import Z80, ParadaZ80  # noqa: E402

GANCHO = 0x402C
INIT = 0x4077
DUERME = 0x40A5
CUADRO_DE_PARTIDA = 0x4184      # la escena 8, el compas de la partida
VUELCA_LOS_SPRITES = 0x52A2
CENTINELA = 0xFFFE


class MagicalTree(Z80):
    def __init__(self, rom):
        super().__init__()
        self.carga(rom, 0x4000)
        # Lo unico que el cartucho LEE de la BIOS: los puertos del VDP de su
        # tabla, (0x0006) y (0x0007) (0x44C6, 0x44D4).
        self.mem[0x0006] = 0x98
        self.mem[0x0007] = 0x98
        self.espacio = False
        self.teclas = {}          # fila -> bits PULSADOS (a uno), p. ej. {8: 0x80}
        self.palanca = 0          # bits PULSADOS del registro 14 del PSG: 0 arriba, 1 abajo, 2 izq., 3 der., 4 disparo
        self.paradas = {}         # direccion -> funcion(self), sin detener nada

    # ------------------------------------------------------------ la BIOS
    def _bios(self):
        pc = self.pc
        if pc == 0x013E:                          # RDVDP
            self.a = 0x80
        elif pc == 0x0050:                        # SETRD
            self.vdp.dir = self.hl & 0x3FFF
            self.vdp.medio = None
        elif pc == 0x0053:                        # SETWRT
            self.vdp.dir = self.hl & 0x3FFF
            self.vdp.medio = None
        elif pc == 0x004A:                        # RDVRM: HL -> A
            self.a = self.vdp.vram[self.hl & 0x3FFF]
        elif pc == 0x0047:                        # WRTVDP: C registro, B valor
            self.vdp.regs[self.c & 7] = self.b
        elif pc == 0x0093:                        # WRTPSG: A registro, E valor
            self.maq.psg[self.a & 15] = self.e
        elif pc == 0x0096:                        # RDPSG
            if self.a == 14:
                self.a = 0xFF & ~self.palanca
            else:
                self.a = self.maq.psg[self.a & 15]
        elif pc == 0x0141:                        # SNSMAT: A fila -> A bits
            fila = self.a
            pulsado = self.teclas.get(fila, 0)
            if fila == 8 and self.espacio:
                pulsado |= 0x01
            self.a = 0xFF & ~pulsado
        else:
            raise ParadaZ80("salto a la BIOS 0x%04X sin atender" % pc)
        self.pc = self._pop()                     # el `ret` de la BIOS

    def _paso(self):
        pc = self.pc
        if pc < 0x4000:
            self._bios()
            return
        f = self.paradas.get(pc)
        if f:
            f(self)
        self._una()

    def arranca(self):
        self.sp = 0xF380
        self.pc = INIT
        n = 0
        while self.pc != DUERME:
            n += 1
            if n > 5_000_000:
                raise ParadaZ80("INIT no llega a 0x40A5")
            self._paso()

    def cuadro(self, tope=2_000_000):
        """Una interrupcion: el gancho de 0x402C hasta su `reti`."""
        self.sp = 0xE400                     # la pila de INIT (0x4085)
        self.sp = (self.sp - 2) & 0xFFFF
        self._escribir16(self.sp, CENTINELA)
        self.pc = GANCHO
        n = 0
        while self.pc != CENTINELA:
            n += 1
            if n > tope:
                raise ParadaZ80("un cuadro de mas de %d instrucciones" % tope)
            self._paso()
        return n
