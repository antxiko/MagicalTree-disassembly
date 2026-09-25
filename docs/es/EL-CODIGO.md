# El código

## Todo en la interrupción

INIT (`0x4077`) pone el modo 1 de interrupción, engancha H.KEYI con un salto a
`0x402C`, deja la pila en `0xE400`, pone a cero el kilobyte de RAM y se queda
en el `jr $` de `0x40A5`. Lo demás pasa en el gancho, una vez por cuadro: el
sonido primero, los mandos, y la escena. Las dieciséis escenas están en la
tabla de `0x40C3`, pegada detrás del `call` del despachador de `0x404A`, que la
encuentra con un `pop hl`.

El cuadro de la partida (`0x51F5`) son once llamadas seguidas, una por cada
cosa que se mueve.

## Subir el árbol

- `0x52BB` sube el guion de la fase a `0x3B80`.
- `0x6749` da un paso: cuenta y, cuando llega a los pasos de la siguiente
  entrada, la saca a los cuarenta objetos de `0xE132`. Las arañas (tipo
  `0xE0`) van a sus tres fichas de `0xE1DE`.
- `0x6889` baja cada objeto ocho píxeles, borra la fila que deja —solo si el
  tipo no lleva el bit 7— y lo repinta; `0x68F8` repinta encima los que llevan
  el bit 6, y `0x6C32` corre las arañas.
- `0x4A0E` elige la pieza en una de cuatro tablas —46 piezas; los nueve
  guiones usan 35 tipos— y `0x49B8` la pinta.
- `0x5363` da veintiséis pasos seguidos para montar la primera pantalla.

## La pantalla es el mapa

No hay mapa en RAM. `0x61A3` lee de la VRAM las dos celdas bajo los pies del
jugador y `0x6465` mira si son el patrón `0x9B`. `0x6251` busca un objeto en la
pantalla para borrarlo, y los bichos miran la celda de delante antes de
avanzar: `0x6EB4` quiere el índice 3, `0x7167` uno entre `0xCD` y `0xD0`.

## El azar

Nueve `ld a,r`: el contador de refresco del Z80.

## Las herramientas

- `tools/arbol.py`: el guion, las piezas y el paso del decorado; dibuja las
  nueve fases.
- `tools/graficos.py`: la VRAM de la fase y las pantallas de menú, con la
  cadena de montaje del cartucho.
- `tools/guiones.py` y `tools/rle.py`: miden los rótulos y los bloques
  comprimidos ejecutando sus intérpretes.
- `tools/coteja_fases.py` y `tools/omsx_fases.tcl`: el cotejo contra openMSX.
