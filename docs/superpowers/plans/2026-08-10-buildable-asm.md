# Buildable ASM Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Author the seven missing C64 system-definition includes and a macOS DASM build so `Creep Sourcecode/` assembles to binaries **byte-identical to `prg/*.orig.prg`**.

**Architecture:** Iterative bring-up. A `build.sh` runs DASM the way the Windows `asm.bat` did (from the `Creep Sourcecode/` dir); we add `inc/*.asm` system-definition files until `object.asm` assembles with no undefined symbols, then `cmp` the output against the original and resolve any divergence to zero. Repeat for `creep.asm` and `PicATitle`.

**Tech Stack:** DASM 6502 macro-assembler (Homebrew), bash, `cmp`/`xxd` for byte verification.

**Convention:** the source uses the classic Commodore names (`SCROLY`=$D011, `SPENA`=$D015, `SP0COL`=$D027, `FRELO1`=$D400, `SIGVOL`=$D418, `TIMAHI`=$DC05, …), extracted from its own inline address comments. The "test" for every task is *assemble + byte-diff*; there is no unit-test framework.

---

## File structure

- Create `Creep Sourcecode/inc/vic.asm` — VIC-II registers `$D000–$D02E`
- Create `Creep Sourcecode/inc/sid.asm` — SID registers `$D400–$D41C`
- Create `Creep Sourcecode/inc/cia1.asm` — CIA #1 `$DC00–$DC0F`
- Create `Creep Sourcecode/inc/cia2.asm` — CIA #2 `$DD00–$DD0F`
- Create `Creep Sourcecode/inc/color.asm` — `COLORAM`, palette names, `HR_*` packed pairs
- Create `Creep Sourcecode/inc/mem.asm` — CPU port (`R6510`/`D6510`) + bank-select constants
- Create `Creep Sourcecode/inc/kernel.asm` — KERNAL entry points used by the loader
- Create `Creep Sourcecode/build.sh` — assemble + verify each target on macOS
- (Leave `asm.bat`, `dis.bat`, and all existing files unchanged.)

---

## Task 1: Install DASM and stand up the build harness

**Files:**
- Create: `Creep Sourcecode/build.sh`

- [ ] **Step 1: Install DASM**

Run: `brew install dasm`
Then: `dasm 2>&1 | head -1`
Expected: a DASM banner like `DASM 2.20.14.1`. Record the exact version in a comment in `build.sh`.

- [ ] **Step 2: Write the build script (single target, verify-by-diff)**

Create `Creep Sourcecode/build.sh`:

```bash
#!/usr/bin/env bash
# Build The Castles of Dr. Creep from the reconstructed DASM source and verify
# each output against the shipped original. Built with: DASM <fill in version>.
set -u
cd "$(dirname "$0")"                 # -> "Creep Sourcecode/"

build_one() {                        # $1=asm base name, $2=orig .prg
  local src="asm/$1.asm" out="prg/$1.built.prg" orig="prg/$2"
  echo "=== $1 ==="
  dasm "$src" -o"$out" -l"lst/$1.txt" -f1 || { echo "  ASSEMBLE FAILED"; return 1; }
  if cmp -s "$out" "$orig"; then
    echo "  OK  byte-identical to $2"
  else
    echo "  DIFF vs $2:"; cmp "$out" "$orig" | head -1
    return 1
  fi
}

rc=0
build_one object Object.orig.prg || rc=1
# creep and PicATitle added in later tasks
exit $rc
```

Then: `chmod +x "Creep Sourcecode/build.sh"`

- [ ] **Step 3: Run it — expect a *missing include file* failure (the red state)**

Run: `cd "Creep Sourcecode" && ./build.sh`
Expected: assemble fails with DASM unable to open `cia1.asm` (or similar). This confirms the harness runs and the only gap is the missing includes. (`-f1` = raw `.prg` with a 2-byte load address, matching a C64 program file.)

- [ ] **Step 4: Commit**

```bash
git add "Creep Sourcecode/build.sh"
git commit -m "build: add macOS DASM build+verify harness for object.asm"
```

---

## Task 2: Resolve include-path handling (backslashes / CWD)

The source uses backslash paths (`incdir ..\inc`, `include inc\CC_VarsGame.asm`) and the Windows `asm.bat` ran DASM from the `Creep Sourcecode/` directory. Confirm DASM-on-macOS resolves those, and fix the harness if not — **without editing the checked-in source**.

**Files:**
- Modify: `Creep Sourcecode/build.sh` (only if a path shim is needed)

- [ ] **Step 1: Probe backslash handling**

Create a throwaway probe `\_probe.asm` in `Creep Sourcecode/`:

```asm
    processor 6502
    incdir ..\inc
    include inc\CC_Zpg.asm
```

Run: `cd "Creep Sourcecode" && dasm _probe.asm -o/dev/null 2>&1 | head -3; rm -f _probe.asm`
Expected — one of:
- **Resolves** ("Complete." / only symbol errors) → DASM converts `\`→`/`; no shim needed, skip Step 2.
- **"unable to open 'inc\CC_Zpg.asm'"** → backslashes are literal; do Step 2.

- [ ] **Step 2: (only if needed) add a path shim to build.sh**

Assemble from a generated temp tree whose include directives use `/`. Insert into `build_one` before the `dasm` call:

```bash
  local work; work="$(mktemp -d)"
  cp -R asm inc prg "$work"/ 2>/dev/null
  # normalise backslash path separators in include/incdir directives only
  sed -i '' -E 's/\\(inc|CC_|[A-Za-z])/\/\1/g' "$work/asm/$1.asm"
  ( cd "$work" && dasm "asm/$1.asm" -o"$OLDPWD/$out" -l"$OLDPWD/lst/$1.txt" -f1 ) \
    || { rm -rf "$work"; echo "  ASSEMBLE FAILED"; return 1; }
  rm -rf "$work"
```

(If Step 1 showed backslashes resolve, leave `build_one` as in Task 1.)

- [ ] **Step 3: Re-run and confirm the failure has moved from *files* to *symbols***

Run: `cd "Creep Sourcecode" && ./build.sh 2>&1 | head -20`
Expected: DASM now opens every include and fails only with **undefined symbol** errors (e.g. `SCROLY`, `SP0COL`) — not "unable to open". That is the signal to start Task 3.

- [ ] **Step 4: Commit (only if build.sh changed)**

```bash
git add "Creep Sourcecode/build.sh"
git commit -m "build: normalise backslash include paths for DASM on macOS"
```

---

## Task 3: Author the system-definition includes → clean assemble of `object.asm`

Create the seven includes with the standard C64 map, using the names the source uses. Then loop: assemble → read the next *undefined symbol* → add its definition at the correct address → repeat until `object.asm` assembles with zero undefined symbols. The concrete starting content below covers the symbols extracted from the source; the loop catches any remainder.

**Files:**
- Create: `inc/vic.asm`, `inc/sid.asm`, `inc/cia1.asm`, `inc/cia2.asm`, `inc/color.asm`, `inc/mem.asm`, `inc/kernel.asm`

- [ ] **Step 1: `inc/vic.asm`**

```asm
; VIC-II registers $D000-$D02E
SP0X    = $D000
SP0Y    = $D001
SP1X    = $D002
SP1Y    = $D003
SP2X    = $D004
SP2Y    = $D005
SP3X    = $D006
SP3Y    = $D007
SP4X    = $D008
SP4Y    = $D009
SP5X    = $D00A
SP5Y    = $D00B
SP6X    = $D00C
SP6Y    = $D00D
SP7X    = $D00E
SP7Y    = $D00F
MSIGX   = $D010    ; sprite X MSBs
SCROLY  = $D011    ; control reg 1 (bitmap/rows/yscroll)
RASTER  = $D012
VMCSB   = $D018    ; memory pointers (screen/char base)
VICIRQ  = $D019    ; IRQ status
IRQMASK = $D01A    ; IRQ enable
SPENA   = $D015    ; sprite enable
SCROLX  = $D016    ; control reg 2 (multicolor/xscroll/cols)
YXPAND  = $D017    ; sprite Y expand
SPBGPR  = $D01B    ; sprite-bg priority
SPMC    = $D01C    ; sprite multicolor enable
XXPAND  = $D01D    ; sprite X expand
SPSPCL  = $D01E    ; sprite-sprite collision
SPBGCL  = $D01F    ; sprite-bg collision
EXTCOL  = $D020    ; border colour
BGCOL0  = $D021    ; background colour 0
SPMC0   = $D025    ; sprite multicolour 0
SPMC1   = $D026    ; sprite multicolour 1
SP0COL  = $D027
SP1COL  = $D028
SP2COL  = $D029
SP3COL  = $D02A
SP4COL  = $D02B
SP5COL  = $D02C
SP6COL  = $D02D
SP7COL  = $D02E
```

- [ ] **Step 2: `inc/sid.asm`**

```asm
; SID registers $D400-$D41C
FRELO1  = $D400
FREHI1  = $D401
PWLO1   = $D402
PWHI1   = $D403
VCREG1  = $D404    ; voice 1 control (waveform/gate)
ATDCY1  = $D405
SUREL1  = $D406
FRELO2  = $D407
FREHI2  = $D408
PWLO2   = $D409
PWHI2   = $D40A
VCREG2  = $D40B
ATDCY2  = $D40C
SUREL2  = $D40D
FRELO3  = $D40E
FREHI3  = $D40F
PWLO3   = $D410
PWHI3   = $D411
VCREG3  = $D412
ATDCY3  = $D413
SUREL3  = $D414
CUTLO   = $D415    ; filter cutoff low
CUTHI   = $D416    ; filter cutoff high
RESON   = $D417    ; resonance / filter routing
SIGVOL  = $D418    ; volume + filter mode
```

- [ ] **Step 3: `inc/cia1.asm`**

```asm
; CIA #1 $DC00-$DC0F
CIAPRA  = $DC00    ; port A (joystick 2 / keyboard cols)
CIAPRB  = $DC01    ; port B
CIDDRA  = $DC02
CIDDRB  = $DC03
TIMALO  = $DC04    ; timer A low
TIMAHI  = $DC05    ; timer A high
TODTEN  = $DC08    ; time-of-day tenths
CIAICR  = $DC0D    ; interrupt control
CIACRA  = $DC0E    ; control A
CIACRB  = $DC0F    ; control B
```

- [ ] **Step 4: `inc/cia2.asm`**

```asm
; CIA #2 $DD00-$DD0F
CI2PRA  = $DD00    ; port A (VIC bank + serial)
C2DDRA  = $DD02
TO2TEN  = $DD08
CI2ICR  = $DD0D
CI2CRA  = $DD0E
CI2CRB  = $DD0F
```

- [ ] **Step 5: `inc/color.asm`**

```asm
; Colour RAM + C64 palette + packed HR_ nibble pairs
COLORAM = $D800

BLACK   = $00
WHITE   = $01
RED     = $02
CYAN    = $03
PURPLE  = $04
GREEN   = $05
BLUE    = $06
YELLOW  = $07
ORANGE  = $08
BROWN   = $09
LT_RED  = $0A
DK_GREY = $0B
GREY    = $0C
LT_GREEN= $0D
LT_BLUE = $0E
LT_GREY = $0F
```

Then append the `HR_<hi><lo>` packed constants. Generate the full 16x16 set programmatically so none is ever undefined (name = `HR_` + CamelCase colour pair, value = `(hi<<4)|lo`). Produce the block once and paste it in:

Run:
```bash
python3 - <<'PY' >> "Creep Sourcecode/inc/color.asm"
n=["Black","White","Red","Cyan","Purple","Green","Blue","Yellow",
   "Orange","Brown","LtRed","DkGrey","Grey","LtGreen","LtBlue","LtGrey"]
print()
for hi in range(16):
    for lo in range(16):
        print(f"HR_{n[hi]}{n[lo]:8s} = ${hi:X}{lo:X}")
PY
```

Expected: 256 `HR_*` equates appended (e.g. `HR_RedRed = $22`, `HR_WhiteBlack = $10`). If the source uses a different casing for any `HR_` name, the assemble loop (Step 8) flags it and you adjust the generator's `n[]` labels.

- [ ] **Step 6: `inc/mem.asm`**

```asm
; CPU I/O port and bank-select constants
D6510   = $00      ; CPU port direction
R6510   = $01      ; CPU port data (memory banking)
; Bank/config values used by the source (confirm names against the assemble loop)
BcKoff  = $36      ; BASIC=off, CHAR RAM, KERNAL=on  (%00110110)
B_Koff  = $35      ; BASIC=off, I/O on, KERNAL=off   (%00110101)
BcKoff2 = $34      ; all RAM                          (%00110100)
```

- [ ] **Step 7: `inc/kernel.asm`**

```asm
; KERNAL entry points / vectors (loader uses these)
CINT    = $FF81
IOINIT  = $FF84
SETLFS  = $FFBA
SETNAM  = $FFBD
OPEN    = $FFC0
CLOSE   = $FFC3
CHKIN   = $FFC6
CHRIN   = $FFCF
CHROUT  = $FFD2
LOAD    = $FFD5
SAVE    = $FFD8
CLALL   = $FFE7
IRQVEC  = $0314    ; RAM IRQ vector
NMIVEC  = $0318    ; RAM NMI vector
```

- [ ] **Step 8: Iterate to a clean assemble**

Run: `cd "Creep Sourcecode" && ./build.sh 2>&1 | grep -iE "unresolved|undefined|error" | head`
For each undefined symbol reported: look up its C64 address/value (VIC/SID/CIA in the maps above; colour/`HR_`/mem/kernel per its device) and add the `equ` to the matching include. Re-run. Repeat until there are **no** undefined-symbol / unresolved errors — the assemble completes and writes `prg/object.built.prg`.
Expected end state: `./build.sh` gets past assembly (it may still report a byte DIFF — that's Task 4).

- [ ] **Step 9: Commit**

```bash
git add "Creep Sourcecode/inc/vic.asm" "Creep Sourcecode/inc/sid.asm" \
        "Creep Sourcecode/inc/cia1.asm" "Creep Sourcecode/inc/cia2.asm" \
        "Creep Sourcecode/inc/color.asm" "Creep Sourcecode/inc/mem.asm" \
        "Creep Sourcecode/inc/kernel.asm"
git commit -m "asm: add C64 system-definition includes; object.asm assembles clean"
```

---

## Task 4: Byte-exact match for `object.prg`

**Files:**
- Modify: whichever `inc/*.asm` value is wrong (data-driven by the diff)

- [ ] **Step 1: Locate the first divergence**

Run: `cd "Creep Sourcecode" && cmp prg/object.built.prg prg/Object.orig.prg`
Expected: either "no differences" (done → skip to Step 3) or `differ: byte N, line M`.

- [ ] **Step 2: Diagnose and fix**

Run: `cmp -l prg/object.built.prg prg/Object.orig.prg | head` and inspect around the offset with `xxd -s $((N-8)) -l 32` on both files. Map the file offset back to an address (offset − 2 + $0800) and find it in `lst/object.txt`. A single wrong byte almost always means one include constant has the wrong value (e.g. a mis-set `HR_*` or bank value); fix that `equ` and re-run `./build.sh`. Loop until `cmp -s` succeeds.

If the divergence is structural (size differs, many bytes), it means this reconstruction targets a *different* build than `Object.orig.prg` — record the offset/size difference and the likely cause in `docs/` and treat "assembles + documented diff" as the outcome for this target (per the spec's risk note).

- [ ] **Step 3: Commit**

```bash
git add -A "Creep Sourcecode/inc"
git commit -m "asm: object.prg byte-identical to Object.orig.prg"
```

---

## Task 5: Build and verify `creep.asm`

**Files:**
- Modify: `Creep Sourcecode/build.sh`; possibly `inc/kernel.asm` (loader uses more KERNAL calls)

- [ ] **Step 1: Enable the target in build.sh**

In `build.sh`, uncomment/add under the `object` line:

```bash
build_one creep Creep.orig.prg || rc=1
```

- [ ] **Step 2: Assemble and resolve**

Run: `cd "Creep Sourcecode" && ./build.sh 2>&1 | sed -n '/=== creep ===/,$p'`
Resolve any new undefined symbols (likely additional KERNAL routines in `inc/kernel.asm`) exactly as in Task 3 Step 8, until it assembles.

- [ ] **Step 3: Byte-diff to exact (or documented)**

Run: `cmp prg/creep.built.prg prg/Creep.orig.prg`
Resolve to identical as in Task 4, or document a structural diff.

- [ ] **Step 4: Commit**

```bash
git add -A "Creep Sourcecode"
git commit -m "asm: build creep.asm and verify against Creep.orig.prg"
```

---

## Task 6: Build and verify `PicATitle`

**Files:**
- Modify: `Creep Sourcecode/build.sh`

- [ ] **Step 1: Find the PicATitle source**

Run: `ls "Creep Sourcecode/asm/" && grep -rl -i "picatitle\|pic a title" "Creep Sourcecode/asm" | head`
Identify the asm file that produces `PicATitle.orig.prg` (may be a differently-named `.asm` under `asm/`). Note its base name as `<pic>`.

- [ ] **Step 2: Enable the target and build**

Add to `build.sh`: `build_one <pic> PicATitle.orig.prg || rc=1`
Run: `cd "Creep Sourcecode" && ./build.sh 2>&1 | sed -n '/=== <pic> ===/,$p'`
Resolve undefined symbols and byte-diff to exact/documented as before.

- [ ] **Step 3: Commit**

```bash
git add -A "Creep Sourcecode"
git commit -m "asm: build PicATitle and verify against PicATitle.orig.prg"
```

---

## Task 7: Finalize — build script gate + build note

**Files:**
- Modify: `Creep Sourcecode/build.sh`
- Create: `Creep Sourcecode/BUILD.md`

- [ ] **Step 1: Confirm the full build passes as a gate**

Run: `cd "Creep Sourcecode" && ./build.sh; echo "exit=$?"`
Expected: every target prints "OK byte-identical" (or the documented-diff note) and `exit=0` when all achievable matches hold.

- [ ] **Step 2: Write the build note**

Create `Creep Sourcecode/BUILD.md`: how to build on macOS (`brew install dasm`, `./build.sh`), the pinned DASM version, what each `inc/*.asm` provides, and any documented residual diffs from Tasks 4–6.

- [ ] **Step 3: Update repo docs**

Add one line to `README.md` (Tools/build section) and `CLAUDE.md` ("Building the original assembly") noting the build is now reproducible on macOS via `Creep Sourcecode/build.sh`, superseding the "not reproducible in this environment" caveat.

- [ ] **Step 4: Commit**

```bash
git add "Creep Sourcecode/build.sh" "Creep Sourcecode/BUILD.md" README.md CLAUDE.md
git commit -m "build: byte-verified macOS build for all targets; document it"
```

---

## Notes for the implementer

- **`-f1` output format** gives a `.prg` with the 2-byte little-endian load address prepended — that is exactly what the `.orig.prg` files are, so `cmp` is a valid whole-file comparison.
- **The assemble loop is the mechanism**, not a placeholder: DASM names each undefined symbol; every C64 hardware symbol has a fixed, well-known address (maps in Task 3), so each fix is deterministic.
- **Never edit the checked-in `.asm`/`inc/CC_*` game source** to force a match — fixes go in the *new* `inc/*.asm` system files (or `build.sh`). A genuine reconstruction-vs-original difference is documented, not papered over.
- If `dasm` reports macro/scope errors (not undefined symbols), check the DASM version against `asm.bat`'s expectations and pin a compatible one in `BUILD.md`.
