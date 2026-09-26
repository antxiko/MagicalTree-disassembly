#!/usr/bin/env python3
"""El CONTENIDO de la portada: los hallazgos y los pies de la galeria.

Va aparte de make_web.py a proposito. make_web.py es el generador -la
plantilla, la maquetacion, el HTML- y no cambia de un juego al siguiente; esto
es lo unico que hay que reescribir entero en cada cartucho. Teniendolo separado
no hay que ir buscando los textos del juego anterior dentro del generador, que
es justo como se han colado los nombres equivocados otras veces.

Cada hallazgo es (titulo, html) y cada entrada de galeria
(fichero, pie en castellano, pie en ingles).

Todas las cifras de aqui estan medidas sobre este cartucho, con las
herramientas de tools/, y no copiadas de ningun otro proyecto.
"""

HALLAZGOS = {
    "es": [
        ("El nivel vive en la VRAM",
         "<p><code>0x52BB</code> sube el guion de la fase a <code>0x3B80</code>, "
         "detras de la tabla de atributos de los sprites: entre 723 y 918 "
         "bytes, segun la fase. El juego tiene <b>un kilobyte de RAM</b> y va "
         "leyendo su nivel del VDP segun se sube.</p>"),

        ("Las piezas que no borran",
         "<p><code>0x6889</code> solo borra la fila que deja un objeto al "
         "bajar si su tipo <b>no</b> lleva el bit 7. Las que lo llevan dejan "
         "su primera fila detras, y asi se alarga el <b>hilo de las "
         "aranas</b>.</p>"),

        ("La pantalla es el mapa",
         "<p>No hay copia del nivel en RAM. Para saber donde pisa el jugador, "
         "<code>0x61A3</code> lee de la VRAM las dos celdas que tiene bajo los "
         "pies, y los bichos, antes de avanzar, <b>preguntan a la "
         "pantalla</b> si la celda de delante deja pasar.</p>"),

        ("El azar es el registro R",
         "<p>Nueve <code>ld a,r</code>: el contador de refresco del Z80, que "
         "avanza solo con cada instruccion, decide el color de un bicho, en "
         "que sitio aparece o que proyectil sale.</p>"),

        ("Nueve cielos, una mascara",
         "<p>El hueco de cada fase toma el color de <code>(0xE05D)</code>: "
         "cian, verde claro, amarillo claro, gris, negro... La primera no la "
         "saca de la tabla de <code>0x741F</code> sino de los valores "
         "iniciales de <code>0x51C1</code>; con el primer valor de la tabla, "
         "el cotejo se separa en <b>1.809 bytes</b> de color.</p>"),

        ("Hermano de Circus Charlie",
         "<p>El descompresor tiene la misma firma de catorce bytes que el del "
         "RC-712, la escala cromatica son los mismos doce bytes y la vida "
         "extra sigue la misma regla: <b>el mismo codigo</b>, en otro "
         "sitio.</p>"),
    ],
    "en": [
        ("The level lives in VRAM",
         "<p><code>0x52BB</code> uploads the stage script to "
         "<code>0x3B80</code>, behind the sprite attribute table: between 723 "
         "and 918 bytes, depending on the stage. The game has <b>one kilobyte "
         "of RAM</b> and reads its level back from the VDP as you climb.</p>"),

        ("The pieces that do not erase",
         "<p><code>0x6889</code> only erases the row an object leaves behind "
         "when its type does <b>not</b> have bit 7 set. The ones that do "
         "leave their first row behind, and that is how the <b>spiders' "
         "threads</b> grow.</p>"),

        ("The screen is the map",
         "<p>There is no copy of the level in RAM. To know where the player "
         "stands, <code>0x61A3</code> reads the two cells under the player's "
         "feet from VRAM, and the creatures, before moving, <b>ask the screen</b> "
         "whether the cell ahead lets them through.</p>"),

        ("Randomness is the R register",
         "<p>Nine <code>ld a,r</code>: the Z80's refresh counter, which ticks "
         "by itself with every instruction, decides a creature's colour, "
         "where it appears or which projectile comes out.</p>"),

        ("Nine skies, one mask",
         "<p>The empty cell of each stage takes the colour of "
         "<code>(0xE05D)</code>: cyan, light green, light yellow, grey, "
         "black... The first one does not come from the table at "
         "<code>0x741F</code> but from the initial values at "
         "<code>0x51C1</code>; with the table's first value, the check drifts "
         "by <b>1,809 bytes</b> of colour.</p>"),

        ("Circus Charlie's sibling",
         "<p>The decompressor has the same fourteen-byte signature as the "
         "RC-712's, the chromatic scale is the same twelve bytes and the "
         "extra life follows the same rule: <b>the same code</b>, somewhere "
         "else.</p>"),
    ],
}

GALERIA = [
    ("arbol-nueve-fases.png",
     "Las nueve fases enteras, una al lado de otra y apoyadas en el suelo: "
     "de abajo arriba se suben. Cada una, a tamano completo, en El juego.",
     "The nine whole stages side by side, standing on the ground: they are "
     "climbed bottom to top. Each one, full size, in The game."),
] + [
    ("arbol-fase-%d-pie.png" % n,
     "La fase %d al empezar: su primera pantalla, desde el guion de la ROM y "
     "cotejada contra openMSX a 0 celdas." % n,
     "Stage %d at the start: its first screen, from the ROM's script and "
     "checked against openMSX down to 0 cells." % n)
    for n in range(1, 10)
] + [
    ("pantalla-presentacion.png",
     "La pantalla de la casa, montada desde la ROM y cotejada a 0 bytes.",
     "The company screen, built from the ROM and checked down to 0 bytes."),
    ("pantalla-titulo.png",
     "La de titulo, montada igual y cotejada a 0 bytes.",
     "The title screen, built the same way and checked down to 0 bytes."),
    ("decorado-A.png",
     "El arbol que 0x7629 pinta al cambiar de fase, del centro hacia fuera "
     "y con los colores de la fase que empieza (aqui, la 2). Cotejado a 0 "
     "bytes.",
     "The tree 0x7629 paints when the stage changes, from the middle "
     "outwards and in the colours of the stage that starts (here, stage 2). "
     "Checked down to 0 bytes."),
    ("decorado-B.png",
     "El castillo, al acabar la novena: sus columnas del centro hacia fuera, "
     "las ventanas de 0x7600 con los dos personajes y el rotulo. Cotejado a "
     "0 bytes.",
     "The castle, after the ninth stage: its columns from the middle "
     "outwards, the windows at 0x7600 with the two characters and the "
     "sign. Checked down to 0 bytes."),
    ("tiles-fase.png",
     "Los patrones de la fase, con la mascara de color de la primera.",
     "The stage's patterns, with the first stage's colour mask."),
    ("sprites.png",
     "Los sprites de 16x16, desde los bloques de la ROM.",
     "The 16x16 sprites, from the ROM's blocks."),
]
