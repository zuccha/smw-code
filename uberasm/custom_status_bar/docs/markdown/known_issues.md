# Known Issues

This UberASM has a few issues:

1. Hitting a message box while `!status_bar_visibility = 0`, the status bar will
   reappear, but broken.
2. If `!status_bar_visibility = 0`, if it is turned on mid-level (e.g., via the
   `toggle_status_bar.asm` block) it will appear with the wrong color palette.

My best recommendation is to use `!status_bar_visibility = 0` sparingly, namely
only when you need to free up space in levels that use a layer 3 background (in
such levels you shouldn't be using the message box anyways). Also, avoid
switching to and from `!status_bar_visibility = 0` mid-level. Instead, rely on
`!status_bar_visibility = 1` to hide the status bar and disable its features.
