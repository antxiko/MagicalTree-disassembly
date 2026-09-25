# Magical Tree (Konami, MSX1) - desensamblado
#
# El orden de las cosas: trazar el flujo -> generar el listado -> comprobar que
# vuelve a dar la ROM byte a byte -> las comprobaciones que el reensamblado NO
# cubre.
#
# El cartucho no se distribuye: hace falta en la raiz como magicaltree.rom, y
# `make comprueba` verifica su sha256.

ROM      = magicaltree.rom
SHA      = a3f3ad0d8f5cda0f04bf917fbd9d796e9dc66d071bd30a2fde8d06260c7ec9f7
SRC      = src
WORK     = work
ORG      = 0x4000
TITULO   = MAGICAL TREE - Konami - MSX1 - cartucho RC-713 de 16 KB en la pagina 1

all: listado verify sanity test

$(ROM):
	@echo "=================================================================="
	@echo " Falta $(ROM), y este repositorio NO lo distribuye."
	@echo ""
	@echo " Es Magical Tree (Konami, RC-713) para MSX, 16384 bytes exactos."
	@echo " Ponlo aqui con ese nombre. Para comprobar que es el mismo:"
	@echo "     shasum -a 256 $(ROM)"
	@echo "     $(SHA)"
	@echo "=================================================================="
	@false

comprueba: $(ROM)
	@echo "$(SHA)  $(ROM)" | shasum -a 256 -c -

# El trazado sigue el flujo desde los puntos de entrada. Los que no se pueden
# deducir estaticamente -ganchos de interrupcion, destinos de saltos
# indirectos- estan declarados en el .entries, cada uno con su justificacion.
$(WORK)/magicaltree.trace.json: $(ROM) $(SRC)/magicaltree.entries $(SRC)/magicaltree.nocode
	@mkdir -p $(WORK)
	python3 tools/z80trace.py $(ROM) $(ORG) $(SRC)/magicaltree.entries \
	        $(WORK)/magicaltree $(SRC)/magicaltree.nocode

trace: $(WORK)/magicaltree.trace.json

listado: $(WORK)/magicaltree.trace.json $(SRC)/magicaltree.notes
	python3 tools/mkasm.py $(ROM) $(ORG) $(WORK)/magicaltree.trace.json \
	        $(SRC)/magicaltree.notes work/msx.sym $(SRC)/magicaltree.asm "$(TITULO)"

# La prueba que decide si el desensamblado es fiable.
verify: $(SRC)/magicaltree.asm $(ROM)
	@sh tools/verify_build.sh $(SRC)/magicaltree.asm $(ROM) $(ORG)

# Lo que el reensamblado NO puede cazar: que unos datos se esten leyendo como
# codigo. El binario sale identico igual, porque los bytes no cambian; lo unico
# que cambia es lo que decimos de ellos.
sanity: $(WORK)/magicaltree.trace.json
	@echo "=================================================================="
	@echo " ningun byte declarado como datos puede salir como codigo"
	@echo "=================================================================="
	@python3 tools/check_trace.py $(WORK)/magicaltree.trace.json $(SRC)/magicaltree.nocode
	@python3 tools/check_datos_como_codigo.py $(WORK) $(SRC)
	@echo "=================================================================="
	@echo " ningun punto de entrada puede caer dentro de una zona de datos"
	@echo "=================================================================="
	@python3 tools/check_entradas.py $(SRC)/magicaltree.entries $(SRC)/magicaltree.notes \
	        $(SRC)/magicaltree.nocode
	@echo "=================================================================="
	@echo " ni un byte del cartucho sin asignar"
	@echo "=================================================================="
	@python3 tools/presupuesto.py $(WORK) $(SRC)

densidad:
	@python3 tools/densidad.py $(SRC)/magicaltree.asm

test:
	@echo "=================================================================="
	@echo " Tests"
	@echo "=================================================================="
	@python3 -m unittest discover -s tests -v

# Rehace la VRAM del cartucho ejecutando sus propios pasos y la DIBUJA. Aqui no
# entra ni una captura del emulador: si un dibujo sale mal, lo que esta mal es
# la lectura de la ROM, y por eso vale como comprobacion y no como adorno.
imagenes: $(ROM)
	@mkdir -p docs/imagenes
	python3 tools/graficos.py $(ROM) $(ORG) docs/imagenes
	python3 tools/arbol.py $(ROM) $(ORG) docs/imagenes

# EL ARBOL DE LAS NUEVE FASES contra openMSX. Los volcados los hace
# tools/omsx_fases.tcl, una fase por arranque (la fase va en work/fase.txt):
#     for F in 0 1 2 3 4 5 6 7 8; do echo $F > work/fase.txt; #       openmsx -machine Philips_VG_8020 -cart $(ROM) -script tools/omsx_fases.tcl; done
coteja_fases: $(ROM)
	@python3 tools/coteja_fases.py $(ROM) $(WORK)/fases

# LA WEB
#
# Bilingue: el ingles en docs/ y el castellano en docs/es/. Las paginas se
# escriben en markdown y se convierten con md2html.py; la portada la monta
# make_web.py, que declara las cifras medidas de ESTE cartucho.
web: $(ROM)
	python3 tools/md2html.py docs en
	python3 tools/md2html.py docs/es es
	python3 tools/make_web.py docs/imagenes docs/index.html en
	python3 tools/make_web.py docs/imagenes docs/es/index.html es
	python3 tools/check_enlaces.py docs

clean:
	rm -rf $(WORK)/magicaltree.trace.json $(WORK)/magicaltree.blocks

.PHONY: all comprueba trace listado verify sanity test densidad imagenes coteja_fases web clean
