; ------------------------------------------------------------------------------------------------------------- ;
; Castles of Dr Creep - Work Areas
; ------------------------------------------------------------------------------------------------------------- ;
; Sprite and Object Work Areas
; ------------------------------------------------------------------------------------------------------------- ;
CC_WaO_DataLen          = $08                       ; length of each object work area
CC_WaS_DataLen          = $20                       ; length of each sprite work area

CC_WaO_BlocksMax        = $20                       ; 
CC_WaS_BlocksMax        = $08                       ; 

CC_WaS_Common           = CC_WorkAreasStart + $0000 ; sprites        data  - max $08 blocks of $20 bytes
CC_WaO_Type             = CC_WorkAreasStart + $0100 ; object special data  - max $20 blocks of $08 bytes
CC_WaO_Common           = CC_WorkAreasStart + $0200 ; object common  data  - max $20 blocks of $08 bytes
; ------------------------------------------------------------------------------------------------------------- ;
; Object Individual Work Area Maps - max $20 blocks of $08 bytes
; ------------------------------------------------------------------------------------------------------------- ;
CC_WaO_TypDoorNo        = CC_WaO_Type + $00         ; Door
CC_WaO_TypDoorFlag      = CC_WaO_Type + $01         ; 
CC_WaO_TypDoorShut        = $00                     ; 
CC_WaO_TypDoorOpen        = $01                     ; 
CC_WaO_TypDoorLiftCount = CC_WaO_Type + $02         ; gate lifting process counter
CC_WaO_TypDoorLiftStart   = $0e
CC_WaO_TypDoorTargColor = CC_WaO_Type + $03         ; target rooms color
; ------------------------------------------------------------------------------------------------------------- ;
CC_WaO_TypBellTargDoorNo= CC_WaO_Type + $00         ; DoorBell
; ------------------------------------------------------------------------------------------------------------- ;
CC_WaO_TypLightBallNo   = CC_WaO_Type + $00         ; LightningMachine
CC_WaO_TypLightBallNone   = $ff
CC_WaO_TypLightBall00     = $00 * CC_WaO_DataLen    ; $00
CC_WaO_TypLightBall01     = $01 * CC_WaO_DataLen    ; $08
CC_WaO_TypLightBall02     = $02 * CC_WaO_DataLen    ; $10
CC_WaO_TypLightBall03     = $03 * CC_WaO_DataLen    ; $18
CC_WaO_TypLightBall04     = $04 * CC_WaO_DataLen    ; $20
CC_WaO_TypLightBall05     = $05 * CC_WaO_DataLen    ; $28
CC_WaO_TypLightBall06     = $06 * CC_WaO_DataLen    ; $30
CC_WaO_TypLightBall07     = $07 * CC_WaO_DataLen    ; $38
CC_WaO_TypLightBall08     = $08 * CC_WaO_DataLen    ; $40
CC_WaO_TypLightBall09     = $09 * CC_WaO_DataLen    ; $48
CC_WaO_TypLightBall0a     = $0a * CC_WaO_DataLen    ; $50
CC_WaO_TypLightBall0b     = $0b * CC_WaO_DataLen    ; $58
CC_WaO_TypLightBall0c     = $0c * CC_WaO_DataLen    ; $60
CC_WaO_TypLightBall0d     = $0d * CC_WaO_DataLen    ; $68
CC_WaO_TypLightBall0e     = $0e * CC_WaO_DataLen    ; $70
CC_WaO_TypLightBall0f     = $0f * CC_WaO_DataLen    ; $78
CC_WaO_TypLightBallMode = CC_WaO_Type + $01         ; $00 $01
CC_WaO_TypLightBallOff    = $00                     ; 
CC_WaO_TypLightBallOn     = $01                     ; 
CC_WaO_TypLightPoleMove = CC_WaO_Type + $02         ; $00 $01 $02
CC_WaO_TypLightMove00     = $00                     ; 
CC_WaO_TypLightMove01     = $01                     ; 
CC_WaO_TypLightMove02     = $02                     ; 
CC_WaO_TypLightPoleLen  = CC_WaO_Type + $03         ; 
; ------------------------------------------------------------------------------------------------------------- ;
CC_WaO_TypForceNo       = CC_WaO_Type + $00         ; ForceField
CC_WaO_TypForcePingSecs = CC_WaO_Type + $01         ; $1e - time between two pings
CC_WaO_TypForcePingInit   = $1e
CC_WaO_TypForceTimer    = CC_WaO_Type + $02         ; 
CC_WaO_TypForceTimerInit  = $08
; ------------------------------------------------------------------------------------------------------------- ;
CC_WaO_TypMummyPtrWA    = CC_WaO_Type + $00         ; Mummy
CC_WaO_TypMummyTimer    = CC_WaO_Type + $01         ; 
CC_WaO_TypMummyTimerInit  = $08                     ; 
CC_WaO_TypMummyAnkhColor= CC_WaO_Type + $02         ; color of ankh
; ------------------------------------------------------------------------------------------------------------- ;
CC_WaO_TypKeyData       = CC_WaO_Type + $00         ; Key
; ------------------------------------------------------------------------------------------------------------- ;
CC_WaO_TypLockColor     = CC_WaO_Type + $00         ; Lock
CC_WaO_TypLockTargDoorNo= CC_WaO_Type + $01         ; 
; ------------------------------------------------------------------------------------------------------------- ;
CC_WaO_TypGunPtrWA      = CC_WaO_Type + $00         ; RayGun
CC_WaO_TypGunPoleBottom = CC_WaO_Type + $01         ; bottom of pole
; ------------------------------------------------------------------------------------------------------------- ;
CC_WaO_TypXmitDataPtrLo   = CC_WaO_Type + $00       ; MatterTransmitter
CC_WaO_TypXmitDataPtrHi   = CC_WaO_Type + $01       ; 
CC_WaO_TypXmitBoothColor  = CC_WaO_Type + $02       ; 
CC_WaO_TypXmitTimer       = CC_WaO_Type + $03       ; 
CC_WaO_TypXmitTimerInit     = $08                   ; 
CC_WaO_TypXmitTargGridCol = CC_WaO_Type + $04       ; target oval
CC_WaO_TypXmitTargGridRow = CC_WaO_Type + $05       ; 
; ------------------------------------------------------------------------------------------------------------- ;
CC_WaO_TypTrapDataOff   = CC_WaO_Type + $00         ; TrapDoor - offset next trap door data
CC_WaO_TypTrapMode      = CC_WaO_Type + $01         ; 
CC_WaO_TypTrapClosed      = $00                     ; 
CC_WaO_TypTrapOpen        = $01                     ; 
CC_WaO_TypTrapPhaseNo   = CC_WaO_Type + $02         ; open/close pase object number
; ------------------------------------------------------------------------------------------------------------- ;
CC_WaO_TypWalkDataOff   = CC_WaO_Type + $00         ; MovingSideWalk
; ------------------------------------------------------------------------------------------------------------- ;
; Object Common Work Area Map - max $20 blocks of $08 bytes
; ------------------------------------------------------------------------------------------------------------- ;
CC_WaO_ObjectType       = CC_WaO_Common + $00
CC_WaO_Door               = $00                     ; Door
CC_WaO_DoorBell           = $01                     ; DoorBell
CC_WaO_LightBall          = $02                     ; LightningMachine Ball
CC_WaO_LightSwitch        = $03                     ; LightningMachine Control
CC_WaO_ForceField         = $04                     ; ForceField
CC_WaO_Mummy              = $05                     ; Mummy
CC_WaO_Key                = $06                     ; Key
CC_WaO_Lock               = $07                     ; Lock
CC_WaO_RayGun             = $08                     ; RayGun Phaser
CC_WaO_RayGunSwitch       = $09                     ; RayGun Control
CC_WaO_XmitReceiveOval    = $0a                     ; MatterTransmitter Receiver Oval
CC_WaO_TrapDoor           = $0b                     ; TrapDoor
CC_WaO_TrapSwitch         = $0c                     ; TrapDoor Control
CC_WaO_SideWalk           = $0d                     ; WalkWay
CC_WaO_SideWalkSwitch     = $0e                     ; WalkWay Control
CC_WaO_Frankenstein       = $0f                     ; Frankenstein
CC_WaO_ObjectGridCol    = CC_WaO_Common + $01       ; 
CC_WaO_ObjectGridRow    = CC_WaO_Common + $02       ; 
CC_WaO_ObjectNo         = CC_WaO_Common + $03       ; 
CC_WaO_ObjectFlag       = CC_WaO_Common + $04       ; $20=move  $40=action_completed  $80=just_initialized
CC_WaO_Move               = $20                     ; 
CC_WaO_Ready              = $40                     ; 
CC_WaO_Init               = $80                     ; 
CC_WaO_ObjectCols       = CC_WaO_Common + $05       ; multipied by 4
CC_WaO_ObjectRows       = CC_WaO_Common + $06       ; 
; ------------------------------------------------------------------------------------------------------------- ;
; Sprite Work Area - max $08 blocks of $20 bytes
; ------------------------------------------------------------------------------------------------------------- ;
CC_WaS_SpriteFlag       = CC_WaS_Common + $00       ; 00=active 01=inactive 02=coll_sprt/sprt 04=coll_sprt/bkgr 80=initialized
CC_WaS_FlagActive         = $00                     ; contains valid data
CC_WaS_FlagInactive       = $01                     ; not used anymore
CC_WaS_FlagCollS_S        = $02                     ; sprite-sprite     collision happened
CC_WaS_FlagCollS_B        = $04                     ; sprite-background collision happened
CC_WaS_Flag08             = $08                     ; 
CC_WaS_FlagAction         = $10                     ; pending action
CC_WaS_FlagDeath          = $20                     ; 
CC_WaS_FlagDead           = $40                     ; mortal sprites death mark
CC_WaS_FlagInit           = $80                     ; 
CC_WaS_SpriteType       = CC_WaS_Common + $01       ; 00=Player 01=Spark 02=Force 03=Mummy 04=Beam 05=Frank
CC_WaS_SpritePlayer       = $00                     ; 
CC_WaS_SpriteSpark        = $01                     ; 
CC_WaS_SpriteForce        = $02                     ; 
CC_WaS_SpriteMummy        = $03                     ; 
CC_WaS_SpriteBeam         = $04                     ; 
CC_WaS_SpriteFrank        = $05                     ; 
CC_WaS_SpritePosX       = CC_WaS_Common + $02       ; 
CC_WaS_SpritePosY       = CC_WaS_Common + $03       ; 
CC_WaS_SpriteNo         = CC_WaS_Common + $04       ; 
CC_WaS_SpriteSeqOld     = CC_WaS_Common + $05       ; old sequence number before death
CC_WaS_SpriteSeqNo      = CC_WaS_Common + $06       ; sprite sequence number
CC_WaS_SpriteDeath      = CC_WaS_Common + $08       ; modifies the death tune
CC_WaS_SpriteAttrib     = CC_WaS_Common + $09       ; Bit7: X-expand Bit6: Y-expand Bit5: Spr/BG-Prio Bit4: MultiColor Bits3-0: Color 0
CC_WaS_AttribColor        = CC_SpriteLookMultiC     ; from sprite data definitions
CC_WaS_AttribPrioBG       = CC_SpriteLookPrioBG     ; 
CC_WaS_AttribExpandY      = CC_SpriteLookXpandY     ; 
CC_WaS_AttribExpandX      = CC_SpriteLookXpandX     ; 
CC_WaS_AttribColors       = CC_SpriteLookColors     ; 
CC_WaS_SpriteCols       = CC_WaS_Common + $0a       ; 
CC_WaS_SpriteRows       = CC_WaS_Common + $0b       ; 
CC_WaS_SpriteStepX      = CC_WaS_Common + $0c       ; next PosX
CC_WaS_SpriteStepY      = CC_WaS_Common + $0d       ; next PosY
CC_WaS_PlayerFire       = CC_WaS_Common + $0e       ; .hbu019. - quick fire button to fire the ray gun
CC_WaS_MummyCollLeft    = CC_WaS_Common + $10       ; .hbu004. - avoid mummies piling up
CC_WaS_MummyCollYes       = $ff                     ; .hbu004.
CC_WaS_MummyCollNo        = $00                     ; .hbu004.
CC_WaS_MummyCollRight   = CC_WaS_Common + $11       ; .hbu004.
CC_WaS_MummyCollWalk    = CC_WaS_Common + $12       ; .hbu004. - speed adjustment store
CC_WaS_StoreToCtrlVal   = CC_WaS_Common + $18       ; value inserted into Move Ctrl Screen ($ef $fe)
CC_WaS_SpriteWrk        = CC_WaS_Common + $19       ; copy of CC_WaS_SpriteObj which is set to $ff
CC_WaS_SpriteObj        = CC_WaS_Common + $1a       ; 
CC_WaS_PlayerRoomIOB    = CC_WaS_Common + $1b       ; offset TabPlayerRoomIO block
CC_WaS_PlayerSpriteNo   = CC_WaS_Common + $1c       ; 
CC_WaS_SpriteMoveDir    = CC_WaS_Common + $1d       ; Player/Frank moves
CC_WaS_JoyNoMove          = $80                     ; 
CC_WaS_JoyMoveU           = $00                     ; ....
CC_WaS_JoyMoveUR          = $01                     ; ...#
CC_WaS_JoyMoveR           = $02                     ; ..#.
CC_WaS_JoyMoveDR          = $03                     ; ..##
CC_WaS_JoyMoveD           = $04                     ; .#..
CC_WaS_JoyMoveDL          = $05                     ; .#.#
CC_WaS_JoyMoveL           = $06                     ; .##.
CC_WaS_JoyMoveUL          = $07                     ; .###
CC_WaS_SpriteFireNo       = $00                     ; 
CC_WaS_SpriteFire         = $01                     ; 
CC_WaS_MummyDataOff     = CC_WaS_Common + $1d       ; Mummy game data offset
CC_WaS_PlayerMoveDir    = CC_WaS_Common + $1e       ; Player: $00=up $02=right $04=down $06=left
CC_WaS_MoveUp             = $00                     ; ....
CC_WaS_MoveRight          = $02                     ; ..#.
CC_WaS_MoveDown           = $04                     ; .#..
CC_WaS_MoveLeft           = $06                     ; .##.
CC_WaS_ForceFieldMode   = CC_WaS_Common + $1e       ; Force: $00= $01=
CC_WaS_ForceClose         = $00                     ; 
CC_WaS_ForceOpen        = $01                       ; 
CC_WaS_EnemyStatus      = CC_WaS_Common + $1e       ; Mummy/Frank: $00=in $01=out $04=dead
CC_WaS_MummyIn            = $00                     ;           / Frank Coffin Point Right
CC_WaS_MummyOut           = $01                     ; Mummy out / Frank Coffin Point Left
CC_WaS_FrankAwake         = $02                     ; Frank awake
CC_WaS_MummyKilled        = $03                     ; Mummy dead
CC_WaS_FrankKilled        = $04                     ; Frank dead
CC_WaS_BeamWaOff        = CC_WaS_Common + $1e       ; Ray Gun: Pointer to Gun ObjStWA
CC_WaS_Work             = CC_WaS_Common + $1f       ; Work field: diffierent content - no $00-$07/game data offset/...
; ------------------------------------------------------------------------------------------------------------- ;
