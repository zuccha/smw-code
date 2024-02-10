# Changelog

## [2.1.0] - 2025-02-10

### Added

- Defines to customize sound effects ports.
- Example list file for GPS.

### Fixed

- `check_and_pay` documentation on how to customize costs.

## [2.0.0] - 2024-01-02

### Breaking

- Instead of using file "shop\_\_pay.asm", the shop blocks rely on
  "routines/check_and_pay.asm".

### Changed

- Replace "shop\_\_pay.asm" with "routines/check_and_pay.asm".

## [1.0.1] - 2023-08-01

### Fixed

- Ensure SA-1 compatibility.

## [1.0.0] - 2023-08-01

### Added

- Create "shop item from below" block.
- Create "shop item through" block.
- Create "shop powerup from below" block.
- Create "shop powerup through" block.
- Allow using bonus stars as cost.
- Allow using coins as cost.
- Allow using lives as cost.
- Allow using score as cost.
- Allow customizing sound effect played when buying.
- Allow customizing sound effect played when not buying ("from below" blocks).
- Allow customizing what shop block becomes after usage ("from below" blocks).
- Allow choosing if the element for sale is infinite or there is only one.

### Documentation

- Write instructions (README).
- Write changelog.
