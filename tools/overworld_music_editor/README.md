# Multiple Songs on Main Map Patch Editor

Author: zuccha, suggested by Heitor Porfirio

This is an editor for generating the table used by the
[Multiple Songs on Main Map](https://www.smwcentral.net/?p=section&a=details&id=20814)
patch, created by smkdan.

## Usage

The tool can be opened in any major web browser.

The grid represents the main map of the overworld, divided in 256 cells. You can
press on a cell to change its value (the value must be in the range of `$00-$FF`).

You can check and copy the ASM table by opening the _Output_ menu.

You can add a screenshot of the overworld through the _Image_ menu. The image
will be stretched to fit inside the grid. Sadly, I might have to reupload the
image every time you open the tool.

You can import an already existing table by copying it and pasting it in the
_Input_ field, then clicking _Import_.

Through the _Colors_ menu, you can toggle seeing background colors (with or
without transparency) for the cells on the grid. This helps visualize how music
is grouped.

## Changelog

### 1.0.0 (2023-08-30)

Added:

- Display editable grid
- Implement copying output table to clipboard
- Implement "import" feature
- Add the possibility to add a background image
- Toggle display colors for cells on the grid

Documentation:

- Write readme
