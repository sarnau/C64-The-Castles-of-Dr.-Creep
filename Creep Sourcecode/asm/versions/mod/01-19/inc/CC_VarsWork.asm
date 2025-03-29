; ------------------------------------------------------------------------------------------------------------- ;
; Castles of Dr Creep - Working
; ------------------------------------------------------------------------------------------------------------- ;
CC_WorkVariables        = $0200                   ; $0200 - $0258 - basic line input buffer

CCW_RndSeed01           = CC_WorkVariables  + $00 ; 
CCW_RndSeed02           = CC_WorkVariables  + $01 ; 
CCW_RndSeed03           = CC_WorkVariables  + $02 ; 
CCW_CountDynWait        = CC_WorkVariables  + $03 ; 
CCW_CountIRQs           = CC_WorkVariables  + $04 ; 
CCW_CountIRQsMap          = $01                   ; 
CCW_CountIRQsGame         = $02                   ; 
CCW_CountIRQsInput        = $03                   ; 
CCW_CountActnHdlrCalls  = CC_WorkVariables  + $05 ; counter action handler accesses
CCW_JoyGotDir           = CC_WorkVariables  + $06 ; 
CCW_JoyGotFire          = CC_WorkVariables  + $07 ; 
CCW_JoySavFire          = CC_WorkVariables  + $08 ; 
CCW_JoyPortNo           = CC_WorkVariables  + $09 ; 
CCW_KeyGotStop          = CC_WorkVariables  + $0a ; stop key pressed  1=pressed
CCW_KeyGotRestore       = CC_WorkVariables  + $0b ; 
CCW_KeyGotNo              = $00                   ; 
CCW_KeyGotYes             = $01                   ; 
CCW_KeyMatrixPosGot     = CC_WorkVariables  + $0c ; 
CCW_KeyMatrixPosSav     = CC_WorkVariables  + $0d ; 
CCW_KeyMatrixTabPos     = CC_WorkVariables  + $0e ; 
CCW_KeyMatrixRowBit     = CC_WorkVariables  + $0f ; 
CCW_KeyMatrixRowMask    = CC_WorkVariables  + $10 ; 
CCW_KeyMatrixColMask    = CC_WorkVariables  + $11 ; 
CCW_RasterColorNo       = CC_WorkVariables  + $12 ; 
CCW_RasterColorMax      = CC_WorkVariables  + $13 ; 
CCW_RasterOff             = $00                   ; no in game raster coloring
CCW_RasterOn_Exit         = $06                   ; switch on raster coloring on castle escape
CCW_RasterColorSav      = CC_WorkVariables  + $14 ; save old background color
CCW_GetInputGridCol     = CC_WorkVariables  + $15 ; input text room column grid number
CCW_GetInputGridRow     = CC_WorkVariables  + $16 ; input text room row    grid number
CCW_GetInputColor       = CC_WorkVariables  + $17 ; input text color
CCW_GetInputTxtType     = CC_WorkVariables  + $18 ; input text hight
CCW_GetInputLen         = CC_WorkVariables  + $19 ; actual  input length
CCW_GetInputLenMax      = CC_WorkVariables  + $1a ; maximum input length
CCW_GetInputCursor      = CC_WorkVariables  + $1b ; 
CCW_GetInputCursorInit    = "-"                   ; place holder char
CCW_GetInputCursorNo    = CC_WorkVariables  + $1c ; actual cursor number
CCW_DemoShowTitle       = CC_WorkVariables  + $1d ; 
CCW_DemoShowTitleInit     = $00                   ; 
CCW_DemoShowTitleMax      = $03                   ; 
CCW_DemoFlag            = CC_WorkVariables  + $1e ; 
CCW_DemoYes               = $01
CCW_DemoNo                = $00
CCW_DemoJoyFire         = CC_WorkVariables  + $1f ; 
CCW_DemoRoomNo          = CC_WorkVariables  + $20 ; 
CCW_DemoRoomInit          = $ff                   ; first start
CCW_DemoRoomStart         = $00                   ; reinit
CCW_DemoTitleTime       = CC_WorkVariables  + $21 ; 
CCW_DemoTitleTimeInit     = $40                   ; show title screen time
CCW_DemoMusicFileNoInit   = "0"                   ; 
CCW_DemoMusicFileLen      = $06                   ; 
CCW_DemoNextSong        = CC_WorkVariables  + $22 ; next time load another demo music
CCW_Tune2PlayCtrlCut2   = CC_WorkVariables  + $23 ; 
CCW_Tune2PlayCtrlCut3   = CC_WorkVariables  + $24 ; 
CCW_Tune2PlayDemo       = CC_WorkVariables  + $25 ; 
CCW_Tune2PlayDemoNo       = $00                   ; 
CCW_Tune2PlayDemoYes      = $01                   ; 
CCW_Tune2PlayTime       = CC_WorkVariables  + $26 ; 
CCW_Tune2PlayTimeInit     = $14                   ; 
CCW_InitSfxNo           = CC_WorkVariables  + $27 ; 
CCW_InitSfxNoWrk        = CC_WorkVariables  + $28 ; 
CCW_InitSfxNoInit         = $ff                   ; 
;CCW_MapP1Enters         = CC_WorkVariables  + $29 ; 
;CCW_MapP2Enters         = CC_WorkVariables  + $2a ; 
;CCW_MapEnterNo            = $01                   ; 
;CCW_MapEnterYes           = $00                   ; 
CCW_MapBlinkTime        = CC_WorkVariables  + $2b ; 
CCW_MapPlayerCount      = CC_WorkVariables  + $2c ; 
CCW_MapPlayerNo         = CC_WorkVariables  + $2d ; 
CCW_MapSpriteNo         = CC_WorkVariables  + $2e ; 
CCW_MapDoorWallId       = CC_WorkVariables  + $2f ; 
CCW_MapRoomCount        = CC_WorkVariables  + $30 ; 
CCW_MapRoomGridCol      = CC_WorkVariables  + $31 ; 
CCW_MapRoomGridRow      = CC_WorkVariables  + $32 ; 
CCW_MapRoomCols         = CC_WorkVariables  + $33 ; 
CCW_MapRoomColsWrk      = CC_WorkVariables  + $34 ; 
CCW_MapRoomRows         = CC_WorkVariables  + $35 ; 
CCW_MapRoomRowsWrk      = CC_WorkVariables  + $36 ; 
CCW_DiskAccess          = CC_WorkVariables  + $37 ; $01=resumed successfully
CCW_DiskAccessOk          = $01                   ; 
CCW_DiskAccessBad         = $00                   ; 
CCW_DiskStatusCC        = CC_WorkVariables  + $38 ; disk status
CCW_DiskActionId        = CC_WorkVariables  + $39 ; 
CCW_DiskActionSave        = $00                   ; 
CCW_DiskActionResume      = $01                   ; 
CCW_GetSpriteDataNo     = CC_WorkVariables  + $3a ; 
CCW_CopySpriteNo        = CC_WorkVariables  + $3b ; 
;CCW_CopySpriteRows      = CC_WorkVariables  + $3c ; 
;CCW_CopySpriteCols      = CC_WorkVariables  + $3d ; 
CCW_SpriteSpriteColl    = CC_WorkVariables  + $3c ; 
CCW_SpriteBackGrColl    = CC_WorkVariables  + $3d ; 
CCW_SpriteWAOffMov      = CC_WorkVariables  + $3e ; moving sprite
CCW_SpriteWAOffHit      = CC_WorkVariables  + $3f ; touched sprite
CCW_SpriteCol           = CC_WorkVariables  + $40 ; 
CCW_SpriteColMax        = CC_WorkVariables  + $41 ; 
CCW_SpriteRow           = CC_WorkVariables  + $42 ; 
CCW_SpriteRowMax        = CC_WorkVariables  + $43 ; 
CCW_SpriteCollPrio      = CC_WorkVariables  + $44 ; 
CCW_SpriteWAOff         = CC_WorkVariables  + $45 ; 
CCW_SpriteVitality      = CC_WorkVariables  + $46 ; 
CCW_SpriteAlive           = $01                   ; 
CCW_SpriteDead            = $00                   ; 
CCW_ObjWAUseCount       = CC_WorkVariables  + $47 ; max $20 entries a $08 bytes in object work area
CCW_ObjWAOffFree        = CC_WorkVariables  + $48 ; 
CCW_ObjWAOffHit         = CC_WorkVariables  + $49 ; offset status work area block to handle
CCW_ObjSpriteCol        = CC_WorkVariables  + $4a ; 
CCW_ObjSpriteColMax     = CC_WorkVariables  + $4b ; columns + posx
CCW_ObjSpriteRow        = CC_WorkVariables  + $4c ; 
CCW_ObjSpriteRowMax     = CC_WorkVariables  + $4d ; rows    + posy
CCW_ObjSpriteCollide    = CC_WorkVariables  + $4e ; 
CCW_ObjCollideYes         = $00                   ; 
CCW_ObjCollideNo          = $01                   ; 
CCW_RunIntoRoomP_No     = CC_WorkVariables  + $4f ; 
CCW_TimeConvertValue    = CC_WorkVariables  + $50 ; 
CCW_TimeConvertColor    = CC_WorkVariables  + $51 ; 
CCW_TimeConvertId       = CC_WorkVariables  + $52 ; 
CCW_TimeConvertIdLeft     = $00                   ; 
CCW_TimeConvertIdRight    = $01                   ; 
CCW_TimeConvertIdMax      = $02                   ; 
CCW_BestTimeDataPtrLo   = CC_WorkVariables  + $53 ; 
CCW_BestTimeDataPtrHi   = CC_WorkVariables  + $54 ; 
CCW_BestTimeEntryNo     = CC_WorkVariables  + $55 ; 
CCW_BestTimeEntryLen    = CC_WorkVariables  + $56 ; 
CCW_BestTimePlayerNo    = CC_WorkVariables  + $57 ; 
;CCW_Free                = CC_WorkVariables  + $58 ; 
; ------------------------------------------------------------------------------------------------------------- ;
C64_Sys200_Start        = CC_WorkVariables  + $59 ; start - Kernal/Keyboard Buffers/Flags
C64_Sys200_End          = CC_WorkVariables  + $a6 ; end   - Kernal/Keyboard Buffers/Flags
; ------------------------------------------------------------------------------------------------------------- ;
CCW_AutoMovWALenCopy    = CC_WorkVariables  + $a7 ; 
CCW_AutoMovWALen        = CC_WorkVariables  + $a8 ; 
CCW_RoomP1Enters        = CC_WorkVariables  + $a9 ; 
CCW_RoomP2Enters        = CC_WorkVariables  + $aa ; 
CCW_RoomP_Enters          = CCW_RoomP1Enters      ; 
CCW_RoomEnterNo           = $00                   ; 
CCW_RoomEnterYes          = $01                   ; 
CCW_DoorCount           = CC_WorkVariables  + $ab ; 
CCW_DoorCountWrk        = CC_WorkVariables  + $ac ; 
CCW_DoorDataPtrLo       = CC_WorkVariables  + $ad ; 
CCW_DoorDataPtrHi       = CC_WorkVariables  + $ae ; 
CCW_DoorOffTypWA        = CC_WorkVariables  + $af ; 
CCW_DoorTargRoomNo      = CC_WorkVariables  + $b0 ; 
CCW_DoorTargDoorNo      = CC_WorkVariables  + $b1 ; 
CCW_RoomTargDoorCount   = CC_WorkVariables  + $b2 ; 
CCW_FloorIdx            = CC_WorkVariables  + $b3 ; indicator start=$01 mid end=CCW_FloorLen
CCW_FloorStart            = $01                   ; 
CCW_FloorLen            = CC_WorkVariables  + $b4 ; 
CCW_FloorLenWrk         = CC_WorkVariables  + $b5 ; 
CCW_PoleLen             = CC_WorkVariables  + $b6 ; 
CCW_LadderLen           = CC_WorkVariables  + $b7 ; 
CCW_BellCount           = CC_WorkVariables  + $b8 ; 
CCW_BellOffTypWA        = CC_WorkVariables  + $b9 ; 
CCW_LightPoleLen        = CC_WorkVariables  + $ba ; 
CCW_LightPolePhase      = CC_WorkVariables  + $bb ; 
CCW_LightPolePhaseMin     = $00                   ; 
CCW_LightPolePhaseMax     = $03                   ; 
CCW_LightPolePhaseLen   = CC_WorkVariables  + $bc ; 
CCW_LightBallNo         = CC_WorkVariables  + $bd ; 
CCW_LightSwtchDataPtrLo = CC_WorkVariables  + $be ; 
CCW_LightSwtchDataPtrHi = CC_WorkVariables  + $bf ; 
CCW_LightSwtchBallNo    = CC_WorkVariables  + $c0 ; 
CCW_LightSwtchBallList  = CC_WorkVariables  + $c1 ; 
CCW_LightSwtchOffTypeWA = CC_WorkVariables  + $c2 ; 
CCW_LightSwtchOffSprtWA = CC_WorkVariables  + $c3 ; 
CCW_ForceNo             = CC_WorkVariables  + $c4 ; 
CCW_MummyWallStatus     = CC_WorkVariables  + $c5 ; 
CCW_MummyWallIn           = $00                   ; 
CCW_MummyWallOut          = $ff                   ; 
CCW_MummyOffSprtWA      = CC_WorkVariables  + $c6 ; 
CCW_MummyOffTypeWA      = CC_WorkVariables  + $c7 ; 
CCW_MummyOffKillWA      = CC_WorkVariables  + $c8 ; 
CCW_MummyOutWallRows    = CC_WorkVariables  + $c9 ; 
CCW_MummyDataPtrLo      = CC_WorkVariables  + $ca ; 
CCW_MummyDataPtrHi      = CC_WorkVariables  + $cb ; 
CCW_MummyDataNext       = CC_WorkVariables  + $cc ; 
CCW_MummyWallRows       = CC_WorkVariables  + $cd ; 
CCW_MummyWallRowsMax      = $03                   ; 
CCW_MummyWallCols       = CC_WorkVariables  + $ce ; 
CCW_MummyWallColsMax      = $05                   ; 
CCW_KeyDataNext         = CC_WorkVariables  + $cf ; 
CCW_KeyDataPtrLo        = CC_WorkVariables  + $d0 ; 
CCW_KeyDataPtrHi        = CC_WorkVariables  + $d1 ; 
CCW_KeyOffTypWA         = CC_WorkVariables  + $d2 ; 
CCW_KeyListAmount       = CC_WorkVariables  + $d3 ; 
CCW_KeyPickedNo         = CC_WorkVariables  + $d4 ; 
CCW_LockOffTypWA        = CC_WorkVariables  + $d5 ; 
CCW_DrawObjCount        = CC_WorkVariables  + $d6 ; 
CCW_GunDataPtrLo        = CC_WorkVariables  + $d7 ; 
CCW_GunDataPtrHi        = CC_WorkVariables  + $d8 ; 
CCW_GunDataNext         = CC_WorkVariables  + $d9 ; 
CCW_GunPoleLen          = CC_WorkVariables  + $da ; 
CCW_GunMoveDir          = CC_WorkVariables  + $db ; 
CCW_GunTargPlayerNo     = CC_WorkVariables  + $dc ; 
CCW_GunOffTypWA         = CC_WorkVariables  + $dd ; 
CCW_GunSwitchColor      = CC_WorkVariables  + $de ; 
CCW_XmitBoothColor      = CC_WorkVariables  + $df ; 
CCW_XmitBoothColorBack  = CC_WorkVariables  + $e0 ; 
CCW_XmitBoothFloorLen   = CC_WorkVariables  + $e1 ; 
CCW_XmitBoothFloorMax     = $03                   ; 
CCW_XmitReceiveColor    = CC_WorkVariables  + $e2 ; 
CCW_XmitOffTypWA        = CC_WorkVariables  + $e3 ; 
CCW_TrapDataPtrLo       = CC_WorkVariables  + $e4 ; 
CCW_TrapDataPtrHi       = CC_WorkVariables  + $e5 ; 
CCW_TrapDataModPtrLo    = CC_WorkVariables  + $e6 ; 
CCW_TrapDataModPtrHi    = CC_WorkVariables  + $e7 ; 
CCW_TrapCtrlDataLo      = CC_WorkVariables  + $e8 ; 
CCW_TrapCtrlDataHi      = CC_WorkVariables  + $e9 ; 
CCW_TrapDataNext        = CC_WorkVariables  + $ea ; 
CCW_TrapOffTypWA        = CC_WorkVariables  + $eb ; 
CCW_WalkDataPtrLo       = CC_WorkVariables  + $ec ; 
CCW_WalkDataPtrHi       = CC_WorkVariables  + $ed ; 
CCW_WalkSpritePacing    = CC_WorkVariables  + $ee ; 
CCW_WalkDataNext        = CC_WorkVariables  + $ef ; 
CCW_WalkOffTypWA        = CC_WorkVariables  + $f0 ; 
CCW_FrankDataPtrLo      = CC_WorkVariables  + $f1 ; 
CCW_FrankDataPtrHi      = CC_WorkVariables  + $f2 ; 
CCW_FrankDataNext       = CC_WorkVariables  + $f3 ; 
CCW_FrankCoffinDir      = CC_WorkVariables  + $f4 ; 
CCW_MoveFrankP_No       = CC_WorkVariables  + $f5 ; 
CCW_MovFrankMoveOk      = CC_WorkVariables  + $f6 ; 
CCW_MovFrankMoveYes       = $01                   ; 
CCW_MovFrankMoveNo        = $00                   ; 
CCW_MovFrankDir         = CC_WorkVariables  + $f7 ; 
CCW_MovFrankP_Pos       = CC_WorkVariables  + $f8 ; 
CCW_MovFrankP_PosSav    = CC_WorkVariables  + $f9 ; 
CCW_MovFrankP_PosPtr    = CC_WorkVariables  + $fa ; 
CCW_MovFrankCtrlVal     = CC_WorkVariables  + $fb ; 
CCW_EscapePlayerNo      = CC_WorkVariables  + $fc ; 
CCW_EscapeActionType    = CC_WorkVariables  + $fd ; 
CCW_EscapeActionTime    = CC_WorkVariables  + $fe ; 
CCW_EscapeActionForm    = CC_WorkVariables  + $ff ; escape action form one or two
; ------------------------------------------------------------------------------------------------------------- ;
CC_WorkBuffers          = $0300                   ; 

C64_Sys300_Start        = CC_WorkBuffers    + $00 ; start - Basic/Kernal Vectors/Register Save
C64_Sys300_End          = CC_WorkBuffers    + $33 ; end   - Basic/Kernal Vectors/Register Save
; ------------------------------------------------------------------------------------------------------------- ;
CCW_SpriteWAOffP1       = CC_WorkBuffers    + $34 ; player 1 WA
CCW_SpriteWAOffP2       = CC_WorkBuffers    + $35 ; player 2 WA
CCW_LoadCtrlDynAreaCol  = CC_WorkBuffers    + $36 ; 
CCW_LoadCtrlDynAreaRow  = CC_WorkBuffers    + $37 ; 
CCW_LoadCtrlTabOffWrk   = CC_WorkBuffers    + $38 ; actual screen control table offset
CCW_LoadCtrlTabOff      = CC_WorkBuffers    + $39 ; 
CCW_LoadCtrlTabOffMax   = CC_WorkBuffers    + $3a ; 
CCW_LoadCtrlUnlimLives  = CC_WorkBuffers    + $3b ; 
CCW_LoadCtrlLivesOnOff    = $ff                   ; 
CCW_LoadCtrlDataFilePos = CC_WorkBuffers    + $3c ; 
CCW_CtrlScrnRowNo       = CC_WorkBuffers    + $3d ; 
CCW_CtrlScrnColNo       = CC_WorkBuffers    + $3e ; 
CCW_CtrlScrnColB0_1     = CC_WorkBuffers    + $3f ; 
CCW_CtrlScrnColB0_2     = CC_WorkBuffers    + $40 ; 
CCW_CtrlScrRowsLo       = CC_WorkBuffers    + $41 ; 
CCW_CtrlScrRowsHi       = CC_WorkBuffers    + $42 ; 
CCW_CtrlScrnVal         = CC_WorkBuffers    + $43 ; 
CCW_CtrlScrnValBelow    = CC_WorkBuffers    + $44 ; 
CCW_GameOver            = CC_WorkBuffers    + $45 ; 
CCW_GameOverNo            = $00                   ; 
CCW_GameOverYes           = $01                   ; 
CCW_Temp                = CC_WorkBuffers    + $46 ; .hbu010. - store temp work values
; ------------------------------------------------------------------------------------------------------------- ;
;                                                 ; $47-$c9 - free
; ------------------------------------------------------------------------------------------------------------- ;
CCW_ForceStatusTab      = CC_WorkBuffers    + $ca ; max $06 force fields in a room
CCW_ForceOpen             = $00                   ; 
CCW_ForceClosed           = $01                   ; 
;                       = CC_WorkBuffers    + $cb ; 
;                       = CC_WorkBuffers    + $cc ; 
;                       = CC_WorkBuffers    + $cd ; 
;                       = CC_WorkBuffers    + $ce ; 
;                       = CC_WorkBuffers    + $cf ; 
; ------------------------------------------------------------------------------------------------------------- ;
CCW_MovFrankP_PosTab    = CC_WorkBuffers    + $d0 ; 
;CCW_MovFrankPosBelow   = CC_WorkBuffers    + $d0 ; set if Frank is below    Player - $00 gives $00=up
;CCW_MovFrankPosLeft    = CC_WorkBuffers    + $d1 ; set if Frank is left  of Player - $01 gives $02=right
;CCW_MovFrankPosAbove   = CC_WorkBuffers    + $d2 ; set if Frank is above    Player - $02 gives $04=down
;CCW_MovFrankPosRight   = CC_WorkBuffers    + $d3 ; set if Frank is right of Player - $03 gives $06=left
; ------------------------------------------------------------------------------------------------------------- ;
CCW_CompareTime         = CC_WorkBuffers    + $d4 ; best times comparison values
;                       = CC_WorkBuffers    + $d5 ; 
;                       = CC_WorkBuffers    + $d6 ; 
;                       = CC_WorkBuffers    + $d7 ; 
CCW_GameP1TimeSav       = CC_WorkBuffers    + $d8 ; CIA 1 - $DC08 = Time of Day Clock: Tenths of Seconds - Player 1
;                       = CC_WorkBuffers    + $d9 ;                                    Seconds
;                       = CC_WorkBuffers    + $da ;                                    Minutes
;                       = CC_WorkBuffers    + $db ;                                    Hours
CCW_GameP2TimeSav       = CC_WorkBuffers    + $dc ; CIA 2 - $DD08 = Time of Day Clock: Tenths of Seconds - Player 2
;                       = CC_WorkBuffers    + $dd ;                                    Seconds
;                       = CC_WorkBuffers    + $de ;                                    Minutes
;                       = CC_WorkBuffers    + $df ;                                    Hours
CCW_GameP_TimeSav         = CCW_GameP1TimeSav     ; 
; ------------------------------------------------------------------------------------------------------------- ;
CCW_KeyMatrixValGot     = CC_WorkBuffers    + $e0 ; table of $03
;                       = CC_WorkBuffers    + $e1 ; 
;                       = CC_WorkBuffers    + $e2 ; 
CCW_KeyMatrixValSav     = CC_WorkBuffers    + $e3 ; table of $03
;                       = CC_WorkBuffers    + $e4 ; 
;                       = CC_WorkBuffers    + $e5 ; 
; ------------------------------------------------------------------------------------------------------------- ;
CCW_Tune2PlayCutLo      = CC_WorkBuffers    + $e6 ; table of $03
;                       = CC_WorkBuffers    + $e7 ; 
;                       = CC_WorkBuffers    + $e8 ; 
; ------------------------------------------------------------------------------------------------------------- ;
CCW_DiskFileEndAdrLo    = CC_WorkBuffers    + $e9 ; address loaded files end of data
CCW_DiskFileEndAdrHi    = CC_WorkBuffers    + $ea ; 
CCW_DiskFileReplHdr     = CC_WorkBuffers    + $eb ; @0: - replace an existing file with same name on save
;                       = CC_WorkBuffers    + $ec ; 
;                       = CC_WorkBuffers    + $ed ; 
CCW_DiskFileReplHdrLen    = $03                   ; 
CCW_DiskFileNameId      = CC_WorkBuffers    + $ee ; 16 byte disk file name buffer
CCW_DiskFileIdDir         = "$"                   ; 
CCW_DiskFileIdSave        = "X"                   ; 
CCW_DiskFileIdTimes       = "Y"                   ; 
CCW_DiskFileIdCastle      = "Z"                   ; 
CCW_TextInputBuffer     = CC_WorkBuffers    + $ef ; input text buffer - same as file name buffer
CCW_DiskFileName        = CC_WorkBuffers    + $ef ; 
CCW_ScoreId             = CC_WorkBuffers    + $ef ; 
;                       = CC_WorkBuffers    + $f0 ; 
;                       = CC_WorkBuffers    + $f1 ; 
;                       = CC_WorkBuffers    + $f2 ; 
CCW_DiskFileMusicNo     = CC_WorkBuffers    + $f3 ; music file number
;                       = CC_WorkBuffers    + $f4 ; 
;                       = CC_WorkBuffers    + $f5 ; 
;                       = CC_WorkBuffers    + $f6 ; 
;                       = CC_WorkBuffers    + $f7 ; 
;                       = CC_WorkBuffers    + $f8 ; 
;                       = CC_WorkBuffers    + $f9 ; 
;                       = CC_WorkBuffers    + $fa ; 
;                       = CC_WorkBuffers    + $fb ; 
;                       = CC_WorkBuffers    + $fc ; 
;                       = CC_WorkBuffers    + $fd ; 
CCW_DiskFileTargetId    = CC_WorkBuffers    + $fe ; flag: $00=CC_LevelGameID $01=CC_LevelStorageID $02=CC_LevelTimesID
CCW_DiskFileNameLen     = CC_WorkBuffers    + $ff ; 
CCW_DiskFileNameLenMax    = $0f                   ; 
; ------------------------------------------------------------------------------------------------------------- ;
