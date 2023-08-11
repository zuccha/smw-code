# KILL PLAYER ON BUTTON PRESS

Author: zuccha, requested by The_Uber_Camper

UberASM that kills the player after a button of your choosing has been pressed a
given amount of times.

## Contents

This bundle contains the following files:

- level.asm: The code specific for the level. This is also where you tune the
  behavior of the UberASM.
- status_code.asm: Code that draws the amount of times the button has been
  pressed in the status bar. Needed only if you want the counter to be visible.

## Usage

Here follow the instructions on how to use, display, and configure this UberASM.

### Basic usage

First, you need to copy "level.asm" file inside UberASMTool's "level" folder.
Rename it to something like "level_105.asm".

Open the copied file, and change the settings. In the file you can choose which
button presses to detect, how many presses are needed to kill Mario, and other
things. Everything is documented in the file.

Open UberASMTool's "list.txt" and add the following under the `level:` label:

```
105 level_105.asm
```

Obviously, use the level you actually want to insert the code into.

Run UberASMTool, and it should work.

### Show the counter over Mario's head

Note that this step is optional, you need to do this only if you want the
counter to be visible over Mario's head.

You can show the indicator over Mario's head via the sprite "indicator.asm". The
sprite requires the bundled "ExGFX80.bin" (you can use numbers other than 80).

The graphics file needs to contain the ten digits spread on two lines as follows

```
  0 1 2 3 4
  5 6 7 8 9
```

The initial position (the position of tile "0") can be configured with the
`!gfx_initial_tile` define, and you can choose which SP slot to use with
`!gfx_sp`.

The sprite will follow Mario whenever he goes. You can choose to show the inputs
done or the input remaining.

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

```
!ram_button_presses_count       = $140B
!ram_show_presses_in_status_bar = $140C
```

These two addresses are configurable. If you need to change them because of
conflicts with other patches, remember to change them in "status_code.asm" and
in all level files you are using.

## Compatibility

This UberASM is compatible with SA-1 and KevinM's Retry System.

## Changelog

### v1.1.0 (2023-08-11)

Added:

- Add indicator sprite showing the counter over Mario's head.
- Allow to show either inputs left or done on sprite counter.
- Allow to configure which SP slot to use, which initial graphics tile, and the
  palette for the sprite counter.
- Allow to specify the size of digits for the sprite counter.
- Allow to show either inputs left or done on status bar counter.

Changed:

- Default to inputs left in status bar.

### v1.0.0 (2023-08-09)

Added:

- Allow to set the threshold, between 1 and 255.
- Allow to choose which buttons to detect, among A, B, X, X or Y, L, R, Start,
  Select, Down, Up, Left, and Right.
- Allow to choose if the player should die or get hurt when the threshold is
  reached.
- Allow to choose whether the counter should be reset or not when the threshold
  is reached (it applies only if Mario doesn't die).
- Allow to choose whether the counter can be increased (buttons detected) if the
  game is paused.
- Allow to display the counter in the status bar.
- Allow to configure RAM addresses for the count and counter visibility.
- Allow to configure the counter position in the status bar.

Documentation:

- Added readme.
