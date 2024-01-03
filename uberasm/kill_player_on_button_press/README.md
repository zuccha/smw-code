# Kill Player on Button Press

Author: zuccha, requested by The_Uber_Camper

UberASM that kills the player after a button of your choosing has been pressed a
given amount of times.

<img src="./docs/assets/images/kill_1.gif" width="400px" />

## Contents

This bundle contains the following files:

- `UberASMTool/level/level.asm`: The code specific for the level. This is also
  where you tune the behavior of the UberASM.
- `UberASMTool/other/status_code.asm`: Code that draws the amount of times the
  button has been pressed in the status bar. Needed only if you want the counter
  to be visible.
- `PIXI/sprites/indicator.asm`: Code for a sprite that shows an indicator with
  the amount of presses done/left above Mario.
- `PIXI/sprites/indicator.json`: Config for a sprite that shows an indicator
  with the amount of presses done/left above Mario.
- `ExGraphics/Indicator (SP3).bin`: Graphics file that contains the digits to be
  used for the indicator sprite.

## Usage

Here follow the instructions on how to use, display, and configure this UberASM.

### Basic usage

First, you need to copy "level.asm" file inside UberASMTool's "level" folder.
Rename it to something like "level_105.asm".

Open the copied file, and change the settings. In the file you can choose which
button presses to detect, how many presses are needed to kill Mario, and other
things. Everything is documented in the file.

Open UberASMTool's "list.txt" and add the following under the `level:` label:

```uberasm
105 level_105.asm
```

Obviously, use the level you actually want to insert the code into.

Run UberASMTool, and it should work.

### Show the counter over Mario's head

Note that this step is optional, you need to do this only if you want the
counter to be visible over Mario's head.

You can show the indicator over Mario's head via the sprite "indicator.asm". The
sprite requires the bundled "Indicator (SP3).bin", or any graphics file
containing the digits 0-9. In case of a custom ExGFX file, you can set the
position of the digits tiles with the `gfx_tiles` table in "indicator.asm". You
can choose which SP slot to use with `!gfx_sp` (the default is SP3).

The sprite will follow Mario whenever he goes. You can choose to show the inputs
done or the inputs remaining via the extra bit.

### Show the counter in the status bar

Note that this step is optional, you need to do this only if you want the
counter to be visible in the status bar.

By default, the counter is not visible in the status bar. To make it appear, we
need to add the routine that draws the counter.

Copy the file "status_code.asm" in UberASMTool's "other" folder. The file
already exists, you can replace it if you never touched the one that was already
there.

If you already modified "other/status_code.asm", you'll need to merge the two
files. Check the
[instructions on SMWCentral](https://www.smwcentral.net/?p=faq&page=1515827-uberasm)
to see how to do that.

### Free RAM

This UberASM uses two bytes of free RAM to keep track of how many times the
player has pressed the button, and if the counter is visible in the status bar
or not.

By default, they are defined as follows:

```asar
!ram_button_presses_count       = $140B|!addr
!ram_show_presses_in_status_bar = $140C|!addr
```

These two addresses are configurable. If you need to change them because of
conflicts with other patches, remember to change them in all level files you are
using, in "status_code.asm", and in "indicator.asm".

## Compatibility

This UberASM is compatible with SA-1.
