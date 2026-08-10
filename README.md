# The Castles of Dr. Creep — Reverse Engineering

A reverse-engineering study of the Commodore 64 game **The Castles of Dr. Creep**
(Brøderbund, 1984). The goal is to fully understand the original 6502 machine code and its data
formats, and to build small Python tools that decode and visualise those formats. There is no
application to "build" — the deliverables are the analysis docs, the reconstructed assembly, and
the decoder/renderer scripts.

## The game in several forms

The same program is present here in complementary representations:

- **`Creep Sourcecode/`** — a reconstructed DASM assembly of the game. This is the **authoritative
  reference** for how the game behaves. `asm/object.asm` is the engine (loaded at `$0800`);
  `inc/CC_*.asm` hold the level/graphics/sound data and the variable/struct layouts. It builds on
  macOS to binaries **byte-identical** to the shipped `prg/*.prg` — `brew install dasm && cd
  "Creep Sourcecode" && ./build.sh` (see [`Creep Sourcecode/BUILD.md`](Creep%20Sourcecode/BUILD.md)).
- **Ghidra project** (`Castles.gpr` / `Castles.rep/`) over a full 64K RAM snapshot
  (`C64_MEMORY_DUMP.BIN`) — used for code in the main program rather than the `object.prg` overlay.
- **IDA databases** (`creepload.prg.idb`, `.../creepload.prg.i64`) — the disk loader.
- **Disk / tape images** (`*.d64`, `*.g64`, tape version) and the per-castle level files in
  `The Castles of Dr. Creep/` (`z<name>.prg`, load base `$7800`).

> The Ghidra dump and the reconstructed source are **different builds** (the source is a "Dr Creep 3"
> build): the behaviour and data formats match, but some absolute RAM addresses differ.

## Analysis documents (`docs/`)

| Document | What it covers |
|----------|----------------|
| [room-level-format.md](docs/room-level-format.md) | Castle/room file layout: room table, threaded object lists, the `$08xx` handler IDs, doors, and the map draw pipeline |
| [object-behavior-table.md](docs/object-behavior-table.md) | The object/entity engine: `_ANIM_TABLE` dispatch, object & sprite work-area records, object/sprite type numbers, lifecycle |
| [sprite-multiplexer.md](docs/sprite-multiplexer.md) | Sprite work-area layout, logical→hardware sprite mapping, the raster-IRQ commit, and collision detection |
| [enemy-behavior.md](docs/enemy-behavior.md) | Motion/AI of every enemy — Mummy, Frankenstein, ray-gun beam, lightning spark, force field |
| [sound-music.md](docs/sound-music.md) | The CIA-timer-driven SID engine that plays both sound effects and demo music, with the full opcode reference |

Each doc cites the exact `object.asm` routines and includes rendered mermaid diagrams.

## Tools

Python 3 + [Pillow](https://python-pillow.org/). Run from the repo root:

- **`python3 level.py`** — dumps every `z*.prg` castle (rooms, doors, objects) as text. The
  reference decoder for the level format.
- **`python3 render_tutorial.py`** — renders **all** castles (the name is historical) into
  `images/<castle>/`: one `room_NN.png` per room plus an `overview.png` that reproduces the in-game
  castle map (coloured room blocks at their map positions with door arrows). The per-room renderer is
  a faithful port of `object.asm`'s room-draw routines and the `PaintObject` blitter.
  *In-room text needs a 4 KB C64 character ROM at `Game.vc64/char.rom`; if it's absent, text is
  skipped and everything else still renders.*
- **`python3 make_sprites.py`** — decodes `inc/CC_DataSprites.asm` into `images/sprite.png`, a sheet
  of all 63 sprites (player, mummy, Frankenstein, beam, spark, force field, arrows).

Everything under `images/` is **generated output** of these tools — regenerate it rather than
hand-editing.

## Repository notes

- `CLAUDE.md` contains orientation notes for working in this repo (memory map, key addresses, data
  formats).
- Ghidra project lock/temp files are git-ignored (see `.gitignore`); the analysis database
  (`Castles.rep/.../db.*.gbf`) is tracked.
