; ------------------------------------------------------------------------------------------------------------- ;
; Castles of Dr Creep - Zero Page Equates
; ------------------------------------------------------------------------------------------------------------- ;
;                                                   ; $58-$82 free
;                                                   ; $96-$a1 free
;                                                   ; $a5-$ab free
;                                                   ; $bd-$bf free
;                                                   ; $c6-$ca free
;                                                   ; $cc-$dc free
; ------------------------------------------------------------------------------------------------------------- ;
CCZ_SwitchesOn            = $01                     ; 
CCZ_SwitchesOff           = $00                     ; 

CCZ_ResumeGame          = $02                       ; select hires gfx screen
CCZ_ResumeOn              = CCZ_SwitchesOn          ; select map  screen storage
CCZ_ResumeOff             = CCZ_SwitchesOff         ; select room screen storage

CCZ_RestoreColor        = $03                       ; avoid color restore the very first time
CCZ_RestoreOn             = CCZ_SwitchesOn          ; 
CCZ_RestoreOff            = CCZ_SwitchesOff         ; 

CCZ_JoyUp               = $04                       ; 
CCZ_JoyDown             = $05                       ; 
CCZ_JoyLeft             = $06                       ; 
CCZ_JoyRight            = $07                       ; 
CCZ_JoyFire             = $08                       ; 
; ------------------------------------------------------------------------------------------------------------- ;
CCZ_SpritesPosX         = $10                       ; horizontal position sprites 0-7
CCZ_Sprite00PosX        = CCZ_SpritesPosX + $00     ; VIC 2 - $D000 - horizontal position sprite 0
CCZ_Sprite01PosX        = CCZ_SpritesPosX + $01     ; VIC 2 - $D002 - horizontal position sprite 1
CCZ_Sprite02PosX        = CCZ_SpritesPosX + $02     ; VIC 2 - $D004 - horizontal position sprite 2
CCZ_Sprite03PosX        = CCZ_SpritesPosX + $03     ; VIC 2 - $D006 - horizontal position sprite 3
CCZ_Sprite04PosX        = CCZ_SpritesPosX + $04     ; VIC 2 - $D008 - horizontal position sprite 4
CCZ_Sprite05PosX        = CCZ_SpritesPosX + $05     ; VIC 2 - $D00a - horizontal position sprite 5
CCZ_Sprite06PosX        = CCZ_SpritesPosX + $06     ; VIC 2 - $D00c - horizontal position sprite 6
CCZ_Sprite07PosX        = CCZ_SpritesPosX + $07     ; VIC 2 - $D00e - horizontal position sprite 7
; ------------------------------------------------------------------------------------------------------------ ;
CCZ_SpritesPosY         = $18                       ; vertical position sprites 0-7
CCZ_Sprite00PosY        = CCZ_SpritesPosY + $00     ; VIC 2 - $D001 - vertical   position sprite 0
CCZ_Sprite01PosY        = CCZ_SpritesPosY + $01     ; VIC 2 - $D003 - vertical   position sprite 1
CCZ_Sprite02PosY        = CCZ_SpritesPosY + $02     ; VIC 2 - $D005 - vertical   position sprite 2
CCZ_Sprite03PosY        = CCZ_SpritesPosY + $03     ; VIC 2 - $D007 - vertical   position sprite 3
CCZ_Sprite04PosY        = CCZ_SpritesPosY + $04     ; VIC 2 - $D009 - vertical   position sprite 4
CCZ_Sprite05PosY        = CCZ_SpritesPosY + $05     ; VIC 2 - $D00b - vertical   position sprite 5
CCZ_Sprite06PosY        = CCZ_SpritesPosY + $06     ; VIC 2 - $D00d - vertical   position sprite 6
CCZ_Sprite07PosY        = CCZ_SpritesPosY + $07     ; VIC 2 - $D00f - vertical   position sprite 7
; ------------------------------------------------------------------------------------------------------------- ;
CCZ_SpritesMSBY         = $20                       ; VIC 2 - $D010 - vertical position sprites 0-7 MSB
CCZ_SpritesEnab         = $21                       ; VIC 2 - $D015 - enable            sprites 0-7
CCZ_VICMemCtrl          = $22                       ; VIC 2 - $D018 - chip memory control
CCZ_CIABankCtrl         = $23                       ; CIA 2 - $DD00 = data port A  
CCZ_ColorBorder         = $24                       ; VIC 2 - $D020 - border Color
CCZ_ColorBackGr         = $25                       ; VIC 2 - $D021 - background color 0
CCZ_VICModeCtrl         = $26                       ; VIC 2 - $D016 - horizontal fine scrolling and control register
; ------------------------------------------------------------------------------------------------------------- ;
CCZ_SpritesDataPtr      = $28                       ; data pointers sprites 0-7
CCZ_Sprite00DataPtr     = CCZ_SpritesDataPtr + $00  ; $cff8 - data pointer sprite 0
CCZ_Sprite01DataPtr     = CCZ_SpritesDataPtr + $01  ; $cff9 - data pointer sprite 1
CCZ_Sprite02DataPtr     = CCZ_SpritesDataPtr + $02  ; $cffa - data pointer sprite 2
CCZ_Sprite03DataPtr     = CCZ_SpritesDataPtr + $03  ; $cffb - data pointer sprite 3
CCZ_Sprite04DataPtr     = CCZ_SpritesDataPtr + $04  ; $cffc - data pointer sprite 4
CCZ_Sprite05DataPtr     = CCZ_SpritesDataPtr + $05  ; $cffd - data pointer sprite 5
CCZ_Sprite06DataPtr     = CCZ_SpritesDataPtr + $06  ; $cffe - data pointer sprite 6
CCZ_Sprite07DataPtr     = CCZ_SpritesDataPtr + $07  ; $cfff - data pointer sprite 7
; ------------------------------------------------------------------------------------------------------------- ;
; pointer
; ------------------------------------------------------------------------------------------------------------- ;
CCZ_GenHiResTabLo       = $30                       ; 
CCZ_GenHiResTabHi       = $31                       ; 

CCZ_ColorDataLenLo      = $30                       ; 
CCZ_ColorDataLenHi      = $31                       ; 
CCZ_ColorDataLenRow     = $32                       ; 

CCZ_CharObject          = $30                       ; 
CCZ_CharObjectLo        = $30                       ; 
CCZ_CharObjectHi        = $31                       ; 

CCZ_CharROM             = $30                       ; 
CCZ_CharROMLo           = $30                       ; 
CCZ_CharROMHi           = $31                       ; 

CCZ_ScreenFileNew       = $30                       ; ptr: CC_ScreenLoadFiles
CCZ_ScreenFileNewLo     = $30                       ; 
CCZ_ScreenFileNewHi     = $31                       ; 

CCZ_GetCIATime          = $30                       ; 
CCZ_GetCIATimeLo        = $30                       ; 
CCZ_GetCIATimeHi        = $31                       ; 

CCZ_GetLevelTime        = $30                       ; 
CCZ_GetLevelTimeLo      = $30                       ; 
CCZ_GetLevelTimeHi      = $31                       ; 

CCZ_BestTimes           = $30                       ; 
CCZ_BestTimesLo         = $30                       ; 
CCZ_BestTimesHi         = $31                       ; 

CCZ_LevelTime           = $30                       ; 
CCZ_LevelTimeLo         = $30                       ; 
CCZ_LevelTimeHi         = $31                       ; 

CCZ_ScreenLoad          = $30                       ; ptr: CC_ScreenLoadFiles
CCZ_ScreenLoadLo        = $30                       ; 
CCZ_ScreenLoadHi        = $31                       ; 

CCZ_DirList             = $30                       ; ptr: dir list of 'z*' file names at $9800
CCZ_DirListLo           = $30                       ; 
CCZ_DirListHi           = $31                       ; 

CCZ_KeyCollection       = $30                       ; ptr: list of collected key
CCZ_KeyCollectionLo     = $30                       ; 
CCZ_KeyCollectionHi     = $31                       ; 

CCZ_ColorRam            = $30                       ; 
CCZ_ColorRamLo          = $30                       ; 
CCZ_ColorRamHi          = $31                       ; 

CCZ_ColorHiRes          = $30                       ; 
CCZ_ColorHiResLo        = $30                       ; 
CCZ_ColorHiResHi        = $31                       ; 

CCZ_SavGameData         = $30                       ; 
CCZ_SavGameDataLo       = $30                       ; 
CCZ_SavGameDataHi       = $31                       ; 

CCZ_MoveCtrl            = $30                       ; 
CCZ_MoveCtrlLo          = $30                       ; 
CCZ_MoveCtrlHi          = $31                       ; 

CCZ_ScreenHiRes         = $30                       ; 
CCZ_ScreenHiResLo       = $30                       ; 
CCZ_ScreenHiResHi       = $31                       ; 

CCZ_SpriteCol           = $30                       ; selected sprite column position
CCZ_SpriteColLo         = $30                       ; 
CCZ_SpriteColHi         = $31                       ; 

CCZ_SpriteData          = $30                       ; selected sprite data
CCZ_SpriteDataLo        = $30                       ; 
CCZ_SpriteDataHi        = $31                       ; 

CCZ_ObjDataTyp12        = $30                       ; selected object data type 1 or type 2
CCZ_ObjDataTyp12Lo      = $30                       ; 
CCZ_ObjDataTyp12Hi      = $31                       ; 
; ------------------------------------------------------------------------------------------------------------- ;
CCZ_PutCIATime          = $32                       ; 
CCZ_PutCIATimeLo        = $32                       ; 
CCZ_PutCIATimeHi        = $33                       ; 

CCZ_PutLevelTime        = $32                       ; 
CCZ_PutLevelTimeLo      = $32                       ; 
CCZ_PutLevelTimeHi      = $33                       ; 

CCZ_ScreenFileOld       = $32                       ; ptr: CC_ScreenLoadFiles
CCZ_ScreenFileOldLo     = $32                       ; 
CCZ_ScreenFileOldHi     = $33                       ; 

CCZ_SpriteStore         = $32                       ; selected sprite data target storage
CCZ_SpriteStoreLo       = $32                       ; 
CCZ_SpriteStoreHi       = $33                       ; 

CCZ_ObjDataTyp0         = $32                       ; selected object data type 0
CCZ_ObjDataTyp0Lo       = $32                       ; 
CCZ_ObjDataTyp0Hi       = $33                       ; 
; ------------------------------------------------------------------------------------------------------------- ;
CCZ_ScreenLoadDyn       = $32                       ; ptr: variable area of castle data file names
CCZ_ScreenLoadDynLo     = $32                       ; 
CCZ_ScreenLoadDynHi     = $33                       ; 
; ------------------------------------------------------------------------------------------------------------- ;
CCZ_ObjHiResRow         = $34                       ; 
CCZ_ObjHiResRowLo       = $34                       ; 
CCZ_ObjHiResRowHi       = $35                       ; 

CCZ_ObjHiResOut         = $36                       ; 
CCZ_ObjHiResOutLo       = $36                       ; 
CCZ_ObjHiResOutHi       = $37                       ; 
; ------------------------------------------------------------------------------------------------------------- ;
CCZ_CtrlScreenRow       = $38                       ; 
CCZ_CtrlScreenRowLo     = $38                       ; 
CCZ_CtrlScreenRowHi     = $39                       ; 

CCZ_SpriteAdrList       = $38                       ; 
CCZ_SpriteAdrListLo     = $38                       ; 
CCZ_SpriteAdrListHi     = $39                       ; 
; ------------------------------------------------------------------------------------------------------------- ;
CCZ_CtrlScreen          = $3c                       ; 
CCZ_CtrlScreenLo        = $3c                       ; 
CCZ_CtrlScreenHi        = $3d                       ; 
; ------------------------------------------------------------------------------------------------------------- ;
CCZ_ScreenLoadFix       = $3e                       ; ptr: fix area of ScreenLoadData lines
CCZ_ScreenLoadFixLo     = $3e                       ; 
CCZ_ScreenLoadFixHi     = $3f                       ; 
; ------------------------------------------------------------------------------------------------------------- ;
CCZ_RoomItem            = $3e                       ; ptr: paint room items data
CCZ_RoomItemLo          = $3e                       ; 
CCZ_RoomItemHi          = $3f                       ; 
CCZ_RoomDoor              = CCZ_RoomItem            ; 
CCZ_RoomFloor             = CCZ_RoomItem            ; 
CCZ_RoomPole              = CCZ_RoomItem            ; 
CCZ_RoomLadder            = CCZ_RoomItem            ; 
CCZ_RoomBell              = CCZ_RoomItem            ; 
CCZ_RoomLight             = CCZ_RoomItem            ; 
CCZ_RoomForce             = CCZ_RoomItem            ; 
CCZ_RoomMummy             = CCZ_RoomItem            ; 
CCZ_RoomKey               = CCZ_RoomItem            ; 
CCZ_RoomLock              = CCZ_RoomItem            ; 
CCZ_RoomGun               = CCZ_RoomItem            ; 
CCZ_RoomMatter            = CCZ_RoomItem            ; 
CCZ_RoomTrap              = CCZ_RoomItem            ; 
CCZ_RoomWalk              = CCZ_RoomItem            ; 
CCZ_RoomFrank             = CCZ_RoomItem            ; 
CCZ_RoomText              = CCZ_RoomItem            ; 
CCZ_RoomGraphic           = CCZ_RoomItem            ; 
; ------------------------------------------------------------------------------------------------------------- ;
CCZ_RoomLiSwMod         = $30                       ; ptr: first  lighning machine modify pointer to switch
CCZ_RoomLiSwModLo       = $30                       ; 
CCZ_RoomLiSwModHi       = $31                       ; 

CCZ_RoomLiBaMod         = $32                       ; ptr: second lighning machine modify pointer to ball
CCZ_RoomLiBaModLo       = $32                       ; 
CCZ_RoomLiBaModHi       = $33                       ; 

CCZ_RoomItemMod         = $40                       ; ptr: modify room items data
CCZ_RoomItemModLo       = $40                       ; 
CCZ_RoomItemModHi       = $41                       ; 
CCZ_RoomDoorMod           = CCZ_RoomItemMod         ; 
CCZ_RoomLightMod          = CCZ_RoomItemMod         ; 
CCZ_RoomMummyMod          = CCZ_RoomItemMod         ; 
CCZ_RoomKeyMod            = CCZ_RoomItemMod         ; 
CCZ_RoomGunMod            = CCZ_RoomItemMod         ; 
CCZ_RoomMatterMod         = CCZ_RoomItemMod         ; 
CCZ_RoomTrapMod           = CCZ_RoomItemMod         ; 
CCZ_RoomWalkMod           = CCZ_RoomItemMod         ; 
CCZ_RoomFrankMod          = CCZ_RoomItemMod         ; 
; ------------------------------------------------------------------------------------------------------------- ;
CCZ_RoomData            = $42                       ; 
CCZ_RoomDataLo          = $42                       ; 
CCZ_RoomDataHi          = $43                       ; 
; ------------------------------------------------------------------------------------------------------------- ;
CCZ_MapData             = $42                       ; 
CCZ_MapDataLo           = $42                       ; 
CCZ_MapDataHi           = $43                       ; 
; ------------------------------------------------------------------------------------------------------------- ;
CCZ_SoundData           = $44                       ; 
CCZ_SoundDataLo         = $44                       ; 
CCZ_SoundDataHi         = $45                       ; 

CCZ_SidVoiceAdr         = $46                       ; 
CCZ_SidVoiceAdrLo       = $46                       ; 
CCZ_SidVoiceAdrHi       = $47                       ; 

CCZ_SidVoiceVal         = $48                       ; 
CCZ_SidVoiceValLo       = $48                       ; 
CCZ_SidVoiceValHi       = $49                       ; 
; ------------------------------------------------------------------------------------------------------------- ;
; Misc
; ------------------------------------------------------------------------------------------------------------- ;
CCZ_CopySpriteRows      = $4a                       ; 
CCZ_CopySpriteCols      = $4b                       ; 

CCZ_CopyFrom            = $4c                       ; 
CCZ_CopyFromLo          = $4c                       ; 
CCZ_CopyFromHi          = $4d                       ; 

CCZ_CopyTarg            = $4e                       ; 
CCZ_CopyTargLo          = $4e                       ; 
CCZ_CopyTargHi          = $4f                       ; 

CCZ_RoomDataStart       = $50                       ; ptr: actual rooms data start
CCZ_RoomDataStartLo     = $50                       ; 
CCZ_RoomDataStartHi     = $51                       ; 

CCZ_RoomDataEnd         = $52                       ; ptr: actual rooms data end
CCZ_RoomDataEndLo       = $52                       ; 
CCZ_RoomDataEndHi       = $53                       ; 

CCZ_RoomCopyFrom        = $54                       ; ptr: actual rooms data start
CCZ_RoomCopyFromLo      = $54                       ; 
CCZ_RoomCopyFromHi      = $55                       ; 

CCZ_RoomCopyTarg        = $56                       ; ptr: actual rooms data end
CCZ_RoomCopyTargLo      = $56                       ; 
CCZ_RoomCopyTargHi      = $57                       ; 

CCZ_CharGenMatrix       = $83                       ; character matrix read from character rom
;                       = $84                       ; 
;                       = $85                       ; 
;                       = $86                       ; 
;                       = $87                       ; 
;                       = $88                       ; 
;                       = $89                       ; 
;                       = $8a                       ; 
CCZ_PaintTextGridCol    = $8b                       ; filled in sub PaintText
CCZ_PaintTextGridRow    = $8c                       ; 
CCZ_PaintTextColor      = $8d                       ; 
CCZ_PaintTextType       = $8e                       ; 
CCZ_PaintTextHeight     = $8f                       ; 
; ------------------------------------------------------------------------------------------------------------- ;
; PaintObject Parameters and Work 
; ------------------------------------------------------------------------------------------------------------- ;
CCZ_ObjAdrList          = $dd                       ; ptr: selected object data address list
CCZ_ObjAdrListLo        = $dd                       ; 
CCZ_ObjAdrListHi        = $de                       ; 
CCZ_PntObjTemp          = $df                       ; temporary value
CCZ_PntObjPrmType       = $e0                       ; parameters
CCZ_PntObjPrmType00       = $00                     ; 
CCZ_PntObjPrmType01       = $01                     ; 
CCZ_PntObjPrmType02       = $02                     ; 
CCZ_PntObj00PrmNo       = $e1                       ; 
CCZ_PntObj00PrmGridRow  = $e2                       ; 
CCZ_PntObj00PrmGridCol  = $e3                       ; 
CCZ_PntObj01PrmNo       = $e4                       ; 
CCZ_PntObj01PrmGridRow  = $e5                       ; 
CCZ_PntObj01PrmGridCol  = $e6                       ; 
CCZ_PntObj00GridRow     = $e7                       ; work
CCZ_PntObj00GridRowMax  = $e8                       ; 
CCZ_PntObj00Cols        = $e9                       ; 
CCZ_PntObj00Rows        = $ea                       ; 
CCZ_PntObj00RowsMax     = $eb                       ; 
CCZ_PntObj00RowsWrk     = $ec                       ; 
CCZ_PntObj00ColStart    = $ed                       ; 
CCZ_PntObj00ColEndX     = $ee                       ; 
CCZ_PntObj00ColEnd      = $ef                       ; 
CCZ_PntObj00ColWrk      = $f0                       ; 
CCZ_PntObj00Switch      = $f1                       ; 
CCZ_PntObjOn              = $01                     ; 
CCZ_PntObjOff             = $00                     ; 
CCZ_PntObj00SwColor     = $f2                       ; 
CCZ_PntObj01Cols        = $f3                       ; 
CCZ_PntObj01Rows        = $f4                       ; 
CCZ_PntObj01RowsWrk     = $f5                       ; 
CCZ_PntObj01RowsMax     = $f6                       ; 
CCZ_PntObj01ColStart    = $f7                       ; 
CCZ_PntObj01ColEndX     = $f8                       ; 
CCZ_PntObj01ColEnd      = $f9                       ; 
CCZ_PntObj01ColWrk      = $fa                       ; 
CCZ_PntObj01Switch      = $fb                       ; 
CCZ_PntObjRowsWrk       = $fc                       ; 
CCZ_PntObjGridRow       = $fd                       ; 
CCZ_PntObjGridRowMax    = $fe                       ; 
CCZ_PntObjGridCol       = $ff                       ; 
; ------------------------------------------------------------------------------------------------------------- ;
