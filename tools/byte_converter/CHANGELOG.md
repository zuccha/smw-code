# Changelog

## Unreleased

### Added

- Show a custom keyboard on mobile.
- Allow to mark binary and hexadecimal numbers as signed (they can be negative).

### Fixed

- Preserve high byte when clearing a value in "Byte" mode.

## [1.2.0] - 2024-01-08

### Added

- Implement calculator, supporting addition, subtraction, logical AND, logical OR, and logical XOR between two operands.
- Add support for signed decimals (decimals can be negative).
- Allow to hide any of the editors.
- Allow to add some space every 4 or 8 digits for readability.
- Increment/decrement the selected digit by 1 by pressing space/shift-space. This is the equivalent of a bit flip in binary.

### Changed

- Reorganize settings section.

### Fixed

- Prevent default keyboard event when typing characters and moving with arrows.
- Preserve high byte when editing in "Byte" mode.

## [1.1.0] - 2024-01-07

### Added

- Allow to switch typing direction from right to left.
- Allow to disable movement after typing a digit.
- Allow to flip binary bits when clicking on a digit.
- Allow to customize caret appearance (bar, box, underline).
- Allow to use tab to move between elements.
- Add hotkeys for changing settings.
- Add bit-index labels above digits.

### Changed

- Restyle entire page.
- Rename "Insertion" to "Typing Mode","Add&Shift" to "Insert", and "Replace" to "Overwrite".

### Fixed

- Make page responsive.

## [1.0.0] - 2024-01-05

### Added

- Display and edit numbers in binary, decimal, and hexadecimal formats.
- Allow to copy values to clipboard with "Copy" button or with ctrl/cmd-C.
- Allow to paste values from clipboard with ctrl/cmd-V.
- Allow to choose unit (byte or word).
- Allow to choose how digits are inserted while typing.
- Add instructions.
