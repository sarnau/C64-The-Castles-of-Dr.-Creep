; ------------------------------------------------------------------------------------------------------------- ;
; The Castles of Dr Creep - Zero Page
; ------------------------------------------------------------------------------------------------------------- ;
; Zero Page - Cannot be used directly by C64ASM because always the long form is generated - no zp optimisation
; ------------------------------------------------------------------------------------------------------------- ;
CC_ZPgSprt__PosX = $10                            ; horizontal position sprites 0-7
CC_ZPgSprt00PosX = CC_ZPgSprt__PosX + $00         ; VIC 2 - $D000 - horizontal position sprite 0
CC_ZPgSprt01PosX = CC_ZPgSprt__PosX + $01         ; VIC 2 - $D002 - horizontal position sprite 1
CC_ZPgSprt02PosX = CC_ZPgSprt__PosX + $02         ; VIC 2 - $D004 - horizontal position sprite 2
CC_ZPgSprt03PosX = CC_ZPgSprt__PosX + $03         ; VIC 2 - $D006 - horizontal position sprite 3
CC_ZPgSprt04PosX = CC_ZPgSprt__PosX + $04         ; VIC 2 - $D008 - horizontal position sprite 4
CC_ZPgSprt05PosX = CC_ZPgSprt__PosX + $05         ; VIC 2 - $D00a - horizontal position sprite 5
CC_ZPgSprt06PosX = CC_ZPgSprt__PosX + $06         ; VIC 2 - $D00c - horizontal position sprite 6
CC_ZPgSprt07PosX = CC_ZPgSprt__PosX + $07         ; VIC 2 - $D00e - horizontal position sprite 7
; ------------------------------------------------------------------------------------------------------------ ;
CC_ZPgSprt__PosY = $18                            ; vertical position sprites 0-7
CC_ZPgSprt00PosY = CC_ZPgSprt__PosY + $08         ; VIC 2 - $D001 - vertical   position sprite 0
CC_ZPgSprt01PosY = CC_ZPgSprt__PosY + $09         ; VIC 2 - $D003 - vertical   position sprite 1
CC_ZPgSprt02PosY = CC_ZPgSprt__PosY + $0a         ; VIC 2 - $D005 - vertical   position sprite 2
CC_ZPgSprt03PosY = CC_ZPgSprt__PosY + $0b         ; VIC 2 - $D007 - vertical   position sprite 3
CC_ZPgSprt04PosY = CC_ZPgSprt__PosY + $0c         ; VIC 2 - $D009 - vertical   position sprite 4
CC_ZPgSprt05PosY = CC_ZPgSprt__PosY + $0d         ; VIC 2 - $D00b - vertical   position sprite 5
CC_ZPgSprt06PosY = CC_ZPgSprt__PosY + $0e         ; VIC 2 - $D00d - vertical   position sprite 6
CC_ZPgSprt07PosY = CC_ZPgSprt__PosY + $0f         ; VIC 2 - $D00f - vertical   position sprite 7
; ------------------------------------------------------------------------------------------------------------- ;
CC_ZPgSprt__MSBY = $20                            ; VIC 2 - $D010 - vertical position sprites 0-7 MSB
CC_ZPgSprt__Enab = $21                            ; VIC 2 - $D015 - enable            sprites 0-7
CC_ZPgVICMemCtrl = $22                            ; VIC 2 - $D018 - VIC-II Chip Memory Control Register
CC_ZPgColrBorder = $23                            ; VIC 2 - $D020 - Border Color
CC_ZPgColrBackGr = $24                            ; VIC 2 - $D021 - Background Color 0
CC_ZPgVICControl = $25                            ; VIC 2 - $D016 - Horizontal Fine Scrolling and Control Register
; ------------------------------------------------------------------------------------------------------------- ;
CC_ZPgSprt__DatP = $26                            ; data pointers sprites 0-7
CC_ZPgSprt00DatP = CC_ZPgSprt__DatP + $00         ; $cff8 - data pointer sprite 0
CC_ZPgSprt01DatP = CC_ZPgSprt__DatP + $01         ; $cff9 - data pointer sprite 1
CC_ZPgSprt02DatP = CC_ZPgSprt__DatP + $02         ; $cffa - data pointer sprite 2
CC_ZPgSprt03DatP = CC_ZPgSprt__DatP + $03         ; $cffb - data pointer sprite 3
CC_ZPgSprt04DatP = CC_ZPgSprt__DatP + $04         ; $cffc - data pointer sprite 4
CC_ZPgSprt05DatP = CC_ZPgSprt__DatP + $05         ; $cffd - data pointer sprite 5
CC_ZPgSprt06DatP = CC_ZPgSprt__DatP + $06         ; $cffe - data pointer sprite 6
CC_ZPgSprt07DatP = CC_ZPgSprt__DatP + $07         ; $cfff - data pointer sprite 7
; ------------------------------------------------------------------------------------------------------------- ;
