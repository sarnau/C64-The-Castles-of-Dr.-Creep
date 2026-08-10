# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

A reverse-engineering project for the Commodore 64 game **The Castles of Dr. Creep** (Brøderbund, 1984). There is no application to build in the normal sense — the work is understanding the original 6502 machine code and its data formats, and writing Python tools that decode/visualize those formats. The game's own assembly is being reconstructed, not authored.

## The four representations of the game (and which to trust)

The same program exists here in several forms. When you need to know *how the game actually behaves*, consult them in this order:

1. **`Creep Sourcecode/` — reconstructed DASM assembly. This is the authoritative source of truth.**
   - `asm/object.asm` (~12.5k lines) is the **engine**, assembled to `object.prg` and loaded at **`$0800`**. It contains the room renderer, the per-object behaviors, sprites, sound, and the in-game map display. Its header has the full memory map.
   - `asm/creep.asm` is only the loader / title screen.
   - `inc/CC_*.asm` are the includes: `CC_Data{Objects,Sprites,Sounds,Tables,Texts}.asm` (the actual graphics/level/sound data as `dc.b`), `CC_Objects.asm` (struct field offsets), `CC_Vars*.asm` / `CC_WorkAreas.asm` / `CC_Zpg.asm` (variable & zero-page layout).
2. **Ghidra project** (`Castles.gpr` + `Castles.rep/`) over a full 64K RAM snapshot (program **`C64_MEMORY_DUMP.BIN`**), reachable through the **`ghidra` MCP tools**. Use this for code that lives in the main `creep` program rather than the `object.prg` overlay (e.g. `_mapDisplay`, `_mainLoop`, IRQ/music handlers). It carries extensive prior naming (functions, structs, constants).
3. **IDA databases** (`creepload.prg.idb`, `The Castles of Dr. Creep/creepload.prg.i64`) — for the disk loader.
4. **`docs/`** — analysis write-ups produced from the above: `room-level-format.md`, `sprite-multiplexer.md`, `object-behavior-table.md`, `enemy-behavior.md` (Mummy/Frankenstein/beam/spark/force-field motion & AI), `sound-music.md` (the SID sound-effect + demo-music engine). Good orientation, but verify against the asm.

The MCP `ghidra` tools work per-address (`decompile_function`, `disassemble_function`) — there is no list-functions / read-memory / strings endpoint, so navigate by following the call graph from known anchors. `disassemble_function(addr, filter_mnemonics="JSR,JMP")` is the way to discover a callee's address (the decompiler shows names, not addresses; correlate by call order). Useful entry anchors in the dump:

| Addr | Function | Role |
|------|----------|------|
| `0x0b84` | `_mainLoop` | `_Intro()` then `_Game()` forever |
| `0x0b8d` / `0x0d71` | `_Intro` / `_Game` | attract loop / one play session |
| `0x0f94` / `0x1203` | `_mapDisplay` / `_mapRoomDraw` | castle map screen / per-room map draw |
| `0x14ce` | `roomMain` | in-room gameplay loop |
| `0x2e1c` | `events_Execute` | per-frame tick (collision → sprites → objects) |
| `0x3f4f` | `object_Execute` | object engine; dispatches via `_ANIM_TABLE` |
| `0x1f29` / `0x21c8` | `musicBufferFeed` / `sound_PlayEffect` | SID music interpreter / sound FX |

## Game data formats (the cross-file picture)

These are spread across the level files, `object.asm`, and the `inc/` data — understanding any one requires the others.

- **Castle/level files** live in `The Castles of Dr. Creep/`: `z<name>.prg` are the playable castles (load base **`$7800`**). Layout: castle header, then a **room table at file offset `0x100`** of 8-byte records `{flagsAndColor, x, y, widthAndHeight, doorPtr(2), objectPtr(2)}`. Each room's `objectPtr` is a **threaded object list**: a 16-bit handler address followed by inline parameters, repeated, terminated by `0x0000`. The handler IDs are `$08xx` addresses — they index `object.asm`'s `ID_Jump_Table` (`$0803`=Door, `$0806`=Floor/walkway, `$0809`=Pole, `$080c`=Ladder, `$080f`=DoorBell, … `$0833`=Text, `$0836`=inline Graphic). `level.py` is the reference parser for this.
- **Screen / graphics**: rooms render in **C64 multicolor bitmap** (full 320×200, black background). The coordinate convention used everywhere: an object is placed by `GridCol`/`GridRow`, where the left hi-res pixel is `(GridCol-16)*2` and a "map cell" is 4 GridCol units wide × 8 rows tall.
- **Object graphic format** (built-in objects and inline `0x0836` images share it): `cols` (bytes wide), `rows` (pixels tall), `$00`, then `cols*rows` row-major bitmap bytes, then colour block(s) of `ceil(rows/8)*cols` bytes — block A = screen-RAM nibbles (bit-pairs 01/10), optional block B = colour-RAM nibble (bit-pair 11). Some objects ship only **one** colour block, and a few (`DatObjFoFiTime…`, `DatObjLiMaPole…`) use `Dat`-prefixed numeric **sub-labels** for their rows — both are easy to mis-parse.
- **Sprites** (`CC_DataSprites.asm`): 3-byte header `{cols, rows, look}` + bitmap. `look` bit4 clear ⇒ multicolor (bit-pairs: 01=`$D025` LT_RED, 10=individual colour, 11=`$D026` LT_GREEN), bit4 set ⇒ hi-res single colour. Individual colours per type: player=YELLOW, beam=RED, mummy=WHITE, frank=GREY, arrow=BLACK.
- Colours in the asm are C64 palette names (`BLACK`..`LT_GREY`) and packed `HR_<hi><lo>` nibble pairs; the C64 palette is hardcoded in the Python tools.

## Python tools (these are the runnable code)

Require Python 3 + Pillow. Run from the repo root:

- `python3 level.py` — dumps every `z*.prg` castle (rooms, doors, objects) as text. The canonical decoder for the level format.
- `python3 render_tutorial.py` — **renders ALL castles** (the name is historical), one folder per castle: `images/<castle>/room_NN.png` plus `images/<castle>/overview.png`. The per-room renderer is a faithful port of `object.asm`'s `Room*` draw routines + the `PaintObject` blitter; `overview.png` reproduces the in-game castle **map** (`_mapRoomDraw`): coloured room rectangles at map positions with door arrows. Text rendering needs a 4 KB C64 character ROM at `Game.vc64/char.rom` (currently **absent** → text is skipped, everything else still renders).
- `python3 make_sprites.py` — decodes `CC_DataSprites.asm` into `images/sprite.png` (all sprites on one sheet).

Everything under `images/` is **generated output** of these tools — regenerate it, don't hand-edit. When changing the renderers, verify by opening the produced PNGs and cross-checking against the corresponding `object.asm` routine; the asm is the spec.

## Building the original assembly

`Creep Sourcecode/asm.bat <name>` assembles `asm/<name>.asm` → `prg/<name>.prg` with a listing in `lst/`; `dis.bat` disassembles. **This is not reproducible in this environment**: it invokes DASM at a hardcoded Windows path, and `object.asm` includes C64 register-definition files (`vic.asm`, `sid.asm`, `cia1.asm`/`cia2.asm`, `color.asm`, `mem.asm`, `kernel.asm` via `incdir ..\inc`) that are **not** in this repo. Treat the assembly as a read/analysis reference unless you set up DASM and those system includes yourself.
