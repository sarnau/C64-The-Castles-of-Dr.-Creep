; ------------------------------------------------------------------------------------------------------------- ;
; The Castles of Dr Creep - Screens
; ------------------------------------------------------------------------------------------------------------- ;
; Screen locations
; ------------------------------------------------------------------------------------------------------------- ;
CC_ScrnOptFile   = $0400                          ; Options/LoadData       screen $0400-$07ff
CC_ScrnMoveCtrl  = $c000                          ; Players move control   screen $c000-$c7ff
CC_ScreenRam     = $cc00                          ; screen ram for object type 0 colors
CC_BitmapRam     = $e000                          ; hires rooms / maps display screen
;
CC_TextScrnCtrl  = $ba00                          ; row control data for options and castle load screen
CC_TabHiResRowHi = $bb00                          ; pointer hires screen row high
CC_TabHiResRowLo = $bc00                          ; pointer hires screen row low
CC_SprtPtrsBase  = $c000                          ; base address sprite pointer storage
CC_SprtPtr00     = CC_SprtPtrsBase + $ff8
CC_SprtPtr01     = CC_SprtPtrsBase + $ff9
CC_SprtPtr02     = CC_SprtPtrsBase + $ffa
CC_SprtPtr03     = CC_SprtPtrsBase + $ffb
CC_SprtPtr04     = CC_SprtPtrsBase + $ffc
CC_SprtPtr05     = CC_SprtPtrsBase + $ffd
CC_SprtPtr06     = CC_SprtPtrsBase + $ffe
CC_SprtPtr07     = CC_SprtPtrsBase + $fff
; ------------------------------------------------------------------------------------------------------------- ;
; Row Control Data for Options / Castle Load Screen
; ------------------------------------------------------------------------------------------------------------- ;
CC_TextScrnRowX  = CC_TextScrnCtrl                ; start point in CC_TextScrnRow
CC_TextScrnColL    = $03                          ; default start column of left  output area
CC_TextScrnColR    = $16                          ; default start column of right output area
CC_TextScrnRowY  = CC_TextScrnCtrl + 1            ; screen row number
CC_TextScrnDynS    = $0c                          ; start row of dynamically filled screen area
CC_TextScrnDynE    = $18                          ; end   row of dynamically filled screen area
CC_TextScrnType  = CC_TextScrnCtrl + 2            ; entry type id
CC_TextScrnLives   = $00                          ; lives on/off
CC_TextScrnExit    = $01                          ; exit menu
CC_TextScrnFile    = $02                          ; dynamic castle data file entry
CC_TextScrnResum   = $03                          ; resume a saved game
CC_TextScrnTimes   = $04                          ; view high scores
CC_TextScrnLen   = CC_TextScrnCtrl + 3            ; entry length for type CC_TextScrnFile name
CC_TextScrnMaxL    = $0f                          ; max len CC_TextScrnFile name
;
CC_TextScrnCrsrX = CC_TextScrnCtrl + 8            ; initial cursor position to type CC_TextScrnExit CC_TextScrnRowX
CC_TextScrnCrsrY = CC_TextScrnCtrl + 9            ; initial cursor position to type CC_TextScrnExit CC_TextScrnRowY
; ------------------------------------------------------------------------------------------------------------- ;
; Screen data for Control Screen - pointer in ($3c/$3d)
; ------------------------------------------------------------------------------------------------------------- ;
CC_CtrlFloorStrt = $04                            ; floor: start  tile
CC_CtrlFloorMid  = $44                            ; floor: middle tile
CC_CtrlFloorEnd  = $40                            ; floor: end    tile
CC_CtrlPole      = $10                            ; pole
CC_CtrlLadderBot = $01                            ; ladder: bottom - mid     consists of both: bot and top
CC_CtrlLadderTop = $10                            ; ladder: top    - top/mid consist  of both: bot and top
CC_CtrlTrapLeft  = $fb                            ; trap open: start          - resets floor to CC_CtrlFloorEnd
CC_CtrlTrapRight = $bf                            ; trap open: end            - resets floor to CC_CtrlFloorStrt
CC_CtrlFrStLeft  = $fb                            ; frank coffin: Left        - resets floor to CC_CtrlFloorEnd
CC_CtrlFrStRight = $bf                            ; frank coffin: Right       - resets floor to CC_CtrlFloorStrt
CC_CtrlFFLeft    = $fb                            ; force field closed: start - resets floor to CC_CtrlFloorEnd
CC_CtrlFFRight   = $bf                            ; force field closed: end   - resets floor to CC_CtrlFloorStrt
; ------------------------------------------------------------------------------------------------------------- ;
; Joystik Action
; ------------------------------------------------------------------------------------------------------------- ;
CC_WAJoyNoMove   = $80                            ; 
CC_WAJoyMoveU    = $00                            ; ....
CC_WAJoyMoveUR   = $01                            ; ...#
CC_WAJoyMoveR    = $02                            ; ..#.
CC_WAJoyMoveDR   = $03                            ; ..##
CC_WAJoyMoveD    = $04                            ; .#..
CC_WAJoyMoveDL   = $05                            ; .#.#
CC_WAJoyMoveL    = $06                            ; .##.
CC_WAJoyMoveUL   = $07                            ; .###
; ------------------------------------------------------------------------------------------------------------- ;
