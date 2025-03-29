; ------------------------------------------------------------------------------------------------------------- ;
; The Castles of Dr Creep - Object Data Maps
; ------------------------------------------------------------------------------------------------------------- ;
; Object ID - copied to ($3e/$3f in PaintRoomItems - is address of paint routine in ID Jump Table
; ------------------------------------------------------------------------------------------------------------- ;
CC_IDLow         = $00
CC_IDDoor          = $03
CC_IDFloor         = $06
CC_IDPole          = $09
CC_IDLadder        = $0c
CC_IDDoorBell      = $0f
CC_IDLightMach     = $12
CC_IDForceField    = $15
CC_IDMummy         = $18
CC_IDKey           = $1b
CC_IDLock          = $1e
CC_IDDrawObject    = $21
CC_IDRayGun        = $24
CC_IDTransmitter   = $27
CC_IDTrapDoor      = $2a
CC_IDSideWalk      = $2d
CC_IDFrank         = $30
CC_IDTextLine      = $33
CC_IDGraphic       = $36
CC_IDHigh        = $01
CC_IDAdr           = $08
; ------------------------------------------------------------------------------------------------------------- ;
; Object Data Maps
; ------------------------------------------------------------------------------------------------------------- ;
; Room
; ------------------------------------------------------------------------------------------------------------- ;
CC_Room          = $00    ;  
CC_EoRoomData      = $40  ; EndOfRoom 
CC_RoomColor     = $00    ; 00-0f Bit 7=1: room visited
CC_RoColor         = $0f
CC_RoVisited       = $80
CC_RoomMapPosX   = $01    ; top left corner on map
CC_RoomMapPosY   = $02    ; 
CC_RoomSize      = $03    ; Bits:  ..xx xyyy - min 2*2  max 7*7
CC_RoomDoorsNoLo = $04    ; address CC_DoorCount
CC_RoomDoorsNoHi = $05    ; 
CC_RoomDoorIdLo  = $06    ; address CC_DoorId
CC_RoomDoorIdHi  = $07    ; 
;
CC_RoomLen       = $08    ; 
; ------------------------------------------------------------------------------------------------------------- ;
; 03-08: Door
; ------------------------------------------------------------------------------------------------------------- ;
CC_DoorCount     = $00    ; doors in room - counter start: 01 
;
CC_Door          = $00    ; 
CC_DoorPosX      = $00    ; top left corner
CC_DoorPosY      = $01    ; 
CC_DoorInWall    = $02    ; Bit 0-1: 00=n 01=e 02=s 03=w / Bit 7=1 - door open
CC_DoorOpen        = $80
CC_DoInWallNorth   = $00
CC_DoInWallEast    = $01
CC_DoInWallSouth   = $02
CC_DoInWallWest    = $03
CC_DoInWallOpen    = $80
CC_DoorToRoomNo  = $03    ; counter start: entry 00 of ROOM list
CC_DoorToDoorNo  = $04    ; counter start: entry 00 of Room DOOR list
CC_DoorMapOffX   = $05    ; 
CC_DoorMapOffY   = $06    ; 
CC_DoorType      = $07    ; 00=normal  01=exit
CC_DoTypeNormal    = $00
CC_DoTypeExit      = $01
;
CC_DoorLen       = $08    ;
; ------------------------------------------------------------------------------------------------------------- ;
; 06-08: Floor
; ------------------------------------------------------------------------------------------------------------- ;
CC_Floor         = $00    ; 
CC_EoFloorData     = $00  ; end of data marker
CC_FloorLength   = $00    ; counter start: 01
CC_FloorPosX     = $01    ; leftmost corner
CC_FloorPosY     = $02    ; 
;
CC_FloorLen      = $03    ;
; ------------------------------------------------------------------------------------------------------------- ;
; 09-08: Pole
; ------------------------------------------------------------------------------------------------------------- ;
CC_Pole          = $00    ; 
CC_EoPoleData      = $00  ; end of data marker
CC_PoleLength    = $00    ; counter start: 01  end: 01 above ground
CC_PolePosX      = $01    ; top of pole
CC_PolePosY      = $02    ; 
;
CC_PoleLen       = $03    ;
; ------------------------------------------------------------------------------------------------------------- ;
; 0c-08: Ladder
; ------------------------------------------------------------------------------------------------------------- ;
CC_Ladder        = $00    ; 
CC_EoLadderData    = $00  ; end of data marker
CC_LadderLength  = $00    ; counter start: 01  end: directly on ground
CC_LadderPosX    = $01    ; top of ladder
CC_LadderPosY    = $02    ; 
;
CC_LadderLen    = $03    ;
; ------------------------------------------------------------------------------------------------------------- ;
; 0f-08: Door Bell
; ------------------------------------------------------------------------------------------------------------- ;
CC_BellCount     = $00    ; bells in room - counter start: 01 
;
CC_DoorBell      = $00    ; 
CC_BellPosX      = $00    ; top left corner
CC_BellPosY      = $01    ; 
CC_BellForDoorNo = $02    ; counter start: entry 00 of Room DOOR list
;
CC_DoorBellLen   = $03    ;
; ------------------------------------------------------------------------------------------------------------- ;
; 12-08: Lighning Machine
; ------------------------------------------------------------------------------------------------------------- ;
CC_LightMachine  = $00    ;
CC_EoLightData     = $20  ; end of data marker
CC_LMMode        = $00    ; $00=Ball off / $40=Ball on / $80=Switch down / $c0=Switch up
CC_LMBallOff       = $00
CC_LMBallOn        = $40
CC_LMSwitchDown    = $80
CC_LMSwitchUp      = $c0
CC_LMPosX        = $01    ; top left corner Pole / Switch
CC_LMPosY        = $02    ; 
CC_LMPoleLenght  = $03    ; counter start: 01  end: 05 above ground (used only for pole)
CC_LMSelectB1    = $04    ; selection list                          (used only for switch)
CC_LMSelectB2    = $05    ; 
CC_LMSelectB3    = $06    ; 
CC_LMSelectB4    = $07    ; 
;
CC_LightMachLen  = $08    ;
; ------------------------------------------------------------------------------------------------------------- ;
; 15-08: ForceField
; ------------------------------------------------------------------------------------------------------------- ;
CC_ForceField    = $00    ; 
CC_EoForceData     = $00  ; end of data marker
CC_FFSwitchPosX  = $00    ; top left corner Switch
CC_FFSwitchPosY  = $01    ; 
CC_FFFieldPosX   = $02    ; top left corner Field
CC_FFFieldPosY   = $03    ; 
;
CC_ForceFieldLen = $04    ;
; ------------------------------------------------------------------------------------------------------------- ;
; 18-08: Mummy
; ------------------------------------------------------------------------------------------------------------- ;
CC_Mummy         = $00    ; 
CC_EoMummyData     = $00  ; end of data marker
CC_MummyStatus   = $00    ; $01=in  $02=out $03=dead
CC_MummyIn         = $01
CC_MummyOut        = $02
CC_MummyGone       = $03
CC_MummyDead       = $04
CC_MummyAnkhPosX = $01    ; top left corner Ankh
CC_MummyAnkhPosY = $02    ; 
CC_MummyWallPosX = $03    ; top left corner Wall
CC_MummyWallPosY = $04    ; 
CC_MummySprtPosX = $05    ; filled during play
CC_MummySprtPosY = $06    ; filled during play
;
CC_MummyLen      = $07    ;
; ------------------------------------------------------------------------------------------------------------- ;
; 1b-08: Key
; ------------------------------------------------------------------------------------------------------------- ;
CC_Key           = $00    ; 
CC_EoKeyData       = $00  ; end of data marker
CC_KeyColor      = $00    ; type1: ($01=white $03=cyan  $06=blue) type2: ($02=red  $04=purple $05=green $07=yellow)
CC_KeyStatus     = $01    ; $50 + CC_KeyColor=not taken   $00=taken
CC_KeyAway         = $00
CC_KeyWhite        = $01
CC_KeyRed          = $02
CC_KeyCyan         = $03
CC_KeyPurple       = $04
CC_KeyGreen        = $05
CC_KeyBlue         = $06
CC_KeyYellow       = $07
CC_KeyPosX       = $02    ; top left corner Key
CC_KeyPosY       = $03    ; 
;
CC_KeyLen        = $04    ;
; ------------------------------------------------------------------------------------------------------------- ;
; 1e-08: Lock
; ------------------------------------------------------------------------------------------------------------- ;
CC_Lock          = $00    ; 
CC_EoLockData      = $00  ; end of data marker
CC_LockColor     = $00    ; type1: ($01=white $03=cyan  $06=blue) type2: ($02=red  $04=purple $05=green $07=yellow)
CC_LockStatus    = $01    ; $57 + CC_LockColor=locked   $00 + CC_LockColor=open
CC_LockForDoor   = $02    ; counter start: entry 00 of rooms DOOR list
CC_LockPosX      = $03    ; top left corner Lock
CC_LockPosY      = $04    ; 
;
CC_LockLen       = $05    ;
; ------------------------------------------------------------------------------------------------------------- ;
; 21-08: DrawObject
; ------------------------------------------------------------------------------------------------------------- ;
CC_DrawObject    = $00    ; 
CC_EoObjectData    = $00  ; end of data marker
CC_ObjCount      = $00    ; counter start: 01
CC_ObjID         = $01    ; object no to be drawn
CC_ObjPosX       = $02    ; top left corner Object
CC_ObjPosY       = $03    ; 
CC_ObjNextX      = $04    ; offset from top left corner if CC_ObjCount > $00
CC_ObjNextY      = $05    ; 
;
CC_ObjectLen     = $06    ;
; ------------------------------------------------------------------------------------------------------------- ;
; 24-08: RayGun
; ------------------------------------------------------------------------------------------------------------- ;
CC_Gun           = $00    ; 
CC_EoGunData       = $80  ; end of data marker
CC_GunDirection  = $00    ; Bit0=0: point right  Bit0=1:point left  Bit1=0: move down  Bit1=1: move up 
CC_GunPointRight   = $00
CC_GunPointLeft    = $01
CC_GunPoint        = $01  ; flag: 0=point right 1=point left
CC_GunMoveDown     = $02  ; flag: 1=move down
CC_GunMoveUp       = $04  ; flag: 1=move up
CC_GunMoveFire     = $08  ; flag: 1=fire pressed
CC_GunMoveStop     = $20  ; flag: 1=move stopped
CC_GunShoots       = $40  ; flag: 1=shoot under way
CC_GunPolePosX   = $01    ; top of Pole
CC_GunPolePosY   = $02    ; 
CC_GunPoleLength = $03    ; 
CC_GunPosY       = $04    ; 
CC_GunSwitchPosX = $05    ; top left corner of Switch
CC_GunSwitchPosY = $06    ; 
;
CC_RayGunLen     = $07    ;
; ------------------------------------------------------------------------------------------------------------- ;
; 27-08: MatterTranmitter
; ------------------------------------------------------------------------------------------------------------- ;
CC_Transmitter   = $00    ; 
CC_EoMatterData    = $00  ; end of data marker
CC_MTBoothPosX   = $00    ; 
CC_MTBoothPosY   = $01    ; 
CC_MTBoothColor  = $02    ; $00=red $01=cyan $02=purple $03=green $04=blue $05=yellow $06=orange $07=brown $08=lt-red $09=grey
CC_MTRec01PosX   = $03    ; Receiver ovals (max $09)
CC_MTRec01PosY   = $04    ; 
;
CC_XmitBoothLen  = $03    ;
CC_XmitOvalLen   = $02    ;
; ------------------------------------------------------------------------------------------------------------- ;
; 2a-08: TrapDoor
; ------------------------------------------------------------------------------------------------------------- ;
CC_TrapDoor      = $00    ; 
CC_EoTrapData      = $80  ; end of data marker
CC_TrapMode      = $00    ; $00=closed  $01=open
CC_TrapClosed      = $00
CC_TrapOpen        = $01
CC_TrapDoorPosX  = $01    ; top left corner of Door
CC_TrapDoorPosY  = $02    ; 
CC_TrapCtrlPosX  = $03    ; top left corner of Control
CC_TrapCtrlPosY  = $04    ; 
;
CC_TrapDoorLen   = $05    ;
; ------------------------------------------------------------------------------------------------------------- ;
; 2d-08: MovingSideWalk
; ------------------------------------------------------------------------------------------------------------- ;
CC_SideWalk      = $00    ; 
CC_EoWalkData      = $80  ; end of data marker
CC_WalkMode      = $00    ; $00=stop $01=right $02=stop $03=left
CC_WalkStopR       = $00
CC_WalkMoveR       = $01
CC_WalkStopL       = $02
CC_WalkMoveL       = $03
CC_WalkStop        = $01  ; flag: sidewalk stops 0=right 1=left
CC_WalkMove        = $02  ; flag: sidewalk moves 0=right 1=left
CC_WalkPressP1     = $04  ; flag: player one pressed control
CC_WalkPressP2     = $08  ; flag: player two pressed control
CC_WalkPressP1Sav  = $10  ; flag: save player one pressed control - useless ??
CC_WalkPressP2Sav  = $20  ; flag: save player two pressed control - useless ??
CC_WalkPosX      = $01    ; top left corner of Sidewalk
CC_WalkPosY      = $02    ; 
CC_WalkCtrlPosX  = $03    ; top left corner of Control
CC_WalkCtrlPosY  = $04    ; 
;
CC_SideWalkLen   = $05    ;
; ------------------------------------------------------------------------------------------------------------- ;
; 30-08: Frankenstein
; ------------------------------------------------------------------------------------------------------------- ;
CC_Frankenstein  = $00    ; 
CC_EoFrankData     = $80  ; end of data marker
CC_FrStCoffDir   = $00    ; $00=look right / $01=look left / $02=right and out / $03=left and out / $04=frank dead
CC_FrStCoffinRi    = $00  ; flag: 00 open to the right
CC_FrStCoffinLe    = $01  ; flag: 01 open to the left
CC_FrStAwake       = $02  ; flag: 01=awake
CC_FrStGone        = $04  ; flag: 01=gone
CC_FrStCoffPosX  = $01    ; top left corner of Coffin
CC_FrStCoffPosY  = $02    ; 
CC_FrStSprtPosX  = $03    ; 
CC_FrStSprtPosY  = $04    ; 
CC_FrStSprtNo    = $05    ; 
CC_FrStSprtDir   = $06    ; $00=up $02=right $04=down $06=left
CC_SprtMovUp       = $00  ; 
CC_SprtMovRight    = $02  ; 
CC_SprtMovDown     = $04  ; 
CC_SprtMovLeft     = $06  ; 
;
CC_FrankLen      = $07    ;
; ------------------------------------------------------------------------------------------------------------- ;
; 33-08: TextLine
; ------------------------------------------------------------------------------------------------------------- ;
CC_TextLine      = $00    ; 
CC_EoTextData      = $00  ; end of data marker
CC_TextPosX      = $00    ; 
CC_TextPosY      = $01    ; 
CC_TextColor     = $02    ; 
CC_TextFormat    = $03    ; height: $x1=normal  $x2=double $x3=tripple / view: $2x=normal $3x=reverse
CC_TextHightNrm    = $01  ; single height
CC_TextHightDbl    = $02  ; double height
CC_TextHightTri    = $03  ; triple height
CC_TextNormal      = $20  ; normal   charset
CC_TextReverse     = $30  ; reversed charset
;
CC_TextHeaderLen = $04    ;
;
CC_TextStart     = $04    ; Bit 7=1 - EndOfLine  (max 20 chrs per line)
CC_TextEoLine      = $80  ; EndOfLine
; ------------------------------------------------------------------------------------------------------------- ;
; 36-08: Graphic
; ------------------------------------------------------------------------------------------------------------- ;
CC_Graphic       = $00    ; 
CC_EoGraphicData   = $00  ; end of data marker
CC_GfxCols       = $00    ; objects number of bytes per column
CC_GfxRows       = $01    ; objects number of rows
CC_GfxEndOfHdr   = $02    ; end of Graphic Header - always $00
;
CC_GfxHeaderLen  = $03    ;
;
;CC_GfxData       = $00    ; (CC_GfxCols * CC_GfxRows) bytes
;
CC_GfxPosX       = $00    ; top left corner of Graphic
CC_GfxPosY       = $01    ; 
;
CC_GfxPointerLen = $02    ;
;
;CC_GfxEndOfPos   = $00    ; $00 = end of position list
;
;CC_GfxColorVideo = $00    ; [(((CC_GfxRows - 1) / 8) + 1) * CC_GfxCols] bytes for video ram - one byte for each 8*8 grid
;CC_GfxColorRam   = $01    ; [(((CC_GfxRows - 1) / 8) + 1) * CC_GfxCols] bytes for color ram - one byte for each 8*8 grid
; ------------------------------------------------------------------------------------------------------------- ;
