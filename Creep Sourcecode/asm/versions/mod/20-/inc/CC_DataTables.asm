; ------------------------------------------------------------------------------------------------------------- ;
; Castles of Dr Creep - Tables
; ------------------------------------------------------------------------------------------------------------- ;
TabColorLiveCount   dc.b CC_ColorLivesLostAll       ; .hbu016. - colors depending on lives count
                    dc.b CC_ColorLivesLastOne       ; 
                    dc.b CC_ColorLivesLostOne       ; .hbu016.
                    dc.b CC_ColorLivesLostNone      ; 
; ------------------------------------------------------------------------------------------------------------- ;
TabColorPlayer      = *                             ; player color table
TabColorPlayer1     dc.b CC_MultiColor0Player1      ; player 1
TabColorPlayer2     dc.b CC_MultiColor0Player2      ; player 2
; ------------------------------------------------------------------------------------------------------------- ;
TabColorBestTimes   dc.b WHITE                      ; line colors for best times display
                    dc.b YELLOW                     ; 
                    dc.b GREEN                      ; 
                    dc.b LT_RED                     ; 
                    dc.b LT_RED                     ; 
                    dc.b LT_RED                     ; 
                    dc.b ORANGE                     ; 
                    dc.b ORANGE                     ; 
                    dc.b ORANGE                     ; 
                    dc.b LT_GREY                    ; 
; ------------------------------------------------------------------------------------------------------------- ;
TabRasterColorPos   dc.b $00                        ; standard background layout for all exit screens
                    dc.b DK_GREY                    ; 
                    dc.b $a2                        ; raster scan line: start DK_GREY
                    dc.b BROWN                      ; 
                    dc.b $ca                        ; raster scan line: start BROWN
                    dc.b DK_GREY                    ; 
                    dc.b $d2                        ; raster scan line: start DK_GREY
; ------------------------------------------------------------------------------------------------------------- ;
RoomTitleScreen     dc.w RoomDrawObject             ; the game start screen
                    
                    dc.b $08                        ; NumObjects: 8
                    dc.b NoObjDoorNormal            ; ObjectID  : Door
                    dc.b $10                        ; StartPos  : PosX = 10
                    dc.b $58                        ; StartPos  : PosY = 58
                    dc.b $14                        ; NextPos   : PosX + 14
                    dc.b $00                        ; NextPos   : PosY + 00
                    dc.b $00                        ; EndOfData
                    
                    dc.w RoomTextLine
                    
                    dc.b $28                        ; StartPos  : PosX = 28
                    dc.b $30                        ; StartPos  : PosY = 30
                    dc.b ORANGE                     ; ColorNo   :
                    dc.b $21                        ; Format    : 21 = normal/normal size
                    dc.b $54 ; t                    ; Text      : (max 20 chr) = the castles oF
                    dc.b $48 ; h
                    dc.b $45 ; e
                    dc.b $20 ; _
                    dc.b $43 ; c
                    dc.b $41 ; a
                    dc.b $53 ; s
                    dc.b $54 ; t
                    dc.b $4c ; l
                    dc.b $45 ; e
                    dc.b $53 ; s
                    dc.b $20 ; _
                    dc.b $4f ; o
                    dc.b $c6 ; F                    ; EndOfLine = Bit 7 set
                    
                    dc.b $30                        ; StartPos  : PosX = 30
                    dc.b $40                        ; StartPos  : PosY = 40
                    dc.b LT_GREEN                   ; ColorNo   :
                    dc.b $22                        ; Format    : 22 = normal/double size
                    dc.b $44 ; d                    ; Text      : (max 20 chr) = doctor creeP
                    dc.b $4f ; o
                    dc.b $43 ; c
                    dc.b $54 ; t
                    dc.b $4f ; o
                    dc.b $52 ; r
                    dc.b $20 ; _
                    dc.b $43 ; c
                    dc.b $52 ; r
                    dc.b $45 ; e
                    dc.b $45 ; e
                    dc.b $d0 ; P                    ; EndOfLine = Bit 7 set
                    
                    dc.b $34                        ; StartPos  : PosX = 34
                    dc.b $80                        ; StartPos  : PosY = 80
                    dc.b YELLOW                     ; ColorNo   :
                    dc.b $21                        ; Format    : 21 = normal/normal size
                    dc.b $42 ; b                    ; Text      : (max 20 chr) = by ed hobbS
                    dc.b $59 ; y
                    dc.b $20 ; _
                    dc.b $45 ; e
                    dc.b $44 ; d
                    dc.b $20 ; _
                    dc.b $48 ; h
                    dc.b $4f ; o
                    dc.b $42 ; b
                    dc.b $42 ; b
                    dc.b $d3 ; S                    ; EndOfLine = Bit 7 set
                    
                    dc.b $10                        ; StartPos  : PosX = 10
                    dc.b $c0                        ; StartPos  : PosY = c0
                    dc.b GREY                       ; ColorNo   :
                    dc.b $21                        ; Format    : 21 = normal/normal size
                    dc.b $42 ; b                    ; Text      : (max 20 chr) = br0derbund  softwarE
                    dc.b $52 ; r
                    dc.b $30 ; 0
                    dc.b $44 ; d
                    dc.b $45 ; e
                    dc.b $52 ; r
                    dc.b $42 ; b
                    dc.b $55 ; u
                    dc.b $4e ; n
                    dc.b $44 ; d
                    dc.b $20 ; _
                    dc.b $20 ; _
                    dc.b $53 ; s
                    dc.b $4f ; o
                    dc.b $46 ; f
                    dc.b $54 ; t
                    dc.b $57 ; w
                    dc.b $41 ; a
                    dc.b $52 ; r
                    dc.b $c5 ; E                    ; EndOfLine = Bit 7 set
                    
                    dc.b $00                        ; EndOfText
                    
                    dc.b $00                        ; EndOfData
                    dc.b $00
; ------------------------------------------------------------------------------------------------------------- ;
TabSelectABit       = *                             ; BIT test / set single bits
Bit_oooo_ooo1       dc.b $01                        ; bit 0
Bit_oooo_oo1o       dc.b $02                        ; bit 1
Bit_oooo_o1oo       dc.b $04                        ; bit 2
Bit_oooo_1ooo       dc.b $08                        ; bit 3
Bit_ooo1_oooo       dc.b $10                        ; bit 4
Bit_oo1o_oooo       dc.b $20                        ; bit 5
Bit_o1oo_oooo       dc.b $40                        ; bit 6
Bit_1ooo_oooo       dc.b $80                        ; bit 7
 ------------------------------------------------------------------------------------------------------------- ;
TabMapP_TextGridCol = *
TabMapP1TextGridCol dc.b CC_Player1MapTxtGridCol
TabMapP2TextGridCol dc.b CC_Player2MapTxtGridCol
                    
TabMapP_TextPtr     = *                    
TabMapP1TextPtr     dc.w TextOneUp
TabMapP2TextPtr     dc.w TextTwoUp
                    
TabMapDoorNSWallOff dc.b $ff
                    dc.b $02
                    dc.b $ff
                    dc.b $fb
                    
TabMapDoorEWWallOff dc.b $f6
                    dc.b $fe
                    dc.b $06
                    dc.b $fe
                    
TabMapArrowNo       dc.b NoSprArrDo                 ; sprite: Arrow: Up
                    dc.b NoSprArrLe                 ; sprite: Arrow: Left
                    dc.b NoSprArrUp                 ; sprite: Arrow: Up
                    dc.b NoSprArrRi                 ; sprite: Arrow: Right
; ------------------------------------------------------------------------------------------------------------- ;
TabEscapeAction     = *
TabEscapeActionOne  = * - TabEscapeAction           ; action form 1: enter/stop/wave/leave
TabEscapeActionTime dc.b $80                        ; duration
TabEscapeActionType dc.b $00                        ; flag: run right
                    
                    dc.b $19                        ; duration
                    dc.b $02                        ; flag: wave
                    
                    dc.b $2d                        ; duration
                    dc.b $00                        ; flag: run right
                    
                    dc.b $00                        ; duration 00 - end type 1
                    dc.b $00
                    
TabEscapeActionTwo  = * - TabEscapeAction           ; action form 1: enter/stop/wave/leave
                    dc.b $ac                        ; duration - action type 2: enter/leave/reenter/wave/leave
                    dc.b $00                        ; flag: run right
                    
                    dc.b $2c                        ; duration
                    dc.b $01                        ; flag: run left
                    
                    dc.b $19                        ; duration
                    dc.b $02                        ; flag: wave goodbye
                    
                    dc.b $2d                        ; duration
                    dc.b $00                        ; flag: run right
                    
                    dc.b $00                        ; duration 00 - end type 2
                    dc.b $00
; ------------------------------------------------------------------------------------------------------------- ;
TabGetInputCursorNo dc.b $6c ; .##.##..
                    dc.b $7b ; .####.##
                    dc.b $7e ; .######.
                    dc.b $7c ; .#####..
; ------------------------------------------------------------------------------------------------------------- ;
TabSaveTargetAdr    dc.w CC_BestTimes               ; best  times
                    dc.w CC_LevelGame               ; level data
                    dc.w CC_DemoMusic               ; music scores
; ------------------------------------------------------------------------------------------------------------- ;
TabLoadTargetAdr    dc.b >CC_BestTimes              ; best  times
                    dc.b >CC_LevelGame              ; level data
                    dc.b >CC_DemoMusic              ; music scores
; ------------------------------------------------------------------------------------------------------------- ;
TabPlayerRoomIO     = *
TabPlayerRoomOut    = *
TabIOPlayerOffX     dc.b $00                        ; posx
TabIOPlayerOffY     dc.b $00                        ; posy
TabIOPlayerSNo      dc.b NoSprPlrArrRoLe            ; sprite: Player: Room Arrived
TabIOPlayerFlag     dc.b $ff                        ; flag: a next move existing
                    
                    dc.b $01                        ; posx
                    dc.b $ff                        ; posy
                    dc.b NoSprPlrArrRo01            ; sprite: Player: Room i/o Phase 01
                    dc.b $ff                        ; flag: a next move existing
                    
                    dc.b $01                        ; posx
                    dc.b $00                        ; posy
                    dc.b NoSprPlrArrRo02            ; sprite: Player: Room i/o Phase 02
                    dc.b $ff                        ; flag: a next move existing
                    
                    dc.b $01                        ; posx
                    dc.b $ff                        ; posy
                    dc.b NoSprPlrArrRo03            ; sprite: Player: Room i/o Phase 03
                    dc.b $ff                        ; flag: a next move existing
                    
                    dc.b $01                        ; posx
                    dc.b $00                        ; posy
                    dc.b NoSprPlrArrRo04            ; sprite: Player: Room i/o Phase 04
                    dc.b $ff                        ; flag: a next move existing
                    
                    dc.b $01                        ; posx
                    dc.b $ff                        ; posy
                    dc.b NoSprPlrArrRo05            ; sprite: Player: Room i/o Phase 05
                    dc.b $01                        ; flag: no next move existing
                    
TabPlayerRoomIn     dc.b $00                        ; posx
                    dc.b $00                        ; posy
                    dc.b NoSprPlrArrRo05            ; sprite: Player: Room i/o Phase 05
                    dc.b $ff                        ; flag: a next move existing
                    
                    dc.b $ff                        ; posx
                    dc.b $01                        ; posy
                    dc.b NoSprPlrArrRo04            ; sprite: Player: Room i/o Phase 04
                    dc.b $ff                        ; flag: a next move existing
                    
                    dc.b $ff                        ; posx
                    dc.b $00                        ; posy
                    dc.b NoSprPlrArrRo03            ; sprite: Player: Room i/o Phase 03
                    dc.b $ff                        ; flag: a next move existing
                    
                    dc.b $ff                        ; posx
                    dc.b $01                        ; posy
                    dc.b NoSprPlrArrRo02            ; sprite: Player: Room i/o Phase 02
                    dc.b $ff                        ; flag: a next move existing
                    
                    dc.b $ff                        ; posx
                    dc.b $00                        ; posy
                    dc.b NoSprPlrArrRo01            ; sprite: Player: Room i/o Phase 01
                    dc.b $ff                        ; flag: a next move existing
                    
                    dc.b $ff                        ; posx
                    dc.b $01                        ; posy
TabIPlayerRoomLR    dc.b NoSprPlrArrRoLe            ; sprite: Player: Room Arrived Left Side
                    dc.b $00                        ; flag: no next move existing
                    
TabMoveAddColOff    dc.b $00                        ; MoveU   +0
                    dc.b $01                        ; MoveUR  +1
                    dc.b $01                        ; MoveR   +1
                    dc.b $01                        ; MoveDR  +1
                    dc.b $00                        ; MoveD   +0
                    dc.b $ff                        ; MoveDL  -1
                    dc.b $ff                        ; MoveL   -1
                    dc.b $ff                        ; MoveUL  -1
                    
TabMoveAddRowOff    dc.b $fe                        ; MoveU   -2
                    dc.b $fe                        ; MoveUR  -2
                    dc.b $00                        ; MoveR   +0
                    dc.b $02                        ; MoveDR  +2
                    dc.b $02                        ; MoveD   +2
                    dc.b $02                        ; MoveDL  +2
                    dc.b $00                        ; MoveL   -0
                    dc.b $fe                        ; MoveUL  -2
                    
TabAdrCiaTimers     dc.w TODTEN                     ; CIA1: $DC08 - Time of Day Clock start
                    dc.w TO2TEN                     ; CIA2: $DD08 - Time of Day Clock start
                    
TabAdrLvlPlayTimes  dc.w CCL_Player1Times           ; game time player 1
                    dc.w CCL_Player2Times           ; game time player 2
; ------------------------------------------------------------------------------------------------------------- ;
TabRoomDoorType     dc.b NoObjDoorNormal            ; object: Door Normal
                    dc.b NoObjDoorExit              ; object: Door Exit
; ------------------------------------------------------------------------------------------------------------- ;
TabMummyOutSpriteNo dc.b NoSprMumMovOu01            ; sprite: Mummy - Out Of Wall Pase 01
                    dc.b NoSprMumMovOu02            ; sprite: Mummy - Out Of Wall Pase 02
                    dc.b NoSprMumMovOu03            ; sprite: Mummy - Out Of Wall Pase 03
                    dc.b NoSprMumMovOu04            ; sprite: Mummy - Out Of Wall Pase 04
                    dc.b NoSprMumMovOu05            ; sprite: Mummy - Out Of Wall Pase 05
                    dc.b NoSprMumMovOu06            ; sprite: Mummy - Out Of Wall Pase 06
                    dc.b NoSprMumMovOu06            ; sprite: Mummy - Out Of Wall Pase 06
                    dc.b $ff                        ; EndOfMove
                    
TabMummyOutColOff   dc.b $00
                    dc.b $fe
                    dc.b $fe
                    dc.b $fe
                    dc.b $fe
                    dc.b $fe
                    dc.b $fe
                    dc.b $00
                    
TabMummyOutRowOff   dc.b $00
                    dc.b $00
                    dc.b $00
                    dc.b $02
                    dc.b $02
                    dc.b $02
                    dc.b $02
                    dc.b $00
; ------------------------------------------------------------------------------------------------------------- ;
TabForcePingHight   dc.b $3a                        ; ping height
                    dc.b $39
                    dc.b $37
                    dc.b $35
                    dc.b $33
                    dc.b $32
                    dc.b $30
                    dc.b $2e
; ------------------------------------------------------------------------------------------------------------- ;
TabGunObjNo         dc.b NoObjGunMovRi04            ; object: Ray Gun - Shoot Right Phase 04
                    dc.b NoObjGunMovRi01            ; object: Ray Gun - Shoot Right Phase 01
                    dc.b NoObjGunMovRi02            ; object: Ray Gun - Shoot Right Phase 02
                    dc.b NoObjGunMovRi03            ; object: Ray Gun - Shoot Right Phase 03
                    
                    dc.b NoObjGunMovLe04            ; object: Ray Gun - Shoot Left  Phase 04
                    dc.b NoObjGunMovLe01            ; object: Ray Gun - Shoot Left  Phase 01
                    dc.b NoObjGunMovLe02            ; object: Ray Gun - Shoot Left  Phase 02
                    dc.b NoObjGunMovLe03            ; object: Ray Gun - Shoot Left  Phase 03
; ------------------------------------------------------------------------------------------------------------- ;
TabCopySpriteFiller dc.b $00, $00, $00              ; sprite filler row up to $14 (20)
; ------------------------------------------------------------------------------------------------------------- ;
                                                    ; rldu
TabJoyDir           dc.b $80                        ; ....
                    dc.b $80                        ; ...#
                    dc.b $80                        ; ..#.
                    dc.b $80                        ; ..##
                    dc.b $80                        ; .#..
                    dc.b $03                        ; .#.#  - right + down
                    dc.b $01                        ; .##.  - right + up
                    dc.b $02                        ; .###  - right
                    dc.b $80                        ; #...
                    dc.b $05                        ; #..#  - left  + down
                    dc.b $07                        ; #.#.  - left  + up
                    dc.b $06                        ; #.##  - left
                    dc.b $80                        ; ##..
                    dc.b $04                        ; ##.#  - down
                    dc.b $00                        ; ###.  - up
                    dc.b $80                        ; ####
; ------------------------------------------------------------------------------------------------------------- ;
TabTimeDigitData    dc.b $fc ; ######..             ; offset $00
                    dc.b $cc ; ##..##..
                    dc.b $cc ; ##..##..
                    dc.b $cc ; ##..##..
                    dc.b $cc ; ##..##..
                    dc.b $cc ; ##..##..
                    dc.b $fc ; ######..
                    dc.b $00 ; ........
                    
                    dc.b $30 ; ..##....             ; offset $08
                    dc.b $30 ; ..##....
                    dc.b $30 ; ..##....
                    dc.b $30 ; ..##....
                    dc.b $30 ; ..##....
                    dc.b $30 ; ..##....
                    dc.b $30 ; ..##....
                    dc.b $00 ; ........
                    
                    dc.b $fc ; ######..             ; offset $10
                    dc.b $0c ; ....##..
                    dc.b $0c ; ....##..
                    dc.b $fc ; ######..
                    dc.b $c0 ; ##......
                    dc.b $c0 ; ##......
                    dc.b $fc ; ######..
                    dc.b $00 ; ........
                    
                    dc.b $fc ; ######..             ; offset $18
                    dc.b $0c ; ....##..
                    dc.b $0c ; ....##..
                    dc.b $fc ; ######..
                    dc.b $0c ; ....##..
                    dc.b $0c ; ....##..
                    dc.b $fc ; ######..
                    dc.b $00 ; ........
                    
                    dc.b $cc ; ##..##..             ; offset $20
                    dc.b $cc ; ##..##..
                    dc.b $cc ; ##..##..
                    dc.b $fc ; ######..
                    dc.b $0c ; ....##..
                    dc.b $0c ; ....##..
                    dc.b $0c ; ....##..
                    dc.b $00 ; ........
                    
                    dc.b $fc ; ######..             ; offset $28
                    dc.b $c0 ; ##......
                    dc.b $c0 ; ##......
                    dc.b $fc ; ######..
                    dc.b $0c ; ....##..
                    dc.b $0c ; ....##..
                    dc.b $fc ; ######..
                    dc.b $00 ; ........
                    
                    dc.b $c0 ; ##......             ; offset $30
                    dc.b $c0 ; ##......
                    dc.b $c0 ; ##......
                    dc.b $fc ; ######..
                    dc.b $cc ; ##..##..
                    dc.b $cc ; ##..##..
                    dc.b $fc ; ######..
                    dc.b $00 ; ........
                    
                    dc.b $fc ; ######..             ; offset $38
                    dc.b $0c ; ....##..
                    dc.b $0c ; ....##..
                    dc.b $0c ; ....##..
                    dc.b $0c ; ....##..
                    dc.b $0c ; ....##..
                    dc.b $0c ; ....##..
                    dc.b $00 ; ........
                    
                    dc.b $fc ; ######..             ; offset $40
                    dc.b $cc ; ##..##..
                    dc.b $cc ; ##..##..
                    dc.b $fc ; ######..
                    dc.b $cc ; ##..##..
                    dc.b $cc ; ##..##..
                    dc.b $fc ; ######..
                    dc.b $00 ; ........
                    
                    dc.b $fc ; ######..             ; offset $48
                    dc.b $cc ; ##..##..
                    dc.b $cc ; ##..##..
                    dc.b $fc ; ######..
                    dc.b $0c ; ....##..
                    dc.b $0c ; ....##..
                    dc.b $0c ; ....##..
                    dc.b $00 ; ........
; ------------------------------------------------------------------------------------------------------------- ;
TabRomCharSet       dc.w CHR_UP                     ; character rom: upper case
                    dc.w CHR_UPR                    ; character rom: upper case / reversed
                    dc.w CHR_LO                     ; character rom: lower case
                    dc.w CHR_LOR                    ; character rom: lower case / reversed

TabTransChr2BitMap  dc.b $00 ; ........  - 00
                    dc.b $01 ; .......#  - 01
                    dc.b $04 ; .....#..  - 02
                    dc.b $05 ; .....#.#  - 03
                    
                    dc.b $10 ; ...#....  - 04
                    dc.b $11 ; ...#...#  - 05
                    dc.b $14 ; ...#.#..  - 06
                    dc.b $15 ; ...#.#.#  - 07
                    
                    dc.b $40 ; .#......  - 08
                    dc.b $41 ; .#.....#  - 09
                    dc.b $44 ; .#...#..  - 0a
                    dc.b $45 ; .#...#.#  - 0b
                    
                    dc.b $50 ; .#.#....  - 0c
                    dc.b $51 ; .#.#...#  - 0d
                    dc.b $54 ; .#.#.#..  - 0e
                    dc.b $55 ; .#.#.#.#  - 0f
; ------------------------------------------------------------------------------------------------------------- ;
TabKeyMatrix        = *                             ; key matrix values - $80 not allowed in game
KeyMatrixColBit0    dc.b $08 ; good: DELETE
                    dc.b $0d ; good: RETURN
                    dc.b $08 ; good: CRSR_R - mapped to DELETE
                    dc.b $80 ; bad : F7
                    dc.b $80 ; bad : F1
                    dc.b $80 ; bad : F3
                    dc.b $80 ; bad : F5
                    dc.b $80 ; bad : CRSR_D
                    
KeyMatrixColBit1    dc.b $33 ; good: 3
                    dc.b $57 ; good: W
                    dc.b $41 ; good: A
                    dc.b $34 ; good: 4
                    dc.b $5a ; good: Z
                    dc.b $53 ; good: S
                    dc.b $45 ; good: E
                    dc.b $80 ; bad : LSHIFT
                     
KeyMatrixColBit2    dc.b $35 ; good: 5 
                    dc.b $52 ; good: R
                    dc.b $44 ; good: D
                    dc.b $36 ; good: 6
                    dc.b $43 ; good: C
                    dc.b $46 ; good: F
                    dc.b $54 ; good: T
                    dc.b $58 ; good: X
                    
KeyMatrixColBit3    dc.b $37 ; good: 7
                    dc.b $59 ; good: Y
                    dc.b $47 ; good: G
                    dc.b $38 ; good: 8
                    dc.b $42 ; good: B
                    dc.b $48 ; good: H
                    dc.b $55 ; good: U
                    dc.b $56 ; good: V
                    
KeyMatrixColBit4    dc.b $39 ; good: 9
                    dc.b $49 ; good: I
                    dc.b $4a ; good: J
                    dc.b $30 ; good: 0
                    dc.b $4d ; good: M
                    dc.b $4b ; good: K
                    dc.b $4f ; good: O
                    dc.b $4e ; good: N
                     
KeyMatrixColBit5    dc.b $2b ; good: +
                    dc.b $50 ; good: P
                    dc.b $4c ; good: L
                    dc.b $2d ; good: -
                    dc.b $2e ; good: .
                    dc.b $3a ; good: :
                    dc.b $40 ; good: @
                    dc.b $2c ; good: ,
                    
KeyMatrixColBit6    dc.b $80 ; bad : LIRA
                    dc.b $2a ; good: *
                    dc.b $3b ; good: ;
                    dc.b $80 ; bad : HOME
                    dc.b $80 ; bad : RSHIFT
                    dc.b $3d ; good: =
                    dc.b $80 ; bad : ^
                    dc.b $2f ; good: /
                    
KeyMatrixColBit7    dc.b $31 ; good: 1
                    dc.b $08 ; good: <- 
                    dc.b $80 ; bad : CTRL
                    dc.b $32 ; good: 2
                    dc.b $20 ; good: SPACE
                    dc.b $80 ; bad : C=
                    dc.b $51 ; good: Q
                    dc.b $80 ; bad : STOP
; ------------------------------------------------------------------------------------------------------------- ;
TabCtrlScrRowsLo    dc.b $00                        ; control screen row offsets low with high=00
                    dc.b $28
                    dc.b $50
                    dc.b $78
                    dc.b $a0
                    dc.b $c8
                    dc.b $f0
                    
                    dc.b $18                        ; control screen row offsets low with high=01
                    dc.b $40
                    dc.b $68
                    dc.b $90
                    dc.b $b8
                    dc.b $e0
                    
                    dc.b $08                        ; control screen row offsets low with high=02
                    dc.b $30
                    dc.b $58
                    dc.b $80
                    dc.b $a8
                    dc.b $d0
                    dc.b $f8
                    
                    dc.b $20                        ; control screen row offsets low with high=03
                    dc.b $48
                    dc.b $70
                    dc.b $98
                    dc.b $c0
                    dc.b $e8
                    
                    dc.b $10                        ; control screen row offsets low with high=04
                    dc.b $38
                    dc.b $60
                    dc.b $88
                    dc.b $b0
                    dc.b $d8
                    
TabCtrlScrRowsHi    dc.b $00                        ; control screen row offsets high
                    dc.b $00
                    dc.b $00
                    dc.b $00
                    dc.b $00
                    dc.b $00
                    dc.b $00
                    
                    dc.b $01
                    dc.b $01
                    dc.b $01
                    dc.b $01
                    dc.b $01
                    dc.b $01
                    
                    dc.b $02
                    dc.b $02
                    dc.b $02
                    dc.b $02
                    dc.b $02
                    dc.b $02
                    dc.b $02
                    
                    dc.b $03
                    dc.b $03
                    dc.b $03
                    dc.b $03
                    dc.b $03
                    dc.b $03
                    
                    dc.b $04
                    dc.b $04
                    dc.b $04
                    dc.b $04
                    dc.b $04
                    dc.b $04
; ------------------------------------------------------------------------------------------------------------- ;
TabDemoMusicFile    dc.b $4d ; m                    ; demo music file name
                    dc.b $55 ; u
                    dc.b $53 ; s
                    dc.b $49 ; i
                    dc.b $43 ; c
TabDemoMusicFileNo  dc.b $2f ; 0 - 1                ; start with music0 the very first time
; ------------------------------------------------------------------------------------------------------------- ;
