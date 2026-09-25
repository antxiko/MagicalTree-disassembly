# Open questions

- **What happens after the ninth stage.** The table at `0x4E1B` has ten
  pointers and the tenth repeats the first, and `0x7545` restores thirteen
  initial values —the stage and its mask among them—, but it has not been
  followed in the emulator.
- **The script at `0x53E4`** that starts each life, with its timer at
  `0xE24D`: how it is walked is known, not what each byte says.
- **Types `0x93`/`0x94`** —the blue figures on the trunk— **and
  `0xC9`/`0xCA`**: which piece they draw is known, not what they are in the
  game.
- **The scoreboard's metres.** The height is divided by sixteen (`0x66C5`),
  but how many steps make a metre has not been measured.
