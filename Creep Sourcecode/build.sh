#!/usr/bin/env bash
# Build The Castles of Dr. Creep from the reconstructed DASM source and verify
# each output against the shipped original. Built with: DASM 2.20.16
# (installed via `brew install dasm`, bottle version 2.20.17).
# Flags -o (output), -l (list file), -f1 (raw .prg with 2-byte load address)
# all match the installed dasm's --help output as-is; no adjustment needed.
set -u
cd "$(dirname "$0")"                 # -> "Creep Sourcecode/"
REPO_ROOT="$(pwd)"                   # absolute path to "Creep Sourcecode/"

build_one() {                        # $1=asm base name, $2=orig .prg
  local out="prg/$1.built.prg" orig="prg/$2"
  echo "=== $1 ==="

  # Assemble from an isolated temp tree so the checked-in game source
  # (asm/, inc/) is never modified. We only patch a *copy*:
  #   1. prepend a `processor 6502` directive (source predates it)
  #   2. dedent the `* equ $0800` origin line (this DASM needs `*` at col 0)
  #   3. flip backslashes -> forward slashes on include/incdir lines
  #      (source was written for a Windows-path DASM)
  #   4. rewrite `incdir ../inc` -> `incdir inc`: this DASM resolves INCDIR
  #      relative to the process cwd (which we set to the temp tree root,
  #      mirroring "Creep Sourcecode/"), not relative to the including
  #      file's own directory the way the original Windows DASM did.
  #   5. normalize explicit accumulator operands (`asl a`/`lsr a`/`rol a`/
  #      `ror a` -> bare `asl`/`lsr`/`rol`/`ror`) - this DASM only accepts
  #      the implied form. Same opcode either way; byte-safe dialect shim.
  local work
  work=$(mktemp -d)
  cp -R asm inc lst prg "$work/"

  local target_asm="$work/asm/$1.asm"
  sed -i '' '1s/^/    processor 6502\n/' "$target_asm"
  sed -i '' -E 's/^[[:space:]]*\* equ/* equ/' "$target_asm"
  sed -i '' -E '/(include|incdir)/ s/\\/\//g' "$target_asm"
  sed -i '' -E 's|^([[:space:]]*incdir[[:space:]]+)\.\./inc|\1inc|' "$target_asm"
  # (some lines carry a local sub-label before the mnemonic, e.g.
  #  ".NextObjWA         asl a", so match after start-of-line OR whitespace,
  #  not only at column 0)
  sed -E -i '' 's/(^|[[:space:]])([Aa][Ss][Ll]|[Ll][Ss][Rr]|[Rr][Oo][Ll]|[Rr][Oo][Rr])[[:space:]]+[aA]([[:space:]]|$)/\1\2\3/' "$target_asm"

  # inc/CC_DataTables.asm line 135 is a divider comment missing its leading
  # `;` (checked-in typo), so DASM tries to parse the dashes as a mnemonic.
  # Fix the temp copy only; the checked-in file stays untouched.
  sed -i '' '135s/^/;/' "$work/inc/CC_DataTables.asm"

  # inc/CC_VarsGame.asm line 99 defines CC_LoadCtrlIdResume but the line is
  # commented out, even though inc/CC_DataTexts.asm still has a live
  # (non-commented) use of it (`ScreenLineIdResume = CC_LoadCtrlIdResume`).
  # Re-enable the equate in the temp copy only, using the exact value already
  # documented on that same line ($03).
  sed -i '' '99s/^;//' "$work/inc/CC_VarsGame.asm"

  ( cd "$work" && dasm "asm/$1.asm" -o"$REPO_ROOT/$out" -l"$REPO_ROOT/lst/$1.txt" -f1 )
  local status=$?
  rm -rf "$work"
  [ $status -eq 0 ] || { echo "  ASSEMBLE FAILED"; return 1; }

  if cmp -s "$out" "$orig"; then
    echo "  OK  byte-identical to $2"
  else
    echo "  DIFF vs $2:"; cmp "$out" "$orig" | head -1
    return 1
  fi
}

rc=0
# Verify against prg/*.prg — the build this reconstructed source targets.
# The prg/*.orig.prg files are an EARLIER (2008) build of the game and are a
# different binary (e.g. Object.orig.prg is ~28 KB vs this source's ~26 KB).
build_one object Object.prg || rc=1
# creep and PicATitle added in later tasks
exit $rc
