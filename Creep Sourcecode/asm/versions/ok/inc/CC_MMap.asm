; ------------------------------------------------------------------------------------------------------------- ;
; The Castles of Dr Creep
; ------------------------------------------------------------------------------------------------------------- ;
; Memory Map
; ------------------------------------------------------------------------------------------------------------- ;
; $0000 - $00ff:  Zero Page Values
; $0200 - $02ff:  <not used>
; $0300 - $03ff:  <not used>
; $0400 - $07e8:  Video Screen 1 - Displays Game Options and Castle Load File Names
;
; $0800 - $77ff:  Game Code - Initial load up to 7919
;
; $7800 - $97ff:  Game Level Data / Demo Music
; $9800 - $b7ff:  Game Store Data
; $b800 - $b8ff:  Best Times
;
; $b900 - $b9ff:  <not used>
; $ba00 - $baff:  Row Control Data for Game Options and Castle Load Screen
; $bb00 - $bbff:  Pointer HiRes Screen Rows: High
; $bc00 - $bcff:  Pointer HiRes Screen Rows: Low
; $bd00 - $bdff:  Sprite         Work Areas - $08 Blocks of $20 Bytes
; $be00 - $beff:  Object Status  Work Areas - $20 Blocks of $08 Bytes
; $bf00 - $bfff:  Object Dynamic Work Areas - $20 Blocks of $08 Bytes
;
; $c000 - $c7ff:  Sprite Move Control Screen
; $c800 - $c9ff:  Sprite Data Area 1
; $ca00 - $cbff:  Sprite Data Area 2
; $cc00 - $cfe8:  Video Screen 2 - Holds Color Values for Multicolour HiRes Screen
; $cff8 - $cfff:  Sprites Data Pointer
; $e000 - $fff9:  Multicolour HiRes Screen
; $fffa - $fffb:  Vector: NMI
; $fffc - $fffd:  Vector: <not set> System Reset
; $fffe - $ffff:  Vector: IRQ
; ------------------------------------------------------------------------------------------------------------- ;
