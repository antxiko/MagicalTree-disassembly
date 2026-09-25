# In the emulator

With openMSX and the `Philips_VG_8020` machine:

    echo 3 > work/fase.txt
    openmsx -machine Philips_VG_8020 -cart magicaltree.rom -script tools/omsx_fases.tcl

`tools/omsx_fases.tcl`:

- reads the stage from `work/fase.txt` (0 to 8) and writes it into `0xE05C`,
  `0xE05D` and `0xE051` at `0x51D2`, before the graphics are set up;
- dumps RAM and VRAM on the first game frame (`0x4184`), which is step 26;
- climbs the stage without playing it: stopped on the `jr $` at `0x40A5`, it
  runs `0x6749` thirty times from a piece of code at `0xE800`, with the hook
  replaced by a `ret` so that the game frame does not draw in between;
- dumps every thirty steps, up to the end of the stage, into `work/fases/`.

The whole game happens in the hook at `0x402C`: a breakpoint there stops once
per frame.

A warning: if a breakpoint's command fails, openMSX freezes the emulation. The
script wraps its commands in `catch` and logs the error in
`work/fases/log.txt`.
