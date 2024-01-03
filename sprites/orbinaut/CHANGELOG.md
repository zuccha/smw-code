# Changelog

## [1.1.0] - 2023-12-24

### Added

- Added palmask for Orbinaut's palette.
- Allow to configure spike ball's radius from orbinaut's center via extra byte.

### Changed

- Moved Orbinaut GFX tile configuration in ASM define instead of using Extra
  Property Byte 1.
- Moved Orbinaut' Spike Ball GFX tile configuration in ASM define instead of
  using Extra Property Byte 1.
- Moved Orbinaut's Spike Ball tile number configuration in ASM define instead of
  using Extra Property Byte 2.

### Fixed

- Prevent orbinaut from drifting downward when hitting a wall.
- Disable spike ball hitbox while orbinaut's core is being eaten by Yoshi.
- Kill spike ball that was on Yoshi's tongue when Mario is hurt and jumps off
  (before it would snap back to the orbinaut).

## [1.0.1] - 2023-08-16

### Fixed

- Dismount Yoshi when colliding with spike balls.
- Make spike balls absorb player fireballs.
- Kill spike balls still attached to orbinaut if orbinaut turns into a coin
  (because of being hit by fireball or activating silver p-switch).
- Include orbinaut's palette in bundle.

## [1.0.0] - 2023-08-15

### Added

- Create orbinaut sprite and orbiting spike ball sprite.
- Add modified GFX02.bin as ExGFX80.bin containing orbinaut and spike ball
  graphics.
- Implement four spike ball orbiting the orbinaut.
- Allow to configure orbinaut and spike balls graphics tile and SP slots through
  extra property bytes.
- Allow to configure whether the orbinaut goes through solid walls or not via
  extra bit.
- Allow to configure orbinaut movement (never move, always move, move when
  player move, move when player doesn't move, always go left, always go right)
  via extra byte 1.
- Allow to configure orbinaut horizontal speed via extra byte 2.
- Allow to configure throw range via extra byte 3.
- Allow to configure throw speed via extra byte 4.
- Allow to configure rotation speed via define.
- Add readme.
