# omsx_vram.tcl - Vuelca la VRAM de verdad del cartucho, para comprobar los PNG.
#
# Para que sirve: tools/graficos.py monta las imagenes ejecutando en Python los
# pasos del cartucho (el descompresor de 0x449B, el espejo de 0x60F0 y el
# interprete de rotulos de 0x405E). Mirar el dibujo no basta: hay que comparar sus
# bytes con los que el VDP tiene de verdad. Esto deja correr el juego y en
# varios instantes vuelca los 16 KB de VRAM, los ocho registros del VDP y las
# variables que dicen QUE se estaba dibujando.
#
# No pone NINGUN punto de ruptura: los volcados van por reloj emulado, que es
# lo unico que no ahoga al emulador.
#
# Variables de entorno:
#   PP_SALIDA  carpeta de salida (por defecto work/omsx)
#
#   "C:/Program Files/openMSX/openmsx.exe" -machine Philips_VG_8020 \
#       -cart magicaltree.rom -script tools/omsx_vram.tcl

proc opcion {nombre porDefecto} {
    global env
    if {[info exists env($nombre)]} { return $env($nombre) }
    return $porDefecto
}

set ::SALIDA [opcion PP_SALIDA {C:/Users/Antxiko/Documents/DES_ASM/MAGICALTREE_DISAM/work/omsx}]
file mkdir $::SALIDA
set ::n 0

proc vuelca {etiqueta} {
    set i [format %02d $::n]
    incr ::n
    # los 16 KB de VRAM tal cual los ve el VDP
    set datos [debug read_block VRAM 0 16384]
    set f [open $::SALIDA/vram_$i.bin w]
    fconfigure $f -translation binary
    puts -nonewline $f $datos
    close $f
    # los ocho registros, que dicen donde esta cada tabla
    set r {}
    for {set k 0} {$k < 8} {incr k} {
        lappend r [format %02X [debug read {VDP regs} $k]]
    }
    set f [open $::SALIDA/info_$i.txt w]
    puts $f [format {etiqueta %s} $etiqueta]
    puts $f [format {tiempo %s} [machine_info time]]
    puts $f [format {regs %s} [join $r { }]]
    # Las variables de trabajo empiezan en 0xE000, con los nombres que tiene
    # confirmados el listado de este cartucho: 0xE000 es la escena que reparte
    # 0x40A7, 0xE001 la bandera de partida en marcha, 0xE002 el modo que deja
    # el menu (bit 5, dos jugadores; bit 4, teclado), 0xE003 el reloj de
    # cuadros, 0xE004 el plazo, 0xE051 la fase en BCD, 0xE05C la fase contada
    # desde cero y 0xE05D su mascara de color.
    foreach {nombre dir} {escena 0xE000 partida 0xE001 modo 0xE002
                          reloj 0xE003 plazo 0xE004 fase 0xE051
                          tanda 0xE05C mascara 0xE05D} {
        puts $f [format {%s %d} $nombre [debug read memory $dir]]
    }
    close $f
    catch { screenshot -raw $::SALIDA/pant_$i.png }
}

# --- la barra de espacio, que es con lo que se elige y se saca ---------------
proc pulsa {} {
    keymatrixdown 8 0x01
    after time 0.4 suelta
}
proc suelta {} {
    keymatrixup 8 0x01
}

# --- calendario -------------------------------------------------------------
# El logotipo de la casa sale primero y la pantalla de eleccion despues; antes
# de los 6 s la VRAM esta a medio pintar y no es comparable con nada. Se pulsa
# espacio para elegir un jugador y arrancar, y a partir de ahi los volcados
# cogen la fase ya montada.
after time  6.0 { vuelca logotipo }
after time 10.0 { vuelca titulo }
after time 14.0 { vuelca titulo }
after time 18.0 { vuelca titulo }
after time 22.0 { pulsa }
after time 24.0 { pulsa }
after time 28.0 { vuelca fase }
after time 34.0 { vuelca fase }
after time 40.0 { vuelca fase }
after time 42.0 { exit }

# perro guardian de tiempo REAL: un guion roto no puede colgar el emulador
after realtime 240 {
    puts {PERRO GUARDIAN a los 240 s reales}
    exit
}
