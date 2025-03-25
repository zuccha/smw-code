# Changelog

## [1.0.1] - 2025-03-25

### Fixed

- Set horizontal speed correctly when frog is spat by Yoshi.

## [1.0.0] - 2025-03-22

### Added

- Create jumping frog sprite that acts like a platform for Mario.
- Allow configuring direction and direction change via extra byte 1.
- Allow configuring vertical and horizontal speeds for the frog via extra bytes
  2 and 3.
- Add a frail version of the frog that uses a different color palette and dies
  on spin jumps and is instantly swallowed by Yoshi. The frail frog has the
  extra bit set.
- Allow setting a list of tasty sprites that are eaten when touched by the frog.
  Tasty sprites can be preserved in the frog's mouth. The frog will be slow
  after eating a sprite and use a different color palette if it ate a sprite
  that is preserved in its mouth.
- Allow choosing if the frog spits a preserved eaten sprite when killed.
- Allow setting a list of deadly sprites that kill the frog on contact. The frog
  will still be solid when dying like this.
- Add a tasty block that can be eaten by the frog (behaves like tasty sprites).
- Add a deadly block that can kills the frog (behaves like deadly sprites).
- Allow configuring the interaction of the frog with Mario and Yoshi fireballs.
  The frog can ignore them, be killed by them, or killed if frail.
- Add settings to control the duration of rest, prepare jump, and landing.
- Add settings to control the minimum number of bounces after a jump and by how
  much vertical and horizontal momentum decrease.
- Add a setting to clear horizontal momentum if the frog is killed by a deadly
  sprite or block (it falls straight down if killed mid-air).
- Add tables to specify graphics for each animation of the frog (phase,
  regular/slow) and the offsets for centering the frog's graphic depending on
  how tiles are organized in the graphics file.
- Add tables to specify the frog's hitbox, for each phase, for frog-Mario
  interactions.
- Add settings to choose the color palette for the frog in its normal or frail,
  fast or slow variants.
- Add settings for sounds played when jumping, landing, dying, and eating.
- Add ExGFX80.bin containing frog and Yoshi graphics.
