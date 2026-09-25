# En el emulador

Con openMSX y la máquina `Philips_VG_8020`:

    echo 3 > work/fase.txt
    openmsx -machine Philips_VG_8020 -cart magicaltree.rom -script tools/omsx_fases.tcl

`tools/omsx_fases.tcl`:

- lee la fase de `work/fase.txt` (0 a 8) y la escribe en `0xE05C`, `0xE05D` y
  `0xE051` en `0x51D2`, antes de que se monten los gráficos;
- vuelca RAM y VRAM en el primer cuadro de partida (`0x4184`), que es el
  paso 26;
- sube la fase sin jugarla: parado en el `jr $` de `0x40A5`, ejecuta treinta
  veces `0x6749` desde un trozo de código en `0xE800`, con el gancho cambiado
  por un `ret` para que el cuadro de partida no pinte en medio;
- vuelca cada treinta pasos, hasta el final de la fase, en `work/fases/`.

Todo el juego pasa en el gancho de `0x402C`: un punto de ruptura ahí para una
vez por cuadro.

Un aviso: si la orden de un punto de ruptura falla, openMSX congela la
emulación. El guion envuelve las suyas en `catch` y apunta el error en
`work/fases/log.txt`.
