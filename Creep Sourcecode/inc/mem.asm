; ------------------------------------------------------------------------------------------------------------- ;
; C64 Memory Layout - CPU Port ($00/$01) and Bank-Select Values
; ------------------------------------------------------------------------------------------------------------- ;
D6510                = $00                     ; CPU Port Data Direction Register
R6510                = $01                     ; CPU Port Data Register
; ------------------------------------------------------------------------------------------------------------- ;
; R6510 bank-select values ($01): bit0 LORAM (basic), bit1 HIRAM (kernal), bit2 CHAREN (I/O vs char ROM @ $D000)
; ------------------------------------------------------------------------------------------------------------- ;
BcKoff               = $30                     ; basic=off char=on  kernal=off  (RAM $A000-$BFFF/$E000-$FFFF, char ROM $D000)
B_Koff               = $34                     ; basic=off io=on    kernal=off  (RAM $A000-$BFFF/$E000-$FFFF, I/O $D000)
B__off               = $36                     ; basic=off io=on    kernal=on   (RAM $A000-$BFFF, I/O $D000, KERNAL $E000-$FFFF)
; ------------------------------------------------------------------------------------------------------------- ;
; Character ROM base addresses (visible at $D000-$DFFF only while CHAREN=0, see BcKoff above). Standard C64
; layout: $D000-$D7FF = set 1 (uppercase/graphics), $D800-$DFFF = set 2 (lowercase/uppercase).
; CHR_UPR/CHR_LOR ("reversed") have no separate ROM storage on real hardware - object.asm's .CopyChr loop
; (asm/object.asm ~line 9811) copies the glyph bytes verbatim with no inversion, and this game renders text as
; multicolor bitmap with a separately-set foreground/background per glyph (see .SetColor just above .CopyChr),
; so the reversed variants are inferred to alias the same ROM base as their non-reversed counterpart; the
; reverse look is produced by that color swap, not by different glyph data. Flagged for verification.
; ------------------------------------------------------------------------------------------------------------- ;
CHR_UP               = $D000                   ; character rom: upper case / graphics set
CHR_UPR              = $D000                   ; character rom: upper case / reversed (inferred alias of CHR_UP)
CHR_LO               = $D800                   ; character rom: lower case set
CHR_LOR              = $D800                   ; character rom: lower case / reversed (inferred alias of CHR_LO)
