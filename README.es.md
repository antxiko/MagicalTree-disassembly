# Magical Tree (Konami, MSX) — desensamblado comentado

*(Also available [in English](README.md).)*

Cartucho **RC-713** de 16 KB, 1984. El listado de `src/magicaltree.asm`
reensambla la ROM **byte a byte** con `pasmo`, y cada uno de sus 16.384 bytes
está asignado: **8.537 de código y 7.847 de datos**. Son **628 rutinas,
ninguna por debajo del 10 % comentado**, y una densidad del **47,4 %**.

Las nueve fases del árbol están dibujadas desde la ROM, con el guion de cada
fase y el paso del decorado del cartucho escritos en Python, y cotejadas contra
openMSX: **156 volcados, 104.832 celdas, cero distintas**.

La ROM no se distribuye.

- Web: https://antxiko.github.io/MagicalTree-disassembly/es/
- Para empezar: [docs/es/EMPEZAR.md](docs/es/EMPEZAR.md)
- Aviso legal: [AVISO-LEGAL.md](AVISO-LEGAL.md)
