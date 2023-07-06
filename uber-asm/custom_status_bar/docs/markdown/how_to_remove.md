# How to remove

Instructions to remove CSB from your ROM hack.

Notice that removing CSB will restore the ROM hack to its state previous to
installing it. If you previously applied other modifications to the status bar
routine, they are likely to still be there (unless they were hijacking the same
ROM addresses, in which case they will go back to vanilla).

## 1. Instructions

Follow these steps in UberASMTool's top folder:

1. Remove folder `csb_asm/`
2. Remove file `library/csb.asm`
3. Open file `other/status_code.asm` and remove the call to `csb_main`

   ```asm6502
   main:
       ...          ; Other stuff
       JSL csb_main ; <- Remove this line
       RTS
   ```

4. Remove file `gamemode/csb_gm11.asm`
5. Open file `list.txt` and remove `11 csb_gm11.asm` under the `gamemode:` label

   ```asm6502
   gamemode:
   11 csb_gm11.asm ; <- Remove this line
   ```

6. Run UberASMTool
7. Patch `asm/csb_unpatch.asm` (supplied with this UberASM code) with Asar

## 2. Clarifications

Clarifications to problems that might arise when uninstalling.

### (1.4/5) What if I have a shared Game Mode 11 (GM11) file?

You can simply remove the call to `csb_reset_ram` from the file that is
specified in GM11 in `list.txt`. For instance, with KevinM's Retry System we
would remove the call from `retry_gm11.asm` that we added during installation

```asm6502
init:
    JSL retry_level_init_1_init
    JSL retry_level_transition_init
    JSL csb_reset_ram               ; <- Remove this line
    RTL
```

If you do this, you don't need to change anything in `list.txt` (skip 1.5).
