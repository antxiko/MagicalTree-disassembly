# Hallazgos

1. **El guion de la fase vive en la VRAM.** `0x52BB` lo sube a `0x3B80`,
   detrás de los atributos de los sprites, y el paso del decorado lo va leyendo
   de ahí con `lee_de_vram` según se sube.
2. **Las piezas con el bit 7 no borran** la fila que dejan al bajar (`0x68CC`).
   De ahí el hilo de las arañas y la escalera del suelo, que llega hasta su
   tramo de arriba.
3. **Las arañas van aparte.** Las entradas de tipo `0xE0` van a tres fichas
   con la fila en 16 bits, que se pintan mientras están entre −16 y 191
   (`0x6C8E`) y se borran al salir (`0x6D41`, con un cero arrastrado con
   `lddr`). Si no queda ficha libre, la araña se queda como un objeto más
   (`0x682C`).
4. **La pantalla hace de mapa**: `0x61A3`, `0x6465`, `0x6251`, `0x6EB4` y
   `0x7167` preguntan a la VRAM lo que otro juego tendría en RAM.
5. **El azar sale del registro R**: nueve `ld a,r`.
6. **Nueve cielos.** La máscara de la primera fase sale de `0x51CE` y no de
   `0x741F`; con el primer valor de la tabla, `0x11`, el cotejo se separa en
   1.809 bytes de color.
7. **El trozo `0x16` se lee a sí mismo.** Cierra los nueve guiones, declara
   dieciséis entradas y tiene quince: la decimosexta son los dos primeros bytes
   de la tabla de trozos. No se nota porque antes llega el `0xFF` que acaba la
   subida.
8. **Dos jugadores, 32 bytes.** La escena 13 (`0x41CF`) permuta los 32 bytes de
   `0xE050` con los de `0xE080`: el jugador en turno está siempre en el mismo
   sitio.
9. **De binario a BCD sin dividir.** `0x66F5` dobla el resultado con
   `adc a,a / daa` por cada bit.
10. **El mismo código que Circus Charlie.** La firma de catorce bytes del
    descompresor, los doce bytes de la escala cromática y la regla de la vida
    extra están igual en el RC-712.
11. **Diez sprites espejados.** `0x60C9` da la vuelta a los 320 bytes de
    `0x5BCD` y los deja en `0x1940`.
12. **Dos comentarios cambiados** en `0x52F1` y `0x52F3`: el primero carga el
    byte alto del puntero y el segundo la cuenta de entradas.
13. **El decorado de entre fases se pinta del centro hacia fuera.** `0x7629`
    saca las columnas en orden, pero el vaivén del plazo las pone en la 15, la
    16, la 14, la 17... Puestas en el orden de la tabla, el castillo sale revuelto.
