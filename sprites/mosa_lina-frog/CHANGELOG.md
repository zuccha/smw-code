# Changelog

## [1.0.0] - 2025-03-??

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
- Allow setting a list of deadly sprites that kill the frog on contact. The frog
  will still be solid when dying like this.
- Allow configuring the interaction of the frog with Mario and Yoshi fireballs.
  The frog can ignore them, be killed by them, or killed if frail.
- Add a tasty block that can be eaten by the frog (behaves like tasty sprites).
- Add a deadly block that can kills the frog (behaves like deadly sprites).
- Add ExGFX80.bin containing frog and Yoshi graphics.
