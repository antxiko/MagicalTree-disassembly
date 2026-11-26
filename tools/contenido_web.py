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

NOMBRE = 'Magical Tree'

ANIO = 1984

REPOSITORIO = 'https://github.com/antxiko/MagicalTree-disassembly'
CODIGO = 8537
COMENTARIOS = 2258
DATOS = 7847
DENSIDAD = '47,4'
DENSIDAD_EN = '47.4'
ESTILO = '\n:root{--tinta:#cfd0d4;--suave:#83868f;--fondo:#000;--panel:#0c0e13;--linea:#23262e;\n  --rojo:#ff897d;--cyan:#65dbef;--verde:#3eb849;--oro:#ded087}\n@media (prefers-color-scheme:light){:root{--tinta:#191a1e;--suave:#5a5d66;--fondo:#e9e7e1;\n  --panel:#f7f6f2;--linea:#d0cdc5;--rojo:#b23f34;--cyan:#1c6b7c;--verde:#2b7734;--oro:#8a7420}}\n:root[data-theme="dark"]{--tinta:#cfd0d4;--suave:#83868f;--fondo:#000;--panel:#0c0e13;\n  --linea:#23262e;--rojo:#ff897d;--cyan:#65dbef;--verde:#3eb849;--oro:#ded087}\n:root[data-theme="light"]{--tinta:#191a1e;--suave:#5a5d66;--fondo:#e9e7e1;--panel:#f7f6f2;\n  --linea:#d0cdc5;--rojo:#b23f34;--cyan:#1c6b7c;--verde:#2b7734;--oro:#8a7420}\n*{box-sizing:border-box}\nbody{margin:0;background:var(--fondo);color:var(--tinta);padding:0 1.25rem 6rem;\n  font:15px/1.7 ui-monospace,"SF Mono",Menlo,Consolas,monospace}\n.w{max-width:1120px;margin:0 auto}\n.n{max-width:68ch}\nh1,h2,h3,h4{font-weight:400;text-wrap:balance}\na{color:var(--cyan)}\nimg{image-rendering:pixelated;max-width:100%;height:auto;display:block}\nheader.top{display:flex;flex-direction:column;align-items:center;gap:1.5rem;\n  padding:4rem 0 2rem;text-align:center}\nheader.top img{width:min(100%,642px)}\n.claim{max-width:60ch;color:var(--suave);font-size:1.05rem}\n.claim b{color:var(--tinta);font-weight:400}\n.ficha{display:flex;flex-wrap:wrap;justify-content:center;gap:0 1.5rem;width:100%;\n  font-size:12px;letter-spacing:.08em;text-transform:uppercase;color:var(--suave);\n  border-top:1px solid var(--linea);border-bottom:1px solid var(--linea);padding:.85rem 0}\n.ficha b{color:var(--rojo);font-weight:400}\nnav{display:flex;flex-wrap:wrap;gap:1.25rem;justify-content:center;padding:1.25rem 0;\n  font-size:12px;letter-spacing:.08em;text-transform:uppercase}\nnav a{color:var(--suave);text-decoration:none;border-bottom:1px solid transparent}\nnav a:hover,nav a:focus{color:var(--tinta);border-bottom-color:var(--rojo)}\nnav.docs{border-top:1px solid var(--linea);border-bottom:1px solid var(--linea);\n  margin-bottom:1rem}\nsection{margin-top:4.5rem;scroll-margin-top:1rem}\nsection>h2{font-size:1rem;letter-spacing:.1em;text-transform:uppercase;\n  border-left:3px solid var(--rojo);padding-left:.9rem;margin:0 0 1.5rem}\n.cifras{display:grid;gap:1px;background:var(--linea);border:1px solid var(--linea);\n  grid-template-columns:repeat(auto-fit,minmax(160px,1fr))}\n.cifra{background:var(--panel);padding:1.1rem}\n.cifra b{display:block;font-size:1.7rem;color:var(--oro);font-weight:400;\n  font-variant-numeric:tabular-nums;line-height:1.2}\n.cifra span{font-size:11px;letter-spacing:.07em;text-transform:uppercase;color:var(--suave)}\n.hall{border-top:1px solid var(--linea);padding-top:1.75rem;margin-top:2.5rem}\n.hall:first-of-type{border-top:0;padding-top:0;margin-top:0}\n.hall h3{margin:0 0 .75rem;font-size:1.15rem;color:var(--rojo)}\n.hall h4{color:var(--oro);margin:1.5rem 0 .5rem;font-size:.95rem}\n.hall p{margin:0 0 1rem}\npre.asm{background:var(--panel);border-left:2px solid var(--verde);margin:1.25rem 0;\n  padding:1rem 1.1rem;overflow-x:auto;font-size:13px;line-height:1.6;color:var(--tinta)}\n.par{display:grid;gap:1.25rem;grid-template-columns:1fr}\n@media(min-width:820px){.par{grid-template-columns:1fr 1fr}}\n.par figure{margin:0}\ntable{border-collapse:collapse;width:100%;margin:1.25rem 0;font-size:13px;display:block;\n  overflow-x:auto}\nth,td{text-align:left;padding:.5rem .75rem;border-bottom:1px solid var(--linea)}\nth{color:var(--suave);font-weight:400;font-size:11px;letter-spacing:.07em;text-transform:uppercase}\ntd.num{font-variant-numeric:tabular-nums;color:var(--oro)}\n.nivel{margin-top:2rem}\n.nivel h3{margin:0 0 .9rem;font-size:.95rem;letter-spacing:.06em;text-transform:uppercase}\n.nivel em{color:var(--cyan);font-style:normal}\n.sep{color:var(--suave);margin:0 .6rem}\n.rejilla{display:grid;gap:.9rem;grid-template-columns:repeat(auto-fill,minmax(250px,1fr))}\n.rejilla figure{margin:0;background:var(--panel);box-shadow:0 0 0 1px var(--linea)}\n.rejilla figcaption{display:flex;justify-content:space-between;padding:.45rem .65rem;\n  font-size:11px;color:var(--suave);border-top:1px solid var(--linea)}\n.dir{font-variant-numeric:tabular-nums;color:var(--verde)}\nfooter{margin-top:5rem;padding-top:1.5rem;border-top:1px solid var(--linea);\n  color:var(--suave);font-size:12px}\n\n/* Aviso de trabajo en curso: tiene que verse antes que las cifras, porque un\n   100% mal leido hace mas dano que no ponerlo. */\n.aviso{background:#3a2a10;border-left:3px solid var(--oro);margin:1.5rem auto;\n  padding:1rem 1.2rem;max-width:900px;border-radius:4px}\n.aviso p{margin:0;color:var(--tinta);font-size:15px;line-height:1.65}\n.galeria{display:grid;grid-template-columns:repeat(auto-fit,minmax(280px,1fr));\n  gap:1.5rem;margin:1.5rem 0}\n.galeria figure{margin:0}\n.galeria img{width:100%;height:auto;image-rendering:pixelated;\n  border:1px solid var(--linea);border-radius:3px}\n.galeria figcaption{color:var(--suave);font-size:13px;margin-top:.5rem}\naudio{display:block;width:100%;max-width:640px;margin:.75rem 0 1.5rem}\n'
INSTRUCCIONES = 4767
RUTINAS = 628

EDITOR = 'Konami'

PORTADA = {
    'es': dict(
        titulo='Magical Tree - desensamblado comentado',
        claim='Un arbol de nueve fases que el cartucho guarda en la VRAM, una pantalla que hace de mapa, y las nueve fases dibujadas desde las tablas sin una celda distinta del emulador.',
        ficha=['Konami - <b>(c) Konami 1984</b>', 'Cartucho <b>RC-713</b>, 16 KB', 'MSX1 - <b>pagina 1</b>', 'Volcado <b>a3f3ad0d...</b>'],
        h_num='El cartucho en cifras',
        cifras=[('100 %', 'del binario explicado'), ('628', 'rutinas con nombre'), ('47,4 %', 'del listado comentado'), ('8.537', 'bytes de codigo'), ('7.847', 'bytes de datos'), ('0', 'bytes sin identificar')],
        pie_leg='Esto es trabajo de documentacion y preservacion: el codigo y los graficos siguen siendo de sus autores y de Konami, y la imagen del cartucho no se distribuye.',
        aviso='<b>Aqui no hay ninguna captura.</b> Todas las imagenes estan <b>dibujadas desde los bytes de la ROM</b>: las pantallas con la cadena de montaje del cartucho escrita en Python, y el arbol con <b>el guion de cada fase y su paso del decorado</b>, cotejado contra openMSX a cero celdas. El listado y las cifras se reproducen con <code>make</code>, y el reensamblado devuelve la ROM <b>byte a byte</b>.',
    ),
    'en': dict(
        titulo='Magical Tree - a commented disassembly',
        claim='A nine-stage tree the cartridge keeps in VRAM, a screen that doubles as the map, and all nine stages drawn from the tables without one cell differing from the emulator.',
        ficha=['Konami - <b>(c) Konami 1984</b>', 'An <b>RC-713</b> 16 KB cartridge', 'MSX1 - <b>page 1</b>', 'Dump <b>a3f3ad0d...</b>'],
        h_num='The cartridge in numbers',
        cifras=[('100%', 'of the binary explained'), ('628', 'named routines'), ('47.4%', 'of the listing commented'), ('8,537', 'bytes of code'), ('7,847', 'bytes of data'), ('0', 'bytes unidentified')],
        pie_leg='This is documentation and preservation work: the code and artwork still belong to their authors and to Konami, and the cartridge image is not distributed.',
        aviso="<b>Not one capture here.</b> Every picture is <b>drawn from the bytes of the ROM</b>: the screens with the cartridge's own set-up chain rewritten in Python, and the tree with <b>each stage's script and its scenery step</b>, checked against openMSX down to zero cells. The listing and the numbers are reproducible with <code>make</code>, and reassembling gives back the ROM <b>byte for byte</b>.",
    ),
}

# La portada: las cifras y el pie tal como estaban
for _i, _c in {'es': ([('100 %', 'del binario explicado'), ('628', 'rutinas con nombre'), ('47,4 %', 'del listado comentado'), ('8.537', 'bytes de codigo'), ('7.847', 'bytes de datos'), ('0', 'bytes sin identificar')], 'El cartucho en cifras', 'Esto es trabajo de documentacion y preservacion: el codigo y los graficos siguen siendo de sus autores y de Konami, y la imagen del cartucho no se distribuye.'), 'en': ([('100%', 'of the binary explained'), ('628', 'named routines'), ('47.4%', 'of the listing commented'), ('8,537', 'bytes of code'), ('7,847', 'bytes of data'), ('0', 'bytes unidentified')], 'The cartridge in numbers', 'This is documentation and preservation work: the code and artwork still belong to their authors and to Konami, and the cartridge image is not distributed.')}.items():
    PORTADA[_i]["cifras"] = _c[0]
    PORTADA[_i]["h_num"] = _c[1]
    PORTADA[_i]["pie_leg"] = _c[2]
PORTADA['es']['aviso'] = '<b>Aqui no hay ninguna captura.</b> Todas las imagenes estan <b>dibujadas desde los bytes de la ROM</b>: las pantallas con la cadena de montaje del cartucho escrita en Python, y el arbol con <b>el guion de cada fase y su paso del decorado</b>, cotejado contra openMSX a cero celdas. El listado y las cifras se reproducen con <code>make</code>, y el reensamblado devuelve la ROM <b>byte a byte</b>.'
PORTADA['en']['aviso'] = "<b>Not one capture here.</b> Every picture is <b>drawn from the bytes of the ROM</b>: the screens with the cartridge's own set-up chain rewritten in Python, and the tree with <b>each stage's script and its scenery step</b>, checked against openMSX down to zero cells. The listing and the numbers are reproducible with <code>make</code>, and reassembling gives back the ROM <b>byte for byte</b>."

PAGINAS = [
    [('THE-GAME.html', 'EL-JUEGO.html', 'The game', 'El juego',
      'what the game is and how it plays',
      'qu&eacute; es el juego y c&oacute;mo se juega'),
     ('THE-PICTURES.html', 'LAS-IMAGENES.html', 'What the cartridge draws', 'Lo que el cartucho dibuja',
      'every picture drawn from the ROM, with its caption',
      'todas las im&aacute;genes dibujadas desde la ROM, con su pie'),
     ('THE-MUSIC.html', 'LA-MUSICA.html', 'The music', 'La m&#250;sica',
      'the tunes, from its own sound engine',
      'las m&uacute;sicas, de su propio motor de sonido')],
    [('CURIOSITIES.html', 'CURIOSIDADES.html', 'Curiosities', 'Curiosidades',
      'what turned up when taking it apart, and what is still open',
      'lo que apareci&oacute; al desmontarlo y lo que queda abierto')],
    [('UNDER-THE-HOOD.html', 'POR-DENTRO.html', 'Under the hood', 'Por dentro',
      'getting started, the cartridge, the code and the emulator',
      'empezar, el cartucho, el c&oacute;digo y el emulador')],
]

VIEJAS = {
    'FINDINGS.html': 'CURIOSITIES.html',
    'HALLAZGOS.html': 'CURIOSIDADES.html',
    'GETTING-STARTED.html': 'UNDER-THE-HOOD.html',
    'EMPEZAR.html': 'POR-DENTRO.html',
    'IN-THE-EMULATOR.html': 'UNDER-THE-HOOD.html',
    'EN-EL-EMULADOR.html': 'POR-DENTRO.html',
    'OPEN-QUESTIONS.html': 'CURIOSITIES.html',
    'PREGUNTAS-ABIERTAS.html': 'CURIOSIDADES.html',
    'THE-CARTRIDGE.html': 'UNDER-THE-HOOD.html',
    'EL-CARTUCHO.html': 'POR-DENTRO.html',
    'THE-CODE.html': 'UNDER-THE-HOOD.html',
    'EL-CODIGO.html': 'POR-DENTRO.html',
}

LOGOTIPO = 'rotulo.png'

PIE_LEGAL = {'es': '<em>Magical Tree</em> lo publico Konami para MSX en 1984; su numero de catalogo es RC-713 y son 16 KB. Todos los derechos sobre el juego siguen siendo de sus titulares. Este trabajo es de preservacion, estudio y documentacion, y la imagen del cartucho no se distribuye.', 'en': '<em>Magical Tree</em> was published by Konami for the MSX in 1984; its catalogue number is RC-713 and it is 16 KB. All rights in the game remain with their holders. This is preservation, study and documentation work, and the cartridge image is not distributed.'}
