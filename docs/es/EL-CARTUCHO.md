# El cartucho

16 KB en la página 1 (`0x4000-0x7FFF`), cabecera `AB` con INIT en `0x4077` y
sin BASIC. Pantalla en SCREEN 2.

## La VRAM, al revés de lo habitual

Los ocho registros los baja `0x44EE` desde `0x44FF`: `02 E2 0E 7F 07 76 03 E1`.
En SCREEN 2, R3 y R4 son base y máscara, así que **el color va en `0x0000` y
los patrones en `0x2000`**.

| zona | qué hay |
|---|---|
| `0x0000` | la tabla de color |
| `0x1800` | los patrones de sprite |
| `0x2000` | los patrones |
| `0x3800` | la tabla de nombres |
| `0x3B00` | los atributos de los sprites |
| `0x3B80` | **el guion de la fase**: entre 723 y 918 bytes |

## La RAM

**Toda la RAM del juego es 1 KB**: `0xE000-0xE3FF`, puesta a cero por INIT. La
pila, en `0xE400`.

| zona | qué hay |
|---|---|
| `0xE000` | la escena en curso |
| `0xE003` | el contador de cuadros |
| `0xE005` | el cerrojo de la interrupción, de un bit |
| `0xE010` | las tres voces del sonido, once bytes cada una |
| `0xE050` | el jugador en turno, 32 bytes; el otro, en `0xE080` |
| `0xE051` | el número de fase, en BCD |
| `0xE05C` / `0xE05D` | la fase contada desde cero y su máscara de color |
| `0xE0B0` | el búfer de los sprites |
| `0xE132` | los cuarenta objetos: fila, columna y tipo |
| `0xE1DE` | las tres arañas, nueve bytes cada una |

## La BIOS

Usa ocho rutinas: RDVDP, RDVRM, SETRD, SETWRT, WRTVDP, WRTPSG, RDPSG y SNSMAT.

## Las dos pantallas de menú

Están dibujadas desde la ROM y cotejadas contra openMSX a **0 bytes**.

![La pantalla de la casa](../imagenes/pantalla-presentacion.png)

![La pantalla de título](../imagenes/pantalla-titulo.png)
