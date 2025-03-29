; ------------------------------------------------------------------------------------------------------------- ;
; Castles of Dr Creep - In game variables
; ------------------------------------------------------------------------------------------------------------- ;
CC_ScreenBankIdText       = VIC_MemBank_0 ; $0000-$3fff - CIA2 -> CI2PRA
CC_ScreenBankIdMap        = VIC_MemBank_2 ; $8000-$bfff - CIA2 -> CI2PRA
CC_ScreenBankIdRoom       = VIC_MemBank_3 ; $c000-$ffff - CIA2 -> CI2PRA

CC_ScreenBankText       = $0000           ; start address vic map  memory bank
CC_ScreenBankMap        = $8000           ; start address vic map  memory bank
CC_ScreenBankRoom       = $c000           ; start address vic room memory bank
CC_ScreenBankDiff       = CC_ScreenBankRoom - CC_ScreenBankMap ; 
CC_VIC_ScreenText         = $14           ; ...# - Bits 4-7: Screen base address: 1=$0400-$07e7 + VIC_MemBank start
                                          ; .#.o - Bits 2-3: Char   base address: 2=$1000-$17ff + VIC_MemBank start
CC_VIC_ScreensGfx         = $38           ; ..## - Bits 4-7: Screen base address: 3=$0c00-$0fe7 + CC_ScreenBankId
                                          ; #..o - Bits 2-3: Bitmap base address: 4=$2000-$27ff + CC_ScreenBankId
; ------------------------------------------------------------------------------------------------------------- ;
; Storage locations
; ------------------------------------------------------------------------------------------------------------- ;
CC_ScreenText           = CC_ScreenBankText     + $0400   ; game options and castle load data
CC_ScreenMapColor       = CC_ScreenBankMap      + $0c00   ; screen ram for object type 0 colors
CC_ScreenMapGfx         = CC_ScreenBankMap      + $2000   ; hires maps display screen
CC_ScreenRoomColor      = CC_ScreenBankRoom     + $0c00   ; screen ram for object type 0 colors
CC_ScreenRoomGfx        = CC_ScreenBankRoom     + $2000   ; hires rooms display screen

CC_BestTimes            = $6400                           ; best times storage                                  - .hbu013.
CC_BestTimesID            = $00                           ; flag: load data to best times storage target
CC_ScreenLoadCtrl       = $6500                           ; row control data for options and castle load screen - .hbu013.
CC_TabHiResRowLo        = $6600                           ; pointer hires screen row low                        - .hbu013.
CC_TabHiResRowHi        = $6700                           ; pointer hires screen row high                       - .hbu013.
CC_LevelGame            = $6800 ; - $87ff                 ; level data
CC_LevelGameID            = $01                           ; flag: load data to level storage target
CC_LevelGameVars        = CC_LevelGame                    ; start of game variable data
CC_LevelGameData        = CC_LevelGame          + $0100   ; start of game room data
CC_SpriteDataMap        = $8800 ; - $8bff                 ; map arrow sprites data
CC_ObjectData           = $9000                           ; start address object data
CC_WorkAreasStart       = $9d00 ; - $9fff                 ; 3 consecutive pages                                 - .hbu013.
CC_DemoMusic            = $a000                           ; start address demo music data
CC_LevelMusicID           = $02                           ; flag: load data to music storage target

CC_ScreenMoveCtrl       = $c000 ; - $c7ff                 ; Players move control screen
CC_SpriteDataRoom       = $c800 ; - $cbff                 ; game sprites data

CC_SpritePtrMapBase     = CC_ScreenBankMap                ; base address sprite pointer storage
CC_SpritePtrMap00       = CC_SpritePtrMapBase   + $0ff8   ; 2 arrows only
CC_SpritePtrMap01       = CC_SpritePtrMapBase   + $0ff9   ; 

CC_SpritePtrRoomBase    = CC_ScreenBankRoom               ; base address sprite pointer storage
CC_SpritePtrRoom00      = CC_SpritePtrRoomBase  + $0ff8   ; 
CC_SpritePtrRoom01      = CC_SpritePtrRoomBase  + $0ff9   ; 
CC_SpritePtrRoom02      = CC_SpritePtrRoomBase  + $0ffa   ; 
CC_SpritePtrRoom03      = CC_SpritePtrRoomBase  + $0ffb   ; 
CC_SpritePtrRoom04      = CC_SpritePtrRoomBase  + $0ffc   ; 
CC_SpritePtrRoom05      = CC_SpritePtrRoomBase  + $0ffd   ; 
CC_SpritePtrRoom06      = CC_SpritePtrRoomBase  + $0ffe   ; 
CC_SpritePtrRoom07      = CC_SpritePtrRoomBase  + $0fff   ; 
; ------------------------------------------------------------------------------------------------------------- ;
; Misc
; ------------------------------------------------------------------------------------------------------------- ;
CC_GridWidth            = $04                             ; 
CC_GridHeight           = $08                             ; 
CC_GridColOff           = $10                             ; offset first column position

CC_MultiColor0Player1   = YELLOW                          ; player 1/2 multicolor 0
CC_MultiColor0Player2   = ORANGE                          ; player 1/2 multicolor 0
CC_MultiColor1Players   = LT_RED                          ; player 1/2 multicolor 0
CC_MultiColor2Players   = LT_GREEN                        ; player 1/2 multicolor 1

CC_ColorLivesLostAll    = LT_GREY                         ; .hbu016. - colors depending on lives count
CC_ColorLivesLastOne    = LT_RED                          ; 
CC_ColorLivesLostOne    = PURPLE                          ; .hbu016.
CC_ColorLivesLostNone   = LT_GREEN                        ; 

CC_ArrowBlinkTime       = $10                             ; 

CC_PlayersMapRow        = $02                             ; row 3
CC_Player1MapCol        = $00                             ; column 1
CC_Player2MapCol        = $19                             ; column 26
CC_PlayersMapTxtGridRow = CC_PlayersMapRow * CC_GridHeight                ; anchor row map statistik player 1/2
CC_Player1MapTxtGridCol = CC_Player1MapCol * CC_GridWidth + CC_GridColOff ; anchor col map statistik player 1
CC_Player2MapTxtGridCol = CC_Player2MapCol * CC_GridWidth + CC_GridColOff ; anchor col map statistik player 2
; ------------------------------------------------------------------------------------------------------------- ;
; Row Control Data for Options / Castle Load Screen
; ------------------------------------------------------------------------------------------------------------- ;
CC_LoadCtrlArea         = CC_ScreenLoadCtrl + $00         ; starting point load control work blocks
CC_LoadCtrlEntryLen       = $04                           ; length of each load control work block entry

CC_LoadCtrlCol          = CC_LoadCtrlArea   + $00         ; start point in CC_LoadCtrlRow
CC_LoadCtrlRowFixMin      = $00 ; $03                     ; default start row of output area - .hbu020.
CC_LoadCtrlColAreaLe      = $03                           ; default start column of left  output area
CC_LoadCtrlColAreaHdr     = $05                           ; default start column of info  output area
CC_LoadCtrlColAreaRi      = $16                           ; default start column of right output area
CC_LoadCtrlRow          = CC_LoadCtrlArea   + $01         ; screen row number
CC_LoadCtrlRowDynMin      = ScreenLineGame  + $02         ; start row of file name area after fix area
CC_LoadCtrlRowDynMax      = $18                           ; end   row of file name area at bottom of screen
CC_LoadCtrlId           = CC_LoadCtrlArea   + $02         ; entry type id
CC_LoadCtrlIdLives        = $00                           ; lives on/off
CC_LoadCtrlIdExit         = $01                           ; exit menu
CC_LoadCtrlIdFile         = $02                           ; dynamic castle data file entry
;CC_LoadCtrlIdResume       = $03                           ; resume a saved game
CC_LoadCtrlIdTimes        = $04                           ; view high scores
CC_LoadCtrlNoFixItems     = $03 ; $04                     ; count fix load item work blocks pointing to first file work block no - .hbu020.
CC_LoadCtrlFiNamLen     = CC_LoadCtrlArea   + $03         ; entry length for type CC_LoadCtrlIdFile name
CC_LoadCtrlFiMaxLen       = $0f                           ; max len CC_LoadCtrlIdFile name

CC_LoadCtrlPosInit      = $00 ; $02                       ; block number of the initial entry - .hbu020.
CC_LoadCtrlCrsrCol      = CC_LoadCtrlArea + CC_LoadCtrlPosInit * CC_LoadCtrlEntryLen ; initial cursor pos
CC_LoadCtrlCrsrRow      = CC_LoadCtrlCrsrCol + $01                                   ; initial cursor pos
; ------------------------------------------------------------------------------------------------------------- ;
; Screen data for Control Screen - pointer in ($3c/$3d)
; ------------------------------------------------------------------------------------------------------------- ;
CC_CtrlFloorStrt        = $04 ; .....#..                  ; floor: start  tile
CC_CtrlFloorMid         = $44 ; .#...#..                  ; floor: middle tile consist of both: start and end
CC_CtrlFloorEnd         = $40 ; .#......                  ; floor: end    tile
CC_CtrlPole             = $10 ; ...#....                  ; pole : has no bot tile
CC_CtrlLadderBot        = $01 ; .......#                  ; ladder: bottom - mid consists of both: bot and top
CC_CtrlLadderTop        = $10 ; ...#....                  ; ladder: top    - mid consist  of both: bot and top
CC_CtrlTrapLeft         = $fb ; #####.##                  ; trap open: start          - resets floor to CC_CtrlFloorEnd
CC_CtrlTrapRight        = $bf ; #.######                  ; trap open: end            - resets floor to CC_CtrlFloorStrt
CC_CtrlFrankLeft        = $fb ; #####.##                  ; frank coffin: Left        - resets floor to CC_CtrlFloorEnd
CC_CtrlFrankRight       = $bf ; #.######                  ; frank coffin: Right       - resets floor to CC_CtrlFloorStrt
CC_CtrlForceLeft        = $fb ; #####.##                  ; force field closed: start - resets floor to CC_CtrlFloorEnd
CC_CtrlForceRight       = $bf ; #.######                  ; force field closed: end   - resets floor to CC_CtrlFloorStrt
; ------------------------------------------------------------------------------------------------------------- ;
