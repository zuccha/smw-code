# Orbinaut

Made by zuccha, requested by NopeContest. Bugfixes by MarioFanGamer.

Sprite featuring a central orbinaut, with four spike balls orbiting around it.

<img src="./docs/assets/images/orbinaut-1.gif" />

## Contents

This package contains the following files:

- `README.txt`: This file.
- `ExGraphics/ExGFX80.bin`: The graphics file containing the images for the
  orbinaut and the spike ball. This is a copy of `GFX02.bin`, adding the new
  graphics in empty tiles.
- `Palettes/orbinaut.pal`: Base color palette of level 105, replacing palette
  `F` with orbinaut's colors.
- `PIXI/list.txt`: A list for PIXI setting orbinat and spike ball sprites to
  numbers 00 and 01 respectively. Feel free to use this file if you don't have
  any other custom sprites already inserted in the hack.
- `PIXI/sprites/orbinaut.asm`: Code for the orbinaut sprite.
- `PIXI/sprites/orbinaut.json`: Configuration for the orbinaut sprite.
- `PIXI/sprites/orbinaut_spike_ball.asm`: Code for the spike ball sprite.
- `PIXI/sprites/orbinaut_spike_ball.json`: Configuration for the spike ball
  sprite.

## Usage

Here follow the instructions on how to use and customize this sprite.

### Simple insertion

If you want to insert the sprite with the provided "list.txt" and graphics file,
do the following:

1. Copy `PIXI/list.txt` in PIXI's main folder.
2. Copy `PIXI/sprites/orbinaut.asm`, `PIXI/sprites/orbinaut.json`,
   `PIXI/sprites/orbinaut_spike_ball.asm`, and
   `PIXI/sprites/orbinaut_spike_ball.json` in PIXI's `sprites` folder.
3. Copy `ExGraphics/ExGFX80.bin` in the ROM's `ExGraphics` folder, then insert
   graphics via Lunar Magic. You can change "80" into any free ExGFX number.
4. Open "Super GFX Bypass" menu in Lunar Magic and change "SP4" to "80" (or the
   number of your choice).
5. In Lunar Magic, open the "Palette Editor" and import `Palettes/orbinaut.pal`.
6. Run PIXI.
7. Insert the sprite in Lunar Magic with the "Insert Manual..." command. The
   sprite accepts four extra bytes and the extra bit; their behavior is
   described in detail in `PIXI/sprites/orbinaut.asm`.

### Customize Sprite Numbers

If you change the number for `orbinaut_spike_ball.json` in PIXI's `list.txt`
(anything other than the default "00"), you also have to change `!ball_number`
in `orbinaut.asm` to match that number.

For instance, if you modify `list.txt` as follows

```
12 orbinaut.json
2F orbinaut_spike_ball.json
```

then you have to set `!ball_number = $2F` in `orbinaut.asm`.

### Customize Graphics

If you want to change the position of graphics for the orbinaut and spike ball
in the graphics file and/or use a different graphic slot, you can do so by
modifying their JSON configuration files.

If you want to use SP1 or SP2, set the property _Use second graphics page_ to
`false`. If you want to use SP3 or SP4 set _Use second graphics page_ to `true`.

With the `!gfx_tile` define found in the ASM files you can define what tile to
use. In a graphics file tiles range from `0x00` to `0x7F`. If you put the
graphics file in slots SP1 or SP3, you use the tile value of the graphics file
(`0x00`-`0x7F`). If you put the graphics file in SP2 or SP4, you need to add
`0x80` to the tile value, resulting in values ranging from `0x80` to `0xFF`.

You can check the following table for reference, where columns indicate whether
"Use second graphics page" is `false` (1st) or `true` (2nd), and the rows state
the range values for `!gfx_tile`:

|                 | 1st | 2nd |
| --------------- | --- | --- |
| **`0x00-0x7F`** | SP1 | SP3 |
| **`0x80-0xFF`** | SP2 | SP4 |

By default, both the orbinaut and the spike ball are in the same graphics file
`ExGFX80.bin` at positions `0x40` and `0x60` respectively. In both their JSON
config file "Use second graphics page" is set to `true` and they are specifying
values greater than `0x80` in `!gfx_tile` (_i.e._, `0xC0 = 0x40 + 0x80` and
`0xE0 = 0x60 + 0x80`), meaning we need to load `80` in SP4 via Lunar Magic.

Let's take another example. In Lunar Magic, we set the following SP slots:

- **SP1**: 0
- **SP2**: 2
- **SP3**: 80
- **SP4**: A2

Also, we have `orbinaut.asm` and `orbinaut.json` with the following properties:

- **!gfx_tile**: `146` (`0x92`)
- **Use second graphics page**: `false`

and `orbinaut_spike_ball.asm` and `orbinaut_spike_ball.json`:

- **!gfx_tile**: `36` (`0x24`)
- **Use second graphics page**: `true`

For the orbinaut the game will take tile `0x12` in GFX02.bin (SP2), because we
set "Use second graphics page" to `false` (either SP1 or SP2) and `!gfx_tile` is
`0x92` >= `0x80` (so SP2). For the spike ball the game will take tile `0x24` in
`ExGFX80.bin` (SP3), because we set "Use second graphics page" to `true` (either
SP3 or SP4) and its `!gfx_tile` is `0x24 < 0x80` (so SP3).

### Customize Palette

By default the sprite uses sprite palette 7 (global palette F) both for the
orbinaut and the spike ball.

To change the palettes, you can open the JSON configuration files and change the
_Palette_ property (`0-7`).

## Compatibility

This sprite is compatible with PIXI 1.40, older versions will not work.

The sprite is compatible with SA-1.

The sprite takes 5 sprite slots, 1 for the orbinaut and 4 for the spike balls,
so be mindful when using it!
