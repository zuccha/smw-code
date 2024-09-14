# Changelog

## [2.0.0] - 2024-09-14

### Breaking

- Make sprite compatible with PIXI 1.42. It's no longer compatible with PIXI
  1.40 or older.

## [1.2.0] - 2023-12-25

### Changed

- Allow to configure inner and outer blast radiuses with pixels, instead of
  using unintuitive nominator/denominator values.

## [1.1.0] - 2023-09-08

### Added

- Allow to set a duration for a shake animation after bomb explosion.
- Include palmask file for color palette.
- Specify some presets for the bomb in the JSON file.

### Changed

- Use actual bomb tiles for the bomb preview in Lunar Magic.

### Fixed

- Correct a color in palette C.

## [1.0.1] - 2023-08-29

### Fixed

- Actually use the setting controlling max falling speed with parachute in the
  code.

### Documentation

- Improve and fix some comments in the code.

## [1.0.0] - 2023-08-28

### Added

- Create exploding bombs.
- Allow to choose among two bomb graphics.
- Allow to make the bomb explode when touching player, other sprites, ground,
  and Mario's fireballs, or after a timer goes out.
- Allow to customize the timer.
- Allow to have the bomb fall with a parachute.
- Allow to set a falling speed limit for the parachute.
- Allow to set initial X and Y speed for the bomb.
- Allow to configure graphics and palettes.
- Allow to configure the explosion sound effect.
- Allow to configure the hitbox radius of the explosion blasts.
- Allow to configure the duration of the explosion blast.
- Allow to configure the rotation speed of the explosion blasts.
- Allow to configure the radius of the explosion blasts.
- Add readme.
