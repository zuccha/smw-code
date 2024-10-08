# Features

List of features available with Custom Status Bar (CSB).

Note that everything that is shown in this overview can be achieved by a series
of different customizations, however by default CSB retains the original
behaviors whenever possible (except for the layout).

Notes about this showcase:

- We use a modified _GFX28_ with custom graphics for the status bar. It is not
  the default, but I personally like it better. The modified _GFX28_ is shipped
  with this UberASM.
- There are little to no technical explanations, for that check out the
  [instructions on how to use this UberASM](./how_to_use.md).

## Table of Contents

1. [Original elements in a minimalistic style](#original-elements-in-a-minimalistic-style)
2. [Control elements visibility](#control-elements-visibility)
3. [Per-level customization](#per-level-customization)
4. [Dynamic elements positioning](#dynamic-elements-positioning)
5. [RAM-controlled settings](#ram-controlled-settings)
6. [Disable IRQ and free layer 3](#disable-irq-and-free-layer-3)
7. [Altering limits and their behaviors](#altering-limits-and-their-behaviors)
8. [Change timer frequency](#change-timer-frequency)
9. [Custom dragon coins messages and symbols](#custom-dragon-coins-messages-and-symbols)
10. [Disable the item box](#disable-the-item-box)
11. [Show speed meter](#show-speed-meter)

## Original elements in a minimalistic style

All of the original elements of the status bar (bonus stars, coins, dragon
coins, item box, lives, score, and time) are still available, but are presented
in a more minimalistic style.

| <img src="../assets/images/minimalistic-1.png" /> |
| :-----------------------------------------------: |
|           Same status bar, less clutter           |

You can also reorganize elements, use different icons and change colors

| <img src="../assets/images/minimalistic-2.png" /> | <img src="../assets/images/minimalistic-3.png" /> |
| :-----------------------------------------------: | :-----------------------------------------------: |
|               A different layout...               |             ...and altered appearance             |

## Control elements visibility

Any element in the status bar can be easily made visible or hidden

| <img src="../assets/images/visibility-1.png" /> |
| :---------------------------------------------: |
|         No score, lives, or bonus stars         |

By default, when an element is hidden it will also be disabled (_e.g._, coins
will not be increased, time doesn't run out, _etc._). If you want, you can make
elements active even if they are not visible

| <img src="../assets/images/visibility-2.gif" /> |
| :---------------------------------------------: |
|       Time runs out even if not displayed       |

You can also set the time to be displayed only if the limit specified in Lunar
Magic is greater than zero

| <img src="../assets/images/visibility-3.gif" /> |
| :---------------------------------------------: |
|            No time limit in sublevel            |

**N.B.:** For this to work with sublevels, you also need to mark the "Force time
limit to reset to this value every time the player enter this level" flag in
Lunar Magic's _Change Music & Time Limit Settings_!

## Per-level customization

You can have different configurations of the status bar depending on the level.
A global configuration defines the base behavior of the status bar, but almost
any setting can be overridden on a level basis

| <img src="../assets/images/level-1.gif" /> |
| :----------------------------------------: |
|     The sublevel has no coin indicator     |

## Dynamic elements positioning

Don't you hate when you have a hole in the UI? This might happen with rigid
systems when sublevels have different status bar configuration

| <img src="../assets/images/dynamic-1.gif" /> |
| :------------------------------------------: |
|           A gap in the status bar!           |

Don't worry, this won't actually happen with CSB ;). In fact, this UberASM
"shifts" elements when one is not visible, preventing gaps among elements

| <img src="../assets/images/dynamic-2.gif" /> |
| :------------------------------------------: |
|           Coins take time's place            |

To understand how it works, check out the guide about
[dynamic positioning](./dynamic_positioning.md).

## RAM-controlled settings

Almost every setting has an equivalent address in memory. The RAM addresses are
available in UberASM code, but they can also be imported in other tools, like
GPS. This means that it is possible to control the behavior of the status bar at
runtime, via custom blocks for example

| <img src="../assets/images/ram-controlled-1.gif" /> |
| :-------------------------------------------------: |
|        A block that toggles the status bar!         |

**N.B.:** This is also how you control the status bar on a level basis.

## Disable IRQ and free layer 3

If you don't really need the status bar in a level (or in most levels), then you
can completely turn it off. The difference compared to turning off elements
individually is that IRQ is disabled and layer 3 is entirely free!

| <img src="../assets/images/irq-1.png" /> | <img src="../assets/images/irq-2.png" /> |
| :--------------------------------------: | :--------------------------------------: |
|            Status bar enabled            |           Status bar disabled            |

Notice how the custom background that is on layer 3 leaves a hole when the
status bar is enabled (the custom background on layer 3 is set to _Start of
Layer 3_).

Credits to KevinM for this, code was taken from his
[RAM Toggled Status Bar (& IRQ)](https://www.smwcentral.net/?p=section&a=details&id=28449)
patch.

## Altering limits and their behaviors

You can customize the maximum amount of bonus stars and coins a player can get
during a level

| <img src="../assets/images/limit-1.gif" /> |
| :----------------------------------------: |
|     Only 5 coins to get an extra life!     |

Altering a limit will change when specific limit-events are triggered (_e.g._,
receiving an extra life when collecting enough coins).

It is possible to prevent the game from resetting these limits when reached

| <img src="../assets/images/limit-2.gif" /> |
| :----------------------------------------: |
|               No more coins                |

You can also disable some vanilla behaviors that happen when different limits
are reached. In particular:

- Disable going to bonus game when bonus stars limit is reached
- Disable getting a life when coins limit is reached
- Disable player dying when time runs out

| <img src="../assets/images/limit-3.gif" /> | <img src="../assets/images/limit-4.gif" /> |
| :----------------------------------------: | :----------------------------------------: |
|               No extra life                |                  No death                  |

In addition to that, you can also define custom behaviors on these events. For
instance, we could reset the level's timer once we reach the limit of five coins

| <img src="../assets/images/limit-5.gif" /> |
| :----------------------------------------: |
|         The timer goes back to 300         |

## Change timer frequency

Ever wished to have the timer count _actual_ seconds? Well, wish no more, for
this is now a reality

| <img src="../assets/images/time-1.gif" /> |
| :---------------------------------------: |
|             Seconds going by              |

## Custom dragon coins messages and symbols

In the original game, dragon coins appear in the status bar as you collect them,
and disappear once you collected them all. While this behavior is still the
default, you can make it so that dragon coins don't ever disappear

| <img src="../assets/images/dragon-coins-1.gif" /> | <img src="../assets/images/dragon-coins-2.gif" /> |
| :-----------------------------------------------: | :-----------------------------------------------: |
|                     Original                      |                      Altered                      |

Even better, you can show a custom message when all dragon coins are collected

| <img src="../assets/images/dragon-coins-3.gif" /> |
| :-----------------------------------------------: |
|            Custom dragon coins message            |

Finally, you can show different graphics for collected and missing dragon coins

| <img src="../assets/images/dragon-coins-4.gif" /> |
| :-----------------------------------------------: |
|         Xs for collected, Os for missing          |

## Disable the item box

By default the item box that drops a stored power up is visible and working

| <img src="../assets/images/item-box-1.gif" /> |
| :-------------------------------------------: |
|              The item box works               |

but you can also make it so that it is invisible and not working, or invisible
and working

| <img src="../assets/images/item-box-2.gif" /> | <img src="../assets/images/item-box-3.gif" /> |
| :-------------------------------------------: | :-------------------------------------------: |
|             Invisible and enabled             |            Invisible and disabled             |

## Show speed meter

Although not present in vanilla, I had fun implementing the speed meter. It
displays the player's speed divided in seven indicators. When all indicators are
full, the player has reached p-speed.

| <img src="../assets/images/speed-meter-1.gif" /> |
| :----------------------------------------------: |
|                 The meter fills                  |

The empty and full indicators can be customized

| <img src="../assets/images/speed-meter-2.gif" /> |
| :----------------------------------------------: |
|             = for full, - for empty              |

**N.B.:** The speed meter is not enabled by default, it has to be added to the
visible elements via settings.
