# Changelog

## [0.3.1] - Unreleased

### Fixed

- Fix crash on startup.

## [0.3.0] - 2024-01-15

### Added

- Include example list file for UberASMTool.
- Include level files to enable and disable the status bar, and one with a
  version with only coins and time.
- Include a GPS block to toggle the status bar visibility.
- Allow to hide the status bar without disabling IRQ (and all problems that come
  with that).

### Modified

- Reorganize code folder structure.
- Refactor code to almost always operate in 8-bit mode.

### Removed

- Remove generic example level code.

## [0.2.1] - 2024-01-03

### Fixed

- Make timer tick on SA-1.

## [0.2.0] - 2023-08-06

### Added

- Make code compatible with SA-1.
- Add better syntax highlight for Asar and UberASM code snippets.
- Add "known issues" section.

### Fixed

- Correct some mistakes in the features overview.

## [0.1.0] - 2023-07-06

### Added

- Reorganize and draw original status bar elements (bonus stars, coins, dragon
  coins, lives, power up, score, and time) in a more minimalistic manner.
- Allow to reorganize original elements.
- Allow choosing the symbol in front of bonus stars, coins, lives, and time.
- Allow to control the entire status bar visibility (on/off), enabling and
  disabling IRQ.
- Allow to control original elements visibility (on/off).
- Allow to modify bonus stars and coins limit.
- Allow to show coins and time indicators only if their limit is greater than 0.
- Allow to disable resetting bonus stars and coins when their limit is reached.
- Allow to disable going to bonus game if bonus stars limit is reached.
- Allow to disable getting a life if coins limit is reached.
- Allow to disable dying if time runs out.
- Allow to run custom code when bonus stars and coins limit are reached, and
  when time runs out.
- Allow to process (increase/decrease) bonus stars, coins, and time even if the
  elements are not visible.
- Allow to modify the frequency for decreasing the time.
- Allow to always show dragon coins even if all have been collected.
- Allow to show a custom message when all dragon coins have been collected and
  to customize the message.
- Allow to customize the icon for collected and missing dragon coins.
- Allow to disable item box (no power up drop).
- Allow to control all aforementioned features with RAM addresses (except for
  elements positioning/ordering).
- Expose RAM addresses so that they can be used in other UberASM code or in
  other tools (_e.g._ GPS).
- Allow customizing the base address for free RAM.
- Add custom GFX28.bin with modified graphics.
- Write generic readme.
- Write features overview.
- Write compatibility notes.
- Write credits.
- Write "how to insert" guide.
- Write "how to remove" guide.
- Write "how to use" guide.
- Write notes about dynamic positioning.
- Document callbacks, colors, RAM, and settings usage.
- Initialize changelog.
