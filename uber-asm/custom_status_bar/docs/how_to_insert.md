# How to Insert

This guide provides the steps required to insert the code into your hack with
UberASMTool.

**N.B.: If you are using KevinM's Retry System, please refer to
[how_to_insert_with_retry_system.md](./how_to_insert_with_retry_system.md).**

All the resources you need are inside `asm` folder.

### 1. Copy `csb_asm` into UberASMTool's folder

Copy the directory and all its contents inside UberASMTool's folder, at the same
lavel of _library_, _gamemode_, _etc._

```
UberASMTool/
├── asm/
├── csb_asm/           <- Here
├── gamemode/
├── level/
├── library/
├── other/
├── overworld/
├── list.txt
└── ...
```

### 2. Copy _library/csb.asm_ into UberASMTool's _library_ folder

Simply copy the file from folder to folder.

```
UberASMTool/
├── asm/
├── csb_asm/
├── gamemode/
├── level/
├── library/
│   └── csb.asm         <- Here
├── other/
├── overworld/
├── list.txt
└── ...
```

### 3. Copy _other/status_code.asm_ into UberASM's _other_ folder

Notice that the file already exist, if you never modified it before, you can
safely overwrite it.

```
UberASMTool/
├── asm/
├── csb_asm/
├── gamemode/
├── level/
├── library/
│   └── csb.asm
├── other/
│   ├── status_code.asm <- Here
│   └── ...
├── overworld/
├── list.txt
└── ...
```

If you already modified the file, instead of copying it, you can just open the
already existing one and add the following line under the `main` label

```asm
main:
    ...
    JSL csb_main <- This
    RTS
```

### 3. Copy _gamemode/csb_gm11.asm_ into UberASMTool's _gamemode_ folder

Copy the file from folder to folder.

```
UberASMTool/
├── asm/
├── csb_asm/
├── gamemode/
│   └── csb_gm11.asm    <- Here
├── level/
├── library/
│   └── csb.asm
├── other/
│   ├── status_code.asm
│   └── ...
├── overworld/
├── list.txt
└── ...
```

The next step (gamemode-related) depends on whether you have other files for
Game Mode 11 or not.

#### 3.1 If you don't have other Game Mode 11 files

Easy peasy, just copy the following in UberASM's _list.txt_ under the _gamemode_
label:

```
11 gm11.asm
```

#### 3.2 If you have other Game Mode 11 files

Create a file named _gm11.asm_ inside the _gamemode_ folder, with the following
content

```asm
macro call_library(i)
  PHB
  LDA.b #<i>>>16
  PHA
  PLB
  JSL <i>
  PLB
endmacro

init:
  ; Custom Status Bar.
  %call_library(csb_gm11_init)
  ; Do this for every other file already present
  ; where <other_gm11> is the name of the file.
  %call_library(other_gm11_init)
RTL
```

Then set the following line in UberASM's _list.txt_ under the _gamemode_ label:

```
11 gm11.asm
```

The folder structure should look like this

```
UberASMTool/
├── asm/
├── csb_asm/
├── gamemode/
│   ├── csb_gm11.asm
│   ├── other_gm11.asm   <- This was already there
│   └── gm11.asm         <- New
├── level/
├── library/
├── other/
├── overworld/
├── list.txt
└── ...
```

For more, check out UberASMTool's
[FAQ](https://www.smwcentral.net/?p=faq&page=1515827-uberasm) on SMWCentral.

### 4. Configure your status bar

Finally you can configure the status bar!

You can edit the status bar by modifying the contents of _csb_asm/settings.asm_.
You will find a description for each setting in there.

You can also modify the color palette used for each tile in the status bar with
_csb_asm/colors.asm_.

### 5. Customize levels

To customize levels, please refer to
[how_to_customize_levels.md](./how_to_customize_levels.md)

### 6. Run UberASMTool

Once you are done with all the aforementioned steps, you can run UberASMTool on
your hack.
