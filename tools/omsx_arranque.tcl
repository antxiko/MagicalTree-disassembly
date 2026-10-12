# omsx_arranque.tcl - Los PRIMEROS CUADROS de la partida: RAM y VRAM.
#
# Vuelca en el primer paso por 0x4184 (el cuadro de partida, escena 11) y
# despues en el vuelco de sprites de 0x52A2 de los cuadros que diga CUADROS,
# sin tocar el mando. Es contra lo que se coteja tools/corre_magical.py.
#
#   "C:/Program Files/openMSX/openmsx.exe" -machine Philips_VG_8020 #       -cart magicaltree.rom -script tools/omsx_arranque.tcl
#
# Deja en work/arranque/ partida_cK.vram (16 KB) y partida_cK.ram (0xE000..0xE3FF),
# o demo_cK.* con PP_MODO=demo (y PP_CUADROS con los cuadros de la demo).

proc opcion {nombre porDefecto} {
    global env
    if {[info exists env($nombre)]} { return $env($nombre) }
    return $porDefecto
}

set ::SALIDA [opcion PP_SALIDA {C:/Users/Antxiko/Documents/DES_ASM/MAGICALTREE_DISAM/work/arranque}]
file mkdir $::SALIDA
set ::bp_vuelca {}
set ::CUADROS [opcion PP_CUADROS {1 2 3 5 10 25 50 100 200}]
set ::cuadro 0

proc empieza_a_contar {} {
    set ::cuadro 0
    if {$::bp_vuelca ne {}} { debug remove_bp $::bp_vuelca; set ::bp_vuelca {} }
    set ::bp_vuelca [debug set_bp 0x52A2 {} {cuenta_cuadro}]
}

proc vuelca {nombre} {
    set f [open $::SALIDA/$nombre.vram w]
    fconfigure $f -translation binary
    puts -nonewline $f [debug read_block VRAM 0 16384]
    close $f
    set f [open $::SALIDA/$nombre.ram w]
    fconfigure $f -translation binary
    puts -nonewline $f [debug read_block memory 0xE000 1024]
    close $f
}

proc cuenta_cuadro {} {
    incr ::cuadro
    if {[lsearch $::CUADROS $::cuadro] >= 0} {
        vuelca [format {%s_c%04d} $::MODO $::cuadro]
        puts [format {cuadro %d t=%s} $::cuadro [machine_info time]]
    }
    if {$::cuadro >= [lindex $::CUADROS end]} {
        debug remove_bp $::bp_vuelca; set ::bp_vuelca {}
    }
}

# PP_MODO=demo: sin tocar nada, la DEMOSTRACION del titulo (escena 7, 0x412F),
# que sube el arbol ella sola. Cuenta desde su primer cuadro.
set ::MODO [opcion PP_MODO partida]
proc arranca {} {
    if {$::MODO eq "demo"} {
        set ::bp_montado [debug set_bp 0x412F {} {vuelca demo_c000; debug remove_bp $::bp_montado; empieza_a_contar}]
    } else {
        set ::bp_montado [debug set_bp 0x4184 {} {vuelca partida_c000; debug remove_bp $::bp_montado; empieza_a_contar}]
    }
}
proc pulsa {} {
    keymatrixdown 8 0x01
    after time 0.4 suelta
}
proc suelta {} {
    keymatrixup 8 0x01
}
after time 1.0 { arranca }
if {$::MODO ne "demo"} {
    after time 16.0 { pulsa }
    after time 18.0 { pulsa }
    after time 20.0 { pulsa }
}
after time 90.0 { exit }

after realtime 600 {
    puts {PERRO GUARDIAN a los 600 s reales}
    exit
}
