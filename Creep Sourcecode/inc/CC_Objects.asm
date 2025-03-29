; ------------------------------------------------------------------------------------------------------------- ;
; Castles of Dr Creep - Object Data Maps
; ------------------------------------------------------------------------------------------------------------- ;
; Object ID copied to ($3e/$3f in PaintRoomItems - as address of the item paint routine in ID-Jump-Table
; ------------------------------------------------------------------------------------------------------------- ;
CC_Obj_IdLow              = $00
CC_Obj_IdEndOfData          = $00
CC_Obj_IdDoor               = <ID_Door              ; $03
CC_Obj_IdFloor              = <ID_Floor             ; $06
CC_Obj_IdPole               = <ID_Pole              ; $09
CC_Obj_IdLadder             = <ID_Ladder            ; $0c
CC_Obj_IdDoorBell           = <ID_DoorBell          ; $0f
CC_Obj_IdLightMach          = <ID_LightMachine      ; $12
CC_Obj_IdForceField         = <ID_ForceField        ; $15
CC_Obj_IdMummy              = <ID_Mummy             ; $18
CC_Obj_IdKey                = <ID_Key               ; $1b
CC_Obj_IdLock               = <ID_Lock              ; $1e
CC_Obj_IdDrawObject         = <ID_Object            ; $21
CC_Obj_IdRayGun             = <ID_RayGun            ; $24
CC_Obj_IdTransmitter        = <ID_MatterXmitter     ; $27
CC_Obj_IdTrapDoor           = <ID_TrapDoor          ; $2a
CC_Obj_IdSideWalk           = <ID_SideWalk          ; $2d
CC_Obj_IdFrank              = <ID_FrankenStein      ; $30
CC_Obj_IdTextLine           = <ID_TextLine          ; $33
CC_Obj_IdGraphic            = <ID_Graphic           ; $36
CC_Obj_IdHigh             = $01
CC_Obj_IdAdr                = >ID_Jump_Table        ; $08

CC_Obj_IdLen                = $02   ; 
; ------------------------------------------------------------------------------------------------------------- ;
; Room
; ------------------------------------------------------------------------------------------------------------- ;
CC_Obj_Room               = $00   ;  
CC_Obj_RoomEoData           = $40 ; EndOfRoom 
CC_Obj_RoomColor          = $00   ; 00-0f Bit 7=1: room visited
CC_Obj_RoomColorMask        = $0f ; 
CC_Obj_RoomPainted          = $20 ; room painted already - .hbu015.
CC_Obj_RoomVisited          = $80 ; room visited already
CC_Obj_RoomGridCol        = $01   ; top left corner on map
CC_Obj_RoomGridRow        = $02   ; 
CC_Obj_RoomSize           = $03   ; Bits:  ..xx xyyy
CC_Obj_RoomSizeMin          = $02 ; min 2*2
CC_Obj_RoomSizeMax          = $07 ; max 7*7
CC_Obj_RoomDoorNoLo       = $04   ; address CC_Obj_DoorCount
CC_Obj_RoomDoorNoHi       = $05   ; 
CC_Obj_RoomDoorIdLo       = $06   ; address CC_DoorId
CC_Obj_RoomDoorIdHi       = $07   ; 

CC_Obj_RoomDataLen        = $08   ; 
; ------------------------------------------------------------------------------------------------------------- ;
; 03-08: Door
; ------------------------------------------------------------------------------------------------------------- ;
CC_Obj_DoorCount          = $00   ; doors in room - counter start: 01 

CC_Obj_Door               = $00   ; 
CC_Obj_DoorGridCol        = $00   ; top left corner
CC_Obj_DoorGridRow        = $01   ; 
CC_Obj_DoorInWallId       = $02   ; Bit 0-1: 00=n 01=e 02=s 03=w / Bit 7=1 - door open
CC_Obj_DoorOpen             = $80 ; 
CC_Obk_DoorInWallMask       = $03 ; Bits 0-1 = wall id for map door
CC_Obk_DoorInWallN          = $00 ; 
CC_Obj_DoorInWallE          = $01 ; 
CC_Obj_DoorInWallS          = $02 ; 
CC_Obj_DoorInWallW          = $03 ; 
CC_Obj_DoorToRoomNo       = $03   ; counter start: entry 00 of ROOM list
CC_Obj_DoorToDoorNo       = $04   ; counter start: entry 00 of Room DOOR list
CC_Obj_DoorMapOffCol      = $05   ; 
CC_Obj_DoorMapOffRow      = $06   ; 
CC_Obj_DoorType           = $07   ; 
CC_Obj_DoorTypeGate         = $00 ; normal entry
CC_Obj_DoorTypeExit         = $01 ; castle exit

CC_Obj_DoorDataLen        = $08   ;
; ------------------------------------------------------------------------------------------------------------- ;
; 06-08: Floor
; ------------------------------------------------------------------------------------------------------------- ;
CC_Obj_Floor              = $00   ; 
CC_Obj_FloorEoData          = $00 ; end of data marker
CC_Obj_FloorLength        = $00   ; counter start: 01
CC_Obj_FloorGridCol       = $01   ; leftmost corner
CC_Obj_FloorGridRow       = $02   ; 

CC_Obj_FloorDataLen       = $03   ;
; ------------------------------------------------------------------------------------------------------------- ;
; 09-08: Pole
; ------------------------------------------------------------------------------------------------------------- ;
CC_Obj_Pole               = $00   ; 
CC_ObjPoleEoData            = $00 ; end of data marker
CC_Obj_PoleLength         = $00   ; counter start: 01  end: 01 above ground
CC_Obj_PoleGridCol        = $01   ; top of pole
CC_Obj_PoleGridRow        = $02   ; 

CC_Obj_PoleDataLen        = $03   ;
; ------------------------------------------------------------------------------------------------------------- ;
; 0c-08: Ladder
; ------------------------------------------------------------------------------------------------------------- ;
CC_Obj_Ladder             = $00   ; 
CC_Obj_LadderEoData         = $00 ; end of data marker
CC_Obj_LadderLength       = $00   ; counter start: 01  end: directly on ground
CC_Obj_LadderGridCol      = $01   ; top of ladder
CC_Obj_LadderGridRow      = $02   ; 

CC_Obj_LadderDataLen      = $03   ;
; ------------------------------------------------------------------------------------------------------------- ;
; 0f-08: Door Bell
; ------------------------------------------------------------------------------------------------------------- ;
CC_Obj_BellCount          = $00   ; bells in room - counter start: 01 

CC_Obj_Bell               = $00   ; 
CC_Obj_BellGridCol        = $00   ; top left corner
CC_Obj_BellGridRow        = $01   ; 
CC_Obj_BellTargetDoorNo   = $02   ; counter start: entry 00 of Room DOOR list

CC_Obj_BellDataLen        = $03   ;
; ------------------------------------------------------------------------------------------------------------- ;
; 12-08: Lighning Machine
; ------------------------------------------------------------------------------------------------------------- ;
CC_Obj_Light              = $00   ;
CC_Obj_LightEoData          = $20 ; end of data marker
CC_Obj_LightMode          = $00   ; $00=Ball off / $40=Ball on / $80=Switch down / $c0=Switch up
CC_Obj_LightBallOff         = $00 ; 
CC_Obj_LightBallOn          = $40 ; 
CC_Obj_LightSwitchDown      = $80 ; 
CC_Obj_LightSwitchUp        = $c0 ; 
CC_Obj_LigthGridCol       = $01   ; top left corner Pole / Switch
CC_Obj_LigthGridRow       = $02   ; 
CC_Obj_LightPoleOn1         = HR_WhiteBlue  ; pole active scrolling phase 1
CC_Obj_LightPoleOn2         = HR_BlueWhite  ; pole active scrolling phase 2
CC_Obj_LightPoleOn3         = HR_BlueBlue   ; pole active scrolling phase 3
CC_Obj_LightPoleOff         = HR_GreenGreen ; pole inactive
CC_Obj_LightPoleLen       = $03   ; counter start: 01  end: 05 above ground (used only for pole)
CC_Obj_LightSelBa1        = $04   ; ball selection list                     (used only for switch)
CC_Obj_LightSelBa2        = $05   ; 
CC_Obj_LightSelBa3        = $06   ; 
CC_Obj_LightSelBa4        = $07   ; 

CC_Obj_LightDataLen       = $08   ;
; ------------------------------------------------------------------------------------------------------------- ;
; 15-08: ForceField
; ------------------------------------------------------------------------------------------------------------- ;
CC_Obj_Force              = $00   ; 
CC_Obj_ForceEoData          = $00 ; end of data marker
CC_Obj_ForceSwGridCol     = $00   ; top left corner Switch
CC_Obj_ForceSwGridRow     = $01   ; 
CC_Obj_ForceFiGridCol     = $02   ; top left corner Field
CC_Obj_ForceFiGridRow     = $03   ; 

CC_Obj_ForceDataLen       = $04   ;
; ------------------------------------------------------------------------------------------------------------- ;
; 18-08: Mummy
; ------------------------------------------------------------------------------------------------------------- ;
CC_Obj_Mummy              = $00   ; 
CC_Obj_MummyEoData          = $00 ; end of data marker
CC_Obj_MummyStatus        = $00   ; $01=in  $02=out $03=dead
CC_Obj_MummyIn              = $01 ; 
CC_Obj_MummyOut             = $02 ; 
CC_Obj_MummyKilled          = $03 ; 
CC_Obj_MummyAnkhGridCol   = $01   ; top left corner Ankh
CC_Obj_MummyAnkhGridRow   = $02   ; 
CC_Obj_MummAnkhColor        = HR_BlueBlue   ; 
CC_Obj_MummAnkhColorFlash   = HR_WhiteWhite ; 
CC_Obj_MummyWallGridCol   = $03   ; top left corner Wall
CC_Obj_MummyWallGridRow   = $04   ; 
CC_Obj_MummySpriteCol     = $05   ; filled during play
CC_Obj_MummySpriteRow     = $06   ; filled during play

CC_Obj_MummyDataLen       = $07   ;
; ------------------------------------------------------------------------------------------------------------- ;
; 1b-08: Key
; ------------------------------------------------------------------------------------------------------------- ;
CC_Obj_Key                = $00   ; 
CC_Obj_KeyEoData            = $00 ; end of data marker
CC_Obj_KeyColor           = $00   ; type1: ($01=white $03=cyan  $06=blue) type2: ($02=red  $04=purple $05=green $07=yellow)
CC_Obj_KeyWhite             = $01 ; 
CC_Obj_KeyRed               = $02 ; 
CC_Obj_KeyCyan              = $03 ; 
CC_Obj_KeyPurple            = $04 ; 
CC_Obj_KeyGreen             = $05 ; 
CC_Obj_KeyBlue              = $06 ; 
CC_Obj_KeyYellow            = $07 ; 
CC_Obj_KeyStatus          = $01   ; $50 + CC_Obj_KeyColor=not taken   $00=taken
CC_Obj_KeyPickedUp          = $00 ; 
CC_Obj_KeyGridCol         = $02   ; top left corner Key
CC_Obj_KeyGridRow         = $03   ; 

CC_Obj_KeyDataLen         = $04   ;
; ------------------------------------------------------------------------------------------------------------- ;
; 1e-08: Lock
; ------------------------------------------------------------------------------------------------------------- ;
CC_Obj_Lock               = $00   ; 
CC_Obj_LockEoData           = $00 ; end of data marker
CC_Obj_LockColor          = $00   ; type1: ($01=white $03=cyan  $06=blue) type2: ($02=red  $04=purple $05=green $07=yellow)
CC_Obj_LockWhite            = $01 ; 
CC_Obj_LockRed              = $02 ; 
CC_Obj_LockCyan             = $03 ; 
CC_Obj_LockPurple           = $04 ; 
CC_Obj_LockGreen            = $05 ; 
CC_Obj_LockBlue             = $06 ; 
CC_Obj_LockYellow           = $07 ; 
CC_Obj_LockStatus         = $01   ; $57 + CC_Obj_LockColor=locked   $00 + CC_Obj_LockColor=open
CC_Obj_LockTargetDoorNo   = $02   ; counter start: entry 00 of rooms DOOR list
CC_Obj_LockGridCol        = $03   ; top left corner Lock
CC_Obj_LockGridRow        = $04   ; 

CC_Obj_LockDataLen        = $05   ;
; ------------------------------------------------------------------------------------------------------------- ;
; 21-08: DrawObject
; ------------------------------------------------------------------------------------------------------------- ;
CC_Obj_Draw               = $00   ; 
CC_Obj_DrawEoData           = $00 ; end of data marker
CC_Obj_Count              = $00   ; counter start: 01
CC_Obj_DrawObjectId       = $01   ; object no to be drawn
CC_Obj_DrawGridCol        = $02   ; top left corner Object
CC_Obj_DrawGridRow        = $03   ; 
CC_Obj_DrawGridColOff     = $04   ; offset from top left corner if CC_Obj_Count > $00
CC_Obj_DrawGridRowOff     = $05   ; 

CC_Obj_DrawDataLen        = $06   ;
; ------------------------------------------------------------------------------------------------------------- ;
; 24-08: RayGun
; ------------------------------------------------------------------------------------------------------------- ;
CC_Obj_Gun                = $00   ; 
CC_Obj_GunEoData            = $80 ; end of data marker
CC_Obj_GunDirection       = $00   ; Bit0=0: point right  Bit0=1:point left  Bit1=0: move down  Bit1=1: move up 
CC_Obj_GunPointRight        = $00 ; 
CC_Obj_GunPointLeft         = $01 ; 
CC_Obj_GunMoveDown          = $02 ; flag: 1=move down
CC_Obj_GunMoveUp            = $04 ; flag: 1=move up
CC_Obj_GunMoveFire          = $08 ; flag: 1=fire pressed
CC_Obj_GunSwitch            = $10 ; flag: 1=switch
CC_Obj_GunMoveStop          = $20 ; flag: 1=move stopped
CC_Obj_GunShoots            = $40 ; flag: 1=shoot under way
CC_Obj_GunPoleGridCol     = $01   ; top of Pole
CC_Obj_GunPoleGridRow     = $02   ; 
CC_Obj_GunPoleLen         = $03   ; 
CC_Obj_GunPosY            = $04   ; 
CC_Obj_GunSwitchGridCol   = $05   ; top left corner of Switch
CC_Obj_GunSwitchGridRow   = $06   ; 
CC_Obj_GunSwitchColorUp     = HR_GreenGrey ; color gun moves up
CC_Obj_GunSwitchColorNo     = HR_GreyGrey  ; color gun does not move
CC_Obj_GunSwitchColorDo     = HR_GreyRed   ; color gun moves down

CC_Obj_GunDataLen         = $07   ;
; ------------------------------------------------------------------------------------------------------------- ;
; 27-08: MatterTranmitter
; ------------------------------------------------------------------------------------------------------------- ;
CC_Obj_Xmit               = $00   ; 
CC_Obj_XmitEoData           = $00 ; end of data marker
CC_Obj_XmitBoothGridCol   = $00   ; 
CC_Obj_XmitBoothGridRow   = $01   ; 
CC_Obj_XmitBoothColor     = $02   ; $00=red $01=cyan $02=purple $03=green $04=blue $05=yellow $06=orange $07=brown $08=lt-red $09=grey
CC_Obj_XmitTarg0GridCol   = $03   ; Receiver ovals (max $09)
CC_Obj_XmitTarg0GridRow   = $04   ; 

CC_Obj_XmitBoothDataLen   = $03   ;
CC_Obj_XmitTarg0DataLen   = $02   ;
; ------------------------------------------------------------------------------------------------------------- ;
; 2a-08: TrapDoor
; ------------------------------------------------------------------------------------------------------------- ;
CC_Obj_Trap               = $00   ; 
CC_Obj_TrapEoData           = $80 ; end of data marker
CC_Obj_TrapStatus         = $00   ; $00=closed  $01=open
CC_Obj_TrapOpen             = $01 ; 
CC_Obj_TrapClosed           = $00 ; 
CC_Obj_TrapDoorGridCol    = $01   ; top left corner of Door
CC_Obj_TrapDoorGridRow    = $02   ; 
CC_Obj_TrapSwitchGridCol  = $03   ; top left corner of Control
CC_Obj_TrapSwitchGridRow  = $04   ; 
CC_Obj_TrapSwColorOpen      = HR_GreenGreen ; color switch trap door open
CC_Obj_TrapSwColorOffTop    = HR_GreyBlack  ; color switch trap neutral top    position
CC_Obj_TrapSwColorOffBot    = HR_GreyGrey   ; color switch trap neutral bottom position
CC_Obj_TrapSwColorClosed    = HR_RedBlack   ; color switch trap door closed

CC_Obj_TrapDataLen        = $05   ;
; ------------------------------------------------------------------------------------------------------------- ;
; 2d-08: MovingSideWalk
; ------------------------------------------------------------------------------------------------------------- ;
CC_Obj_Walk               = $00   ; 
CC_Obj_WalkEoData           = $80 ; end of data marker
CC_Obj_WalkStatus         = $00   ; $00=stop $01=right $02=stop $03=left
CC_Obj_WalkStopRight        = $00 ; 
CC_Obj_WalkMoveRight        = $01 ; flag: sidewalk moves 0=right 1=left
CC_Obj_WalkStopLeft         = $02 ; flag: sidewalk stops 0=right 1=left
CC_Obj_WalkMoveLeft         = $03 ; 
CC_Obj_WalkSwitchPressP1    = $04 ; flag: player one pressed control
CC_Obj_WalkSwitchPressP2    = $08 ; flag: player two pressed control
CC_Obj_WalkSwitchPressP1S   = $10 ; flag: save player one pressed control - useless ??
CC_Obj_WalkSwitchPressP2S   = $20 ; flag: save player two pressed control - useless ??
CC_Obj_WalkGridCol        = $01   ; top left corner of Sidewalk
CC_Obj_WalkGridRow        = $02   ; 
CC_Obj_WalkSwitchGridCol  = $03   ; top left corner of Control
CC_Obj_WalkSwitchGridRow  = $04   ; 
CC_Obj_WalkSwitchColorLe    = HR_GreenBlack ; 
CC_Obj_WalkSwitchColorNo    = HR_GreyBlack  ; 
CC_Obj_WalkSwitchColorRi    = HR_RedBlack   ; 

CC_Obj_WalkDataLen        = $05   ;
; ------------------------------------------------------------------------------------------------------------- ;
; 30-08: Frankenstein
; ------------------------------------------------------------------------------------------------------------- ;
CC_Obj_Frank              = $00   ; 
CC_Obj_FrankEoData          = $80 ; end of data marker
CC_Obj_FrankCoffinDir     = $00   ; $00=look right / $01=look left / $02=right and out / $03=left and out / $04=frank dead
CC_Obj_FrankCoffinRight     = $00 ; direction
CC_Obj_FrankCoffinLeft      = $01 ; 
CC_Obj_FrankAwake           = $02 ; out and living
CC_Obj_FrankKilled          = $04 ; out but dead
CC_Obj_FrankCoffinGridCol = $01   ; top left corner of Coffin
CC_Obj_FrankCoffinGridRow = $02   ; 
CC_Obj_FrankSpritePosX    = $03   ; 
CC_Obj_FrankSpritePosY    = $04   ; 
CC_Obj_FrankSpriteNo      = $05   ; 
CC_Obj_FrankSpriteMoveDir = $06   ; $00=up $02=right $04=down $06=left
CC_Obj_FrankMoveMoveUp      = $00 ; 
CC_Obj_FrankMoveMoveRight   = $02 ; 
CC_Obj_FrankMoveMoveDown    = $04 ; 
CC_Obj_FrankMoveMoveLeft    = $06 ; 

CC_Obj_FrankDataLen       = $07   ;
; ------------------------------------------------------------------------------------------------------------- ;
; 33-08: TextLine - fix header and variable length text
; ------------------------------------------------------------------------------------------------------------- ;
CC_Obj_Text               = $00   ; 
CC_Obj_TextEoData           = $00 ; end of data marker
CC_Obj_TextEoLine           = $80 ; end of line flag
CC_Obj_TextGridCol        = $00   ; 
CC_Obj_TextGridRow        = $01   ; 
CC_Obj_TextColor          = $02   ; 
CC_Obj_TextFormat         = $03   ; height: $x1=normal  $x2=double $x3=tripple / view: $2x=normal $3x=reverse
CC_Obj_TextHightSingle      = $01 ; single height
CC_Obj_TextHightDouble      = $02 ; double height
CC_Obj_TextHightTripple     = $03 ; triple height
CC_Obj_TextNormal           = $20 ; normal   charset
CC_Obj_TextReversed         = $30 ; reversed charset
                          
CC_Obj_TextHdrLen         = $04   ;

CC_Obj_TextStart          = $04   ; Start of text - Bit 7=1 - end of line (max 20 chrs if CC_Obj_TextHightDouble)
; ------------------------------------------------------------------------------------------------------------- ;
; 36-08: Graphic
; ------------------------------------------------------------------------------------------------------------- ;
CC_Obj_Graphic            = $00   ; 
CC_Obj_GraphicEoData        = $00   ; end of data marker
CC_Obj_GraphicCols        = $00   ; objects number of bytes per column
CC_Obj_GraphicRows        = $01   ; objects number of rows
CC_Obj_GraphicEndOfHdr    = $02   ; end of Graphic Header - always $00

CC_Obj_GraphicHdrLen      = $03   ;

CC_Obj_GraphicData        = $00   ; variable - (CC_Obj_GraphicCols * CC_Obj_GraphicRows) bytes

CC_Obj_GraphicGridCol     = $00   ; top left corner of Graphic
CC_Obj_GraphicGridRow     = $01   ; 

CC_Obj_GraphicPosLen      = $02   ; length pointer grid pos
CC_Obj_GraphicPosLstEnd   = $00   ; $00 = end of position list

CC_Obj_GraphicColorHiRes  = $00   ; [(((CC_Obj_GraphicRows - 1) / 8) + 1) * CC_Obj_GraphicCols] bytes for video ram - 1 byte per 8*8 grid
CC_Obj_GraphicColorRam    = $01   ; [(((CC_Obj_GraphicRows - 1) / 8) + 1) * CC_Obj_GraphicCols] bytes for color ram - 1 byte per 8*8 grid
; ------------------------------------------------------------------------------------------------------------- ;
