; ------------------------------------------------------------------------------------------------------------- ;
; C64 KERNAL Entry Points
; ------------------------------------------------------------------------------------------------------------- ;
SETLFS              = $FFBA
SETNAM              = $FFBD
LOAD                = $FFD5
SAVE                = $FFD8
OPEN                = $FFC0
CLOSE               = $FFC3
CHKIN               = $FFC6
CHKOUT              = $FFC9
CLRCHN              = $FFCC
CHRIN               = $FFCF
CHROUT              = $FFD2
READST              = $FFB7
IOINIT              = $FF84
CLALL                = $FFE7
; ------------------------------------------------------------------------------------------------------------- ;
; KERNAL hardware vectors
; ------------------------------------------------------------------------------------------------------------- ;
VNMI                = $FFFA                    ; Non-Maskable Interrupt Hardware Vector
VRES                = $FFFC                    ; System Reset Vector
VBRK                = $FFFE                    ; Maskable Interrupt Request / Break Hardware Vector
