# Mosa Lina - Frog

Author: zuccha, requested by Theopold. Graphics provided by Theopold.

Frog from the Mona Lisa game. The frog is a jumping sprite that can jump back
and forth or in one direction. Mario can ride the frog like a platform.

<img src="./docs/assets/images/frog01.gif" />

## Contents

This package contains the following files:

- `README.txt`: This file.
- `ExGraphics/ExGFX80.bin`: The file containing the graphics for the frog and
  for Yoshi (to ensure compatibility).
- `PIXI/list.txt`: PIXI list file for quick drag-and-drop setup.
- `PIXI/sprites/mosa_lina-frog.asm`: Code for the frog sprite.
- `PIXI/sprites/mosa_lina-frog.json`: Configuration for the frog sprite.
- `GPS/list.txt`: Example list file for deadly and tasty blocks.
- `GPS/mosa_lina-frog_deadly.asm`: Block that soft-kills the frog.
- `GPS/mosa_lina-frog_tasty.asm`: Block that can be eaten by the frog.

## Insertion

To insert the sprite, do the following:

1. Copy `PIXI/list.txt` in PIXI's main folder.
2. Copy `PIXI/sprites/mosa_lina-frog.asm` and `PIXI/sprites/mosa_lina-frog.json`
   in PIXI's `sprites` folder.
3. Copy `ExGraphics/ExGFX80.bin` in the ROM's `ExGraphics` folder, then insert
   graphics via Lunar Magic. You can change "80" into any free ExGFX number.
4. Open "Super GFX Bypass" menu in Lunar Magic and change "SP3" to "80" (or the
   number of your choice).
5. Run PIXI.
6. Insert the sprite in Lunar Magic, a few presets are available. Customization
   options are described in detail in `PIXI/sprites/mosa_lina-frog.asm`.

## Compatibility

Compatible with PIXI 1.42, GPS 1.4.4, and Lunar Magic 3.51. Compatibility with
other versions is not guaranteed.

## Known Issues

If the frog spawns mid-air or if it suddenly finds itself mid-air (e.g., solid
blocks disappear from under its feet), the frog will not switch to a falling
animation. This means that if the frog will stay mid-air in a non-falling
animation long enough, it will jump. Fixing this issue caused other issues, so I
let it be.
