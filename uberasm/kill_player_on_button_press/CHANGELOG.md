# Changelog

## [1.4.0] - 2024-03-03

### Changed

- Control sprite and status bar indicators directly from within the UberASM
  level file.
- Rename `level.asm` to `kill_player_on_button_press.asm`.

### Removed

- Removed redundant sprite indicator.
- Removed redundant status bar file.

### Fixed

- Prevent "TIME" text to appear for one frame before rendering counter in the
  status bar.

## [1.3.0] - 2024-01-02

### Changed

- Display indicator sprite as text in Lunar Magic.
- Rename "ExGFX80.bin" to "Indicator (SP3).bin".

### Fixed

- Remove non-relevant graphics from sprite graphics file.

## [1.2.0] - 2023-12-27

### Added

- Allow to choose whether the counter can be increased (buttons detected) while
  the player is hurt.
- Add Lunar Magic display and presets (by replacing the CFG file with a JSON).

### Changed

- Move files in folders that mimic those of the related tools.
- Make every digit's position in the ExGFX file independently configurable.
- Make the indicator sprite's done/left setting configurable via extra bit
  instead of ASM define.

### Fixed

- Prevent the game from crashing if the threshold is reached while the game is
  paused.

## [1.1.0] - 2023-08-11

### Added

- Add indicator sprite showing the counter over Mario's head.
- Allow to show either inputs left or done on sprite counter.
- Allow to configure which SP slot to use, which initial graphics tile, and the
  palette for the sprite counter.
- Allow to specify the size of digits for the sprite counter.
- Allow to show either inputs left or done on status bar counter.

### Changed

- Default to inputs left in status bar.

## [1.0.0] - 2023-08-09

### Added

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
- Add readme.
