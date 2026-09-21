# omsx_cuadro.tcl - A QUE CUADRO PERTENECE LA FOTO.
#
# EL PROBLEMA, que se pago en Circus Charlie (RC-712). tools/omsx_vram.tcl
# vuelca la VRAM y pide la foto una detras de otra, y eso NO da un par
# comparable: el `screenshot` de openMSX devuelve un cuadro del renderizador,
# que no es el del instante en que se leyo la VRAM. Entre uno y otro el juego
# ha movido los sprites y ha subido el marcador, asi que cotejar el dibujo
# hecho desde esa VRAM contra esa foto acusa al renderizador de fallos que son
# del reloj.
#
# LO QUE NO LO ARREGLA: congelar con `set ::pause on` antes de volcar. Probado
# en Circus, y da EXACTAMENTE las mismas diferencias: con la maquina parada el
# renderizador no vuelve a pintar.
#
# LO QUE SI: no buscar el cuadro bueno, MEDIRLO. Se dispara la foto una vez y
# se vuelca la VRAM en una rafaga de cuadros alrededor. En Circus el que casa
# es el -1 en las cinco atracciones y en dos instantes distintos, con cero
# puntos de diferencia. Lo comprueba tools/coteja_pixels.py --serie.
#
#   "C:/Program Files/openMSX/openmsx.exe" -machine Philips_VG_8020 \
#       -cart magicaltree.rom -script tools/omsx_cuadro.tcl
#
# Variables de entorno:
#   PP_SALIDA     carpeta de salida (por defecto work/serie)
#   PP_INSTANTES  los segundos de reloj EMULADO en que disparar cada foto

proc opcion {nombre porDefecto} {
    global env
    if {[info exists env($nombre)]} { return $env($nombre) }
    return $porDefecto
}

set ::SALIDA [opcion PP_SALIDA {C:/Users/Antxiko/Documents/DES_ASM/MAGICALTREE_DISAM/work/serie}]
file mkdir $::SALIDA

# El cuadro del MSX no dura 1/50 s, dura 1/50,15: en trece cuadros la
# diferencia ya se nota, y aqui se cuentan cuadros.
set ::CUADRO 0.019940
set ::VENTANA 6
set ::INSTANTES [opcion PP_INSTANTES {6 12 20 30 42 55 68}]

# Lanzado con `-script`, openMSX arranca con el renderizador sin inicializar y
# las capturas salen negras sin que nadie proteste.
catch { set renderer SDLGL-PP }

# Y HAY QUE APAGARLE LOS EFECTOS DE TELEVISOR, que son DOS y los dos estropean
# el cotejo. Leidos del propio emulador, no supuestos: `blur` y `glow` ya vienen
# a 0, asi que los culpables son los otros dos.
#
#   deflicker = true   MEZCLA CUADROS: un punto encendido en uno y apagado en
#                      el siguiente sale a media intensidad. El magenta del
#                      monociclo de Circus, (201,104,178), aparecia como
#                      (101,56,89), que no es ningun color del MSX, y bastaban
#                      nueve puntos para que el cotejo no diera cero.
#   gamma = 1.1        RETOCA LOS COLORES, y los dos verdes del MSX -el 2 y el
#                      12- se acercan tanto que se confunden: en Magical Tree
#                      58 puntos del 12 salian clasificados como 2. Con la
#                      gamma a 1.0 la foto trae los colores tal cual.
catch { set blur 0 }
catch { set glow 0 }
catch { set deflicker off }
catch { set gamma 1.0 }
catch { set brightness 0 }
catch { set contrast 0 }
catch { set scale_algorithm simple }

proc vuelca_vram {acto k} {
    global SALIDA
    set datos [debug read_block VRAM 0 16384]
    set signo [expr {$k < 0 ? "m" : "p"}]
    set nom [format {%s/vram_%s_%s%02d.bin} $SALIDA $acto $signo [expr {abs($k)}]]
    set f [open $nom w]
    fconfigure $f -translation binary
    puts -nonewline $f $datos
    close $f
}

proc foto {acto} {
    global SALIDA
    set r {}
    for {set k 0} {$k < 8} {incr k} {
        lappend r [format %02X [debug read {VDP regs} $k]]
    }
    set f [open $SALIDA/info_$acto.txt w]
    puts $f [format {etiqueta %s} $acto]
    puts $f [format {tiempo %s} [machine_info time]]
    puts $f [format {regs %s} [join $r { }]]
    foreach {nombre dir} {escena 0xE000 subescena 0xE001 modo 0xE002
                          reloj 0xE003 espera 0xE004 fase 0xE051
                          tanda 0xE05C mascara_de_color 0xE05D} {
        puts $f [format {%s %d} $nombre [debug read memory $dir]]
    }
    close $f
    catch { screenshot -raw $SALIDA/pant_$acto.png }
}

# --- calendario -------------------------------------------------------------
# Sin tocar una tecla: la demostracion del cartucho pasa sola por el logotipo
# de la casa, el titulo y el juego, y lo unico que hace falta es disparar en
# varios instantes y dejarla correr.
set ::n 0
foreach t $::INSTANTES {
    set acto [format {t%02d} $::n]
    incr ::n
    for {set k [expr {-$::VENTANA}]} {$k <= $::VENTANA} {incr k} {
        after time [expr {$t + $k * $::CUADRO}] [list vuelca_vram $acto $k]
    }
    after time $t [list foto $acto]
}
after time [expr {[lindex $::INSTANTES end] + 3}] { exit }

after realtime 900 {
    puts {PERRO GUARDIAN a los 900 s reales}
    exit
}
