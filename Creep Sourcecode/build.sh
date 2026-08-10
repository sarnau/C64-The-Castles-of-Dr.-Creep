#!/usr/bin/env bash
# Build The Castles of Dr. Creep from the reconstructed DASM source and verify
# each output against the shipped original. Built with: DASM 2.20.16
# (installed via `brew install dasm`, bottle version 2.20.17).
# Flags -o (output), -l (list file), -f1 (raw .prg with 2-byte load address)
# all match the installed dasm's --help output as-is; no adjustment needed.
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
