# Compatibility

Compatibility notes and considerations regarding other patches/systems.

## Hijacks

The code hijacks the ROM in the following points:

|  Id | Addresses         | Bytes | Reason                                       |
| --: | ----------------- | ----: | -------------------------------------------- |
|   1 | `$008294-$008298` |     4 | Disable IRQ                                  |
|   2 | `$008C81-$008CFE` |    63 | Alter the status bar's tilemap               |
|   3 | `$008CFF-$008D02` |     4 | Disable status bar tilemap transfer from ROM |
|   4 | `$008DAC-$008D10` |     4 | Disable status bar tilemap transfer from RAM |
|   5 | `$008E1F`         |     1 | Turn off original status bar routine         |
|   6 | `$028008`         |     1 | Prevent item in item box from falling        |
|   7 | `$028052`         |     1 | Override item box horizontal position        |

The code comes with a patch that can be applied to revert hijacks. For more, see
[how to remove](./how_to_remove.md).

## Free RAM

CSB requires 40 bytes of contiguous free RAM, that are set to start at `$7FB700`
by default.

In case of conflicts, this address can be modified in `csb_asm/ram.asm`.

## SA-1

CSB is compatible with SA-1.

## KevinM's Retry System

CSB is fully compatible with KevinM's Retry System. Making them work together is
quite easy, the process is described as an example in the
[insertion guide](./how_to_insert.md).

## Other status bar patches

Not tested, but probably not compatible with any patch that overrides in some
way the original status bar routine.
