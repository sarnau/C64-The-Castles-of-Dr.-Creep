; ------------------------------------------------------------------------------------------------------------- ;
; The Castles of Dr Creep - Work Areas
; ------------------------------------------------------------------------------------------------------------- ;
; Sprite and Object Work Areas
; ------------------------------------------------------------------------------------------------------------- ;
CC_WAStartAdr    = $bd00
;
CC_ObjWALen      = $08
CC_SprWALen      = $20
;
CC_ObjWAMax      = $20
CC_SprWAMax      = $08
;
CC_WASprtBlock   = CC_WAStartAdr   + $000   ; sprites       - max $08 blocks of $20 bytes
CC_WAObjsStatus  = CC_WAStartAdr   + $100   ; object status - max $20 blocks of $08 bytes
CC_WAObjsBlock   = CC_WAStartAdr   + $200   ; object shape  - max $20 blocks of $08 bytes
; ------------------------------------------------------------------------------------------------------------- ;
; Sprite Header
; ------------------------------------------------------------------------------------------------------------- ;
CC_SpriteCols   = $00
CC_SpriteRows   = $01
CC_SpriteAttr   = $02                       ; Bit7: X-expand Bit6: Y-expand Bit5: Spr/BG-Prio Bit4: MultiColor Bits3-0: Color 0
CC_SpriteXpandX   = $80
CC_SpriteXpandY   = $40
CC_SpriteXPrioB   = $20
CC_SpriteMultiC   = $10
CC_SpriteColor    = $0f
CC_SpriteData   = $03
; ------------------------------------------------------------------------------------------------------------- ;
; Object Status Work Area Maps - max $20 blocks of $08 bytes
; ------------------------------------------------------------------------------------------------------------- ;
CC_ObjStDoNo     = CC_WAObjsStatus + $00    ; Door
CC_ObjStDoFlag   = CC_WAObjsStatus + $01
CC_ObjDoorShut     = $00
CC_ObjDoorOpen     = $01
CC_ObjStDoLift   = CC_WAObjsStatus + $02    ; gate lifting process counter
CC_ObjStDoTColor = CC_WAObjsStatus + $03    ; target romms color
; ------------------------------------------------------------------------------------------------------------- ;
CC_ObjStBeDoorNo = CC_WAObjsStatus + $00    ; DoorBell
; ------------------------------------------------------------------------------------------------------------- ;
CC_ObjStLMBallNo = CC_WAObjsStatus + $00    ; LightningMachine
CC_ObjBallNoUse    = $ff
CC_ObjBall00       = $00 * CC_ObjWALen ; $00
CC_ObjBall01       = $01 * CC_ObjWALen ; $08
CC_ObjBall02       = $02 * CC_ObjWALen ; $10
CC_ObjBall03       = $03 * CC_ObjWALen ; $18
CC_ObjBall04       = $04 * CC_ObjWALen ; $20
CC_ObjBall05       = $05 * CC_ObjWALen ; $28
CC_ObjBall06       = $06 * CC_ObjWALen ; $30
CC_ObjBall07       = $07 * CC_ObjWALen ; $38
CC_ObjBall08       = $08 * CC_ObjWALen ; $40
CC_ObjBall09       = $09 * CC_ObjWALen ; $48
CC_ObjBall0a       = $0a * CC_ObjWALen ; $50
CC_ObjBall0b       = $0b * CC_ObjWALen ; $58
CC_ObjBall0c       = $0c * CC_ObjWALen ; $60
CC_ObjBall0d       = $0d * CC_ObjWALen ; $68
CC_ObjBall0e       = $0e * CC_ObjWALen ; $70
CC_ObjBall0f       = $0f * CC_ObjWALen ; $78
CC_ObjStLMModeBa = CC_WAObjsStatus + $01    ; $00 $01
CC_ObjModeOff      = $00
CC_ObjModeOn       = $01
CC_ObjStLMMotion = CC_WAObjsStatus + $02    ; $00 $01 $02
CC_ObjMotion00     = $00
CC_ObjMotion01     = $01
CC_ObjMotion02     = $02
CC_ObjStLMPoleLe = CC_WAObjsStatus + $03    ; 
; ------------------------------------------------------------------------------------------------------------- ;
CC_ObjStFoNo     = CC_WAObjsStatus + $00    ; ForceField
CC_ObjStFoSecond = CC_WAObjsStatus + $01    ; $1e - time between two pings
CC_ObjStFoTimer  = CC_WAObjsStatus + $02    ; 
CC_FoTimerStart    = $08
; ------------------------------------------------------------------------------------------------------------- ;
CC_ObjStMuPtrWA  = CC_WAObjsStatus + $00    ; Mummy
CC_ObjStMuTimer  = CC_WAObjsStatus + $01    ; 
CC_MuTimerStart    = $08
CC_ObjStMuAColor = CC_WAObjsStatus + $02    ; color of ankh
; ------------------------------------------------------------------------------------------------------------- ;
CC_ObjStKeData   = CC_WAObjsStatus + $00    ; Key
; ------------------------------------------------------------------------------------------------------------- ;
CC_ObjStLoColor  = CC_WAObjsStatus + $00    ; Lock
CC_ObjStLoDoorNo = CC_WAObjsStatus + $01    ; 
; ------------------------------------------------------------------------------------------------------------- ;
CC_ObjStGuPtrWA  = CC_WAObjsStatus + $00    ; RayGun
CC_ObjStGuBoP    = CC_WAObjsStatus + $01    ; bottom of pole
; ------------------------------------------------------------------------------------------------------------- ;
CC_ObjStMaDPtrHi = CC_WAObjsStatus + $00    ; MatterTransmitter
CC_ObjStMaDPtrLo = CC_WAObjsStatus + $01    ; 
CC_ObjStMaColor  = CC_WAObjsStatus + $02    ; 
CC_ObjStMaTimer  = CC_WAObjsStatus + $03    ; 
CC_MaTimerStart    = $08
CC_ObjStMaOvalX  = CC_WAObjsStatus + $04    ; target oval
CC_ObjStMaOvalY  = CC_WAObjsStatus + $05    ; 
; ------------------------------------------------------------------------------------------------------------- ;
CC_ObjStTrOffDat = CC_WAObjsStatus + $00    ; TrapDoor - offset next trap door data
CC_ObjStTrStatus = CC_WAObjsStatus + $01    ; 
CC_TrClosed        = $00
CC_TrOpen          = $01
CC_ObjStTrObjNo  = CC_WAObjsStatus + $02    ; 
; ------------------------------------------------------------------------------------------------------------- ;
CC_ObjStMWOffDat = CC_WAObjsStatus + $00    ; MovingSideWalk
; ------------------------------------------------------------------------------------------------------------- ;
; Object Dynamic Work Area Map - max $20 blocks of $08 bytes
; ------------------------------------------------------------------------------------------------------------- ;
CC_WAObjsType    = CC_WAObjsBlock + $00
CC_ObjDoor         = $00                    ; Door
CC_ObjBell         = $01                    ; DoorBell
CC_ObjLightBall    = $02                    ; LightningMachine Ball
CC_ObjLightCtrl    = $03                    ; LightningMachine Control
CC_ObjForce        = $04                    ; ForceField
CC_ObjMummy        = $05                    ; Mummy
CC_ObjKey          = $06                    ; Key
CC_ObjLock         = $07                    ; Lock
CC_ObjGun          = $08                    ; RayGun Phaser
CC_ObjGunCtrl      = $09                    ; RayGun Control
CC_ObjMatRecOval   = $0a                    ; MatterTransmitter Receiver Oval
CC_ObjTrapDoor     = $0b                    ; TrapDoor
CC_ObjTrapCtrl     = $0c                    ; TrapDoor Control
CC_ObjWalkWay      = $0d                    ; WalkWay
CC_ObjWalkCtrl     = $0e                    ; WalkWay Control
CC_ObjFrank        = $0f                    ; Frankenstein
CC_WAObjsPosX    = CC_WAObjsBlock + $01
CC_WAObjsPosY    = CC_WAObjsBlock + $02
CC_WAObjsNo      = CC_WAObjsBlock + $03
CC_WAObjsFlag    = CC_WAObjsBlock + $04     ; $20=move  $40=action_completed  $80=just_initialized
CC_WAObjsMove      = $20
CC_WAObjsReady     = $40
CC_WAObjsInit      = $80
CC_WAObjsCols    = CC_WAObjsBlock + $05     ; multipied by 4
CC_WAObjsRows    = CC_WAObjsBlock + $06
; ------------------------------------------------------------------------------------------------------------- ;
; Sprite Work Area - max $08 blocks of $20 bytes
; ------------------------------------------------------------------------------------------------------------- ;
CC_WASprtType    = CC_WASprtBlock + $00     ; 00=Player 01=Spark 02=Force 03=Mummy 04=Beam 05=Frank
CC_SprPlayer       = $00
CC_SprSpark        = $01
CC_SprForce        = $02
CC_SprMummy        = $03
CC_SprBeam         = $04
CC_SprFrank        = $05
CC_WASprtPosX    = CC_WASprtBlock + $01     ;
CC_WASprtPosY    = CC_WASprtBlock + $02     ;
CC_WASprtImgNo   = CC_WASprtBlock + $03     ;
CC_WASprtFlag    = CC_WASprtBlock + $04     ; 00=active 01=inactive 02=coll_sprt/sprt 04=coll_sprt/bkgr 80=initialized
CC_WASprActive     = $00                    ; contains valid data
CC_WASprInActive   = $01                    ; wa not used anymore
CC_WASprCollS_S    = $02                    ; sprite-sprite     collision happened
CC_WASprCollS_B    = $04                    ; sprite-background collision happened
CC_WASpr08         = $08                    ; 
CC_WASprAction     = $10                    ; ongoing action
CC_WASpr20         = $20
CC_WASprDeath      = $40                    ; mortal sprites death mark
CC_WASprInit       = $80
CC_WASprtOldNo   = CC_WASprtBlock + $05     ; old sequence number before death
CC_WASprtSeqNo   = CC_WASprtBlock + $06     ; sprite sequence number
CC_WASprDeathSnd = CC_WASprtBlock + $08     ; modifies the death tune
CC_WASprtAttr    = CC_WASprtBlock + $09     ; Bit7: X-expand Bit6: Y-expand Bit5: Spr/BG-Prio Bit4: MultiColor Bits3-0: Color 0
CC_WASprColor      = $0F
CC_WASprMColor     = $10
CC_WASprPrioBG     = $20
CC_WASprExpandY    = $40
CC_WASprExpandX    = $80
CC_WASprtCols    = CC_WASprtBlock + $0a     ;
CC_WASprtRows    = CC_WASprtBlock + $0b     ;
CC_WASprtStepX   = CC_WASprtBlock + $0c     ; next PosX
CC_WASprtStepY   = CC_WASprtBlock + $0d     ; next PosY
CC_WASprtCtrlSV  = CC_WASprtBlock + $18     ; value inserted into Move Ctrl Screen ($ef $fe)
CC_WASprtWrkWA   = CC_WASprtBlock + $19     ; copy of CC_WASprtObjWA which is set to $ff
CC_WASprtObjWA   = CC_WASprtBlock + $1a     ;
CC_WASprtRoomIOB = CC_WASprtBlock + $1b     ; offset TabPlayerRoomIO block
CC_WASprtPlayrNo = CC_WASprtBlock + $1c     ; 
CC_WASprtJoyActn = CC_WASprtBlock + $1d     ;
CC_WASprtNoFire    = $00
CC_WASprtFire      = $01
CC_WASprtDataOff = CC_WASprtBlock + $1d     ; Mummy game data offset
CC_WASprtDirMove = CC_WASprtBlock + $1e     ; Player: $00=up $02=right $04=down $06=left
CC_WASprtUp        = $00                    ; ....
CC_WASprtRight     = $02                    ; ..#.
CC_WASprtDown      = $04                    ; .#..
CC_WASprtLeft      = $06                    ; .##.
CC_WASprtPassage = CC_WASprtBlock + $1e     ; Force: $00= $01=
CC_WASprtClose     = $00                    ; 
CC_WASprtOpen      = $01                    ; 
CC_WASprtStatus  = CC_WASprtBlock + $1e     ; Mummy/Frank: $00=in $01=out $04=dead
CC_WASprtIn        = $00                    ;           / Frank Coffin Point Right
CC_WASprtOut       = $01                    ; Mummy out / Frank Coffin Point Left
CC_WASprtAwake     = $02                    ; Frank awake
CC_WASprtDead      = $03                    ; Mummy dead
CC_WASprtGone      = $04                    ; Frank dead
CC_WASprtOffWA   = CC_WASprtBlock + $1e     ; Ray Gun: Pointer to Gun ObjStWA
CC_WASprtWork    = CC_WASprtBlock + $1f     ; Work field: diffierent content - no $00-$07/game data offset/...
CC_WASprtNumWA   = CC_WASprtBlock + $1f     ; $00-$07  $80=not used
; ------------------------------------------------------------------------------------------------------------- ;
