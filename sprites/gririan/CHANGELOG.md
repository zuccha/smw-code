# Changelog

## [2.0.1] - 2025-03-03

### Fixed

- Correct Gririan spelling (previously "Girian").

## [2.0.0] - 2024-09-14

### Breaking

- Make Gririan compatible with PIXI 1.42. It's no longer compatible with PIXI
  1.40 or older.

## [1.0.0] - 2023-10-10

### Added

- Create Gririan/Woo.
- Allow to switch between Gririan and Woo via extra bit.
- Allow to switch between static/walking via extra byte.
- Allow to switch between spitting/non-spitting via extra byte.
- Allow to configure walking speed.
- Allow to configure max health.
- Allow to configure damage dealt by player (head bounce), thrown sprites, Yoshi
  fireballs, and Mario fireballs.
- Allow to configure how close the player needs to be for the Gririan/Woo to
  start spitting fire/ice.
- Allow frequency at which the sprite spits projectiles.
- Allow to configure mouth position (origin for the projectiles).
- Allow to configure speed of the projectile.
- Allow to configure head hitbox of the Gririan/Woo (for determining if player
  is bouncing on its head).
- Allow to configure player's vertical speed when it bounces off the sprite's
  head.
- Allow to configure the sound effect played when the Gririan/Woo is being hurt.
- Allow to configure the sound effect played when the Gririan/Woo dies.
- Allow to configure the sound effect played when the Gririan/Woo spits
  fire/ice.
- Allow to configure the score points rewarded when the Gririan/Woo dies.
- Allow to configure the duration of each phase of the Gririan/Woo and fire/ice
  projectile.
- Allow to configure the color palettes for the Gririan, Woo, fire, and ice.
- Allow to configure the color graphics for the Gririan, Woo, fire, and ice,
  during each of their phases.
- Allow to configure the hitbox of the projectile during each of its phases.
- Allow to configure the projectile effect when hitting the player, depending on
  its type (fire/ice). The effects can be: hurt, kill, or stun player.
- Allow to configure the duration of the stun when the player gets hit.
- Allow to configure the sound effect played when the player gets stun.
- Add readme.
