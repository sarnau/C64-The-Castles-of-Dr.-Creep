; ------------------------------------------------------------------------------------------------------------- ;
; The Castles of Dr Creep - Best Times
; ------------------------------------------------------------------------------------------------------------- ;
; Best Times Mapping
; ------------------------------------------------------------------------------------------------------------- ;
CC_BestTimes     = CC_LvlTimes
CC_EoBestTimes     = $ff
CC_BestEntryMax    = $0a                                              ; maximum number of entries per 1/2 players game
CC_BestEntryLen    = $06
CC_BestLenHi     = CC_BestTimes + $00                                 ; for kernal SAVE routine
CC_BestLenUsedHi   = $02 + (CC_BestEntryLen * CC_BestEntryMax * 2)    ; $7a = offset EndOfBestTimesData
CC_BestLenLo     = CC_BestTimes + $01                                 ; for kernal SAVE routine
CC_BestLenUsedLo   = $00
;
CC_BestOneID     = CC_BestTimes + $02                                 ; 3 chr players initials
CC_BestOneTimeLo = CC_BestOneID + $03                                 ; bcd time values
CC_BestOneTimeMi = CC_BestOneID + $04                                 ; 
CC_BestOneTimeHi = CC_BestOneID + $05                                 ; 
;
CC_BestTwoID     = CC_BestOneID + (CC_BestEntryMax * CC_BestEntryLen)
CC_BestTwoTimeLo = CC_BestTwoID + $03                                 ; 
CC_BestTwoTimeMi = CC_BestTwoID + $04                                 ; 
CC_BestTwoTimeHi = CC_BestTwoID + $05                                 ; 
; ------------------------------------------------------------------------------------------------------------- ;
