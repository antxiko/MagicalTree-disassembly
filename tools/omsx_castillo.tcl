# omsx_castillo.tcl - EL CASTILLO, volcado desde openMSX.
#
# El castillo sale al acabar la novena fase: 0x73E3 sube la tanda a 9, cambia
# las columnas del decorado a las de 0x778A y 0x7629 las va pintando. Para
# llegar sin jugar: se fuerza la novena fase al montarse (0x51D2), se sube
# entera con 0x6749 desde un trozo de codigo en 0xE800 -como omsx_fases.tcl-
# y, con el guion ya en su 0xFF, se pone el estado del jugador (0xE1B2) a 12,
# el cambio de fase (0x7395). Desde ahi el juego va solo, y se vuelca la VRAM
# en el vuelco de sprites (0x52A2) de los cuadros de CUADROS.
#
#   "C:/Program Files/openMSX/openmsx.exe" -machine Philips_VG_8020 #       -cart magicaltree.rom -script tools/omsx_castillo.tcl
#
# Deja en work/castillo/ cambioN_cK.vram y cambioN_cK.ram, y log.txt.

set ::RAIZ {C:/Users/Antxiko/Documents/DES_ASM/MAGICALTREE_DISAM}
# la novena por defecto (el castillo); con work/fase.txt, la que diga, para
# ver el decorado de entre fases de una fase normal
set ::FASE 8
catch {
    set f [open $::RAIZ/work/fase.txt r]
    set ::FASE [string trim [read $f]]
    close $f
}
set ::SALIDA $::RAIZ/work/castillo
file mkdir $::SALIDA

# 0x741F, y la de la primera, que es la de los valores iniciales de 0x51C1
set ::MASCARAS {0x77 0x33 0xBB 0xEE 0x11 0xBB 0xEE 0x11 0x11}
# el paso del 0xFF de cada guion, medido en tools/arbol.py
set ::FINES {451 493 508 498 491 515 549 473 515}
set ::FIN [lindex $::FINES $::FASE]
set ::TANDA 30

set ::paso 26
set ::estado 0

set ::LOG [open $::SALIDA/log.txt w]
proc apunta {texto} {
    puts $::LOG "[machine_info time] $texto"
    flush $::LOG
}

set ::CUADROS {50 150 300 450 600 800 1000 1300}
proc cuenta_cuadro {} {
    incr ::cuadro
    if {[lsearch $::CUADROS $::cuadro] >= 0} {
        vuelca [format {cambio%d_c%04d} [expr {$::FASE + 1}] $::cuadro]
    }
    if {$::cuadro >= [lindex $::CUADROS end]} { after time 0.1 exit }
}

proc vuelca {{nombre {}}} {
    if {$nombre eq {}} { set nombre [format {fase%d_p%04d} [expr {$::FASE + 1}] $::paso] }
    set f [open $::SALIDA/$nombre.vram w]
    fconfigure $f -translation binary
    puts -nonewline $f [debug read_block VRAM 0 16384]
    close $f
    set f [open $::SALIDA/$nombre.ram w]
    fconfigure $f -translation binary
    puts -nonewline $f [debug read_block memory 0xE000 1024]
    close $f
    apunta "volcado $nombre"
}

proc fuerza_la_fase {} {
    debug write memory 0xE05C $::FASE
    debug write memory 0xE05D [lindex $::MASCARAS $::FASE]
    debug write memory 0xE051 [expr {$::FASE + 1}]
}

proc primer_cuadro {} {
    if {$::estado != 0} { return }
    set ::estado 1
}

proc en_el_jr {} {
    if {$::estado == 1} {
        set n [expr {$::FIN - $::paso}]
        if {$n > $::TANDA} { set n $::TANDA }
        if {$n <= 0} {
            # el guion esta en su 0xFF: al cambio de fase, y a contar cuadros
            debug write memory 0xE1B2 12
            set ::estado 4
            set ::cuadro 0
            debug set_bp 0x52A2 {} {seguro cuenta_cuadro}
            apunta "estado 12 puesto en el paso $::paso"
            return
        }
        # ld a,0C9h / ld (0FD9Ah),a / ld b,n
        # bucle: push bc / ld a,1 / ld (0E1AAh),a / call 06749h / pop bc / djnz bucle
        # ld a,0C3h / ld (0FD9Ah),a / jp 040A5h
        set codigo [list 0x3E 0xC9 0x32 0x9A 0xFD 0x06 $n \
                         0xC5 0x3E 0x01 0x32 0xAA 0xE1 0xCD 0x49 0x67 0xC1 0x10 0xF4 \
                         0x3E 0xC3 0x32 0x9A 0xFD 0xC3 0xA5 0x40]
        set a 0xE800
        foreach b $codigo { debug write memory $a $b; incr a }
        set ::paso [expr {$::paso + $n}]
        set ::estado 2
        apunta "tanda de $n pasos, hasta el $::paso"
        reg pc 0xE800
        apunta "pc = [reg pc]"
    } elseif {$::estado == 2} {
        set ::estado 1
    }
}

set throttle off
# un error dentro de la orden de un punto de ruptura PARA la emulacion: se
# apunta y se sale, para no dejar el juego congelado
proc seguro {orden} {
    if {[catch $orden error]} { apunta "ERROR en $orden: $error"; exit }
}
debug set_bp 0x51D2 {} {seguro fuerza_la_fase}
debug set_bp 0x4184 {} {seguro primer_cuadro}
debug set_bp 0x40A5 {} {seguro en_el_jr}

proc pulsa {} {
    keymatrixdown 8 0x01
    after time 0.4 suelta
}
proc suelta {} {
    keymatrixup 8 0x01
}
after time 16.0 { pulsa }
after time 18.0 { pulsa }
after time 20.0 { pulsa }
after time 400.0 { apunta {SIN ACABAR a los 400 s}; exit }
after realtime 600 { puts {PERRO GUARDIAN a los 600 s reales}; exit }
