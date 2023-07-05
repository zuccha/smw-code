# CHANGELOG

## Unreleased

New features:

- Reorganize and draw original status bar elements (bonus stars, coins, dragon
  coins, lives, power up, score, and time) in a more minimalistic manner
- Allow to reorganize original elements
- Allow choosing the symbol in front of bonus stars, coins, lives, and time
- Allow to control original elements visibility (on/off)
- Allow to modify bonus stars and coins limit
- Allow to show coins and time indicators only if their limit is greater than 0
- Allow to disable resetting bonus stars and coins when their limit is reached
- Allow to disable going to bonus game if bonus stars limit is reached
- Allow to disable getting a life if coins limit is reached
- Allow to disable dying if time runs out
- Allow to run custom code when bonus stars and coins limit are reached, and
  when time runs out
- Allow to process (increase/decrease) bonus stars, coins, and time even if the
  elements are not visible
- Allow to modify the frequency for decreasing the time
- Allow to always show dragon coins even if all have been collected
- Allow to show a custom message when all dragon coins have been collected and
  to cutomize the message
- Allow to customize the icon for collected and missing dragon coins
- Allow to disable item box (no power up drop)
- Allow to control all aforementioned features with RAM addresses (except for
  elements positioning/ordering)
- Expose RAM addresses so that they can be used in other UberASM code or in
  other tools (e.g. GPS)
- Allow customizing the base address for free RAM
- Add custom GFX28.bin with modified graphics

Documentation:

- Write generic readme
- Write features overview
- Write compatibility notes
- Write credits
- Write "how to insert" guide
- Write "how to remove" guide
- Write "how to use" guide
- Write notes about dynamic positioning
- Document callbacks, colors, RAM, and settings usage
- Initialize changelog
