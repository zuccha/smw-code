# How to insert

Instructions for inserting CSB into your ROM hack via UberASMTool.

## 1. Instructions

Follow these steps:

1. Copy `asm/csb_asm/` inside UberASMTool's top folder (at the same level of
   `gamemode/`, `levels/`, `library/`, _etc._)
2. Copy `asm/library/csb.asm` inside UberASMTool's `library/` folder
3. Copy `asm/other/status.code` inside UberASMTool's `other/` folder (note that
   the file already exists, you can replace it)
4. Copy `asm/gamemode/csb_gm11.asm` inside UberASMTool's `gamemode/` folder
5. Copy the following in UberASMTool's `list.txt`, under `gamemode:`

   ```uberasm
   gamemode:
   11 csb_gm11.asm ; <- Add this line
   ```

6. Make sure you have edited at least one level in Lunar Magic
7. Run UberASMTool

## 2. Clarifications

Clarifications to problems that might arise when installing.

### (1.3) What if I previously edited UberASMTool's `other/status_code.asm`?

Instead of copying and replacing the file, you can just open UberASMTool's
`other/status_code.asm` and modify the `main:` label as follows

```asar
main:
    ...          ; Other stuff that you previously added
    JSL csb_main ; <- Add this line
    RTS
```

### (1.4) What if I already have a file for Game Mode 11 (GM11)?

In this case, you have a couple of solutions. The first (and simplest) is to
call CSB's routine for GM11 inside the already existing GM11 file, under the
`init:` label. For instance, if you are using KevinM's Retry System, you can
modify `retry_gm11.asm` to look like this

```asar
init:
    JSL retry_level_init_1_init
    JSL retry_level_transition_init
    JSL csb_reset_ram               ; <- Add this line
    RTL
```

With this method, you skip step (1.e) of the instructions.

As an alternative, you can create a common file that merges the two (or more)
GM11 files, as described on SMWCentral. For more about that, consult the
[FAQ](https://www.smwcentral.net/?p=faq&page=1515827-uberasm).

In our case, we need to create a `gm11.asm` file in UberASMTool's `gamemode/`
folder with the following content

```asar
macro call_library(i)
    PHB
    LDA.b #<i>>>16
    PHA
    PLB
    JSL <i>
    PLB
endmacro

init:
    %call_library(other_gm11_init) ; Stuff from already existing GM11 file
    JSL csb_reset_ram              ; <- Call to our library
    RTL

main:
    %call_library(other_gm11_main) ; More stuff from already existing GM11 file
    RTL
```

In this case `other_gm11.asm` is the other GM11 file, that now we moved from
`gamemode/` folder to `library/` folder. It looks something like this

```asar
init:
    ... ; Some code
    RTL

main:
    ... ; Some other code
    RTL
```

Also, notice that we don't need to move `csb_gm11.asm` in the `library/` folder,
since `csb_reset_ram` is already available in UberASM code. In fact, we don't
need "csb_gm11.asm" at all!

Now, in `list.txt`, under `gamemode:` label, we list the newly created file

```uberasm
gamemode:
11 gm11.asm ; <- Add this line
```
