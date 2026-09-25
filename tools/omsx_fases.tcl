# omsx_fases.tcl - Cada FASE del arbol, entera, volcada desde openMSX.
#
# Es contra lo que se cotejan las tiras de tools/arbol.py. Arranca una partida,
# escribe la fase de work/fase.txt (0..8) en sus tres variables justo antes de
# que 0x51D2 monte los graficos -(0xE05C) la tanda, (0xE05D) su mascara de
# color y (0xE051) el numero en BCD-, y vuelca RAM y VRAM en el primer cuadro
# de partida (0x4184), que es el paso 26: las veintiseis pasadas de 0x5363.
#
# Despues sube la fase sin jugarla: parado en el `jr $` de 0x40A5, copia a
# 0xE800 un trozo de codigo que llama TREINTA veces a 0x6749 -el paso del
# decorado- con (0xE1AA) a 1, que es subiendo, y con el gancho H.KEYI (0xFD9A)
# cambiado por un `ret` para que el cuadro de partida no pinte mientras tanto.
# Vuelve al `jr $`, se vuelca, y otra tanda, hasta el 0xFF del guion.
#
#   echo 3 > work/fase.txt
#   "C:/Program Files/openMSX/openmsx.exe" -machine Philips_VG_8020 \
#       -cart magicaltree.rom -script tools/omsx_fases.tcl
#
# Deja en work/fases/ faseN_pPPPP.vram (16 KB) y faseN_pPPPP.ram (0xE000..0xE3FF).

set ::RAIZ {C:/Users/Antxiko/Documents/DES_ASM/MAGICALTREE_DISAM}
set f [open $::RAIZ/work/fase.txt r]
set ::FASE [string trim [read $f]]
close $f
set ::SALIDA $::RAIZ/work/fases
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

proc vuelca {} {
    set nombre [format {fase%d_p%04d} [expr {$::FASE + 1}] $::paso]
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
    vuelca
    set ::estado 1
}

proc en_el_jr {} {
    if {$::estado == 1} {
        set n [expr {$::FIN - $::paso}]
        if {$n > $::TANDA} { set n $::TANDA }
        if {$n <= 0} { set ::estado 3; after time 0.1 exit; return }
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
        vuelca
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
after time 200.0 { apunta {SIN ACABAR a los 200 s}; exit }
after realtime 600 { puts {PERRO GUARDIAN a los 600 s reales}; exit }
