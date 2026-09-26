"""La web y el arbol, comprobados contra el listado y la ROM.

Portados de CIRCUS_DISAM: las cifras de la portada atadas al listado y el
barrido de nombres y ficheros de otros juegos de la serie. Y los del arbol:
lo que las paginas dicen de las nueve fases, medido con tools/arbol.py.
"""

import os
import re
import subprocess
import sys
import unittest

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(RAIZ, "tools"))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from test_listado import ASM, FILA, lee      # noqa: E402

DOCS = os.path.join(RAIZ, "docs")

# Los demas juegos de la serie. Que el nombre de otro salga en una pagina de
# este es casi siempre un copia y pega: ya paso con cinco ficheros LICENSE, con
# el pie de catorce paginas de otro proyecto y con tests que apuntaban a
# src/soccer.asm. Este andamiaje llego de Ping Pong y de Circus Charlie.
OTROS_JUEGOS = (
    "Tennis", "Pitfall", "Temptations", "Stardust", "Ale Hop", "Colt 36",
    "Antarctic", "Athletic Land", "Monkey Academy", "F-1 Spirit", "Pippols",
    "Time Pilot", "Frogger", "Super Cobra", "Billiards", "Mahjong",
    "Hyper Rally", "Nemesis", "Demonia", "Cabbage", "Hole in One",
    "Casio World Open", "3D Golf", "Baseball", "Yie Ar Kung-Fu",
    "King's Valley", "Sky Jaguar", "Mopi Ranger", "Descubrimiento",
    "War in Middle Earth", "Ping Pong", "Soccer", "Football", "Road Fighter",
    "Hyper Sports", "Hyper Olympic", "Goonies", "Knightmare", "Twin Bee",
    "Penguin", "Bomber", "Circus Charlie", "Comic Bakery",
)

# Circus Charlie se nombra A PROPOSITO donde el hallazgo es el codigo que
# comparten. La excepcion vale solo en esas paginas, solo para ese juego y
# solo si aparece una de las palabras que la justifican.
CITAS_LEGITIMAS = {
    "HALLAZGOS.md": (("mismo codigo", "mismo código"), ("Circus Charlie",)),
    "FINDINGS.md": (("same code",), ("Circus Charlie",)),
    "index.html": (("mismo codigo", "same code"), ("Circus Charlie",)),
}
CITAS_LEGITIMAS["HALLAZGOS.html"] = CITAS_LEGITIMAS["HALLAZGOS.md"]
CITAS_LEGITIMAS["FINDINGS.html"] = CITAS_LEGITIMAS["FINDINGS.md"]


def lee_texto(ruta):
    with open(ruta, encoding="utf-8") as f:
        return f.read()


def bytes_de_datos_del_listado():
    """Cuantos bytes salen en filas defb/defw: los DATOS del cartucho."""
    n = 0
    for ln in lee_texto(ASM).splitlines():
        m = FILA.match(ln)
        if not m:
            continue
        toks = [t for t in m.group(2).split(",") if t.strip()]
        n += len(toks) * (1 if m.group(1) == "b" else 2)
    return n


class LasCifrasDeLaPortada(unittest.TestCase):
    """Las cifras que declara make_web.py tienen que ser las del listado."""

    def setUp(self):
        import make_web
        self.w = make_web

    def test_la_suma_de_bytes_da_el_cartucho(self):
        self.assertEqual(self.w.CODIGO + self.w.DATOS, 16384)

    def test_las_cifras_de_bytes_son_las_de_este_listado(self):
        datos = bytes_de_datos_del_listado()
        self.assertEqual(self.w.DATOS, datos)
        self.assertEqual(self.w.CODIGO, 16384 - datos)

    def test_las_cifras_de_la_portada_son_las_del_listado(self):
        """Se EJECUTA tools/densidad.py y se le lee la salida."""
        salida = subprocess.run(
            [sys.executable, os.path.join(RAIZ, "tools", "densidad.py"), ASM],
            capture_output=True, text=True, check=True).stdout
        m = re.search(r"(\d+) instrucciones, (\d+) comentarios", salida)
        self.assertIsNotNone(m, "densidad.py no imprimio el total:\n" + salida)
        self.assertEqual(self.w.INSTRUCCIONES, int(m.group(1)))
        self.assertEqual(self.w.COMENTARIOS, int(m.group(2)))
        m = re.search(r"(\d+) rutinas por debajo del 10 %, de (\d+)", salida)
        self.assertIsNotNone(m)
        self.assertEqual(int(m.group(1)), 0, "hay rutinas flojas")
        self.assertEqual(self.w.RUTINAS, int(m.group(2)))

    def test_la_densidad_declarada_cuadra_con_las_dos_cuentas(self):
        pct = 100.0 * self.w.COMENTARIOS / self.w.INSTRUCCIONES
        self.assertAlmostEqual(pct, float(self.w.DENSIDAD.replace(",", ".")),
                               places=1)
        self.assertEqual(self.w.DENSIDAD.replace(",", "."), self.w.DENSIDAD_EN)

    def test_la_ficha_dice_el_sha_de_este_cartucho(self):
        sha = None
        for linea in lee_texto(os.path.join(RAIZ, "Makefile")).splitlines():
            if linea.startswith("SHA"):
                sha = linea.split("=")[1].strip()
        self.assertIsNotNone(sha)
        for idioma in ("es", "en"):
            ficha = " ".join(self.w.TXT[idioma]["ficha"])
            self.assertIn(sha[:8], ficha)
            self.assertIn("RC-713", ficha)


class SinNombresDeOtroJuego(unittest.TestCase):
    """El copia y pega de otro proyecto de la serie, cazado a tiempo."""

    def _revisa(self, ruta):
        texto = lee_texto(ruta)
        fn = os.path.basename(ruta)
        palabras, permitidos = CITAS_LEGITIMAS.get(fn, ((), ()))
        if permitidos and any(j in texto for j in permitidos):
            self.assertTrue(any(p in texto.lower() for p in palabras),
                            "%s puede nombrar %s solo si dice por que (%r)"
                            % (fn, permitidos, palabras))
        for juego in OTROS_JUEGOS:
            if juego in permitidos:
                continue
            self.assertNotIn(juego, texto, "%s nombra a %s" % (fn, juego))

    def test_el_encabezado_del_listado_es_de_este_juego(self):
        cabeza = "\n".join(lee_texto(ASM).splitlines()[:30])
        for juego in OTROS_JUEGOS:
            self.assertNotIn(juego, cabeza)

    def test_la_licencia_y_los_avisos_son_de_este_juego(self):
        for fn in ("LICENSE", "README.md", "README.es.md", "AVISO-LEGAL.md",
                   "LEGAL-NOTICE.md"):
            ruta = os.path.join(RAIZ, fn)
            self.assertTrue(os.path.exists(ruta), "falta %s" % fn)
            self._revisa(ruta)

    OTROS_FICHEROS = ("soccer", "hypersports", "roadfighter", "pingpong",
                      "mopiranger", "tennis", "baseball", "nemesis",
                      "pippols", "antarctic", "golf", "frogger",
                      "kingsvalley", "yiearkungfu", "skyjaguar", "hyperrally",
                      "goonies", "knightmare", "twinbee", "circus", "comic")

    def _sin_ficheros_de_otro(self, ruta):
        texto = lee_texto(ruta).lower()
        for otro in self.OTROS_FICHEROS:
            for pega in ("src/%s" % otro, "%s.asm" % otro, "%s.rom" % otro,
                         "%s.notes" % otro):
                self.assertNotIn(pega, texto, "%s nombra el fichero %s"
                                 % (os.path.relpath(ruta, RAIZ), pega))

    def test_las_herramientas_de_la_web_no_apuntan_a_otro_juego(self):
        for fn in ("make_web.py", "md2html.py", "contenido_web.py",
                   "arbol.py", "coteja_fases.py", "omsx_fases.tcl",
                   "graficos.py"):
            self._sin_ficheros_de_otro(os.path.join(RAIZ, "tools", fn))

    def test_ni_los_textos_publicados(self):
        for sitio in (RAIZ, DOCS, os.path.join(DOCS, "es")):
            for fn in os.listdir(sitio):
                ruta = os.path.join(sitio, fn)
                if os.path.isfile(ruta) and (
                        fn.endswith((".md", ".html")) or fn == "LICENSE"):
                    self._sin_ficheros_de_otro(ruta)

    def test_la_web_no_nombra_otro_juego(self):
        for raiz, _, ficheros in os.walk(DOCS):
            for fn in ficheros:
                if fn.endswith((".md", ".html")):
                    self._revisa(os.path.join(raiz, fn))


class ElArbol(unittest.TestCase):
    """Lo que las paginas dicen de las nueve fases, medido sobre la ROM."""

    def setUp(self):
        import arbol
        self.a = arbol
        self.r = arbol.Rom(lee())

    def test_las_imagenes_no_ejecutan_el_cartucho(self):
        for fn in ("arbol.py", "graficos.py"):
            fuente = lee_texto(os.path.join(RAIZ, "tools", fn))
            self.assertNotIn("corre_magical", fuente)
            self.assertNotIn("z80run", fuente)

    def test_los_pasos_de_cada_fase(self):
        self.assertEqual([self.a.paso_final(self.r, f) for f in range(9)],
                         [451, 493, 508, 498, 491, 515, 549, 473, 515])

    def test_el_guion_ocupa_de_723_a_918_bytes(self):
        tam = [3 * len(self.a.guion(self.r, f)) for f in range(9)]
        self.assertEqual((min(tam), max(tam)), (723, 918))
        self.assertLessEqual(0x3B80 + max(tam), 0x4000)

    def test_las_aranas_de_cada_fase(self):
        aranas = []
        for f in range(9):
            g = self.a.guion(self.r, f)
            fin = [k for k, e in enumerate(g) if e[1] == 0xFF][0]
            aranas.append(sum(1 for e in g[:fin] if e[1] == 0xE0))
        self.assertEqual(aranas, [5, 12, 13, 14, 16, 12, 19, 16, 19])

    def test_la_primera_mascara_sale_de_los_valores_iniciales(self):
        self.assertEqual(self.a.mascara_de_la_fase(self.r, 0), 0x77)
        self.assertEqual(self.r.b(0x741F), 0x11)
        self.assertEqual([self.a.mascara_de_la_fase(self.r, f)
                          for f in range(9)],
                         [0x77, 0x33, 0xBB, 0xEE, 0x11, 0xBB, 0xEE, 0x11, 0x11])

    def test_el_trozo_16_se_lee_a_si_mismo(self):
        """Declara dieciseis entradas y tiene quince: la ultima son los dos
        primeros bytes de la tabla de trozos. Antes llega el 0xFF."""
        for f in range(9):
            g = self.a.guion(self.r, f)
            self.assertEqual(g[-2], (0x20, 0xFF, 0x00))
            self.assertEqual(g[-1], (0x00, 0x4A, 0x50))

    def test_nueve_ld_a_r(self):
        n = sum(1 for ln in lee_texto(ASM).splitlines()
                if re.match(r"^\s+ld a,r\s", ln))
        self.assertEqual(n, 9)

    def test_el_decorado_se_pinta_del_centro_hacia_fuera(self):
        """Medido en openMSX: la columna 0 de la tabla en la 15, la 1 en la
        16, la 2 en la 14... y las 32 caen una vez cada una."""
        import graficos
        orden = [graficos.columna_en_pantalla(k) for k in range(32)]
        self.assertEqual(orden[:4], [15, 16, 14, 17])
        self.assertEqual(sorted(orden), list(range(32)))

    def test_las_nueve_tiras_estan_publicadas(self):
        for f in range(1, 10):
            for fn in ("arbol-fase-%d.png" % f, "arbol-fase-%d-pie.png" % f,
                       "arbol-nueve-fases.png"):
                self.assertTrue(os.path.exists(
                    os.path.join(DOCS, "imagenes", fn)), fn)


if __name__ == "__main__":
    unittest.main()
