; ------------------------------------------------------------------------------------------------------------- ;
; The Castles of Dr Creep - Loaded Data Maps
; ------------------------------------------------------------------------------------------------------------- ;
; Level Process
; ------------------------------------------------------------------------------------------------------------- ;
CC_LvlGame       = $7800              ; $7800 actual level data for play
CC_LvlGameID       = $00              ;   game start address flag for data loader
CC_LvlGameData     = $100             ; start of room definitions
CC_LvlStor       = CC_LvlGame + $2000 ; $9800 loaded level data for restart
CC_LvlStorID       = $01              ;   store start address flag for data loader
CC_LvlStorData     = $100             ; start of room definitions
CC_LvlTimes      = CC_LvlGame + $4000 ; $b800 loaded best times
CC_LvlTimesID      = $02              ;   best time start address flag for data loader
;
CC_DmoMusic      = CC_LvlGame         ; start address of the different demo music pieces
CC_DmoMusicLastP = CC_DmoMusic + $00  ; no of bytes in last page
CC_DmoMusicPages = CC_DmoMusic + $01  ; no of pages
CC_DmoMusicStart = CC_DmoMusic + $02  ; 
; ------------------------------------------------------------------------------------------------------------- ;
CC_LvlLastPGame  = CC_LvlGame + $00   ; no of bytes in last page  counter start: 1)
CC_LvlPagesGame  = CC_LvlGame + $01   ; no of pages  max: 20      data must fit into 7800 - 97ff)
CC_LvlLastPSave  = CC_LvlStor + $00   ; no of bytes in last page  counter starts: 1)
CC_LvlPagesSave  = CC_LvlStor + $01   ; no of pages  max: 20      data must fit into 7800 - 97ff)
; ------------------------------------------------------------------------------------------------------------- ;
; Players Start
; ------------------------------------------------------------------------------------------------------------- ;
CC_LvlP_StrtRoom = CC_LvlGame + $03   ; players start room number
CC_LvlP1StrtRoom = CC_LvlGame + $03   ; count start: entry 00 of ROOM list
CC_LvlP2StrtRoom = CC_LvlGame + $04   ; count start: entry 00 of ROOM list
CC_LvlP_StrtDoor = CC_LvlGame + $05   ; players start door number in start room
CC_LvlP1StrtDoor = CC_LvlGame + $05   ; count start: entry 00 of Room DOOR list
CC_LvlP2StrtDoor = CC_LvlGame + $06   ; count start: entry 00 of Room DOOR list
; ------------------------------------------------------------------------------------------------------------- ;
; Players Target
; ------------------------------------------------------------------------------------------------------------- ;
CC_LvlP_TargRoom = CC_LvlGame + $09   ; players target room number
CC_LvlP1TargRoom = CC_LvlGame + $09   ; count start: entry 00 of ROOM list
CC_LvlP2TargRoom = CC_LvlGame + $0a   ; count start: entry 00 of ROOM list
CC_LvlP_TargDoor = CC_LvlGame + $0b   ; players target door number in target room
CC_LvlP1TargDoor = CC_LvlGame + $0b   ; count start: entry 00 of Room DOOR list
CC_LvlP2TargDoor = CC_LvlGame + $0c   ; count start: entry 00 of Room DOOR list
; ------------------------------------------------------------------------------------------------------------- ;
; Players Life
; ------------------------------------------------------------------------------------------------------------- ;
CC_LvlP_NumLives = CC_LvlGame + $07   ; number of lives left - 00=dead
CC_LvlP1NumLives = CC_LvlGame + $07   ; player1
CC_LvlP2NumLives = CC_LvlGame + $08   ; player2
CC_LvlP_Status   = CC_LvlGame + $0d   ; in game action status
CC_LvlP1Status   = CC_LvlGame + $0d   ; player 1
CC_LvlP2Status   = CC_LvlGame + $0e   ; player 2
CC_LVLP_Survive    = $00              ; survived room action
CC_LVLP_Accident   = $02              ; something really bad happened in the room
CC_LVLP_Inactive   = $04              ; coward did not take part
CC_LVLP_IORoom     = $05              ; ongoing enter
CC_LVLP_IOStart    = $06              ; start entering a room through an open door
CC_LvlP_Health   = CC_LvlGame + $0f   ; health flag - 00=dead  01=alive
CC_LvlP1Health   = CC_LvlGame + $0f   ; player 1
CC_LvlP2Health   = CC_LvlGame + $10   ; player 2
CC_LVLP_Dead       = $00              ; 
CC_LVLP_Alive      = $01              ; 
CC_LvlP_Active   = CC_LvlGame + $11   ; player pressed fire at start of the game for one/two player action
CC_LvlP1Active   = CC_LvlGame + $11   ; player 1
CC_LvlP2Active   = CC_LvlGame + $12   ; player 2
CC_LVLP_Out        = $00              ; 
CC_LVLP_In         = $01              ; 
; ------------------------------------------------------------------------------------------------------------- ;
CC_LvlP_Times    = CC_LvlGame + $55   ; players castle escape times
CC_LvlP1Times    = CC_LvlGame + $55   ; 
CC_LvlP1TimMil   = CC_LvlGame + $55   ; milliseconds
CC_LvlP1TimSec   = CC_LvlGame + $56   ; seconds
CC_LvlP1TimMin   = CC_LvlGame + $57   ; minutes
CC_LvlP1TimHrs   = CC_LvlGame + $58   ; hours
CC_LvlP2Times    = CC_LvlGame + $59   ; 
CC_LvlP2TimMil   = CC_LvlGame + $59   ; milliseconds
CC_LvlP2TimSec   = CC_LvlGame + $5a   ; seconds
CC_LvlP2TimMin   = CC_LvlGame + $5b   ; minutes
CC_LvlP2TimHrs   = CC_LvlGame + $5c   ; hours
; ------------------------------------------------------------------------------------------------------------- ;
; Players Collected Keys
; ------------------------------------------------------------------------------------------------------------- ;
CC_LvlP1KeyAmnt  = CC_LvlGame + $13   ; count start: 01
CC_LvlP2KeyAmnt  = CC_LvlGame + $14   ; count start: 01
CC_LvlP1KeyColct = CC_LvlGame + $15   ; 7 entries - stored unsorted as they were collected
CC_LvlP2KeyColct = CC_LvlGame + $35   ; 7 entries - stored unsorted as they were collected
; ------------------------------------------------------------------------------------------------------------- ;
; Players Position
; ------------------------------------------------------------------------------------------------------------- ;
CC_LvlP1AtDoor   = CC_LvlGame + $5d   ; Player 1 in front of door
CC_LvlP2AtDoor   = CC_LvlGame + $5e   ; Player 2 in front of door
; ------------------------------------------------------------------------------------------------------------- ;
; Escape Picture
; ------------------------------------------------------------------------------------------------------------- ;
CC_LvlXPicFlag   = CC_LvlGame + $02   ; Bit 7=1: Show Escape picture
CC_LvlXPicYes      = $80 
CC_LvlXPicPtrLo  = CC_LvlGame + $5f   ; Escape picture ID Pointer Low : points to (36/08) entry in level data
CC_LvlXPicPtrHi  = CC_LvlGame + $60   ; Escape picture ID Pointer High: points to (36/08) entry in level data
; ------------------------------------------------------------------------------------------------------------- ;
; Best Times Mapping
; ------------------------------------------------------------------------------------------------------------- ;
CC_BestTimes     = CC_LvlTimes
CC_EoBestTimes     = $ff                                                      ; End of Data marker
CC_BestEntryMax    = $0a                                                      ; max entries per 1/2 players game
CC_BestEntryLen    = $06                                                      ; 
CC_BestLenHdr    = $02                                                        ; header length
CC_BestLenHi     = CC_BestTimes + $00                                         ; for kernal SAVE routine
CC_BestLenUsedHi   = CC_BestLenHdr + (CC_BestEntryLen * CC_BestEntryMax * 2)  ;   $7a = offset EndOfBestTimesData
CC_BestLenLo     = CC_BestTimes + $01                                         ; for kernal SAVE routine
CC_BestLenUsedLo   = $00
;
CC_BestPlayers   = CC_BestTimes + CC_BestLenHdr                               ; times player 1 and player 2
;
CC_BestOneID     = CC_BestTimes + $02  ; 3 chr players initials
CC_BestOneTimeLo = CC_BestOneID + $03  ; bcd time values from timer A
CC_BestOneTimeMi = CC_BestOneID + $04  ; 
CC_BestOneTimeHi = CC_BestOneID + $05  ; 
;
CC_BestTwoID     = CC_BestOneID + (CC_BestEntryMax * CC_BestEntryLen)
CC_BestTwoTimeLo = CC_BestTwoID + $03  ; bcd time values from timer B
CC_BestTwoTimeMi = CC_BestTwoID + $04  ; 
CC_BestTwoTimeHi = CC_BestTwoID + $05  ; 
; ------------------------------------------------------------------------------------------------------------- ;
