; ------------------------------------------------------------------------------------------------------------- ;
; Castles of Dr Creep - Level Variables / Music Variables / Best Times Mapping
; ------------------------------------------------------------------------------------------------------------- ;
; Level Data Length
; ------------------------------------------------------------------------------------------------------------- ;
CCL_GameLastPageBytes   = CC_LevelGame     + $00     ; no of bytes in last page  counter start: 1)
CCL_GameNumPages        = CC_LevelGame     + $01     ; no of pages  max: 20      data must fit into 7800 - 97ff)
; ------------------------------------------------------------------------------------------------------------- ;
; Escape Picture
; ------------------------------------------------------------------------------------------------------------- ;
CCL_Flag                = CC_LevelGameVars + $02    ; game flag byte
CCL_Game                  = $01                     ; Bit 0=1: Ongoing Game
CCL_ShowXitPicture        = $80                     ; Bit 7=1: Show Escape picture
CCL_XitPicDataPtrLo     = CC_LevelGameVars + $5f    ; Escape picture ID Pointer Low : points to (36/08) entry in level data
CCL_XitPicDataPtrHi     = CC_LevelGameVars + $60    ; Escape picture ID Pointer High: points to (36/08) entry in level data
; ------------------------------------------------------------------------------------------------------------- ;
; Players Start
; ------------------------------------------------------------------------------------------------------------- ;
CCL_PlayersStartRoomNo  = CC_LevelGameVars + $03    ; players start room number
CCL_Player1StartRoomNo  = CC_LevelGameVars + $03    ; count start: entry 00 of ROOM list
CCL_Player2StartRoomNo  = CC_LevelGameVars + $04    ; count start: entry 00 of ROOM list

CCL_PlayersStartDoorNo  = CC_LevelGameVars + $05    ; players start door number in start room
CCL_Player1StartDoorNo  = CC_LevelGameVars + $05    ; count start: entry 00 of Room DOOR list
CCL_Player2StartDoorNo  = CC_LevelGameVars + $06    ; count start: entry 00 of Room DOOR list
; ------------------------------------------------------------------------------------------------------------- ;
; Players Target
; ------------------------------------------------------------------------------------------------------------- ;
CCL_PlayersTargetRoomNo = CC_LevelGameVars + $07    ; players target room number
CCL_Player1TargetRoomNo = CC_LevelGameVars + $07    ; count start: entry 00 of ROOM list
CCL_Player2TargetRoomNo = CC_LevelGameVars + $08    ; count start: entry 00 of ROOM list

CCL_PlayersTargetDoorNo = CC_LevelGameVars + $09    ; players target door number in target room
CCL_Player1TargetDoorNo = CC_LevelGameVars + $09    ; count start: entry 00 of Room DOOR list
CCL_Player2TargetDoorNo = CC_LevelGameVars + $0a    ; count start: entry 00 of Room DOOR list
; ------------------------------------------------------------------------------------------------------------- ;
; Players Position
; ------------------------------------------------------------------------------------------------------------- ;
CCL_PlayersAtDoor       = CC_LevelGameVars + $0b    ; Players door position
CCL_Player1AtDoor       = CC_LevelGameVars + $0b    ; Player 1 in front of door
CCL_Player2AtDoor       = CC_LevelGameVars + $0c    ; Player 2 in front of door
; ------------------------------------------------------------------------------------------------------------- ;
; Players Life
; ------------------------------------------------------------------------------------------------------------- ;
CCL_PlayersNumLives     = CC_LevelGameVars + $0d    ; number of lives left - 00=dead
CCL_PlayersLivesMin       = $00                     ; 
CCL_PlayersLivesMax       = $03                     ; 
CCL_Player1NumLives     = CC_LevelGameVars + $0d    ; player1
CCL_Player2NumLives     = CC_LevelGameVars + $0e    ; player2
; ------------------------------------------------------------------------------------------------------------- ;
; Players Status
; ------------------------------------------------------------------------------------------------------------- ;
CCL_PlayersStatus       = CC_LevelGameVars + $0f    ; in game action status
CCL_Player1Status       = CC_LevelGameVars + $0f    ; player 1
CCL_Player2Status       = CC_LevelGameVars + $10    ; player 2
CCL_PlayerSurvive         = $00                     ; survived room action
CCL_PlayerAccident        = $02                     ; something really bad happened in the room
CCL_PlayerInactive        = $04                     ; coward did not take part
CCL_PlayerRoomInOut       = $05                     ; ongoing enter
CCL_PlayerRoomInOutInit   = $06                     ; start entering a room through an open door
CCL_PlayersHealth       = CC_LevelGameVars + $11    ; health flag - 00=dead  01=alive
CCL_Player1Health       = CC_LevelGameVars + $11    ; player 1
CCL_Player2Health       = CC_LevelGameVars + $12    ; player 2
CCL_Dead                  = $00                     ; 
CCL_Alive                 = $01                     ; 
CCL_PlayersActive       = CC_LevelGameVars + $13    ; player pressed fire at start of the game for one/two player action
CCL_Player1Active       = CC_LevelGameVars + $13    ; player 1
CCL_Player2Active       = CC_LevelGameVars + $14    ; player 2
CCL_Out                   = $00                     ; 
CCL_In                    = $01                     ; 
; ------------------------------------------------------------------------------------------------------------- ;
; Players Collected Keys
; ------------------------------------------------------------------------------------------------------------- ;
CCL_PlayersKeysAmount   = CC_LevelGameVars + $15    ; 
CCL_Player1KeysAmount   = CC_LevelGameVars + $15    ; count start: 00
CCL_Player2KeysAmount   = CC_LevelGameVars + $16    ; count start: 00

CCL_PlayersKeysCollect  = CC_LevelGameVars + $17    ; - $1d - $24
CCL_Player1KeysCollect  = CC_LevelGameVars + $17    ; - $1d - 7 entries - stored unsorted as they were collected
CCL_Player2KeysCollect  = CC_LevelGameVars + $1e    ; - $24 - 7 entries - stored unsorted as they were collected
CCL_PlayersKeyListLen     = CCL_Player2KeysCollect - CCL_Player1KeysCollect ; 
; ------------------------------------------------------------------------------------------------------------- ;
; Players Times
; ------------------------------------------------------------------------------------------------------------- ;
CCL_PlayersTimes        = CC_LevelGameVars + $25    ; players castle escape times
CCL_PlayersTimesLen       = $03                     ; player level time entry length
CCL_Player1Times        = CC_LevelGameVars + $25    ; 
CCL_Player1TimesMil     = CC_LevelGameVars + $25    ; milliseconds
CCL_Player1TimesSec     = CC_LevelGameVars + $26    ; seconds
CCL_Player1TimesMin     = CC_LevelGameVars + $27    ; minutes
CCL_Player1TimesHrs     = CC_LevelGameVars + $28    ; hours

CCL_Player2Times        = CC_LevelGameVars + $29    ; 
CCL_Player2TimesMil     = CC_LevelGameVars + $29    ; milliseconds
CCL_Player2TimesSec     = CC_LevelGameVars + $2a    ; seconds
CCL_Player2TimesMin     = CC_LevelGameVars + $2b    ; minutes
CCL_Player2TimesHrs     = CC_LevelGameVars + $2c    ; hours
; ------------------------------------------------------------------------------------------------------------- ;
; Players Save 
; ------------------------------------------------------------------------------------------------------------- ;
CCL_PlayersSaveRoomNo   = CC_LevelGameVars + $30    ; .hbu017. - players target room number
CCL_Player1SaveRoomNo   = CC_LevelGameVars + $30    ; .hbu017.
CCL_Player2SaveRoomNo   = CC_LevelGameVars + $31    ; .hbu017.

CCL_PlayersSaveDoorNo   = CC_LevelGameVars + $32    ; .hbu017. - players target door number in target room
CCL_Player1SaveDoorNo   = CC_LevelGameVars + $32    ; .hbu017.
CCL_Player2SaveDoorNo   = CC_LevelGameVars + $33    ; .hbu017.

CCL_PlayersSaveKeyAmnt  = CC_LevelGameVars + $34    ; .hbu017. - players amount of collected keys
CCL_Player1SaveKeyAmnt  = CC_LevelGameVars + $34    ; .hbu017.
CCL_Player2SaveKeyAmnt  = CC_LevelGameVars + $35    ; .hbu017.
; ------------------------------------------------------------------------------------------------------------- ;
; Demo Music Data - Loaded to Game Level Data
; ------------------------------------------------------------------------------------------------------------- ;
CCL_MusicLastPageBytes  = CC_DemoMusic     + $00    ; no of bytes in last page
CCL_MusicNumPages       = CC_DemoMusic     + $01    ; no of pages
CCL_MusicDataStart      = CC_DemoMusic     + $02    ; start address of the music score data
; ------------------------------------------------------------------------------------------------------------- ;
; Best Times Mapping
; ------------------------------------------------------------------------------------------------------------- ;
CCH_BestTimesHdr        = CC_BestTimes              ; header
CCH_BestTimesHdrLen       = $02                     ; header length
CCH_BestTimesLenLo      = CC_BestTimes     + $00    ; for kernal SAVE routine
CCH_BestTimesEoDLo        = CCH_BestTimesHdrLen + (CCH_BestTimesEntryLen * CCH_BestTimesMaxEntries * 2) ; $7a = offset EndOfBestTimesData
CCH_BestTimesLenHi      = CC_BestTimes     + $01    ; for kernal SAVE routine
CCH_BestTimesEoDHi        = $00                     ; 

CCH_BestTimesData       = CCH_BestTimesHdr + CCH_BestTimesHdrLen ; time data player 1 / player 2

CCH_BestTimesP1         = CCH_BestTimesData         ; time data player 1 / player 2
CCH_BestTimesP1Len        = CCH_BestTimesEntryLen * CCH_BestTimesMaxEntries ; 
CCH_BestTimesP1Id       = CCH_BestTimesP1  + $00    ; 3 chr players initials
CCH_BestTimesIDLen        = $03                     ; 
CCH_BestTimesPlayer1    = CCH_BestTimesP1  + $03    ; bcd time values from timer A
CCH_BestTimesP1Lo       = CCH_BestTimesP1  + $03    ; 
CCH_BestTimesP1Mi       = CCH_BestTimesP1  + $04    ; 
CCH_BestTimesP1Hi       = CCH_BestTimesP1  + $05    ; 
CCH_BestTimesTimeLen      = $03                     ; length time data

CCH_BestTimesP2         = CCH_BestTimesP1  + (CCH_BestTimesMaxEntries * CCH_BestTimesEntryLen)
CCH_BestTimesP2Len        = CCH_BestTimesEntryLen * CCH_BestTimesMaxEntries ; 
CCH_BestTimesP2ID       = CCH_BestTimesP2  + $00    ; 3 chr players initials
CCH_BestTimesPlayer2    = CCH_BestTimesP2  + $03    ; bcd time values from timer A
CCH_BestTimesP2Lo       = CCH_BestTimesP2  + $03    ; 
CCH_BestTimesP2Mi       = CCH_BestTimesP2  + $04    ; 
CCH_BestTimesP2Hi       = CCH_BestTimesP2  + $05    ; 

CCH_BestTimesMaxEntries   = $0a                     ; max entries per 1/2 players game
CCH_BestTimesEntryLen     = CCH_BestTimesIDLen + CCH_BestTimesTimeLen ; 
CCH_BestTimesEoD          = $ff                     ; End of Data marker
; ------------------------------------------------------------------------------------------------------------- ;
