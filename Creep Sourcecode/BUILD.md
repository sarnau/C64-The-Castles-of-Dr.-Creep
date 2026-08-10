# Building on macOS

The reconstructed source assembles to binaries **byte-identical** to the shipped
`prg/*.prg` (the 2010 build this source targets).

## Requirements

- [DASM](https://github.com/dasm-assembler/dasm): `brew install dasm` (verified with **DASM 2.20.16**,
  Homebrew bottle 2.20.17).

## Build & verify

```bash
cd "Creep Sourcecode"
./build.sh
```

Expected:

```
=== object ===
Complete. (0)
  OK  byte-identical to Object.prg
=== creep ===
Complete. (0)
  OK  byte-identical to Creep.prg
```

`build.sh` exits non-zero if any target fails to assemble or diverges from its
reference `.prg`, so it doubles as a regression gate.

## What `build.sh` does

The source was written for an older Windows DASM. Rather than edit the checked-in
game source (`asm/*.asm`, `inc/CC_*.asm` stay byte-for-byte untouched), the script
assembles from a throwaway temp tree and normalises a copy for modern DASM:

1. prepend a `processor 6502` directive (the source has none);
2. dedent the `* equ $0800` origin (`*` must be at column 0 in this DASM);
3. convert `\` → `/` on `include`/`incdir` lines (Windows-style paths);
4. rewrite `incdir ../inc` → `incdir inc` (this DASM resolves `INCDIR` relative to
   the process CWD, which the script sets to the temp-tree root);
5. drop explicit accumulator operands: `asl a`/`lsr a`/`rol a`/`ror a` → bare
   `asl`/`lsr`/`rol`/`ror` (identical opcodes — a byte-safe dialect shim);
6. two one-line source-typo fixes applied to the *temp copy* only:
   `inc/CC_DataTables.asm:135` (a divider comment missing its leading `;`) and
   `inc/CC_VarsGame.asm:99` (a needed `equ` that was commented out, value `$03`).

None of these change emitted bytes.

## The missing system includes

`object.asm`/`creep.asm` `include` seven C64 register/constant files that were not
in the repo; they are now authored in `inc/`:

| File | Contents |
|------|----------|
| `vic.asm` | VIC-II registers `$D000–$D02E` |
| `sid.asm` | SID registers `$D400–$D418` |
| `cia1.asm` | CIA #1 `$DC00–$DC0F` |
| `cia2.asm` | CIA #2 `$DD00–$DD0F` |
| `color.asm` | `COLORAM`, the 16 palette names, and all 256 `HR_<hi><lo>` packed nibble pairs |
| `mem.asm` | CPU port `D6510`/`R6510`, bank-select values, and char-ROM bases |
| `kernel.asm` | KERNAL entry points / vectors the loader uses |

Symbol values were taken from the standard C64 hardware map and the source's own
address comments, then confirmed by the byte-for-byte match against the originals.

## Notes

- Verification targets are `prg/*.prg`. The `prg/*.orig.prg` files are an **earlier
  (2008) build** and are a *different* binary (e.g. `Object.orig.prg` is ~28 KB vs
  this source's ~26 KB), so they are not used as the reference.
- `PicATitle.prg` is title-screen picture **data**, not assembly — there is no
  `PicATitle.asm`, so it is not a build target.
- The Windows `asm.bat`/`dis.bat` are left as-is; `build.sh` is the macOS entry point.
