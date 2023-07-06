# How to use

You have different ways of customizing the status bar. After applying any change
with the methods described below, rerun UberASMTool and you are good to go.

## 1. Global settings

You can change global settings in `csb_asm/settings.asm`. A detailed explanation
on what each setting does is provided in the file.

Global settings are restored any time a level is loaded (from overworld,
sub-level entrances, fast retry after death, _etc._), but they can be overridden
on a level basis (see next section).

## 2. Per-level customization

You can override global settings on a level basis. To do this, you just need to
create an ASM file for the level (or modify an existing one) and add code under
the `load:` label.

For instance, let's say we want to enable the timer (globally disabled) and
customize it for level 105. Then we create file `level_105.asm` in UberASMTool's
`levels/` folder as follows

```asm6502
load:
    LDA #$01 : STA csb_ram_time_visibility ; Make timer visible
    LDA #$3C : STA csb_ram_time_frequency  ; Decrease timer every real second
```

then add the level in UberASMTool's `list.txt`, under the `level:` label

```asm6502
level:
105 level_105.asm ; <- Add this line
```

In UberASM code almost every setting has a corresponding RAM address, that can
be accessed with `csb_ram_<setting_name>`. The RAM address can also be found in
the setting's description in `csb_asm/settings.asm`. To change a value we do

```asm6502
   value            RAM address
     v                   v
LDA #01 : STA csb_ram_time_visibility
```

where `value` is any of the possible listed in the setting's description (always
prefixed by a `#` and written with two digits), and `RAM address` is the name of
the setting, prefixed by `csb_ram`.

An example for a level file is provided under `asm/level/example.asm`.

## 3. Using RAM addresses in other tools

You can also use RAM addresses outside of UberASMTool (_e.g._, GPS), but in that
case you first need to include their definitions.

For instance, we can create a block that toggles the visibility of the status
bar when hit from below

```asm6502
db $42
JMP MarioBelow
JMP Ignore : JMP Ignore : JMP Ignore
JMP Ignore : JMP Ignore : JMP Ignore
JMP Ignore : JMP Ignore : JMP Ignore

; Redefine RAM base address.
; It has to be the same as the one in ram.asm!
!freeram_address = $7FB700

; Macro for generating addresses.
macro define_ram(offset, name)
    !ram_<name> = !freeram_address+<offset>
    base !ram_<name>
        ram_<name>:
    base off
endmacro

; Define the addresses we need for the block.
; Do not change the offset ($00)!
%define_ram($00, status_bar_visibility)

; Our code.
MarioBelow:
    ; If visibility is 1 set it to 0, if it is 0 set it to 1.
    LDA ram_status_bar_visibility : BEQ +
    LDA #$00 : STA ram_status_bar_visibility : RTL
+   LDA #$01 : STA ram_status_bar_visibility : RTL

Ignore:
    RTL

print "Toggle status bar when hit from below"
```

Alternatively, you can copy `ram.asm` and put it in the folder containing the
block file(s) and include it

```asm6502
db $42
JMP MarioBelow
JMP Ignore : JMP Ignore : JMP Ignore
JMP Ignore : JMP Ignore : JMP Ignore
JMP Ignore : JMP Ignore : JMP Ignore

; Include the RAM file. Make sure !freeram_address has the correct address!
incsrc ram.asm

; Our code.
MarioBelow:
    ; If visibility is 1 set it to 0, if it is 0 set it to 1.
    LDA ram_status_bar_visibility : BEQ +
    LDA #$00 : STA ram_status_bar_visibility : RTL
+   LDA #$01 : STA ram_status_bar_visibility : RTL

Ignore:
    RTL

print "Toggle status bar when hit from below"
```

For more, check out `csb_asm/ram.asm`.

## 4. Status bar tilemap color palette

The colors used for tiles of the status bar are defined in `csb_asm/colors.asm`.
Please, refer to the explanation in the file to find out more.

Also, I suggest you read
[HammerBrother's Status Bar tutorial](https://www.smwcentral.net/?p=section&a=details&id=26018).

## 5. Event callbacks

You can specify your custom behaviors on specific events that are tied to the
status bar. Currently, the following are supported:

- Bonus stars limit reached
- Coins limit reached
- Time run out

To add custom behaviors, modify the contents of `csb_asm/callbacks.asm`.

Let's take an example, we want to change the symbol in front of our bonus stars'
and coins' indicators to a "!" when they reach the limit. To do so, add to the
already defined routines in `csb_asm/callbacks.asm`

```asm6502
trigger_bonus_stars_limit_reached:
    LDA #$28 : STA ram_bonus_stars_symbol ; $28 is the "!" tile in GFX28
    RTS

trigger_coins_limit_reached:
    LDA #$28 : STA ram_coins_symbol       ; $28 is the "!" tile in GFX28
    RTS
```

Notice that since we are in CSB's namespace, in this file we don't have to
prefix RAM addresses with `csb_`. In fact, we use `ram_coins_symbol` instead of
`csb_ram_coins_symbol`.

## 6. Base RAM address

This UberASM requires 34 bytes of contiguous free RAM. The base RAM address is
specified in `csb_asm/ram.asm`, if you need to change it due to conflict with
other custom code, you can modify it there.

## 7. Custom graphics

The patch comes with a modified version of `GFX28.bin` that you can use. The
changes are:

1. Lower the clock tile (`$76`) by one pixel.
2. Replace the first part of the "TIME" text (`$3D`) with an empty coin that can
   be used to display missing dragon coins (instead of a blank space).
3. Replace the middle part of the "TIME" text (`$3E`) with a heart that can be
   used in front of the lives counter.
4. Replace the last part of the "TIME" text (`$3F`) with a star that can be used
   in front of the bonus stars counter.
5. Replace the corner of the item box (`$3A`) with a checkmark that can be used
   to mark when all dragon coins have been collected.
6. Replace the top of the item box (`$3B`) with an alternative coin that can be
   used in front of the coins counter.

Using the modified version is entirely **optional**.

To use the modified version, simply replace the `Graphics/GFX28.bin` file in
your ROM hack folder with `graphics/GFX28.bin` present in this bundle, then
import graphics via Lunar Magic.

Changing graphics doesn't require a rerun of UberASMTool. However, since _GFX28_
is loaded on the title screen, you want to make sure you go through that to see
changes (relevant if you're using save states).
