; ------------------------------------------------------------------------------------------------------------- ;
; The Castles of Dr Creep - OBJECT.PRG
; ------------------------------------------------------------------------------------------------------------- ;
; Memory Map
; ------------------------------------------------------------------------------------------------------------- ;
; $0000 - $00ff:  Zero Page Values
; $0200 - $02ff:  Work Values and C64 system
; $0300 - $03ff:  Work Values and C64 system
; $0400 - $07e8:  Video Screen 1 - Displays Game Options and Castle Load File Names
; 
; $0800 - $77ff:  Loaded Game Code
; 
; $6400 - $64ff:  Best Times
; $6500 - $65ff:  Row Control Data for Game Options and Castle Load Screen
; $6600 - $66ff:  Pointer HiRes Screen Rows: Low
; $6700 - $67ff:  Pointer HiRes Screen Rows: High
;
; $6800 - $87ff:  Loaded Level Data - Area from 'StoreRoomData' on will be overwritten by a copy of the actual room
; 
; $8800 - $8bff:  Maps Sprite Data - Arrows
; $8c00 - $8fe8:  Video Screen 1 - Holds Color Values for Maps Multicolour HiRes Screen
; $9000 - $9cff:  Objects Data   - no VIC possible from $9000-$9fff
; $9d00 - $9dff:  Work Areas: Sprites         data - max $08 blocks of $20 bytes
; $9e00 - $9eff:  Work Areas: Objects special data - max $20 blocks of $08 bytes
; $9f00 - $9fff:  Work Areas: Objects common  data - max $20 blocks of $08 bytes
; $a000 - $bfff:  HiRes Screen 1 - Holds Maps Multicolour Data
; 
; $a000 - $bfff:  Demo Music
;
; $c000 - $c7ff:  Sprite Move Control Screen
; $c800 - $cbff:  Rooms Sprite Data - All but Arrows
; $cc00 - $cfe8:  Video Screen 2 - Holds Color Values for Room Multicolour HiRes Screen
; $cff8 - $cfff:  Sprites Data Pointer
; $e000 - $ffff:  HiRes Screen 2 - Holds Rooms Multicolour Data
; 
; $fffa - $fffb:  Vector: NMI
; $fffc - $fffd:  Vector: System Reset <not set>
; $fffe - $ffff:  Vector: IRQ
; ------------------------------------------------------------------------------------------------------------- ;
                    * equ $0800                     ; Start address
; ------------------------------------------------------------------------------------------------------------- ;
; compiler settings                                                                                             ;
; ------------------------------------------------------------------------------------------------------------- ;
                    incdir  ..\..\..\..\inc         ; C64 System Includes
                    
C64CIA1             include cia1.asm                ; Complex Interface Adapter (CIA) #1 Registers  $DC00-$DC0F
C64CIA2             include cia2.asm                ; Complex Interface Adapter (CIA) #2 Registers  $DD00-$DD0F
C64SID              include sid.asm                 ; Sound Interface Device (SID) Registers        $D400-$D41C
C64VicII            include vic.asm                 ; Video Interface Chip (VIC-II) Registers       $D000-$D02E
C64Kernel           include kernel.asm              ; Kernel Vectors
C64Colors           include color.asm               ; Colour RAM Address / Colours
C64Memory           include mem.asm                 ; Memory Layout
                    
Game                include inc\CC_VarsGame.asm     ; Game Variables
Level               include inc\CC_VarsLevel.asm    ; Level Variables / Music Variables / Best Times Mapping
Working             include inc\CC_VarsWork.asm     ; Work  Variables
ZeroPage            include inc\CC_Zpg.asm          ; Zero Page Addresses - cannot be used directly with C64ASM
WorkAreas           include inc\CC_WorkAreas.asm    ; Work Areas Mapping
ObjectMaps          include inc\CC_Objects.asm      ; Level Objects Mapping
; ------------------------------------------------------------------------------------------------------------- ;
EntryPoint          jmp ColdStart                   ; Entry Point
; ------------------------------------------------------------------------------------------------------------- ;
; ID_Jump_Table     Dispatched from: PaintRoomItems
; ------------------------------------------------------------------------------------------------------------- ;
ID_Jump_Table       equ *                           ;
ID_Door             jmp RoomDoor                    ; Door
ID_Floor            jmp RoomFloor                   ; Floor
ID_Pole             jmp RoomPole                    ; Sliding Pole
ID_Ladder           jmp RoomLadder                  ; Ladder
ID_DoorBell         jmp RoomDoorBell                ; Door Bell
ID_LightMachine     jmp RoomLightMachine            ; Lightning Machine
ID_ForceField       jmp RoomForceField              ; Force Field
ID_Mummy            jmp RoomMummy                   ; Mummy
ID_Key              jmp RoomKey                     ; Key
ID_Lock             jmp RoomLock                    ; Lock
ID_Object           jmp RoomDrawObject              ; Draw Object - never used in castle data
ID_RayGun           jmp RoomRayGun                  ; Ray Gun
ID_MatterXmitter    jmp RoomMatterXmit              ; Matter Transmitter
ID_TrapDoor         jmp RoomTrapDoor                ; Trap Door
ID_SideWalk         jmp RoomSideWalk                ; Moving Side Walk
ID_FrankenStein     jmp RoomFrankenStein            ; Frankenstein
ID_TextLine         jmp RoomTextLine                ; Text Line
ID_Graphic          jmp RoomGraphic                 ; Graphic
; ------------------------------------------------------------------------------------------------------------- ;
; Action address list:  1st entry moves each object automatically
;                       2st entry moves each object after player action
; ------------------------------------------------------------------------------------------------------------- ;
ObjectMoveAuto      dc.w AutoDoorOpen               ; Object Type $00: Door
ObjectMoveManu      dc.w ManuDoorLeave              ; 
                    
                    dc.w $0000                      ; Object Type $01: Door Bell
                    dc.w ManuBellPress              ; 
                    
                    dc.w AutoLightPole              ; Object Type $02: Lightning Machine Ball
                    dc.w $0000                      ; 
                    
                    dc.w $0000                      ; Object Type $03: Lightning Machine Switch
                    dc.w ManuLightSwitch            ; 
                    
                    dc.w AutoForceClose             ; Object Type $04: Force Field
                    dc.w ManuForceSwitch            ; 
                    
                    dc.w AutoAnkhFlash              ; Object Type $05: Mummy
                    dc.w ManuMummyBirth             ; 
                    
                    dc.w $0000                      ; Object Type $06: Key
                    dc.w ManuKeyPick                ; 
                    
                    dc.w $0000                      ; Object Type $07: Lock
                    dc.w ManuLockOpen               ; 
                    
                    dc.w AutoRayGunAim              ; Object Type $08: Ray Gun
                    dc.w $0000
                    
                    dc.w $0000                      ; Object Type $09: Ray Gun Switch
                    dc.w ManuRayGunSwitch           ; 
                    
                    dc.w AutoMatterTarget           ; Object Type $0a: Matter Transmitter Reciever Oval
                    dc.w ManuMatterBooth            ; flicker receiver oval
                    
                    dc.w AutoTrapDoorOpen           ; Object Type $0b: Trap Door
                    dc.w $0000
                    
                    dc.w $0000                      ; Object Type $0c: Trap Door Switch
                    dc.w $0000
                    
                    dc.w AutoSideWalkMove           ; Object Type $0d: Side Walk
                    dc.w ManuSideWalkPace           ; adjust players move speed
                    
                    dc.w $0000                      ; Object Type $0e: Side Walk Switch
                    dc.w ManuSideWalkSwitch         ; 
                    
                    dc.w $0000                      ; Object Type $0f: Frankenstein
                    dc.w $0000
; ------------------------------------------------------------------------------------------------------------- ;
SpriteMove          dc.w MovePlayerSprite           ; Sprite Type $00: Player
SpriteSpriteKill    dc.w KillPlayerSprt             ; Sprite Type $00: Player
SpriteObjectKill    dc.w KillPlayerTrap             ; Sprite Type $00: Player
SpriteCollisionPrio dc.b $00                        ; Flag: $00-low - $00=Player $00=Frank $02=Mummy $03=Force $04=Spark  $04=Beam
SpriteMortality     dc.b SpriteMortal               ; Flag: Mortals - 1=Player/Mummy/Frank
SpriteMortal          = $01
SpriteImmortal        = $00
                    
                    dc.w MoveSparkSprite            ; Sprite Type $01: Lightning Machine
                    dc.w KillSparkSprite            ; Sprite Type $01: Lightning Machine
                    dc.w $0000                      ; 
                    dc.b $04                        ; Flag: Collision priority $00-low 
                    dc.b SpriteImmortal             ; Flag: Immortals - 0=Light/Force/Gun
                    
                    dc.w MoveForceSprite            ; Sprite Type $02: Force Field
                    dc.w KillForceSprite            ; Sprite Type $02: Force Field
                    dc.w $0000                      ; 
                    dc.b $03                        ; Flag: Collision priority $00-low 
                    dc.b SpriteImmortal             ; Flag: Immortals - 0=Light/Force/Gun
                    
                    dc.w MoveMummySprite            ; Sprite Type $03: Mummy
                    dc.w KillMummySprite            ; Sprite Type $03: Mummy
                    dc.w KillMummyTrap              ; Sprite Type $03: Mummy
                    dc.b $02                        ; Flag: Collision priority $00-low 
                    dc.b SpriteMortal               ; Flag: Mortals - 1=Player/Mummy/Frank
                    
                    dc.w MoveBeamSprite             ; Sprite Type $04: Ray Gun Beam
                    dc.w $0000                      ; 
                    dc.w KillBeamOnObject           ; Sprite Type $04: Ray Gun Beam
                    dc.b $04                        ; Flag: Collision priority $00-low 
                    dc.b SpriteImmortal             ; Flag: Immortals - 0=Light/Force/Gun
                    
                    dc.w MoveFrankSprite            ; Sprite Type $05: Frank N Forter
                    dc.w KillFrankSprite            ; Sprite Type $05: Frank N Forter
                    dc.w KillFrankTrap              ; Sprite Type $05: Frank N Forter
                    dc.b $00                        ; Flag: Collision priority $00-low 
                    dc.b SpriteMortal               ; Flag: Mortals - 1=Player/Mummy/Frank
                    
                    dc.b $80                        ; EndOfJumpTab / TabValues
; ------------------------------------------------------------------------------------------------------------- ;
MainLoop            subroutine                      ; 
                    jsr DemoHandler                 ; 
                    jsr GameHandler                 ; 
                    jmp MainLoop                    ; 
; ------------------------------------------------------------------------------------------------------------- ;
; DemoHandler       Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
DemoHandler         subroutine
                    lda #CCZ_SwitchesOff            ; .hbu015.
                    sta CCZ_RestoreColor            ; .hbu015.
                    
.CastleReload       jsr LoadCastleData              ; .hbu012. - reload because no copy available any longer
                    
.RunDemoI           lda #$00                        ; 
                    sta CCW_DemoNextSong            ; 
                    sta CCW_DemoJoyFire             ; 
                    
                    lda #CCW_DemoShowTitleMax       ; 
                    sta CCW_DemoShowTitle           ; show room counter - title screen after every 03 rooms
                    
                    lda #CCW_DemoYes                ; 
                    sta CCW_DemoFlag                ; 
                    
                    lda #CCW_DemoRoomInit           ; start demo with room one
                    sta CCW_DemoRoomNo              ; 
                    
.RunDemo            inc CCW_DemoShowTitle           ; show room counter
                    lda CCW_DemoShowTitle           ; show room counter
                    and #CCW_DemoShowTitleMax       ; isolate count bits
                    sta CCW_DemoShowTitle           ; show room counter
                    beq .GoPaintTitleScreen         ; show title screen at start and after every third room
                    
                    inc CCW_DemoRoomNo              ; 
                    
                    lda CCW_DemoRoomNo              ; 
                    jsr SetRoomDataPtr              ; 
                    
                    ldy #CC_Obj_RoomColor           ; color offset
                    lda (CCZ_RoomData),y            ; 
                    and #CC_Obj_RoomEoData          ;
                    beq .PaintRoom                  ; no
                    
                    lda #CCW_DemoRoomStart          ; 
                    sta CCW_DemoRoomNo              ; restart at first room
                    
.PaintRoom          jsr PaintRoom                   ; 
                    jmp .ScreenOn                   ; switch screen on again
                    
.GoPaintTitleScreen jsr PaintTitleScreen            ;
                    
.ScreenOn           jsr SwitchScreenOn              ; 
                    
.ChkDemoTune        lda CCW_Tune2PlayDemo           ; 
                    cmp #CCW_Tune2PlayDemoYes       ; 
                    beq .GetTitleWaitTime           ; 
                    
                    lda CCW_DemoShowTitle           ; 
                    bne .GetTitleWaitTime           ; 
                    
                    lda CCW_DemoNextSong            ; 
                    bne .SetNextSongNo              ; 
                    
                    inc CCW_DemoNextSong            ; next time load another demo melody
                    
.GetTitleWaitTime   lda #CCW_DemoTitleTimeInit      ; 
.SetTitleWaitTime   sta CCW_DemoTitleTime           ; 
                    
.ChkTitle           lda CCW_DemoShowTitle           ; 
                    beq .WaitIRQs                   ; 
                    
                    jsr ActionHandler               ; show room actions
                    jmp .ResetJoyFire               ; .hbu019.
                    
.WaitIRQs           lda CCW_CountIRQs               ; counted down to $00 with every IRQ
                    bne .WaitIRQs                   ; 
                    
                    lda #CCW_CountIRQsGame          ; 
                    sta CCW_CountIRQs               ; reeinit to default
                    
.ResetJoyFire       lda #$00                        ; .hbu019.
                    sta CCW_JoyGotFire              ; .hbu019.
                    
.GetKeyJoyVal       lda CCW_DemoJoyFire             ; joystick port
                    jsr GetKeyJoyVal                ; 
                    
.ChkJoyFire         lda CCW_JoyGotFire              ; 
                    beq .SetJoyNext                 ; 0=not pressed
                    
.GoExitDemoOnFire   jmp .ExitDemoOnFire             ; 1=FIRE
                    
.SetJoyNext         lda CCW_DemoJoyFire             ; 
                    eor #$01                        ; 
                    sta CCW_DemoJoyFire             ; 
                    
.ChkKeyStop         lda CCW_KeyGotStop              ; 
                    cmp #CCW_KeyGotYes              ; 
                    beq .GoLoadOptionScreen         ; 
                    
                    dec CCW_DemoTitleTime           ; 
                    bne .ChkTitle                   ; 
                    
                    jmp .RunDemo                    ; show next room
                    
.GoLoadOptionScreen jsr TextScreenHandler           ; set options / load castle data screen handler
                    
                    lda CCW_DiskAccess              ; 
                    cmp #CCW_DiskAccessOk           ; game resumeded successfully
                    beq .GoExitDemoOnFire           ; 
                    
                    jmp .RunDemoI                   ; reinit demo and start again
                    
.SetNextSongNo      inc TabDemoMusicFileNo          ; number of demo music file name
                    ldx #CCW_DemoMusicFileLen       ; 
                    stx CCW_DiskFileNameLen         ; 
.CopySongName       dex                             ; 
                    bmi .SetSongLoadAdr             ; 
                    
                    lda TabDemoMusicFile,x          ; demo music file name
                    sta CCW_DiskFileNameId,x        ; 
                    jmp .CopySongName               ; 
                    
.SetSongLoadAdr     lda #CC_LevelMusicID            ; 
                    sta CCW_DiskFileTargetId        ; 
                    
                    jsr PrepareIO                   ; 
.SongLoadRetry      jsr LoadLevelData               ; 
                    jsr READST                      ; KERNEL - $FFB7 = read I/O status word
                    
                    cmp #$40                        ; EndOfData input file
                    beq .GoWaitRestart              ; load was ok
                    
                    lda TabDemoMusicFileNo          ; 
                    cmp #CCW_DemoMusicFileNoInit    ; 
                    beq .SongLoadBad                ; even first load failed
                    
                    lda #CCW_DemoMusicFileNoInit    ; maybe because maximum passed - reinit
                    sta TabDemoMusicFileNo          ; 
                    sta CCW_DiskFileMusicNo         ; 
                    jmp .SongLoadRetry              ; try the first one again
                    
.SongLoadBad        lda #$09 * $04                  ; TabTune2PlayCopyLen pos $09
                    sta CCL_MusicDataStart          ; 
                    
.GoWaitRestart      jsr WarmStart                   ; 
                    
                    lda #<CCL_MusicDataStart        ; start adress loaded music data
                    sta CCZ_SoundDataLo             ; 
                    lda #>CCL_MusicDataStart        ; 
                    sta CCZ_SoundDataHi             ; 
                    jsr InitTuneVoices              ; 
                    
                    lda TabSidRes                   ; 
                    and #$f0                        ; ####....
                    sta RESON                       ; SID - $D417 = Filter Resonance Control
                    sta TabSidRes                   ; 
                    
                    lda #$00                        ; 
                    sta CCW_Tune2PlayCtrlCut2       ; 
                    sta CCW_Tune2PlayCtrlCut3       ; 
                    
                    lda #CCW_Tune2PlayTimeInit      ; ...#.#..
                    sta CCW_Tune2PlayTime           ; 
                    asl a                           ; ..#.#...
                    asl a                           ; .#.#....
                    ora #$03                        ; .#.#..##
                    sta TIMAHI                      ; CIA 1 - $DC05 = Timer A (high byte)
                    
                    lda #CCW_Tune2PlayDemoYes       ; on
                    sta CCW_Tune2PlayDemo           ; 
                    
                    lda #$81                        ; #......# - care or did Timer A count down to 0
                    sta CIAICR                      ; CIA 1 - $DC0D = Interrupt Control
                    lda #$01                        ; .......#
                    sta CIACRA                      ; CIA 1 - $DC0E = Control A
                    
                    lda #CCW_DemoTitleTimeInit - $10; reduced wait
                    jmp .SetTitleWaitTime           ; 
                    
.ExitDemoOnFire     lda #CCW_Tune2PlayDemoNo        ; off
                    sta CCW_Tune2PlayDemo           ; 
                    
                    lda #CCW_DemoNo                 ; 
                    sta CCW_DemoFlag                ; 
                    
                    lda #$00
                    sta CIACRA                      ; CIA 1 - $DC0E = Control A
                    
                    lda #$7f
                    sta CIAICR                      ; CIA 1 - $DC0D = Interrupt Control
                    lda CIAICR                      ; CIA 1 - $DC0D = Interrupt Control
                    
                    jsr InitTuneVoices              ; 
                    
                    jsr SwitchScreenOff             ; .hbu015.
DemoHandlerX        jmp InitHiResMap                ; initialize the hires map screen and sprite work area
; ------------------------------------------------------------------------------------------------------------- ;
; GameHandler       Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
GameHandler         subroutine
                    lda CCW_DiskAccess              ; 
                    cmp #CCW_DiskAccessOk           ; castle loaded successfully
                    bne .SetPlayer2                 ; 
                    
                    lda #CCW_DiskAccessBad          ; 
                    sta CCW_DiskAccess              ; 
                    
                    lda CCL_Flag                    ; 
                    ora #CCL_Game                   ; 
                    sta CCL_Flag                    ; 
                    jmp .ChkP_Health                ; 
                    
.SetPlayer2         lda CCW_DemoJoyFire             ; 
                    sta CCL_Player2Active           ; player 2 pressed fire at start
                    
                    lda #$00                        ; 
                    ldy #CCL_PlayersTimesLen*2 + 1  ; for both players
.InitTime           sta CCL_PlayersTimes,y          ; 
                    dey                             ; 
                    bpl .InitTime                   ; 
                    
                    sta CCL_Player1Active           ; player 1 pressed fire at start
                    
                    sta CCL_Player1AtDoor           ; init start room/door to first entry in lists
                    sta CCL_Player2AtDoor           ; 
                    sta CCL_Player1KeysAmount       ; init amount of collected keys
                    sta CCL_Player2KeysAmount       ; 
                    
                    lda CCL_Player1StartRoomNo      ; count start: entry 00 of ROOM list
                    sta CCL_Player1TargetRoomNo     ; count start: entry 00 of ROOM list
                    lda CCL_Player2StartRoomNo      ; count start: entry 00 of ROOM list
                    sta CCL_Player2TargetRoomNo     ; count start: entry 00 of ROOM list
                    lda CCL_Player1StartDoorNo      ; count start: entry 00 of Room DOOR list
                    sta CCL_Player1TargetDoorNo     ; count start: entry 00 of Room DOOR list
                    lda CCL_Player2StartDoorNo      ; count start: entry 00 of Room DOOR list
                    sta CCL_Player2TargetDoorNo     ; count start: entry 00 of Room DOOR list
                    
                    lda #CCL_PlayersLivesMax        ; 
                    sta CCL_Player1NumLives         ; 
                    sta CCL_Player2NumLives         ; 
                    
                    lda #CCL_Alive                  ; 
                    sta CCL_Player1Health           ; 00=dead  01=alive
                    
                    lda CCL_Player2Active           ; player 2 pressed fire at start
                    cmp #CCL_In                     ; 
                    beq .MarkP2ALive                ; 
                    
.MarkP2Dead         lda #CCL_Dead                   ; 
                    sta CCL_Player2Health           ; 00=dead  01=alive
                    
                    lda #CCL_PlayerInactive         ; player 2 does not participate
                    sta CCL_Player2Status           ; 
                    jmp .ChkP_Health                ; 
                    
.MarkP2ALive        lda #CCL_Alive                  ; 
                    sta CCL_Player2Health           ; 00=dead  01=alive
                    
.ChkP_Health        lda CCL_Player1Health           ; loop - 00=dead  01=alive
                    cmp #CCL_Alive                  ; 
                    beq .ChkP1Alive01               ; 
                    
                    lda CCL_Player2Health           ; 00=dead  01=alive
                    cmp #CCL_Alive                  ; 
                    beq .ChkP1Alive01               ; 
                    
.AllPlayersDead     jmp .CastleReload               ; and exit
                    
.ChkP1Alive01       lda CCL_Player1Health           ; 00=dead  01=alive
                    cmp #CCL_Alive                  ; 
                    bne .ChkP1Alive02               ; 
                    
.ChkP2Alive         lda CCL_Player2Health           ; 00=dead  01=alive
                    cmp #CCL_Alive                  ; 
                    bne .ChkP1Alive02               ; 
                    
.ChkSameRoom        lda CCL_Player1TargetRoomNo     ; count start: entry 00 of ROOM list
                    cmp CCL_Player2TargetRoomNo     ; count start: entry 00 of ROOM list
                    bne .SetDiffRooms               ; 
                    
.SetSameRoom        lda #CCW_RoomEnterYes           ; both players enter the same room
                    sta CCW_RoomP1Enters            ; 
                    sta CCW_RoomP2Enters            ; 
                    jmp .HandleMapRooms             ; show map / handle rooms
                    
.SetDiffRooms       ldx CCL_Player1Active           ; both players enter different rooms
                    lda #CCW_RoomEnterNo            ; 
                    sta CCW_RoomP_Enters,x          ; 
                    txa                             ; 
                    eor #$01                        ; flip player
                    tax                             ; 
                    lda #CCW_RoomEnterYes           ; 
                    sta CCW_RoomP_Enters,x          ; 
                    jmp .HandleMapRooms             ; show map / handle rooms
                    
.ChkP1Alive02       lda CCL_Player1Health           ; 00=dead  01=alive
                    cmp #CCL_Alive                  ; 
                    beq .OnlyP1Enters               ; 
                    
.OnlyP2Enters       lda #CCW_RoomEnterYes           ; player one already dead
                    sta CCW_RoomP2Enters            ; 
                    lda #CCW_RoomEnterNo            ; 
                    sta CCW_RoomP1Enters            ; 
                    jmp .HandleMapRooms             ; show map / handle rooms
                    
.OnlyP1Enters       lda #CCW_RoomEnterYes           ; 
                    sta CCW_RoomP1Enters            ; 
                    lda #CCW_RoomEnterNo            ; 
                    sta CCW_RoomP2Enters            ; 
                    
.HandleMapRooms     jsr MapHandler                  ; 
                    jsr RoomHandler                 ; 
                    
                    jsr InitHiResSpriteWAs          ; initialize the hires screen and sprite work area
                    
                    lda #CCW_GameOverNo             ; 
                    sta CCW_GameOver                ; 
                    
                    ldx #$00                        ; player one
.HandlePlayers      lda CCW_RoomP_Enters,x          ; loop
                    cmp #CCW_RoomEnterYes           ; 
                    bne .SetNextPlayer              ; 
                    
.ChkP_Status        lda CCL_PlayersStatus,x         ; 
                    cmp #CCL_PlayerAccident         ; 
                    beq .ChkUnlimLives              ; 
                    
                    lda CCL_PlayersAtDoor,x         ; 
                    cmp #$01                        ; 
                    bne .SetNextPlayer              ; 
                    
                    stx CCW_EscapePlayerNo          ; 
                    jsr EscapeHandler               ; 
                    ldx CCW_EscapePlayerNo          ; 
                    
                    lda CCL_Flag                    ; 
                    and #CCL_Game                   ; 
                    bne .SetP_Dead                  ; 
                    
                    lda CCW_LoadCtrlUnlimLives      ; 
                    cmp #CCW_LoadCtrlLivesOnOff     ; 
                    beq .SetP_Dead                  ; 
                    
                    lda CCW_LoadCtrlTabOff          ; 
                    cmp #$ff                        ; 
                    beq .SetP_Dead                  ; 
                    
                    txa                             ; player number
                    asl a                           ; *2
                    asl a                           ; *4 - level time length
                    
                    clc                             ; 
                    adc #<CCL_PlayersTimes          ; 
                    sta CCZ_LevelTimeLo             ; 
                    lda #>CCL_PlayersTimes          ; 
                    adc #$00                        ; 
                    sta CCZ_LevelTimeHi             ; 
                    
                    ldy #CCL_PlayersTimesLen        ; 
.CpyCompareTime     lda (CCZ_LevelTime),y           ; 
                    sta CCW_CompareTime,y           ; 
                    dey                             ; 
                    bpl .CpyCompareTime             ; 
                    
                    stx CCW_BestTimePlayerNo        ; 
                    jsr NewBestTime                 ; 
                    
                    ldx CCW_BestTimePlayerNo        ; 
                    jmp .SetP_Dead                  ; 
                    
.ChkUnlimLives      lda CCW_LoadCtrlUnlimLives      ; 
                    cmp #CCW_LoadCtrlLivesOnOff     ; 
                    beq .GetSavedRoomNo             ; 
                    
.DecP_Lives         dec CCL_PlayersNumLives,x       ; 
                    lda CCL_PlayersNumLives,x       ; 
                    beq .SetP_Dead                  ; $00=dead
                    
.GetSavedRoomNo     lda CCL_PlayersSaveRoomNo,x     ; .hbu017. - restore target rooms for both players
                    sta CCL_PlayersTargetRoomNo,x   ; count start: entry 00 of ROOM list
.GetSavedDoorNo     lda CCL_PlayersSaveDoorNo,x     ; .hbu017. - restore target doors for both players
                    sta CCL_PlayersTargetDoorNo,x   ; count start: entry 00 of Room DOOR list
.GetKeyAmount       lda CCL_PlayersSaveKeyAmnt,x    ; .hbu017. - restore amount of collected keys
                    sta CCL_PlayersKeysAmount,x     ; 
                    jmp .SetNextPlayer              ; 
                    
.SetP_Dead          lda #CCL_Dead                   ; 
                    sta CCL_PlayersHealth,x         ; $00=dead  $01=alive
                    
.SetGameOver        lda #CCW_GameOverYes            ; 
                    sta CCW_GameOver                ; 
                    
.SetNextPlayer      inx                             ; player two
                    cpx #$02                        ; 
                    bcc .GoHandlePlayers            ; 
                    
                    lda CCW_GameOver                ; all active players gone
                    cmp #CCW_GameOverYes            ; 
                    bne .GoChkP_Health              ; 
                    
                    jsr InitHiResSpriteWAs          ; initialize the hires screen and sprite work area
                    
                    lda #<TextGameOver              ; 
                    sta CCZ_RoomItemLo              ; 
                    lda #>TextGameOver              ; 
                    sta CCZ_RoomItemHi              ; 
                    jsr RoomTextLine                ; 
                    
                    lda CCL_Player2Active           ; player 2 pressed fire at start
                    cmp #CCL_Out                    ; 
                    beq .SetScnVisible              ; 
                    
.ChkP1Alive03       lda CCL_Player1Health           ; 
                    cmp #CCL_Alive                  ; 
                    beq .ChkP2Alive01               ; 
                    
.GameOverP1         lda #<TextGameOverP1            ; 
                    sta CCZ_RoomItemLo              ; 
                    lda #>TextGameOverP1            ; 
                    sta CCZ_RoomItemHi              ; 
                    jsr RoomTextLine                ; 
                    
.ChkP2Alive01       lda CCL_Player2Health           ; 00=dead  01=alive
                    cmp #CCL_Alive                  ; 
                    beq .SetScnVisible              ; 
                    
.GameOverP2         lda #<TextGameOverP2            ; 
                    sta CCZ_RoomItemLo              ; 
                    lda #>TextGameOverP2            ; 
                    sta CCZ_RoomItemHi              ; 
                    jsr RoomTextLine                ; 
                    
.SetScnVisible      jsr SwitchScreenOn              ; 
                    
                    lda #$10                        ; dynamic wait time
                    jsr WaitSomeTime                ; 
                    
.GoChkP_Health      jmp .ChkP_Health                ; 
                    
.GoHandlePlayers    jmp .HandlePlayers              ; avoid branch too far errors
                    
.CastleReload       ldx CCW_LoadCtrlTabOff          ; .hbu012. - same level as before
GameHandlerX        rts                             ; 
; ------------------------------------------------------------------------------------------------------------- ;
; MapHandler        Function: Show Map screen and handle player room enter arrows
;                   Parms   : 
;                   Returns : 
;                   Id      : hbu016. - rewritten to handle a second map display screen and different player indicator colors
; ------------------------------------------------------------------------------------------------------------- ;
MapHandler          subroutine
.SetMapMode         lda #>CC_SpritePtrMapBase       ; .hbu015. - indicate map hires storage
                    sta ModSpriteData               ; .hbu015.
                    lda #>CC_ScreenBankDiff         ; .hbu015.
                    sta ModObjectData               ; .hbu015.
                    lda #>CC_ScreenMapColor         ; .hbu015.
                    sta ModObjectColor              ; .hbu015.

                    jsr RestoreColorRam             ; .hbu015.
                    
                    ldx #01                         ; player number
.ChkPlayer2Time     lda CCL_Player2Active           ; 
                    beq .SetPlayerNext              ; 
                    
.SetPlayersTime     txa                             ; 
                    asl a                           ; *2
                    asl a                           ; *4 - time entry length
                    clc                             ; 
                    adc #<CCL_PlayersTimes          ; 
                    sta CCZ_RoomItemLo              ; 
                    lda #$00                        ; 
                    adc #>CCL_PlayersTimes          ; 
                    sta CCZ_RoomItemHi              ; point to player1/2 castle escape times
                    
                    ldy #WHITE                      ; .hbu018 - light the life counter
                    sty ColObjTimeDataBestT1        ; .hbu018
                    sty ColObjTimeDataBestT2        ; .hbu018
                    
                    ldy CCL_PlayersNumLives,x       ; 
                    lda TabColorLiveCount,y         ; color according to livescount
                    tay
                    jsr FillObjTimeFrame            ; 
                    
                    clc                             ; 
                    lda TabMapP_TextGridCol,x       ; 
                    sta CCZ_PntObj00PrmGridCol      ; 
                    lda #CC_PlayersMapTxtGridRow    ; 
                    sta CCZ_PntObj00PrmGridRow      ; 
                    
                    lda #NoObjTime                  ; object: Time Frame
                    sta CCZ_PntObj00PrmNo           ; 
                    lda #CCZ_PntObjPrmType00        ; 
                    sta CCZ_PntObjPrmType           ;                     
.PaintPlayersTime   jsr PaintObject                 ; 
                    
.SetPlayerNext      dex                             ; 
                    bpl .SetPlayersTime             ; show the time for player 1 always
                    
.SwitchBank         lda #CC_ScreenBankIdMap         ; .hbu015. - force switch of VIC memory bank
                    sta CI2PRA                      ; .hbu015.
;                    sta CCZ_CIABankCtrl             ; .hbu015.
                    
.InitSpriteWAs      jsr InitAllSpriteWAs            ; .hbu015. - mark all WAs as useable
                    
                    lda #$00                        ; 
                    sta CCZ_SpritesEnab             ; .hbu015. - sprites off via interrupt - otherwise they still might be displayed
                    sta CCW_JoyGotFire              ; 
                    sta CCW_MapPlayerNo             ; 
                    
.NextPlayer         ldx CCW_MapPlayerNo             ; 
                    lda CCW_RoomP_Enters,x          ; 
                    cmp #CCW_RoomEnterYes           ; 
                    beq .GetTargetRoomNo            ; 
                    
                    jmp .SetNextPlayer              ; 
                    
.GetTargetRoomNo    lda CCL_PlayersTargetRoomNo,x   ; count start: entry 00 of ROOM list
                    jsr SetRoomDataPtr              ; 
                    
                    ldy #CC_Obj_RoomColor           ; 
                    lda (CCZ_RoomData),y            ; RoomDataPtr: RoomColorNo
                    sta CCW_Temp                    ; .hbu007. - save target room color for modified enter ping
                    ora #CC_Obj_RoomVisited         ; CC_Obj_RoomVisited
                    sta (CCZ_RoomData),y            ; Bit 7=1 - mark room as visited
                    
                    lda CCL_PlayersTargetDoorNo,x   ; count start: entry 00 of Room DOOR list
                    jsr SetRoomDoorPtr              ; 
                    
                    ldy #CC_Obj_DoorInWallId        ; door direction in map wall
                    lda (CCZ_RoomDoorMod),y         ; door object
                    and #CC_Obk_DoorInWallMask      ; isolate Bits 0-1 - 0=n 1=e 2=s 3=w
                    sta CCW_MapDoorWallId           ; 
                    
.GetArrowSprites    jsr GetNewSpriteWA              ; 
                    txa                             ; $00, $20, $40, $60, $80, $a0, $c0 or $e0 = block offset
                    
                    lsr a                           ; /2
                    lsr a                           ; /4
                    lsr a                           ; /8
                    lsr a                           ; /16
                    lsr a                           ; /32 = sprite number
                    sta CCW_MapSpriteNo             ; 

                    ldy #CC_Obj_RoomGridCol         ; 
                    lda (CCZ_RoomData),y            ; room object
                    ldy #CC_Obj_DoorMapOffCol       ; 
                    clc                             ; 
                    adc (CCZ_RoomDoorMod),y         ; door object
                    
                    clc                             ; 
                    ldy CCW_MapDoorWallId           ; 
                    adc TabMapDoorNSWallOff,y       ; 
                    sec                             ; 
                    sbc #$04                        ; 
                    asl a                           ; *2
                    ldy CCW_MapSpriteNo             ; 
                    sta CCZ_SpritesPosX,y           ; PosX sprites 0-7
                    bcc .GetMask                    ; 
                    
                    lda TabSelectABit,y             ; 
                    ora CCZ_SpritesMSBY             ; sprites 0-7 MSB PosY
                    jmp .PutMSBY                    ; 
                    
.GetMask            lda TabSelectABit,y             ; 
                    eor #$ff                        ; 
                    and CCZ_SpritesMSBY             ; sprites 0-7 MSB PosY
                    
.PutMSBY            sta CCZ_SpritesMSBY             ; sprites 0-7 MSB PosY
                    clc                             ; 
                    ldy #CC_Obj_RoomGridRow         ; 
                    lda (CCZ_RoomData),y            ; RoomDataPtr: CC_Obj_RoomGridRow
                    ldy #CC_Obj_DoorMapOffRow       ; 
                    adc (CCZ_RoomDoorMod),y         ; door object
                    
                    clc                             ; 
                    ldy CCW_MapDoorWallId           ; 
                    adc TabMapDoorEWWallOff,y       ; 
                    clc                             ; 
                    adc #$32                        ; 
                    
                    ldy CCW_MapSpriteNo             ; 
                    sta CCZ_SpritesPosY,y           ; PosY sprites 0-7
                    
                    ldy CCW_MapDoorWallId           ; 
                    lda TabMapArrowNo,y             ; 
                    sta CC_WaS_SpriteNo,x           ; 
                    
.GetArrowSpriteData jsr CopySpriteData              ; set shape / expand and copy sprite data of a given number to its memory location
                    
.SetSpritePointers  ldy CCZ_Sprite00DataPtr         ; .hbu015. - always $00 and $01 after sprite work area init
                    sty CC_SpritePtrMap00           ; .hbu015.
                    ldy CCZ_Sprite01DataPtr         ; .hbu015.
                    sty CC_SpritePtrMap01           ; .hbu015.
                    
.SetNextPlayer      inc CCW_MapPlayerNo             ; 
                    lda CCW_MapPlayerNo             ; 
                    cmp #$02                        ; 
                    beq .GoPaintMap                 ; 
                    
                    jmp .NextPlayer                 ; 
                    
.GoPaintMap         jsr PaintMapRooms               ; 
                    jsr SwitchScreenOn              ; 
                    
.ChkKey_RestoreI    lda #CCW_KeyGotNo               ; reset
                    sta CCW_KeyGotRestore           ; restore key pressed
                    
                    lda #CC_ArrowBlinkTime          ; 
                    sta CCW_MapBlinkTime            ; 
                    
.SetPlayerCount     lda CCW_RoomP2Enters            ; 
                    asl
                    ora CCW_RoomP1Enters            ; 
                    sta CCW_MapPlayerCount          ; 
                    
.Preset             lda CCZ_SpritesEnab             ; let player1 blink if player2 is off and vice versa
                    ora #$01                        ; on
                    sta CCZ_SpritesEnab             ; 
                    
.BlinkMapArrows     dec CCW_MapBlinkTime            ; 
                    bne .ChkKey_Restore             ; 
                    
                    lda CC_ArrowBlinkTime           ; 
                    sta CCW_MapBlinkTime            ; 
                    
                    ldx CCW_MapPlayerCount          ; 
                    cpx #$03                        ; both players about to enter
                    beq .BlinkBoth                  ; 
                    
                    dex                             ; adapt player number (count starts with $00)
                    
.BlinkOne           lda TabColorPlayer,x            ; init colors after call copy CopySpriteData
                    sta SP0COL                      ; VIC 2 - $D027 = Color Sprite 0
                    
                    lda CCZ_SpritesEnab             ; sprites 0-7 enable
                    eor #$01                        ; on-off
                    sta CCZ_SpritesEnab             ; 
                    
                    jmp .ChkKey_Restore             ; 
                    
.BlinkBoth          lda #CC_MultiColor0Player1      ; init colors after call copy CopySpriteData
                    sta SP0COL                      ; VIC 2 - $D027 = Color Sprite 0
                    lda #CC_MultiColor0Player2      ; 
                    sta SP1COL                      ; VIC 2 - $D028 = Color Sprite 1
                    
                    lda CCZ_SpritesEnab             ; sprites 0-7 enable
                    eor #$03                        ; 
                    sta CCZ_SpritesEnab             ; 
                    
                    ldx #$00                        ; set player1 fire check as he must at least press fire thus ignoring player2
                    
.ChkKey_Restore     lda CCW_KeyGotRestore           ; restore key pressed
                    cmp #CCW_KeyGotYes              ; 
                    bne .ChkInputPlayers            ; 
                    
                    lda #CCW_KeyGotNo               ; reset
                    sta CCW_KeyGotRestore           ; restore key pressed
                    
                    jsr SwitchToGameMode            ; .hbu015.- cleanup first
                    
                    ldx CCW_LoadCtrlTabOff          ; .hbu012. - same level as before
.Exit_Restore       jmp MainLoop                    ; 
                    
.ChkInputPlayers    txa                             ; player number = port number
                    jsr GetKeyJoyVal                ; 
                    
.ChkKey_Stop        lda CCW_KeyGotStop              ; 
                    cmp #CCW_KeyGotYes              ; 
                    bne .ChkJoy_Fire                ; check if a guy pressed the fir button
                    
                    jsr SaveColorRam                ; .hbu015.
                    jsr SwitchToGameMode            ; .hbu015. - cleanup first
                    jsr SaveGame                    ; 
                    jsr RestoreColorRam             ; .hbu015.
                    
.Restart_Stop       jmp .SetMapMode                 ; .hbu015. - switch back to map made
                    
.ChkJoy_Fire        lda CCW_JoyGotFire              ; 
                    bne .ExitPing                   ; 
                    
.SetIRQCount        lda #CCW_CountIRQsMap           ; loop
                    sta CCW_CountIRQs               ; counted down to $00 with every IRQ
                    
.Wait               lda CCW_CountIRQs               ; counted down to $00 with every IRQ
                    bne .Wait                       ; 
                    
.GoBlinkNext        jmp .BlinkMapArrows             ; next round
                    
.ExitPing           lda #$00                        ; .hbu015. - switch off immediately
                    sta SPENA                       ; .hbu015. - VIC 2 - $D015 = Sprite Enable
                    
                    lda CCW_Temp                    ; .hbu007. - get target room color
                    and #$07                        ; .hbu007. - reduce to color values
                    clc                             ; .hbu007.
                    adc #SFX_MapPingHeight          ; .hbu007. - color modify ping hight
                    sta SFX_MapPingTone             ; .hbu007.
                    
                    lda #NoSndMapPing               ; sound: Map Enter Ping
                    jsr InitSoundFx                 ; 
                    
MapHandlerX         jsr SaveColorRam                ; .hbu015.
; ------------------------------------------------------------------------------------------------------------- ;
SwitchToGameMode    subroutine
                    jsr SwitchScreenOff             ; .hbu015.
                    
                    lda #>CC_ScreenRoomColor        ; .hbu015.
                    sta ModObjectColor              ; .hbu015.
                    lda #$00                        ; .hbu015.
                    sta ModObjectData               ; .hbu015.
                    lda #>CC_SpritePtrRoomBase      ; .hbu015.
                    sta ModSpriteData               ; .hbu015.
                    
                    lda #CC_ScreenBankIdRoom        ; .hbu015. - force switch of VIC memory bank
                    sta CI2PRA                      ; .hbu015.
;                    sta CCZ_CIABankCtrl             ; .hbu015.
                    
SwitchToGameModeX   rts                             ; 
; ------------------------------------------------------------------------------------------------------------- ;
; RoomHandler       Function: Control the action within a chamber
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
RoomHandler         subroutine
                    jsr PaintRoom                   ; display the room first
                    
                    ldx #$00                        ; 
.EnterPlayers       lda CCW_RoomP_Enters,x          ; 
                    cmp #CCW_RoomEnterYes           ; 
                    bne .EnterNextPlayer            ; 
                    
                    stx CCW_RunIntoRoomP_No         ; 
                    jsr RunIntoRoom                 ; 
                    
                    ldx CCW_RunIntoRoomP_No         ; restore
.EnterNextPlayer    inx                             ; 
                    cpx #$02                        ; 
                    bcc .EnterPlayers               ; lower - next one
                    
                    lda #CCW_KeyGotNo               ; reset
                    sta CCW_KeyGotRestore           ; restore key pressed
                    
                    jsr SwitchScreenOn              ; 
                    
.ActionHandler      jsr ActionHandler               ; 
                    
.ChkStop            lda CCW_KeyGotStop              ; 
                    cmp #CCW_KeyGotYes              ; 
                    bne .ChkRestore                 ; 
                    
.WaitI01            lda #CCW_CountIRQsInput         ; 
                    sta CCW_CountIRQs               ; 
.Wait01             lda CCW_CountIRQs               ; counted down to $00 with every IRQ
                    bne .Wait01                     ; 
                    
                    jsr GetKeyJoyVal                ; 
                    
                    lda CCW_KeyGotStop              ; 
                    cmp #CCW_KeyGotYes              ; 
                    beq .WaitI01                    ; 
                    
                    ldx #CCL_PlayersTimesLen        ; 
.SaveTime           lda TODTEN,x                    ; CIA 1 - $DC08 = Time of Day Clock Tenths of Seconds
                    sta CCW_GameP1TimeSav,x         ; 
                    lda TO2TEN,x                    ; CIA 2 - $DD08 = Time of Day Clock Tenths of Seconds
                    sta CCW_GameP2TimeSav,x         ; 
                    dex                             ; 
                    bpl .SaveTime                   ; 
                    
.ChkJoystick        lda #$00                        ; joystick port
                    jsr GetKeyJoyVal                ; 
                    
                    lda CCW_KeyGotStop              ; 
                    cmp #CCW_KeyGotYes              ; 
                    bne .ChkJoystick                ; 
                    
.WaitI02            lda #CCW_CountIRQsInput         ; 
                    sta CCW_CountIRQs               ; 
.Wait02             lda CCW_CountIRQs               ; counted down to $00 with every IRQ
                    bne .Wait02                     ; 
                    
                    jsr GetKeyJoyVal                ; 
                    
                    lda CCW_KeyGotStop              ; 
                    cmp #CCW_KeyGotYes              ; 
                    beq .WaitI02                    ; 
                    
                    ldx #CCL_PlayersTimesLen        ; 
.RestoreTime        lda CCW_GameP1TimeSav,x         ; 
                    sta TODTEN,x                    ; CIA 1 - $DC08 = Time of Day Clock Tenths of Seconds
                    lda CCW_GameP2TimeSav,x         ; 
                    sta TO2TEN,x                    ; CIA 2 - $DD08 = Time of Day Clock Tenths of Seconds
                    dex                             ; 
                    bpl .RestoreTime                ; 
                    
.ChkRestore         lda CCW_KeyGotRestore           ; restore key pressed
                    cmp #CCW_KeyGotYes              ; 
                    bne .ChkP1Status                ; 
                    
                    lda #CCW_KeyGotNo               ; reset
                    sta CCW_KeyGotRestore           ; restore key pressed
                    
                    ldx #$01                        ; 
.ChkP_Status        lda CCL_PlayersStatus,x         ; 
                    cmp #CCL_PlayerSurvive          ; 
                    bne .SetNextPlayer              ; 
                    
                    lda #CCL_PlayerAccident         ; 
                    sta CCL_PlayersStatus,x         ; 
                    ldy CCW_SpriteWAOffP1,x         ; 
                    lda CC_WaS_SpriteFlag,y         ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    ora #CC_WaS_FlagDead            ;            $10=action   $20=death          $40=dead           $80=init
                    sta CC_WaS_SpriteFlag,y         ; 
.SetNextPlayer      dex                             ; 
                    bpl .ChkP_Status                ; 
                    
.ChkP1Status        lda CCL_Player1Status           ; 
                    cmp #CCL_PlayerSurvive          ; 
                    bne .ChkP2Status                ; 
                    
                    lda #$00                        ; 
                    sta CCL_Player1Active           ; player 1 pressed fire at start
                    jmp .ActionHandler              ; 
                    
.ChkP2Status        lda CCL_Player2Status           ; 
                    cmp #CCL_PlayerSurvive          ; 
                    bne .ChkP_StatusExI             ; 
                    
                    lda #$01                        ; 
                    sta CCL_Player1Active           ; player 1 pressed fire at start
                    
.GoActionHandler    jmp .ActionHandler              ; 
                    
.ChkP_StatusExI     ldx #$00                        ; 
.ChkP_StatusEx      lda CCL_PlayersStatus,x         ; 
                    cmp #CCL_PlayerRoomInOut        ; 
                    beq .GoActionHandler            ; 
                    
                    cmp #CCL_PlayerRoomInOutInit    ; 
                    beq .GoActionHandler            ; 
                    
                    inx                             ; 
                    cpx #$02                        ; 
                    bcc .ChkP_StatusEx              ; 
                    
                    ldx #$1e                        ; time amount
.FinishAnimation    jsr ActionHandler               ; allow pending animations (death/leave-enter room) to finish
                    dex                             ; 
                    bne .FinishAnimation            ; 
                    
RoomHandlerX        rts
; ------------------------------------------------------------------------------------------------------------- ;
; EscapeHandler     Function: Success screen and picture and goodbye waves
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
EscapeHandler       subroutine
                    jsr InitHiResSpriteWAs          ; initialize the hires screen and sprite work area
                    
                    lda #CCW_RasterOn_Exit          ; switch on raster interrupt coloring on castle escape
                    sta CCW_RasterColorMax          ; for IRQ exit screen layout
                    
                    lda CCL_Flag                    ; 
                    and #CCL_ShowXitPicture         ; 
                    beq .SetEscapeText              ; do not show escape picture
                    
.VictoryPicture     lda CCL_XitPicDataPtrLo         ; point to (36/08) entry in level data
                    sta CCZ_RoomItemLo              ; 
                    lda CCL_XitPicDataPtrHi         ; point to (36/08) entry in level data
                    sta CCZ_RoomItemHi              ; 
                    jsr PaintRoomItems              ; 
                    
.SetEscapeText      clc                             ; 
                    lda CCW_EscapePlayerNo          ; player number
                    adc #$31                        ; make it printable
                    sta TextEscapePNo               ; 
                    
                    lda #<TextEscape                ; 
                    sta CCZ_RoomItemLo              ; 
                    lda #>TextEscape                ; 
                    sta CCZ_RoomItemHi              ; 
                    jsr RoomTextLine                ; 
                    
.SetEscapeTime      lda CCW_EscapePlayerNo          ; 
                    asl a                           ; *2
                    asl a                           ; *4
                    clc                             ; 
                    adc #<CCL_PlayersTimes          ; 
                    sta CCZ_RoomItemLo              ; 
                    lda #$00                        ; 
                    adc #>CCL_PlayersTimes          ; 
                    sta CCZ_RoomItemHi              ; 
                    
                    ldy #BLACK                      ; .hbu018. - do not care for life counter this time
                    sty ColObjTimeDataBestT1        ; .hbu018.
                    sty ColObjTimeDataBestT2        ; .hbu018.
                    iny                             ; .hbu016. - white
                    jsr FillObjTimeFrame            ; 
                    
                    lda #NoObjTime                  ; object: Time - Empty Frame
                    sta CCZ_PntObj00PrmNo           ; 
                    lda #$14 * CC_GridWidth + CC_GridColOff ; .hbu018. - column 21 * width + start offset - shifted 2 to left 
                    sta CCZ_PntObj00PrmGridCol      ; 
                    lda #$03 * CC_GridHeight        ; row    04 * hight
                    sta CCZ_PntObj00PrmGridRow      ; 
                    lda #CCZ_PntObjPrmType00        ; 
                    sta CCZ_PntObjPrmType           ; 
                    
.PaintEscapeTime    jsr PaintObject                 ; 
                    
                    lda SCROLY                      ; VIC 2 - $D011 = VIC Control Register 1 (and Vertical Fine Scrolling)
                    ora #$10                        ;   Bit 4: Screen Disable   1=visible again
                    and #$7f                        ;   Bit 7: Bit 8 of raster compare register $D012    0=
                    sta SCROLY                      ; VIC 2 - $D011 = VIC Control Register 1 (and Vertical Fine Scrolling)
                    
                    ldy CCW_EscapePlayerNo          ; 
                    ldx CCW_SpriteWAOffP1,y         ; 
                    lda #$87                        ; 
                    sta CC_WaS_SpritePosY,x         ; 
                    lda #$08                        ; 
                    sta CC_WaS_SpritePosX,x         ; 
                    
                    jsr Randomizer                  ; 
                    
                    and #$0e                        ; ....###.
                    beq .GetLeave                   ; 
                    
.GetStay            lda #TabEscapeActionOne         ; offset: player waves goodbye first before leaving
                    jmp .SetLeave                   ; 
                    
.GetLeave           lda #TabEscapeActionTwo         ; offset: player leaves completely first and returns to wave goodbye
.SetLeave           sta CCW_EscapeActionForm        ; 
                    
                    lda #$00                        ; 
                    sta CCW_EscapeActionTime        ; 
                    
.ActionPhases       lda CCW_EscapeActionTime        ; 
                    bne .ChkAction                  ; 
                    
                    ldy CCW_EscapeActionForm        ; 
                    lda TabEscapeActionTime,y       ; 
                    bne .SetDuration                ; 
                    
.GoExit             jmp .Exit                       ; 
                    
.SetDuration        sta CCW_EscapeActionTime        ; 
                    lda TabEscapeActionType,y       ; 
                    sta CCW_EscapeActionType        ; 
                    
                    clc                             ; 
                    lda CCW_EscapeActionForm        ; 
                    adc #$02                        ; 
                    sta CCW_EscapeActionForm        ; 
                    
.ChkAction          lda CCW_EscapeActionType        ; 
                    cmp #$01                        ; $00=run right $01=run left $02=wave
                    bcc .RunRight                   ; 
                    beq .RunLeft                    ; 
                    
.Wave               inc CC_WaS_SpriteNo,x           ; sprite: Player: Wave Good Bye Phases
                    lda CC_WaS_SpriteNo,x           ; 
                    cmp #NoSprPlrWavGBMax           ; sprite: Player: Wave Good Bye Phase 03 + 2
                    bcs .WaveGBStart                ; 
                    
                    cmp #NoSprPlrWavGBMin           ; sprite: Player: Wave Good Bye Phase 01
                    bcs .SetActionImgNo             ; 
                    
.WaveGBStart        lda #NoSprPlrWavGBMin           ; sprite: Player: Wave Good Bye Phase 01
                    jmp .SetActionImgNo             ; 
                    
.RunRight           inc CC_WaS_SpritePosX,x         ; 
                    inc CC_WaS_SpriteNo,x           ; 
                    lda CC_WaS_SpriteNo,x           ; 
                    cmp #NoSprPlrMovLeMax           ; sprite: Player: Move Left  Phase 03 + 1
                    bcs .RunLeftStart               ; 
                    
                    cmp #NoSprPlrMovLeMin           ; sprite: Player: Move Left  Phase 01
                    bcs .SetActionImgNo             ; 
                    
.RunLeftStart       lda #NoSprPlrMovLeMin           ; sprite: Player: Move Left  Phase 01
                    jmp .SetActionImgNo             ; 
                    
.RunLeft            dec CC_WaS_SpritePosX,x         ; 
                    inc CC_WaS_SpriteNo,x           ; 
                    lda CC_WaS_SpriteNo,x           ; 
                    cmp #NoSprPlrMovLeMin           ; sprite: Player: Move Left  Phase 01
                    bcc .SetActionImgNo             ; 
                    
.RunRightStart      lda #NoSprPlrMovRiMin           ; sprite: Player: Move Right Phase 01
.SetActionImgNo     sta CC_WaS_SpriteNo,x           ; 
                    txa                             ; 
                    lsr a                           ; /2
                    lsr a                           ; /4
                    lsr a                           ; /8
                    lsr a                           ; /16
                    lsr a                           ; /32 = sprite number
                    tay                             ; 
                    
                    sei                             ; interrupts off
                    
                    lda CC_WaS_SpritePosX,x         ; 
                    sec                             ; 
                    sbc #$10                        ; 
                    asl a                           ; 
                    
                    clc                             ; 
                    adc #$18                        ; 
                    sta CCZ_SpritesPosX,y           ; PosX sprites 0-7
                    
                    lda CC_WaS_SpritePosX,x         ; 
                    cmp #$84                        ; 
                    bcs .Set20                      ; 
                    
                    lda TabSelectABit,y             ; 
                    eor #$ff                        ; 
                    and CCZ_SpritesMSBY             ; sprites 0-7 MSB PosY
                    jmp .SetMSBPosY                 ; 
                    
.Set20              lda TabSelectABit,y             ; 
                    ora CCZ_SpritesMSBY             ; sprites 0-7 MSB PosY
.SetMSBPosY         sta CCZ_SpritesMSBY             ; sprites 0-7 MSB PosY
                    
                    cli                             ; interrupts on again
                    
                    lda CC_WaS_SpritePosY,x         ; 
                    clc                             ; 
                    adc #$32                        ; 
                    sta CCZ_SpritesPosY,y           ; PosY sprites 0-7
                    
                    jsr CopySpriteData              ; set shape / expand and copy sprite data of a given number to its memory location
                    
                    lda TabSelectABit,y             ; 
                    ora CCZ_SpritesEnab             ; 
                    sta CCZ_SpritesEnab             ; sprites 0-7 enable
                    lda CCW_EscapePlayerNo          ; 
                    beq .GetP1Color                 ; 
                    
.GetP2Color         lda TabColorPlayer2             ; 
                    jmp .SetP_Color                 ; 
                    
.GetP1Color         lda TabColorPlayer1             ; 
                    
.SetP_Color         sta SP0COL,y                    ; VIC 2 - $D027 = Color Sprite 0(-7)
                    
                    dec CCW_EscapeActionTime        ; 
                    
                    lda #CCW_CountIRQsGame          ; 
                    sta CCW_CountIRQs               ; 
                    
.Wait               lda CCW_CountIRQs               ; counted down to $00 with every IRQ
                    bne .Wait                       ; 
                    
                    jmp .ActionPhases               ; 
                    
.Exit               lda #$05                        ; dynamic wait time
EscapeHandlerX      jmp WaitSomeTime                ; 
; ------------------------------------------------------------------------------------------------------------- ;
; TextScreenHandler Function: Control the game options / load castle data files actions
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
TextScreenHandler   subroutine
.TextScreenStart    lda #$0b                        ; ....#.## Bit 5: 0=text mode Bit 3: 1=25 rows  Bits 0-2: vertical fine scrolling
                    sta SCROLY                      ; VIC 2 - $D011 = VIC Control Register 1 (and Vertical Fine Scrolling)
                    
                    lda #CC_ScreenBankIdText        ; 
                    sta C2DDRA                      ; CIA 2 - $DD02 = Data Direction A
                    sta CI2PRA                      ; 
;                    sta CCZ_CIABankCtrl             ; .hbu015.
                    
                    lda #$00                        ; 
                    sta CCZ_SpritesEnab             ; sprites 0-7 off
                    
                    lda #CC_VIC_ScreenText          ; ...# - Bits 4-7: Screen base address: 1=$0400-$07e7 + base in $DD00 ($0000-$3fff)
                    sta CCZ_VICMemCtrl              ; .#.. - Bits 2-3: Char   base address: 2=$1000-$17ff + base in $DD00 ($0000-$3fff)
                    
                    lda #WHITE                      ; 
                    jsr InitColorRam                ; 
                    
                    jsr SwitchScreenOn              ; 
                    
.GetJoyVal          lda #$00                        ; joystick port
                    sta CCW_JoyGotFire              ; .hbu019. - reset fire
                    jsr GetKeyJoyVal                ; 
                    
                    lda CCW_JoyGotFire              ; 
                    bne .Fire                       ; 
                    
                    lda CCW_JoyGotDir               ; 
                    and #$fb                        ; #### #.##
                    bne .GetJoyVal                  ; 
                    
                    ldx CCW_LoadCtrlTabOffWrk       ; actual screen control table offset
                    clc                             ; 
                    ldy CC_LoadCtrlRow,x            ; 
                    lda TabCtrlScrRowsLo,y          ; 
                    adc #$00                        ; 
                    sta CCZ_ScreenLoadLo            ; 
                    lda TabCtrlScrRowsHi,y          ; 
                    adc #$04                        ; 
                    sta CCZ_ScreenLoadHi            ; 
                    
                    ldy CC_ScreenLoadCtrl,x         ; 
                    dey                             ; 
                    dey                             ; 
                    lda #" "                        ; 
                    sta (CCZ_ScreenLoad),y          ; 
                    
                    lda CCW_JoyGotDir               ; 
                    beq .Up                         ; CC_WaS_JoyMoveU
                    
                    lda CCW_LoadCtrlTabOffWrk       ; actual screen control table offset
                    cmp CCW_LoadCtrlTabOffMax       ; 
                    bne .NextFilePos                ; 
                    
.FirstFilePos       lda #$00                        ; 
                    jmp .StoreFilePos               ; 
                    
.NextFilePos        clc                             ; 
                    adc #$04                        ; 
                    jmp .StoreFilePos               ; 
                    
.Up                 lda CCW_LoadCtrlTabOffWrk       ; actual screen control table offset
                    bne .PrevFilePos                ; 
                    
                    lda CCW_LoadCtrlTabOffMax       ; 
                    jmp .StoreFilePos               ; 
                    
.PrevFilePos        sec                             ; 
                    sbc #$04                        ; 
                    
.StoreFilePos       sta CCW_LoadCtrlTabOffWrk       ; actual screen control table offset
                    
                    tax                             ; 
                    ldy CC_LoadCtrlRow,x            ; 
                    clc                             ; 
                    lda TabCtrlScrRowsLo,y          ; 
                    adc #$00                        ; 
                    sta CCZ_ScreenLoadLo            ; 
                    lda TabCtrlScrRowsHi,y          ; 
                    adc #$04                        ; 
                    sta CCZ_ScreenLoadHi            ; 
                    
                    ldy CC_ScreenLoadCtrl,x         ; 
                    dey                             ; 
                    dey                             ; 
                    lda #">"                        ; 
                    sta (CCZ_ScreenLoad),y          ; 
                    
                    jmp .GoGetJoyVal                ; wait for joystick to be released to avoid permanent action
                    
.Fire               ldx CCW_LoadCtrlTabOffWrk       ; actual screen control table offset
                    lda CC_LoadCtrlId,x             ; 
                    bne .ChkDynFile                 ; CC_LoadCtrlIdLives
                    
.LivesOnOff         lda CCW_LoadCtrlUnlimLives      ; 
                    eor #CCW_LoadCtrlLivesOnOff     ; flip to off
                    sta CCW_LoadCtrlUnlimLives      ; 
                    
                    clc                             ; 
                    ldy CC_LoadCtrlRow,x            ; 
                    lda TabCtrlScrRowsLo,y          ; 
                    adc #$00                        ; 
                    sta CCZ_ScreenLoadLo            ; 
                    lda TabCtrlScrRowsHi,y          ; 
                    adc #$04                        ; 
                    sta CCZ_ScreenLoadHi            ; 
                    
                    lda CC_ScreenLoadCtrl,x         ; 
                    clc                             ; 
                    adc #$11                        ; 
                    tay                             ; 
                    ldx #$00                        ; 
.FlipLives          cpx #$02                        ; omit the "/" separator
                    beq .NextFlip                   ; 
                    
.Flip               lda (CCZ_ScreenLoad),y          ; 
                    eor #$80                        ; flip the reverse on/off bit
                    sta (CCZ_ScreenLoad),y          ; 
                    
.NextFlip           inx                             ; 
                    iny                             ; 
                    cpx #$06                        ; length of "on/off"
                    bcc .FlipLives                  ; 
                    
.GoGetJoyVal        jsr WaitJoyKeyRlse              ; wait for joystick to be released to avoid permanent action
                    jmp .GetJoyVal                  ; 
                    
.ChkDynFile         cmp #CC_LoadCtrlIdFile          ; 
                    bne .ChkResume                  ; 
                    
                    ldx CCW_LoadCtrlTabOffWrk       ; actual screen control table offset - number castle data file name
                    jsr LoadCastleData              ; 
                    
.GoTextScreenStart  jmp .TextScreenStart            ; 
                    
.ChkResume          cmp #CC_LoadCtrlIdResume        ; 
                    bne .CheckTimes                 ; 
                    
                    jsr ResumeGame                  ; 
                    
                    lda CCW_DiskAccess              ; 
                    cmp #CCW_DiskAccessOk           ; 
                    bne .GoTextScreenStart          ; 
                    
.CheckTimes         cmp #CC_LoadCtrlIdTimes         ; 
                    bne .Exit                       ; CC_LoadCtrlIdExit not checked yet and left over
                    
                    lda CCW_LoadCtrlTabOff          ; 
                    cmp #$ff                        ; 
                    beq .GoTextScreenStart          ; 
                    
                    jsr WarmStart                   ; 
                    jsr ShowBestTimes               ; 
                    
                    lda #<TextExit                  ; 
                    sta CCZ_RoomItemLo              ; 
                    lda #>TextExit                  ; 
                    sta CCZ_RoomItemHi              ; 
                    jsr RoomTextLine                ; 
                    
                    jsr SwitchScreenOn              ; 
                    
.WaitFire           lda #$00                        ; .hbu010. - joystick port
                    sta CCW_JoyGotFire              ; .hbu019. - reset fire
                    jsr GetKeyJoyVal                ; .hbu010.
                    
                    lda CCW_JoyGotFire              ; .hbu010.
                    beq .WaitFire                   ; .hbu010.
                    
                    jsr WaitJoyKeyRlse              ; .hbu010. - wait for joystick to be released to avoid permanent action
                    jmp .TextScreenStart            ; .hbu010.
                    
.Exit               jsr WaitJoyKeyRlse              ; wait for joystick to be released to avoid permanent action
TextScreenHandlerX  jmp WarmStart                   ; 
; ------------------------------------------------------------------------------------------------------------- ;
; TrapDoorHandler   Function: Open/Close Trap Door if Switch is touched by Player/Mummy/Frank
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
TrapDoorHandler     subroutine
                    pha
                    sta CCW_TrapOffTypWA
                    tya
                    pha
                    txa
                    pha
                    
                    lda CCZ_RoomItemModLo
                    sta CCW_TrapDataModPtrLo
                    lda CCZ_RoomItemModHi
                    sta CCW_TrapDataModPtrHi
                    
                    lda CCZ_CtrlScreenLo
                    sta CCW_TrapCtrlDataLo
                    lda CCZ_CtrlScreenHi
                    sta CCW_TrapCtrlDataHi
                    
                    clc
                    lda CCW_TrapDataPtrLo
                    adc CCW_TrapOffTypWA
                    sta CCZ_RoomItemModLo
                    lda CCW_TrapDataPtrHi
                    adc #$00
                    sta CCZ_RoomItemModHi
                    
                    ldy #CC_Obj_TrapStatus
                    lda (CCZ_RoomTrapMod),y
                    eor #CC_Obj_TrapOpen            ; flip trap door mode
                    sta (CCZ_RoomTrapMod),y
                    
                    ldx #$00
.FindTrapWA         lda CC_WaO_ObjectType,x
                    cmp #CC_WaO_TrapDoor
                    bne .SetNextObjWA
                    
                    lda CC_WaO_TypTrapDataOff,x
                    cmp CCW_TrapOffTypWA
                    beq .FoundTrapWA
                    
.SetNextObjWA       txa
                    clc
                    adc #CC_WaO_DataLen
                    tax
                    jmp .FindTrapWA
                    
.FoundTrapWA        lda CC_WaO_ObjectFlag,x
                    ora #CC_WaO_Ready               ; action completed - CC_WaO_Ready
                    sta CC_WaO_ObjectFlag,x
                    
                    ldy #CC_Obj_TrapStatus
                    lda (CCZ_RoomTrapMod),y
                    and #CC_Obj_TrapOpen            ; CC_Obj_TrapOpen
                    bne .TrapOpen
                    
.TrapClosed         lda #CC_WaO_TypTrapClosed
                    sta CC_WaO_TypTrapMode,x
                    lda #NoObjTrapMovMax            ; object: Trap Door Shut Complete
                    sta CC_WaO_TypTrapPhaseNo,x
                    
                    lda #CC_Obj_TrapSwColorOffTop   ; grey top of switch
                    sta ColObjTrapSw01              ; trap control top
                    lda #CC_Obj_TrapSwColorOpen     ; green
                    sta ColObjTrapSw02              ; trap control bottom
                    
                    ldy #CC_Obj_TrapDoorGridCol
                    lda (CCZ_RoomTrapMod),y
                    lsr a
                    lsr a
                    sec
                    sbc #$04
                    sta CCW_CtrlScrnColNo
                    
                    ldy #CC_Obj_TrapDoorGridRow
                    lda (CCZ_RoomTrapMod),y
                    lsr a
                    lsr a
                    lsr a
                    sta CCW_CtrlScrnRowNo
                    
                    jsr SetCtrlScrnPtr              ; point to control screen output address $c000-$c7ff
                    
                    ldy #$00
                    lda (CCZ_CtrlScreen),y
                    ora #CC_CtrlFloorStrt
                    sta (CCZ_CtrlScreen),y
                    
                    ldy #$04
                    lda (CCZ_CtrlScreen),y
                    ora #CC_CtrlFloorEnd
                    sta (CCZ_CtrlScreen),y
                    
                    jmp .SetTrapCtrl
                    
.TrapOpen           lda #CC_Obj_TrapOpen
                    sta CC_WaO_TypTrapMode,x
                    lda #NoObjTrapMovMin            ; object: Trap Door - Open Complete
                    sta CC_WaO_TypTrapPhaseNo,x
                    
                    lda #CC_Obj_TrapSwColorClosed   ; red
                    sta ColObjTrapSw01              ; trap control top
                    lda #CC_Obj_TrapSwColorOffBot   ; grey bottom of switch
                    sta ColObjTrapSw02              ; trap control bottom
                    
                    ldy #CC_Obj_TrapDoorGridCol
                    lda (CCZ_RoomTrapMod),y
                    lsr a
                    lsr a
                    sec
                    sbc #$04
                    sta CCW_CtrlScrnColNo
                    ldy #CC_Obj_TrapDoorGridRow
                    lda (CCZ_RoomTrapMod),y
                    lsr a
                    lsr a
                    lsr a
                    sta CCW_CtrlScrnRowNo
                    
                    jsr SetCtrlScrnPtr              ; point to control screen output address $c000-$c7ff
                    
                    ldy #$00
                    lda (CCZ_CtrlScreen),y
                    and #CC_CtrlTrapLeft            ; trap open: start - resets floor to CC_CtrlFloorEnd
                    sta (CCZ_CtrlScreen),y
                    
                    ldy #$04
                    lda (CCZ_CtrlScreen),y
                    and #CC_CtrlTrapRight           ; trap open: end   - resets floor to CC_CtrlFloorStrt
                    sta (CCZ_CtrlScreen),y
                    
.SetTrapCtrl        ldy #CC_Obj_TrapSwitchGridCol
                    lda (CCZ_RoomTrapMod),y
                    sta CCZ_PntObj00PrmGridCol
                    ldy #CC_Obj_TrapSwitchGridRow
                    lda (CCZ_RoomTrapMod),y
                    sta CCZ_PntObj00PrmGridRow
                    lda #NoObjTrapSw                ; object: Trap Door Control
                    sta CCZ_PntObj00PrmNo
                    lda #CCZ_PntObjPrmType00
                    sta CCZ_PntObjPrmType  
                    
.PaintTrapCtrl      jsr PaintObject
                    
                    lda CCW_TrapDataModPtrLo
                    sta CCZ_RoomItemModLo
                    lda CCW_TrapDataModPtrHi
                    sta CCZ_RoomItemModHi
                    lda CCW_TrapCtrlDataLo
                    sta CCZ_CtrlScreenLo
                    lda CCW_TrapCtrlDataHi
                    sta CCZ_CtrlScreenHi
                    
TrapDoorHandlerX    pla
                    tax
                    pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
; ActionHandler     Function: Detect sprite collisions and handle all sprite/object actions - Called from: RoomHandler
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
ActionHandler       subroutine
                    pha                             ; 
                    
.Wait               lda CCW_CountIRQs               ; counted down to $00 with every IRQ
                    bne .Wait                       ; 
                    
                    lda #CCW_CountIRQsGame          ; 
                    sta CCW_CountIRQs               ; reinit to default
                    
                    jsr FillSprtCollsWA             ; Loop through the sprite work areas and fill CC_WaS_SpriteFlag with collisions
                    jsr SpriteHandler               ; Loop through the sprite work areas and check for actions
                    jsr ObjectHandler               ; Loop through the object work areas and check for actions
                    
                    inc CCW_CountActnHdlrCalls      ; counter ActionHandler routine calls
                    
ActionHandlerX      pla                             ; 
                    rts                             ; 
; ------------------------------------------------------------------------------------------------------------- ;
; SpriteHandler     Function: Loop through the sprite work areas and check for actions
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
SpriteHandler       subroutine
                    pha
                    tya
                    pha
                    txa
                    pha
                    
                    ldx #$00
.GetNextSpriteWA    lda CC_WaS_SpriteFlag,x         ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    bit Bit_oooo_ooo1               ;            $10=action   $20=death          $40=dead           $80=init
                    beq .ChkActiveWA
                    
                    jmp .SetNextSpriteWA            ; inactive
                    
.ChkActiveWA        bit Bit_ooo1_oooo
                    bne SpriteHandlerSetMov
                    
                    bit Bit_o1oo_oooo               ; death
                    bne .GoAnimateDeath
                    
                    dec CC_WaS_SpriteSeqOld,x
                    beq .ChkDeath20
                    
                    bit Bit_oooo_oo1o               ; collision sprite-sprite
                    beq .NextWA
                    
                    jsr SprtSprtHandler             ; handle sprite-sprite collisions
                    
                    lda CC_WaS_SpriteFlag,x         ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    bit Bit_o1oo_oooo               ;            $10=action   $20=death          $40=dead           $80=init
                    bne .GoAnimateDeath
                    
.NextWA             jmp .SetNextSpriteWA
                    
.ChkDeath20         bit Bit_oo1o_oooo
                    bne .GoAnimateDeath
                    
                    bit Bit_oooo_o1oo
                    beq .ChkSprSprColl
                    
                    jsr SprtBkgrHandler             ; handle sprite-background collisions
                    
                    lda CC_WaS_SpriteFlag,x         ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    bit Bit_o1oo_oooo               ;            $10=action   $20=death          $40=dead           $80=init
                    bne .GoAnimateDeath
                    
.ChkSprSprColl      lda CC_WaS_SpriteFlag,x         ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    bit Bit_oooo_oo1o               ;            $10=action   $20=death          $40=dead           $80=init
                    beq SpriteHandlerSetMov
                    
                    jsr SprtSprtHandler             ; handle sprite-sprite collisions
                    
                    lda CC_WaS_SpriteFlag,x         ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    bit Bit_o1oo_oooo               ;            $10=action   $20=death          $40=dead           $80=init
                    bne .GoAnimateDeath
                    
SpriteHandlerSetMov lda CC_WaS_SpriteType,x         ; $00=Player $01=Spark $02=Force $03=Mummy $04=Beam $05=Frank
                    asl a                           ; *2
                    asl a                           ; *4
                    asl a                           ; *8
                    
                    tay
                    lda SpriteMove,y
                    sta .___SprtTypAdrLo
                    lda SpriteMove+1,y
                    sta .___SprtTypAdrHi
                    
.JmpSprtMove        dc.b $4c                        ; jmp $2ee9
.___SprtTypAdrLo    dc.b $e9
.___SprtTypAdrHi    dc.b $2e
                    
SpriteHandlerRetMov lda CC_WaS_SpriteFlag,x         ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    bit Bit_o1oo_oooo               ;            $10=action   $20=death          $40=dead           $80=init
                    beq .StillAlive

.GoAnimateDeath     jsr AnimateDeath
                    
.StillAlive         lda CC_WaS_SpriteFlag,x         ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    and #CC_WaS_FlagAction          ;            $10=action   $20=death          $40=dead           $80=init
                    bne SpriteHandlerSetMov
                    
                    txa
                    lsr a                           ; /2
                    lsr a                           ; /4
                    lsr a                           ; /8
                    lsr a                           ; /16
                    lsr a                           ; /32 = sprite number
                    tay
                    
                    lda CC_WaS_SpriteFlag,x         ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    and #CC_WaS_Flag08              ;            $10=action   $20=death          $40=dead           $80=init
                    beq .Move
                    
                    lda #CC_WaS_FlagInactive        ; 
                    sta CC_WaS_SpriteFlag,x         ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    jmp .SetEnable                  ;            $10=action   $20=death          $40=dead           $80=init
                    
.Move               lda CC_WaS_SpritePosX,x         ; 
                    sta CCZ_SpriteColLo
                    lda #$00
                    sta CCZ_SpriteColHi
                    
                    asl CCZ_SpriteColLo             ; *2
                    rol CCZ_SpriteColHi             ; 
                    
                    sec
                    lda CCZ_SpriteColLo             ; 
                    sbc #$08
                    
                    sei
                    
                    sta CCZ_SpritesPosX,y           ; PosX sprites 0-7
                    
                    lda CCZ_SpriteColHi
                    sbc #$00
                    bcc .SetEnable
                    beq .SetMSBPosY
                    
                    lda CCZ_SpritesMSBY             ; sprites 0-7 MSB PosY
                    ora TabSelectABit,y
                    jmp .MSBPosY
                    
.SetMSBPosY         lda TabSelectABit,y
                    eor #$ff
                    and CCZ_SpritesMSBY             ; sprites 0-7 MSB PosY
                    
.MSBPosY            sta CCZ_SpritesMSBY             ; sprites 0-7 MSB PosY
                    and TabSelectABit,y
                    beq .PosY
                    
                    lda CCZ_SpritesPosX,y           ; PosX sprites 0-7
                    cmp #$58
                    bcc .PosY
                    
.SetEnable          lda TabSelectABit,y
                    eor #$ff
                    and CCZ_SpritesEnab             ; sprites 0-7 enable
                    jmp .Enable
                    
.PosY               lda CC_WaS_SpritePosY,x
                    clc
                    adc #$32
                    sta CCZ_SpritesPosY,y           ; PosY  sprites 0-7
                    
                    lda CCZ_SpritesEnab             ; sprites 0-7 enable
                    ora TabSelectABit,y
                    
.Enable             sta CCZ_SpritesEnab             ; sprites 0-7 enable
                    
                    cli
                    
                    lda CC_WaS_SpriteSeqNo,x
                    sta CC_WaS_SpriteSeqOld,x
                    
.SetNextSpriteWA    clc
                    txa
                    adc #$20
                    tax
                    beq SpriteHandlerX
                    
                    jmp .GetNextSpriteWA
                    
SpriteHandlerX      pla
                    tax
                    pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
; ObjectHandler     Function: Loop through the object work areas and check for actions
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
ObjectHandler       subroutine
                    pha
                    tya
                    pha
                    txa
                    pha
                    
                    lda #$00
                    sta CCW_AutoMovWALen
                    
.GetNextObjWA       lda CCW_AutoMovWALen
                    cmp CCW_ObjWAUseCount           ; max $20 entries a $08 bytes in object work area
                    bcc .NextObjWA                  ; lower
                    
                    jmp ObjectHandlerX              ; exit
                    
.NextObjWA          asl a                           ; *2
                    asl a                           ; *4
                    asl a                           ; *8 - length of each entry
                    tax
                    lda CC_WaO_ObjectFlag,x
.Chk40              bit Bit_o1oo_oooo               ; action completed - CC_WaO_Ready
                    beq .ChkMove                    ; no: complete
                    
.ObjectType         lda CC_WaO_ObjectType,x         ; object type ($00-$0f)
                    asl a
                    asl a                           ; *4
                    tay
                    lda ObjectMoveAuto,y            ; $00-Door           -Bell       $02-LightBall      -LightSwitch
                    sta .___ObjTypAdrLo             ; $04-Force       $05-Mummy          Key            -Lock
                    lda ObjectMoveAuto+1,y          ; $08-Gun            -GunSwitch  $0a-MTRecOval   $0b-TrapDoor
                    sta .___ObjTypAdrHi             ;    -TrapSwitch  $0d-WalkWay       -WalkSwitch     -Frank
                    beq .CheckReady
                    
.JmpObjMoveAuto     dc.b $4c                        ; jmp $3f85
.___ObjTypAdrLo     dc.b $85
.___ObjTypAdrHi     dc.b $3f
                    
.CheckReady         lda CC_WaO_ObjectFlag,x
                    eor Bit_o1oo_oooo               ; action completed - CC_WaO_Ready
                    sta CC_WaO_ObjectFlag,x
                    
RetObjMoveAuto      equ *                           ; common return point cannot be local
                    
.GetMove            lda CC_WaO_ObjectFlag,x
.ChkMove            bit Bit_oo1o_oooo               ; move - CC_WaO_Move
                    beq .GoChkNextObjWA
                    
                    jsr PaintWAObjTyp1
                    
                    dec CCW_ObjWAUseCount           ; max $20 entries of $08 bytes in object work area
                    
                    lda CCW_ObjWAUseCount           ; max $20 entries of $08 bytes in object work area
                    asl a
                    asl a
                    asl a                           ; *8 - length of each work area entry
                    sta .___WAAmount
                    
.CpxWAUsed          dc.b $e0                        ; cpx #$00
.___WAAmount        dc.b $00
                    
                    beq ObjectHandlerX              ; exit
                    
                    tay
                    lda #CC_WaO_DataLen
                    sta CCW_AutoMovWALenCopy
.Copy               lda CC_WaO_Common,y
                    sta CC_WaO_Common,x
                    
                    lda CC_WaO_Type,y
                    sta CC_WaO_Type,x
                    
                    inx
                    iny
                    dec CCW_AutoMovWALenCopy
                    bne .Copy
                    
.GoChkNextObjWA     inc CCW_AutoMovWALen
                    jmp .GetNextObjWA
                    
ObjectHandlerX      pla
                    tax
                    pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
; SprtSprtHandler   Function: Handle sprite sprite collisions
;                   Parms   : xr=Sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
SprtSprtHandler     subroutine
                    pha                             ; 
                    tya                             ; 
                    pha                             ; 
                    
                    stx CCW_SpriteWAOffMov          ; 
                    
                    lda CC_WaS_SpriteType,x         ; $00=Player $01=Spark $02=Force $03=Mummy $04=Beam $05=Frank
                    asl a                           ; *2
                    asl a                           ; *4
                    asl a                           ; *8
                    tay                             ; 
                    lda SpriteCollisionPrio,y       ; $00=Player $04=Spark $03=Force $02=Mummy $04=Beam $00=Frank
                    bpl .SetMaxX                    ; 
                    
.Exit               jmp SprtSprtHandlerX            ; 
                    
.SetMaxX            sta CCW_SpriteCollPrio          ; 
                    
                    lda CC_WaS_SpritePosX,x         ; 
                    sta CCW_SpriteCol               ; 
                    clc                             ; 
                    adc CC_WaS_SpriteCols,x         ; 
                    sta CCW_SpriteColMax            ; 
                    bcc .SetMaxY                    ; 
                    
                    lda #$00                        ; 
                    sta CCW_SpriteCol               ; 
                    
.SetMaxY            lda CC_WaS_SpritePosY,x         ; 
                    sta CCW_SpriteRow               ; 
                    clc                             ; 
                    adc CC_WaS_SpriteRows,x         ; 
                    sta CCW_SpriteRowMax            ; 
                    bcc .NextSprtWAI                ; 
                    
                    lda #$00                        ; 
                    sta CCW_SpriteRow               ; 
                    
.NextSprtWAI        ldy #$00                        ; 
.NextSprtWA         sty CCW_SpriteWAOffHit          ; 
                    cpy CCW_SpriteWAOffMov          ; 
                    bne .ChkSpriteActive            ; .hbu004.
                    
.GoSetNextSprtWA    jmp .SetNextSprtWA              ; .hbu004.
                    
.ChkSpriteActive    lda CC_WaS_SpriteFlag,y         ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    bit Bit_oooo_ooo1               ;            $10=action   $20=death          $40=dead           $80=init
                    bne .GoSetNextSprtWA            ; .hbu004. - yes
                    
                    and #CC_WaS_FlagCollS_S         ; sprite-sprite collision
                    beq .GoSetNextSprtWA            ; .hbu004. - no
                    
                    lda CC_WaS_SpriteType,y         ; .hbu004. - $00=Player $01=Spark $02=Force $03=Mummy $04=Beam $05=Frank
                    cmp #CC_WaS_SpriteMummy         ; .hbu004.
                    bne .SprtSprtShift              ; .hbu004. - no mummy
                    
                    cmp CC_WaS_SpriteType,x         ; .hbu004. - $00=Player $01=Spark $02=Force $03=Mummy $04=Beam $05=Frank
                    bne .SprtSprtShift              ; .hbu004. - no mummy
                    
.ChkMummyRowPos     lda CC_WaS_SpritePosY,x         ; .hbu004. - mummy-mummy collision - check tapped side
                    cmp CC_WaS_SpritePosY,y         ; .hbu004.
                    bne .SprtSprtColl               ; .hbu004.
                    
.ChkMummyColPos     lda CC_WaS_SpritePosX,x         ; .hbu004. - mummy-mummy collision - check tapped side
                    cmp CC_WaS_SpritePosX,y         ; .hbu004.
                    bcc .OnLeftSide                 ; .hbu004. - lower
                    bne .OnRightSide                ; .hbu004. - higher
                    
.Overlap            lda CC_WaS_SpritePosX,x         ; .hbu004. - pushed together by a moving sidewalk
                    clc                             ; .hbu004. - do not pile them up completely again
                    adc CC_WaS_MummyCollWalk,x      ; .hbu004. - by adding the speed adjustment twice
                    sta CC_WaS_SpritePosX,x         ; .hbu004.
                    jmp .SprtSprtColl               ; .hbu004.
                    
.OnRightSide        lda #CC_WaS_MummyCollYes        ; .hbu004.
                    sta CC_WaS_MummyCollLeft,x      ; .hbu004. - mark tapped from the left
                    jmp .SprtSprtColl               ; .hbu004.
                    
.OnLeftSide         lda #CC_WaS_MummyCollYes        ; .hbu004. - mark tapped from the right
                    sta CC_WaS_MummyCollRight,x     ; .hbu004.
                    
.SprtSprtColl       lda CC_WaS_SpriteType,y         ; $00=Player $01=Spark $02=Force $03=Mummy $04=Beam $05=Frank
.SprtSprtShift      asl a                           ; 
                    asl a                           ; 
                    asl a                           ; *8
                    tay                             ; 
                    
                    lda SpriteCollisionPrio,y       ; $00=Player $04=Spark $03=Force $02=Mummy $04=Beam $00=Frank
                    bmi .SetNextSprtWA              ; $80=EndOfTable
                    
                    bit CCW_SpriteCollPrio          ; 
                    bne .SetNextSprtWA              ; 
                    
                    ldy CCW_SpriteWAOffHit          ; 
                    
                    lda CCW_SpriteColMax            ; 
                    cmp CC_WaS_SpritePosX,y         ; 
                    bcc .SetNextSprtWA              ; 
                    
                    lda CC_WaS_SpritePosX,y         ; 
                    clc          ; 
                    adc CC_WaS_SpriteCols,y         ; 
                    cmp CCW_SpriteCol               ; 
                    bcc .SetNextSprtWA              ; 
                    
                    lda CCW_SpriteRowMax            ; 
                    cmp CC_WaS_SpritePosY,y         ; 
                    bcc .SetNextSprtWA              ; 
                    
                    lda CC_WaS_SpritePosY,y         ; 
                    clc          ; 
                    adc CC_WaS_SpriteRows,y         ; 
                    cmp CCW_SpriteRow               ; 
                    bcc .SetNextSprtWA              ; 
                    
                    jsr ChkSprtSprtKill             ; 
                    
                    ldx CCW_SpriteWAOffHit          ; 
                    ldy CCW_SpriteWAOffMov          ; 
                    
                    jsr ChkSprtSprtKill             ; 
                    
.SetNextSprtWA      ldx CCW_SpriteWAOffMov          ; 
                    ldy CCW_SpriteWAOffHit          ; 
                    tya                             ; 
                    
                    clc                             ; 
                    adc #$20                        ; set next sprite work area offset
                    beq SprtSprtHandlerX            ; 
                    
                    tay                             ; 
                    jmp .NextSprtWA                 ; 
                    
SprtSprtHandlerX    pla                             ; 
                    tay                             ; 
                    pla                             ; 
                    rts                             ; 
; ------------------------------------------------------------------------------------------------------------- ;
; SprtBkgrHandler   Function: 
;                   Parms   : xr=Sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
SprtBkgrHandler     subroutine
                    pha
                    tya
                    pha
                    
                    clc
.MaxPosX            lda CC_WaS_SpritePosX,x
                    sta CCW_ObjSpriteCol
                    adc CC_WaS_SpriteCols,x
                    sta CCW_ObjSpriteColMax
                    bcc .MaxPosY
                    
                    lda #$00
                    sta CCW_ObjSpriteCol
                    
.MaxPosY            clc
                    lda CC_WaS_SpritePosY,x
                    sta CCW_ObjSpriteRow
                    adc CC_WaS_SpriteRows,x
                    sta CCW_ObjSpriteRowMax
                    bcc .ChkWAUseCount
                    
                    lda #$00
                    sta CCW_ObjSpriteRow
                    
.ChkWAUseCount      lda CCW_ObjWAUseCount           ; max $20 entries a $08 bytes in object work area
                    bne .NextWAI
                    
                    jmp SprtBkgrHandlerX
                    
.NextWAI            asl a
                    asl a
                    asl a                           ; *8 = length status work area block
                    sta CCW_ObjWAOffFree            ; next free status work area block
                    
                    ldy #$00                        ; start
.NextWAObjs         sty CCW_ObjWAOffHit             ; offset status work area block to handle
                    lda CC_WaO_ObjectFlag,y         ; 
                    and #CC_WaO_Init                ; just initialized - CC_WaO_Init
                    bne RetObjMoveManu
                    
                    lda CCW_ObjSpriteColMax
                    cmp CC_WaO_ObjectGridCol,y
                    bcc RetObjMoveManu
                    
                    clc
                    lda CC_WaO_ObjectGridCol,y
                    adc CC_WaO_ObjectCols,y
                    cmp CCW_ObjSpriteCol
                    bcc RetObjMoveManu
                    
                    lda CCW_ObjSpriteRowMax
                    cmp CC_WaO_ObjectGridRow,y
                    bcc RetObjMoveManu
                    
                    clc
                    lda CC_WaO_ObjectGridRow,y
                    adc CC_WaO_ObjectRows,y
                    cmp CCW_ObjSpriteRow
                    bcc RetObjMoveManu
                    
                    lda #CCW_ObjCollideNo
                    sta CCW_ObjSpriteCollide
                    
.DynSprite          lda CC_WaS_SpriteType,x         ; $00=Player $01=Spark $02=Force $03=Mummy $04=Beam $05=Frank
                    asl a
                    asl a
                    asl a                           ; *8
                    tay
                    lda SpriteObjectKill,y
                    sta .___SprtTypAdrLo
                    lda SpriteObjectKill+1,y
                    sta .___SprtTypAdrHi
                    beq .DynObject
                    
                    ldy CCW_ObjWAOffHit             ; offset status work area block to handle
                    
.JmpSprtObjKill     dc.b $4c                        ; jmp $31aa
.___SprtTypAdrLo    dc.b $aa
.___SprtTypAdrHi    dc.b $31
                    
RetSprtObjKill      ldy CCW_ObjWAOffHit             ; offset status work area block to handle
                    
                    lda CCW_ObjSpriteCollide
                    cmp #CCW_ObjCollideNo
                    bne .DynObject
                    
                    lda CC_WaS_SpriteFlag,x         ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    ora #CC_WaS_FlagDead            ;            $10=action   $20=death          $40=dead           $80=init
                    sta CC_WaS_SpriteFlag,x         ; 
                    
.DynObject          ldy CCW_ObjWAOffHit             ; offset status work area block to handle
                    lda CC_WaO_ObjectType,y         ; object type ($00-$0f)
                    asl a
                    asl a                           ; *4
                    tay
                    lda ObjectMoveManu,y            ; $00-Door        $01-Bell           LightBall   $03-LightSwitch 
                    sta .___ObjTypAdrLo             ; $04-Force       $05-Mummy      $06-Key         $07-Lock        
                    lda ObjectMoveManu+1,y          ;     Gun         $09-GunSwitch  $0a-MTRecOval       TrapDoor    
                    sta .___ObjTypAdrHi             ;     TrapSwitch  $0d-WalkWay    $0e-WalkSwitch      Frank       
                    beq RetObjMoveManu
                    
                    ldy CCW_ObjWAOffHit             ; offset status work area block to handle
                    
.JmpObjMoveManu     dc.b $4c                        ; jmp $31da
.___ObjTypAdrLo     dc.b $da
.___ObjTypAdrHi     dc.b $31
                    
RetObjMoveManu      lda CCW_ObjWAOffHit             ; offset status work area block to handle
                    clc
                    adc #CC_WaO_DataLen             ; point to next status work area block
                    
                    tay
                    cpy CCW_ObjWAOffFree            ; next free status work area block
                    beq SprtBkgrHandlerX
                    
                    jmp .NextWAObjs
                    
SprtBkgrHandlerX    pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
; PaintRoomItems    Function: 
;                   Parms   : Pointer ($3e/$3f) to CC_Obj_IDLow of CC_LevelGame
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
PaintRoomItems      subroutine
.SetObjectPtr       ldy #CC_Obj_IdLow               ; CC_Obj_IdDoor - CC_Obj_IdGraphic
                    lda (CCZ_RoomItem),y            ; 
                    sta .___ObjAdrLo                ; 
                    iny                             ; CC_Obj_IdHigh
                    lda (CCZ_RoomItem),y            ; 
                    sta .___ObjAdrHi                ; 
                    
                    clc                             ; 
                    lda CCZ_RoomItemLo              ; 
                    adc #CC_Obj_IdLen               ; 2 byte object id
                    sta CCZ_RoomItemLo              ; 
                    bcc .ChkEndOfRoomObjs           ; 
                    inc CCZ_RoomItemHi              ; object data starts behind the id
                    
.ChkEndOfRoomObjs   lda .___ObjAdrHi                ; 
                    beq PaintRoomItemsX             ; CC_Obj_IdEndOfData - all data processed
                    
.JsrObj             dc.b $20                        ; jsr selected room item sub routine (init: jsr $1601)
.___ObjAdrLo        dc.b $01                        ;   from jump table at
.___ObjAdrHi        dc.b $16                        ;   $0803 - $0836
                    
                    jmp .SetObjectPtr               ; get next object
                    
PaintRoomItemsX     rts
; ------------------------------------------------------------------------------------------------------------- ;
; RoomDoor          Function: Paint a chambers door - Called from: PaintRoomItems
;                   Parms   : Pointer ($3e/$3f) to CC_Obj_Door of CC_LevelGame
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
RoomDoor            subroutine
                    ldy #CC_Obj_DoorCount           ; 
                    lda (CCZ_RoomDoor),y            ; door object
                    sta CCW_DoorCount               ; CC_Obj_DoorCount = number of doors in room
                    
                    inc CCZ_RoomItemLo              ; 
                    bne .SavPtr                     ; 
                    inc CCZ_RoomItemHi              ; point to door data
                    
.SavPtr             lda CCZ_RoomItemLo              ; 
                    sta CCW_DoorDataPtrLo           ; 
                    lda CCZ_RoomItemHi              ; 
                    sta CCW_DoorDataPtrHi           ; 
                    
                    lda #$00                        ; 
                    sta CCW_DoorCountWrk            ; 
                    
.ChkNextDoor        lda CCW_DoorCountWrk            ; 
                    cmp CCW_DoorCount               ; 
                    bne .NextDoor                   ; 
                    
.Exit               jmp RoomDoorX                   ; all room doors handled
                    
.NextDoor           ldy #CC_Obj_DoorType            ; $00=normal $01=exit
                    lda (CCZ_RoomDoor),y            ; door object
                    tax                             ; 
                    lda TabRoomDoorType,x           ; object: doortab - normal/exit
                    sta CCZ_PntObj00PrmNo           ; 
                    
                    ldy #CC_Obj_DoorGridCol         ; 
                    lda (CCZ_RoomDoor),y            ; door object
                    sta CCZ_PntObj00PrmGridCol      ; 
                    
                    ldy #CC_Obj_DoorGridRow         ; 
                    lda (CCZ_RoomDoor),y            ; door object
                    sta CCZ_PntObj00PrmGridRow      ; 
                    
                    lda #CCZ_PntObjPrmType00        ; 
                    sta CCZ_PntObjPrmType           ; 
                    
.PaintDoor          jsr PaintObject                 ; 
                    jsr InitObjectWA                ; XR=ObjectWAOffset
                    
                    clc                             ; 
                    lda CCZ_PntObj00PrmGridCol      ; 
                    adc #CC_GridWidth               ; 
                    sta CCZ_PntObj00PrmGridCol      ; 
                    clc                             ; 
                    lda CCZ_PntObj00PrmGridRow      ; 
                    adc #CC_GridHeight * 2          ; 
                    sta CCZ_PntObj00PrmGridRow      ; 
                    
                    lda CCW_DoorCountWrk            ; 
                    sta CC_WaO_TypDoorNo,x          ; 
                    lda #CC_WaO_Door                ; 
                    sta CC_WaO_ObjectType,x         ; 
                    
                    ldy #CC_Obj_DoorToRoomNo        ; 
                    lda (CCZ_RoomDoor),y            ; door object
                    
                    jsr SetRoomDataPtr              ; 
                    
                    ldy #CC_Obj_RoomColor           ; 
                    lda (CCZ_RoomData),y            ; TargetRoomDataPtr
                    and #CC_Obj_RoomColorMask       ; ....####
                    sta CC_WaO_TypDoorTargColor,x   ; 
                    asl a                           ; *2
                    asl a                           ; *4
                    asl a                           ; *8
                    asl a                           ; *16
                    ora CC_WaO_TypDoorTargColor,x   ; 
                    sta CC_WaO_TypDoorTargColor,x   ;  
                    
                    ldy #CC_Obj_DoorInWallId        ; 
                    lda (CCZ_RoomDoor),y            ; door object
                    and #CC_Obj_DoorOpen            ; isolate Bit 7
                    bne .Open                       ; 1=door open
                    
                    lda #NoObjDoorGrate             ; object: Door Grating
                    jmp .SetObjNo                   ; 
                    
.Open               lda #CC_WaO_TypDoorOpen         ; 
                    sta CC_WaO_TypDoorFlag,x        ; 
                    
                    ldy #$05                        ; 
                    lda CC_WaO_TypDoorTargColor,x   ; color
.OpenColor          sta ColObjDoorGround,y          ; object: Open Door Ground
                    dey                             ; 
                    bpl .OpenColor                  ; 
                    
                    lda #NoObjDoorGround            ; object: Open Door Ground
.SetObjNo           sta CCZ_PntObj00PrmNo           ; 
                    
.PaintGrtGrnd       jsr PaintWAObjTyp0              ; grating or ground
                    
.SetNextDoor        clc                             ; 
                    lda CCZ_RoomItemLo              ; 
                    adc #CC_Obj_DoorDataLen         ; $08 = length of each door data entry
                    sta CCZ_RoomItemLo              ; 
                    bcc .SetCount                   ; 
                    inc CCZ_RoomItemHi              ; 
                    
.SetCount           inc CCW_DoorCountWrk            ; 
                    jmp .ChkNextDoor                ; 
                    
RoomDoorX           rts
; ------------------------------------------------------------------------------------------------------------- ;
; RoomFloor         Function: Paint a chambers floors - Called from: PaintRoomItems
;                   Parms   : Pointer ($3e/$3f) to CC_Obj_Floor of CC_LevelGame
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
RoomFloor           subroutine 
.NextFloor          ldy #CC_Obj_FloorLength         ; 
                    lda (CCZ_RoomFloor),y           ; floor object
                    sta CCW_FloorLen                ; 
                    bne .Floor                      ; 00=EndOfFloors
                    
                    inc CCZ_RoomItemLo              ; 
                    bne .Exit
                    inc CCZ_RoomItemHi              ; point behind EndOfFloorData
                    
.Exit               jmp RoomFloorX                  ; all floors handled
                    
.Floor              ldy #CC_Obj_FloorGridCol        ; 
                    lda (CCZ_RoomFloor),y           ; floor object
                    sta CCZ_PntObj00PrmGridCol      ; 
                    ldy #CC_Obj_FloorGridRow        ; 
                    lda (CCZ_RoomFloor),y           ; floor object
                    sta CCZ_PntObj00PrmGridRow      ; 
                    lda #$01                        ; 
                    sta CCW_FloorLenWrk             ; 
                    
                    lda CCZ_PntObj00PrmGridCol      ; 
                    lsr a                           ; /2
                    lsr a                           ; /4
                    sec                             ; 
                    sbc #$04                        ; 
                    sta CCW_CtrlScrnColNo           ; 
                    
                    lda CCZ_PntObj00PrmGridRow      ; 
                    lsr a                           ; /2
                    lsr a                           ; /4
                    lsr a                           ; /8
                    sta CCW_CtrlScrnRowNo           ; 
                    
                    jsr SetCtrlScrnPtr              ; point to control screen output address $c000-$c7ff
                    
.FloorPaint         lda CCW_FloorLenWrk             ; 
                    cmp #$01                        ; start
                    beq .FloorStart                 ; yes
                    
                    cmp CCW_FloorLen                ; 
                    beq .FloorEnd                   ; 
                    
.FloorMid           lda #NoObjFloorMid              ; object: Floor Middle Tile 
                    jmp .SetObj                     ; 
                    
.FloorStart         lda #NoObjFloorStart            ; object: Floor Start  Tile
                    jmp .SetObj                     ; 
                    
.FloorEnd           lda #NoObjFloorEnd              ; object: Floor End    Tile
                    
.SetObj             sta CCZ_PntObj00PrmNo           ; 
                    
                    lda #CCZ_PntObjPrmType00        ; 
                    sta CCZ_PntObjPrmType           ; 
                    
.PaintFloorTile     jsr PaintObject                 ; 
                    
                    lda #CCW_FloorStart             ; 
                    sta CCW_FloorIdx                ; 
                    
.FloorCtrl          lda CCW_FloorLenWrk             ; 
                    cmp #CCW_FloorStart             ; start
                    beq .CtrlChkStart               ; 
                    
                    cmp CCW_FloorLen                ; 
                    beq .CtrlChkEnd                 ; end
                    
.CtrlMid            lda #CC_CtrlFloorMid            ; ctrlObj: Floor Middle Tile
                    jmp .SetCtrl                    ; 
                    
.CtrlChkStart       lda CCW_FloorIdx                ; 
                    cmp #CCW_FloorStart             ; start
                    bne .CtrlMid                    ; 
                    
                    lda #CC_CtrlFloorStrt           ; ctrlObj: Floor Start  Tile
                    jmp .SetCtrl                    ; 
                    
.CtrlChkEnd         lda CCW_FloorIdx                ; 
                    cmp CCZ_PntObj00Cols            ; end
                    bne .CtrlMid                    ; 
                    
                    lda #CC_CtrlFloorEnd            ; ctrlObj: Floor End    Tile
                    
.SetCtrl            ldy #$00                        ; 
                    ora (CCZ_CtrlScreen),y          ; 
                    sta (CCZ_CtrlScreen),y          ; point to control screen output address $c000-$c7ff
                    
                    inc CCW_FloorIdx                ; floor tile counter
                    
                    clc                             ; 
                    lda CCZ_CtrlScreenLo            ; 
                    adc #$02                        ; update every second position
                    sta CCZ_CtrlScreenLo            ; 
                    bcc .CtrlChkDone                ; 
                    inc CCZ_CtrlScreenHi            ; point to control screen output address $c000-$c7ff
                    
.CtrlChkDone        lda CCW_FloorIdx                ; 
                    cmp CCZ_PntObj00Cols            ; end
                    bcc .FloorCtrl                  ; lower
                    beq .FloorCtrl                  ; equal
                    
                    lda CCZ_PntObj00Cols            ; 
                    asl a                           ; *2
                    asl a                           ; *4
                    clc                             ; 
                    adc CCZ_PntObj00PrmGridCol      ; 
                    sta CCZ_PntObj00PrmGridCol      ; 
                    
                    inc CCW_FloorLenWrk             ; 
                    lda CCW_FloorLenWrk             ; 
                    cmp CCW_FloorLen                ; 
                    beq .GoFloorPaint               ; 
                    bcs .SetNextFloor               ; floor handled completely
                    
.GoFloorPaint       jmp .FloorPaint                 ; 
                    
.SetNextFloor       lda CCZ_RoomItemLo              ; 
                    clc                             ; 
                    adc #CC_Obj_FloorDataLen        ; $03 = floor data entry length
                    sta CCZ_RoomItemLo              ; 
                    bcc .GoNextFloor                ; 
                    inc CCZ_RoomItemHi              ; 
                    
.GoNextFloor        jmp .NextFloor                  ; 
                    
RoomFloorX          rts
; ------------------------------------------------------------------------------------------------------------- ;
; RoomPole          Function: Paint a chambers poles - Called from: PaintRoomItems
;                   Parms   : Pointer ($3e/$3f) to CC_Obj_Pole of CC_LevelGame
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
RoomPole            subroutine
.NextPole           ldy #CC_Obj_PoleLength          ; 
                    lda (CCZ_RoomPole),y            ; pole object
                    bne .Pole                       ; 
                    
                    inc CCZ_RoomItemLo              ; 
                    bne .Exit                       ; 
                    inc CCZ_RoomItemHi              ; point behind EndOfPoleData
                    
.Exit               jmp RoomPoleX                   ; 
                    
.Pole               sta CCW_PoleLen                 ; 
                    ldy #CC_Obj_PoleGridCol         ; 
                    lda (CCZ_RoomPole),y            ; pole object
                    sta CCZ_PntObj00PrmGridCol      ; 
                    ldy #CC_Obj_PoleGridRow         ; 
                    lda (CCZ_RoomPole),y            ; pole object
                    sta CCZ_PntObj00PrmGridRow      ; 
                    
                    lda CCZ_PntObj00PrmGridCol      ; 
                    lsr a                           ; /2
                    lsr a                           ; /4
                    sec                             ; 
                    sbc #$04                        ; 
                    sta CCW_CtrlScrnColNo           ; 
                    
                    lda CCZ_PntObj00PrmGridRow      ; 
                    lsr a                           ; /2
                    lsr a                           ; /4
                    lsr a                           ; /8
                    sta CCW_CtrlScrnRowNo           ; 
                    
                    jsr SetCtrlScrnPtr              ; point to control screen output address $c000-$c7ff
                    
.ChkFloor           ldy #$00                        ; 
                    lda (CCZ_CtrlScreen),y          ; 
                    and #CC_CtrlFloorMid            ; detect any floor tile type (start/middle/end)
                    beq .SetObjPole                 ; 
                    
                    sec                             ; 
                    lda CCZ_PntObj00PrmGridCol      ; 
                    sbc #CC_GridWidth               ; 
                    sta CCZ_PntObj01PrmGridCol      ; 
                    lda CCZ_PntObj00PrmGridRow      ; 
                    sta CCZ_PntObj01PrmGridRow      ; 
                    
                    lda #NoObjPolePassFl            ; object: Pole Passes Floor
                    sta CCZ_PntObj01PrmNo           ; 
                    
.ObjFrontCover      lda #NoObjPoleCover             ; object: Pole Front Floor Piece
                    sta CCZ_PntObj00PrmNo           ; 
                    lda #CCZ_PntObjPrmType02        ; 
                    sta CCZ_PntObjPrmType           ; 
                    
                    jmp .GoPolePaint                ; 
                    
.SetObjPole         lda #NoObjPole                  ; object: Pole
                    sta CCZ_PntObj00PrmNo           ; 
                    lda #CCZ_PntObjPrmType00        ; 
                    sta CCZ_PntObjPrmType           ; 
                    
.GoPolePaint        jsr PaintObject                 ; 
                    
.PoleCtrl           ldy #$00                        ; 
                    lda (CCZ_CtrlScreen),y          ; 
                    ora #CC_CtrlPole                ; ctrlObj: Pole
                    sta (CCZ_CtrlScreen),y          ; 
                    
                    dec CCW_PoleLen                 ; 
                    bne .NextCtrlRow                ; 
                    
                    clc                             ; 
                    lda CCZ_RoomItemLo              ; 
                    adc #CC_Obj_PoleDataLen         ; $03 = pole data entry length
                    sta CCZ_RoomItemLo              ; 
                    bcc .GoNextPole                 ; 
                    inc CCZ_RoomItemHi              ; point to next pole
                    
.GoNextPole         jmp .NextPole                   ; 
                    
.NextCtrlRow        clc                             ; 
                    lda CCZ_PntObj00PrmGridRow      ; 
                    adc #CC_GridHeight              ; 
                    sta CCZ_PntObj00PrmGridRow      ; 
                    
                    clc                             ; 
                    lda CCZ_CtrlScreenLo            ; 
                    adc #$50                        ; 
                    sta CCZ_CtrlScreenLo            ; 
                    bcc .GoChkFloor                 ; 
                    inc CCZ_CtrlScreenHi            ; point to next control screen row
                    
.GoChkFloor         jmp .ChkFloor                   ; 
                    
RoomPoleX           rts
; ------------------------------------------------------------------------------------------------------------- ;
; RoomLadder        Function: Paint a chambers ladders - Called from: PaintRoomItems
;                   Parms   : Pointer ($3e/$3f) to CC_Obj_Ladder of CC_LevelGame
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
RoomLadder          subroutine
.NextLadder         ldy #CC_Obj_LadderLength        ; 
                    lda (CCZ_RoomLadder),y          ; ladder object
                    bne .Ladder
                    
                    inc CCZ_RoomItemLo              ; 
                    bne .Exit                       ; 
                    inc CCZ_RoomItemHi              ; point behind EndOfLadderData
                    
.Exit               jmp RoomLadderX                 ; 
                    
.Ladder             sta CCW_LadderLen               ; 
                    ldy #CC_Obj_LadderGridCol       ; 
                    lda (CCZ_RoomLadder),y          ; ladder object
                    sta CCZ_PntObj00PrmGridCol      ; 
                    ldy #CC_Obj_LadderGridRow       ; 
                    lda (CCZ_RoomLadder),y          ; ladder object
                    sta CCZ_PntObj00PrmGridRow      ; 
                    
                    lda CCZ_PntObj00PrmGridCol      ; 
                    lsr a                           ; /2
                    lsr a                           ; /4
                    sec                             ; 
                    sbc #$04                        ; 
                    sta CCW_CtrlScrnColNo           ; 
                    
                    lda CCZ_PntObj00PrmGridRow      ; 
                    lsr a                           ; /2
                    lsr a                           ; /4
                    lsr a                           ; /8
                    sta CCW_CtrlScrnRowNo           ; 
                    
                    jsr SetCtrlScrnPtr              ; point to control screen output address $c000-$c7ff
                    
.ChkFloor           ldy #$00                        ; 
                    lda (CCZ_CtrlScreen),y          ; 
                    and #CC_CtrlFloorMid            ; detect any floor tile type (start/middle/end)
                    bne .PassFloor                  ; 
                    
                    lda #CCZ_PntObjPrmType00        ; 
                    sta CCZ_PntObjPrmType           ; 
                    
                    lda CCW_LadderLen               ; 
                    cmp #$01                        ; 
                    beq .ObjLadderTop               ; 
                    
.ObjLadderMid       lda #NoObjLadderMid             ; object: Ladder Mid
                    sta CCZ_PntObj00PrmNo           ; 
                    jmp .PaintLadder1               ; 
                    
.ObjLadderTop       lda #NoObjLadderTop             ; object: Ladder Top
                    sta CCZ_PntObj00PrmNo           ; 
                    jmp .PaintLadder1               ; 
                    
.PassFloor          lda #CCZ_PntObjPrmType02        ; 
                    sta CCZ_PntObjPrmType           ; 
                    
                    lda CCW_LadderLen               ; 
                    cmp #$01                        ; bottom
                    bne .ObjLadderPass              ; 
                    
.ObjLadderEnd       lda #NoObjLadderFloor           ; object: Ladder on Floor
                    sta CCZ_PntObj00PrmNo           ; 
                    lda #NoObjLadderXOn             ; object: Ladder Clear Floor
                    sta CCZ_PntObj01PrmNo           ; 
                    
                    lda CCZ_PntObj00PrmGridCol      ; 
                    sta CCZ_PntObj01PrmGridCol      ; 
                    lda CCZ_PntObj00PrmGridRow      ; 
                    sta CCZ_PntObj01PrmGridRow      ; 
                    
.PaintLadder1       jsr PaintObject                 ; 
                    
                    jmp .ChkCtrlTop                 ; 
                    
.ObjLadderPass      lda #NoObjLaddrPassFl           ; object: Ladder Pass Floor
                    sta CCZ_PntObj00PrmNo           ; 
                    lda #NoObjLadderXPa             ; object: Ladder Clear Floor
                    sta CCZ_PntObj01PrmNo           ; 
                    sec                             ; 
                    lda CCZ_PntObj00PrmGridCol      ; 
                    sbc #CC_GridWidth               ; 
                    sta CCZ_PntObj00PrmGridCol      ; 
                    sta CCZ_PntObj01PrmGridCol      ; 
                    lda CCZ_PntObj00PrmGridRow      ; 
                    sta CCZ_PntObj01PrmGridRow      ; 
                    
.PaintLadder2       jsr PaintObject                 ; 
                    
                    clc                             ; 
                    lda CCZ_PntObj00PrmGridCol      ; 
                    adc #CC_GridWidth               ; 
                    sta CCZ_PntObj00PrmGridCol      ; 
                    
.ChkCtrlTop         lda CCW_LadderLen               ; 
                    ldy #CC_Obj_LadderLength        ; 
                    cmp (CCZ_RoomLadder),y          ; ladder object
                    beq .LadderDec                  ; ctrlObj: Top tile consists of part 2 only
                    
.LadderSetBot       ldy #$00                        ; only set for MidOfLadder (not for TopOfLadder/BottomOfLadder)
                    lda (CCZ_CtrlScreen),y          ; 
                    ora #CC_CtrlLadderBot           ; ctrlObj: $01 - Ladder Part One - Bottom tile consists of part 1 only
                    sta (CCZ_CtrlScreen),y          ;                               
                    
.LadderDec          dec CCW_LadderLen               ; 
                    bne .LadderSetTop               ; 
                    
.LadderDone         clc                             ; this ladder finished
                    lda CCZ_RoomItemLo              ; 
                    adc #CC_Obj_LadderDataLen       ; $03 = ladder data entry length
                    sta CCZ_RoomItemLo              ; 
                    bcc .GoNextLadder               ; 
                    inc CCZ_RoomItemHi              ; point to next ladder
                    
.GoNextLadder       jmp .NextLadder                 ; 
                    
.LadderSetTop       ldy #$00                        ; 
                    lda (CCZ_CtrlScreen),y          ; 
                    ora #CC_CtrlLadderTop           ; ctrlObj: $10 - Ladder Part Two - Middle tile consists of both parts
                    sta (CCZ_CtrlScreen),y          ;                                - Top    tile consists of part 2 only
                    
.NextCtrlRow        clc                             ; 
                    lda CCZ_PntObj00PrmGridRow      ; 
                    adc #CC_GridHeight              ; 
                    sta CCZ_PntObj00PrmGridRow      ; 
                    
                    clc                             ; 
                    lda CCZ_CtrlScreenLo            ; 
                    adc #$50                        ; 
                    sta CCZ_CtrlScreenLo            ; 
                    bcc .GoChkFloor                 ; 
                    inc CCZ_CtrlScreenHi            ; point to next control screen row
                    
.GoChkFloor         jmp .ChkFloor                   ; 
                    
RoomLadderX         rts
; ------------------------------------------------------------------------------------------------------------- ;
; RoomDoorBell      Function: Paint a chambers door bells - Called from: PaintRoomItems
;                   Parms   : Pointer ($3e/$3f) to CC_Obj_DoorBell of CC_LevelGame
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
RoomDoorBell        subroutine
                    ldy #CC_Obj_BellCount           ; 
                    lda (CCZ_RoomBell),y            ; door bell object
                    sta CCW_BellCount               ; 
                    
                    inc CCZ_RoomItemLo              ; 
                    bne .ChkBellCount               ; 
                    inc CCZ_RoomItemHi              ; point to bell data
                    
.ChkBellCount       lda CCW_BellCount               ; 
                    beq RoomDoorBellX               ; 
                    
                    jsr InitObjectWA                ; XR=ObjectWAOffset
                    
                    lda #CC_WaO_DoorBell            ; 
                    sta CC_WaO_ObjectType,x         ; 
                    
                    ldy #CC_Obj_BellGridCol         ; 
                    lda (CCZ_RoomBell),y            ; door bell object
                    sta CCZ_PntObj00PrmGridCol      ; 
                    ldy #CC_Obj_BellGridRow         ; 
                    lda (CCZ_RoomBell),y            ; door bell object
                    sta CCZ_PntObj00PrmGridRow      ; 
                    
                    lda #NoObjDoorBell              ; object: Door Bell
                    sta CCZ_PntObj00PrmNo           ; 
                    
                    ldy #CC_Obj_BellTargetDoorNo    ; 
                    lda (CCZ_RoomBell),y            ; door bell object
                    sta CC_WaO_TypBellTargDoorNo,x  ; 
                    
                    ldy #CC_WaO_Door                ; 
.FindColor          lda CC_WaO_ObjectType,y         ; 
                    bne .SetNextEntry               ; no door (type=CC_WaO_Door)
                    
.ObjWADoor          lda CC_WaO_TypDoorNo,y          ;   doornumber Door
                    cmp CC_WaO_TypBellTargDoorNo,x  ; = doornumber Bell
                    bne .SetNextEntry               ; 
                    
                    lda CC_WaO_TypDoorTargColor,y   ; target room color
                    jmp .BellColorI                 ; 
                    
.SetNextEntry       tya                             ; 
                    clc                             ; 
                    adc #CC_WaO_DataLen             ; select next work area entry
                    tay                             ; 
                    jmp .FindColor                  ; 
                    
.BellColorI         ldy #$08                        ; 
.BellColor          sta ColObjDoorBell01,y          ; 
                    dey                             ; 
                    bpl .BellColor                  ; 
                    
                    lsr a                           ;  shift right nibble to right
                    lsr a                           ; 
                    lsr a                           ; 
                    lsr a                           ; 
                    ora #HR_WhiteBlack              ; ...#.... - set left nibble to white
.KnobColor          sta ColObjDoorBell02            ; 
                    
.PaintBell          jsr PaintWAObjTyp0              ; 
                    
                    clc                             ; 
                    lda CCZ_RoomItemLo              ; 
                    adc #CC_Obj_BellDataLen         ; $03 = length of each bell data entry
                    sta CCZ_RoomItemLo              ; 
                    bcc .BellCountDec               ; 
                    inc CCZ_RoomItemHi              ; 
                    
.BellCountDec       dec CCW_BellCount               ; 
                    jmp .ChkBellCount               ; 
                    
RoomDoorBellX       rts
; ------------------------------------------------------------------------------------------------------------- ;
; RoomLightMachine  Function: Paint a chambers lightning machines - Called from: PaintRoomItems
;                   Parms   : Pointer ($3e/$3f) to CC_Obj_Light of CC_LevelGame
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
RoomLightMachine    subroutine
                    lda CCZ_RoomItemLo              ; 
                    sta CCW_LightSwtchDataPtrLo     ; 
                    lda CCZ_RoomItemHi              ; 
                    sta CCW_LightSwtchDataPtrHi     ; 
                    
                    lda #$00                        ; 
                    sta CCW_LightBallNo             ; 
                    
.NextLM             ldy #CC_Obj_Light               ; 
                    lda (CCZ_RoomLight),y           ; lightning machine object
                    and #CC_Obj_LightEoData         ;
                    beq .LightMac                   ; 
                    
                    inc CCZ_RoomItemLo              ; 
                    bne .Exit                       ; 
                    inc CCZ_RoomItemHi              ; point behind EndOfLightData
                    
.Exit               jmp RoomLightMachineX           ; 
                    
.LightMac           jsr InitObjectWA                ; XR=ObjectWAOffset
                    
                    lda CCW_LightBallNo             ; 
                    sta CC_WaO_TypLightBallNo,x     ; 
                    
                    ldy #CC_Obj_LightMode           ; 
                    lda (CCZ_RoomLight),y           ; lightning machine object
                    and #CC_Obj_LightSwitchDown     ; 
                    beq .SetWrkBall                 ; 
                    
                    ldy #CC_Obj_LigthGridCol        ; 
                    lda (CCZ_RoomLight),y           ; lightning machine object
                    sta CCZ_PntObj00PrmGridCol      ; 
                    ldy #CC_Obj_LigthGridRow        ; 
                    lda (CCZ_RoomLight),y           ; lightning machine object
                    sta CCZ_PntObj00PrmGridRow      ; 
                    lda #CCZ_PntObjPrmType00        ; 
                    sta CCZ_PntObjPrmType           ; 
                    lda #NoObjLiMaSwFrm             ; object: Lightning Machine Switch Frame
                    sta CCZ_PntObj00PrmNo           ; 
                    
.PaintLMSFrame      jsr PaintObject                 ; 
                    
                    clc                             ; 
                    lda CCZ_PntObj00PrmGridCol      ; 
                    adc #CC_GridWidth               ; 
                    sta CCZ_PntObj00PrmGridCol      ;
                    clc                             ; 
                    lda CCZ_PntObj00PrmGridRow      ; 
                    adc #CC_GridHeight              ; 
                    sta CCZ_PntObj00PrmGridRow      ; 
                    
                    lda #CC_WaO_LightSwitch         ; 
                    sta CC_WaO_ObjectType,x         ; 
                    
                    ldy #CC_Obj_LightMode           ; 
                    lda (CCZ_RoomLight),y           ; lightning machine object
                    and #CC_Obj_LightBallOn         ; 
                    bne .SwitchUp                   ; 
                    
.SwitchDown         lda #NoObjLiMaSwDo              ; object: Lightning Machine Switch Down
                    jmp .SetSwitch                  ; 
                    
.SwitchUp           lda #NoObjLiMaSwUp              ; object: Lightning Machine Switch Up
.SetSwitch          sta CCZ_PntObj00PrmNo           ; 
                    
                    jsr PaintWAObjTyp0              ; 
                    
                    jmp .WrkBallNoInc               ; 
                    
.SetWrkBall         lda #CC_WaO_LightBall           ;  
                    sta CC_WaO_ObjectType,x         ; 
                    
                    ldy #CC_Obj_LigthGridCol        ; 
                    lda (CCZ_RoomLight),y           ; lightning machine object
                    sta CCZ_PntObj00PrmGridCol      ; 
                    ldy #CC_Obj_LigthGridRow        ; 
                    lda (CCZ_RoomLight),y           ; lightning machine object
                    sta CCZ_PntObj00PrmGridRow      ; 
                    
                    lda #CCZ_PntObjPrmType00        ; 
                    sta CCZ_PntObjPrmType           ;
                    
                    lda #NoObjLiMaPoleOn            ; object: Lightning Machine Pole On
                    sta CCZ_PntObj00PrmNo           ; 
                    
                    ldy #CC_Obj_LightPoleLen        ; 
                    lda (CCZ_RoomLight),y           ; lightning machine object
                    sta CCW_LightPoleLen            ; 
                    sta CC_WaO_TypLightPoleLen,x    ; 
                    
.Pole               lda CCW_LightPoleLen            ; 
                    beq .Ball                       ; 
                    
.PaintPole          jsr PaintObject                 ; 
                    
                    clc                             ; 
                    lda CCZ_PntObj00PrmGridRow      ; 
                    adc #CC_GridHeight              ; 
                    sta CCZ_PntObj00PrmGridRow      ; 
                    dec CCW_LightPoleLen            ; 
                    jmp .Pole                       ; 
                    
.Ball               sec                             ; 
                    lda CCZ_PntObj00PrmGridCol      ; 
                    sbc #CC_GridWidth               ; 
                    sta CCZ_PntObj00PrmGridCol      ; 
                    lda #NoObjLiMaBall              ; object: Lightning Machine Ball
                    sta CCZ_PntObj00PrmNo           ; 
                    
                    jsr PaintWAObjTyp0              ; 
                    
                    ldy #CC_Obj_LightMode           ; 
                    lda (CCZ_RoomLight),y           ; lightning machine object
                    and #CC_Obj_LightBallOn         ; 
                    beq .WrkBallNoInc               ; 
                    
                    lda CC_WaO_ObjectFlag,x         ; 
                    ora #CC_WaO_Ready               ; action completed - CC_WaO_Ready
                    sta CC_WaO_ObjectFlag,x         ; 
                    
.WrkBallNoInc       clc                             ; 
                    lda CCW_LightBallNo             ; 
                    adc #$08                        ; set next ball
                    sta CCW_LightBallNo             ; 
                    
                    clc                             ; 
                    lda CCZ_RoomItemLo              ; 
                    adc #CC_Obj_LightDataLen        ; $08 = lightning machine data entry length
                    sta CCZ_RoomItemLo              ; 
                    bcc .GoNextLM                   ; 
                    inc CCZ_RoomItemHi              ; 
                    
.GoNextLM           jmp .NextLM                     ; 
                    
RoomLightMachineX   rts
; ------------------------------------------------------------------------------------------------------------- ;
; RoomForceField    Function: Paint a chambers force fields - Called from: PaintRoomItems
;                   Parms   : Pointer ($3e/$3f) to CC_Obj_Force of CC_LevelGame
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
RoomForceField      subroutine
                    lda #$00                        ; 
                    sta CCW_ForceNo                 ; 
                    
.NextForceField     ldy #CC_Obj_ForceSwGridCol      ; 
                    lda (CCZ_RoomForce),y           ; force field object - switch
                    bne .ForceField                 ; 
                    
                    inc CCZ_RoomItemLo              ; 
                    bne .Exit
                    inc CCZ_RoomItemHi              ; point behind EndOfForceFieldData
                    
.Exit               jmp RoomForceFieldX             ; 
                    
.ForceField         jsr InitObjectWA                ; XR=ObjectWAOffset
                    
                    lda #CC_WaO_ForceField          ; 
                    sta CC_WaO_ObjectType,x         ; 
                    
                    ldy #CC_Obj_ForceSwGridCol      ; 
                    lda (CCZ_RoomForce),y           ; force field object - switch
                    sta CCZ_PntObj00PrmGridCol      ; 
                    ldy #CC_Obj_ForceSwGridRow      ; 
                    lda (CCZ_RoomForce),y           ; force field object
                    sta CCZ_PntObj00PrmGridRow      ; 
                    
                    lda #NoObjFoFiSwitch            ; object: Force Field Switch
                    sta CCZ_PntObj00PrmNo           ; 
                    lda #CCZ_PntObjPrmType00        ; 
                    sta CCZ_PntObjPrmType           ; 
                    
.PaintSwitch        jsr PaintObject                 ; 
                    
                    clc                             ; 
                    lda CCZ_PntObj00PrmGridCol      ; 
                    adc #CC_GridWidth               ; 
                    sta CCZ_PntObj00PrmGridCol      ; 
                    clc                             ; 
                    lda CCZ_PntObj00PrmGridRow      ; 
                    adc #CC_GridHeight              ; 
                    sta CCZ_PntObj00PrmGridRow      ; 
                    
                    lda #NoObjFoFiTime              ; object: Force Field Timer Square
                    sta CCZ_PntObj00PrmNo           ; 
                    
                    ldy #$07                        ; max amount
                    lda #$55                        ; .#.#.#.# - filler lines
.ColorTimer         sta DatObjFoFiTime01,y          ; 
                    dey                             ; 
                    bpl .ColorTimer                 ; 
                    
.PaintTimer         jsr PaintWAObjTyp0              ; 
                    
                    lda CCW_ForceNo                 ; 
                    sta CC_WaO_TypForceNo,x         ; 
                    tay                             ; 
                    lda #CCW_ForceClosed            ; 
                    sta CCW_ForceStatusTab,y        ; 
                    
                    jsr InitSpriteForce             ; 
                    
                    ldy #CC_Obj_ForceFiGridCol      ; 
                    lda (CCZ_RoomForce),y           ; force field object
                    sta CCZ_PntObj00PrmGridCol      ; 
                    ldy #CC_Obj_ForceFiGridRow      ; 
                    lda (CCZ_RoomForce),y           ; force field object
                    sta CCZ_PntObj00PrmGridRow      ; 
                    
                    lda #NoObjFoFiHead              ; object: Force Field Head
                    sta CCZ_PntObj00PrmNo           ; 
                    lda #CCZ_PntObjPrmType00        ; 
                    sta CCZ_PntObjPrmType           ; 
                    
.PaintHead          jsr PaintObject                 ; 
                    
                    inc CCW_ForceNo                 ; 
                    
                    clc                             ; 
                    lda CCZ_RoomItemLo              ; 
                    adc #CC_Obj_ForceDataLen        ; $04 = force field data entry length
                    sta CCZ_RoomItemLo              ; 
                    bcc .GoForceField               ; 
                    inc CCZ_RoomItemHi              ; 
                    
.GoForceField       jmp .NextForceField             ; 
                    
RoomForceFieldX     rts
; ------------------------------------------------------------------------------------------------------------- ;
; RoomMummy         Function: Paint a chambers mummies - Called from: PaintRoomItems
;                   Parms   : Pointer ($3e/$3f) to CC_Obj_Mummy of CC_LevelGame
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
RoomMummy           subroutine
                    lda #$00                        ; 
                    sta CCW_MummyDataNext           ; 
                    
                    lda CCZ_RoomItemLo              ; 
                    sta CCW_MummyDataPtrLo          ; 
                    lda CCZ_RoomItemHi              ; 
                    sta CCW_MummyDataPtrHi          ; 
                    
.NextMummy          ldy #CC_Obj_Mummy               ; 
                    lda (CCZ_RoomMummy),y           ; mummy object
                    cmp #CC_Obj_MummyEoData         ;
                    bne .Mummy                      ; 
                    
                    inc CCZ_RoomItemLo              ; 
                    bne .Exit                       ; 
                    inc CCZ_RoomItemHi              ; point behind EndOfMummyData
                    
.Exit               jmp RoomMummyX                  ; 
                    
.Mummy              jsr InitObjectWA                ; XR=ObjectWAOffset
                    
                    lda #CC_WaO_Mummy               ; 
                    sta CC_WaO_ObjectType,x         ; 
                    
                    ldy #CC_Obj_MummyAnkhGridCol    ; 
                    lda (CCZ_RoomMummy),y           ; mummy object
                    sta CCZ_PntObj00PrmGridCol      ; 
                    ldy #CC_Obj_MummyAnkhGridRow    ; 
                    lda (CCZ_RoomMummy),y           ; mummy object
                    sta CCZ_PntObj00PrmGridRow      ; 
                    
                    lda #NoObjMummyAnkh             ; object: Mummy Ankh
                    sta CCZ_PntObj00PrmNo           ; 
                    lda CCW_MummyDataNext           ; 
                    sta CC_WaO_TypMummyPtrWA,x      ; 
                    
                    ldy #$05                        ; 
                    lda #CC_Obj_MummAnkhColor       ; base color
                    sta CC_WaO_TypMummyAnkhColor,x  ; 
.ColorAnkh          sta ColObjMummyAnkh,y           ; 
                    dey                             ; 
                    bpl .ColorAnkh                  ; 
                    
.PaintAnkh          jsr PaintWAObjTyp0              ; 
                    
                    lda #CCW_MummyWallRowsMax       ; 
                    sta CCW_MummyWallRows           ; 3 brick rows per wall
                    
                    ldy #CC_Obj_MummyWallGridRow    ; 
                    lda (CCZ_RoomMummy),y           ; mummy object
                    sta CCZ_PntObj00PrmGridRow      ; 
                    lda #CCZ_PntObjPrmType00        ; 
                    sta CCZ_PntObjPrmType           ; 
                    
.PaintWallI         lda #NoObjMummyWall             ; .hbu009. - object: Mummy Wall Brick
                    sta CCZ_PntObj00PrmNo           ; 
                    
.PaintWallII        lda #CCW_MummyWallColsMax - 1   ; .hbu009. - discount the end piece
                    sta CCW_MummyWallCols           ; 
                    ldy #CC_Obj_MummyWallGridCol    ; 
                    lda (CCZ_RoomMummy),y           ; mummy object
                    sta CCZ_PntObj00PrmGridCol      ; 
                    
.PaintWallBrick     jsr PaintObject                 ; 
                    
                    clc                             ; 
                    lda CCZ_PntObj00PrmGridCol      ; 
                    adc #CC_GridWidth               ; 
                    sta CCZ_PntObj00PrmGridCol      ; 
                    
                    dec CCW_MummyWallCols           ; 
                    bmi .SetNextRow                 ; .hbu009. - end piece painted already
                    bne .PaintWallBrick             ; .hbu009.
                    
.SetWallEnd         lda #NoObjMummyWallEnd          ; .hbu009. - object: Mummy Wall Brick End
                    sta CCZ_PntObj00PrmNo           ; .hbu009.
                    jmp .PaintWallBrick             ; .hbu009. - always
                    
.SetNextRow         clc                             ; 
                    lda CCZ_PntObj00PrmGridRow      ; 
                    adc #CC_GridHeight              ; 
                    sta CCZ_PntObj00PrmGridRow      ; 
                    
                    dec CCW_MummyWallRows           ; 
                    bne .PaintWallI                 ; 
                    
                    ldy #CC_Obj_MummyStatus         ; $01=in  $02=out $03=dead
                    lda (CCZ_RoomMummy),y           ; mummy object
                    cmp #CC_Obj_MummyIn             ; 
                    beq .MummyIn                    ; 
                    
                    ldy #CC_Obj_MummyWallGridCol    ; 
                    lda (CCZ_RoomMummy),y           ; mummy object
                    clc                             ; 
                    adc #CC_GridWidth               ; 
                    sta CCZ_PntObj01PrmGridCol      ; 
                    ldy #CC_Obj_MummyWallGridRow    ; 
                    lda (CCZ_RoomMummy),y           ; mummy object
                    clc                             ; 
                    adc #CC_GridHeight              ; 
                    sta CCZ_PntObj01PrmGridRow      ; 
                    
                    lda #CCZ_PntObjPrmType01        ; 
                    sta CCZ_PntObjPrmType           ; 
                    lda #NoObjMummyWall             ; object: Mummy Wall Brick
                    sta CCZ_PntObj01PrmNo           ; 
                    
                    lda #CCW_MummyWallRowsMax       ; 
                    sta CCW_MummyWallRows           ; 3 brick rows per wall
                    
.PaintOpenBrick     jsr PaintObject                 ; 
                    
                    clc                             ; 
                    lda CCZ_PntObj01PrmGridCol      ; 
                    adc #CC_GridWidth               ; 
                    sta CCZ_PntObj01PrmGridCol      ; 
                    
                    dec CCW_MummyWallRows           ; 
                    bne .PaintOpenBrick             ; 
                    
                    lda CCZ_PntObj01PrmGridCol      ; 
                    sec                             ; 
                    sbc #$0c                        ; 
                    sta CCZ_PntObj00PrmGridCol      ; 
                    lda CCZ_PntObj01PrmGridRow      ; 
                    sta CCZ_PntObj00PrmGridRow      ; 
                    
                    lda #NoObjMummyOut              ; object: Mummy Wall Open
                    sta CCZ_PntObj00PrmNo           ; 
                    lda #CCZ_PntObjPrmType00        ; 
                    sta CCZ_PntObjPrmType           ; 
                    
.PaintWallOpen      jsr PaintObject                 ; 
                    
                    ldy #CC_Obj_MummyStatus         ; $01=in  $02=out $03=dead
                    lda (CCZ_RoomMummy),y           ; mummy object
                    cmp #CC_Obj_MummyOut            ; 
                    bne .MummyIn                    ; 
                    
.MummyOut           lda #$ff                        ; flag: mummy in wall
                    jsr InitSpriteMummy             ; 
                    
.MummyIn            lda CCZ_RoomItemLo              ; 
                    clc                             ; 
                    adc #CC_Obj_MummyDataLen        ; $07 = mummy data entry length
                    sta CCZ_RoomItemLo              ; 
                    bcc .GoNextMummy                ; 
                    inc CCZ_RoomItemHi              ; 
                    
.GoNextMummy        clc                             ; 
                    lda CCW_MummyDataNext           ; 
                    adc #CC_Obj_MummyDataLen        ; 
                    sta CCW_MummyDataNext           ; 
                    jmp .NextMummy                  ; 
                    
RoomMummyX          rts
; ------------------------------------------------------------------------------------------------------------- ;
; RoomKey           Function: Paint a chambers keys - Called from: PaintRoomItems
;                   Parms   : Pointer ($3e/$3f) to CC_Obj_Key of CC_LevelGame
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
RoomKey             subroutine
                    lda CCZ_RoomItemLo              ; 
                    sta CCW_KeyDataPtrLo            ; 
                    lda CCZ_RoomItemHi              ; 
                    sta CCW_KeyDataPtrHi            ; 
                    
                    lda #$00                        ; 
                    sta CCW_KeyDataNext             ; 
                    
.NextKey            ldy #CC_Obj_Key                 ; 
                    lda (CCZ_RoomKey),y             ; key object
                    bne .Key                        ; 
                    
                    inc CCZ_RoomItemLo              ; 
                    bne .Exit                       ; 
                    inc CCZ_RoomItemHi              ; point behind EndOfKeyData
                    
.Exit               jmp RoomKeyX                    ; 
                    
.Key                ldy #CC_Obj_KeyStatus           ; 
                    lda (CCZ_RoomKey),y             ; key object
                    beq .SetNextKeyWAPos            ; 
                    
                    jsr InitObjectWA                ; XR=ObjectWAOffset
                    
                    lda #CC_WaO_Key                 ; 
                    sta CC_WaO_ObjectType,x         ; 
                    
                    ldy #CC_Obj_KeyGridCol          ; 
                    lda (CCZ_RoomKey),y             ; key object
                    sta CCZ_PntObj00PrmGridCol      ; 
                    ldy #CC_Obj_KeyGridRow          ; 
                    lda (CCZ_RoomKey),y             ; key object
                    sta CCZ_PntObj00PrmGridRow      ; 
                    
                    ldy #CC_Obj_KeyStatus           ; 
                    lda (CCZ_RoomKey),y             ; .hbu001. - recalc the room data key object numbers $51-$57
                    and #$0f                        ; .hbu001. - ....#### - isolate colors
                    sec                             ; .hbu001.
                    adc #NoObjKeyTab                ; .hbu001. - add new object offset - make key objects moveable
                    sta CCZ_PntObj00PrmNo           ; .hbu001. - object: Keys 1-7
                    
                    lda CCW_KeyDataNext             ; 
                    sta CC_WaO_TypKeyData,x         ; 
                    
.PaintKey           jsr PaintWAObjTyp0              ; 
                    
.SetNextKeyWAPos    clc                             ; 
                    lda CCW_KeyDataNext             ; 
                    adc #CC_Obj_KeyDataLen          ; 
                    sta CCW_KeyDataNext             ; 
                    
                    clc                             ; 
                    lda CCZ_RoomItemLo              ; 
                    adc #CC_Obj_KeyDataLen          ; $04 = key data entry length
                    sta CCZ_RoomItemLo              ; 
                    bcc .NextKey                    ; 
                    inc CCZ_RoomItemHi              ; 
                    jmp .NextKey                    ; 
                    
RoomKeyX            rts
; ------------------------------------------------------------------------------------------------------------- ;
; RoomLock          Function: Paint a chambers locks - Called from: PaintRoomItems
;                   Parms   : Pointer ($3e/$3f) to CC_Obj_Lock of CC_LevelGame
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
RoomLock            subroutine
.NextLock           ldy #$00                        ; 
                    lda (CCZ_RoomLock),y            ; lock object
                    beq .Exit                       ; 
                    
                    jsr InitObjectWA                ; XR=ObjectWAOffset
                    
                    lda #CC_WaO_Lock                ; 
                    sta CC_WaO_ObjectType,x         ; 
                    
                    ldy #CC_Obj_LockGridCol         ; 
                    lda (CCZ_RoomLock),y            ; lock object
                    sta CCZ_PntObj00PrmGridCol      ; 
                    ldy #CC_Obj_LockGridRow         ; 
                    lda (CCZ_RoomLock),y            ; lock object
                    sta CCZ_PntObj00PrmGridRow      ; 
                    
                    ldy #CC_Obj_LockColor           ; 
                    lda (CCZ_RoomLock),y            ; lock object
                    asl a                           ; shift color to left nibble
                    asl a                           ; 
                    asl a                           ; 
                    asl a                           ; 
                    ora (CCZ_RoomLock),y            ; lock object
                    
                    ldy #$08                        ; 
.ColorLock          sta ColObjLock,y                ; 
                    dey                             ; 
                    bpl .ColorLock                  ; 
                    
                    lda #NoObjLock                  ; object: Lock
                    sta CCZ_PntObj00PrmNo           ; 
                    
                    ldy #CC_Obj_LockColor           ; 
                    lda (CCZ_RoomLock),y            ; lock object
                    sta CC_WaO_TypLockColor,x       ; 
                    ldy #CC_Obj_LockTargetDoorNo    ; 
                    lda (CCZ_RoomLock),y            ; lock object
                    sta CC_WaO_TypLockTargDoorNo,x  ; 
                    
.PaintLock          jsr PaintWAObjTyp0              ; 
                    
                    clc                             ; 
                    lda CCZ_RoomItemLo              ; 
                    adc #CC_Obj_LockDataLen         ; $05 = lock data entry length
                    sta CCZ_RoomItemLo              ; 
                    bcc .NextLock                   ; 
                    inc CCZ_RoomItemHi              ; 
                    jmp .NextLock                   ; 
                    
.Exit               inc CCZ_RoomItemLo              ; 
                    bne RoomLockX                   ; 
                    inc CCZ_RoomItemHi              ; 
                    
RoomLockX           rts
; ------------------------------------------------------------------------------------------------------------- ;
; RoomDrawObject    Function: Paint chamber objects - Never called from: PaintRoomItems - Used in: RoomTitleScreen
;                   Parms   : Pointer ($3e/$3f) to CC_Obj_Draw of CC_LevelGame
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
RoomDrawObject      subroutine
                    lda #CCZ_PntObjPrmType00        ; 
                    sta CCZ_PntObjPrmType           ; 
                    
.NextObject         ldy #CC_Obj_Count               ; 
                    lda (CCZ_RoomItem),y            ; room object
                    beq .Exit                       ; 
                    
                    sta CCW_DrawObjCount            ; 
                    
                    ldy #CC_Obj_DrawObjectId        ; 
                    lda (CCZ_RoomItem),y            ; room object
                    sta CCZ_PntObj00PrmNo           ; 
                    
                    ldy #CC_Obj_DrawGridCol         ;
                    lda (CCZ_RoomItem),y            ; room object
                    sta CCZ_PntObj00PrmGridCol      ;
                    ldy #CC_Obj_DrawGridRow         ;
                    lda (CCZ_RoomItem),y            ; room object
                    sta CCZ_PntObj00PrmGridRow      ;
                    
.PaintNextObject    jsr PaintObject                 ; 
                    
                    dec CCW_DrawObjCount            ; 
                    beq .GoNextObject               ; 
                    
                    clc                             ; 
                    ldy #CC_Obj_DrawGridColOff      ; 
                    lda CCZ_PntObj00PrmGridCol      ; 
                    adc (CCZ_RoomItem),y            ; room object
                    sta CCZ_PntObj00PrmGridCol      ; 
                    ldy #CC_Obj_DrawGridRowOff      ; 
                    clc                             ; 
                    lda CCZ_PntObj00PrmGridRow      ; 
                    adc (CCZ_RoomItem),y            ; room object
                    sta CCZ_PntObj00PrmGridRow      ; 
                    jmp .PaintNextObject            ; 
                    
.GoNextObject       clc                             ; 
                    lda CCZ_RoomItemLo              ; 
                    adc #CC_Obj_DrawDataLen         ; $06 = length graphic data entry
                    sta CCZ_RoomItemLo              ; 
                    bcc .NextObject                 ; 
                    inc CCZ_RoomItemHi              ; 
                    jmp .NextObject                 ; 
                    
.Exit               inc CCZ_RoomItemLo              ; 
                    bne RoomDrawObjectX             ; 
                    inc CCZ_RoomItemHi              ;
                    
RoomDrawObjectX     rts
; ------------------------------------------------------------------------------------------------------------- ;
; RoomRayGun        Function: Paint a chambers ray guns - Called from: PaintRoomItems
;                   Parms   : Pointer ($3e/$3f) to CC_Obj_Gun of CC_LevelGame
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
RoomRayGun          subroutine
                    lda CCZ_RoomItemLo              ; 
                    sta CCW_GunDataPtrLo            ; 
                    lda CCZ_RoomItemHi              ; 
                    sta CCW_GunDataPtrHi            ; 
                    
                    lda #$00                        ; 
                    sta CCW_GunDataNext             ; 
                    
.NextGun            ldy #CC_Obj_Gun                 ; 
                    lda (CCZ_RoomGun),y             ; ray gun object
                    and #CC_Obj_GunEoData           ; 
                    beq .Gun                        ; 
                    
                    inc CCZ_RoomItemLo              ; 
                    bne .Exit                       ; 
                    inc CCZ_RoomItemHi              ; point behind EndOfRayGunData
                    
.Exit               jmp RoomRayGunX
                    
.Gun                lda #$ff                        ; senseless - results in $00/$01 as before
                    eor #CC_Obj_GunShoots           ; 
                    and (CCZ_RoomGun),y             ; ray gun object - CC_Obj_GunDirection
                    sta (CCZ_RoomGun),y             ; ray gun object - CC_Obj_GunDirection
                    
                    ldy #CC_Obj_GunPoleGridCol      ; 
                    lda (CCZ_RoomGun),y             ; ray gun object
                    sta CCZ_PntObj00PrmGridCol      ; 
                    ldy #CC_Obj_GunPoleGridRow      ; 
                    lda (CCZ_RoomGun),y             ; ray gun object
                    sta CCZ_PntObj00PrmGridRow      ; 
                    
                    lda #CCZ_PntObjPrmType00        ; 
                    sta CCZ_PntObjPrmType           ; 
                    
                    ldy #CC_Obj_GunDirection        ; 
                    lda (CCZ_RoomGun),y             ; ray gun object
                    and #CC_Obj_GunPointLeft        ;
                    bne .PoleLeft                   ; 
                    
.PoleRight          lda #NoObjGunPoleRi             ; object: Ray Gun Pole for Shooting Right
                    jmp .SetGunPole                 ; 
                    
.PoleLeft           lda #NoObjGunPoleLe             ; object: Ray Gun Pole for Shooting Left
.SetGunPole         sta CCZ_PntObj00PrmNo           ; 
                    
                    ldy #CC_Obj_GunPoleLen          ; 
                    lda (CCZ_RoomGun),y             ; ray gun object
                    sta CCW_GunPoleLen              ; 
                    
.Pole               lda CCW_GunPoleLen              ; 
                    beq .ChkWa                      ; 
                    
                    jsr PaintObject                 ; 
                    
                    clc                             ; 
                    lda CCZ_PntObj00PrmGridRow      ; 
                    adc #CC_GridHeight              ; 
                    sta CCZ_PntObj00PrmGridRow      ; 
                    
                    dec CCW_GunPoleLen              ; 
                    jmp .Pole                       ; 
                    
.ChkWa              ldy #CC_Obj_GunDirection        ; 
                    lda (CCZ_RoomGun),y             ; ray gun object
                    and #CC_Obj_GunSwitch           ; 
                    bne .SetWrkSwitch               ; 
                    
.SetWrkGun          jsr InitObjectWA                ; XR=ObjectWAOffset
                    
                    lda #CC_WaO_RayGun              ; 
                    sta CC_WaO_ObjectType,x         ; 
                    
                    lda CCW_GunDataNext             ; 
                    sta CC_WaO_TypGunPtrWA,x        ; 
                    lda CC_WaO_ObjectFlag,x         ; 
                    ora #CC_WaO_Ready               ; 
                    sta CC_WaO_ObjectFlag,x         ; 
                    
                    ldy #CC_Obj_GunPoleLen          ; 
                    lda (CCZ_RoomGun),y             ; ray gun object
                    asl a                           ; 
                    asl a                           ; 
                    asl a                           ; *8
                    ldy #CC_Obj_GunPoleGridRow      ; 
                    clc                             ; 
                    adc (CCZ_RoomGun),y             ; ray gun object
                    sec                             ; 
                    sbc #$0b                        ; 
                    sta CC_WaO_TypGunPoleBottom,x   ; save BottomOfPole
                    
                    ldy #CC_Obj_GunDirection        ; 
                    lda (CCZ_RoomGun),y             ; ray gun object
                    and #CC_Obj_GunPointLeft        ; 
                    bne .GunPosLeft                 ; 
                    
.GunPosRight        clc                             ; 
                    ldy #CC_Obj_GunPoleGridCol      ; 
                    lda (CCZ_RoomGun),y             ; ray gun object
                    adc #CC_GridWidth               ; 
                    jmp .SetGunPos                  ; 
                    
.GunPosLeft         sec                             ; 
                    ldy #CC_Obj_GunPoleGridCol      ; 
                    lda (CCZ_RoomGun),y             ; ray gun object
                    sbc #$08                        ; 
                    
.SetGunPos          sta CC_WaO_ObjectGridCol,x      ; 
                    
.SetWrkSwitch       jsr InitObjectWA                ; XR=ObjectWAOffset
                    
                    lda #CC_WaO_RayGunSwitch        ; 
                    sta CC_WaO_ObjectType,x         ; 
                    
                    ldy #CC_Obj_GunSwitchGridCol    ; 
                    lda (CCZ_RoomGun),y             ; ray gun object
                    sta CCZ_PntObj00PrmGridCol      ; 
                    ldy #CC_Obj_GunSwitchGridRow    ; 
                    lda (CCZ_RoomGun),y             ; ray gun object
                    sta CCZ_PntObj00PrmGridRow      ; 
                    
                    lda #NoObjGunSwitch             ; object: Ray Gun Operator
                    sta CCZ_PntObj00PrmNo           ; 
                    
.PaintOperator      jsr PaintWAObjTyp0              ; 
                    
                    lda CCW_GunDataNext             ; 
                    sta CC_WaO_TypGunPtrWA,x        ; 
                    
                    clc                             ; 
                    lda CCZ_RoomItemLo              ; 
                    adc #CC_Obj_GunDataLen          ; $07 = ray gun data entry length
                    sta CCZ_RoomItemLo              ; 
                    bcc .GoNextGun                  ; 
                    inc CCZ_RoomItemHi              ; 
                    
.GoNextGun          clc                             ; 
                    lda CCW_GunDataNext             ; 
                    adc #CC_Obj_GunDataLen          ; 
                    sta CCW_GunDataNext             ; 
                    jmp .NextGun                    ; 
                    
RoomRayGunX         rts
; ------------------------------------------------------------------------------------------------------------- ;
; RoomMatterXmit    Function: Paint a chambers matter transmitter - Called from: PaintRoomItems
;                   Parms   : Pointer ($3e/$3f) to CC_Obj_Xmit of CC_LevelGame
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
RoomMatterXmit      subroutine
                    ldy #CC_Obj_XmitBoothGridCol    ; 
                    lda (CCZ_RoomMatter),y          ; matter transmitter object
                    sta CCZ_PntObj01PrmGridCol      ; 
                    ldy #CC_Obj_XmitBoothGridRow    ; 
                    lda (CCZ_RoomMatter),y          ; matter transmitter object
                    clc                             ; 
                    adc #$18                        ; 
                    sta CCZ_PntObj01PrmGridRow      ; 
                    
                    lda #NoObjFloorMid              ; object: Floor Mid Tile
                    sta CCZ_PntObj01PrmNo           ; 
                    lda #CCZ_PntObjPrmType01        ; 
                    sta CCZ_PntObjPrmType           ; 
                    lda #CCW_XmitBoothFloorMax      ; 
                    sta CCW_XmitBoothFloorLen       ; 
                    
.PaintFloor         jsr PaintObject                 ; 
                    
                    clc                             ; 
                    lda CCZ_PntObj01PrmGridCol      ; 
                    adc #CC_GridWidth               ; 
                    sta CCZ_PntObj01PrmGridCol      ; 
                    
                    dec CCW_XmitBoothFloorLen       ; 
                    bne .PaintFloor                 ; 
                    
                    ldy #CC_Obj_XmitBoothGridCol    ; 
                    lda (CCZ_RoomMatter),y          ; matter transmitter object
                    sta CCZ_PntObj00PrmGridCol      ; 
                    ldy #CC_Obj_XmitBoothGridRow    ; 
                    lda (CCZ_RoomMatter),y          ; matter transmitter object
                    sta CCZ_PntObj00PrmGridRow      ; 
                    
                    lda #NoObjXmitBooth             ; object: Matter Transmitter Booth
                    sta CCZ_PntObj00PrmNo           ; 
                    lda #CCZ_PntObjPrmType00        ; 
                    sta CCZ_PntObjPrmType           ; 
                    
.PaintBooth         jsr PaintObject                 ; 
                    
                    clc                             ; 
                    lda CCZ_PntObj00PrmGridCol      ; 
                    adc #$0c                        ; 
                    sta CCZ_PntObj00PrmGridCol      ; 
                    clc                             ; 
                    lda CCZ_PntObj00PrmGridRow      ; 
                    adc #$18                        ; 
                    sta CCZ_PntObj00PrmGridRow      ; 
                    
                    lda #NoObjFloorMid              ; object: Floor Mid Tile
                    sta CCZ_PntObj00PrmNo           ; 
                    
                    jsr PaintObject                 ;
                    jsr InitObjectWA                ; XR=ObjectWAOffset
                    
                    lda #CC_WaO_XmitReceiveOval     ; 
                    sta CC_WaO_ObjectType,x         ; 
                    
                    ldy #CC_Obj_XmitBoothGridCol    ;
                    clc                             ; 
                    lda (CCZ_RoomMatter),y          ; matter transmitter object
                    adc #CC_GridWidth               ; 
                    sta CCZ_PntObj00PrmGridCol      ; 
                    
                    ldy #CC_Obj_XmitBoothGridRow    ; 
                    lda (CCZ_RoomMatter),y          ; matter transmitter object
                    clc                             ; 
                    adc #$18                        ; 
                    sta CCZ_PntObj00PrmGridRow      ; 
                    
                    lda #NoObjXmit                  ; object: Matter Transmitter
                    sta CCZ_PntObj00PrmNo           ; 
                    
                    lda CCZ_RoomItemLo              ; 
                    sta CC_WaO_TypXmitDataPtrLo,x   ; 
                    lda CCZ_RoomItemHi              ; 
                    sta CC_WaO_TypXmitDataPtrHi,x   ; save booth data pointer to object work area
                    
                    jsr PaintWAObjTyp0              ; 
                    
                    ldy #CC_Obj_XmitBoothColor      ; 
                    lda (CCZ_RoomMatter),y          ; matter transmitter object
                    clc                             ; 
                    adc #$02                        ; bypass black and white
                    jsr ColorXmitBackWall           ; 
                    
                    lda #CCZ_PntObjPrmType00        ; 
                    sta CCZ_PntObjPrmType           ; 
                    lda #NoObjXmitRcOv              ; object: Matter Transmitter Receiver Oval
                    sta CCZ_PntObj00PrmNo           ; 
                    
                    lda #HR_RedBlack                ; 
                    sta CCW_XmitReceiveColor        ; 
.RecOvals           ldy #CC_Obj_XmitTarg0GridCol    ; 
                    lda (CCZ_RoomMatter),y          ; matter transmitter object
                    beq .Exit                       ; 
                    
                    lda CCW_XmitReceiveColor        ; 
                    sta DatObjXmitRcOv01            ; 
                    sta DatObjXmitRcOv02            ; 
                    sta DatObjXmitRcOv03            ; 
                    sta DatObjXmitRcOv04            ; 
                    
                    ldy #CC_Obj_XmitTarg0GridCol    ; 
                    lda (CCZ_RoomMatter),y          ; matter transmitter object
                    sta CCZ_PntObj00PrmGridCol      ; 
                    ldy #CC_Obj_XmitTarg0GridRow    ; 
                    lda (CCZ_RoomMatter),y          ; matter transmitter object
                    sta CCZ_PntObj00PrmGridRow      ; 
                    
.PaintRecOval       jsr PaintObject                 ; 
                    
                    clc                             ; 
                    lda CCZ_RoomItemLo              ; 
                    adc #CC_Obj_XmitTarg0DataLen    ; $02 = xmit receiver oval data entry length
                    sta CCZ_RoomItemLo              ; 
                    bcc .NextColor                  ; 
                    inc CCZ_RoomItemHi              ; 
                    
.NextColor          clc                             ; 
                    lda CCW_XmitReceiveColor        ; 
                    adc #HR_WhiteBlack              ; $10 = next color
                    sta CCW_XmitReceiveColor        ; 
                    jmp .RecOvals                   ; 
                    
.Exit               clc                             ; 
                    lda CCZ_RoomItemLo              ; 
                    adc #CC_Obj_XmitBoothDataLen +1 ; $03 = xmit booth data entry length
                    sta CCZ_RoomItemLo              ; 
                    bcc RoomMatterXmitX             ; 
                    inc CCZ_RoomItemHi              ; 
                    
RoomMatterXmitX     rts
; ------------------------------------------------------------------------------------------------------------- ;
; RoomTrapDoor      Function: Paint a chambers trap doors - Called from: PaintRoomItems
;                   Parms   : Pointer ($3e/$3f) to CC_Obj_Trap of CC_LevelGame
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
RoomTrapDoor        subroutine
                    lda CCZ_RoomItemLo              ; 
                    sta CCW_TrapDataPtrLo           ; 
                    lda CCZ_RoomItemHi              ; 
                    sta CCW_TrapDataPtrHi           ; 
                    
                    lda #$00                        ; 
                    sta CCW_TrapDataNext            ; 
                    
.NextTrap           ldy #CC_Obj_Trap                ; 
                    lda (CCZ_RoomTrap),y            ; trap door object
                    and #CC_Obj_TrapEoData          ; 
                    beq .Trap                       ; 
                    
                    inc CCZ_RoomItemLo              ; 
                    bne .Exit                       ; 
                    inc CCZ_RoomItemHi              ; point behind EndOfTrapDoorData
                    
.Exit               jmp RoomTrapDoorX               ; 
                    
.Trap               jsr InitObjectWA                ; XR=ObjectWAOffset
                    
                    lda #CC_WaO_TrapDoor            ; 
                    sta CC_WaO_ObjectType,x         ; 
                    lda CCW_TrapDataNext            ; 
                    sta CC_WaO_TypTrapDataOff,x     ; 
                    
                    ldy #CC_Obj_TrapStatus          ; 
                    lda (CCZ_RoomTrap),y            ; trap door object
                    and #CC_Obj_TrapOpen            ; 
                    bne .TrapOpen                   ; 
                    
.TrapClosed         lda #CC_Obj_TrapSwColorOffTop   ; grey top of switch
                    sta ColObjTrapSw01              ; trap control top
                    lda #$55                        ; .#.#.#.# - trap door line data
                    sta ColObjTrapSw02              ; trap control bottom
                    jmp .TrapCtrl                   ; 
                    
.TrapOpen           ldy #CC_Obj_TrapDoorGridCol     ; 
                    lda (CCZ_RoomTrap),y            ; trap door object
                    sta CCZ_PntObj01PrmGridCol      ; 
                    ldy #CC_Obj_TrapDoorGridRow     ; 
                    lda (CCZ_RoomTrap),y            ; trap door object
                    sta CCZ_PntObj01PrmGridRow      ; 
                    
                    lda #CCZ_PntObjPrmType01        ; 
                    sta CCZ_PntObjPrmType           ; 
                    lda #NoObjTrapOpen              ; object: Trap Door Open
                    sta CCZ_PntObj01PrmNo           ; 
                    
.PaintDoor          jsr PaintObject                 ; 
                    
                    clc                             ; 
                    lda CCZ_PntObj01PrmGridCol      ; 
                    adc #CC_GridWidth               ; 
                    sta CCZ_PntObj00PrmGridCol      ; 
                    lda CCZ_PntObj01PrmGridRow      ; 
                    sta CCZ_PntObj00PrmGridRow      ; 
                    
                    lda #NoObjTrapMovBas            ; object: Trap Door Base Line if Open
                    sta CCZ_PntObj00PrmNo           ; 
                    
                    jsr PaintWAObjTyp0
                    
                    lda #HR_RedBlack                ; red-black
                    sta ColObjTrapSw01              ; trap control top
                    lda #$cc                        ; color grey2
                    sta ColObjTrapSw02              ; trap control bottom
                    
                    ldy #CC_Obj_TrapDoorGridCol     ; 
                    lda (CCZ_RoomTrap),y            ; trap door object
                    lsr a                           ; *2
                    lsr a                           ; *4
                    sec                             ; 
                    sbc #$04                        ; 
                    sta CCW_CtrlScrnColNo           ; 
                    
                    ldy #CC_Obj_TrapDoorGridRow     ; 
                    lda (CCZ_RoomTrap),y            ; trap door object
                    lsr a                           ; *2
                    lsr a                           ; *4
                    lsr a                           ; *8
                    sta CCW_CtrlScrnRowNo           ; 
                    
                    jsr SetCtrlScrnPtr              ; point to control screen output address $c000-$c7ff
                    
                    ldy #$00                        ; 
                    lda (CCZ_CtrlScreen),y          ; 
                    and #CC_CtrlTrapLeft            ; 
                    sta (CCZ_CtrlScreen),y          ; mark trap start - resets floor to CC_CtrlFloorEnd
                    
                    ldy #$04                        ; 
                    lda (CCZ_CtrlScreen),y          ; 
                    and #CC_CtrlTrapRight           ; 
                    sta (CCZ_CtrlScreen),y          ; mark trap end   - resets floor to CC_CtrlFloorStrt
                    
.TrapCtrl           jsr InitObjectWA                ; XR=ObjectWAOffset
                    
                    lda #CC_WaO_TrapSwitch          ; 
                    sta CC_WaO_ObjectType,x         ; 
                    
                    ldy #CC_Obj_TrapSwitchGridCol   ; 
                    lda (CCZ_RoomTrap),y            ; trap door object
                    sta CCZ_PntObj00PrmGridCol      ; 
                    ldy #CC_Obj_TrapSwitchGridRow   ; 
                    lda (CCZ_RoomTrap),y            ; trap door object
                    sta CCZ_PntObj00PrmGridRow      ; 
                    
                    lda #NoObjTrapSw                ; object: Trap Door Control
                    sta CCZ_PntObj00PrmNo           ; 
                    lda CCW_TrapDataNext            ; 
                    sta CC_WaO_TypTrapDataOff,x     ; 
                    
.PaintControl       jsr PaintWAObjTyp0              ; 
                    
                    clc                             ; 
                    lda CCW_TrapDataNext            ; 
                    adc #$05                        ; 
                    sta CCW_TrapDataNext            ; 
                    
                    clc                             ; 
                    lda CCZ_RoomItemLo              ; 
                    adc #CC_Obj_TrapDataLen         ; $05 = trap door data entry length
                    sta CCZ_RoomItemLo              ; 
                    bcc .GoNextTrap                 ; 
                    inc CCZ_RoomItemHi              ; 
                    
.GoNextTrap         jmp .NextTrap                   ; 
                    
RoomTrapDoorX       rts
; ------------------------------------------------------------------------------------------------------------- ;
; RoomSideWalk      Function: Paint a chambers moving sidewalks - Called from: PaintRoomItems
;                   Parms   : Pointer ($3e/$3f) to CC_Obj_Walk of CC_LevelGame
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
RoomSideWalk        subroutine
                    lda CCZ_RoomItemLo              ; 
                    sta CCW_WalkDataPtrLo           ; 
                    lda CCZ_RoomItemHi              ; 
                    sta CCW_WalkDataPtrHi           ; 
                    
                    lda #$00                        ; 
                    sta CCW_WalkDataNext            ; 
                    
.NextWalk           ldy #CC_Obj_Walk                ; 
                    lda (CCZ_RoomWalk),y            ; moving sidewalk object
                    and #CC_Obj_WalkEoData          ; 
                    beq .Walk                       ; 
                    
                    inc CCZ_RoomItemLo              ; 
                    bne .Exit
                    inc CCZ_RoomItemHi              ; point behind EndOfSideWalkData
                    
.Exit               jmp RoomSideWalkX               ; 
                    
.Walk               lda #$ff                        ; 
                    eor #CC_Obj_WalkSwitchPressP1   ; 
                    eor #CC_Obj_WalkSwitchPressP2   ; 
                    eor #CC_Obj_WalkSwitchPressP1S  ; 
                    eor #CC_Obj_WalkSwitchPressP2S  ; 
                    and (CCZ_RoomWalk),y            ; moving sidewalk object
                    sta (CCZ_RoomWalk),y            ; moving sidewalk object
                    
                    jsr InitObjectWA                ; XR=ObjectWAOffset
                    
                    lda #CC_WaO_SideWalk            ; 
                    sta CC_WaO_ObjectType,x         ; 
                    
                    lda CCW_WalkDataNext            ; 
                    sta CC_WaO_TypWalkDataOff,x     ; 
                    
                    lda CC_WaO_ObjectFlag,x         ; 
                    ora #CC_WaO_Ready               ; action completed - CC_WaO_Ready
                    sta CC_WaO_ObjectFlag,x         ; 
                    
                    ldy #CC_Obj_WalkGridCol         ; 
                    lda (CCZ_RoomWalk),y            ; moving sidewalk object
                    sta CCZ_PntObj01PrmGridCol      ; 
                    ldy #CC_Obj_WalkGridRow         ; 
                    lda (CCZ_RoomWalk),y            ; moving sidewalk object
                    sta CCZ_PntObj01PrmGridRow      ; 
                    
                    lda #NoObjWalkBlank             ; object: Moving Sidewalk Background
                    sta CCZ_PntObj01PrmNo           ; 
                    lda #CCZ_PntObjPrmType01        ; 
                    sta CCZ_PntObjPrmType           ; 
                    
.PaintBack          jsr PaintObject                 ; 
                    
                    lda CCZ_PntObj01PrmGridCol      ; 
                    sta CCZ_PntObj00PrmGridCol      ; 
                    lda CCZ_PntObj01PrmGridRow      ; 
                    sta CCZ_PntObj00PrmGridRow      ; 
                    
                    lda #NoObjWalkMov01             ; object: Moving Sidewalk Phase 01
                    sta CCZ_PntObj00PrmNo           ; 
                    
.PaintWalk          jsr PaintWAObjTyp0              ; 
                    jsr InitObjectWA                ; XR=ObjectWAOffset
                    
                    lda #CC_WaO_SideWalkSwitch      ; 
                    sta CC_WaO_ObjectType,x         ; 
                    lda CCW_WalkDataNext            ; 
                    sta CC_WaO_TypWalkDataOff,x     ; 
                    
                    ldy #CC_Obj_WalkSwitchGridCol   ; 
                    lda (CCZ_RoomWalk),y            ; moving sidewalk object
                    sta CCZ_PntObj00PrmGridCol      ; 
                    ldy #CC_Obj_WalkSwitchGridRow   ; 
                    lda (CCZ_RoomWalk),y            ; moving sidewalk object
                    sta CCZ_PntObj00PrmGridRow      ; 
                    
                    lda #NoObjWalkSw                ; object: Moving Sidewalk Control
                    sta CCZ_PntObj00PrmNo           ; 
                    lda #CCZ_PntObjPrmType00        ; 
                    sta CCZ_PntObjPrmType           ; 
                    
                    ldy #CC_Obj_WalkStatus          ; 
                    lda (CCZ_RoomWalk),y            ; moving sidewalk object
                    bit Bit_oooo_ooo1               ; CC_Obj_WalkMoveRight
                    bne .ChkDir                     ; 
                    
.Halt               lda #HR_GreyBlack               ; grey-black
                    sta ColObjWalkSw01              ; walk control left
                    sta ColObjWalkSw02              ; walk control right
                    jmp .PaintControl               ; 
                    
.ChkDir             and #CC_Obj_WalkStopLeft        ; 
                    bne .MoveLeft                   ; 
                    
.MovesRight         lda #HR_GreyBlack               ; grey-black
                    sta ColObjWalkSw01              ; walk control left
                    lda #HR_RedBlack                ; red-black
                    sta ColObjWalkSw02              ; walk control right
                    jmp .PaintControl               ; 
                    
.MoveLeft           lda #HR_GreenBlack              ; green-black
                    sta ColObjWalkSw01              ; walk control left
                    lda #HR_GreyBlack               ; grey-black
                    sta ColObjWalkSw02              ; walk control right
                    
.PaintControl       jsr PaintObject                 ; 
                    
                    ldy #CC_Obj_WalkSwitchGridCol   ; 
                    lda (CCZ_RoomWalk),y            ; moving sidewalk object
                    clc                             ; 
                    adc #CC_GridWidth               ; 
                    sta CCZ_PntObj00PrmGridCol      ; 
                    ldy #CC_Obj_WalkSwitchGridRow   ; 
                    lda (CCZ_RoomWalk),y            ; moving sidewalk object
                    clc                             ; 
                    adc #CC_GridHeight              ; 
                    sta CCZ_PntObj00PrmGridRow      ; 
                    
                    lda #NoObjWalkSpot              ; object: Moving Sidewalk Hot Spot
                    sta CCZ_PntObj00PrmNo           ; 
                    
.PaintHotSpot       jsr PaintWAObjTyp0              ; 
                    
                    clc                             ; 
                    lda CCW_WalkDataNext            ; 
                    adc #CC_Obj_WalkDataLen         ; 
                    sta CCW_WalkDataNext            ; 
                    
                    clc                             ; 
                    lda CCZ_RoomItemLo              ; 
                    adc #CC_Obj_WalkDataLen         ; $05 = sidewalk data entry length
                    sta CCZ_RoomItemLo              ; 
                    bcc .GoNextWalk                 ; 
                    inc CCZ_RoomItemHi              ; 
                    
.GoNextWalk         jmp .NextWalk                   ; 
                    
RoomSideWalkX       rts
; ------------------------------------------------------------------------------------------------------------- ;
; RoomFrankenStein  Function: Paint a  chambers Frankenstein - Called from: PaintRoomItems
;                           : Alloc an Object and Sprite WA
;                   Parms   : Pointer ($3e/$3f) to CC_Obj_Frank of CC_LevelGame
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
RoomFrankenStein    subroutine
                    lda CCZ_RoomItemLo              ; 
                    sta CCW_FrankDataPtrLo          ; 
                    lda CCZ_RoomItemHi              ; 
                    sta CCW_FrankDataPtrHi          ; 
                    
                    lda #$00                        ; 
                    sta CCW_FrankDataNext           ; 
                    
.NextFrank          ldy #CC_Obj_Frank               ; 
                    lda (CCZ_RoomFrank),y           ; frankenstein object
                    and #CC_Obj_FrankEoData         ; 
                    beq .Frank                      ; 
                    
                    inc CCZ_RoomItemLo              ; 
                    bne .Exit                       ; 
                    inc CCZ_RoomItemHi              ; point behind EndOfFrankData
                    
.Exit               jmp RoomFrankenSteinX           ; 
                    
.Frank              ldy #CC_Obj_FrankCoffinGridCol  ; 
                    lda (CCZ_RoomFrank),y           ; frankenstein object
                    sta CCZ_PntObj01PrmGridCol      ; 
                    clc                             ; 
                    ldy #CC_Obj_FrankCoffinGridRow  ; 
                    lda (CCZ_RoomFrank),y           ; frankenstein object
                    adc #$18                        ; 
                    sta CCZ_PntObj01PrmGridRow      ; 
                    
                    lda #NoObjFrankCover            ; object: Frank Blank Out Start of Floor
                    sta CCZ_PntObj01PrmNo           ; 
                    lda #CCZ_PntObjPrmType01        ; 
                    sta CCZ_PntObjPrmType           ; 
                    
.PaintBlank         jsr PaintObject                 ; 
                    
                    lda CCZ_PntObj01PrmGridCol      ; 
                    lsr a                           ; /2
                    lsr a                           ; /4
                    sec                             ; 
                    sbc #$04                        ; 
                    sta CCW_CtrlScrnColNo           ; 
                    
                    lda CCZ_PntObj01PrmGridRow      ; 
                    lsr a                           ; /2
                    lsr a                           ; /4
                    lsr a                           ; /8
                    sta CCW_CtrlScrnRowNo           ; 
                    
                    jsr SetCtrlScrnPtr              ; point to control screen output address $c000-$c7ff
                    
                    ldy #CC_Obj_FrankCoffinDir      ; 
                    lda (CCZ_RoomFrank),y           ; frankenstein object
                    and #CC_Obj_FrankCoffinLeft     ; 
                    bne .ScrnSetOutPtr              ; 
                    
.ScrnCoffinRight    lda #CC_CtrlFrankRight          ; 
                    jmp .ScrnSetCoffin              ; 
                    
.ScrnSetOutPtr      sec                             ; 
                    lda CCZ_CtrlScreenLo            ; 
                    sbc #$02                        ; 
                    sta CCZ_CtrlScreenLo            ; 
                    bcs .ScrnCoffinLeft             ; 
                    dec CCZ_CtrlScreenHi            ; 
                    
.ScrnCoffinLeft     lda #CC_CtrlFrankLeft           ; 
.ScrnSetCoffin      sta CCW_FrankCoffinDir          ; 
                    
                    ldy #$04                        ; 
.ScrnSetData        lda (CCZ_CtrlScreen),y          ; 
                    and CCW_FrankCoffinDir          ; 
                    sta (CCZ_CtrlScreen),y          ; mark coffin r/l - resets floor to CC_CtrlFloorStrt/CC_CtrlFloorEnd
                    dey                             ; 
                    dey                             ; 
                    bpl .ScrnSetData                ; 
                    
.SetObjWA           jsr InitObjectWA                ; XR=ObjectWAOffset
                    
                    lda #CC_WaO_Frankenstein        ; Mark WA as type Frankenstein
                    sta CC_WaO_ObjectType,x         ; 
                    
.PrepCoffin         ldy #CC_Obj_FrankCoffinGridCol  ; 
                    lda (CCZ_RoomFrank),y           ; frankenstein object
                    sta CCZ_PntObj00PrmGridCol      ; 
                    ldy #CC_Obj_FrankCoffinGridRow  ; 
                    lda (CCZ_RoomFrank),y           ; frankenstein object
                    sta CCZ_PntObj00PrmGridRow      ; 
                    
                    ldy #CC_Obj_FrankCoffinDir      ; 
                    lda (CCZ_RoomFrank),y           ; frankenstein object
                    and #CC_Obj_FrankCoffinLeft     ; 
                    bne .CoffinLeft                 ; 
                    
.CoffinRight        lda #NoObjFrankCofRi            ; object: Frank Coffin Open Right
                    jmp .SetCoffin                  ; 
                    
.CoffinLeft         lda #NoObjFrankCofLe            ; object: Frank Coffin Open Left
.SetCoffin          sta CCZ_PntObj00PrmNo           ; 
                    
.PaintCoffin        jsr PaintWAObjTyp0              ; 
                    
                    ldy #CC_Obj_FrankCoffinDir      ; 
                    lda (CCZ_RoomFrank),y           ; frankenstein object
                    and #CC_Obj_FrankCoffinLeft     ; 
                    bne .SetSpriteWA                ; 
                    
.PrepFloor          clc                             ; 
                    lda CCZ_PntObj00PrmGridCol      ; 
                    adc #CC_GridWidth               ; 
                    sta CCZ_PntObj00PrmGridCol      ; 
                    clc                             ; 
                    lda CCZ_PntObj00PrmGridRow      ; 
                    adc #$18                        ; 
                    sta CCZ_PntObj00PrmGridRow      ; 
                    
                    lda #NoObjFloorMid              ; object: Floor Mid Tile
                    sta CCZ_PntObj00PrmNo           ; 
                    lda #CCZ_PntObjPrmType00        ; 
                    sta CCZ_PntObjPrmType           ; 
                    
.PaintFloor         jsr PaintObject                 ; 
                    
.SetSpriteWA        jsr InitSpriteFrank             ; 
                    
                    clc                             ; 
                    lda CCZ_RoomItemLo              ; 
                    adc #CC_Obj_FrankDataLen        ; $07 = frank data entry length
                    sta CCZ_RoomItemLo              ; 
                    bcc .GoNextFrank                ; 
                    inc CCZ_RoomItemHi              ; 
                    
.GoNextFrank        clc                             ; 
                    lda CCW_FrankDataNext           ; 
                    adc #CC_Obj_FrankDataLen        ; $07 = frank data entry length
                    sta CCW_FrankDataNext           ; 
                    jmp .NextFrank                  ; 
                    
RoomFrankenSteinX   rts
; ----------------------------------------------------------------------------------------------------------
; RoomTextLine      Function: Paint a chambers texts - Called from: PaintRoomItems / Ingame text subroutines
;                   Parms   : Pointer ($3e/$3f) to CC_Obj_Text of CC_LevelGame
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
RoomTextLine        subroutine
.NextTextLine       ldy #CC_Obj_TextGridCol         ; 
                    lda (CCZ_RoomText),y            ; text object
                    beq .Exit                       ; 
                    
                    sta CCZ_PaintTextGridCol        ; 
                    ldy #CC_Obj_TextGridRow         ; 
                    lda (CCZ_RoomText),y            ; text object
                    sta CCZ_PaintTextGridRow        ; 
                    
                    ldy #CC_Obj_TextColor           ; 
                    lda (CCZ_RoomText),y            ; text object
                    sta CCZ_PaintTextColor          ; 
                    
                    ldy #CC_Obj_TextFormat          ; 
                    lda (CCZ_RoomText),y            ; text object
                    sta CCZ_PaintTextType           ; 
                    
                    clc                             ; 
                    lda CCZ_RoomItemLo              ; 
                    adc #CC_Obj_TextHdrLen          ; $04 = length of each text header data entry
                    sta CCZ_RoomItemLo              ; 
                    bcc .PaintText
                    inc CCZ_RoomItemHi              ; point to text
                    
.PaintText          jsr PaintText                   ; 
                    
                    jmp .NextTextLine               ; 
                    
.Exit               inc CCZ_RoomItemLo              ; 
                    bne RoomTextLineX               ; 
                    inc CCZ_RoomItemHi              ; 
                    
RoomTextLineX       rts
; ------------------------------------------------------------------------------------------------------------- ;
; RoomGraphic       Function: Paint the EndOfGame Picture - Called from: PaintRoomItems after EscapeHandler
;                   Parms   : Pointer ($3e/$3f) to CC_Obj_Graphic of CC_LevelGame
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
RoomGraphic         subroutine
                    lda CCZ_RoomItemLo              ; 
                    sta ObjRoomDyn                  ; 
                    lda CCZ_RoomItemHi              ; 
                    sta ObjRoomDyn+1                ; set object pointer to castle graphic data pointer
                    
                    lda #CCZ_PntObjPrmType00        ; 
                    sta CCZ_PntObjPrmType           ; 
                    
                    lda #NoObjRoomDyn               ; object: Dynamically filled
                    sta CCZ_PntObj00PrmNo           ; 
                    
                    ldy #CC_Obj_GraphicRows         ; 
                    lda (CCZ_RoomGraphic),y         ; graphic object
                    
                    sec                             ; rows
                    sbc #$01                        ; ... - 1 ...
                    lsr a                           ; ... / 2 ...
                    lsr a                           ; ... / 4 ...
                    lsr a                           ; ... / 8 ...
                    sta CCZ_ColorDataLenRow         ; 
                    inc CCZ_ColorDataLenRow         ; ... + 1 ...
                    
                    ldy #CC_Obj_GraphicCols         ; 
                    lda (CCZ_RoomGraphic),y         ; graphic object
                    
                    tax                             ; 
                    lda #$00                        ; 
                    sta CCZ_ColorDataLenLo          ; 
                    sta CCZ_ColorDataLenHi          ; 
.Cols               cpx #$00                        ; ... * cols ...
                    beq .ColsX                      ; 
                    
                    clc                             ; 
                    lda CCZ_ColorDataLenLo          ; 
                    adc CCZ_ColorDataLenRow         ; 
                    sta CCZ_ColorDataLenLo          ; 
                    
                    lda CCZ_ColorDataLenHi          ; 
                    adc #$00                        ; 
                    sta CCZ_ColorDataLenHi          ; 
                    
                    dex                             ; 
                    jmp .Cols                       ; 
                    
.ColsX              asl CCZ_ColorDataLenLo          ; 
                    rol CCZ_ColorDataLenHi          ; ... * 2 = length color data in ($30/$31) so far
                    
                    ldy #CC_Obj_GraphicRows         ; 
                    lda (CCZ_RoomGraphic),y         ; graphic object
                    tax                             ; 
                    ldy #CC_Obj_GraphicCols         ; 
.Rows               cpx #$00                        ; ... + (rows * cols) ... (data length)
                    beq .RowsX                      ; 
                    
                    clc                             ; 
                    lda CCZ_ColorDataLenLo          ; 
                    adc (CCZ_RoomGraphic),y         ; graphic object
                    sta CCZ_ColorDataLenLo          ; 
                    
                    lda CCZ_ColorDataLenHi          ; 
                    adc #$00                        ; 
                    sta CCZ_ColorDataLenHi          ; 
                    dex                             ; 
                    jmp .Rows                       ; 
                    
.RowsX              clc                             ; 
                    lda #CC_Obj_GraphicHdrLen       ; ... + $03 ... (header length)
                    adc CCZ_ColorDataLenLo          ; 
                    sta CCZ_ColorDataLenLo          ; 
                    lda #$00                        ; 
                    adc CCZ_ColorDataLenHi          ; 
                    sta CCZ_ColorDataLenHi          ; = complete lenght of graphic header + data + color info
                    
                    clc                             ; 
                    lda CCZ_RoomItemLo              ; 
                    adc CCZ_ColorDataLenLo          ; 
                    sta CCZ_RoomItemLo              ; add to GraphicDataPtr
                    
                    lda CCZ_RoomItemHi              ; 
                    adc CCZ_ColorDataLenHi          ; 
                    sta CCZ_RoomItemHi              ; point behind GraphicData to Graphic Position List
                    
.NextGraphicPos     ldy #CC_Obj_GraphicGridCol      ; 
                    lda (CCZ_RoomGraphic),y         ; graphic object
                    bne .SetPosition                ; 
                    
.EndOfPosList       clc                             ; 
                    lda CCZ_RoomItemLo              ; 
                    adc #$01                        ; 
                    sta CCZ_RoomItemLo              ; 
                    
                    lda CCZ_RoomItemHi              ; 
                    adc #$00                        ; 
                    sta CCZ_RoomItemHi              ; point behind EndOfGraphicData
                    jmp RoomGraphicX                ; 
                    
.SetPosition        sta CCZ_PntObj00PrmGridCol      ; 
                    iny                             ; CC_Obj_GraphicGridRow
                    lda (CCZ_RoomGraphic),y         ; graphic object
                    sta CCZ_PntObj00PrmGridRow      ; 
                    
.PaintGraphic       jsr PaintObject                 ; 
                    
                    clc                             ; 
                    lda CCZ_RoomItemLo              ; 
                    adc #CC_Obj_GraphicPosLen       ; $02 = graphic piece position data entry length
                    sta CCZ_RoomItemLo              ; 
                    lda CCZ_RoomItemHi              ; 
                    adc #$00                        ; 
                    sta CCZ_RoomItemHi              ; 
                    jmp .NextGraphicPos             ; 
                    
RoomGraphicX        rts
; ------------------------------------------------------------------------------------------------------------- ;
; AutoDoorOpen      Function: - Called from: ObjectHandler
;                   Parms   : xr=Object status area offset ($00, $08, $10, $18, ...)
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
AutoDoorOpen        subroutine
                    lda CC_WaO_TypDoorFlag,x        ; 
                    bne .Sound                      ; CC_WaO_TypDoorOpen
                    
                    lda #CC_WaO_TypDoorOpen         ; 
                    sta CC_WaO_TypDoorFlag,x        ; flag: door is open
                    
                    lda #CC_WaO_TypDoorLiftStart    ; door lift count start value
                    sta CC_WaO_TypDoorLiftCount,x   ; 
                    lda CC_WaO_TypDoorNo,x          ; 
                    asl a                           ; *2
                    asl a                           ; *4
                    asl a                           ; *8 - length of each door data entry
                    clc                             ; 
                    adc CCW_DoorDataPtrLo           ; 
                    sta CCZ_RoomItemModLo           ; 
                    lda CCW_DoorDataPtrHi           ; 
                    adc #$00                        ; 
                    sta CCZ_RoomItemModHi           ; point to target door data
                    
.MarkFromDoor       ldy #CC_Obj_DoorInWallId        ; 
                    lda (CCZ_RoomDoorMod),y         ; door object
                    ora #CC_Obj_DoorOpen            ; set Bit 7 = door open
                    sta (CCZ_RoomDoorMod),y         ; mark actual door of actual room
                    
                    ldy #CC_Obj_DoorToDoorNo        ; 
                    lda (CCZ_RoomDoorMod),y         ; door object
                    
                    pha                             ; save target door number
                    ldy #CC_Obj_DoorToRoomNo        ; 
                    lda (CCZ_RoomDoorMod),y         ; door object
                    jsr SetRoomDataPtr              ; 
                    
                    pla                             ; restore target door number
                    jsr SetRoomDoorPtr
                    
.MarkToDoor         ldy #CC_Obj_DoorInWallId        ; 
                    lda (CCZ_RoomDoorMod),y         ; door object
                    ora #CC_Obj_DoorOpen            ; set Bit 7 = door open
                    sta (CCZ_RoomDoorMod),y         ; mark target door of target room
                    
.Sound              sec                             ; 
                    lda #SFX_OpenDoorHeight         ; 
                    sbc CC_WaO_TypDoorLiftCount,x   ; 
                    sta SFX_OpenDoorTone            ; vary tone
                    
                    lda #NoSndOpenDoor              ; sound: Open Door
                    jsr InitSoundFx                 ; 
                    
                    lda CC_WaO_TypDoorLiftCount,x   ; 
                    beq .IsOpen                     ; door fully opened
                    
                    dec CC_WaO_TypDoorLiftCount,x   ; door lift counter
                    
                    clc                             ; 
                    adc CC_WaO_ObjectGridRow,x      ; 
                    sta CCZ_PntObj01PrmGridRow      ; 
                    lda CC_WaO_ObjectGridCol,x      ; 
                    sta CCZ_PntObj01PrmGridCol      ; 
                    
                    lda #NoObjBlank                 ; object: various - Blank Line
                    sta CCZ_PntObj01PrmNo           ; 
                    lda #CCZ_PntObjPrmType01        ; 
                    sta CCZ_PntObjPrmType           ; 
                    
.PaintLiftGate      jsr PaintObject                 ; blank grate line by line bottom up
                    
.Exit               jmp AutoDoorOpenX               ; 
                    
.IsOpen             lda CC_WaO_ObjectFlag,x         ; 
                    eor #CC_WaO_Ready               ; action completed - CC_WaO_Ready
                    sta CC_WaO_ObjectFlag,x         ; 
                    
                    ldy #$05                        ; 
                    lda CC_WaO_TypDoorTargColor,x   ; target room color
.OpenColor          sta ColObjDoorGround,y          ; color open doors floor
                    dey                             ; 
                    bpl .OpenColor                  ; 
                    
                    lda #NoObjDoorGround            ; object: Open Doors Floor
                    sta CCZ_PntObj00PrmNo           ; 
                    
                    lda CC_WaO_ObjectGridCol,x      ; 
                    sta CCZ_PntObj00PrmGridCol      ; 
                    lda CC_WaO_ObjectGridRow,x      ; 
                    sta CCZ_PntObj00PrmGridRow      ; 
                    
.PaintFloor         jsr PaintWAObjTyp0              ; 
                    
AutoDoorOpenX       jmp RetObjMoveAuto              ; 
; ------------------------------------------------------------------------------------------------------------- ;
; AutoLightPole     Function: - Called from: ObjectHandler
;                   Parms   : xr=Object status area offset ($00, $08, $10, $18, ...)
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
AutoLightPole       subroutine
                    clc
                    lda CCW_LightSwtchDataPtrLo
                    adc CC_WaO_TypLightBallNo,x          ; $00 $08 $10 $18 $20 ...
                    sta CCZ_RoomItemModLo
                    lda CCW_LightSwtchDataPtrHi
                    adc #$00
                    sta CCZ_RoomItemModHi
                    
                    lda CC_WaO_TypLightBallMode,x
                    cmp #CC_WaO_TypLightBallOn
                    beq .SparkIsOn
                    
.SparkIsOff         lda #CC_WaO_TypLightBallOn
                    sta CC_WaO_TypLightBallMode,x
                    
                    jsr InitSpriteSpark
                    
                    jmp .PoleMotion
                    
.SparkIsOn          ldy #CC_Obj_LightMode
                    lda (CCZ_RoomLightMod),y
                    and #CC_Obj_LightBallOn         ; 
                    bne .SwitchedOn
                    
.SwitchedOff        lda #CC_WaO_TypLightBallOff
                    sta CC_WaO_TypLightBallMode,x
                    
                    lda CC_WaO_ObjectFlag,x
                    eor #CC_WaO_Ready               ; action completed - CC_WaO_Ready
                    sta CC_WaO_ObjectFlag,x
                    
                    lda #CC_Obj_LightPoleOff        ; green-green
                    sta DatObjLiMaPole01
                    sta DatObjLiMaPole02
                    
                    lda #CCZ_PntObjPrmType00
                    sta CCZ_PntObjPrmType  
                    
                    ldy #CC_Obj_LigthGridCol
                    lda (CCZ_RoomLightMod),y
                    sta CCZ_PntObj00PrmGridCol
                    ldy #CC_Obj_LigthGridRow
                    lda (CCZ_RoomLightMod),y
                    sta CCZ_PntObj00PrmGridRow
                    
                    lda #NoObjLiMaPole              ; object: Lightning Machine Pole Off
                    sta CCZ_PntObj00PrmNo
                    
                    ldy #CC_Obj_LightPoleLen
                    lda (CCZ_RoomLightMod),y
                    sta CCW_LightPolePhaseLen
.Pole               lda CCW_LightPolePhaseLen
                    beq .SearchWAI
                    
.PaintPoleOff       jsr PaintObject
                    
                    clc
                    lda CCZ_PntObj00PrmGridRow
                    adc #CC_GridHeight
                    sta CCZ_PntObj00PrmGridRow
                    dec CCW_LightPolePhaseLen
                    jmp .Pole
                    
.SearchWAI          ldy #$00
.SearchWA           lda CC_WaS_SpriteType,y         ; $00=Player $01=Spark $02=Force $03=Mummy $04=Beam $05=Frank
                    cmp #CC_WaS_SpriteSpark
                    bne .NextWA
                    
                    lda CC_WaS_SpriteFlag,y         ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    and #CC_WaS_FlagInactive        ;            $10=action   $20=death          $40=dead           $80=init
                    bne .NextWA
                    
                    lda CC_WaS_Work,y
                    cmp CC_WaO_TypLightBallNo,x
                    beq .FoundWA
                    
.NextWA             tya
                    clc
                    adc #$20
                    tay
                    jmp .SearchWA
                    
.FoundWA            lda CC_WaS_SpriteFlag,y         ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    ora #CC_Obj_WalkSwitchPressP1S  ;            $10=action   $20=death          $40=dead           $80=init
                    sta CC_WaS_SpriteFlag,y
                    jmp AutoLightPoleX
                    
.SwitchedOn         lda CCW_CountActnHdlrCalls      ; counter ActionHandler routine calls
                    and #$03
                    beq .PoleMotion
                    
                    jmp AutoLightPoleX
                    
.PoleMotion         inc CC_WaO_TypLightPoleMove,x
                    lda CC_WaO_TypLightPoleMove,x
                    cmp #CCW_LightPolePhaseMax
                    bcc .PolePasesI                 ; lower
                    
                    lda #CCW_LightPolePhaseMin
                    sta CC_WaO_TypLightPoleMove,x
                    
.PolePasesI         sta CCW_LightPolePhase
                    ldy #CC_Obj_LigthGridCol
                    lda (CCZ_RoomLightMod),y
                    sta CCZ_PntObj00PrmGridCol
                    ldy #CC_Obj_LigthGridRow
                    lda (CCZ_RoomLightMod),y
                    sta CCZ_PntObj00PrmGridRow
                    
                    lda #CCZ_PntObjPrmType00
                    sta CCZ_PntObjPrmType  
                    lda #NoObjLiMaPole              ; object: Lightning Machine Pole Off
                    sta CCZ_PntObj00PrmNo
                    
                    ldy #CC_Obj_LightPoleLen
                    lda (CCZ_RoomLightMod),y
                    sta CCW_LightPolePhaseLen
                    
.PolePases          lda CCW_LightPolePhaseLen
                    beq AutoLightPoleX
                    
                    lda CCW_LightPolePhase
                    beq .PolePhase00
                    
                    cmp #$01
                    beq .PolePhase01
                    
.PolePhase02        lda #CC_Obj_LightPoleOn3        ; blue/blue
                    sta DatObjLiMaPole01
                    lda #WHITE                      ; 
                    sta DatObjLiMaPole02
                    jmp .PaintPoleOn
                    
.PolePhase00        lda #CC_Obj_LightPoleOn1        ; white/blue
                    sta DatObjLiMaPole01
                    lda #BLUE                       ; 
                    sta DatObjLiMaPole02
                    jmp .PaintPoleOn
                    
.PolePhase01        lda #CC_Obj_LightPoleOn2        ; blue/white
                    sta DatObjLiMaPole01
                    lda #BLUE                       ; 
                    sta DatObjLiMaPole02
                    
.PaintPoleOn        jsr PaintObject
                    
                    inc CCW_LightPolePhase
                    lda CCW_LightPolePhase
                    cmp #CCW_LightPolePhaseMax
                    bcc .SetNextPolePart            ; lower
                    
                    lda #CCW_LightPolePhaseMin
                    sta CCW_LightPolePhase
                    
.SetNextPolePart    clc
                    lda CCZ_PntObj00PrmGridRow
                    adc #CC_GridHeight
                    sta CCZ_PntObj00PrmGridRow
                    dec CCW_LightPolePhaseLen
                    jmp .PolePases
                    
AutoLightPoleX      jmp RetObjMoveAuto
; ------------------------------------------------------------------------------------------------------------- ;
; AutoForceClose    Function: - Called from: ObjectHandler
;                   Parms   : xr=Object status area offset ($00, $08, $10, $18, ...)
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
AutoForceClose      subroutine                      ; close an open force field again
                    dec CC_WaO_TypForcePingSecs,x
                    bne AutoForceCloseX             ; no second has passed by
                    
                    dec CC_WaO_TypForceTimer,x      ; set next close ping tone
                    
                    ldy CC_WaO_TypForceTimer,x
                    lda TabForcePingHight,y
                    sta SFX_ForcePingHeight         ; vary tone
                    
                    lda #NoSndForcePing             ; sound: Close Force Field Ping
                    jsr InitSoundFx
                    
                    ldy #$00
.FillTimer          tya
                    cmp CC_WaO_TypForceTimer,x
                    bcc .Black
                    
.White              lda #$55                        ; .#.#.#.# - pattern force field switch timer square
                    jmp .FillSquare
                    
.Black              lda #$00                        ; ........ - pattern force field switch timer square
.FillSquare         sta DatObjFoFiTime01,y
                    iny
                    cpy #CC_WaO_TypForceTimerInit
                    bcc .FillTimer
                    
                    lda CC_WaO_ObjectGridCol,x
                    sta CCZ_PntObj00PrmGridCol
                    lda CC_WaO_ObjectGridRow,x
                    sta CCZ_PntObj00PrmGridRow
                    
                    lda #NoObjFoFiTime              ; object: Force Field Timer Square
                    sta CCZ_PntObj00PrmNo
                    lda #CCZ_PntObjPrmType00
                    sta CCZ_PntObjPrmType 
                    
.PaintTimer         jsr PaintObject
                    
                    lda CC_WaO_TypForceTimer,x
                    beq .TimeIsUp
                    
                    lda #CC_WaO_TypForcePingInit
                    sta CC_WaO_TypForcePingSecs,x   ; reinit second counter
                    jmp AutoForceCloseX
                    
.TimeIsUp           lda CC_WaO_ObjectFlag,x
                    eor #CC_WaO_Ready               ; action completed - CC_WaO_Ready
                    sta CC_WaO_ObjectFlag,x
                    
                    ldy CC_WaO_TypForceNo,x
                    lda #CCW_ForceClosed
                    sta CCW_ForceStatusTab,y
                    
AutoForceCloseX     jmp RetObjMoveAuto
; ------------------------------------------------------------------------------------------------------------- ;
; AutoAnkhFlash     Function: - Called from: ObjectHandler
;                   Parms   : xr=Object status area offset ($00, $08, $10, $18, ...)
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
AutoAnkhFlash       subroutine
                    lda CCW_CountActnHdlrCalls      ; counter ActionHandler routine calls
                    and #$03
                    bne AutoAnkhFlashX              ; no switch yet
                    
                    dec CC_WaO_TypMummyTimer,x
                    bne .ChkColor
                    
                    lda CC_WaO_ObjectFlag,x
                    eor #CC_WaO_Ready               ; action completed - CC_WaO_Ready
                    sta CC_WaO_ObjectFlag,x
                    jmp .AnkhBlue
                    
.ChkColor           lda CC_WaO_TypMummyAnkhColor,x
                    cmp #CC_Obj_MummAnkhColor
                    bne .AnkhBlue
                    
.AnkhWhite          lda #CC_Obj_MummAnkhColorFlash
                    jmp .AnkhSetColorI
                    
.AnkhBlue           lda #CC_Obj_MummAnkhColor
                    
.AnkhSetColorI      ldy #$05
.AnkhSetColor       sta ColObjMummyAnkh,y
                    dey
                    bpl .AnkhSetColor
                    
                    sta CC_WaO_TypMummyAnkhColor,x
                    lda CC_WaO_ObjectGridCol,x
                    sta CCZ_PntObj00PrmGridCol
                    lda CC_WaO_ObjectGridRow,x
                    sta CCZ_PntObj00PrmGridRow
                    lda CC_WaO_ObjectNo,x
                    sta CCZ_PntObj00PrmNo
                    
.PaintAnkh          jsr PaintWAObjTyp0
                    
AutoAnkhFlashX      jmp RetObjMoveAuto
; ------------------------------------------------------------------------------------------------------------- ;
; AutoRayGunAim     Function: - Called from: ObjectHandler
;                   Parms   : xr=Object status area offset ($00, $08, $10, $18, ...)
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
AutoRayGunAim       subroutine
                    lda CCW_CountActnHdlrCalls      ; counter ActionHandler routine calls
                    and #$03
                    beq .Gun
                    
.Exit               jmp AutoRayGunAimX
                    
.Gun                clc
                    lda CCW_GunDataPtrLo
                    adc CC_WaO_TypGunPtrWA,x
                    sta CCZ_RoomItemModLo
                    lda CCW_GunDataPtrHi
                    adc #$00
                    sta CCZ_RoomItemModHi
                    
                    lda CC_WaO_ObjectFlag,x
                    and #CC_WaO_Init                ; initialized only - CC_WaO_Init
                    beq .ChkDemo
                    
                    jmp .SetPos
                    
.ChkDemo            lda CCW_DemoFlag                ; 
                    cmp #CCW_DemoYes                ; 
                    beq .Exit                       ; demo
                    
                    ldy #CC_Obj_GunDirection        ; 
                    lda (CCZ_RoomGunMod),y          ; 
                    and #CC_Obj_GunMoveStop         ; 
                    bne .ChkMoveUp                  ; 
                    
                    lda #$ff
                    sta CCW_GunDataNext
                    lda #$00
                    sta CCW_GunMoveDir
                    
                    lda #$01                        ; start with player 2
                    sta CCW_GunTargPlayerNo
.SetGunMoveDir      ldy CCW_GunTargPlayerNo
                    lda CCL_PlayersStatus,y
                    cmp #CCL_PlayerSurvive
                    bne .SetNextPlayer
                    
                    lda CCW_SpriteWAOffP1,y
                    tay
                    sec
                    lda CC_WaS_SpritePosY,y
                    sbc CC_WaO_ObjectGridRow,x
                    bcs .ChkGunPos                  ; still positive
                    
                    eor #$ff                        ; negative: flip bits and ...
                    adc #$01                        ; ... add 1 = switch negative sign
                    
.ChkGunPos          cmp CCW_GunDataNext
                    bcs .SetNextPlayer
                    
                    sta CCW_GunDataNext
                    
                    lda CC_WaS_SpritePosY,y
                    cmp #$c8
                    bcs .SetGunMoveUp
                    
                    cmp CC_WaO_ObjectGridRow,x
                    bcs .SetGunMoveDown
                    
.SetGunMoveUp       lda #CC_Obj_GunMoveUp           ; CC_Obj_GunMoveUp   - player 1 wins if still alive
                    sta CCW_GunMoveDir
                    jmp .SetNextPlayer
                    
.SetGunMoveDown     lda #CC_Obj_GunMoveDown         ; CC_Obj_GunMoveDown - player 1 wins if still alive
                    sta CCW_GunMoveDir
                    
.SetNextPlayer      dec CCW_GunTargPlayerNo
                    bpl .SetGunMoveDir
                    
                    lda #$ff
                    eor #CC_Obj_GunMoveUp           ; CC_Obj_GunMoveUp
                    eor #CC_Obj_GunMoveDown         ; CC_Obj_GunMoveDown
                    
                    ldy #CC_Obj_GunDirection
                    and (CCZ_RoomGunMod),y
                    ora CCW_GunMoveDir 
                    sta (CCZ_RoomGunMod),y
                    
.ChkMoveUp          ldy #CC_Obj_GunDirection
                    lda (CCZ_RoomItemModLo),y
                    bit Bit_oooo_o1oo               ; CC_Obj_GunMoveUp
                    beq .ChkMoveDown
                    
                    ldy #CC_Obj_GunPosY
                    lda (CCZ_RoomItemModLo),y
                    ldy #CC_Obj_GunPoleGridRow
                    cmp (CCZ_RoomItemModLo),y
                    beq .MoveStop
                    
.Up                 sec
                    sbc #$01
                    ldy #CC_Obj_GunPosY
                    sta (CCZ_RoomItemModLo),y
                    
                    lda #CC_Obj_GunSwitchColorUp    ; gun moves up: control - green/grey
                    jsr ColorGunSwitch
                    jmp .SetPos
                    
.ChkMoveDown        and #CC_Obj_GunMoveDown         ; 
                    bne .MoveDown
                    
.MoveStop           lda #CC_Obj_GunSwitchColorNo    ; gun has stopped: control - grey/grey
                    jsr ColorGunSwitch
                    jmp .Stop
                    
.MoveDown           ldy #CC_Obj_GunPosY
                    lda (CCZ_RoomGunMod),y
                    cmp CC_WaO_TypGunPoleBottom,x   ; BottomOfPole
                    bcs .MoveStop
                    
.Down               clc
                    adc #$01
                    sta (CCZ_RoomGunMod),y
                    
                    lda #CC_Obj_GunSwitchColorDo    ; gun moves down: control - grey/red
                    jsr ColorGunSwitch
                    
.SetPos             lda CC_WaO_ObjectGridCol,x
                    sta CCZ_PntObj00PrmGridCol
                    
                    ldy #CC_Obj_GunPosY
                    lda (CCZ_RoomGunMod),y
                    sta CCZ_PntObj00PrmGridRow
                    
                    ldy #CC_Obj_GunDirection
                    lda (CCZ_RoomGunMod),y
                    and #CC_Obj_GunPointLeft        ; CC_Obj_GunPointLeft - Bit0=0: point right  Bit0=1:point left 
                    beq .TabGunObjNoRi
                    
.TabGunObjNoLe      lda #$04                        ; table offset to left  gun object numbers
                    jmp .SetMoveDir
                    
.TabGunObjNoRi      lda #$00                        ; table offset to right gun object numbers
                    
.SetMoveDir         sta CCW_GunMoveDir
                    
                    ldy #CC_Obj_GunPosY
                    lda (CCZ_RoomGunMod),y
                    and #$03
                    ora CCW_GunMoveDir
                    tay
                    lda TabGunObjNo,y
                    sta CCZ_PntObj00PrmNo
                    
.PaintGun           jsr PaintWAObjTyp0
                    
.Stop               ldy #CC_Obj_GunDirection
                    lda (CCZ_RoomGunMod),y
                    bit Bit_oo1o_oooo               ; CC_Obj_GunMoveStop
                    beq .ChkGunMax
                    
                    eor #CC_Obj_GunMoveStop         ; CC_Obj_GunMoveStop
                    sta (CCZ_RoomGunMod),y
                    
                    and #CC_Obj_GunMoveFire         ; CC_Obj_GunMoveFire - player pressed the gun control
                    bne .ChkGunFire
                    
                    jmp AutoRayGunAimX
                    
.ChkGunMax          lda CCW_GunDataNext             ; max six guns allowed
                    cmp #$05
                    bcs AutoRayGunAimX
                    
.ChkGunFire         ldy #CC_Obj_GunDirection
                    lda (CCZ_RoomGunMod),y
                    bit Bit_o1oo_oooo               ; CC_Obj_GunShoots
                    bne AutoRayGunAimX
                    
.SetGunFire         ora #CC_Obj_GunShoots           ; CC_Obj_GunShoots
                    sta (CCZ_RoomGunMod),y
                    jsr InitSpriteBeam
                    
AutoRayGunAimX      jmp RetObjMoveAuto
; ------------------------------------------------------------------------------------------------------------- ;
; AutoMatterTarget  Function: - Called from: ObjectHandler
;                   Parms   : xr=Object status area offset ($00, $08, $10, $18, ...)
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
AutoMatterTarget    subroutine
                    lda CCW_CountActnHdlrCalls      ; counter ActionHandler routine calls
                    and #$01                        ; 
                    bne AutoMatterTargetX           ; 
                    
                    jsr Randomizer                  ; 
                    
                    and #SFX_MatterXmitMask         ; limit values
                    sta SFX_MatterXmitTone          ; randomly vary xmit sound
                    
                    lda #NoSndMaTrXmit              ; sound: Matter Transmitter Transmit
                    jsr InitSoundFx                 ; 
                    
                    lda CCW_CountActnHdlrCalls      ; counter ActionHandler routine calls
                    and #$03                        ; ......##
                    beq .GetOvalColor               ; 
                    
                    lda #$01                        ; oval flip color white
                    jmp .SetColor                   ; 
                    
.GetOvalColor       lda CC_WaO_TypXmitBoothColor,x  ; 
.SetColor           asl a                           ; shift color to left nibble
                    asl a                           ; 
                    asl a                           ; 
                    asl a                           ; 
                    sta DatObjXmitRcOv01            ; 
                    sta DatObjXmitRcOv02            ; 
                    sta DatObjXmitRcOv03            ; 
                    sta DatObjXmitRcOv04            ; 
                    
                    lda CC_WaO_TypXmitTargGridCol,x ; 
                    sta CCZ_PntObj00PrmGridCol      ; 
                    lda CC_WaO_TypXmitTargGridRow,x ; 
                    sta CCZ_PntObj00PrmGridRow      ; 
                    
                    lda #CCZ_PntObjPrmType00        ; 
                    sta CCZ_PntObjPrmType           ; 
                    lda #NoObjXmitRcOv              ; object: Matter Transmitter Receiver Oval
                    sta CCZ_PntObj00PrmNo           ; 
                    
.PaintOval          jsr PaintObject                 ; 
                    
                    lda CCW_CountActnHdlrCalls      ; counter ActionHandler routine calls
                    and #$03                        ; ......##
                    beq .GetBoothColor              ; 
                    
                    lda #00                         ; 
                    jmp .PaintBoothBack             ; 
                    
.GetBoothColor      lda CC_WaO_TypXmitBoothColor,x  ; 
                    
.PaintBoothBack     jsr ColorXmitBackWall           ; 
                    
                    lda CCW_CountActnHdlrCalls      ; counter ActionHandler routine calls
                    and #$03                        ; ......##
                    bne AutoMatterTargetX           ; 
                    
                    dec CC_WaO_TypXmitTimer,x       ; 
                    bne AutoMatterTargetX           ; 
                    
                    lda CC_WaO_ObjectFlag,x         ; 
                    eor #CC_WaO_Ready               ; action completed - CC_WaO_Ready
                    sta CC_WaO_ObjectFlag,x         ; 
                    
AutoMatterTargetX   jmp RetObjMoveAuto              ; 
; ------------------------------------------------------------------------------------------------------------- ;
; AutoTrapDoorOpen  Function: - Called from: ObjectHandler
;                   Parms   : xr=Object status area offset ($00, $08, $10, $18, ...)
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
AutoTrapDoorOpen    subroutine
                    clc
                    lda CC_WaO_TypTrapDataOff,x
                    adc CCW_TrapDataPtrLo
                    sta CCZ_RoomItemModLo
                    lda CCW_TrapDataPtrHi
                    adc #$00
                    sta CCZ_RoomItemModHi
                    
                    lda CC_WaO_TypTrapMode,x
                    beq .ChkOpenMax                 ; CC_WaO_TypTrapClosed
                    
.SetNextOpen        ldy #CC_Obj_TrapDoorGridCol
                    lda (CCZ_RoomTrapMod),y
                    sta CCZ_PntObj01PrmGridCol
                    ldy #CC_Obj_TrapDoorGridRow
                    lda (CCZ_RoomTrapMod),y
                    sta CCZ_PntObj01PrmGridRow
                    
                    lda CC_WaO_TypTrapPhaseNo,x     ; object: Trap Door Phases
                    sta CCZ_PntObj01PrmNo
                    
                    jsr SetTrapSound
                    
                    lda #CCZ_PntObjPrmType01
                    sta CCZ_PntObjPrmType  
                    
.PaintOpen          jsr PaintObject
                    
                    lda CC_WaO_TypTrapPhaseNo,x
                    cmp #NoObjTrapMovMax            ; object: Trap Door Open Max
                    bne .OpenNext
                    
.SetBase            clc
                    ldy #CC_Obj_TrapDoorGridCol
                    lda (CCZ_RoomTrapMod),y
                    adc #CC_GridWidth
                    sta CCZ_PntObj00PrmGridCol
                    ldy #CC_Obj_TrapDoorGridRow
                    lda (CCZ_RoomTrapMod),y
                    sta CCZ_PntObj00PrmGridRow
                    lda #NoObjTrapMovBas            ; object: Trap Door Base Line if Open
                    sta CCZ_PntObj00PrmNo
                    
.PaintBase          jsr PaintWAObjTyp0
                    
                    jmp .Complete
                    
.ChkOpenMax         lda CC_WaO_TypTrapPhaseNo,x
                    cmp #NoObjTrapMovMax            ; object: Trap Door Open Max
                    bne .SetNextClose
                    
                    jsr PaintWAObjTyp1
                    
.SetNextClose       ldy #CC_Obj_TrapDoorGridCol
                    lda (CCZ_RoomTrapMod),y
                    sta CCZ_PntObj00PrmGridCol
                    ldy #CC_Obj_TrapDoorGridRow
                    lda (CCZ_RoomTrapMod),y
                    sta CCZ_PntObj00PrmGridRow
                    
                    lda CC_WaO_TypTrapPhaseNo,x     ; object: Trap Door Phases
                    sta CCZ_PntObj00PrmNo
                    
                    jsr SetTrapSound
                    
                    lda #CCZ_PntObjPrmType00
                    sta CCZ_PntObjPrmType  
                    
.PaintClose         jsr PaintObject
                    
.ChkCloseMax        lda CC_WaO_TypTrapPhaseNo,x
                    cmp #NoObjTrapMovMin            ; object: Trap Door Shut Max
                    beq .Complete
                    
.CloseNext          dec CC_WaO_TypTrapPhaseNo,x     ; shut the door a bit more
                    jmp AutoTrapOpenX
                    
.OpenNext           inc CC_WaO_TypTrapPhaseNo,x     ; open the door a bit more
                    jmp AutoTrapOpenX
                    
.Complete           lda CC_WaO_ObjectFlag,x
                    eor #CC_WaO_Ready               ; action completed - CC_WaO_Ready
                    sta CC_WaO_ObjectFlag,x
                    
AutoTrapOpenX       jmp RetObjMoveAuto
; ------------------------------------------------------------------------------------------------------------- ;
; SetTrapSound      Function: Vary the trap door open/close tone
;                   Parms   : ac=Open/close object number
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
SetTrapSound        subroutine
                    clc                             ; .hbu002. - make sound movable
                    adc #SFX_TrapSwitchHeight       ; .hbu002. - add tone hight
                    sec                             ; .hbu002.
                    sbc #NoObjTrapMovMin            ; .hbu002. - subtract min
                    sta SFX_TrapSwitchTone          ; vary tone
                    
                    lda #NoSndTrapSwitch            ; sound: Trap Door Switch
SetTrapSoundX       jmp InitSoundFx
; ------------------------------------------------------------------------------------------------------------- ;
; AutoSideWalkMove  Function: - Called from: ObjectHandler
;                   Parms   : xr=Object status area offset ($00, $08, $10, $18, ...)
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
AutoSideWalkMove    subroutine
                    clc
                    lda CCW_WalkDataPtrLo
                    adc CC_WaO_TypWalkDataOff,x
                    sta CCZ_RoomItemModLo
                    lda CCW_WalkDataPtrHi
                    adc #$00
                    sta CCZ_RoomItemModHi
                    
                    ldy #CC_Obj_WalkStatus
                    lda (CCZ_RoomWalkMod),y
                    bit Bit_oooo_o1oo               ; CC_Obj_WalkSwitchPressP1
                    beq .ChkFireButnP2
                    
                    bit Bit_ooo1_oooo               ; set here if p1 pressed fire
                    beq .ChkMove
                    
.ChkFireButnP2      bit Bit_oooo_1ooo               ; CC_Obj_WalkSwitchPressP2
                    beq .Walk
                    
                    bit Bit_oo1o_oooo               ; set here if p2 pressed fire
                    bne .Walk
                    
.ChkMove            bit Bit_oooo_ooo1
                    beq .SetMove
                    
                    eor #CC_Obj_WalkMoveRight       ; 
                    eor #CC_Obj_WalkStopLeft        ; 
                    sta (CCZ_RoomWalkMod),y
                    
.SetMoveStop        lda #CC_Obj_WalkSwitchColorNo   ; color: grey=stop
                    sta ColObjWalkSw01              ; walk control left
                    sta ColObjWalkSw02              ; walk control right
                    
                    lda #SFX_WalkSwitchOff          ; 
                    sta SFX_WalkSwitchTone          ; vary sound
                    jmp .Control
                    
.SetMove            ora #CC_Obj_WalkMoveRight       ; 
                    sta (CCZ_RoomWalkMod),y         ; 
                    
                    and #CC_Obj_WalkStopLeft        ; 
                    beq .SetCtrlRight
                    
.SetCtrlLeft        lda #CC_Obj_WalkSwitchColorLe   ; color: green=move left
                    sta ColObjWalkSw01              ; walk control left
                    lda #CC_Obj_WalkSwitchColorNo   ; color: grey=inactive
                    sta ColObjWalkSw02              ; walk control right
                    
                    lda #SFX_WalkSwitchLeft         ; 
                    sta SFX_WalkSwitchTone          ; vary sound
                    jmp .Control
                    
.SetCtrlRight       lda #CC_Obj_WalkSwitchColorNo   ; color: grey=inactive
                    sta ColObjWalkSw01              ; walk control left
                    lda #CC_Obj_WalkSwitchColorRi   ; color: left=move right
                    sta ColObjWalkSw02              ; walk control right
                    
                    lda #SFX_WalkSwitchRight        ; 
                    sta SFX_WalkSwitchTone          ; vary sound
                    
.Control            ldy #CC_Obj_WalkSwitchGridCol
                    lda (CCZ_RoomWalkMod),y
                    sta CCZ_PntObj00PrmGridCol
                    ldy #CC_Obj_WalkSwitchGridRow
                    lda (CCZ_RoomWalkMod),y
                    sta CCZ_PntObj00PrmGridRow
                    
                    lda #NoObjWalkSw                ; object: Moving Sidewalk Control
                    sta CCZ_PntObj00PrmNo
                    lda #CCZ_PntObjPrmType00
                    sta CCZ_PntObjPrmType  
                    
.PaintControl       jsr PaintObject
                    
                    lda #NoSndWalkSwitch            ; sound: Moving Sidewalk Switch
                    jsr InitSoundFx
                    
.Walk               ldy #CC_Obj_WalkStatus
                    lda #$ff
                    eor #CC_Obj_WalkSwitchPressP1S  ; 
                    eor #CC_Obj_WalkSwitchPressP2S  ;
                    and (CCZ_RoomWalkMod),y         ; 
                    bit Bit_oooo_o1oo               ; CC_Obj_WalkSwitchPressP1
                    beq .ChkFireP2
                    
.FireP1             ora #CC_Obj_WalkSwitchPressP1S  ; 
                    eor #CC_Obj_WalkSwitchPressP1   ; reset
                    
.ChkFireP2          bit Bit_oooo_1ooo               ; CC_Obj_WalkSwitchPressP2
                    beq .SetFire
                    
.FireP2             ora #CC_Obj_WalkSwitchPressP2S  ; 
                    eor #CC_Obj_WalkSwitchPressP2   ; reset
                    
.SetFire            sta (CCZ_RoomWalkMod),y
                    and #CC_Obj_WalkMoveRight       ; 
                    beq AutoSideWalkMoveX           ; stopped
                    
                    lda CCW_CountActnHdlrCalls      ; counter ActionHandler routine calls
                    and #$01
                    bne AutoSideWalkMoveX
                    
                    lda CC_WaO_ObjectNo,x
                    sta CCZ_PntObj00PrmNo
                    lda (CCZ_RoomWalkMod),y
                    and #CC_Obj_WalkStopLeft        ; 
                    bne .MoveWalkLeft               ; 
                    
.MoveWalkRight      inc CCZ_PntObj00PrmNo
                    lda CCZ_PntObj00PrmNo
                    cmp #NoObjWalkMovMax            ; object: Moving Sidewalk Max
                    bcc .SetWalk
                    
                    lda #NoObjWalkMov01             ; object: Moving Sidewalk Phase 01
                    sta CCZ_PntObj00PrmNo
                    jmp .SetWalk
                    
.MoveWalkLeft       dec CCZ_PntObj00PrmNo
                    lda CCZ_PntObj00PrmNo
                    cmp #NoObjWalkMovMin            ; object: Moving Sidewalk Min
                    bcs .SetWalk
                    
                    lda #NoObjWalkMov04             ; object: Moving Sidewalk Phase 04
                    sta CCZ_PntObj00PrmNo
                    
.SetWalk            lda CC_WaO_ObjectGridCol,x
                    sta CCZ_PntObj00PrmGridCol
                    lda CC_WaO_ObjectGridRow,x
                    sta CCZ_PntObj00PrmGridRow
                    
.PaintWalk          jsr PaintWAObjTyp0
                    
AutoSideWalkMoveX   jmp RetObjMoveAuto
; ------------------------------------------------------------------------------------------------------------- ;
; ManuDoorLeave     Function: - called from: SprtBkgrHandler
;                   Parms   : xr=Sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                           : yr=Status work area block offset 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
ManuDoorLeave       subroutine
                    sty CCW_DoorOffTypWA            ; YR=CCW_ObjWAOffHit (offset status work area block to handle)
                    
                    lda CC_WaO_TypDoorFlag,y        ; shut=00 open=01
                    beq .Exit                       ; 
                    
                    lda CC_WaS_SpriteType,x         ; $00=Player $01=Spark $02=Force $03=Mummy $04=Beam $05=Frank
                    beq .Player                     ; 
                    
.Exit               jmp ManuDoorLeaveX              ; 
                    
.Player             lda CC_WaS_PlayerMoveDir,x      ; 
                    cmp #CC_WaS_JoyMoveUR           ; 
                    bne ManuDoorLeaveX              ; 
                    
                    ldy CC_WaS_PlayerSpriteNo,x     ; 
                    lda CCL_PlayersStatus,y         ; 
                    cmp #CCL_PlayerSurvive          ; 
                    bne ManuDoorLeaveX              ; 
                    
                    lda #CCL_PlayerRoomInOutInit    ; 
                    sta CCL_PlayersStatus,y         ; 
                    
                    lda #$00                        ; 
                    sta CC_WaS_PlayerRoomIOB,x      ; offset TabPlayerRoomIO block
                    
                    lda #$03                        ; 
                    sta CC_WaS_SpriteSeqNo,x        ; 
                    
                    ldy CCW_DoorOffTypWA            ; 
                    lda CC_WaO_TypDoorNo,y          ; 
                    asl a                           ; *2
                    asl a                           ; *4
                    asl a                           ; *8
                    clc                             ; 
                    adc CCW_DoorDataPtrLo           ; 
                    sta CCZ_RoomItemModLo           ; 
                    lda CCW_DoorDataPtrHi           ; 
                    adc #$00                        ; 
                    sta CCZ_RoomItemModHi           ; 
                    
                    ldy #CC_Obj_DoorGridRow         ; 
                    clc                             ; 
                    lda (CCZ_RoomDoorMod),y         ; door object
                    adc #$0f                        ; 
                    sta CC_WaS_SpritePosY,x         ; 
                    ldy #CC_Obj_DoorGridCol         ; 
                    clc                             ; 
                    lda (CCZ_RoomDoorMod),y         ; door object
                    adc #$06                        ; 
                    sta CC_WaS_SpritePosX,x             ; 
                    
                    ldy #CC_Obj_DoorType            ; 
                    lda (CCZ_RoomDoorMod),y         ; door object
                    beq .NormalDoor                 ; 
                    
.ExitDoor           ldy CC_WaS_PlayerSpriteNo,x     ; 
                    lda #$01                        ; 
                    sta CCL_PlayersAtDoor,y         ; 
                    
.NormalDoor         ldy #CC_Obj_DoorToDoorNo        ; 
                    lda (CCZ_RoomDoorMod),y         ; door object
                    sta CCW_DoorTargDoorNo          ; 
                    ldy #CC_Obj_DoorToRoomNo        ; 
                    lda (CCZ_RoomDoorMod),y         ; door object
                    sta CCW_DoorTargRoomNo          ;
                    
                    jsr SetRoomDataPtr              ; 
                    
                    ldy #CC_Obj_RoomColor           ; 
                    lda (CCZ_RoomData),y            ; 
                    ora #CC_Obj_RoomVisited         ; CC_Obj_RoomVisited
                    sta (CCZ_RoomData),y            ; 
                    
                    ldy CC_WaS_PlayerSpriteNo,x     ; 
                    lda CCW_DoorTargRoomNo          ; 
                    sta CCL_PlayersTargetRoomNo,y   ; count start: entry 00 of ROOM list
                    lda CCW_DoorTargDoorNo          ; 
                    sta CCL_PlayersTargetDoorNo,y   ; count start: entry 00 of Room DOOR list
                    
                    jsr RoomDataSave                ; .hbu017.
                    
ManuDoorLeaveX      ldy CCW_DoorOffTypWA            ; 
                    jmp RetObjMoveManu              ; 
; ------------------------------------------------------------------------------------------------------------- ;
; ManuBellPress     Function: - called from: SprtBkgrHandler
;                   Parms   : xr=Sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                           : yr=Status work area block offset 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
ManuBellPress       subroutine
                    stx CCW_BellOffTypWA            ; YR=CCW_ObjWAOffHit (offset status work area block to handle)
                    
                    lda CC_WaS_SpriteType,x         ; $00=Player $01=Spark $02=Force $03=Mummy $04=Beam $05=Frank
                    bne ManuBellPressX              ; only a player can press the button
                    
                    lda CC_WaS_SpriteMoveDir,x
                    beq ManuBellPressX              ; CC_WaS_JoyNoFire
                    
                    clc
                    lda CC_WaS_SpritePosX,x
                    adc CC_WaS_SpriteStepX,x
                    sec
                    sbc CC_WaO_ObjectGridCol,y
                    cmp #$0c
                    bcs ManuBellPressX
                    
                    lda CC_WaS_PlayerSpriteNo,x
                    tax
                    lda CCL_PlayersStatus,x
                    cmp #CCL_PlayerSurvive
                    bne ManuBellPressX
                    
                    ldx #$00
.GetWADoor          lda CC_WaO_ObjectType,x
                    bne .SetNextWA                  ; no door
                    
                    lda CC_WaO_TypDoorNo,x
                    cmp CC_WaO_TypBellTargDoorNo,y
                    beq .Found
                    
.SetNextWA          clc
                    txa
                    adc #$08
                    tax
                    jmp .GetWADoor
                    
.Found              lda CC_WaO_TypDoorFlag,x
                    bne ManuBellPressX              ; CC_WaO_TypDoorOpen
                    
                    lda CC_WaO_ObjectFlag,x
                    ora #CC_WaO_Ready               ; action completed - CC_WaO_Ready
                    sta CC_WaO_ObjectFlag,x
                    
ManuBellPressX      ldx CCW_BellOffTypWA
                    jmp RetObjMoveManu
; ------------------------------------------------------------------------------------------------------------- ;
; ManuLightSwitch   Function: - called from: SprtBkgrHandler
;                   Parms   : xr=Sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                           : yr=Status work area block offset 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
ManuLightSwitch     subroutine
                    lda CC_WaS_SpriteType,x         ; $00=Player $01=Spark $02=Force $03=Mummy $04=Beam $05=Frank
                    bne .Exit
                    
                    clc
                    lda CC_WaS_SpritePosX,x
                    adc CC_WaS_SpriteStepX,x
                    sec
                    sbc CC_WaO_ObjectGridCol,y
                    cmp #$04
                    bcs .Exit
                    
                    lda CC_WaS_PlayerMoveDir,x
                    beq .Switch                     ; CC_WaS_JoyMoveU
                    
                    cmp #CC_WaS_JoyMoveD
                    beq .Switch
                    
.Exit               jmp ManuLightSwitchX
                    
.Switch             lda #$00
                    sta CCW_LightSwtchBallList
                    
                    clc
                    lda CCW_LightSwtchDataPtrLo
                    adc CC_WaO_TypLightBallNo,y
                    sta CCZ_RoomLiSwModLo
                    lda CCW_LightSwtchDataPtrHi
                    adc #$00
                    sta CCZ_RoomLiSwModHi
                    
                    sty CCW_LightSwtchOffTypeWA     ; offset status work area block to handle
                    
                    ldy #CC_Obj_LightMode
                    lda (CCZ_RoomLiSwMod),y
                    and #CC_Obj_LightBallOn         ; CC_Obj_LightBallOn
                    bne .Check
                    
                    lda CC_WaS_PlayerMoveDir,x
                    bne .Exit                       ; not CC_WaS_JoyMoveU
                    
                    jmp .SetSwitchOn
                    
.Check              lda CC_WaS_PlayerMoveDir,x
                    beq .Exit                       ; CC_WaS_JoyMoveU
                    
.SetSwitchOn        lda (CCZ_RoomLiSwMod),y
                    eor #CC_Obj_LightBallOn         ; set on
                    sta (CCZ_RoomLiSwMod),y
                    
.SelctionList       lda CCW_LightSwtchBallList
                    cmp #$04                        ; length selection list
                    bcs .GoKlick                    ; greater/equal
                    
                    clc
                    lda #$04
                    adc CCW_LightSwtchBallList
                    tay
                    lda (CCZ_RoomLiSwMod),y
                    cmp #CC_WaO_TypLightBallNone
                    bne .HandleBall
                    
.GoKlick            jmp .Klick
                    
.HandleBall         sta CCW_LightSwtchBallNo
                    clc
                    adc CCW_LightSwtchDataPtrLo
                    sta CCZ_RoomLiBaModLo
                    lda CCW_LightSwtchDataPtrHi
                    adc #$00
                    sta CCZ_RoomLiBaModHi
                    
                    ldy #CC_Obj_LightMode
                    lda (CCZ_RoomLiBaMod),y
                    eor #CC_Obj_LightBallOn         ; set on
                    sta (CCZ_RoomLiBaMod),y
                    
                    ldy #$00
.SearchWA           lda CC_WaO_ObjectType,y
                    cmp #CC_WaO_LightBall
                    bne .SetNextWA
                    
                    lda CC_WaO_TypLightBallNo,y
                    cmp CCW_LightSwtchBallNo
                    beq .FoundWA
                    
.SetNextWA          tya
                    clc
                    adc #$08
                    tay
                    jmp .SearchWA
                    
.FoundWA            lda CC_WaO_ObjectFlag,y
                    ora #CC_WaO_Ready               ; action completed - CC_WaO_Ready
                    sta CC_WaO_ObjectFlag,y
                    
                    inc CCW_LightSwtchBallList
                    jmp .SelctionList
                    
.Klick              ldy #CC_Obj_LightMode
                    lda (CCZ_RoomLiSwMod),y
                    and #CC_Obj_LightBallOn         ; CC_LMBallOn
                    bne .KlickOn
                    
.KlickOff           lda #SFX_LightSwitchOff         ; 
                    sta SFX_LightSwitchTone         ; vary sound
                    
                    lda #NoObjLiMaSwDo              ; object: Lightning Machine Switch Down
                    jmp .SetSwitch
                    
.KlickOn            lda #SFX_LightSwitchOn          ; 
                    sta SFX_LightSwitchTone         ; vary sound
                    
                    lda #NoObjLiMaSwUp              ; object: Lightning Machine Switch Up
.SetSwitch          sta CCZ_PntObj00PrmNo
                    
                    ldy CCW_LightSwtchOffTypeWA     ; offset status work area block to handle
                    lda CC_WaO_ObjectGridCol,y
                    sta CCZ_PntObj00PrmGridCol
                    lda CC_WaO_ObjectGridRow,y
                    sta CCZ_PntObj00PrmGridRow
                    stx CCW_LightSwtchOffSprtWA
                    ldx CCW_LightSwtchOffTypeWA     ; offset status work area block to handle
                    
.PaintSwitch        jsr PaintWAObjTyp0
                    
                    ldx CCW_LightSwtchOffSprtWA
                    ldy CCW_LightSwtchOffTypeWA     ; offset status work area block to handle
                    
                    lda #NoSndLiMacSwitch           ; sound: Lightning Machine Switch
                    jsr InitSoundFx
                    
ManuLightSwitchX    jmp RetObjMoveManu
; ------------------------------------------------------------------------------------------------------------- ;
; ManuForceSwitch   Function: - called from: SprtBkgrHandler
;                   Parms   : xr=Sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                           : yr=Status work area block offset 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
ManuForceSwitch     subroutine
                    lda CC_WaS_SpriteType,x         ; $00=Player $01=Spark $02=Force $03=Mummy $04=Beam $05=Frank
                    bne ManuForceSwitchX
                    
                    lda CC_WaS_SpriteMoveDir,x
                    beq ManuForceSwitchX
                    
                    lda #SFX_ForcePingSwitch        ; switch sound
                    sta SFX_ForcePingHeight         ; 
                    
                    lda #NoSndForcePing             ; sound: Close Force Field Ping
                    jsr InitSoundFx
                    
                    lda CC_WaO_ObjectFlag,y
                    ora #CC_WaO_Ready               ; action completed - CC_WaO_Ready
                    sta CC_WaO_ObjectFlag,y
                    
                    lda #CC_WaO_TypForcePingInit
                    sta CC_WaO_TypForcePingSecs,y   ; init second counter
                    lda #CC_WaO_TypForceTimerInit
                    sta CC_WaO_TypForceTimer,y
                    
                    lda #$55                        ; .#.#.#.# - pattern force field switch timer square
                    sta DatObjFoFiTime01
                    sta DatObjFoFiTime02
                    sta DatObjFoFiTime03
                    sta DatObjFoFiTime04
                    sta DatObjFoFiTime05
                    sta DatObjFoFiTime06
                    sta DatObjFoFiTime07
                    sta DatObjFoFiTime08
                    
                    lda CC_WaO_ObjectGridCol,y
                    sta CCZ_PntObj01PrmGridCol
                    lda CC_WaO_ObjectGridRow,y
                    sta CCZ_PntObj01PrmGridRow
                    
                    lda CC_WaO_ObjectNo,y
                    sta CCZ_PntObj01PrmNo
                    lda #CCZ_PntObjPrmType01
                    sta CCZ_PntObjPrmType  
                    
.PaintSwitch        jsr PaintObject
                    
                    lda CC_WaO_TypForceNo,y
                    tay
                    lda #CCW_ForceOpen
                    sta CCW_ForceStatusTab,y
                    
ManuForceSwitchX    jmp RetObjMoveManu
; ------------------------------------------------------------------------------------------------------------- ;
; ManuMummyBirth    Function: - called from: SprtBkgrHandler
;                   Parms   : xr=Sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                           : yr=Status work area block offset 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
ManuMummyBirth      subroutine
                    stx CCW_MummyOffSprtWA
                    sty CCW_MummyOffTypeWA
                    
                    lda CC_WaS_SpriteType,x         ; $00=Player $01=Spark $02=Force $03=Mummy $04=Beam $05=Frank
                    bne .Exit                       ; no player
                    
                    clc
                    lda CC_WaS_SpritePosX,x
                    adc CC_WaS_SpriteStepX,x
                    sec
                    sbc CC_WaO_ObjectGridCol,y
                    cmp #$08
                    bcs .Exit
                    
                    clc
                    lda CCW_MummyDataPtrLo
                    adc CC_WaO_TypMummyPtrWA,y
                    sta CCZ_RoomItemModLo
                    lda CCW_MummyDataPtrHi
                    adc #$00
                    sta CCZ_RoomItemModHi
                    
                    ldy #CC_Obj_MummyStatus
                    lda (CCZ_RoomMummyMod),y
                    cmp #CC_Obj_MummyIn
                    beq .Birth
                    
.Exit               jmp ManuMummyBirthX
                    
.Birth              lda #CC_Obj_MummyOut
                    ldy #CC_Obj_MummyStatus
                    sta (CCZ_RoomMummyMod),y
                    
                    clc
                    ldy #CC_Obj_MummyWallGridCol
                    lda (CCZ_RoomMummyMod),y
                    adc #CC_GridWidth
                    ldy #CC_Obj_MummySpriteCol
                    sta (CCZ_RoomMummyMod),y
                    
                    clc
                    ldy #CC_Obj_MummyWallGridRow
                    lda (CCZ_RoomMummyMod),y
                    adc #$07
                    ldy #CC_Obj_MummySpriteRow
                    sta (CCZ_RoomMummyMod),y
                    
                    ldy CCW_MummyOffTypeWA
                    lda CC_WaO_ObjectFlag,y
                    ora #CC_WaO_Ready               ; action completed - CC_WaO_Ready
                    sta CC_WaO_ObjectFlag,y
                    
                    lda #CC_WaO_TypMummyTimerInit
                    sta CC_WaO_TypMummyTimer,y
                    
                    lda #CC_Obj_MummAnkhColor
                    sta CC_WaO_TypMummyAnkhColor,y
                    
                    ldy #CC_Obj_MummyWallGridCol
                    lda (CCZ_RoomMummyMod),y
                    clc
                    adc #CC_GridWidth
                    sta CCZ_PntObj01PrmGridCol
                    
                    ldy #CC_Obj_MummyWallGridRow
                    lda (CCZ_RoomMummyMod),y
                    clc
                    adc #CC_GridHeight
                    sta CCZ_PntObj01PrmGridRow
                    
                    lda #CCW_MummyWallRowsMax
                    sta CCW_MummyOutWallRows
                    
                    lda #NoObjMummyWall             ; object: Mummy Wall Brick
                    sta CCZ_PntObj01PrmNo
                    lda #CCZ_PntObjPrmType01
                    sta CCZ_PntObjPrmType 
                    
.PaintWall          jsr PaintObject
                    
                    clc
                    lda CCZ_PntObj01PrmGridCol
                    adc #CC_GridWidth
                    sta CCZ_PntObj01PrmGridCol
                    dec CCW_MummyOutWallRows
                    bne .PaintWall
                    
                    lda #NoObjMummyOut              ; object: Mummy Wall Open
                    sta CCZ_PntObj00PrmNo
                    
                    sec
                    lda CCZ_PntObj01PrmGridCol
                    sbc #$0c
                    sta CCZ_PntObj00PrmGridCol
                    lda CCZ_PntObj01PrmGridRow
                    sta CCZ_PntObj00PrmGridRow
                    lda #CCZ_PntObjPrmType00
                    sta CCZ_PntObjPrmType  
                    
.PaintOpening       jsr PaintObject
                    
                    ldx CCW_MummyOffTypeWA
                    lda #$00                        ; flag: get mummy out
                    jsr InitSpriteMummy
                    
ManuMummyBirthX     ldx CCW_MummyOffSprtWA
                    ldy CCW_MummyOffTypeWA
                    jmp RetObjMoveManu
; ------------------------------------------------------------------------------------------------------------- ;
; ManuKeyPick       Function: - called from: SprtBkgrHandler
;                   Parms   : xr=Sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                           : yr=Status work area block offset 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
ManuKeyPick         subroutine
                    sty CCW_KeyOffTypWA
                    lda CC_WaS_SpriteType,x         ; $00=Player $01=Spark $02=Force $03=Mummy $04=Beam $05=Frank
                    bne ManuKeyPickX                ; no player
                    
                    ldy CC_WaS_PlayerSpriteNo,x
                    lda CCL_PlayersStatus,y
                    cmp #CCL_PlayerSurvive
                    bne ManuKeyPickX
                    
                    lda CC_WaS_SpriteMoveDir,x
                    beq ManuKeyPickX
                    
                    ldy CCW_KeyOffTypWA
                    lda CC_WaO_ObjectFlag,y
                    ora #CC_WaO_Move                ; move - CC_WaO_Move
                    sta CC_WaO_ObjectFlag,y
                    
                    clc
                    lda CCW_KeyDataPtrLo
                    adc CC_WaO_TypKeyData,y
                    sta CCZ_RoomItemModLo
                    lda CCW_KeyDataPtrHi
                    adc #$00
                    sta CCZ_RoomItemModHi
                    
                    ldy #CC_Obj_KeyStatus
                    lda #CC_Obj_KeyPickedUp
                    sta (CCZ_RoomKeyMod),y
                    
                    ldy #CC_Obj_KeyColor
                    lda (CCZ_RoomKeyMod),y
                    sta CCW_KeyDataNext
                    
                    clc                             ; .hbu007.
                    adc #SFX_KeyPickHeight          ; .hbu007.
                    sta SFX_KeyPickTone             ; .hbu007. - vary tone
                    
                    lda #NoSndKeyPing               ; sound: Pick Up Key Ping
                    jsr InitSoundFx
                    
                    lda CC_WaS_PlayerSpriteNo,x
                    beq .Player1
                    
.Player2            ldy CCL_Player2KeysAmount       ; count start: 00
                    inc CCL_Player2KeysAmount       ; 
                    lda CCW_KeyDataNext
                    sta CCL_Player2KeysCollect,y    ; 7 entries - stored unsorted as they were collected
                    jmp ManuKeyPickX
                    
.Player1            ldy CCL_Player1KeysAmount       ; count start: 00
                    inc CCL_Player1KeysAmount       ; 
                    lda CCW_KeyDataNext
                    sta CCL_Player1KeysCollect,y    ; 7 entries - stored unsorted as they were collected
                    
ManuKeyPickX        jmp RetObjMoveManu
; ------------------------------------------------------------------------------------------------------------- ;
; ManuLockOpen      Function: - called from: SprtBkgrHandler
;                   Parms   : xr=Sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                           : yr=Status work area block offset 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
ManuLockOpen        subroutine
                    stx CCW_LockOffTypWA
                    
                    lda CC_WaS_SpriteType,x         ; $00=Player $01=Spark $02=Force $03=Mummy $04=Beam $05=Frank
                    bne ManuLockOpenX               ; no player
                    
                    lda CC_WaS_PlayerSpriteNo,x
                    tax
                    lda CCL_PlayersStatus,x
                    cmp #CCL_PlayerSurvive
                    bne ManuLockOpenX
                    
                    ldx CCW_LockOffTypWA
                    lda CC_WaS_SpriteMoveDir,x
                    beq ManuLockOpenX
                    
                    lda CC_WaO_TypLockColor,y
                    jsr SearchKeyInList
                    bcs ManuLockOpenX               ; key not yet collected
                    
                    ldx #$00
.SearchWA           lda CC_WaO_ObjectType,x
                    bne .SetNextWA
                    
                    lda CC_WaO_TypDoorNo,x          ; is door number
                    cmp CC_WaO_TypLockTargDoorNo,y  ; same as lock door number
                    beq .Found                      ; yes
                    
.SetNextWA          txa
                    clc
                    adc #$08
                    tax
                    jmp .SearchWA
                    
.Found              lda CC_WaO_TypLockTargDoorNo,x
                    bne ManuLockOpenX
                    
                    lda CC_WaO_ObjectFlag,x
                    ora #CC_WaO_Ready               ; action completed - CC_WaO_Ready
                    sta CC_WaO_ObjectFlag,x
                    
ManuLockOpenX       ldx CCW_LockOffTypWA
                    jmp RetObjMoveManu
; ------------------------------------------------------------------------------------------------------------- ;
; ManuRayGunSwitch  Function: - called from: SprtBkgrHandler
;                   Parms   : xr=Sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                           : yr=Status work area block offset 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
ManuRayGunSwitch    subroutine
                    sty CCW_GunOffTypWA             ; offset status work area block to handle
                    
                    lda CC_WaS_SpriteType,x         ; $00=Player $01=Spark $02=Force $03=Mummy $04=Beam $05=Frank
                    bne ManuRayGunSwitchX           ; no player
                    
                    clc
                    lda CC_WaS_SpritePosX,x
                    adc CC_WaS_SpriteStepX,x
                    sec
                    sbc CC_WaO_ObjectGridCol,y
                    cmp #$08
                    bcs ManuRayGunSwitchX
                    
                    ldy CC_WaS_PlayerSpriteNo,x
                    lda CCL_PlayersStatus,y
                    cmp #CCL_PlayerSurvive
                    bne ManuRayGunSwitchX
                    
                    ldy CCW_GunOffTypWA
                    clc
                    lda CCW_GunDataPtrLo
                    adc CC_WaO_TypGunPtrWA,y
                    sta CCZ_RoomItemModLo
                    lda CCW_GunDataPtrHi
                    adc #$00
                    sta CCZ_RoomItemModHi
                    
                    lda #$ff
                    eor #CC_Obj_GunMoveUp           ; CC_Obj_GunMoveUp
                    eor #CC_Obj_GunMoveDown         ; CC_Obj_GunMoveDown
                    
                    ldy #CC_Obj_GunDirection
                    and (CCZ_RoomGunMod),y
                    ldy CC_WaS_PlayerMoveDir,x
                    bne .ChkJoyDown                 ; not CC_WaS_JoyMoveU
                    
.MoveUp             ora #CC_Obj_GunMoveUp           ; set CC_Obj_GunMoveUp
                    jmp .MoveStop
                    
.ChkJoyDown         cpy #CC_WaS_JoyMoveD
                    bne .ChkBad
                    
.MoveDown           ora #CC_Obj_GunMoveDown        ; set CC_Obj_GunMoveDown
                    jmp .MoveStop
                    
.ChkBad             cpy #CC_WaS_JoyNoMove
                    bne ManuRayGunSwitchX
                    
.MoveStop           ora #CC_Obj_GunMoveStop        ; set CC_Obj_GunMoveStop
                    
                    ldy #CC_Obj_GunDirection
                    sta (CCZ_RoomGunMod),y
                    
                    lda CC_WaS_PlayerFire,x         ; .hbu019. - enable dauerfeuer for ray guns
                    beq .NoFire                     ; CC_WaS_JoyNoFire
                    
.MoveFire           lda (CCZ_RoomGunMod),y
                    ora #CC_Obj_GunMoveFire         ; set CC_Obj_GunMoveFire
                    jmp .SetMove
                    
.NoFire             lda #$ff
                    eor #CC_Obj_GunMoveFire         ; CC_Obj_GunMoveFire
                    and (CCZ_RoomGunMod),y
                    
.SetMove            sta (CCZ_RoomGunMod),y
                    
ManuRayGunSwitchX   jmp RetObjMoveManu
; ------------------------------------------------------------------------------------------------------------- ;
; ManuMatterBooth   Function: - called from: SprtBkgrHandler
;                   Parms   : xr=Sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                           : yr=Status work area block offset 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
ManuMatterBooth     subroutine
                    lda CC_WaO_ObjectFlag,y         ; 
                    and #CC_WaO_Ready               ; action completed - CC_WaO_Ready
                    bne .Exit                       ; 
                    
                    lda CC_WaS_SpriteType,x         ; $00=Player $01=Spark $02=Force $03=Mummy $04=Beam $05=Frank
                    bne .Exit                       ; no player
                    
                    sty CCW_XmitOffTypWA            ; 
                    
                    ldy CC_WaS_PlayerSpriteNo,x     ; 
                    lda CCL_PlayersStatus,y         ; 
                    cmp #CCL_PlayerSurvive          ; 
                    bne .Exit                       ; 
                    
                    ldy CCW_XmitOffTypWA            ; 
                    lda CC_WaO_TypXmitDataPtrLo,y   ; 
                    sta CCZ_RoomItemModLo
                    lda CC_WaO_TypXmitDataPtrHi,y
                    sta CCZ_RoomItemModHi
                    
                    lda CC_WaS_SpriteMoveDir,x
                    bne .Transmit
                    
                    lda CC_WaS_PlayerMoveDir,x
                    bne .Exit                       ; not CC_WaS_JoyMoveU
                    
                    lda CCW_CountActnHdlrCalls      ; counter ActionHandler routine calls
                    and #$0f
                    bne .Exit
                    
                    ldy #CC_Obj_XmitBoothColor
                    lda (CCZ_RoomMatterMod),y
                    
                    clc
                    adc #$01
                    sta (CCZ_RoomMatterMod),y
                    
                    asl a                           ; *2
                    adc #$03                        ; header data length
                    tay                             ; CC_Obj_XmitTarg0GridCol
                    lda (CCZ_RoomMatterMod),y
                    bne .SetExitColor
                    
.SetStartColor      lda #$00                        ; init color
                    ldy #CC_Obj_XmitBoothColor
                    sta (CCZ_RoomMatterMod),y
                    
.SetExitColor       ldy #CC_Obj_XmitBoothColor
                    lda (CCZ_RoomMatterMod),y
                    clc
                    adc #SFX_MatterSelHeight        ; 
                    sta SFX_MatterSelTone           ; vary select sound
                    
                    lda #NoSndMaTrSelect            ; sound: Matter Transmitter Select Receiver Oval
                    jsr InitSoundFx
                    
                    lda (CCZ_RoomMatterMod),y
                    clc
                    adc #$02                        ; bypass black/white
                    stx CCW_XmitBoothColor
                    ldx CCW_XmitOffTypWA
                    
                    jsr ColorXmitBackWall
                    
                    ldx CCW_XmitBoothColor
.Exit               jmp ManuMatterBoothX
                    
.Transmit           ldy CCW_XmitOffTypWA
                    lda CC_WaO_ObjectFlag,y
                    ora #CC_WaO_Ready               ; action completed - CC_WaO_Ready
                    sta CC_WaO_ObjectFlag,y
                    
                    lda #CC_WaO_TypXmitTimerInit
                    sta CC_WaO_TypXmitTimer,y
                    
                    ldy #CC_Obj_XmitBoothColor
                    lda (CCZ_RoomMatterMod),y
                    clc
                    adc #$02                        ; bypass black/white
                    ldy CCW_XmitOffTypWA
                    sta CC_WaO_TypXmitBoothColor,y
                    
                    ldy #CC_Obj_XmitBoothColor
                    lda (CCZ_RoomMatterMod),y
                    asl a                           ; *2
                    adc #$03                        ; header data length
                    
.SetTargetOval      tay                             ; CC_Obj_XmitTarg0GridCol
                    lda (CCZ_RoomMatterMod),y
                    pha
                    
                    iny                             ; CC_Obj_XmitTarg0GridRow
                    lda (CCZ_RoomMatterMod),y
                    ldy CCW_XmitOffTypWA
                    sta CC_WaO_TypXmitTargGridRow,y
                    clc
                    adc #$07
                    sta CC_WaS_SpritePosY,x
                    pla
                    sta CC_WaO_TypXmitTargGridCol,y
                    sta CC_WaS_SpritePosX,x
                    
ManuMatterBoothX    jmp RetObjMoveManu
; ------------------------------------------------------------------------------------------------------------- ;
; ManuSideWalkPace  Function: - called from: SprtBkgrHandler
;                   Parms   : xr=Sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                           : yr=Status work area block offset 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
ManuSideWalkPace    subroutine
                    clc
                    lda CCW_WalkDataPtrLo
                    adc CC_WaO_TypWalkDataOff,y
                    sta CCZ_RoomItemModLo
                    lda CCW_WalkDataPtrHi
                    adc #$00
                    sta CCZ_RoomItemModHi
                    
                    sty CCW_WalkOffTypWA
                    
                    ldy #CC_Obj_WalkStatus
                    lda (CCZ_RoomWalkMod),y
                    and #CC_Obj_WalkMoveRight       ; moves left/right if set
                    beq ManuSideWalkPaceX           ; stopped
                    
                    lda CC_WaS_SpriteType,x         ; $00=Player $01=Spark $02=Force $03=Mummy $04=Beam $05=Frank
                    beq .HandlePlayer
                    
                    cmp #CC_WaS_SpriteMummy         ; 
                    beq .HandleEnemy                ; 
                    
                    cmp #CC_WaS_SpriteFrank         ; 
                    beq .HandleEnemy
                    
                    jmp ManuSideWalkPaceX
                    
.HandlePlayer       lda CC_WaS_SpriteNo,x           ; 
                    cmp #$06                        ; NoSprPlrMovPole
                    bcs ManuSideWalkPaceX           ; higher/equal - handle only moves left/right
                    
.HandleEnemy        clc
                    lda CC_WaS_SpritePosX,x
                    adc CC_WaS_SpriteStepX,x
                    
                    ldy CCW_WalkOffTypWA
                    sec
                    sbc CC_WaO_ObjectGridCol,y      ; side walk start column
                    bcc ManuSideWalkPaceX           ; lower
                    
                    cmp #$20                        ; length sidewalk
                    bcs ManuSideWalkPaceX           ; higher/equal
                    
                    ldy #CC_Obj_WalkStatus
                    lda (CCZ_RoomWalkMod),y
                    and #CC_Obj_WalkStopLeft        ; 
                    beq .NormalPace                 ; 
                    
.BackPace           lda #$ff                        ; -1 makes it impossible to move further on
                    jmp .SetPace
                    
.NormalPace         lda #$01                        ; +1
                    
.SetPace            sta CCW_WalkSpritePacing
                    sta CC_WaS_MummyCollWalk,x      ; .hbu004. - keep pace to be able to spread mummies again
                    
                    lda CC_WaS_SpriteType,x         ; $00=Player $01=Spark $02=Force $03=Mummy $04=Beam $05=Frank
                    bne .DoublePace
                    
                    lda CCW_CountActnHdlrCalls      ; counter ActionHandler routine calls
                    and #$07
                    bne .AddPace
                    
.DoublePace         asl CCW_WalkSpritePacing        ; *2
                    
.AddPace            clc
                    lda CC_WaS_SpritePosX,x
                    adc CCW_WalkSpritePacing
                    sta CC_WaS_SpritePosX,x
                    
ManuSideWalkPaceX   jmp RetObjMoveManu
; ------------------------------------------------------------------------------------------------------------- ;
; ManuSideWalkSwitch Function: - called from: SprtBkgrHandler
;                    Parms   : xr=Sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                            : yr=Status work area block offset 
;                    Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
ManuSideWalkSwitch  subroutine
                    lda CC_WaS_SpriteType,x         ; $00=Player $01=Spark $02=Force $03=Mummy $04=Beam $05=Frank
                    bne ManuSideWalkSwitchX         ; no player
                    
                    lda CC_WaS_SpriteMoveDir,x
                    beq ManuSideWalkSwitchX         ; no fire button pressed
                    
                    clc
                    lda CCW_WalkDataPtrLo
                    adc CC_WaO_TypWalkDataOff,y
                    sta CCZ_RoomItemModLo
                    lda CCW_WalkDataPtrHi
                    adc #$00
                    sta CCZ_RoomItemModHi
                    
                    lda CC_WaS_PlayerSpriteNo,x
                    beq .MarkPlayer1
                    
.MarkPlayer2        lda #CC_Obj_WalkSwitchPressP2   ; 
                    jmp .SetMarkPlayer
                    
.MarkPlayer1        lda #CC_Obj_WalkSwitchPressP1   ; 
                    
.SetMarkPlayer      ldy #CC_Obj_WalkStatus
                    ora (CCZ_RoomWalkMod),y
                    sta (CCZ_RoomWalkMod),y
                    
ManuSideWalkSwitchX jmp RetObjMoveManu
; ------------------------------------------------------------------------------------------------------------- ;
; MovePlayerSprite  Function: 
;                   Parms   : xr=Sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
MovePlayerSprite    subroutine
                    lda CC_WaS_SpriteFlag,x         ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    bit Bit_ooo1_oooo               ;            $10=action   $20=death          $40=dead           $80=init
                    beq .ChkInit                    ; 
                    
                    eor #CC_WaS_FlagAction          ; 
                    ora #CC_WaS_Flag08              ; 
                    sta CC_WaS_SpriteFlag,x         ; 
                    
                    lda CC_WaS_PlayerSpriteNo,x     ; 
                    asl a                           ; *2
                    tay                             ; 
                    lda TabAdrCiaTimers,y           ; CIA1: $DC08 - Time of Day Clock start / CIA2: $DD08 - Time of Day Clock start
                    sta CCZ_GetCIATimeLo            ; 
                    lda TabAdrCiaTimers+1,y         ; 
                    sta CCZ_GetCIATimeHi            ; 
                    
                    lda TabAdrLvlPlayTimes,y        ; CCL_Player1Times / CCL_Player2Times
                    sta CCZ_PutLevelTimeLo          ; 
                    lda TabAdrLvlPlayTimes+1,y      ; 
                    sta CCZ_PutLevelTimeHi          ; 
                    
                    ldy #CCL_PlayersTimesLen        ; 
.PutPlayTime        lda (CCZ_GetCIATime),y          ; save play time
                    sta (CCZ_PutLevelTime),y        ; 
                    dey                             ; 
                    bpl .PutPlayTime                ; 
                    
                    jmp MovePlayerSpriteX           ; 
                    
.ChkInit            bit Bit_1ooo_oooo               ; init
                    beq .ChkStatXtra                ; 
                    
                    eor #CC_WaS_FlagInit            ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    sta CC_WaS_SpriteFlag,x         ; $10=action $20=dead $40=death $80=initialized
                    
                    lda CC_WaS_PlayerSpriteNo,x     ; 
                    asl a                           ; *2
                    tay                             ; 
                    lda TabAdrCiaTimers,y           ; CIA1: $DC08 - Time of Day Clock start / CIA2: $DD08 - Time of Day Clock start
                    sta CCZ_PutCIATimeLo            ; 
                    lda TabAdrCiaTimers+1,y         ; 
                    sta CCZ_PutCIATimeHi            ; 
                    
                    lda TabAdrLvlPlayTimes,y        ; CCL_Player1Times / CCL_Player2Times
                    sta CCZ_GetLevelTimeLo          ; 
                    lda TabAdrLvlPlayTimes+1,y      ; 
                    sta CCZ_GetLevelTimeHi          ; 
                    
                    ldy #CCL_PlayersTimesLen        ; 
.GetPlayTime        lda (CCZ_GetLevelTime),y        ; restore play time
                    sta (CCZ_PutCIATime),y          ;  
                    dey                             ; 
                    bpl .GetPlayTime                ; 
                    
                    ldy CC_WaS_PlayerSpriteNo,x     ;
                    lda CCL_PlayersStatus,y         ; 
                    cmp #CCL_PlayerRoomInOutInit    ; 
                    beq .SetIOPhase                 ; 
                    
                    jsr GetSpriteData               ; 
                    
                    jmp .ChkSprtObjWA               ; 
                    
.ChkStatXtra        lda CC_WaS_PlayerSpriteNo,x     ; 
                    tay                             ; 
                    lda CCL_PlayersStatus,y         ; 
                    cmp #CCL_PlayerRoomInOut        ; 
                    beq .ChkNextIOPhase             ; 
                    
                    cmp #CCL_PlayerRoomInOutInit    ; 
                    bne .ChkStatus00                ; 
                    
                    lda #CCL_PlayerRoomInOut        ; 
                    sta CCL_PlayersStatus,y         ; 
                    jmp .SetIOPhase                 ; 
                    
.ChkNextIOPhase     sty CCW_GetSpriteDataNo         ; 
                    ldy CC_WaS_PlayerRoomIOB,x      ; offset TabPlayerRoomIO block
                    lda TabIOPlayerFlag,y           ; 
                    cmp #$ff                        ; 
                    beq .SetNextIOPhase             ; 
                    
.SetIOReady         ldy CCW_GetSpriteDataNo         ; 
                    sta CCL_PlayersStatus,y         ; 
                    lda #$01
                    sta CC_WaS_SpriteSeqNo,x
                    lda CCL_PlayersStatus,y
                    jmp .ChkStatus00
                    
.SetNextIOPhase     clc
                    lda CC_WaS_PlayerRoomIOB,x      ; offset TabPlayerRoomIO block
                    adc #$04
                    sta CC_WaS_PlayerRoomIOB,x      ; offset TabPlayerRoomIO block
                    tay
                    
                    clc
                    lda CC_WaS_SpritePosX,x
                    adc TabIOPlayerOffX,y
                    sta CC_WaS_SpritePosX,x
                    
                    clc
                    lda CC_WaS_SpritePosY,x
                    adc TabIOPlayerOffY,y
                    sta CC_WaS_SpritePosY,x
                    
.SetIOPhase         ldy CC_WaS_PlayerRoomIOB,x     ; offset TabPlayerRoomIO block
                    lda TabIOPlayerSNo,y
                    sta CC_WaS_SpriteNo,x
                    
                    jsr GetSpriteData
                    
                    jmp MovePlayerSpriteX
                    
.ChkStatus00        cmp #$00
                    beq .ChkSprtObjWA
                    
                    lda CC_WaS_SpriteFlag,x         ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    ora #CC_WaS_FlagAction          ;            $10=action   $20=death          $40=dead           $80=init
                    sta CC_WaS_SpriteFlag,x
                    jmp MovePlayerSpriteX
                    
.ChkSprtObjWA       lda CC_WaS_SpriteObj,x
                    cmp #$ff
                    beq .SetSprtObjWA
                    
                    cmp CC_WaS_SpriteWrk,x
                    beq .SetSprtObjWA
                    
                    jsr TrapDoorHandler
                    
.SetSprtObjWA       sta CC_WaS_SpriteWrk,x
                    lda #$ff
                    sta CC_WaS_SpriteObj,x
                    
                    jsr SetCtrlSprtPtr              ; set move control screen pointer for sprites
; ------------------------------------------------------------------------------------------------------------- ;
; player starts with a pole move in case of a short ladder which starts directly on a floor
; because ladder top and pole do not differ in screen control data ($10)
; so check tile directly below for a ladder - set CCW_CtrlScrnValBelow here for the later check
; ------------------------------------------------------------------------------------------------------------- ;
                    ldy #$28 * $02                  ; .hbu005. - two control bytes for each screen position
                    lda (CCZ_CtrlScreen),y          ; .hbu005.
                    sta CCW_CtrlScrnValBelow        ; .hbu005.
                    
                    ldy #$00
                    lda (CCZ_CtrlScreen),y
                    and CC_WaS_StoreToCtrlVal,x
                    sta CCW_CtrlScrnVal
                    
                    lda #$ff
                    sta CC_WaS_StoreToCtrlVal,x
                    
                    lda CCW_CtrlScrnColB0_2         ; Bit 0-2 of CCW_CtrlScrnRowNo
                    beq .ChkColInCtrlLo2
                    
                    lda CCW_CtrlScrnVal
                    and #$11
                    bne .ResetJoyFire               ; .hbu019.
                    
                    lda CCW_CtrlScrnVal
                    and #$bb
                    sta CCW_CtrlScrnVal
                    
                    lda CCW_CtrlScrnColB0_2         ; Bit 0-2 of CCW_CtrlScrnRowNo
                    lsr a
                    cmp CCW_CtrlScrnColB0_1
                    beq .SetCtrlScrnVal
                    
                    lda CCW_CtrlScrnVal
                    and #$77
                    sta CCW_CtrlScrnVal
                    jmp .ResetJoyFire               ; .hbu019.
                    
.SetCtrlScrnVal     lda CCW_CtrlScrnVal
                    and #$dd
                    sta CCW_CtrlScrnVal
                    jmp .ResetJoyFire               ; .hbu019.
                    
.ChkColInCtrlLo2    lda CCW_CtrlScrnColB0_1         ; Bit 0-1 of CCW_CtrlScrnColNo
                    cmp #$03                        ; max
                    bne .ChkP_ColMin
                    
                    sec
                    lda CCZ_CtrlScreenLo
                    sbc #$4e
                    sta CCZ_CtrlScreenLo
                    bcs .Mask75
                    dec CCZ_CtrlScreenHi
                    
.Mask75             ldy #$00
                    lda CCW_CtrlScrnVal
                    and #$75                        ; .### .#.#
                    sta CCW_CtrlScrnVal
                    
                    lda (CCZ_CtrlScreen),y
                    and #$02
                    ora CCW_CtrlScrnVal
                    sta CCW_CtrlScrnVal
                    jmp .ResetJoyFire               ; .hbu019.
                    
.ChkP_ColMin        cmp #$00
                    bne .Mask55
                    
                    sec
                    lda CCZ_CtrlScreenLo
                    sbc #$52
                    sta CCZ_CtrlScreenLo
                    bcs .Mask5d
                    dec CCZ_CtrlScreenHi
                    
.Mask5d             ldy #$00
                    lda CCW_CtrlScrnVal
                    and #$5d                        ; .#.###.#
                    sta CCW_CtrlScrnVal
                    
                    lda (CCZ_CtrlScreen),y
                    and #$80                        ; #.......
                    ora CCW_CtrlScrnVal
                    sta CCW_CtrlScrnVal
                    jmp .ResetJoyFire               ; .hbu019.
                    
.Mask55             lda CCW_CtrlScrnVal
                    and #$55                        ; .#.# .#.#
                    sta CCW_CtrlScrnVal
                    
.ResetJoyFire       lda #$00                        ; .hbu019. - get fire butten only on release ...
                    sta CCW_JoyGotFire              ; .hbu019.
                    
.SetPlayerPort      lda CC_WaS_PlayerSpriteNo,x     ; joystick port
                    jsr GetKeyJoyVal
                    
                    lda CCW_JoyGotFire              ; 
                    sta CC_WaS_SpriteMoveDir,x      ; 
                    
                    lda CCW_JoySavFire              ; .hbu019.
                    sta CC_WaS_PlayerFire,x         ; .hbu019. - ... but special treatment to fire the ray gun permanently
                    
                    lda CCW_JoyGotDir
                    sta CC_WaS_PlayerMoveDir,x
                    tay
                    bmi .BadSprtDirMove             ; CC_WaS_JoyNoMove
                    
                    lda TabSelectABit,y
                    bit CCW_CtrlScrnVal
                    beq .ChkSprtDirMove
                    
                    tya
                    sta CC_WaS_Work,x
                    jmp .ChkMoveR
                    
.ChkSprtDirMove     lda CC_WaS_Work,x
                    bmi .BadSprtDirMove
                    
                    clc
                    adc #$01
                    and #$07                        ; .....###
                    cmp CCW_JoyGotDir
                    beq .ChkP_ScrnObj
                    
                    sec
                    sbc #$02
                    and #$07                        ; .....###
                    cmp CCW_JoyGotDir
                    bne .BadSprtDirMove
                    
.ChkP_ScrnObj       ldy CC_WaS_Work,x
                    lda TabSelectABit,y
                    bit CCW_CtrlScrnVal
                    bne .ChkMoveR
                    
.BadSprtDirMove     lda #$80
                    sta CC_WaS_Work,x
                    jmp MovePlayerSpriteX
                    
.ChkMoveR           lda CC_WaS_Work,x
                    and #$03                        ; ......##
                    cmp #$02
                    bne .ChkMoveU
                    
                    sec
                    lda CC_WaS_SpritePosY,x
                    sbc CCW_CtrlScrnColB0_2         ; Bit 0-2 of CCW_CtrlScrnRowNo
                    sta CC_WaS_SpritePosY,x
                    jmp .MovePlayer
                    
.ChkMoveU           cmp #$00
                    bne .MovePlayer
                    
                    sec                             ; center on ladder/pole
                    lda CC_WaS_SpritePosX,x
                    sbc CCW_CtrlScrnColB0_1          ; Bit 0-1 of CCW_CtrlScrnColNo
                    sta CC_WaS_SpritePosX,x
                    inc CC_WaS_SpritePosX,x
                    
.MovePlayer         ldy CC_WaS_Work,x
                    clc
                    lda CC_WaS_SpritePosX,x
                    adc TabMoveAddColOff,y
                    sta CC_WaS_SpritePosX,x
                    clc
                    lda CC_WaS_SpritePosY,x
                    adc TabMoveAddRowOff,y
                    sta CC_WaS_SpritePosY,x
                    
                    tya
                    and #$03
                    bne .IncSprtImgNoLR
                    
                    lda CCW_CtrlScrnValBelow        ; .hbu005.
                    and #CC_CtrlLadderBot           ; .hbu005. - set for ladders only - not for poles and ground
                    beq .SetPole                    ; .hbu005. - pole follows
                    
.GetSprtWork        lda CC_WaS_Work,x
                    bne .DecSprtImgNoUD
                    
.IncSprtImgNoUD     inc CC_WaS_SpriteNo,x           ; up/down moves
                    jmp .GetSprtImgNo
                    
.DecSprtImgNoUD     dec CC_WaS_SpriteNo,x
                    
.GetSprtImgNo       lda CC_WaS_SpriteNo,x
                    
.ChkLadderMin       cmp #NoSprPlrMovLaMin           ; sprite: Player: Ladder u/d Phase 01
                    bcs .ChkLadderMax
                    
.SetLadderMax       lda #NoSprPlrMovLa04            ; sprite: Player - Ladder u/d Phase 04
                    sta CC_WaS_SpriteNo,x
                    jmp .GetNewSprtData
                    
.ChkLadderMax       cmp #NoSprPlrMovLaMax           ; sprite: Player - Ladder u/d Phase 04 + 1
                    bcc .GetNewSprtData             ; not reached
                    
.SetLadderMin       lda #NoSprPlrMovLaMin           ; sprite: Player - Ladder u/d Phase 01
                    sta CC_WaS_SpriteNo,x
                    jmp .GetNewSprtData
                    
.SetPole            lda #NoSprPlrMovPole            ; sprite: Player - Pole Down
                    sta CC_WaS_SpriteNo,x
                    jmp .GetNewSprtData
                    
.IncSprtImgNoLR     inc CC_WaS_SpriteNo,x           ; left/right moves
                    lda CC_WaS_Work,x
                    cmp #NoSprPlrMovLe02            ; sprite: Player - Move Left  Phase 02
                    bcs .ChkRightMax
                    
.ChkLeftMax         lda CC_WaS_SpriteNo,x
                    cmp #NoSprPlrMovLeMax           ; sprite: Player - Move Left  Phase 03 + 1
                    bcs .SetLeftMin
                    
                    cmp #NoSprPlrMovRiMax           ; sprite: Player - Move Right Phase 03 + 1
                    bcs .GetNewSprtData
                    
.SetLeftMin         lda #NoSprPlrMovLeMin           ; sprite: Player - Move Left  Phase 01
                    sta CC_WaS_SpriteNo,x
                    jmp .GetNewSprtData
                    
.ChkRightMax        lda CC_WaS_SpriteNo,x
                    cmp #NoSprPlrMovRiMax           ; sprite: Player - Move Right Phase 03 + 1
                    bcc .GetNewSprtData
                    
                    lda #NoSprPlrMovRiMin           ; sprite: Player - Move Right Phase 01
                    sta CC_WaS_SpriteNo,x
                    
.GetNewSprtData     jsr GetSpriteData
                    
MovePlayerSpriteX   jmp SpriteHandlerRetMov
; ------------------------------------------------------------------------------------------------------------- ;
; MoveSparkSprite   Function: 
;                   Parms   : xr=Sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
MoveSparkSprite     subroutine
                    lda CC_WaS_SpriteFlag,x         ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    bit Bit_ooo1_oooo               ;            $10=action   $20=death          $40=dead           $80=init
                    beq .ChkInit
                    
                    eor #CC_WaS_FlagAction          ; 
                    ora #CC_WaS_Flag08              ; 
                    sta CC_WaS_SpriteFlag,x
                    jmp MoveSparkSpriteX
                    
.ChkInit            bit Bit_1ooo_oooo
                    beq .Rnd
                    
                    eor #CC_WaS_FlagInit            ; reset init
                    sta CC_WaS_SpriteFlag,x
                    
.Rnd                jsr Randomizer
                    
                    and #$03
                    sta CC_WaS_SpriteSeqNo,x
                    inc CC_WaS_SpriteSeqNo,x
                    
                    jsr Randomizer
                    
                    and #$03
                    clc
                    adc #NoSprSpaMovMin             ; sprite: Lightning Machine Spark - Phase 01
                    cmp CC_WaS_SpriteNo,x
                    bne .SetSpriteNo
                    
                    clc
                    adc #$01
                    cmp #NoSprSpaMovMax             ; sprite: Lightning Machine Spark - Phase 04
                    bcc .SetSpriteNo
                    
                    lda #NoSprSpaMovMin             ; sprite: Lightning Machine Spark - Phase 01
.SetSpriteNo        sta CC_WaS_SpriteNo,x
                    
                    jsr CopySpriteData              ; set shape / expand and copy sprite data of a given number to its memory location
                    
MoveSparkSpriteX    jmp SpriteHandlerRetMov
; ------------------------------------------------------------------------------------------------------------- ;
; MoveForceSprite   Function: 
;                   Parms   : xr=Sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
MoveForceSprite     subroutine
                    lda CC_WaS_SpriteFlag,x         ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    bit Bit_ooo1_oooo               ;            $10=action   $20=death          $40=dead           $80=init
                    beq .Chk80
                    
                    eor #CC_WaS_FlagAction
                    ora #CC_WaS_Flag08
                    sta CC_WaS_SpriteFlag,x
                    jmp MoveForceSpriteX
                    
.Chk80              bit CC_WaS_FlagInit
                    beq .ChkFieldStatus
                    
                    eor #CC_WaS_FlagInit
                    sta CC_WaS_SpriteFlag,x
                    
.ChkFieldStatus     ldy CC_WaS_Work,x
                    lda CCW_ForceStatusTab,y
                    cmp #CCW_ForceClosed
                    bne .FieldOpen
                    
.FieldClose         lda CC_WaS_ForceFieldMode,x
                    cmp #CC_WaS_ForceOpen
                    beq .ChkForceField
                    
                    lda #CC_WaS_ForceOpen
                    sta CC_WaS_ForceFieldMode,x
                    
                    jsr SetCtrlSprtPtr              ; set move control screen pointer for sprites
                    
                    sec
                    lda CCZ_CtrlScreenLo
                    sbc #$02
                    sta CCZ_CtrlScreenLo
                    bcs .MarkFieldOpen
                    dec CCZ_CtrlScreenHi
                    
.MarkFieldOpen      ldy #$00
                    lda (CCZ_CtrlScreen),y
                    and #CC_CtrlForceLeft           ; reset floor to CC_CtrlFloorEnd if closed - no move
                    sta (CCZ_CtrlScreen),y
                    
                    ldy #$04
                    lda (CCZ_CtrlScreen),y
                    and #CC_CtrlForceRight          ; reset floor to CC_CtrlFloorStrt if closed - no move
                    sta (CCZ_CtrlScreen),y
                    jmp .GetThin
                    
.ChkForceField      lda CC_WaS_SpriteNo,x
                    cmp #NoSprForMov01              ; sprite: Force Field - Phase 01 (thin)
                    bne .GetThin
                    
.GetThick           lda #NoSprForMov02              ; sprite: Force Field - Phase 02 (thick)
                    jmp .SetImage
                    
.GetThin            lda #NoSprForMov01              ; sprite: Force Field - Phase 01 (thin)
                    jmp .SetImage
                    
.FieldOpen          lda CC_WaS_ForceFieldMode,x
                    cmp #CC_WaS_ForceOpen
                    bne MoveForceSpriteX
                    
                    lda #CC_WaS_ForceClose
                    sta CC_WaS_ForceFieldMode,x
                    
                    jsr SetCtrlSprtPtr              ; set move control screen pointer for sprites
                    
                    sec
                    lda CCZ_CtrlScreenLo
                    sbc #$02
                    sta CCZ_CtrlScreenLo
                    bcs .MarkFieldClose
                    dec CCZ_CtrlScreenHi
                    
.MarkFieldClose     ldy #$00
                    lda (CCZ_CtrlScreen),y
                    ora #CC_CtrlFloorStrt           ; set floor to CC_CtrlFloorEnd
                    sta (CCZ_CtrlScreen),y
                    
                    ldy #$04
                    lda (CCZ_CtrlScreen),y
                    ora #CC_CtrlFloorEnd            ; set floor to CC_CtrlFloorStrt
                    sta (CCZ_CtrlScreen),y
                    
.GetOpen            lda #NoSprForMov03              ; sprite: Force Field - Phase 03 (open)
.SetImage           sta CC_WaS_SpriteNo,x
                    
                    jsr CopySpriteData              ; set shape / expand and copy sprite data of a given number to its memory location
                    
MoveForceSpriteX    jmp SpriteHandlerRetMov
; ------------------------------------------------------------------------------------------------------------- ;
; MoveMummySprite   Function: Move Mummy out of  wall / Move Mummy around
;                   Parms   : xr=Sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
MoveMummySprite     subroutine
                    lda CC_WaS_SpriteFlag,x         ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    bit Bit_ooo1_oooo               ;            $10=action   $20=death          $40=dead           $80=init
                    beq .Chk80
                    
                    eor #CC_WaS_FlagAction
                    ora #CC_WaS_Flag08
                    sta CC_WaS_SpriteFlag,x
                    jmp MoveMummySpriteX
                    
.Chk80              bit Bit_1ooo_oooo
                    beq .ChkSprtPlayerNo
                    
                    eor #CC_WaS_FlagInit
                    sta CC_WaS_SpriteFlag,x
                    
                    lda CC_WaS_EnemyStatus,x
                    beq .ChkSprtPlayerNo            ; CC_WaS_MummyIn
                    
                    lda #NoSprMumMovLeMin           ; sprite: Mummy - Move Left   Pase 01
                    sta CC_WaS_SpriteNo,x
                    
                    jsr CopySpriteData              ; set shape / expand and copy sprite data of a given number to its memory location
                    
.ChkSprtPlayerNo    lda CC_WaS_PlayerSpriteNo,x
                    cmp #$ff
                    beq .SetRoomIOB
                    
                    cmp CC_WaS_PlayerRoomIOB,x      ; offset TabPlayerRoomIO block
                    beq .SetRoomIOB
                    
                    jsr TrapDoorHandler
                    
.SetRoomIOB         sta CC_WaS_PlayerRoomIOB,x      ; offset TabPlayerRoomIO block
                    lda #$ff
                    sta CC_WaS_PlayerSpriteNo,x
                    
                    clc
                    lda CCW_MummyDataPtrLo
                    adc CC_WaS_SpriteMoveDir,x
                    sta CCZ_RoomItemModLo
                    lda CCW_MummyDataPtrHi
                    adc #$00
                    sta CCZ_RoomItemModHi
                    
                    lda CC_WaS_EnemyStatus,x
                    bne .ChkP_Alive
                    
                    inc CC_WaS_Work,x
                    ldy CC_WaS_Work,x
                    lda TabMummyOutSpriteNo,y
                    cmp #$ff
                    beq .SetMummyOut
                    
                    sta CC_WaS_SpriteNo,x
                    clc
                    lda CC_WaS_SpritePosX,x
                    adc TabMummyOutColOff,y
                    sta CC_WaS_SpritePosX,x
                    clc
                    lda CC_WaS_SpritePosY,x
                    adc TabMummyOutRowOff,y
                    sta CC_WaS_SpritePosY,x
                    
                    lda CC_WaS_Work,x
                    asl a                           ; *2
                    asl a                           ; *4
                    adc #SFX_MummyOutHeight         ; 
                    sta SFX_MummyOutTone            ; vary tone
                    
                    lda #NoSndMummyOut              ; sound: Mummy Out
                    jsr InitSoundFx
                    
                    jmp .SetMovSprite
                    
.SetMummyOut        lda #CC_WaS_MummyOut
                    sta CC_WaS_EnemyStatus,x
                    
                    clc
                    ldy #CC_Obj_MummyWallGridCol
                    lda (CCZ_RoomMummyMod),y        ; 
                    adc #$04
                    sta CC_WaS_SpritePosX,x
                    clc
                    ldy #CC_Obj_MummyWallGridRow
                    lda (CCZ_RoomMummyMod),y        ; 
                    adc #$07
                    sta CC_WaS_SpritePosY,x
                    
                    lda #$02
                    sta CC_WaS_SpriteSeqNo,x
                    
.ChkP_Alive         lda CCL_Player1Status
                    cmp #CCL_PlayerSurvive
                    beq .SetP1
                    
                    lda CCL_Player2Status
                    cmp #CCL_PlayerSurvive
                    beq .SetP2
                    
                    jmp MoveMummySpriteX
                    
.SetP1              ldy #$00
                    jmp .GetP_WA
                    
.SetP2              ldy #$01
.GetP_WA            lda CCW_SpriteWAOffP1,y
                    tay
                    
                    jsr SetCtrlSprtPtr              ; set move control screen pointer for sprites
                    
                    sec
                    lda CC_WaS_SpritePosX,x         ; mummy
                    sbc CC_WaS_SpritePosX,y         ; player
                    bcs .ChkPlayerCol               ; lower/equal - Mummy on Players left side
                    
                    eor #$ff
                    adc #$01                        ; make positve                  
                    cmp #$03                        ; .hbu006.
.ChkPlayerCol       bcc .MummyStayPl                ; .hbu006. - Mummy on Players column
                    
.SetNextImgNo       inc CC_WaS_SpriteNo,x
                    
                    lda CC_WaS_SpritePosX,x         ; mummy
                    cmp CC_WaS_SpritePosX,y         ; player
                    bcs .ChkTouchMummyLe            ; higher/equal     - mummy on players right side - will move left
                    
.ChkTouchMummyRi    lda CC_WaS_MummyCollRight,x     ; .hbu004. - lower - mummy on players left  side - will move right
                    bne .MummyStayRi                ; .hbu004. - blocked with mummy-mummy collision to the right
                    
.ChkFloorStart      ldy #00
                    lda (CCZ_CtrlScreen),y
                    and #CC_CtrlFloorStrt
                    beq .MummyStayRi                ; .hbu006.
                    
                    inc CC_WaS_SpritePosX,x
                    
                    lda CC_WaS_SpriteNo,x
                    cmp #NoSprMumMovRiMin           ; sprite: Mummy - Move Right  Pase 01
                    bcc .SetStartRi                 ; .hbu006.
                    
                    cmp #NoSprMumMovRiMax           ; sprite: Mummy - Move Right  Pase 03 + 1
                    bcc .SavMummyPos
                    
.SetStartRi         lda #NoSprMumMovRiMin           ; sprite: Mummy - Move Right  Pase 01
                    sta CC_WaS_SpriteNo,x
                    jmp .SavMummyPos
                    
.ChkTouchMummyLe    lda CC_WaS_MummyCollLeft,x      ; .hbu004. - mummy on players right side - will move left
                    bne .MummyStayLe                ; .hbu004. - blocked with mummy-mummy collision to the left
                    
.ChkFloorEnd        ldy #00
                    lda (CCZ_CtrlScreen),y
                    and #CC_CtrlFloorEnd
                    beq .MummyStayLe                ; .hbu006.
                    
                    dec CC_WaS_SpritePosX,x
                    
                    lda CC_WaS_SpriteNo,x
                    cmp #NoSprMumMovLeMin           ; sprite: Mummy - Move Left   Pase 01
                    bcc .SetStartLe
                    
                    cmp #NoSprMumMovLeMax           ; sprite: Mummy - Move Right  Pase 03
                    bcc .SavMummyPos
                    
.SetStartLe         lda #NoSprMumMovLeMin           ; sprite: Mummy - Move Left   Pase 01
                    sta CC_WaS_SpriteNo,x
                    
.SavMummyPos        ldy #CC_Obj_MummySpriteCol      ; 
                    lda CC_WaS_SpritePosX,x
                    sta (CCZ_RoomMummyMod),y        ; 
                    ldy #CC_Obj_MummySpriteRow      ; 
                    lda CC_WaS_SpritePosY,x         ; 
                    sta (CCZ_RoomMummyMod),y        ; 
.SetMovSprite       jsr CopySpriteData              ; set shape / expand and copy sprite data of a given number to its memory location
                    
                    jmp MoveMummySpriteX            ; .hbu006.
                    
.MummyStayPl        lda CC_WaS_SpriteNo,x           ; .hbu006. - active wait on players standstill
                    inc CC_WaS_SpriteNo,x           ; .hbu006. - next mummy sprite
.ChkStayRi          cmp #NoSprMumMovRiMin           ; .hbu006. - 
                    bcc .MummyStayLe                ; .hbu006. - 
                    
                    cmp #NoSprMumMovRiMax           ; .hbu006.
                    bcc .MummyStayRi                ; .hbu006.
                    
.MummyStayLe        lda CC_WaS_SpriteNo,x           ; .hbu006. - active waits on left floor end
.StayLeChk          cmp #NoSprMumMovLeMax           ; .hbu006.
                    bcc .StayLeSav                  ; .hbu006.
                    
                    lda #NoSprMumMovLeMin           ; .hbu006.
.StayLeSav          tay                             ; .hbu006. - save move image no
                    sec                             ; .hbu006.
                    sbc #NoSprMumMovLeMin           ; .hbu006. - $00-$02
.StayLeAdd          clc                             ; .hbu006.
                    adc #NoSprMumStaLeMin           ; .hbu006. - add to new stay sprites
.StayLeSet          sta CC_WaS_SpriteNo,x           ; .hbu006. - set stay sprites
                    
                    jmp .SetStaySprite              ; .hbu006.
                    
.MummyStayRi        lda CC_WaS_SpriteNo,x           ; .hbu006. - active waits on right floor end
.StayRiChk          cmp #NoSprMumMovRiMax           ; .hbu006.
                    bcc .StayRiSav                  ; .hbu006.
                    
                    lda #NoSprMumMovRiMin           ; .hbu006.
.StayRiSav          tay                             ; .hbu006. - save move image no
                    sec                             ; .hbu006.
                    sbc #NoSprMumMovRiMin           ; .hbu006. - $00-$02
.StayRiAdd          clc                             ; .hbu006.
                    adc #NoSprMumStaRiMin           ; .hbu006. - add to new stay sprites
.StayRiSet          sta CC_WaS_SpriteNo,x           ; .hbu006. - set stay sprites
                    
.SetStaySprite      jsr CopySpriteData              ; .hbu006.
                    
                    tya                             ; .hbu006. - restore move images
                    sta CC_WaS_SpriteNo,x           ; .hbu006.
                    
MoveMummySpriteX    jmp SpriteHandlerRetMov
; ------------------------------------------------------------------------------------------------------------- ;
; MoveBeamSprite    Function: 
;                   Parms   : xr=Sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
MoveBeamSprite      subroutine
                    lda CC_WaS_SpriteFlag,x         ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    bit Bit_ooo1_oooo               ;            $10=action   $20=death          $40=dead           $80=init
                    beq .Chk80
                    
                    eor #CC_WaS_FlagAction
                    ora #CC_WaS_Flag08
                    sta CC_WaS_SpriteFlag,x
                    
                    lda CC_WaS_BeamWaOff,x
                    
                    clc
                    adc CCW_GunDataPtrLo
                    sta CCZ_RoomItemModLo
                    lda CCW_GunDataPtrHi
                    adc #$00
                    sta CCZ_RoomItemModHi
                    
                    ldy #$00
                    lda #$ff
                    eor #CC_WaS_FlagDead
                    and (CCZ_RoomGunMod),y
                    sta (CCZ_RoomItemModLo),y
                    jmp MoveBeamSpriteX
                    
.Chk80              bit Bit_1ooo_oooo
                    beq .Move
                    
                    eor #CC_WaS_FlagInit            ;            $10=action   $20=death          $40=dead           $80=init
                    sta CC_WaS_SpriteFlag,x         ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    
.Move               clc
                    lda CC_WaS_SpritePosX,x
                    adc CC_WaS_Work,x
                    sta CC_WaS_SpritePosX,x
                    cmp #$b0
                    bcs .SetFlag10
                    
                    cmp #$08
                    bcs MoveBeamSpriteX
                    
.SetFlag10          lda CC_WaS_SpriteFlag,x         ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    ora #CC_WaS_FlagAction          ;            $10=action   $20=death          $40=dead           $80=init
                    sta CC_WaS_SpriteFlag,x
                    
MoveBeamSpriteX     jmp SpriteHandlerRetMov
; ------------------------------------------------------------------------------------------------------------- ;
; MoveFrankSprite   Function: 
;                   Parms   : xr=Sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
MoveFrankSprite     subroutine
                    lda CC_WaS_SpriteFlag,x         ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    bit Bit_ooo1_oooo               ;            $10=action   $20=death          $40=dead           $80=init
                    beq .Chk80
                    
                    eor #CC_WaS_FlagAction
                    ora #CC_WaS_Flag08
                    sta CC_WaS_SpriteFlag,x
                    jmp MoveFrankSpriteX
                    
.Chk80              bit Bit_1ooo_oooo
                    beq .SetFrankDatPtr
                    
                    eor #CC_WaS_FlagInit
                    sta CC_WaS_SpriteFlag,x
                    
.SetFrankDatPtr     clc
                    lda CCW_FrankDataPtrLo
                    adc CC_WaS_Work,x               ; offset actual Frank data
                    sta CCZ_RoomItemModLo
                    lda CCW_FrankDataPtrHi
                    adc #$00
                    sta CCZ_RoomItemModHi
                    
                    lda CC_WaS_EnemyStatus,x        ; stores CC_Obj_FrankCoffinDir
                    and #CC_WaS_FrankAwake          ; CC_Obj_FrankAwake
                    bne .ChkRoomIO                  ; Frank has left his coffin
                    
                    lda CCW_DemoFlag                ; 
                    cmp #CCW_DemoYes                ; 
                    bne .ChkFrankToAwake
                    
                    jmp MoveFrankSpriteX            ; stay in coffin in demo mode
                    
.ChkFrankToAwake    lda #$01
                    sta CCW_MoveFrankP_No
.NextPlayer01       ldy CCW_MoveFrankP_No
                    lda CCL_PlayersStatus,y
                    cmp #CCL_PlayerSurvive          ; player still alive
                    bne .SetNextPlayer01            ; no
                    
                    lda CCW_SpriteWAOffP1,y
                    tay
                    sec
                    lda CC_WaS_SpritePosY,x         ; Frank
                    sbc CC_WaS_SpritePosY,y         ; Player
                    cmp #$04
                    bcs .SetNextPlayer01            ; wrong row
                    
                    sec
                    lda CC_WaS_SpritePosX,x         ; Frank
                    sbc CC_WaS_SpritePosX,y         ; Player
                    bcc .ChkFrankOutLe              ; left side
                    
.ChkFrankOutRi      lda CC_WaS_EnemyStatus,x        ; right side
                    bit Bit_oooo_ooo1               ; CC_Obj_FrankCoffinLeft
                    beq .SetNextPlayer01
                    
                    jmp .MarkFrankOut
                    
.ChkFrankOutLe      lda CC_WaS_EnemyStatus,x
                    bit Bit_oooo_ooo1               ; CC_Obj_FrankCoffinLeft
                    beq .MarkFrankOut
                    
.SetNextPlayer01    dec CCW_MoveFrankP_No
                    bpl .NextPlayer01
                    
                    jmp MoveFrankSpriteX
                    
.MarkFrankOut       ora #CC_WaS_FrankAwake           ; 
                    sta CC_WaS_EnemyStatus,x
                    
                    ldy #CC_Obj_FrankCoffinDir
                    sta (CCZ_RoomFrankMod),y
                    
                    lda #$80
                    sta CC_WaS_SpriteMoveDir,x
                    
                    lda #NoSndFrankOut              ; sound: Frank Out
                    jsr InitSoundFx
                    
.ChkRoomIO          lda CC_WaS_PlayerRoomIOB,x      ; 
                    cmp #$ff                        ; object handled already
                    beq .PutIOB                     ; yes
                    
                    cmp CC_WaS_SpriteObj,x          ; object to handle
                    beq .PutIOB                     ; no
                    
                    jsr TrapDoorHandler             ; Trap Door Switch touched
                    
.PutIOB             sta CC_WaS_SpriteObj,x
                    lda #$ff
                    sta CC_WaS_PlayerRoomIOB,x      ; set object handled
                    
                    jsr SetCtrlSprtPtr              ; set move control screen pointer for sprites
                    
                    ldy #$00
                    lda (CCZ_CtrlScreen),y
                    and CC_WaS_PlayerSpriteNo,x
                    sta CCW_MovFrankCtrlVal
                    
                    lda #$ff
                    sta CC_WaS_PlayerSpriteNo,x
                    
                    lda CCW_MovFrankCtrlVal
                    bne .ChkScrnValI
                    
                    lda #$80
                    sta CC_WaS_SpriteMoveDir,x
                    jmp .ChkJoyDir
                    
.ChkScrnValI        ldy #$06
                    lda #$00
                    sta CCW_MovFrankMoveOk
.ChkScrnVal         lda TabSelectABit,y
                    bit CCW_MovFrankCtrlVal         ; $01 $04 $10 $40 - control screen types (ladder ground pole ground)
                    beq .ChkScrnValNext
                    
                    inc CCW_MovFrankMoveOk          ; frank can move
                    sty CCW_MovFrankDir             ; $00=up $02=right $04=down $06=left $80=
                    
.ChkScrnValNext     dey
                    dey
                    bpl .ChkScrnVal
                    
                    lda CCW_MovFrankMoveOk
.ChkValFound01      cmp #CCW_MovFrankMoveYes
                    bne .ChkValFound02
                    
                    lda CCW_MovFrankDir
                    sta CC_WaS_SpriteMoveDir,x      ; $00=up $02=right $04=down $06=left $80=
                    jmp .ChkJoyDir
                    
.ChkValFound02      cmp #$02
                    bne .MoveTabInitI               ; found03 - Ladder/Pole crosses
                    
                    lda CCW_MovFrankDir
                    sec
                    sbc #$04                        ; $fc $fe $00 $02
                    and #$07                        ; $04 $06 $00 $02
                    tay
                    lda TabSelectABit,y             ; $10 $40 $01 $04
                    bit CCW_MovFrankCtrlVal
                    beq .MoveTabInitI
                    
                    ldy CC_WaS_SpriteMoveDir,x      ; $00=up $02=right $04=down $06=left $80=
                    bmi .MoveTabInitI
                    
                    lda TabSelectABit,y
                    bit CCW_MovFrankCtrlVal
                    beq .MoveTabInitI
                    
                    jmp .ChkJoyDir                  ; no direction checks for pole bottom
                    
.MoveTabInitI       lda #$ff
                    ldy #$03
.MoveTabInit        sta CCW_MovFrankP_PosTab,y
                    dey
                    bpl .MoveTabInit
                    
.NextPlayer02I      lda #$01
                    sta CCW_MoveFrankP_No
.NextPlayer02       ldy CCW_MoveFrankP_No
                    lda CCL_PlayersStatus,y
                    cmp #CCL_PlayerSurvive
                    bne .SetNextPlayer02
                    
.ChkPosX            lda CCW_SpriteWAOffP1,y
                    tay
                    sec
                    lda CC_WaS_SpritePosX,y         ; Player
                    sbc CC_WaS_SpritePosX,x         ; Frank
                    bcs .SelTabPos01                ; larger/equal  - Frank on Players left side
                    
                    eor #$ff
                    adc #$01                        ; make positive - Frank on Players right side
.SelTabPos03        ldy #$03
                    jmp .ChkTabPosX
                    
.SelTabPos01        ldy #$01
.ChkTabPosX         cmp CCW_MovFrankP_PosTab,y
                    bcs .ChkPosY
                    
.SetTabPosX         sta CCW_MovFrankP_PosTab,y      ; $01 or $03 - Frank on left or right
                    
.ChkPosY            ldy CCW_MoveFrankP_No
                    lda CCW_SpriteWAOffP1,y
                    tay
                    sec
                    lda CC_WaS_SpritePosY,y         ; Player
                    sbc CC_WaS_SpritePosY,x         ; Frank
                    bcs .SelTabPos02                ; larger/equal  - Frank above Player
                    
                    eor #$ff
                    adc #$01                        ; make positive - Frank below Player
.SelTabPos00        ldy #$00
                    jmp .ChkTabPosY
                    
.SelTabPos02        ldy #$02
.ChkTabPosY         cmp CCW_MovFrankP_PosTab,y
                    bcs .SetNextPlayer02
                    
.SetTabPosY         sta CCW_MovFrankP_PosTab,y      ; $00 or $02 - above or below
                    
.SetNextPlayer02    dec CCW_MoveFrankP_No
                    bpl .NextPlayer02
                    
                    lda #$ff
                    sta CCW_MovFrankP_Pos
.LoopP_PosXYI       lda #$00
                    sta CCW_MovFrankP_PosSav
                    lda #$ff
                    sta CCW_MovFrankP_PosPtr
                    
                    ldy #$03
.LoopP_PosXY        lda CCW_MovFrankP_PosTab,y
                    cmp CCW_MovFrankP_Pos
                    bcs .NextP_PosXY                ; new value lower than saved value
                    
                    cmp CCW_MovFrankP_PosSav
                    bcc .NextP_PosXY                ; new value higher than actual value
                    
                    sta CCW_MovFrankP_PosSav        ; save actual value
                    sty CCW_MovFrankP_PosPtr        ; save actual pointer
                    
.NextP_PosXY        dey
                    bpl .LoopP_PosXY
                    
                    lda CCW_MovFrankP_PosPtr
                    cmp #$ff                        ; nothing found
                    bne .ChkCScrnVal
                    
                    lda #$80
                    sta CC_WaS_SpriteMoveDir,x      ; $00=up $02=right $04=down $06=left $80=
                    jmp .ChkJoyDir
                    
.ChkCScrnVal        asl a                           ; CCW_MovFrankP_PosPtr *2 - $00=up $02=right $04=down $06=left
                    tay
                    lda TabSelectABit,y
                    bit CCW_MovFrankCtrlVal
                    bne .SetJoyDir
                    
                    lda CCW_MovFrankP_PosSav
                    sta CCW_MovFrankP_Pos
                    jmp .LoopP_PosXYI
                    
.SetJoyDir          tya                             ; $00=up $02=right $04=down $06=left
                    sta CC_WaS_SpriteMoveDir,x
                    
.ChkJoyDir          lda CC_WaS_SpriteMoveDir,x      ; $00=up $02=right $04=down $06=left $80=
                    and #$02
                    beq .ChkJoyUpDo
                    
.JoyLeRi            sec
                    lda CC_WaS_SpritePosY,x
                    sbc CCW_CtrlScrnColB0_2         ; Bit 0-2 of CCW_CtrlScrnRowNo
                    sta CC_WaS_SpritePosY,x
                    
                    inc CC_WaS_SpriteNo,x
                    
                    lda CC_WaS_SpriteMoveDir,x      ; $00=up $02=right $04=down $06=left $80=
                    cmp #$02
                    beq .MoveRight
                    
.MoveLeft           dec CC_WaS_SpritePosX,x
                    
                    lda CC_WaS_SpriteNo,x
                    cmp #NoSprFraMovLeMin           ; sprite: Frank - Move Left  Pase 01
                    bcc .GetMoveLeftImgMin          ; 
                    
                    cmp #NoSprFraMovLeMax           ; sprite: Frank - Move Left  Pase 03 + 1
                    bcc .GoSetLeftImgMin            ; 
                    
.GetMoveLeftImgMin  lda #NoSprFraMovLeMin           ; sprite: Frank - Move Left  Pase 01
                    sta CC_WaS_SpriteNo,x
.GoSetLeftImgMin    jmp .SetSpriteData
                    
.MoveRight          inc CC_WaS_SpritePosX,x
                    
                    lda CC_WaS_SpriteNo,x
                    cmp #NoSprFraMovRiMin           ; sprite: Frank - Move Right Pase 01
                    bcc .GetMoveRightImgMin         ; 
                    
                    cmp #NoSprFraMovRiMax           ; sprite: Frank - Move Right Pase 03 + 1
                    bcc .GoSetRightImgMin           ; 
                    
.GetMoveRightImgMin lda #NoSprFraMovRiMin           ; sprite: Frank - Move Right Pase 01
                    sta CC_WaS_SpriteNo,x
.GoSetRightImgMin   jmp .SetSpriteData
                    
.ChkJoyUpDo         lda CC_WaS_SpriteMoveDir,x      ; $00=up $02=right $04=down $06=left $80=
                    bmi .UpdFrankGameDat
                    
.JoyUpDo            sec                             ; center on ladder/pole
                    lda CC_WaS_SpritePosX,x
                    sbc CCW_CtrlScrnColB0_1         ; Bit 0-1 of CCW_CtrlScrnColNo
                    sta CC_WaS_SpritePosX,x
                    inc CC_WaS_SpritePosX,x
                    
                    ldy #$00                        ; leave this check in otherwise he will move through the floor
                    lda (CCZ_CtrlScreen),y          ; 
                    and #CC_CtrlLadderBot           ; 
                    bne .ChkJoyUp                   ; 
                    
                    ldy #$28 * $02                  ; .hbu005. - two control bytes for each screen position
                    lda (CCZ_CtrlScreen),y          ; .hbu005. - check tile directly below - ladder top and pole do not differ ($10)
                    and #CC_CtrlLadderBot           ; .hbu005. - set for ladders only - not for poles and ground
                    bne .ChkJoyUp                   ; .hbu005. - was ladder
                    
.SetSprtPole        lda #NoSprFraMovPole            ; sprite: Frank - Pole Down
                    sta CC_WaS_SpriteNo,x
                    
.MovePoleDown       clc
                    lda CC_WaS_SpritePosY,x
                    adc #$02                        ; speed down
                    sta CC_WaS_SpritePosY,x
                    jmp .SetSpriteData
                    
.ChkJoyUp           lda CC_WaS_SpriteMoveDir,x      ; $00=up $02=right $04=down $06=left $80=
                    bne .MoveFrankDown
                    
.MoveFrankUp        sec
                    lda CC_WaS_SpritePosY,x
                    sbc #$02
                    sta CC_WaS_SpritePosY,x
                    jmp .SetSpriteNoUD
                    
.MoveFrankDown      clc
                    lda CC_WaS_SpritePosY,x
                    adc #$02
                    sta CC_WaS_SpritePosY,x

.SetSpriteNoUD      lda CC_WaS_SpritePosY,x
                    and #$06                        ; .... .##.
                    lsr a                           ; .... ..##
                    clc                             ; 
                    adc #NoSprFraMovLaMin           ; sprite: Frank - Ladder u/d Phase 01 - $8b
                    sta CC_WaS_SpriteNo,x           ; 
                    
.SetSpriteData      jsr CopySpriteData              ; set shape / expand and copy sprite data of a given number to its memory location
                    
.UpdFrankGameDat    lda CC_WaS_SpriteMoveDir,x      ; $00=up $02=right $04=down $06=left $80=
                    ldy #CC_Obj_FrankSpriteMoveDir
                    sta (CCZ_RoomFrankMod),y
                    
                    lda CC_WaS_SpritePosX,x
                    ldy #CC_Obj_FrankSpritePosX
                    sta (CCZ_RoomFrankMod),y
                    
                    lda CC_WaS_SpritePosY,x
                    ldy #CC_Obj_FrankSpritePosY
                    sta (CCZ_RoomFrankMod),y
                    
                    lda CC_WaS_SpriteNo,x
                    ldy #CC_Obj_FrankSpriteNo
                    sta (CCZ_RoomFrankMod),y
                    
MoveFrankSpriteX    jmp SpriteHandlerRetMov
; ------------------------------------------------------------------------------------------------------------- ;
; KillPlayerSprt    Function: - called from: ChkSprtSprtKill
;                   Parms   : xr=touched sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                           : yr=moved   sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
KillPlayerSprt      subroutine
                    lda CC_WaS_SpriteType,y         ; $00=Player $01=Spark $02=Force $03=Mummy $04=Beam $05=Frank
                    cmp #CC_WaS_SpriteForce
                    beq .SetDeath
                    
                    cmp #CC_WaS_SpritePlayer
                    bne .ChkAccident
                    
                    lda CC_WaS_SpriteNo,y           ; sprite number
                    cmp #NoSprPlrMovLaMin           ; sprite: Player - Ladder Up Phase 01
                    beq .ChkLadderUp
                    
                    cmp #NoSprPlrMovLa02            ; sprite: Player - Ladder Up Phase 02
                    beq .ChkLadderUp
                    
                    cmp #NoSprPlrMovLa03            ; sprite: Player - Ladder Up Phase 03
                    beq .ChkLadderUp
                    
                    cmp #NoSprPlrMovLa04            ; sprite: Player - Ladder Up Phase 04
                    beq .ChkLadderUp
                    
                    cmp #NoSprPlrMovPole            ; sprite: Player - Pole Down
                    bne .SetDeath
                    
.ChkLadderUp        lda CC_WaS_SpriteNo,x           ; sprite number
                    cmp #NoSprPlrMovLa01            ; sprite: Player - Ladder Up Phase 01
                    beq .ChkPosY
                    
                    cmp #NoSprPlrMovLa02            ; sprite: Player - Ladder Up Phase 02
                    beq .ChkPosY
                    
                    cmp #NoSprPlrMovLa03            ; sprite: Player - Ladder Up Phase 03
                    beq .ChkPosY
                    
                    cmp #NoSprPlrMovLa04            ; sprite: Player - Ladder Up Phase 04
                    beq .ChkPosY
                    
                    cmp #NoSprPlrMovPole            ; sprite: Player - Pole Down
                    bne .SetDeath
                    
.ChkPosY            lda CC_WaS_SpritePosY,y
                    cmp CC_WaS_SpritePosY,x
                    beq .SetDeath
                    
                    bcc .MarkFE
                    
.MarkEF             lda #$ef
                    sta CC_WaS_StoreToCtrlVal,x
                    jmp .SetDeath
                    
.MarkFE             lda #$fe
                    sta CC_WaS_StoreToCtrlVal,x
                    
.SetDeath           lda #CCW_SpriteDead
                    sta CCW_SpriteVitality
                    jmp KillPlayerSprtX
                    
.ChkAccident        ldy CC_WaS_PlayerSpriteNo,x
                    lda CCL_PlayersStatus,y
                    cmp #CCL_PlayerSurvive
                    bne .SetDeath
                    
                    lda #CCL_PlayerAccident
                    sta CCL_PlayersStatus,y
                    
KillPlayerSprtX     jmp RetSprtSprtKill
; ------------------------------------------------------------------------------------------------------------- ;
; KillSparkSprite   Function: - called from: ChkSprtSprtKill
;                   Parms   : xr=touched sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                           : yr=moved   sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
KillSparkSprite     subroutine
                    lda #CCW_SpriteDead
                    sta CCW_SpriteVitality
                    
KillSparkSpriteX    jmp RetSprtSprtKill
; ------------------------------------------------------------------------------------------------------------- ;
; KillForceSprite   Function: - called from: ChkSprtSprtKill
;                   Parms   : xr=touched sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                           : yr=moved   sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
KillForceSprite     subroutine
                    lda #CCW_SpriteDead
                    sta CCW_SpriteVitality
                    
KillForceSpriteX    jmp RetSprtSprtKill
; ------------------------------------------------------------------------------------------------------------- ;
; KillMummySprite   Function: - called from: ChkSprtSprtKill
;                   Parms   : xr=touched sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                           : yr=moved   sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
KillMummySprite     subroutine
                    lda CC_WaS_SpriteType,y         ; $00=Player $01=Spark $02=Force $03=Mummy $04=Beam $05=Frank
                    beq .SetDeath                   ; CC_WaS_SpritePlayer
                    
                    cmp #CC_WaS_SpriteFrank         ; 
                    bne .SetDataPtr                 ; 
                    
.SetDeath           lda #CCW_SpriteDead             ; 
                    sta CCW_SpriteVitality          ; 
                    jmp KillMummySpriteX            ; 
                    
.SetDataPtr         clc                             ; 
                    lda CCW_MummyDataPtrLo          ; 
                    adc CC_WaS_MummyDataOff,x       ; 
                    sta CCZ_RoomItemModLo           ; 
                    lda CCW_MummyDataPtrHi          ; 
                    adc #$00                        ; 
                    sta CCZ_RoomItemModHi           ; 
                    
                    ldy #CC_Obj_MummyStatus         ; 
                    lda #CC_Obj_MummyKilled         ; 
                    sta (CCZ_RoomMummyMod),y        ; 
                    
KillMummySpriteX    jmp RetSprtSprtKill             ; 
; ------------------------------------------------------------------------------------------------------------- ;
; KillFrankSprite   Function: - called from: ChkSprtSprtKill
;                   Parms   : xr=frank   sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                           : yr=touched sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
KillFrankSprite     subroutine
                    lda CC_WaS_EnemyStatus,x        ; frank
                    and #CC_WaS_FrankAwake          ; 
                    beq .GoMarkDeath                ; 
                    
                    lda CC_WaS_SpriteType,y         ; touched - $00=Player $01=Spark $02=Force $03=Mummy $04=Beam $05=Frank
                    beq .GoMarkDeath                ; CC_WaS_SpritePlayer
                    
                    cmp #CC_WaS_SpriteForce         ; 
                    beq .GoMarkDeath                ; 
                    
                    cmp #CC_WaS_SpriteMummy         ; 
                    beq .GoMarkDeath                ; 
                    
                    cmp #CC_WaS_SpriteFrank         ; 
                    beq .ChkFrankImgLeMax           ; frank-frank handling
                    
                    clc                             ; Spark and Beam left over - kill frank
                    lda CCW_FrankDataPtrLo          ; 
                    adc CC_WaS_Work,x               ; 
                    sta CCZ_RoomItemModLo           ; 
                    lda CCW_FrankDataPtrHi          ; 
                    adc #$00                        ; 
                    sta CCZ_RoomItemModHi           ; 
                    
                    ldy #$00                        ; 
                    lda #CC_Obj_FrankAwake          ; 
                    eor #$ff                        ; 
                    and (CCZ_RoomFrankMod),y        ; 
                    ora #CC_Obj_FrankKilled         ; mark death
                    sta (CCZ_RoomFrankMod),y        ; 
                    jmp KillFrankSpriteX            ; 
                    
.ChkFrankImgLeMax   lda CC_WaS_SpriteNo,x           ; check frank sprite
                    cmp #NoSprFraMovLeMax           ; sprite: Frank: Move Right-Left max
                    bcc .ChkFrankImgRiMax           ; 
                    
.ChkFrankImgLaMax   cmp #NoSprFraMovLaMax           ; sprite: Frank: Move Ladder Up-Down max
                    bcs .ChkFrankImgRiMax
                    
                    lda CC_WaS_SpriteNo,y           ; check touched frank
                    cmp #NoSprFraMovLeMax           ; sprite: Frank: Move Right-Left max
                    bcc .MarkDeath                  ; 
                    
                    cmp #NoSprFraMovLaMax           ; sprite: Frank: Move Ladder Up-Down max
                    bcs .MarkDeath                  ; 
                    
                    lda CC_WaS_SpritePosY,x         ; 
                    cmp CC_WaS_SpritePosY,y         ; 
                    beq .MarkDeath                  ; 
                    bcs .ClrBit0                    ; 
                    
                    lda CC_WaS_PlayerSpriteNo,x     ;
.ClrBit4            and #$ef                        ; ###. ####
                    sta CC_WaS_PlayerSpriteNo,x     ; 
                    jmp .MarkDeath                  ; 
                    
.ClrBit0            lda CC_WaS_PlayerSpriteNo,x     ; 
                    and #$fe                        ; #### ###.
                    sta CC_WaS_PlayerSpriteNo,x     ; 
                    
.GoMarkDeath        jmp .MarkDeath                  ; 
                    
.ChkFrankImgRiMax   lda CC_WaS_SpriteNo,x           ; check frank sprite
                    cmp #NoSprFraMovRiMin           ; sprite: Frank - Move Right Phase 01
                    bcc .MarkDeath                  ; 
                    
                    cmp #NoSprFraMovLeMax           ; sprite: Frank: Move Right-Left max
                    bcs .MarkDeath                  ; 
                    
                    lda CC_WaS_SpriteNo,y           ; check touched frank
                    cmp #NoSprFraMovRiMin           ; sprite: Frank - Move Right Phase 01
                    bcc .MarkDeath                  ; 
                    
                    cmp #NoSprFraMovLeMax           ; sprite: Frank: Move Right-Left max
                    bcs .MarkDeath                  ; 
                    
                    lda CC_WaS_SpritePosX,x         ; 
                    cmp CC_WaS_SpritePosX,y         ; 
                    bcs .ClrBit6                    ; 
                    
.ClrBit2            lda CC_WaS_PlayerSpriteNo,x     ; 
                    and #$fb                        ; #### #.##
                    sta CC_WaS_PlayerSpriteNo,x     ; 
                    jmp .MarkDeath                  ; 
                    
.ClrBit6            lda CC_WaS_PlayerSpriteNo,x     ; 
                    and #$bf                        ; #.## ####
                    sta CC_WaS_PlayerSpriteNo,x     ; 
                    
.MarkDeath          lda #CCW_SpriteDead             ; 
                    sta CCW_SpriteVitality          ; 
                    
KillFrankSpriteX    jmp RetSprtSprtKill             ; 
; ------------------------------------------------------------------------------------------------------------- ;
; KillPlayerTrap    Function: - called from: SprtBkgrHandler
;                   Parms   : xr=Sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                           : yr=Status work area block offset 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
KillPlayerTrap      subroutine
                    lda CC_WaO_ObjectType,y
                    cmp #CC_WaO_TrapDoor
                    bne .CheckTrapCtrl
                    
                    clc
                    lda CC_WaS_SpritePosX,x
                    adc CC_WaS_SpriteStepX,x
                    sec
                    sbc CC_WaO_ObjectGridCol,y
                    cmp #$04
                    bcc .OnOpenTrap
                    
.CheckTrapCtrl      lda #CCW_ObjCollideYes
                    sta CCW_ObjSpriteCollide
                    
                    lda CC_WaO_ObjectType,y
                    cmp #CC_WaO_TrapSwitch
                    bne KillPlayerTrapX
                    
                    clc
                    lda CC_WaS_SpritePosX,x
                    adc CC_WaS_SpriteStepX,x
                    sec
                    sbc CC_WaO_ObjectGridCol,y
                    cmp #$04
                    bcs KillPlayerTrapX
                    
                    lda CC_WaO_TypTrapDataOff,y
                    sta CC_WaS_SpriteObj,x
                    jmp KillPlayerTrapX
                    
.OnOpenTrap         ldy CC_WaS_PlayerSpriteNo,x     ; player directly over open trap
                    lda #CCL_PlayerAccident
                    sta CCL_PlayersStatus,y
                    
KillPlayerTrapX     jmp RetSprtObjKill
; ------------------------------------------------------------------------------------------------------------- ;
; KillMummyTrap     Function: - called from: SprtBkgrHandler
;                   Parms   : xr=Sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                           : yr=Status work area block offset 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
KillMummyTrap       subroutine
                    sty CCW_MummyOffKillWA
                    lda CC_WaO_ObjectType,y
                    cmp #CC_WaO_TrapDoor
                    bne .SetDeath
                    
                    clc
                    lda CC_WaS_SpritePosX,x
                    adc CC_WaS_SpriteStepX,x
                    sec
                    sbc CC_WaO_ObjectGridCol,y
                    cmp #$04
                    bcs .SetDeath
                    
                    clc
                    lda CCW_TrapDataPtrLo
                    adc CC_WaO_TypTrapDataOff,y
                    sta CCZ_RoomItemModLo
                    lda CCW_TrapDataPtrHi
                    adc #$00
                    sta CCZ_RoomItemModHi
                    
                    ldy #$00
                    lda (CCZ_RoomTrapMod),y
                    and #CC_Obj_TrapOpen
                    beq .SetDeath
                    
                    clc
                    lda CCW_MummyDataPtrLo
                    adc CC_WaS_MummyDataOff,x
                    sta CCZ_RoomItemModLo
                    lda CCW_MummyDataPtrHi
                    adc #$00
                    sta CCZ_RoomItemModHi
                    
                    ldy #$00
                    lda #CC_Obj_MummyKilled
                    sta (CCZ_RoomMummyMod),y
                    jmp KillMummyTrapX
                    
.SetDeath           ldy CCW_MummyOffKillWA
                    lda #CCW_ObjCollideYes
                    sta CCW_ObjSpriteCollide
                    
                    lda CC_WaO_ObjectType,y
                    cmp #CC_WaO_TrapSwitch
                    bne KillMummyTrapX
                    
                    clc
                    lda CC_WaS_SpritePosX,x
                    adc CC_WaS_SpriteStepX,x
                    sec
                    sbc CC_WaO_ObjectGridCol,y
                    cmp #$04
                    bcs KillMummyTrapX
                    
                    lda CC_WaO_TypTrapDataOff,y
                    sta CC_WaS_PlayerSpriteNo,x
                    
KillMummyTrapX      jmp RetSprtObjKill
; ------------------------------------------------------------------------------------------------------------- ;
; KillFrankTrap     Function: - called from: SprtBkgrHandler
;                   Parms   : xr=Sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                           : yr=Status work area block offset 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
KillFrankTrap       subroutine
                    clc
                    lda CC_WaS_SpritePosX,x
                    adc CC_WaS_SpriteStepX,x
                    sec
                    sbc CC_WaO_ObjectGridCol,y
                    cmp #$04
                    bcc .NoContact
                    
.Contact            lda #CCW_ObjCollideYes
                    sta CCW_ObjSpriteCollide
.Exit               jmp KillFrankTrapX
                    
.NoContact          lda CC_WaO_ObjectType,y
                    cmp #CC_WaO_TrapDoor
                    beq .GetTrapDataPtr
                    
                    lda #CCW_ObjCollideYes
                    sta CCW_ObjSpriteCollide
                    
                    lda CC_WaO_ObjectType,y
                    cmp #CC_WaO_TrapSwitch
                    bne KillFrankTrapX
                    
                    lda CC_WaO_TypTrapDataOff,y
                    sta CC_WaS_PlayerRoomIOB,x      ; offset TabPlayerRoomIO block
                    jmp KillFrankTrapX
                    
.GetTrapDataPtr     clc
                    lda CCW_TrapDataPtrLo
                    adc CC_WaO_TypTrapDataOff,y
                    sta CCZ_RoomItemModLo
                    lda CCW_TrapDataPtrHi
                    adc #$00
                    sta CCZ_RoomItemModHi
                    
                    ldy #CC_Obj_TrapStatus
                    lda (CCZ_RoomTrapMod),y
                    and #CC_Obj_TrapOpen            ; CC_Obj_TrapOpen
                    beq .Contact
                    
                    clc
.GetFrankDataPtr    lda CCW_FrankDataPtrLo
                    adc CC_WaS_Work,x
                    sta CCZ_RoomItemModLo
                    lda CCW_FrankDataPtrHi
                    adc #$00
                    sta CCZ_RoomItemModHi
                    
.MarkFrankDead      ldy #CC_Obj_FrankCoffinDir
                    lda #CC_Obj_FrankAwake
                    eor #$ff
                    and (CCZ_RoomFrankMod),y
                    ora #CC_Obj_FrankKilled         ; 
                    sta (CCZ_RoomFrankMod),y
                    sta CC_WaS_EnemyStatus,x        ; CC_WaS_FrankKilled
                    
KillFrankTrapX      jmp RetSprtObjKill
; ------------------------------------------------------------------------------------------------------------- ;
; KillBeamOnObject  Function: 
;                   Parms   : xr=Sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                           : yr=
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
KillBeamOnObject    subroutine
                    lda CC_WaO_ObjectType,y
                    cmp #CC_WaO_LightBall
                    beq KillBeamOnObjectX
                    
                    cmp #CC_WaO_Frankenstein
                    beq KillBeamOnObjectX
                    
                    cmp #CC_WaO_RayGun
                    bne .SetDeath
                    
                    lda CC_WaS_BeamWaOff,x
                    cmp CC_WaO_TypGunPtrWA,y
                    bne KillBeamOnObjectX
                    
.SetDeath           lda #CCW_ObjCollideYes
                    sta CCW_ObjSpriteCollide
                    
KillBeamOnObjectX   jmp RetSprtObjKill
; ------------------------------------------------------------------------------------------------------------- ;
; NewBestTime       Function: 
;                   Parms   : CCW_BestTimePlayerNo=player_no / CCW_CompareTime filled with reache time
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
NewBestTime         subroutine
                    lda CCL_Player2Active           ; player 2 pressed fire at start
                    cmp #CCL_Out                    ; 
                    beq .SetPlayer1Time             ; 
                    
.SetPlayer2Time     lda #<(CCH_BestTimesPlayer2-1)  ; 
                    sta CCZ_BestTimesLo             ; 
                    lda #>(CCH_BestTimesPlayer2-1)  ; 
                    sta CCZ_BestTimesHi             ; 
                    jmp .SetMaxEntries              ; 
                    
.SetPlayer1Time     lda #<(CCH_BestTimesPlayer1-1)  ; 
                    sta CCZ_BestTimesLo             ; 
                    lda #>(CCH_BestTimesPlayer1-1)  ; 
                    sta CCZ_BestTimesHi             ; 
                    
.SetMaxEntries      lda #CCH_BestTimesMaxEntries    ; 
                    sta CCW_BestTimeEntryNo         ; 
                    
.ReadEntryTimeI     ldy #CCL_PlayersTimesLen        ; 
.ReadEntryTime      lda (CCZ_BestTimes),y           ; 
                    cmp CCW_CompareTime,y           ; 
                    bcc .SetNextEntry               ; lower
                    bne .ChkP2Active                ; higher - insert here
                    
                    jmp .NextTimeVal                ; try next
                    
.SetNextEntry       clc                             ; 
                    lda CCZ_BestTimesLo             ; 
                    adc #CCH_BestTimesEntryLen      ; 
                    sta CCZ_BestTimesLo             ; 
                    bcc .NextEntryNo                ; 
                    inc CCZ_BestTimesHi             ; 
                    
.NextEntryNo        dec CCW_BestTimeEntryNo         ; 
                    bne .ReadEntryTimeI             ; 
                    
.ExitNoEntry        jmp NewBestTimeX                ; no new best time
                    
.NextTimeVal        dey                             ; 
                    bne .ReadEntryTime              ; 
                    
.ChkP2Active        lda CCL_Player2Active           ; a new best time found
                    cmp #CCL_Out                    ; 
                    beq .SetPosPlayer1              ; player 2 did not pressed fire at start
                    
.SetPosPlayer2      ldy #$09 * CCH_BestTimesEntryLen + CCH_BestTimesP1Len + 1 ; start best times data two players entry $09
                    lda #$16 * CC_GridWidth + CC_GridColOff  ; column 16 * width + column offset
                    sta CCW_GetInputGridCol         ; input text room column grid number
                    jmp .SetScreenRow               ; 
                    
.SetPosPlayer1      ldy #$09 * CCH_BestTimesEntryLen + 1 ; start best times data one player entry $09
                    lda #$03 * CC_GridHeight        ; row 03 * height
                    sta CCW_GetInputGridCol         ; input text room column grid number
                    
.SetScreenRow       sec                             ; 
                    lda #CCH_BestTimesMaxEntries    ; 
                    sbc CCW_BestTimeEntryNo         ;
                    asl a                           ; *2
                    asl a                           ; *4
                    asl a                           ; *8 - row height
                    
                    clc                             ; 
                    adc #$07 * CC_GridHeight        ; row 07 * row height
                    sta CCW_GetInputGridRow         ; input text room row grid number
                    
.SetInputColor      sec                             ; 
                    lda #CCH_BestTimesMaxEntries    ; 
                    sbc CCW_BestTimeEntryNo         ; 
                    tax                             ; 
                    lda TabColorBestTimes,x         ; 
                    sta CCW_GetInputColor           ; 
                    
                    sec                             ; 
                    lda CCZ_BestTimesLo             ;                    
                    sbc #CCH_BestTimesIDLen - 1     ; point to entry data start
                    sta CCW_BestTimeDataPtrLo       ; 
                    lda CCZ_BestTimesHi             ; 
                    sbc #$00                        ; 
                    sta CCW_BestTimeDataPtrHi       ; 
                    
.MoveEntriesI       dec CCW_BestTimeEntryNo         ; move entries one up
                    beq .InsertTimeI                ; 
                    
                    lda #CCH_BestTimesEntryLen      ; 
                    sta CCW_BestTimeEntryLen        ; 
.MoveEntries        lda CC_BestTimes,y              ; 
                    sta CC_BestTimes+CCH_BestTimesEntryLen,y ; 
                    dey                             ; 
                    dec CCW_BestTimeEntryLen        ; 
                    bne .MoveEntries                ; 
                    
                    jmp .MoveEntriesI               ; 
                    
.InsertTimeI        ldy #CCH_BestTimesTimeLen       ; 
.InsertTime         lda CCW_CompareTime,y           ; 
                    sta (CCZ_BestTimes),y           ; 
                    dey                             ; 
                    bne .InsertTime                 ; 
                    
                    lda CCW_BestTimeDataPtrLo       ; 
                    sta CCZ_BestTimesLo             ; 
                    lda CCW_BestTimeDataPtrHi       ; 
                    sta CCZ_BestTimesHi             ; 
                    
                    lda #$00                        ; 
                    ldy #$00                        ; 
                    sta (CCZ_BestTimes),y           ; 
                    jsr ShowBestTimes               ; 
                    
                    lda #<TextHiScore               ; 
                    sta CCZ_RoomItemLo              ; 
                    lda #>TextHiScore               ; 
                    sta CCZ_RoomItemHi              ; 
                    
                    ldx CCW_BestTimePlayerNo        ; 
                    lda TextBestTimePlayers,x       ; 
                    sta TextHiScorePNo              ; 
                    jsr RoomTextLine                ; 
                    
                    jsr SwitchScreenOn              ; 
                    
                    lda #CC_Obj_TextHightSingle     ; 
                    sta CCW_GetInputTxtType         ; 
                    lda #CCH_BestTimesIDLen         ; 
                    sta CCW_GetInputLenMax          ; 
                    jsr GetInputText                ; 
                    
                    lda CCW_BestTimeDataPtrLo       ; save data poiner
                    sta CCZ_BestTimesLo             ; 
                    lda CCW_BestTimeDataPtrHi       ; 
                    sta CCZ_BestTimesHi             ; 
                    
                    ldy #$00                        ; 
.SetIdI             cpy CCW_GetInputLen             ; actual input length
                    bcc .GetId                      ; 
                    
                    lda #" "                        ; filler if id was too short
                    jmp .SetId                      ; 
                    
.GetId              lda CCW_ScoreId,y               ; 
.SetId              sta (CCZ_BestTimes),y           ; 
                    iny                             ; 
                    cpy #CCH_BestTimesTimeLen       ; 
                    bcc .SetIdI                     ; lower
                    
                    ldx CCW_LoadCtrlTabOff          ; 
                    ldy CC_LoadCtrlRow,x            ; 
                    clc                             ; 
                    lda TabCtrlScrRowsLo,y          ; 
                    adc CC_ScreenLoadCtrl,x         ; 
                    sta CCZ_ScreenFileNewLo         ; 
                    lda TabCtrlScrRowsHi,y          ; 
                    adc #$00                        ; 
                    ora #>CC_ScreenText             ; game options and castle load data
                    sta CCZ_ScreenFileNewHi         ; 
                    
                    lda #CCW_DiskFileIdTimes        ; 
                    sta CCW_DiskFileNameId          ; 
                    
                    ldy #CC_LoadCtrlFiMaxLen - 1    ; 
.GetSaveFileNam     lda (CCZ_ScreenFileNew),y       ; 
                    and #$7f                        ; .####### - switch reverse character off
                    cmp #" "                        ; 
                    bcs .SetSaveFileNam             ; 
                    
                    ora #$40                        ; .#......
                    
.SetSaveFileNam     sta CCW_DiskFileName,y          ; 
                    dey                             ; 
                    bpl .GetSaveFileNam             ; 
                    
                    lda CC_LoadCtrlFiNamLen,x       ; 
                    sta CCW_DiskFileNameLen         ; 
                    
                    lda #CC_BestTimesID             ; 
                    sta CCW_DiskFileTargetId        ; 
                    
                    jsr PrepareIO                   ; 
                    jsr SaveLevelData               ; 
                    jsr WarmStart                   ; 
                    
                    lda #$10                        ; dynamic wait time
                    jsr WaitSomeTime                ; 
                    
NewBestTimeX        rts
; ------------------------------------------------------------------------------------------------------------- ;
; ShowBestTimes     Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
ShowBestTimes       subroutine
                    jsr InitHiResSpriteWAs          ; initialize the hires screen and sprite work areas
                    
                    ldx CCW_LoadCtrlTabOff          ; 
                    ldy CC_LoadCtrlRow,x            ;
                    
                    clc                             ; 
                    lda TabCtrlScrRowsLo,y          ; 
                    adc CC_ScreenLoadCtrl,x         ; 
                    sta CCZ_ScreenFileNewLo         ; 
                    lda TabCtrlScrRowsHi,y          ; 
                    adc #$00                        ; 
                    ora #>CC_ScreenText             ; game options and castle load data
                    sta CCZ_ScreenFileNewHi         ; 
                    
.CopyCastleNameI    ldy CC_LoadCtrlFiNamLen,x       ; 
                    dey                             ; 
                    dey                             ; real length
                    lda (CCZ_ScreenFileNew),y       ;    
                    sta CC_BestTimes + CCH_BestTimesEoDLo,y ; 
.CopyCastleName     dey                             ; 
                    bmi .StartCastleName            ; 
                    
                    lda (CCZ_ScreenFileNew),y       ; 
                    and #$7f                        ; .####### - reverse charcters off
                    sta CC_BestTimes + CCH_BestTimesEoDLo,y ;
                    jmp .CopyCastleName             ; 
                    
.StartCastleName    lda #<(CC_BestTimes + CCH_BestTimesEoDLo) ;
                    sta CCZ_RoomItemLo              ; 
                    lda #>(CC_BestTimes + CCH_BestTimesEoDLo) ;
                    sta CCZ_RoomItemHi              ; 
                    
                    sec                             ; 
                    lda #$15                        ; line length
                    sbc CC_LoadCtrlFiNamLen,x       ; put castle name to middle of the line
                    asl a                           ; *2
                    asl a                           ; *4
                    clc                             ; 
                    adc #CC_GridColOff              ; column offset
                    sta CCZ_PaintTextGridCol        ; 
                    lda #$02 * CC_GridHeight        ; row 02 * row height
                    sta CCZ_PaintTextGridRow        ; 
                    
                    lda #WHITE                      ; 
                    sta CCZ_PaintTextColor          ; 
                    
                    lda #CC_Obj_TextHightDouble     ; 
                    sta CCZ_PaintTextType           ; 
                    
.PaintCastleName    jsr PaintText                   ; 

                    lda #$03 * CC_GridHeight        ; row 03 * row height
                    sta CCZ_PaintTextGridCol        ; 
                    
                    ldx #$00                        ; 
                    lda #CC_Obj_TextNormal + CC_Obj_TextHightSingle ; 
                    sta CCZ_PaintTextType           ; 
                    
.SetStartRow        lda #$00                        ; 
                    sta CC_BestTimes + CCH_BestTimesEoDLo + CC_LoadCtrlFiMaxLen ;
                    
                    lda #$0a * CC_GridWidth + CC_GridColOff ; column 10 * column height + offset
                    sta CCZ_PaintTextGridRow        ; 
                    
.GetRowColor        ldy CC_BestTimes + CCH_BestTimesEoDLo + CC_LoadCtrlFiMaxLen ; 
                    lda TabColorBestTimes,y         ; 
                    sta CCZ_PaintTextColor          ; 
                    
                    lda CCH_BestTimesP1Id,x         ; 
                    cmp #CCH_BestTimesEoD           ; 
                    beq .Empty                      ; 
                    
                    sta CC_BestTimes + CCH_BestTimesEoDLo ;
                    lda CCH_BestTimesP1Id+1,x       ; 
                    sta CC_BestTimes + CCH_BestTimesEoDLo + $01 ; 
                    lda CCH_BestTimesP1Id+2,x       ; 
                    jmp .MarkEoL                    ; 
                    
.Empty              lda #"."                        ; 
                    sta CC_BestTimes + CCH_BestTimesEoDLo + $00 ; 
                    sta CC_BestTimes + CCH_BestTimesEoDLo + $01 ; 
.MarkEoL            ora #CC_Obj_TextEoLine          ; 
                    sta CC_BestTimes + CCH_BestTimesEoDLo + $02 ; 
                    
                    lda #<(CC_BestTimes + CCH_BestTimesEoDLo) ; 
                    sta CCZ_RoomItemLo              ; 
                    lda #>(CC_BestTimes + CCH_BestTimesEoDLo) ; 
                    sta CCZ_RoomItemHi              ; 
                    
                    stx CCW_Temp                    ; .hbu010. - save: will be destroyed in paintext
.PaintId            jsr PaintText                   ; 
                    ldx CCW_Temp                    ; .hbu010. - restore
                    
                    lda CCH_BestTimesP1Id,x         ; 
                    cmp #CCH_BestTimesEoD           ; 
                    beq .SetNextRow                 ; 
                    
                    clc                             ; 
                    txa                             ; 
                    adc #$04                        ; time offset
                    sta CCZ_RoomItemLo              ; 
                    lda #>CC_BestTimes              ; 
                    adc #$00                        ; 
                    sta CCZ_RoomItemHi              ; 
                    
                    ldy #BLACK                      ; .hbu018. - do not care for life counter this time
                    sty ColObjTimeDataBestT1        ; .hbu018.
                    sty ColObjTimeDataBestT2        ; .hbu018.
                    iny                             ; .hbu016. - white
                    jsr FillObjTimeFrame            ; 
                    
                    lda CCZ_PaintTextGridCol        ; 
                    clc                             ; 
                    adc #$06 * CC_GridWidth         ; .hbu018. - shift display 2 columns to the left because of life counter
                    sta CCZ_PntObj00PrmGridCol      ; 
                    lda CCZ_PaintTextGridRow        ; 
                    sta CCZ_PntObj00PrmGridRow      ; 
                    lda #CCZ_PntObjPrmType00        ; 
                    sta CCZ_PntObjPrmType           ; 
                    lda #NoObjTime                  ; object: Time Frame
                    sta CCZ_PntObj00PrmNo           ; 
                    
.PaintTime          jsr PaintObject                 ; 
                    
.SetNextRow         clc                             ; 
                    lda CCZ_PaintTextGridRow        ; 
                    adc #CC_GridHeight              ; 
                    sta CCZ_PaintTextGridRow        ; 
                    
                    clc                             ; 
                    txa                             ; 
                    adc #CCH_BestTimesEntryLen      ; 
                    tax                             ; 
                    
                    inc CC_BestTimes + CCH_BestTimesEoDLo + CC_LoadCtrlFiMaxLen ; 
                    lda CC_BestTimes + CCH_BestTimesEoDLo + CC_LoadCtrlFiMaxLen ; 
                    cmp #CCH_BestTimesMaxEntries    ; 
                    bcs .ChkRight                   ; 
                    
                    jmp .GetRowColor                ; 
                    
.ChkRight           lda CCZ_PaintTextGridCol        ; 
                    cmp #$02 * CC_GridWidth + CC_GridColOff ; column 02 * column width + offset = left  column - one player data
                    bne .SetHeader                  ; $68 = right column processed too - complete
                    
                    lda #$16 * CC_GridWidth + CC_GridColOff ; column 23 * column width + offset = right column - two player data
                    sta CCZ_PaintTextGridCol        ; 
                    jmp .SetStartRow                ; 
                    
.SetHeader          lda #<TextBestTimes             ; 
                    sta CCZ_RoomItemLo              ; 
                    lda #>TextBestTimes             ; 
                    sta CCZ_RoomItemHi              ; 
                    
ShowBestTimesX      jmp RoomTextLine                ; 
; ------------------------------------------------------------------------------------------------------------- ;
; LoadCastleData    Function: 
;                   Parms   : xr=screen control table offset for seleted file name
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
LoadCastleData      subroutine
.GetNewDataFile     lda #CCW_DiskFileIdCastle       ; "Z" - castle data file id
                    sta CCW_DiskFileNameId          ; 
                    
.SetScreenFilePtr   ldy CC_LoadCtrlRow,x            ; row number of castle name 
                    lda TabCtrlScrRowsLo,y          ; 
                    sta CCZ_ScreenFileNewLo         ; 
                    lda TabCtrlScrRowsHi,y          ; 
                    ora #>CC_ScreenText             ; game options and castle load data
                    sta CCZ_ScreenFileNewHi         ; 
                    
                    clc                             ; 
                    lda CCZ_ScreenFileNewLo         ; 
                    adc CC_LoadCtrlCol,x            ; column number of castle name 
                    sta CCZ_ScreenFileNewLo         ; 
                    bcc .CpyFileNameI               ; 
                    inc CCZ_ScreenFileNewHi         ; 
                    
.CpyFileNameI       ldy #$00
.CpyFileName        lda (CCZ_ScreenFileNew),y       ; ptr: this file name on Options/LoadData screen
                    and #$7f                        ; .hbu012. - .####### - revert char
                    cmp #$20                        ; blank
                    bcs .PutFileName                ; equal or higher - file name end in screen storage
                    
                    ora #$40                        ; convert from screen code to chr code
.PutFileName        sta CCW_DiskFileName,y          ; and store
                    iny                             ; 
                    cpy #CC_LoadCtrlFiMaxLen        ; max lenght file name
                    bcc .CpyFileName                ; lower
                    
                    ldy CC_LoadCtrlFiNamLen,x       ; 
                    sty CCW_DiskFileNameLen         ; 
                    
                    lda #CC_LevelGameID             ; .hbu012. - always load to game storage now
                    sta CCW_DiskFileTargetId        ; 
                    
.SavCtrlTabOff      stx CCW_Temp                    ; .hbu010. - save control table offset
.LoadLevelFile      jsr PrepareIO                   ; 
                    jsr LoadLevelData               ; 
                    jsr READST                      ; KERNEL - $FFB7 = read I/O status word
                    
                    cmp #$40                        ; was ok - end of file
.LoadLevelFileOk    beq .GetNewScoreFile            ; 
                    
.LoadLevelFileErr   jsr WarmStart                   ; 
                    jmp LoadCastleDataX             ; 
                    
.GetNewScoreFile    lda #CCW_DiskFileIdTimes        ; "Y" - castle data high scores id
                    sta CCW_DiskFileNameId          ; 
                    
                    lda #CC_BestTimesID             ; 
                    sta CCW_DiskFileTargetId        ; 
                    
                    jsr LoadLevelData
                    jsr READST                      ; KERNEL - $FFB7 = read I/O status word
                    
                    cmp #$40                        ; was ok - end of file
                    beq .LoadedBoth                 ; 
                    
.SavScoreLoadLen    lda #CCH_BestTimesEoDLo         ; save max load adddress of score file
                    sta CCH_BestTimesLenLo          ; 
                    lda #CCH_BestTimesEoDHi         ; 
                    sta CCH_BestTimesLenHi          ; 
                    
.InitScoreI         ldy #CCH_BestTimesEoDLo - CCH_BestTimesHdrLen - $01 ;
                    lda #CCH_BestTimesEoD           ; 
.InitScore          sta CCH_BestTimesP1Id,y         ; 
                    dey                             ; 
                    bpl .InitScore                  ; 
                    
.LoadedBoth         jsr WarmStart                   ; 
                    
.GetCtrlTabOff      ldx CCW_Temp                    ; .hbu010. - restore control table offset
                    cpx CCW_LoadCtrlTabOff          ; .hbu012.
                    beq LoadCastleDataX             ; .hbu012. - same file - already marked
                    
.SetNewFileNamPtr   ldy CC_LoadCtrlRow,x            ; row number - old file name (to be reversed)
                    lda TabCtrlScrRowsLo,y          ; 
                    sta CCZ_ScreenFileNewLo         ; 
                    lda TabCtrlScrRowsHi,y          ; 
                    ora #>CC_ScreenText             ; game options and castle load data
                    sta CCZ_ScreenFileNewHi         ; 
                    
                    clc                             ; 
                    lda CC_LoadCtrlCol,x            ; column number
                    adc CCZ_ScreenFileNewLo         ; 
                    sta CCZ_ScreenFileNewLo         ; 
                    bcc .SavNewDatFilePos           ; 
                    inc CCZ_ScreenFileNewHi         ; 
                    
.SavNewDatFilePos   stx CCW_LoadCtrlDataFilePos     ; 

                    ldx CCW_LoadCtrlTabOff          ; 
.SetOldFileNamPtr   ldy CC_LoadCtrlRow,x            ; row number - old file name (still reversed)
                    lda TabCtrlScrRowsLo,y          ; 
                    sta CCZ_ScreenFileOldLo         ; 
                    lda TabCtrlScrRowsHi,y          ; 
                    ora #>CC_ScreenText             ; game options and castle load data
                    sta CCZ_ScreenFileOldHi         ; 
                    
                    clc                             ; 
                    lda CCZ_ScreenFileOldLo         ; 
                    adc CC_LoadCtrlCol,x            ; column number
                    sta CCZ_ScreenFileOldLo         ; 
                    bcc .FileInvRevI                ; 
                    inc CCZ_ScreenFileOldHi         ; 
                    
.FileInvRevI        ldy #CC_LoadCtrlFiMaxLen        ; max length file name
                    ldx CCW_LoadCtrlDataFilePos     ; 
.FileInvRev         lda CCW_LoadCtrlTabOff          ; 
                    cmp #$ff                        ; none loaded so far
                    beq .FileInv                    ; 
                    
.FileRev            lda (CCZ_ScreenFileOld),y       ; 
                    and #$7f                        ; .####### - revert char
                    sta (CCZ_ScreenFileOld),y       ; reverse old file name
.FileInv            lda (CCZ_ScreenFileNew),y       ; 
                    ora #$80                        ; #....... - invert char
                    sta (CCZ_ScreenFileNew),y       ; inverse new file name
                    dey                             ; 
                    bpl .FileInvRev                 ; 
                    
                    stx CCW_LoadCtrlTabOff          ; 
                    
LoadCastleDataX     jmp AdjustRoomDataPtrs          ; .hbu014. - adjust room data pointers after each new load only
; ------------------------------------------------------------------------------------------------------------- ;
; GetDiskFileName   Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
GetDiskFileName     subroutine
                    jsr InitHiResSpriteWAs          ; initialize the hires screen and sprite work area
                    
                    lda #<TextFileName              ; 
                    sta CCZ_RoomItemLo              ; 
                    lda #>TextFileName              ; 
                    sta CCZ_RoomItemHi              ; 
                    jsr PaintRoomItems              ; 
                    
                    lda CCW_DiskActionId            ; $00=save $01=resume a game
                    beq .TextSaveGame               ; 
                    
.TextResumeGame     lda #<TextResumeGame            ; 
                    sta CCZ_RoomItemLo              ; 
                    lda #>TextResumeGame            ; 
                    sta CCZ_RoomItemHi              ; 
                    jmp .PaintScreen                ; 
                    
.TextSaveGame       lda #<TextSaveGame              ; 
                    sta CCZ_RoomItemLo              ; 
                    lda #>TextSaveGame              ; 
                    sta CCZ_RoomItemHi              ; 
                    
.PaintScreen        jsr PaintRoomItems              ; save/resume text out
                    
                    jsr SwitchScreenOn              ; 
                    
                    lda #$20                        ; 
                    sta CCW_GetInputGridCol         ; input text room column grid number
                    lda #$48                        ; 
                    sta CCW_GetInputGridRow         ; input text room row grid number
                    
                    lda #WHITE                      ; input color
                    sta CCW_GetInputColor           ; 
                    lda #CC_Obj_TextHightDouble     ; double size
                    sta CCW_GetInputTxtType         ; 
                    
                    lda #CCW_DiskFileNameLenMax     ; .hbu011. - discount new save file id
                    sta CCW_GetInputLenMax          ; 
                    
GetDiskFileNameX    jmp GetInputText                ; get a file name
; ------------------------------------------------------------------------------------------------------------- ;
; ResumeGame        Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
ResumeGame          subroutine
                    jsr WarmStart                   ; 
                    
                    lda #CCW_DiskActionResume       ; 
                    sta CCW_DiskActionId            ; 
                    
                    jsr GetDiskFileName             ; 
                    
                    ldx CCW_GetInputLen             ; file name length
                    beq ResumeGameX                 ; no file name entered
                    
                    inx                             ; .hbu011. - add disk file id
                    stx CCW_DiskFileNameLen         ; .hbu011.
                    
                    lda #CCW_DiskFileIdSave         ; .hbu011. - new save file id
                    sta CCW_DiskFileNameId          ; .hbu011.
                    
                    lda #CC_LevelGameID             ; target data storage
                    sta CCW_DiskFileTargetId        ; 
                    
                    jsr PrepareIO                   ; 
.Resume             jsr LoadLevelData               ; 
                    jsr READST                      ; KERNEL - $FFB7 = read I/O status word
                    
                    sta CCW_DiskStatusCC            ; save disk status
                    cmp #$40                        ; end of file
                    bne ResumeGameX                 ; 
                    
                    lda #$01                        ; .hbu010. - volume nearly off - used in warmstart
                    sta TabSidVolume                ; .hbu010. - stop demo music

                    lda #CCW_DiskAccessOk           ; game resumeded successfully
                    sta CCW_DiskAccess              ; 
                    
                    lda #CCZ_ResumeOn               ; .hbu015. - force repaint of all rooms after resume
                    sta CCZ_ResumeGame              ; 
                    
ResumeGameX         jmp WarmStart                   ; 
; ------------------------------------------------------------------------------------------------------------- ;
; SaveGame          Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
SaveGame            subroutine
                    lda #CCW_DiskActionSave         ; 
                    sta CCW_DiskActionId            ; 
                    
                    jsr GetDiskFileName             ; 
                    
                    ldx CCW_GetInputLen             ; file name length
                    beq SaveGameX                   ; no file name entered
                    
                    inx                             ; .hbu011. - add disk file id
                    stx CCW_DiskFileNameLen         ; .hbu011.
                    
                    lda #CCW_DiskFileIdSave         ; .hbu011. - new save file id
                    sta CCW_DiskFileNameId          ; .hbu011.
                    
                    lda #CC_LevelGameID             ; target data storage
                    sta CCW_DiskFileTargetId        ; 
                    
                    jsr PrepareIO                   ; 
                    jsr SaveLevelData               ; 
                    jsr READST                      ; KERNEL - $FFB7 = read I/O status word --> $FE07
                    bne .ExitBad                    ; save not ok
                    
.ExitOk             jmp WarmStart                   ; 
                    
.ExitBad            jsr WarmStart                   ; 
                    
                    lda #<TextIOError               ; 
                    sta CCZ_RoomItemLo              ; 
                    lda #>TextIOError               ; 
                    sta CCZ_RoomItemHi              ; 
                    
                    jsr InitHiResSpriteWAs          ; initialize the hires screen and sprite work area
                    jsr RoomTextLine                ; 
                    jsr SwitchScreenOn              ; 
                    
SaveGameX           rts                             ; 
; ------------------------------------------------------------------------------------------------------------- ;
; SaveLevelData     Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
SaveLevelData       subroutine
                    lda #$02                        ; 
                    ldx #$08                        ; 
                    ldy #$00                        ; 
                    jsr SETLFS                      ; KERNEL - $FFBA = set logical file parameters
                    
                    clc                             ; 
                    lda CCW_DiskFileNameLen         ; 
                    adc #CCW_DiskFileReplHdrLen     ; header length
                    ldx #<CCW_DiskFileReplHdr       ; 
                    ldy #>CCW_DiskFileReplHdr       ; 
                    jsr SETNAM                      ; KERNEL - $FFBD = set filename parameters
                    
                    lda CCW_DiskFileTargetId        ; flag: CC_LevelGameID CC_LevelMusicID CC_BestTimesID
                    asl a                           ; *2
                    tax                             ; 
                    lda TabSaveTargetAdr,x          ; 
                    sta CCZ_SavGameDataLo           ; 
                    lda TabSaveTargetAdr+1,x        ; 
                    sta CCZ_SavGameDataHi           ; point to start address of save data - lenght info
                    
                    clc                             ; 
                    ldy #$00                        ; 
                    lda (CCZ_SavGameData),y         ; no of bytes in last data page
                    adc CCZ_SavGameDataLo           ; 
                    tax                             ; KERNEL SAVE - EndOfSaveData address low
                    
                    iny                             ; 
                    lda (CCZ_SavGameData),y         ; number of data pages
                    adc CCZ_SavGameDataHi           ; 
                    tay                             ; KERNEL SAVE - EndOfSaveData address high
                    
                    lda #CCZ_SavGameData            ; KERNEL SAVE - start address registers
SaveLevelDataX      jmp SAVE                        ; KERNEL - $FFD8 = save to a device
; ------------------------------------------------------------------------------------------------------------- ;
; LoadLevelData     Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
LoadLevelData       subroutine
                    lda #$02                        ; 
                    ldx #$08                        ; 
                    ldy #$00                        ; 
                    jsr SETLFS                      ; KERNEL - $FFBA = set logical file parameters
                    
                    lda CCW_DiskFileNameLen         ; 
                    ldx #<CCW_DiskFileNameId        ; 
                    ldy #>CCW_DiskFileNameId        ; 
                    jsr SETNAM                      ; KERNEL - $FFBD = set filename parameters
                    
                    lda #$00                        ; flag: $00=Load $01=Check
                    ldx CCW_DiskFileTargetId        ; flag: CC_LevelGameID CC_LevelMusicID CC_BestTimesID
                    ldy TabLoadTargetAdr,x          ; load address high
                    ldx #$00                        ; load address low
                    jsr LOAD                        ; KERNEL - $FFD5 = load from device
                    
                    stx CCW_DiskFileEndAdrLo        ; save loaded files end address
                    sty CCW_DiskFileEndAdrHi        ; 
                    
LoadLevelDataX      rts
; ------------------------------------------------------------------------------------------------------------- ;
; PrepareIO         Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
PrepareIO           subroutine
                    lda #$00                        ; all IRQ sources=OFF
                    sta IRQMASK                     ; VIC 2 - $D01A = IRQ Mask
                    
                    lda #$7f                        ; 
                    sta CIAICR                      ; CIA 1 - $DC0D = Interrupt Control
                    lda CIAICR                      ; CIA 1 - $DC0D = Interrupt Control
                    
                    lda #$07                        ; 
                    sta D6510                       ; CPU Port Data Direction Register
                    lda #B__off                     ; -> basic=off io=on kernel=on
                    sta R6510                       ; CPU Port Data Register
                    jsr IOINIT                      ; KERNEL - $FF84 = init I/O devices
                    
                    lda SCROLY                      ; VIC 2 - $D011 = VIC Control Register 1 (and Vertical Fine Scrolling)
                    and #$20                        ;   Bit 5: Enable bitmap graphics mode  1=enable
                    beq PrepareIOX                  ; not set
                    
.AvoidGfxFailure    lda #$03                        ; 
                    sta C2DDRA                      ; CIA 2 - $DD02 = Data Direction A
                    lda CI2PRA                      ; CIA 2 - $DD00 = Data Port A
                    and #VIC_MemBankClr             ; Bits 0-1: 00 = $c000-$ffff - VIC-II chip mem bank 3
                    sta CI2PRA                      ; CIA 2 - $DD00 = Data Port A
                    
PrepareIOX          rts                             ; 
; ------------------------------------------------------------------------------------------------------------- ;
; GetInputText      Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
GetInputText        subroutine
                    pha
                    txa
                    pha
                    
                    lda #CCW_KeyGotNo               ; reset
                    sta CCW_KeyGotRestore           ; restore key pressed
                    
                    lda CCW_GetInputColor           ; 
                    sta CCZ_PaintTextColor          ; 
                    
                    lda CCW_GetInputTxtType         ; 
                    ora #CC_Obj_TextNormal          ; normal (not reversed)
                    sta CCZ_PaintTextType           ; 
                    
                    lda CCW_GetInputGridCol         ; input text room column grid number
                    sta CCZ_PaintTextGridCol        ; 
                    lda CCW_GetInputGridRow         ; input text room row grid number
                    sta CCZ_PaintTextGridRow        ; 
                    
                    lda #CCW_GetInputCursorInit     ; place holder char
                    sta CCW_GetInputCursor          ; 
                    
                    ldx CCW_GetInputLenMax          ; .hbu010. - should be greater zero
                    stx CCW_GetInputLen             ; .hbu010. - count down value
.OutSingleChar      jsr PaintSingleChar             ; 
                    
                    dec CCW_GetInputLen             ; .hbu010. - count down value
                    beq .GetNextChar                ; .hbu010. - input line filled up completely with place holder
                    
.SetNextPos         clc                             ; 
                    lda CCZ_PaintTextGridCol        ; 
                    adc #CC_GridWidth * 2           ; 
                    sta CCZ_PaintTextGridCol        ; 
                    jmp .OutSingleChar              ; 
                    
.GetNextChar        lda CCW_GetInputLen             ; actual input length
                    cmp CCW_GetInputLenMax          ; 
                    beq .NoCursor                   ; 
                    
.RotateCursor       inc CCW_GetInputCursorNo        ; actual cursor form
                    lda CCW_GetInputCursorNo        ; actual cursor form
                    and #$03                        ; only 4 different forms
                    tax                             ; 
                    lda TabGetInputCursorNo,x       ; 
                    sta CCW_GetInputCursor          ; 
                    
                    lda CCW_GetInputLen             ; actual input length
                    asl a                           ; *2
                    asl a                           ; *4
                    asl a                           ; *8
                    clc                             ; 
                    adc CCW_GetInputGridCol         ; input text room column grid number
                    sta CCZ_PaintTextGridCol        ; 
                    
.PaintCursor        jsr PaintSingleChar             ; 
                    
.NoCursor           jsr GetInputKey                 ; 
                    
.Chk_Bad            cmp #$80                        ; ivalid key
                    bne .Chk_Delete                 ; 
                    
.Chk_Restore        lda CCW_KeyGotRestore           ; restore key pressed
                    cmp #CCW_KeyGotYes              ; 
                    beq .KeyRestore                 ; 
                    
                    lda #CCW_CountIRQsInput         ; 
                    sta CCW_CountIRQs               ; counted down to $00 with every IRQ
.WaitKey            lda CCW_CountIRQs               ; 
                    bne .WaitKey                    ; 
                    
                    jmp .GetNextChar                ; 
                    
.KeyRestore         lda #$00                        ; 
                    sta CCW_GetInputLen             ; actual input length
                    
.WaitI              lda #CCW_KeyGotNo               ; reset
                    sta CCW_KeyGotRestore           ; restore key pressed
                    
                    lda #CCW_CountIRQsInput         ; 
                    sta CCW_CountIRQs               ; counted down to $00 with every IRQ
.WaitRestore        lda CCW_CountIRQs               ; 
                    bne .WaitRestore                ; 
                    
                    lda CCW_KeyGotRestore           ; restore key pressed
                    cmp #CCW_KeyGotNo               ; is it still pressed
                    bne .WaitI                      ; 
                    
.ExitRestore        jmp GetInputTextX               ; exit if RESTORE pressed
                    
.Chk_Delete         cmp #$08                        ; delete key
                    bne .Chk_Return                 ; 
                    
                    lda CCW_GetInputLen             ; actual input length
                    cmp CCW_GetInputLenMax          ; 
                    beq .ChkInputLen                ; 
                    
                    lda #CCW_GetInputCursorInit     ; place holder char
                    sta CCW_GetInputCursor          ; 
                    
                    jsr PaintSingleChar             ; 
                    
.ChkInputLen        lda CCW_GetInputLen             ; actual input length
                    beq .GoGetNextChar
                    
                    dec CCW_GetInputLen             ; actual input length
                    
.GoGetNextChar      jmp .GetNextChar                ; 
                    
.Chk_Return         cmp #$0d                        ; return key
                    bne .ChkInputMax                ; 
                    
.ExitReturn         jmp GetInputTextX               ; 
                    
.ChkInputMax        ldx CCW_GetInputLen             ; actual input length
                    cpx CCW_GetInputLenMax          ; 
                    beq .GoGetNextChar              ; 
                    
                    sta CCW_TextInputBuffer,x       ; 
                    inx                             ; 
                    stx CCW_GetInputLen             ; actual input length
                    sta CCW_GetInputCursor          ; 
                    
.PaintInitial       jsr PaintSingleChar             ; 
                    
                    jmp .GetNextChar                ; 
                    
GetInputTextX       pla
                    tax
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
; GetInputKey       Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
GetInputKey         subroutine
                    lda #$00                        ; 
                    sta CCW_KeyMatrixPosGot         ; 
                    sta CCW_KeyMatrixTabPos         ; 
                    
                    lda #$fe                        ; check keyboard matrix row - 0 for row to read / 1 for row to ignore
                    sta CCW_KeyMatrixRowMask        ; #######. = row 0 (CRSR_D/F5/F3/F1/F7/CRSR_R/RETURN/DELETE)
                    
                    lda #$ff                        ; prepare read  if A=$ff and B=$00
                    sta CIDDRA                      ; CIA 1 - $DC02 = Data Direction A
                    lda #$00                        ; prepare read  if A=$ff and B=$00
                    sta CIDDRB                      ; CIA 1 - $DC03 = Data Direction B
                    
.ReadNextKeyRow     lda CCW_KeyMatrixRowMask        ; 
                    sta CIAPRA                      ; CIA 1 - $DC00 = Data Port A - write to    A
                    lda CIAPRB                      ; CIA 1 - $DC01 = Data Port B - read  from  B
                    sta CCW_KeyMatrixColMask        ; check which key in row 0 was pressed
                    
                    lda #$07                        ; 
                    sta CCW_KeyMatrixRowBit         ; check all 8 bits
                    
.ChkRow             lsr CCW_KeyMatrixColMask        ; shift out key bits startig with Bit0
                    bcs .SetNextRow                 ; 1= not pressed
                    
                    ldx CCW_KeyMatrixTabPos         ; 
                    lda TabKeyMatrix,x              ; 
                    bmi .SetNextRow                 ; illegal key
                    
                    ldx CCW_KeyMatrixPosGot         ; 
                    sta CCW_KeyMatrixValGot,x       ; 
                    inx                             ; 
                    stx CCW_KeyMatrixPosGot         ; 
                    cpx #$03                        ; 
                    beq .KeyNew                     ; exit if 3 legal keys found
                    
.SetNextRow         inc CCW_KeyMatrixTabPos         ; 
                    dec CCW_KeyMatrixRowBit         ; 
                    bpl .ChkRow                     ; 
                    
                    sec                             ; set to be shure only one row will be checked
                    rol CCW_KeyMatrixRowMask        ; no key pressed in this row - set next
                    bcs .ReadNextKeyRow             ; still one row left to check
                    
.KeyNew             ldx #$00                        ; 
.KeyNewChk          cpx CCW_KeyMatrixPosGot         ; 
                    beq .SetBad                     ; 
                    
                    ldy #$00                        ; 
.KeyOldChk          cpy CCW_KeyMatrixPosSav         ; 
                    beq .SetGood                    ; 
                    
                    lda CCW_KeyMatrixValSav,y       ; 
                    cmp CCW_KeyMatrixValGot,x       ; 
                    beq .KeyNewNext                 ; 
                    
                    iny                             ; 
                    jmp .KeyOldChk                  ; 
                    
.KeyNewNext         inx                             ; 
                    jmp .KeyNewChk                  ; 
                    
.SetBad             lda #$80                        ; 
                    jmp .KeyStore                   ; 
                    
.SetGood            lda CCW_KeyMatrixValGot,x       ; 
.KeyStore           sta CCW_KeyMatrixRowBit         ; 
                    
                    ldx CCW_KeyMatrixPosGot         ; 
                    stx CCW_KeyMatrixPosSav         ; 
.KeyCopy            dex                             ; 
                    bmi .GetKey                     ; 
                    
                    lda CCW_KeyMatrixValGot,x       ; 
                    sta CCW_KeyMatrixValSav,x       ; 
                    jmp .KeyCopy                    ; 
                    
.GetKey             lda CCW_KeyMatrixRowBit
                    
GetInputKeyX        rts
; ------------------------------------------------------------------------------------------------------------- ;
; FillSprtCollsWA   Function: Loop through the sprite work areas
;                             and transport sprite/sprite and sprite/background collisions to each CC_WaS_SpriteFlag
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
FillSprtCollsWA     subroutine
                    pha
                    txa
                    pha
                    
                    lda SPSPCL                      ; VIC 2 - $D01E = Sprite to Sprite Collision
                    sta CCW_SpriteSpriteColl        ; collision sprite/sprite
                    lda SPBGCL                      ; VIC 2 - $D01F = Sprite to Foreground Collision
                    sta CCW_SpriteBackGrColl        ; collision sprite/background
                    
                    ldx #$00
.ChkSpriteWA        lda CC_WaS_SpriteFlag,x         ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    bit Bit_oooo_ooo1               ;            $10=action   $20=death          $40=dead           $80=init
                    beq .NoS1S2                     ; active
                    
                    lsr CCW_SpriteSpriteColl        ; collision sprite/sprite     - shift inactive bit out
                    lsr CCW_SpriteBackGrColl        ; collision sprite/background - shift inactive bit out
                    jmp .SetNextSpriteWA
                    
.NoS1S2             and #$f9                        ; #### #..# - clear collision flags
                    lsr CCW_SpriteSpriteColl        ; collision sprite/sprite     - shift active bit to carry
                    bcc .ChkBkgr                    ; no collision
                    
                    ora #CC_WaS_FlagCollS_S         ; Bit 1: a sprite/sprite collision happend
                    
.ChkBkgr            lsr CCW_SpriteBackGrColl        ; collision sprite/background - shift active bit to carry
                    bcc .SetMark                    ; no collision
                    
                    ora #CC_WaS_FlagCollS_B         ; Bit 3: a sprite/background collision happend
                    
.SetMark            sta CC_WaS_SpriteFlag,x         ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                                                    ;            $10=action   $20=death          $40=dead           $80=init
.ClrMummyColl       lda #CC_WaS_MummyCollNo         ; .hbu004. - reset a possible mummy collision
                    sta CC_WaS_MummyCollLeft,x      ; .hbu004.
                    sta CC_WaS_MummyCollRight,x     ; .hbu004.
                    
.SetNextSpriteWA    clc                             ; 
                    txa                             ; 
                    adc #CC_WaS_DataLen             ; point to next sprite work area
                    tax                             ; 
                    bne .ChkSpriteWA                ; not all areas processed
                    
FillSprtCollsWAX    pla
                    tax
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
; AnimateDeath      Function: 
;                   Parms   : xr=Sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
AnimateDeath        subroutine
                    lda CC_WaS_SpriteFlag,x         ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    bit Bit_o1oo_oooo               ; $10=action $20=death    $40=dead           $80=initialized
                    bne .InitDeath                  ; death required
                    
                    lda CC_WaS_SpriteDeath,x        ; 
                    bne .ChkWait                    ; death ongoing
                    
                    lda CC_WaS_SpriteFlag,x         ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    eor Bit_oo1o_oooo               ;            $10=action   $20=death          $40=dead           $80=init
                    jmp .Immortals                  ; 
                    
.InitDeath          eor #CC_WaS_FlagDead            ; reset death flag
                    sta CC_WaS_SpriteFlag,x         ; 
                    
                    lda CC_WaS_SpriteType,x         ; $00=Player $01=Spark $02=Force $03=Mummy $04=Beam $05=Frank
                    bne .SetSpriteNo                ; .hbu017.
                    
                    pha                             ; .hbu017.
.GetSavedRoomData   jsr RoomDataRestore             ; .hbu017.
                    pla                             ; .hbu017.
                    
.SetSpriteNo        asl a                           ; *2
                    asl a                           ; *4
                    asl a                           ; *8
                    tay                             ; 
                    lda SpriteMortality,y           ; 
                    and SpriteMortal                ; 
                    bne .Mortals                    ; Flag: Mortals - 1=Player/Mummy/Frank
                    
                    lda CC_WaS_SpriteFlag,x         ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
.Immortals          ora #CC_WaS_FlagAction          ;            $10=action   $20=death          $40=dead           $80=init
                    sta CC_WaS_SpriteFlag,x         ; 
                    jmp AnimateDeathX               ; 
                    
.Mortals            lda #NoSndDeath                 ; sound: Player/Mummy/Frank Death
                    sta CC_WaS_SpriteDeath,x        ;
                    
                    txa                             ; 
                    lsr a                           ; /2
                    lsr a                           ; /4
                    lsr a                           ; /8
                    lsr a                           ; /16
                    lsr a                           ; /32 = sprite number
                    tay                             ; 
                    lda TabSelectABit,y             ; 
                    eor #$ff                        ; 
                    and SPMC                        ; VIC 2 - $D01C = Sprite Multicolor
                    sta SPMC                        ; VIC 2 - $D01C = Sprite Multicolor
                    
                    lda CC_WaS_SpriteFlag,x         ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    ora #CC_WaS_FlagDeath           ;            $10=action   $20=death          $40=dead           $80=init
                    sta CC_WaS_SpriteFlag,x         ; 
                    
                    lda #$01                        ; 
                    sta CC_WaS_SpriteSeqNo,x        ; 
                    
.ChkWait            lda CCW_CountActnHdlrCalls      ; counter ActionHandler routine calls
                    and #$01                        ; 
                    bne .FlickerBlack               ; 
                    
.FlickerWhite       txa                             ; 
                    lsr a                           ; /2
                    lsr a                           ; /4
                    lsr a                           ; /8
                    lsr a                           ; /16
                    lsr a                           ; /32 = sprite number
                    tay                             ; 
                    lda #WHITE                      ; 
                    sta SP0COL,y                    ; VIC 2 - $D027 = Color Sprite 0(-7)
                    
                    dec CC_WaS_SpriteDeath,x        ;  
                    lda CC_WaS_SpriteDeath,x        ; 
                    asl a                           ; *2
                    asl a                           ; *4
                    asl a                           ; *8
                    sta SFX_DeathTone               ; vary tone
                    
                    lda #NoSndDeath                 ; sound: Player/Mummy/Frank Death
                    jsr InitSoundFx                 ; 
                    
                    jmp .SaveSeqNo                  ; 
                    
.FlickerBlack       txa                             ; 
                    lsr a                           ; /2
                    lsr a                           ; /4
                    lsr a                           ; /8
                    lsr a                           ; /16
                    lsr a                           ; /32 = sprite number
                    tay                             ; 
                    lda #BLACK                      ; 
                    sta SP0COL,y                    ; VIC 2 - $D027 = Color Sprite 0(-7)
                    
.SaveSeqNo          lda CC_WaS_SpriteSeqNo,x        ; 
                    sta CC_WaS_SpriteSeqOld,x       ; 
                    
AnimateDeathX       rts
; ------------------------------------------------------------------------------------------------------------- ;
; ChkSprtSprtKill   Function: 
;                   Parms   : xr=touched sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                           : yr=moved   sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
ChkSprtSprtKill     subroutine
                    lda CC_WaS_SpriteFlag,x         ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    and #CC_WaS_FlagDeath           ;            $10=action   $20=death          $40=dead           $80=init
                    bne ChkSprtSprtKillX
                    
                    lda #CCW_SpriteAlive
                    sta CCW_SpriteVitality          ; prepare killings
                    
                    sty CCW_SpriteWAOff
                    
                    lda CC_WaS_SpriteType,x         ; $00=Player $01=Spark $02=Force $03=Mummy $04=Beam $05=Frank
                    asl a                           ; *2
                    asl a                           ; *4
                    asl a                           ; *8
                    tay
                    lda SpriteSpriteKill,y
                    sta .___SprtTypAdrLo
                    lda SpriteSpriteKill+1,y
                    sta .___SprtTypAdrHi
                    beq .MarkDeath
                    
                    ldy CCW_SpriteWAOff
                    
.JmpSprtSprtKill    dc.b $4c                        ; jmp $3102
.___SprtTypAdrLo    dc.b $02
.___SprtTypAdrHi    dc.b $31
                    
RetSprtSprtKill     lda CCW_SpriteVitality          ; check killings
                    cmp #CCW_SpriteAlive
                    bne ChkSprtSprtKillX
                    
.MarkDeath          lda CC_WaS_SpriteFlag,x         ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    ora #CC_WaS_FlagDead            ;            $10=action   $20=death          $40=dead           $80=init
                    sta CC_WaS_SpriteFlag,x
                    
ChkSprtSprtKillX    rts
; ------------------------------------------------------------------------------------------------------------- ;
; GetSpriteData     Function: 
;                   Parms   : 
;                   Returns : xr=Sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
; ------------------------------------------------------------------------------------------------------------- ;
GetSpriteData       subroutine
                    jsr CopySpriteData              ; set shape / expand and copy sprite data of a given number to its memory location
                    
                    txa                             ; 
                    lsr a                           ; 
                    lsr a                           ; 
                    lsr a                           ; 
                    lsr a                           ; 
                    lsr a                           ; /32 - sprite no
                    sta CCW_GetSpriteDataNo         ; 
                    ldy CC_WaS_PlayerSpriteNo,x     ; 
                    lda TabColorPlayer,y            ; 
                    ldy CCW_GetSpriteDataNo         ; 
                    sta SP0COL,y                    ; VIC 2 - $D027 = Color Sprite 0(-7)
                    
NewSpriteDataX      rts
; ------------------------------------------------------------------------------------------------------------- ;
; RunIntoRoom       Function: 
;                   Parms   : xr=$00 or $01 - Player number
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
RunIntoRoom         subroutine
                    jsr GetNewSpriteWA              ; 
                    
                    ldy CCW_RunIntoRoomP_No         ; 
                    txa                             ; 
                    sta CCW_SpriteWAOffP1,y         ; 
                    
                    lda CCL_PlayersTargetDoorNo,y   ; count start: entry 00 of Room DOOR list
                    asl a                           ; *2
                    asl a                           ; *4
                    asl a                           ; *8 - length of each door entry
                    clc                             ; 
                    adc CCW_DoorDataPtrLo           ; 
                    sta CCZ_RoomItemModLo           ; 
                    lda CCW_DoorDataPtrHi           ; 
                    adc #$00                        ; 
                    sta CCZ_RoomItemModHi           ; point to players target door data
                    
                    ldy #CC_Obj_DoorInWallId        ; 
                    lda (CCZ_RoomDoorMod),y         ; door object
                    and #CC_Obj_DoorOpen            ; Bit 7: 1=door already open
                    beq .DoorClosed                 ; door not open
                    
.DoorOpen           lda #CCL_PlayerRoomInOutInit    ; 
                    ldy CCW_RunIntoRoomP_No         ; 
                    sta CCL_PlayersStatus,y         ; 
                    
                    clc                             ; 
                    ldy #CC_Obj_DoorGridCol         ; 
                    lda (CCZ_RoomDoorMod),y         ; door object
                    adc #$0b                        ; 
                    sta CC_WaS_SpritePosX,x         ; 
                    clc                             ; 
                    ldy #CC_Obj_DoorGridRow         ; 
                    lda (CCZ_RoomDoorMod),y         ; door object
                    adc #$0c                        ; 
                    sta CC_WaS_SpritePosY,x         ; 
                    
                    lda #$18                        ; offset TabPlayerRoomIn
                    sta CC_WaS_PlayerRoomIOB,x      ; offset TabPlayerRoomIO block
                    lda #$03                        ; 
                    sta CC_WaS_SpriteSeqNo,x        ; 
                    
                    lda #NoSprPlrArrRoLe            ; .hbu003. - preset left room arrival
                    sta TabIPlayerRoomLR            ; .hbu003.
                    
                    lda CC_WaS_SpritePosX,x         ; .hbu003.
                    cmp #$60                        ; .hbu003. - mid of room
                    bcc .GoSetWrkValues             ; .hbu003.
                    
                    lda #NoSprPlrArrRoRi            ; .hbu003. - set right room arrival
                    sta TabIPlayerRoomLR            ; .hbu003.

.GoSetWrkValues     jmp .SetWrkValues               ; 
                    
.DoorClosed         lda #CCL_PlayerSurvive          ; 
                    ldy CCW_RunIntoRoomP_No         ; 
                    sta CCL_PlayersStatus,y         ; 
                    
                    ldy #CC_Obj_DoorGridCol         ; 
                    lda (CCZ_RoomDoorMod),y         ; door object
                    clc                             ; 
                    adc #$06                        ; 
                    sta CC_WaS_SpritePosX,x         ; 
                    ldy #CC_Obj_DoorGridRow         ; 
                    lda (CCZ_RoomDoorMod),y         ; door object
                    clc                             ; 
                    adc #$0f                        ; 
                    sta CC_WaS_SpritePosY,x         ; 
                    
                    lda CC_WaS_SpritePosX,x         ; .hbu003.
                    cmp #$60                        ; .hbu003. - mid of room
                    bcs .GetStartRi                 ; .hbu003.
.GetStartLe         lda #NoSprPlrMovLeMin           ; .hbu003. - sprite: Player - Move Left Phase 01
                    jmp .SetStart                   ; .hbu003.
                    
.GetStartRi         lda #NoSprPlrMovRiMin           ; .hbu003. - sprite: Player - Move Right Phase 01
.SetStart           sta CC_WaS_SpriteNo,x           ; .hbu003.
                    
.SetWrkValues       lda #$03                        ; 
                    sta CC_WaS_SpriteStepX,x        ; 
                    lda #$11                        ; 
                    sta CC_WaS_SpriteStepY,x        ; 
                    
                    lda #$80                        ; 
                    sta CC_WaS_Work,x               ; 
                    
                    lda CCW_RunIntoRoomP_No         ; 
                    sta CC_WaS_PlayerSpriteNo,x     ; 
                    
                    lda #$ff                        ; 
                    sta CC_WaS_SpriteWrk,x          ; 
                    sta CC_WaS_SpriteObj,x          ; 
                    sta CC_WaS_StoreToCtrlVal,x     ; 
                    
RunIntoRoomX        jmp RoomDataSave                ; .hbu017.
; ------------------------------------------------------------------------------------------------------------- ;
; FillObjTimeFrame  Function: 
;                   Parms   : .hbu016. - yr=color number
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
FillObjTimeFrame    subroutine
                    txa                             ; 
                    pha                             ; 
                    
                    tya                             ; .hbu016. - color number
                    ldy #$07                        ; 
.ColorTimeFrame     sta ColObjTimeData,y            ; .hbu016. - color the play time now instead of player texts
                    dey                             ; .hbu016.
                    bpl .ColorTimeFrame             ; .hbu016.
                    
                    lda CCL_PlayersNumLives,x       ; .hbu018.
                    ldy #$00                        ; .hbu018. - bitmap offset
                    jsr TimeConvert                 ; 
                    
                    ldy #$01                        ; CCL_PlayersTimesSec = seconds player 1/2
                    lda (CCZ_RoomItem),y            ; 
                    ldy #$09                        ; .hbu018. - bitmap offset
                    
                    jsr TimeConvert                 ; 
                    
                    ldy #$02                        ; CCL_PlayersTimesMin = minutes player 1/2
                    lda (CCZ_RoomItem),y            ; 
                    ldy #$06                        ; .hbu018. - bitmap offset                    
                    jsr TimeConvert                 ; 
                    
                    ldy #$03                        ; CCL_PlayersTimesHrs = hours player 1/2
                    lda (CCZ_RoomItem),y            ; 
                    ldy #$03                        ; .hbu018. - bitmap offset
                    jsr TimeConvert                 ; 
                    
                    ldx CCW_TimeConvertValue        ; 
                    
FillObjTimeFrameX   pla
                    tax
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
; TimeConvert       Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
TimeConvert         subroutine
                    sta CCW_TimeConvertValue        ; 
                    
                    lda #CCW_TimeConvertIdLeft      ; 
                    sta CCW_TimeConvertId           ; 
                    
                    lda CCW_TimeConvertValue        ; 
                    lsr a                           ; 
                    lsr a                           ; 
                    lsr a                           ; 
                    lsr a                           ; isolate left bcd nibble by shifting it to the right
                    
.ShiftNibble        asl a                           ; *2
                    asl a                           ; *4
                    asl a                           ; *8 - digit tab offset 0-9
                    
                    tax                             ; 
                    
.ConvertNibble      txa                             ; 
                    and #$07                        ; .....### - clear a possibly set bit 3
                    cmp #$07                        ; 
                    beq .NextNibble                 ; all 8 bytes processed
                    
                    lda TabTimeDigitData,x          ; 
                    sta DatObjTimeData,y            ; 
                    
                    clc                             ; 
                    tya                             ; 
                    adc #$0b                        ; .hbu018. - next row position in timeframe
                    tay                             ; 
                    
                    inx                             ; next posistion in digit data tab
                    jmp .ConvertNibble              ; 
                    
.NextNibble         inc CCW_TimeConvertId           ; 
                    
                    lda CCW_TimeConvertId           ; 
                    cmp #CCW_TimeConvertIdMax       ; 
                    beq TimeConvertX                ; left and right nibbles processed
                    
                    tya                             ; 
                    sec                             ; 
                    sbc #$0b * $07 - 1              ; .hbu018. - point to start pos timeframe + $01 for right nibble
                    tay                             ; 
                    
                    lda CCW_TimeConvertValue        ; 
                    and #$0f                        ; isolate right nibble
                    jmp .ShiftNibble                ; 
                    
TimeConvertX        rts
; ------------------------------------------------------------------------------------------------------------- ;
; InitSpriteSpark   Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
InitSpriteSpark     subroutine
                    txa
                    pha
                    
                    tay
                    jsr GetNewSpriteWA
                    
                    lda #CC_WaS_SpriteSpark
                    sta CC_WaS_SpriteType,x         ; $00=Player $01=Spark $02=Force $03=Mummy $04=Beam $05=Frank
                    
                    lda CC_WaO_ObjectGridRow,y
                    clc
                    adc #$08
                    sta CC_WaS_SpritePosY,x
                    
                    lda CC_WaO_ObjectGridCol,y
                    sta CC_WaS_SpritePosX,x
                    
                    lda CC_WaO_TypLightBallNo,y
                    sta CC_WaS_Work,x
                    
                    pla
                    tax
InitSpriteSparkX    rts
; ------------------------------------------------------------------------------------------------------------- ;
; InitSpriteForce   Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
InitSpriteForce     subroutine
                    jsr GetNewSpriteWA
                    
                    lda #CC_WaS_SpriteForce
                    sta CC_WaS_SpriteType,x         ; $00=Player $01=Spark $02=Force $03=Mummy $04=Beam $05=Frank
                    
                    ldy #CC_Obj_ForceFiGridCol
                    lda ($3e),y                     ; ForceDataPtr
                    sta CC_WaS_SpritePosX,x
                    ldy #CC_Obj_ForceFiGridRow
                    lda ($3e),y                     ; ForceDataPtr
                    clc
                    adc #$02
                    sta CC_WaS_SpritePosY,x
                    
                    lda #NoSprForMov01              ; sprite: Force Field - Phase 01 (thin)
                    sta CC_WaS_SpriteNo,x
                    
                    lda CCW_ForceNo
                    sta CC_WaS_Work,x
                    
                    lda #CC_WaS_ForceClose
                    sta CC_WaS_ForceFieldMode,x
                    lda #$04
                    sta CC_WaS_SpriteSeqNo,x
                    lda #$02
                    sta CC_WaS_SpriteStepX,x
                    lda #$19
                    sta CC_WaS_SpriteStepY,x
                    
InitSpriteForceX    rts
; ------------------------------------------------------------------------------------------------------------- ;
; InitSpriteMummy   Function: 
;                   Parms   : ac<>$00 - Flag mummy out
;                           : xr=Sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
InitSpriteMummy     subroutine
                    sta CCW_MummyWallStatus
                    
                    txa
                    tay
                    jsr GetNewSpriteWA
                    
                    lda #CC_WaS_SpriteMummy
                    sta CC_WaS_SpriteType,x         ; $00=Player $01=Spark $02=Force $03=Mummy $04=Beam $05=Frank
                    
                    lda #$ff
                    sta CC_WaS_PlayerRoomIOB,x      ; offset TabPlayerRoomIO block
                    sta CC_WaS_PlayerSpriteNo,x
                    
                    lda CC_WaO_TypMummyPtrWA,y
                    sta CC_WaS_MummyDataOff,x
                    
                    clc
                    adc CCW_MummyDataPtrLo          ; saved MummyDataPtrLo
                    sta CCZ_RoomItemModLo           ; 
                    lda CCW_MummyDataPtrHi          ; saved MummyDataPtrHi
                    adc #$00
                    sta CCZ_RoomItemModHi           ; point to mummy data
                    
                    lda #$05
                    sta CC_WaS_SpriteStepX,x
                    lda #$11
                    sta CC_WaS_SpriteStepY,x
                    
                    lda #$ff
                    sta CC_WaS_SpriteNo,x
                    
                    lda CCW_MummyWallStatus
                    bne .MummyOut
                    
.MummyIn            lda #CC_WaS_MummyIn
                    sta CC_WaS_EnemyStatus,x
                    
                    lda #$ff
                    sta CC_WaS_Work,x
                    lda #$04
                    sta CC_WaS_SpriteSeqNo,x
                    
                    ldy #CC_Obj_MummyWallGridCol
                    clc
                    lda (CCZ_RoomMummyMod),y
                    adc #$0d
                    sta CC_WaS_SpritePosX,x
                    
                    clc
                    ldy #CC_Obj_MummyWallGridRow
                    lda (CCZ_RoomMummyMod),y
                    adc #$08
                    sta CC_WaS_SpritePosY,x
                    jmp InitSpriteMummyX
                    
.MummyOut           lda #CC_WaS_MummyOut
                    sta CC_WaS_EnemyStatus,x
                    
                    ldy #CC_Obj_MummySpriteCol
                    lda (CCZ_RoomMummyMod),y
                    sta CC_WaS_SpritePosX,x
                    
                    ldy #CC_Obj_MummySpriteRow
                    lda (CCZ_RoomMummyMod),y
                    sta CC_WaS_SpritePosY,x
                    
                    lda #$02
                    sta CC_WaS_SpriteSeqNo,x
                    
InitSpriteMummyX    rts
; ------------------------------------------------------------------------------------------------------------- ;
; InitSpriteBeam    Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
InitSpriteBeam      subroutine
                    txa
                    pha
                    
                    tay                    
                    clc
                    lda CC_WaO_TypGunPtrWA,y
                    adc #$07                        ; 
                    and #$f8                        ; #####...
                    lsr a                           ; .#####..
                    adc #SFX_GunShotHeight          ; 
                    sta SFX_GunShotTone             ; vary tone
                    
                    lda #NoSndGunShot               ; sound: Ray Gun Shot
                    jsr InitSoundFx
                    jsr GetNewSpriteWA
                    
                    lda #CC_WaS_SpriteBeam
                    sta CC_WaS_SpriteType,x         ; $00=Player $01=Spark $02=Force $03=Mummy $04=Beam $05=Frank
                    lda CC_WaO_ObjectGridCol,y
                    sta CC_WaS_SpritePosX,x
                    
                    clc
                    lda CC_WaO_ObjectGridRow,y
                    adc #$05
                    sta CC_WaS_SpritePosY,x
                    
                    lda #NoSprRayMov01              ; sprite: Ray Gun - Beam
                    sta CC_WaS_SpriteNo,x
                    
                    lda CC_WaO_TypGunPtrWA,y
                    sta CC_WaS_BeamWaOff,x
                    
                    ldy #CC_Obj_GunDirection
                    lda (CCZ_RoomGunMod),y          ; CC_Obj_Gun
                    and #CC_Obj_GunPointLeft        ; test direction
                    beq .MoveBeamRight
                    
.MoveBeamLeft       sec
                    lda CC_WaS_SpritePosX,x
                    sbc #$08
                    sta CC_WaS_SpritePosX,x
                    
                    lda #$fc
                    sta CC_WaS_Work,x
                    jmp .SetSpriteData
                    
.MoveBeamRight      clc
                    lda CC_WaS_SpritePosX,x
                    adc #$08
                    sta CC_WaS_SpritePosX,x
                    
                    lda #$04
                    sta CC_WaS_Work,x
                    
.SetSpriteData      jsr CopySpriteData              ; set shape / expand and copy sprite data of a given number to its memory location
                    
                    pla
                    tax
InitSpriteBeamX     rts
; ------------------------------------------------------------------------------------------------------------- ;
; InitSpriteFrank   Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
InitSpriteFrank     subroutine
                    ldy #CC_Obj_FrankCoffinDir
                    lda (CCZ_RoomFrank),y           ; frank object
                    and #CC_Obj_FrankKilled
                    bne InitSpriteFrankX            ; yes
                    
                    jsr GetNewSpriteWA
                    
.MarkSprtWA         lda #CC_WaS_SpriteFrank
                    sta CC_WaS_SpriteType,x         ; $00=Player $01=Spark $02=Force $03=Mummy $04=Beam $05=Frank
                    
.SavDataOff         lda CCW_FrankDataNext
                    sta CC_WaS_Work,x               ; store game data offset
                    
                    ldy #CC_Obj_FrankCoffinDir
                    lda (CCZ_RoomFrank),y           ; frank object
.SavStatus          sta CC_WaS_EnemyStatus,x        ; store status
                    
                    and #CC_Obj_FrankAwake          ;
                    bne .SavFrankOut
                    
.SavFrankIn         ldy #CC_Obj_FrankCoffinGridCol
                    lda (CCZ_RoomFrank),y           ; frank object
                    sta CC_WaS_SpritePosX,x
                    ldy #CC_Obj_FrankCoffinGridRow
                    lda (CCZ_RoomFrank),y           ; frank object
                    clc
                    adc #$07
                    sta CC_WaS_SpritePosY,x
                    
                    lda #NoSprFraStaCoff            ; sprite: Frank - Coffin wait
                    sta CC_WaS_SpriteNo,x
                    jmp .SetSprite
                    
.SavFrankOut        ldy #CC_Obj_FrankSpritePosX
                    lda (CCZ_RoomFrank),y           ; frank object
                    sta CC_WaS_SpritePosX,x
                    ldy #CC_Obj_FrankSpritePosY
                    lda (CCZ_RoomFrank),y           ; frank object
                    sta CC_WaS_SpritePosY,x
                    
                    ldy #CC_Obj_FrankSpriteNo
                    lda (CCZ_RoomFrank),y           ; frank object
                    sta CC_WaS_SpriteNo,x
                    
                    ldy #CC_Obj_FrankSpriteMoveDir
                    lda (CCZ_RoomFrank),y           ; frank object
                    sta CC_WaS_SpriteMoveDir,x
                    
.SetSprite          lda #$03
                    sta CC_WaS_SpriteStepX,x
                    lda #$11
                    sta CC_WaS_SpriteStepY,x
                    
                    jsr CopySpriteData              ; set shape / expand and copy sprite data of a given number to its memory location
                    
                    lda #$ff
                    sta CC_WaS_PlayerSpriteNo,x
                    sta CC_WaS_SpriteObj,x
                    sta CC_WaS_PlayerRoomIOB,x      ; offset TabPlayerRoomIO block
                    
                    lda #$02
                    sta CC_WaS_SpriteSeqNo,x
                    sta CC_WaS_SpriteSeqOld,x
                    
InitSpriteFrankX    rts
; ------------------------------------------------------------------------------------------------------------- ;
; InitColorRam       Function: Init the color ram
;                    Parms   : ac=color
;                    Returns : 
;                    Id      : .hbu015.
; ------------------------------------------------------------------------------------------------------------- ;
InitColorRam        subroutine
                    sta .ModColorRamColor           ; 
                    
                    lda #<COLORAM                   ; 
                    sta CCZ_ColorRamLo              ; 
                    lda #>COLORAM                   ; 
                    sta CCZ_ColorRamHi              ; 
                    
                    ldy #$00                        ; 
                    ldx #$04
.SetColorRamI       lda #WHITE                      ; 
.ModColorRamColor   = *-1
.SetColorRam        sta (CCZ_ColorRam),y            ; 
                    iny                             ; 
                    bne .SetColorRam                ; 
                    
                    inc CCZ_ColorRamHi              ; 
                    dex
                    bne .SetColorRam                ; 
                    
InitColorRamX       rts                             ; 
; ------------------------------------------------------------------------------------------------------------- ;
; InitHiResMap       Function: Init the hires screen and sprite work areas
;                    Parms   : 
;                    Returns : 
;                    Id      : .hbu015.
; ------------------------------------------------------------------------------------------------------------- ;
InitHiResMap        subroutine
.SetInitMap         lda #<CC_ScreenMapGfx           ; 
                    sta CCZ_ScreenHiResLo           ; 
                    lda #>CC_ScreenMapGfx           ; 
                    sta CCZ_ScreenHiResHi           ; 
                    
                    ldx #$20                        ; 
                    ldy #$00                        ; 
                    tya                             ; 
.ClrHiRes           sta (CCZ_ScreenHiRes),y         ; clear hires grafic screen at $a000 - $bff9
                    iny                             ; 
                    bne .ClrHiRes                   ; 
                    
                    inc CCZ_ScreenHiResHi           ; 
                    
                    dex                             ; 
                    bne .ClrHiRes                   ; 
                    
InitHiResMapX       jmp InitColorRam                ; ac=BLACK
; ------------------------------------------------------------------------------------------------------------- ;
; InitHiResSpriteWAs Function: Init the hires screen and sprite work areas
;                    Parms   : 
;                    Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
InitHiResSpriteWAs  subroutine
                    jsr SwitchScreenOff             ; 
                                        
.SpritesOff         lda #$00                        ; all sprites off
                    sta CCZ_SpritesEnab             ; sprites 0-7 enable
                    
.SetInitRoom        lda #<(CC_ScreenRoomGfx + $1f00); 
                    sta CCZ_ScreenHiResLo           ; 
                    lda #>(CC_ScreenRoomGfx + $1f00); 
                    sta CCZ_ScreenHiResHi           ; 
                    
.ClrHiResI          ldy #$f9                        ; amount first page (leave interrupt pointers intact)
.ClrHiResValue      lda #$00                        ; 
.ClrHiRes           sta (CCZ_ScreenHiRes),y         ; clear hires grafic screen at $e000 - $fff9
                    dey                             ; 
                    cpy #$ff                        ; 
                    bne .ClrHiRes                   ; 
                    
                    dec CCZ_ScreenHiResHi           ; 
                    lda CCZ_ScreenHiResHi           ; 
                    cmp #>CC_ScreenRoomGfx          ; 
                    bcs .ClrHiResValue              ; 
; ------------------------------------------------------------------------------------------------------------- ;
InitAllSpriteWAs    subroutine
                    ldy #$00                        ; 
.ClrSprtWrk         lda #CC_WaS_FlagInactive
                    sta CC_WaS_SpriteFlag,y         ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    tya                             ;            $10=action   $20=death          $40=dead           $80=init
                    clc                             ; 
                    adc #CC_WaS_DataLen             ; $20
                    tay                             ; 
                    bne .ClrSprtWrk                 ; 
                    
                    lda #$00                        ; 
                    sta CCW_ObjWAUseCount           ; max $20 entries a $08 bytes in object work area
                    sta CCW_RasterColorMax          ; for IRQ exit screen layout
                    sta CCW_RasterColorSav          ; for IRQ exit screen layout
                    sta CCZ_ColorBorder             ; VIC II Border Color
                    
InitHiResSpriteWAsX rts
; ------------------------------------------------------------------------------------------------------------- ;
; GetNewSpriteWA    Function: 
;                   Parms   : 
;                   Returns : xr=Sprite WA offset ($00, $20, $40, $60, $80, $a0, $c0, $e0)
; ------------------------------------------------------------------------------------------------------------- ;
GetNewSpriteWA      subroutine
                    pha                             ; initialize the work area blocks - $20 bytes each
                    tya
                    pha
                    
                    ldx #$00
.NextBlock          lda CC_WaS_SpriteFlag,x         ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    and #CC_WaS_FlagInactive
                    bne .InitI                      ; no
                    
                    txa
                    clc
                    adc #CC_WaS_DataLen             ; point to next block of data
                    tax
                    bne .NextBlock                  ; check all 8 blocks
                    
.ExitBad            sec                             ; nothing to init
                    jmp GetNewSpriteWAX
                    
.InitI              ldy #CC_WaS_DataLen             ; amount
                    lda #$00
.Init               sta CC_WaS_Common,x             ; variable block start
                    inx
                    dey
                    bne .Init
                    
                    txa
                    sec
                    sbc #CC_WaS_DataLen             ; reset to start
                    tax
                    
                    lda #CC_WaS_FlagInit            ; 
                    sta CC_WaS_SpriteFlag,x         ; 80=initialized
                    
                    lda #$01
                    sta CC_WaS_SpriteSeqOld,x
                    sta CC_WaS_SpriteSeqNo,x
                    
.ExitGood           clc                             ; a block was initialized
                    
GetNewSpriteWAX       pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
; InitObjectWA      Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
InitObjectWA        subroutine
                    pha
                    tya
                    pha
                    
                    lda CCW_ObjWAUseCount           ; max $20 entries a $08 bytes in object work area
                    cmp #CC_WaO_BlocksMax           ; 
                    bne .InitI                      ; 
                    
                    sec                             ; init failed - no free space left
                    jmp InitObjectWAX               ; exit
                    
.InitI              inc CCW_ObjWAUseCount           ; max $20 entries a $08 bytes in object work area
                    asl a                           ; *2
                    asl a                           ; *4
                    asl a                           ; *8 - entry length of 8 bytes
                    tax                             ; 
                    ldy #CC_WaO_DataLen             ; 
                    lda #$00                        ; 
.Init               sta CC_WaO_ObjectType,x         ; 
                    sta CC_WaO_Type,x               ; 
                    inx                             ; 
                    dey                             ; 
                    bne .Init                       ; 
                    
                    txa                             ; 
                    sec                             ; 
                    sbc #CC_WaO_DataLen             ; set XR to start of work area block
                    tax                             ; 
                    lda #CC_WaS_FlagInit            ; 
                    sta CC_WaO_ObjectFlag,x         ; $80=just_initialized
                    
                    clc                             ; init successfull
                    
InitObjectWAX       pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
; PaintTitleScreen  Function: Display the title screen
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
PaintTitleScreen    subroutine
                    jsr InitHiResSpriteWAs          ; initialize the hires screen and sprite work area
                    
                    lda #<RoomTitleScreen           ; level data structure of room items
                    sta CCZ_RoomItemLo              ; 
                    lda #>RoomTitleScreen           ; 
                    sta CCZ_RoomItemHi              ; 
                    
PaintTitleScreenX   jmp PaintRoomItems              ; 
; ------------------------------------------------------------------------------------------------------------- ;
; PaintMapRooms     Function: Paint the castles map of visited chambers
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
PaintMapRooms       subroutine
                    lda #<CC_LevelGameData          ; point to level room data
                    sta CCZ_MapDataLo               ; 
                    lda #>CC_LevelGameData          ; 
                    sta CCZ_MapDataHi               ; 
                    
.NextRoom           ldy #CC_Obj_RoomColor           ; 
                    lda (CCZ_MapData),y             ; 
.ChkEndOfData       bit Bit_o1oo_oooo               ; CC_Obj_RoomEoData
                    beq .ChkVisited                 ; check if room was visited already
                    
                    lda #CCZ_ResumeOff              ; .hbu015. - reset a possible resume flag 
                    sta CCZ_ResumeGame              ; .hbu015. - force repaint of all rooms after resume
.GoExit             jmp PaintMapRoomsX              ; EndOfRoom data marker set
                    
.ChkVisited         bit Bit_1ooo_oooo               ; CC_Obj_RoomVisited
                    beq .SetNextRoom                ; .hbu015. - not visited
                    
                    ldx CCZ_ResumeGame              ; .hbu015. - force repaint of all rooms after resume
                    bne .GetRoomColor               ; .hbu015.
                    
.ChkPainted         bit Bit_oo1o_oooo               ; .hbu015. - CC_Obj_RoomPainted - check if room was painted already
                    beq .SetRoomPainted             ; .hbu015. - no so mark and paint it
                    
.SetNextRoom        clc                             ; .hbu015. - all doors handled - treat next room
                    lda CCZ_MapDataLo               ; .hbu015. - 
                    adc #CC_Obj_RoomDataLen         ; .hbu015. - $08 = length of each room data entry
                    sta CCZ_MapDataLo               ; .hbu015.
                    bcc .GoNextRoom                 ; .hbu015.
                    inc CCZ_MapDataHi               ; .hbu015.
.GoNextRoom         bne .NextRoom                   ; .hbu015. - only one room must be painted now - except after a resume
                    
.SetRoomPainted     ora #CC_Obj_RoomPainted         ; .hbu015. - set painted
                    sta (CCZ_MapData),y             ; start of room definitions after the game parms
                    
.GetRoomColor       and #CC_Obj_RoomColorMask       ; ....#### - isolate colors from CC_Obj_RoomColor
                    sta ColObjMapFiller             ; Map Room: Color for Filler Square
                    
.GetRoomMapPos      ldy #CC_Obj_RoomGridCol         ; 
                    lda (CCZ_MapData),y             ; CC_Obj_RoomGridCol
                    sta CCW_MapRoomGridCol          ; 
                    ldy #CC_Obj_RoomGridRow         ; 
                    lda (CCZ_MapData),y             ; CC_Obj_RoomGridRow
                    sta CCW_MapRoomGridRow          ; 
                    
.GetRoomMapSize     ldy #CC_Obj_RoomSize            ; 
                    lda (CCZ_MapData),y             ; CC_Obj_RoomSize - Bits:  ..xx xyyy - min 2*2  max 7*7
                    and #CC_Obj_RoomSizeMax         ; isolate max Y
                    sta CCW_MapRoomRows             ; 
                    
                    lda (CCZ_MapDataLo),y           ; CC_Obj_RoomSize - Bits:  ..xx xyyy - min 2*2  max 7*7
                    lsr a                           ; shift to right 
                    lsr a                           ; 
                    lsr a                           ; 
                    and #CC_Obj_RoomSizeMax         ; isolate max X
                    sta CCW_MapRoomCols             ; 
                    
                    lda #CCZ_PntObjPrmType00        ; 
                    sta CCZ_PntObjPrmType           ; 
                    
                    lda CCW_MapRoomGridRow          ; 
                    sta CCZ_PntObj00PrmGridRow      ; 
                    lda #NoObjMapFiller             ; object: Map Room - Color Filler Square: 1*8
                    sta CCZ_PntObj00PrmNo           ; 
                    
                    lda CCW_MapRoomRows             ; 
                    sta CCW_MapRoomRowsWrk          ; 
                    
.PaintRoomI         lda CCW_MapRoomCols             ; set col and row counters
                    sta CCW_MapRoomColsWrk          ; 
                    lda CCW_MapRoomGridCol          ; 
                    sta CCZ_PntObj00PrmGridCol      ; 
                    
.PaintRoomSquare    jsr PaintObject                 ;  
                    
                    clc                             ; set next room tile column pos
                    lda CCZ_PntObj00PrmGridCol      ; 
                    adc #CC_GridWidth               ; 
                    sta CCZ_PntObj00PrmGridCol      ; 
                    
                    dec CCW_MapRoomColsWrk          ; column counter
                    bne .PaintRoomSquare            ; 
                    
                    clc                             ; set next room tile row pos
                    lda CCZ_PntObj00PrmGridRow      ; 
                    adc #CC_GridHeight              ; 
                    sta CCZ_PntObj00PrmGridRow      ; 
                    
                    dec CCW_MapRoomRowsWrk          ; row counter
                    bne .PaintRoomI                 ; init counters for next row
                    
.PaintWalls         lda CCW_MapRoomGridCol          ; 
                    sta CCZ_PntObj01PrmGridCol      ; 
                    lda CCW_MapRoomGridRow          ; 
                    sta CCZ_PntObj01PrmGridRow      ; 
                    
                    lda #CCZ_PntObjPrmType01        ; 
                    sta CCZ_PntObjPrmType           ; 
                    
PaintWallNorthI     lda CCW_MapRoomCols             ; 
                    sta CCW_MapRoomColsWrk          ; 
                    
                    lda #NoObjMapWallNS             ; object: Map Wall - n/s
                    sta CCZ_PntObj01PrmNo           ; 
                    
.PaintWallNorth     jsr PaintObject                 ; wall north
                    
                    clc                             ; set next wall tile column pos
                    lda CCZ_PntObj01PrmGridCol      ; 
                    adc #CC_GridWidth               ; 
                    sta CCZ_PntObj01PrmGridCol      ; 
                    
                    dec CCW_MapRoomColsWrk          ; 
                    bne .PaintWallNorth             ; 
                    
.PaintWallSouthI    lda CCW_MapRoomGridCol          ; 
                    sta CCZ_PntObj01PrmGridCol      ; 
                    
                    lda CCW_MapRoomRows             ; 
                    asl a                           ; *2
                    asl a                           ; *4
                    asl a                           ; *8
                    clc                             ; 
                    adc CCW_MapRoomGridRow          ; 
                    sec                             ; 
                    sbc #$03                        ; 
                    sta CCZ_PntObj01PrmGridRow      ; 
                    
                    lda CCW_MapRoomCols             ; 
                    sta CCW_MapRoomColsWrk          ; 
                    
.PaintWallSouth     jsr PaintObject                 ; 
                    
                    clc                             ; set next wall tile column pos
                    lda CCZ_PntObj01PrmGridCol      ; 
                    adc #CC_GridWidth               ; 
                    sta CCZ_PntObj01PrmGridCol      ; 
                    
                    dec CCW_MapRoomColsWrk          ; 
                    bne .PaintWallSouth             ; 
                    
.PaintWallWestI     lda CCW_MapRoomGridCol          ; 
                    sta CCZ_PntObj01PrmGridCol      ; 
                    lda CCW_MapRoomGridRow          ; 
                    sta CCZ_PntObj01PrmGridRow      ; 
                    
                    lda #NoObjMapWallW              ; object: Map Wall - w long
                    sta CCZ_PntObj01PrmNo           ; 
                    
                    lda CCW_MapRoomRows             ; 
                    sta CCW_MapRoomColsWrk          ; 
                    
.PaintWallWest      jsr PaintObject                 ; 
                    
                    clc                             ; set next wall tile row pos
                    lda CCZ_PntObj01PrmGridRow      ; 
                    adc #CC_GridHeight              ; 
                    sta CCZ_PntObj01PrmGridRow      ; 
                    
                    dec CCW_MapRoomColsWrk          ; 
                    bne .PaintWallWest              ; 
                    
.PaintWallEastI     lda CCW_MapRoomCols             ; 
                    asl a                           ; 
                    asl a                           ; 
                    clc                             ; 
                    adc CCW_MapRoomGridCol          ; 
                    sec                             ; 
                    sbc #CC_GridWidth               ; 
                    sta CCZ_PntObj01PrmGridCol      ; 
                    
                    lda CCW_MapRoomGridRow          ; 
                    sta CCZ_PntObj01PrmGridRow      ; 
                    
                    lda #NoObjMapWallE              ; object: Map Wall - e long
                    sta CCZ_PntObj01PrmNo           ; 
                    
                    lda CCW_MapRoomRows             ; 
                    sta CCW_MapRoomColsWrk          ; 
                    
.PaintWallEast      jsr PaintObject                 ; 
                    
                    clc                             ; set next wall tile row pos
                    lda CCZ_PntObj01PrmGridRow      ; 
                    adc #CC_GridHeight              ; 
                    sta CCZ_PntObj01PrmGridRow      ; 
                    
                    dec CCW_MapRoomColsWrk          ; 
                    bne .PaintWallEast              ; 
                    
                    lda #$00                        ; 
                    jsr SetRoomDoorPtr              ; 
                    
                    lda CCW_RoomTargDoorCount       ; number of doors in target room
                    sta CCW_MapRoomCount            ; 
                    
.NextDoor           ldy #CC_Obj_DoorInWallId        ; 
                    lda (CCZ_RoomDoorMod),y         ; door object
                    and #$03                        ; ......## - isolate id bits - 00=n 01=e 02=s 03=w
                    bne .ChkDoorSouth               ; e-s-w
                    
.SetDoorNPosY       lda CCW_MapRoomGridRow          ; n
                    sta CCZ_PntObj01PrmGridRow      ; 
                    jmp .SetDoorNSPosX              ; 
                    
.ChkDoorSouth       cmp #CC_Obj_DoorInWallS         ; 
                    bne .SavIsolatedId              ; e-w
                    
.SetDoorSPosY       lda CCW_MapRoomRows             ; s
                    asl a                           ; 
                    asl a                           ; 
                    asl a                           ; *8
                    clc                             ; 
                    adc CCW_MapRoomGridRow          ; 
                    sec                             ; 
                    sbc #$03                        ; 
                    sta CCZ_PntObj01PrmGridRow      ; 
                    
.SetDoorNSPosX      lda CCW_MapRoomGridCol          ; 
                    ldy #CC_Obj_DoorMapOffCol       ; 
                    clc                             ; 
                    adc (CCZ_RoomDoorMod),y         ; door object
                    sta CCZ_PntObj01PrmGridCol      ; 
.ChkDoorNSForm      and #$02                        ; ......#. - two forms
                    beq .LeftDoorNS                 ; 
                    
.RightDoorNS        eor CCZ_PntObj01PrmGridCol      ; 
                    sta CCZ_PntObj01PrmGridCol      ; 
                    
                    lda #NoObjMapDoNSRi             ; object: Map Door - N/S Right
                    jmp .SetDoorObjNo               ; 
                    
.LeftDoorNS         lda #NoObjMapDoNSLe             ; object: Map Door - N/S Left
                    jmp .SetDoorObjNo               ; 
                    
.SavIsolatedId      pha                             ; save for e-w testing
                    
                    lda CCW_MapRoomGridRow          ; 
                    clc                             ; 
                    ldy #CC_Obj_DoorMapOffRow       ; 
                    adc (CCZ_RoomDoorMod),y         ; door object
                    sta CCZ_PntObj01PrmGridRow      ; 
                    
.GetIsolatedId      pla                             ; 
                    
                    cmp #CC_Obj_DoorInWallW         ; 
                    beq .DoorW                      ; 
                    
.SetDoorEPosY       lda CCW_MapRoomCols             ; 
                    asl a                           ; *2
                    asl a                           ; *4
                    clc                             ; 
                    adc CCW_MapRoomGridCol          ; 
                    sec                             ; 
                    sbc #CC_GridWidth               ; 
                    sta CCZ_PntObj01PrmGridCol      ; 
                    
                    lda #NoObjMapDoEWRi             ; object: Map Door - E/W Right
                    jmp .SetDoorObjNo               ; 
                    
.DoorW              lda CCW_MapRoomGridCol          ; 
                    sta CCZ_PntObj01PrmGridCol      ; 
                    lda #NoObjMapDoEWLe             ; object: Map Door - E/W Left
                    
.SetDoorObjNo       sta CCZ_PntObj01PrmNo           ; 
                    
.PaintDoor          jsr PaintObject                 ; 
                    
                    clc                             ; 
                    lda CCZ_RoomItemModLo           ; 
                    adc #CC_Obj_DoorDataLen         ; 
                    sta CCZ_RoomItemModLo           ; 
                    bcc .DecRoomDoorCount           ; 
                    inc CCZ_RoomItemModHi           ; 
                    
.DecRoomDoorCount   dec CCW_MapRoomCount            ; 
                    bne .NextDoor                   ; 
                    
                    ldx CCZ_ResumeGame              ; .hbu015. - force repaint of all rooms after resume
                    beq PaintMapRoomsX              ; .hbu015.
                    
                    jmp .SetNextRoom                ; .hbu015.
                    
PaintMapRoomsX      rts                             ; 
; ------------------------------------------------------------------------------------------------------------- ;
; PaintRoom         Function: Paint a single castle chamber
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
PaintRoom           subroutine
                    jsr InitHiResSpriteWAs          ; initialize the hires screen and sprite work area
                    
.GetMoveCtrlPtr     lda #<CC_ScreenMoveCtrl         ; 
                    sta CCZ_MoveCtrlLo              ; 
                    lda #>CC_ScreenMoveCtrl         ; 
                    sta CCZ_MoveCtrlHi              ; 
                    
                    ldy #$00                        ; number of bytes
                    ldx #$08                        ; number of pages
                    lda #$00                        ; 
.ClrMoveCtrlData    sta (CCZ_MoveCtrl),y            ; init move control data
                    iny                             ; 
                    bne .ClrMoveCtrlData            ; 
                    
                    inc CCZ_MoveCtrlHi              ; 
                    dex                             ; 
                    bne .ClrMoveCtrlData            ; 
                    
                    lda CCW_RoomP1Enters            ; 
                    cmp #CCW_RoomEnterYes           ; 
                    beq .SetP1                      ; 
                    
.SetP2              ldx #$01                        ; 
                    jmp .ChkDemo                    ; 
                    
.SetP1              ldx #$00                        ; 

.ChkDemo            lda CCW_DemoFlag                ; 
                    cmp #CCW_DemoYes                ; 
                    bne .SetGameRoom                ; 
                    
.SetDemoRoom        lda CCW_DemoRoomNo              ; 
                    jmp .GetRoomDataPtr             ; 
                    
.SetGameRoom        lda CCL_PlayersTargetRoomNo,x   ; count start: entry 00 of ROOM list
                    
.GetRoomDataPtr     jsr SetRoomDataPtr              ; point to target room
                    
                    ldy #CC_Obj_RoomColor           ; target room color offset
                    lda (CCZ_RoomData),y            ; 
                    and #CC_Obj_RoomColorMask       ; ....#### - isolate colors
                    sta ColObjFloorStart            ; object: Floor Start
                    asl a                           ; 
                    asl a                           ; 
                    asl a                           ; 
                    asl a                           ; color moved to left  nibble
                    ora ColObjFloorStart            ; color set   to right niblle
                    
                    sta ColObjFloorStart            ; object: Floor Start
                    sta ColObjFloorMid              ; object: Floor Mid
                    sta ColObjFloorEnd              ; object: Floor End
                    
                    sta ColLadderPaFl01             ; object: Floor Ladder Passes
                    sta ColLadderPaFl03             ; object: Floor Ladder Passes
                    
                    sta ColObjTrapMov011            ; object: Floor Trap Door Open 01
                    sta ColObjTrapMov012            ; object: Floor Trap Door Open 01
                    sta ColObjTrapMov013            ; object: Floor Trap Door Open 01
                    
                    sta ColObjTrapMov021            ; object: Floor Trap Door Open 02
                    sta ColObjTrapMov022            ; object: Floor Trap Door Open 02
                    sta ColObjTrapMov023            ; object: Floor Trap Door Open 02
                    
                    sta ColObjTrapMov031            ; object: Floor Trap Door Open 03
                    sta ColObjTrapMov032            ; object: Floor Trap Door Open 03
                    sta ColObjTrapMov033            ; object: Floor Trap Door Open 03
                    
                    sta ColObjTrapMov041            ; object: Floor Trap Door Open 04
                    sta ColObjTrapMov042            ; object: Floor Trap Door Open 04
                    sta ColObjTrapMov043            ; object: Floor Trap Door Open 04
                    
                    sta ColObjTrapMov051            ; object: Floor Trap Door Open 05
                    sta ColObjTrapMov052            ; object: Floor Trap Door Open 05
                    sta ColObjTrapMov053            ; object: Floor Trap Door Open 05
                    
                    sta ColObjTrapMov061            ; object: Floor Trap Door Open 06
                    sta ColObjTrapMov062            ; object: Floor Trap Door Open 06
                    sta ColObjTrapMov063            ; object: Floor Trap Door Open 06
                    
                    ldy #$07                        ; 
.ColorObjSideWalk   sta ColObjWalkMov011,y          ; object: Moving Sidewalk 01
                    sta ColObjWalkMov021,y          ; object: Moving Sidewalk 02
                    sta ColObjWalkMov031,y          ; object: Moving Sidewalk 03
                    sta ColObjWalkMov041,y          ; object: Moving Sidewalk 04
                    dey                             ; 
                    bpl .ColorObjSideWalk           ; 
                    
                    and #$0f                        ; ....####
                    ora #$10                        ; ...#....
                    sta ColObjPoleCover             ; object: Front Floor Piece to Cover Pole
                    
                    lda ColObjFloorEnd              ; object: Floor End
                    and #$f0                        ; ####....
                    ora #$01                        ; .......#
                    sta ColObjLadderFl              ; object: Floor End
                    sta ColLadderPaFl02             ; object: Floor Ladder Passes
                    
.SetGameData        ldy #CC_Obj_RoomDoorIdLo        ; 
                    lda (CCZ_RoomData),y            ; 
                    sta CCZ_RoomItemLo              ; 
                    sta CCZ_RoomDataStartLo         ; .hbu017. - save original data start pointer
                    iny                             ; CC_Obj_RoomDoorIdHi
                    lda (CCZ_RoomData),y            ; point to room data
                    sta CCZ_RoomItemHi              ; point to room door id of game data $7800 (03 08)
                    sta CCZ_RoomDataStartHi         ; .hbu017. - save original data start pointer
                    
                    jsr PaintRoomItems              ; 
                    
                    lda CCZ_RoomItemLo              ; .hbu017. - save original data end pointer
                    sta CCZ_RoomDataEndLo           ; .hbu017. 
                    lda CCZ_RoomItemHi              ; .hbu017.
                    sta CCZ_RoomDataEndHi           ; .hbu017.
                    
PaintRoomsX         rts                             ; .hbu017.
; ------------------------------------------------------------------------------------------------------------- ;
; PaintText         Function: Convert a CharRom Character for Graphic Output
;                   Parms   : Output text pointer in ($3e/$3f)
;                           : CCZ_PaintText* variables filled
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
PaintText           subroutine
                    lda CCZ_PaintTextGridCol        ; 
                    sta CCZ_PntObj00PrmGridCol      ; 
                    sta CCZ_PntObj01PrmGridCol      ; 
                    lda CCZ_PaintTextGridRow        ; 
                    sta CCZ_PntObj00PrmGridRow      ; 
                    sta CCZ_PntObj01PrmGridRow      ; 
                    
                    lda #NoObjCharBack              ; object: Text - Character Background
                    sta CCZ_PntObj01PrmNo           ; 
                    lda #NoObjChar                  ; object: Text - Character
                    sta CCZ_PntObj00PrmNo           ; 
                    
                    lda #CCZ_PntObjPrmType02        ; 
                    sta CCZ_PntObjPrmType           ; 
                    
                    lda CCZ_PaintTextType           ; height: $x1=normal  $x2=double $x3=tripple view: $2x=normal $3x=reverse
                    and #$03                        ; ......## - isolate Bits 0-1 = height
                    bne .SetHeight                  ; 
                    
                    lda #$01                        ; force Bit 0=1 - normal height
.SetHeight          sta CCZ_PaintTextHeight         ; 
                    asl a                           ; *2
                    asl a                           ; *4
                    asl a                           ; *8
                    sta DatObjCharBackRo            ; rows
                    sta DatObjCharRows              ; 
                    
                    asl a                           ; *16
                    clc                             ; 
                    adc #<DatObjCharData            ; 
                    sta CCZ_CharObjectLo            ; 
                    lda #$00                        ; 
                    adc #>DatObjCharData            ; 
                    sta CCZ_CharObjectHi            ; point to DatObjChar Color Information
                    
                    ldy #$05                        ; amount
                    lda CCZ_PaintTextColor          ; 
                    asl a                           ; *2
                    asl a                           ; *4
                    asl a                           ; *8
                    asl a                           ; *16
.SetColor           sta (CCZ_CharObject),y          ; 
                    dey                             ; 
                    bpl .SetColor                   ; 
                    
.NextChr            ldy #$00                        ; 
                    lda CCZ_PaintTextType           ; 
                    and #$30                        ; ..##.... - isolate bit4-5 (view: $2x=normal $3x=reverse)
                    lsr a                           ; ...##...
                    lsr a                           ; ....##..
                    lsr a                           ; .....##. - bit1-2 (view: $x4=normal $x6=reverse)
                    tax                             ; 
                    
                    lda (CCZ_RoomText),y            ; TextDataPtr - load one character
                    and #$7f                        ; .####### - clear a poosibly set bit 7 - EndOfLine
                    sta CCZ_CharROMLo               ; 
                    lda #$00                        ; 
                    sta CCZ_CharROMHi               ; 
                    
                    asl CCZ_CharROMLo               ; *2
                    rol CCZ_CharROMHi               ; 
                    asl CCZ_CharROMLo               ; *4
                    rol CCZ_CharROMHi               ; 
                    asl CCZ_CharROMLo               ; *8
                    rol CCZ_CharROMHi               ; 
                    
                    clc                             ; 
                    lda TabRomCharSet,x             ; 
                    adc CCZ_CharROMLo               ; 
                    sta CCZ_CharROMLo               ; 
                    lda TabRomCharSet+1,x           ; 
                    adc CCZ_CharROMHi               ; 
                    sta CCZ_CharROMHi               ; point to character pos in chargen
                    
                    sei                             ; no interrupts
                    
                    ldy #$07                        ; 
                    sty D6510                       ; CPU Port Data Direction Register
                    lda #BcKoff                     ; -> basic=off char=on kernel=off
                    sta R6510                       ; CPU Port Data Register
                    
.CopyChr            lda (CCZ_CharROM),y             ; copy character matrix
                    sta CCZ_CharGenMatrix,y         ; 
                    dey                             ; 
                    bpl .CopyChr                    ; 
                    
                    lda #B_Koff                     ; -> basic=off io=on kernel=off
                    sta R6510                       ; CPU Port Data Register
                    
                    cli                             ; reallow interrupts
                    
                    ldx #$00                        ; 
                    lda #<DatObjCharData            ; 
                    sta CCZ_CharObjectLo            ; 
                    lda #>DatObjCharData            ; 
                    sta CCZ_CharObjectHi            ; 
                    
.NextChrRow         lda CCZ_CharGenMatrix,x         ; 
                    lsr a                           ; 
                    lsr a                           ; 
                    lsr a                           ; 
                    lsr a                           ; shift left nibble to right
                    and #$0f                        ; ....#### - clear left nibble
                    
                    tay                             ; 
                    lda TabTransChr2BitMap,y        ; 
                    ldy #$00                        ; 
                    sta (CCZ_CharObject),y          ; 
                    
                    lda CCZ_CharGenMatrix,x         ; 
                    and #$0f                        ; ....#### - clear left nibble
                    
                    tay                             ; 
                    lda TabTransChr2BitMap,y        ; 
                    ldy #$01                        ; 
                    sta (CCZ_CharObject),y          ; 
                    
                    lda CCZ_PaintTextHeight         ; $01=normal $02=double $03=tripple height
                    cmp #CC_Obj_TextHightDouble     ; check double height
                    bcs .ChkDouble                  ; greater/equal
                    
.Normal             lda #$02                        ; single offset
                    jmp .Single                     ; 
                    
.ChkDouble          bne .Tripple                    ; greater
                    
.Double             ldy #$00                        ; equal
                    lda (CCZ_CharObject),y          ; 
                    ldy #$02                        ; 
                    sta (CCZ_CharObject),y          ; 
                    
                    ldy #$01                        ; 
                    lda (CCZ_CharObject),y          ; 
                    ldy #$03                        ; 
                    sta (CCZ_CharObject),y          ; 
                    
                    lda #$04                        ; double offset
                    jmp .Single                     ; 
                    
.Tripple            ldy #$00                        ; 
                    lda (CCZ_CharObject),y          ; 
                    ldy #$02                        ; 
                    sta (CCZ_CharObject),y          ; 
                    ldy #$04                        ; 
                    sta (CCZ_CharObject),y          ; 
                    
                    ldy #$01                        ; 
                    lda (CCZ_CharObject),y          ; 
                    ldy #$03                        ; 
                    sta (CCZ_CharObject),y          ; 
                    ldy #$05                        ; 
                    sta (CCZ_CharObject),y          ; 
                    
                    lda #$06                        ; tripple offset
.Single             clc                             ; 
                    adc CCZ_CharObjectLo            ; 
                    sta CCZ_CharObjectLo            ; 
                    bcc .SetNextChrRow              ; 
                    inc CCZ_CharObjectHi            ; 
                    
.SetNextChrRow      inx                             ; 
                    cpx #$08                        ; 
                    bcc .NextChrRow                 ; 
                    
.PaintChr           jsr PaintObject                 ; 
                    
                    ldy #$00                        ; 
                    lda (CCZ_RoomText),y            ; text object
                    bmi .Exit                       ; 
                    
                    inc CCZ_RoomItemLo              ; 
                    bne .SetNextPaintPos            ; 
                    inc CCZ_RoomItemHi              ; 
                    
.SetNextPaintPos    clc                             ; 
                    lda CCZ_PntObj00PrmGridCol      ; 
                    adc #CC_GridWidth * 2           ; 
                    sta CCZ_PntObj00PrmGridCol      ; 
                    sta CCZ_PntObj01PrmGridCol      ; 
                    jmp .NextChr                    ; 
                    
.Exit               inc CCZ_RoomItemLo              ; 
                    bne PaintTextX                  ; 
                    inc CCZ_RoomItemHi              ; 
                    
PaintTextX          rts
; ------------------------------------------------------------------------------------------------------------- ;
; ColorGunSwitch    Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
ColorGunSwitch      subroutine
                    sta CCW_GunSwitchColor
                    
                    lda CCW_GunSwitchColor
                    sta ColObjGunOper01
                    sta ColObjGunOper02
                    
                    ldy #CC_Obj_GunSwitchGridCol
                    lda (CCZ_RoomGunMod),y
                    sta CCZ_PntObj00PrmGridCol
                    ldy #CC_Obj_GunSwitchGridRow
                    lda (CCZ_RoomGunMod),y
                    sta CCZ_PntObj00PrmGridRow
                    
                    lda #CCZ_PntObjPrmType00
                    sta CCZ_PntObjPrmType  
                    lda #NoObjGunOper               ; object: Ray Gun: Operator
                    sta CCZ_PntObj00PrmNo
                    
.TopArrow           jsr PaintObject
                    
                    lda CCW_GunSwitchColor
                    asl a
                    asl a
                    asl a
                    asl a                           ; move right to left nibble / right nibble = $0
                    sta ColObjGunOper01
                    sta ColObjGunOper02
                    
                    clc
                    lda CCZ_PntObj00PrmGridRow
                    adc #$10
                    sta CCZ_PntObj00PrmGridRow
                    
ColorGunSwitchX     jmp PaintObject
; ------------------------------------------------------------------------------------------------------------- ;
; ColorXmitBackWall Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
ColorXmitBackWall   subroutine
                    sta CCW_XmitBoothColorBack
                    
                    lda CCW_XmitBoothColorBack
                    asl a
                    asl a
                    asl a
                    asl a
                    ora #LT_RED
                    
                    sta ColObjXmitBack01
                    sta ColObjXmitBack02
                    sta ColObjXmitBack03
                    
                    lda #$0f
                    sta ColObjXmitBack04
                    sta ColObjXmitBack05
                    sta ColObjXmitBack06
                    
                    lda CC_WaO_TypXmitDataPtrLo,x   ; saved MatterDataPtrLo
                    sta CCZ_RoomItemModLo
                    lda CC_WaO_TypXmitDataPtrHi,x   ; saved MatterDataPtrHi
                    sta CCZ_RoomItemModHi           ; point to matter transmitter data
                    
                    ldy #CC_Obj_XmitBoothGridCol
                    lda (CCZ_RoomMatterMod),y
                    clc
                    adc #CC_GridWidth
                    sta CCZ_PntObj00PrmGridCol
                    ldy #CC_Obj_XmitBoothGridRow
                    lda (CCZ_RoomMatterMod),y
                    sta CCZ_PntObj00PrmGridRow
                    
                    lda #CCZ_PntObjPrmType00
                    sta CCZ_PntObjPrmType  
                    lda #NoObjXmitBack              ; object: Matter Transmitter Booth Back Wall
                    sta CCZ_PntObj00PrmNo
                    
.PaintBackWall      jsr PaintObject
                    
                    clc
                    lda CCZ_PntObj00PrmGridRow
                    adc #CC_GridHeight
                    sta CCZ_PntObj00PrmGridRow
                    lda #$01
                    sta ColObjXmitBack04
                    sta ColObjXmitBack05
                    sta ColObjXmitBack06
                    
                    jsr PaintObject
                    
                    clc
                    lda CCZ_PntObj00PrmGridRow
                    adc #CC_GridHeight
                    sta CCZ_PntObj00PrmGridRow
                    
ColorXmitBackWallX  jmp PaintObject
; ------------------------------------------------------------------------------------------------------------- ;
; PaintSingleChar   Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
PaintSingleChar     subroutine
                    lda CCW_GetInputCursor          ; 
                    ora #$80                        ; reverse on/off
                    sta CCW_GetInputCursor          ; 
                    
                    lda #<CCW_GetInputCursor        ; 
                    sta CCZ_RoomItemLo              ; 
                    lda #>CCW_GetInputCursor        ; 
                    sta CCZ_RoomItemHi              ; 
                    
PaintSingleCharX    jmp PaintText                   ; 
; ------------------------------------------------------------------------------------------------------------- ;
; PaintWAObjTyp0    Function: Paint a object work area object of type 0 (with color info)
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
PaintWAObjTyp0      subroutine
                    lda CC_WaO_ObjectFlag,x         ; 
                    and #CC_WaO_Init                ; just initialized
                    bne .SetType00                  ; 
                    
.SetType02          lda #CCZ_PntObjPrmType02        ; 
                    sta CCZ_PntObjPrmType           ; 
                    lda CC_WaO_ObjectGridCol,x      ; 
                    sta CCZ_PntObj01PrmGridCol      ; 
                    lda CC_WaO_ObjectGridRow,x      ; 
                    sta CCZ_PntObj01PrmGridRow      ; 
                    lda CC_WaO_ObjectNo,x           ; 
                    sta CCZ_PntObj01PrmNo           ; 
                    jmp .Paint                      ; 
                    
.SetType00          lda #CCZ_PntObjPrmType00        ; 
                    sta CCZ_PntObjPrmType           ; 
                    
.Paint              jsr PaintObject                 ; 
                    
                    lda #CC_WaO_Init                ; 
                    eor #$ff                        ; 
                    and CC_WaO_ObjectFlag,x         ; 
                    sta CC_WaO_ObjectFlag,x         ; 
                    
                    lda CCZ_PntObj00PrmNo           ; 
                    sta CC_WaO_ObjectNo,x           ; 
                    
                    lda CCZ_PntObj00PrmGridCol      ; 
                    sta CC_WaO_ObjectGridCol,x      ; 
                    
                    lda CCZ_PntObj00PrmGridRow      ; 
                    sta CC_WaO_ObjectGridRow,x      ; 
                    
                    lda CCZ_PntObj00Cols            ; 
                    sta CC_WaO_ObjectCols,x         ; 
                    
                    lda CCZ_PntObj00Rows            ; 
                    sta CC_WaO_ObjectRows,x         ; 
                    asl CC_WaO_ObjectCols,x         ; *2
                    asl CC_WaO_ObjectCols,x         ; *4
                    
PaintWAObjTyp0X     rts
; ------------------------------------------------------------------------------------------------------------- ;
; PaintWAObjTyp1    Function: Paint a object work area object of type 0 (without color info)
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
PaintWAObjTyp1      subroutine
                    lda CC_WaO_ObjectFlag,x         ; 
                    and #CC_WaO_Init                ; just initialized - CC_WaO_Init
                    bne PaintWAObjTyp1X             ; 
                    
                    lda #CCZ_PntObjPrmType01        ; 
                    sta CCZ_PntObjPrmType           ; 
                    lda CC_WaO_ObjectNo,x           ; 
                    sta CCZ_PntObj01PrmNo           ; 
                    lda CC_WaO_ObjectGridCol,x      ; 
                    sta CCZ_PntObj01PrmGridCol      ; 
                    lda CC_WaO_ObjectGridRow,x      ; 
                    sta CCZ_PntObj01PrmGridRow      ; 
                    
                    jsr PaintObject                 ; 
                    
                    lda CC_WaO_ObjectFlag,x         ; 
                    ora #CC_WaO_Init                ; just initialized - CC_WaO_Init
                    sta CC_WaO_ObjectFlag,x         ; 
                    
PaintWAObjTyp1X     rts
; ------------------------------------------------------------------------------------------------------------- ;
; PaintObject       Function: Paint all objects of type any type - 00=with color info 01=without color info 02=
;                   Parms   : PaintParmArea filled with some good values
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
PaintObject         subroutine
                    pha                             ; 
                    tya                             ; 
                    pha                             ; 
                    txa                             ; 
                    pha                             ; 
                    
.ChkTypes01         lda CCZ_PntObjPrmType           ;   
                    cmp #CCZ_PntObjPrmType00        ; 
                    bne .Type01or02                 ; 
                    
                    jmp .Type00                     ; 
                    
.Type01or02         lda CCZ_PntObj01PrmNo           ; 
                    sta CCZ_ObjAdrListLo            ; 
                    lda #$00                        ; 
                    sta CCZ_ObjAdrListHi            ; 
                    
                    asl CCZ_ObjAdrListLo            ; address list pointer *2
                    rol CCZ_ObjAdrListHi            ; 
                    clc                             ; 
                    lda CCZ_ObjAdrListLo            ; add base address object address list
                    adc #<TabObjectDataPtr          ; 
                    sta CCZ_ObjAdrListLo            ; 
                    lda CCZ_ObjAdrListHi            ; 
                    adc #>TabObjectDataPtr          ; 
                    sta CCZ_ObjAdrListHi            ; point to object data pointer
                    
                    ldy #$00                        ; 
                    lda (CCZ_ObjAdrList),y          ; 
                    sta CCZ_ObjDataTyp12Lo          ; 
                    iny                             ; 
                    lda (CCZ_ObjAdrList),y          ; 
                    sta CCZ_ObjDataTyp12Hi          ; point to type 1 or 2 object data
                    
                    ldy #$00
                    lda (CCZ_ObjDataTyp12),y        ; type 1 or 2 object data
                    sta CCZ_PntObj01Cols            ; 
                    ldy #$01                        ; 
                    lda (CCZ_ObjDataTyp12),y        ; type 1 or 2 object data
                    sta CCZ_PntObj01Rows            ; 
                    sta CCZ_PntObj01RowsWrk         ; 
                    
                    clc                             ; 
                    lda CCZ_PntObj01PrmGridRow      ; 
                    adc CCZ_PntObj01Rows            ; 
                    sta CCZ_PntObj01RowsMax         ; 
                    
                    dec CCZ_PntObj01RowsMax         ; 
                    
                    sec                             ; 
                    lda CCZ_PntObj01PrmGridCol      ; 
                    sbc #$10                        ; 
                    bcs .SameObj1Row                ; 
                    
                    sta CCZ_PntObj01ColStart        ; PosX - $10
                    lda #$ff                        ; 
                    jmp .SetObj1UFlow               ; 
                    
.SameObj1Row        sta CCZ_PntObj01ColStart        ; PosX - $10
                    
                    lda #$00                        ; 
.SetObj1UFlow       sta CCZ_PntObj01ColEndX         ; 
                    
                    lda CCZ_PntObj01ColStart        ; PosX - $10
                    lsr a                           ; /2
                    lsr a                           ; /4
                    sta CCZ_PntObj01ColEnd          ; 
                    
                    lda CCZ_PntObj01ColEndX         ; 
                    and #$c0                        ; ##......
                    ora CCZ_PntObj01ColEnd          ; 
                    sta CCZ_PntObj01ColEnd          ; 
                    
                    asl CCZ_PntObj01ColStart        ; *2 - PosX - $10
                    rol CCZ_PntObj01ColEndX         ; 
                    
                    clc                             ; 
                    lda CCZ_PntObj01ColEnd          ; 
                    adc CCZ_PntObj01Cols            ; 
                    sta CCZ_PntObj01ColWrk          ; 
                    
                    dec CCZ_PntObj01ColWrk          ; 
                    
                    lda #CCZ_PntObjOff              ; 
                    sta CCZ_PntObj01Switch          ; 
                    
                    clc                             ; 
                    lda CCZ_ObjDataTyp12Lo          ; 
                    adc #$03                        ; object header length
                    sta CCZ_ObjDataTyp12Lo          ; 
                    bcc .ChkTypes02                 ; 
                    inc CCZ_ObjDataTyp12Hi          ; point to type 1 or 2 object data
                    
.ChkTypes02         lda CCZ_PntObjPrmType           ; 
                    cmp #CCZ_PntObjPrmType01        ; 
                    bne .Type00                     ; 
                    
                    jmp .GetObj1PrmY01              ; 
                    
.Type00             lda CCZ_PntObj00PrmNo           ; object number
                    sta CCZ_ObjAdrListLo            ; 
                    lda #$00                        ; 
                    sta CCZ_ObjAdrListHi            ; 
                    
                    asl CCZ_ObjAdrListLo            ; address list pointer * 2
                    rol CCZ_ObjAdrListHi            ; 
                    
                    clc                             ; add base address object address list
                    lda CCZ_ObjAdrListLo            ; 
                    adc #<TabObjectDataPtr          ; 
                    sta CCZ_ObjAdrListLo            ; 
                    lda CCZ_ObjAdrListHi            ; 
                    adc #>TabObjectDataPtr          ; 
                    sta CCZ_ObjAdrListHi            ; point to object data pointer
                    
                    ldy #$00                        ; 
                    lda (CCZ_ObjAdrList),y          ; 
                    sta CCZ_ObjDataTyp0Lo           ; 
                    iny                             ; 
                    lda (CCZ_ObjAdrList),y
                    sta CCZ_ObjDataTyp0Hi           ; point to type 0 object data
                    
                    ldy #$00
                    lda (CCZ_ObjDataTyp0),y         ; point to type 0 object data
                    sta CCZ_PntObj00Cols            ; 
                    ldy #$01
                    lda (CCZ_ObjDataTyp0),y         ; point to type 0 object data
                    sta CCZ_PntObj00Rows            ; 
                    sta CCZ_PntObj00RowsWrk         ; 
                    
                    clc                             ; 
                    lda CCZ_PntObj00PrmGridRow      ; 
                    adc CCZ_PntObj00Rows            ; 
                    sta CCZ_PntObj00RowsMax         ; 
                    
                    dec CCZ_PntObj00RowsMax         ; 
                    
                    sec                             ; 
                    lda CCZ_PntObj00PrmGridCol      ; 
                    sbc #$10                        ; 
                    bcs .SameObj0Row                ; 
                    
                    sta CCZ_PntObj00ColStart        ; PosX - $10
                    lda #$ff                        ; 
                    jmp .SetObj0UFlow               ; 
                    
.SameObj0Row        sta CCZ_PntObj00ColStart        ; PosX - $10
                    lda #$00                        ; 
.SetObj0UFlow       sta CCZ_PntObj00ColEndX         ; $00 or $ff
                    
                    lda CCZ_PntObj00ColStart        ; PosX - $10
                    lsr a                           ; *2
                    lsr a                           ; *4
                    sta CCZ_PntObj00ColEnd          ; 
                    
                    lda CCZ_PntObj00ColEndX         ; $00 or $ff
                    and #$c0                        ; ##......
                    ora CCZ_PntObj00ColEnd          ; 
                    sta CCZ_PntObj00ColEnd          ; 
                    
                    asl CCZ_PntObj00ColStart        ; *2 - PosX - $10
                    rol CCZ_PntObj00ColEndX         ; $00 or $ff => *2
                    
                    clc                             ; 
                    lda CCZ_PntObj00ColEnd          ; 
                    adc CCZ_PntObj00Cols            ; 
                    sta CCZ_PntObj00ColWrk          ; 
                    
                    dec CCZ_PntObj00ColWrk          ; 
                    
                    lda #CCZ_PntObjOff              ; 
                    sta CCZ_PntObj00Switch          ; 
                    
                    clc                             ; 
                    lda CCZ_ObjDataTyp0Lo           ; 
                    adc #$03                        ; object header length
                    sta CCZ_ObjDataTyp0Lo           ; 
                    bcc .GetPrmPosY
                    inc CCZ_ObjDataTyp0Hi           ; point to type 0 object data
                    
.GetPrmPosY         lda CCZ_PntObj00PrmGridRow      ; 
                    sta CCZ_PntObj00GridRow         ; 
                    cmp #$dc                        ; 
                    bcs .GetPosYFF                  ; 
                    
                    lda #$00                        ; 
                    jmp .SetPosYTo38                ; 
                    
.GetPosYFF          lda #$ff                        ; 
.SetPosYTo38        sta CCZ_PntObjTemp              ; 
                    
                    lsr CCZ_PntObjTemp              ; /2
                    ror CCZ_PntObj00GridRow         ; 
                    lsr CCZ_PntObjTemp              ; /4
                    ror CCZ_PntObj00GridRow         ; 
                    lsr CCZ_PntObjTemp              ; /8
                    ror CCZ_PntObj00GridRow         ; 
                    
                    lda CCZ_PntObj00Rows            ; 
                    sec                             ; 
                    sbc #$01                        ; 
                    lsr a                           ; /2
                    lsr a                           ; /4
                    lsr a                           ; /8
                    
                    clc                             ; 
                    adc CCZ_PntObj00GridRow         ; 
                    sta CCZ_PntObj00GridRowMax      ; 
                    
                    lda CCZ_PntObj00GridRow         ; 
                    bpl .GetCtrlScrnRow             ; 
                    
                    lda #$00                        ; 
                    sec                             ; 
                    sbc CCZ_PntObj00GridRow         ; 
                    
.GetCtrlScrnRow     tax                             ; 
                    lda TabCtrlScrRowsLo,x          ; 
                    sta CCW_CtrlScrRowsLo           ; 
                    lda TabCtrlScrRowsHi,x          ; 
                    sta CCW_CtrlScrRowsHi           ; 
                    
                    lda CCZ_PntObj00GridRow         ; 
                    bpl .GetPrmPosX                 ; 
                    
                    sec                             ; 
                    lda #$00                        ; 
                    sbc CCW_CtrlScrRowsLo           ; 
                    sta CCW_CtrlScrRowsLo           ; 
                    lda #$00                        ; 
                    sbc CCW_CtrlScrRowsHi           ; 
                    sta CCW_CtrlScrRowsHi           ; 
                    
.GetPrmPosX         lda CCZ_PntObj00PrmGridCol      ; 
                    sec                             ; 
                    sbc #$10                        ; 
                    sta CCZ_CtrlScreenRowLo         ; 
                    bcs .GetPosX00                  ; 
                    
                    lda #$ff                        ; 
                    jmp .SetPosXTo39                ; 
                    
.GetPosX00          lda #$00                        ; 
.SetPosXTo39        sta CCZ_CtrlScreenRowHi         ; 
                    
                    lsr CCZ_CtrlScreenRowHi         ; /2
                    ror CCZ_CtrlScreenRowLo         ; 
                    lsr CCZ_CtrlScreenRowHi         ; /4
                    ror CCZ_CtrlScreenRowLo         ; 
                    
                    sta CCZ_CtrlScreenRowHi         ; 
                    
                    clc                             ; 
                    lda CCW_CtrlScrRowsLo           ; 
                    adc CCZ_CtrlScreenRowLo         ; (object PosX - $10) / 4
                    sta CCW_CtrlScrRowsLo           ; 
                    lda CCW_CtrlScrRowsHi           ; 
                    adc CCZ_CtrlScreenRowHi         ; 
                    sta CCW_CtrlScrRowsHi           ; 
                    
.ChkType02          lda CCZ_PntObjPrmType           ; 
                    cmp #CCZ_PntObjPrmType02        ; 
                    beq .GetObj0PrmY02              ; 
                    
                    cmp #$00                        ; 
                    bne .GetObj1PrmY01              ; 
                    
.GetType0PrmY01     lda CCZ_PntObj00PrmGridRow      ; 
                    sta CCZ_PntObjGridRow           ; 
                    
                    lda CCZ_PntObj00RowsMax         ; 
                    sta CCZ_PntObjGridRowMax        ; 
                    
                    jmp .GetNextObjectRow           ; 
                    
.GetObj1PrmY01      lda CCZ_PntObj01PrmGridRow      ; 
                    sta CCZ_PntObjGridRow           ; 
                    
                    lda CCZ_PntObj01RowsMax         ; 
                    sta CCZ_PntObjGridRowMax        ; 
                    
                    jmp .GetNextObjectRow           ; 
                    
.GetObj0PrmY02      lda CCZ_PntObj00PrmGridRow      ; 
                    cmp CCZ_PntObj01PrmGridRow      ; 
                    beq .GetObj0PrmY03              ; 
                    
                    bcc .ChkType1Max                ; 
                    
                    cmp #$dc                        ; 
                    bcc .GetObj1PrmY02              ; 
                    
                    lda CCZ_PntObj01PrmGridRow      ; 
                    cmp #$dc                        ; 
                    bcs .GetObj1PrmY02              ; 
                    
                    jmp .GetObj0PrmY03              ; 
                    
.ChkType1Max        lda CCZ_PntObj01PrmGridRow      ; 
                    cmp #$dc                        ; 
                    bcc .GetObj0PrmY03              ; 
                    
                    lda CCZ_PntObj00PrmGridRow      ; 
                    cmp #$dc                        ; 
                    bcs .GetObj0PrmY03              ; 
                    
.GetObj1PrmY02      lda CCZ_PntObj01PrmGridRow      ; 
                    jmp .SetObj0PrmY03              ; 
                    
.GetObj0PrmY03      lda CCZ_PntObj00PrmGridRow      ; 
.SetObj0PrmY03      sta CCZ_PntObjGridRow           ; 
                    
                    lda CCZ_PntObj00RowsMax         ; 
                    cmp CCZ_PntObj01RowsMax         ; 
                    beq .GetObj1SavYY02             ; 
                    
                    bcc .GetObj1SavYY01             ; 
                    
                    cmp #$dc                        ; 
                    bcc .GetObj0SavYY               ; 
                    
                    lda CCZ_PntObj01RowsMax         ; 
                    cmp #$dc                        ; 
                    bcc .GetObj1SavYY02             ; 
                    
                    jmp .GetObj0SavYY               ; 
                    
.GetObj1SavYY01     lda CCZ_PntObj01RowsMax         ; 
                    cmp #$dc                        ; 
                    bcc .GetObj1SavYY02             ; 
                    
                    lda CCZ_PntObj00RowsMax         ; 
                    cmp #$dc                        ; 
                    bcs .GetObj1SavYY02             ; 
                    
.GetObj0SavYY       lda CCZ_PntObj00RowsMax         ; 
                    sta CCZ_PntObjGridRowMax        ; 
                    jmp .GetNextObjectRow           ; 
                    
.GetObj1SavYY02     lda CCZ_PntObj01RowsMax         ; 
                    sta CCZ_PntObjGridRowMax        ; 
                    
.GetNextObjectRow   lda CCZ_PntObjGridRow           ; loop through rows
                    sta CCZ_PntObjRowsWrk           ; 
                    
.GetHiResPtr        tax                             ; 
                    lda CC_TabHiResRowLo,x          ; hires screen row (PosY)
                    sta CCZ_ObjHiResRowLo           ; 
                    lda CC_TabHiResRowHi,x          ; hires screen row (PosY)
                    
                    sec                             ; .hbu015.
.SetHiResPtrMap     sbc #$00                        ; .hbu015.
ModObjectData       = *-1                           ; .hbu015.
                    
.SetHiResPtrRoom    sta CCZ_ObjHiResRowHi           ; point to hires screen graphic output row
                    
.AllObjectsOut      lda CCZ_PntObjPrmType           ; 
                    cmp #CCZ_PntObjPrmType00        ; 
                    beq .ChkType01_01               ; 
                    
                    lda CCZ_PntObj01RowsWrk         ; 
                    beq .ChkType01_01               ; 
                    
                    lda CCZ_PntObj01Switch          ; 
                    cmp #CCZ_PntObjOn               ; 
                    beq .DecObj1Rows                ; 
                    
                    lda CCZ_PntObjRowsWrk           ; 
                    cmp CCZ_PntObj01PrmGridRow      ; 
                    bne .ChkType01_01               ; 
                    
                    lda #CCZ_PntObjOn               ; 
                    sta CCZ_PntObj01Switch          ; 
                    
.DecObj1Rows        dec CCZ_PntObj01RowsWrk         ; 
                    lda CCZ_PntObjRowsWrk           ; 
                    cmp #$c8                        ; 
                    bcs .NextObj1Col                ; 
                    
                    lda CCZ_PntObj01ColEnd          ; 
                    sta CCZ_PntObjGridCol           ; 
                    
                    clc                             ; 
                    lda CCZ_ObjHiResRowLo           ; point to hires screen graphic output row
                    adc CCZ_PntObj01ColStart        ; PosX - $10
                    sta CCZ_ObjHiResOutLo           ; 
                    lda CCZ_ObjHiResRowHi           ; 
                    adc CCZ_PntObj01ColEndX         ; 
                    sta CCZ_ObjHiResOutHi           ; 
                    
                    ldy #$00                        ; 
.ChkObj1ColMax      lda CCZ_PntObjGridCol           ; 
                    cmp #$28                        ; max $28 (40) columns per row
                    bcs .ChkCntObj1PosX             ; 
                    
.Type1ObjectOut     lda (CCZ_ObjDataTyp12),y        ; (30/31) points to object type 1 or 2 data
                    eor #$ff                        ; 
                    and (CCZ_ObjHiResOut),y         ; 
                    sta (CCZ_ObjHiResOut),y         ; point to hires screen graphic output col
                    
.ChkCntObj1PosX     lda CCZ_PntObjGridCol           ; 
                    cmp CCZ_PntObj01ColWrk          ; 
                    beq .NextObj1Col                ; 
                    
                    clc                             ; 
                    lda CCZ_ObjHiResOutLo           ; 
                    adc #$07                        ; next block
                    sta CCZ_ObjHiResOutLo           ; 
                    bcc .IncObj1PosX                ; 
                    inc CCZ_ObjHiResOutHi           ; point to hires screen graphic output col
                    
.IncObj1PosX        inc CCZ_PntObjGridCol           ; 
                    iny                             ; 
                    jmp .ChkObj1ColMax              ; 
                    
.NextObj1Col        clc                             ; 
                    lda CCZ_ObjDataTyp12Lo          ; 
                    adc CCZ_PntObj01Cols            ; 
                    sta CCZ_ObjDataTyp12Lo          ; 
                    bcc .ChkType01_01               ; 
                    inc CCZ_ObjDataTyp12Hi          ; 
                    
.ChkType01_01       lda CCZ_PntObjPrmType           ; 
                    cmp #CCZ_PntObjPrmType01        ; 
                    beq .ChkObj0YY                  ; 
                    
                    lda CCZ_PntObj00RowsWrk         ; 
                    beq .ChkObj0YY                  ; 
                    
                    lda CCZ_PntObj00Switch          ; 
                    cmp #CCZ_PntObjOn               ; 
                    beq .DecWrkObj0Rows             ; 
                    
                    lda CCZ_PntObjRowsWrk           ; 
                    cmp CCZ_PntObj00PrmGridRow      ; 
                    bne .ChkObj0YY                  ; 
                    
                    lda #CCZ_PntObjOn               ; 
                    sta CCZ_PntObj00Switch          ; 
                    
.DecWrkObj0Rows     dec CCZ_PntObj00RowsWrk         ; 
                    lda CCZ_PntObjRowsWrk           ; 
                    cmp #$c8                        ; 
                    bcs .NextTyp0DataCol            ; 
                    
                    lda CCZ_PntObj00ColEnd          ; 
                    sta CCZ_PntObjGridCol           ; 
                    
                    lda CCZ_ObjHiResRowLo           ; point to hires screen graphic output row
                    clc                             ; 
                    adc CCZ_PntObj00ColStart        ; PosX - $10
                    sta CCZ_ObjHiResOut             ; 
                    lda CCZ_ObjHiResRowHi           ; 
                    adc CCZ_PntObj00ColEndX         ; $00 or $ff
                    sta CCZ_ObjHiResOutHi           ; point to hires screen graphic output col
                    
                    ldy #$00                        ; 
.ChkTyp0MaxPosX     lda CCZ_PntObjGridCol           ; 
                    cmp #$28                        ; max $28 (40) columns per row
                    bcs .ChkTyp0PosX                ; 
                    
.Type0ObjectOut     lda (CCZ_ObjDataTyp0),y         ; point to object type 0 data
                    ora (CCZ_ObjHiResOut),y         ; 
                    sta (CCZ_ObjHiResOut),y         ; point to hires screen graphic output col
                    
.ChkTyp0PosX        lda CCZ_PntObjGridCol           ; 
                    cmp CCZ_PntObj00ColWrk          ; 
                    beq .NextTyp0DataCol            ; 
                    
.NextTyp0OutCol     clc                             ; 
                    lda CCZ_ObjHiResOutLo           ; 
                    adc #$07                        ; 
                    sta CCZ_ObjHiResOutLo           ; 
                    bcc .NextColPosX                ; 
                    inc CCZ_ObjHiResOutHi           ; point to hires screen graphic output col
                    
.NextColPosX        iny                             ; 
                    inc CCZ_PntObjGridCol           ; 
                    jmp .ChkTyp0MaxPosX             ; 
                    
.NextTyp0DataCol    clc                             ; 
                    lda CCZ_ObjDataTyp0Lo           ; 
                    adc CCZ_PntObj00Cols            ; 
                    sta CCZ_ObjDataTyp0Lo           ; 
                    bcc .ChkObj0YY                  ; 
                    inc CCZ_ObjDataTyp0Hi           ; (32/33) points to object type 0 data
                    
.ChkObj0YY          lda CCZ_PntObjRowsWrk           ; 
                    cmp CCZ_PntObjGridRowMax        ; 
                    beq .AllObjectsFin              ; finished
                    
                    inc CCZ_PntObjRowsWrk           ; 
                    
                    lda CCZ_PntObjRowsWrk           ; 
                    and #$07                        ; 
                    beq .SetNextHiresRow            ; 
                    
.SetNextHiresCol    inc CCZ_ObjHiResRowLo           ; point to hires screen graphic output row
                    bne .GoAllObjectsOut            ; 
                    inc CCZ_ObjHiResRowHi           ; point to next hires column in row
                    jmp .GoAllObjectsOut            ; 
                    
.SetNextHiresRow    clc                             ; 
                    lda CCZ_ObjHiResRowLo           ; point to hires screen graphic output row
                    adc #$39                        ; 
                    sta CCZ_ObjHiResRowLo           ; 
                    lda CCZ_ObjHiResRowHi           ; 
                    adc #$01                        ; $140 bytes for each multicolor row 
                    sta CCZ_ObjHiResRowHi           ; 
                    
.GoAllObjectsOut    jmp .AllObjectsOut
                    
.AllObjectsFin      = *
; ------------------------------------------------------------------------------------------------------------- ;
HandleObj0Colors    subroutine
                    lda CCZ_PntObjPrmType           ; 
                    cmp #CCZ_PntObjPrmType01        ; 
                    bne Obj0VideoColors             ; only for objects of type 0
                    
                    jmp PaintObjectX                ; 
; ------------------------------------------------------------------------------------------------------------- ;
Obj0VideoColors     subroutine
                    lda CCZ_PntObj00PrmGridRow      ; spread compressed color info to video ram
                    and #$07                        ; 
                    beq .GetSwitch00_01             ; 
                    
.GetSwitch01_01     lda #$01                        ; 
                    jmp .SetSwitch_01               ; 
                    
.GetSwitch00_01     lda #$00                        ; 
.SetSwitch_01       sta CCZ_PntObj00SwColor         ; 
                    
                    lda CCZ_PntObj00GridRow         ; 
                    sta CCZ_PntObjRowsWrk           ; 
                    
.SetColorPtrRoom    clc                             ; 
                    lda #<CC_ScreenRoomColor        ; 
                    adc CCW_CtrlScrRowsLo           ; 
                    sta CCZ_ColorHiResLo            ; 
                    lda #>CC_ScreenRoomColor        ; 
ModObjectColor      = *-1                           ; .hbu015.
                    adc CCW_CtrlScrRowsHi           ; 
                    sta CCZ_ColorHiResHi            ; point to $cc00 - screen storage for object type 0 colors
                    
.FillVideoColors    lda CCZ_PntObjRowsWrk           ; 
                    cmp #$19                        ; max $19 (25) screen rows
                    bcs .ChkMaxPosY                 ; 
                    
                    ldy #$00                        ; 
                    lda CCZ_PntObj00ColEnd          ; 
                    sta CCZ_PntObjGridCol           ; 
                    
.ChkMaxPosX         lda CCZ_PntObjGridCol           ; 
                    cmp #$28                        ; max $28 (40) columns per row
                    bcs .NextObjPosX                ; 
                    
.CopyToVideoRam     lda (CCZ_ObjDataTyp0),y         ; point to type  0 object screen ram color data
                    sta (CCZ_ColorHiRes),y          ; point to type  0 object screen ram
                    
.NextObjPosX        iny                             ; 
                    lda CCZ_PntObjGridCol           ; 
                    cmp CCZ_PntObj00ColWrk          ; 
                    beq .ChkMaxPosY                 ; 
                    
                    inc CCZ_PntObjGridCol           ; 
                    jmp .ChkMaxPosX                 ; 
                    
.ChkMaxPosY         lda CCZ_PntObjRowsWrk           ; 
                    cmp CCZ_PntObj00GridRowMax      ; 
                    beq .ChkSwitch                  ; 
                    
                    inc CCZ_PntObjRowsWrk           ; 
                    
                    clc                             ; 
                    lda CCZ_ObjDataTyp0Lo           ; 
                    adc CCZ_PntObj00Cols            ; 
                    sta CCZ_ObjDataTyp0Lo           ; 
                    bcc .SetNextColorRow            ; 
                    inc CCZ_ObjDataTyp0Hi           ; 
                    
                    jmp .SetNextColorRow            ; 
                    
.ChkSwitch          lda CCZ_PntObj00SwColor         ; 
                    cmp #$01                        ; 
                    bne .SetNextObjCol              ; 
                    
                    lda #$00                        ; 
                    sta CCZ_PntObj00SwColor         ; 
                    
                    lda CCZ_PntObjRowsWrk           ; 
                    cmp #$ff                        ; 
                    beq .SetNextColorRow            ; 
                    
                    cmp #$18                        ; 
                    bcs .SetNextObjCol              ; 
                    
.SetNextColorRow    clc                             ; 
                    lda CCZ_ColorHiResLo            ; 
                    adc #$28                        ; $28 columns per screen row
                    sta CCZ_ColorHiResLo            ; 
                    bcc .FillVideoColors            ; 
                    inc CCZ_ColorHiResHi            ; 
                    
                    jmp .FillVideoColors            ; 
                    
.SetNextObjCol      clc                             ; 
                    lda CCZ_ObjDataTyp0Lo           ; 
                    adc CCZ_PntObj00Cols            ; 
                    sta CCZ_ObjDataTyp0Lo           ; 
                    bcc Obj0RamColors               ; 
                    inc CCZ_ObjDataTyp0Hi           ; 
; ------------------------------------------------------------------------------------------------------------- ;
Obj0RamColors       subroutine
                    lda CCZ_PntObj00PrmGridRow      ; copy temp colors to color ram
                    and #$07                        ; 
                    beq .GetSwitch00                ; 
                    
.GetSwitch01        lda #$01                        ; 
                    jmp .SetSwitch                  ; 
                    
.GetSwitch00        lda #$00                        ; 
.SetSwitch          sta CCZ_PntObj00SwColor         ; 
                    
                    lda CCZ_PntObj00GridRow         ; 
                    sta CCZ_PntObjRowsWrk           ; 
                    
                    clc                             ; 
                    lda #<COLORAM                   ; 
                    adc CCW_CtrlScrRowsLo           ; 
                    sta CCZ_ColorRamLo              ; 
                    lda #>COLORAM                   ; 
                    adc CCW_CtrlScrRowsHi           ; 
                    sta CCZ_ColorRamHi              ; point to colour ram
                    
.FillCoRamColors    lda CCZ_PntObjRowsWrk           ; 
                    cmp #$19                        ; max $19 (25) screen rows
                    bcs .ChkMaxPosY                 ; 
                    
                    ldy #$00                        ; 
                    lda CCZ_PntObj00ColEnd          ; 
                    sta CCZ_PntObjGridCol           ; 
                    
.ChkMaxPosXRam      lda CCZ_PntObjGridCol           ; 
                    cmp #$28                        ; max $28 (40) columns per row
                    bcs .NextObjPosX                ; 
                    
.CopyToColorRam     lda (CCZ_ObjDataTyp0),y         ; point to type 0 object color ram data
                    sta (CCZ_ColorRam),y            ; point to colour ram
                    
.NextObjPosX        iny                             ; 
                    lda CCZ_PntObjGridCol           ; 
                    cmp CCZ_PntObj00ColWrk          ; 
                    beq .ChkMaxPosY                 ; 
                    
                    inc CCZ_PntObjGridCol           ; 
                    jmp .ChkMaxPosXRam              ; 
                    
.ChkMaxPosY         lda CCZ_PntObjRowsWrk           ; 
                    cmp CCZ_PntObj00GridRowMax      ; 
                    beq .ChkSwitch                  ; 
                    
                    inc CCZ_PntObjRowsWrk           ; 
                    
                    clc                             ; 
                    lda CCZ_ObjDataTyp0Lo           ; 
                    adc CCZ_PntObj00Cols            ; 
                    sta CCZ_ObjDataTyp0Lo           ; 
                    bcc .SetNextColorRow            ;
                    inc CCZ_ObjDataTyp0Hi           ; 
                    
                    jmp .SetNextColorRow            ; 
                    
.ChkSwitch          lda CCZ_PntObj00SwColor         ; 
                    cmp #$01                        ; 
                    bne PaintObjectX                ; 
                    
                    lda #$00                        ; 
                    sta CCZ_PntObj00SwColor         ; 
                    
                    lda CCZ_PntObjRowsWrk           ; 
                    cmp #$ff                        ; 
                    beq .SetNextColorRow            ; 
                    
                    cmp #$18                        ; 
                    bcs PaintObjectX                ; 
                    
.SetNextColorRow    clc                             ; 
                    lda CCZ_ColorRamLo              ; 
                    adc #$28                        ; 
                    sta CCZ_ColorRamLo              ; 
                    bcc .FillCoRamColors            ; 
                    inc CCZ_ColorRamHi              ; 
                    
                    jmp .FillCoRamColors            ; 
                    
PaintObjectX        pla                             ; 
                    tax                             ; 
                    pla                             ; 
                    tay                             ; 
                    pla                             ; 
                    rts                             ; 
; ------------------------------------------------------------------------------------------------------------- ;
; CopySpriteData    Function: Set shape / expand and copy sprite data of a given number to its memory location
;                   Parms   : xr=sprite workarea block offset ($00, $20, $40, $60, $80, $a0, $c0, $e0)
;                   Returns : xr=sprite workarea block offset ($00, $20, $40, $60, $80, $a0, $c0, $e0)
; ------------------------------------------------------------------------------------------------------------- ;
CopySpriteData      subroutine
                    pha
                    tya
                    pha
                    
                    lda CC_WaS_SpriteNo,x           ; sprite image number
                    sta CCZ_SpriteAdrListLo         ; 
                    lda #$00                        ; 
                    sta CCZ_SpriteAdrListHi         ; 
                    
                    asl CCZ_SpriteAdrListLo         ; address list pointer * 2
                    rol CCZ_SpriteAdrListHi         ; 
                    
                    clc                             ; add base address sprite address list
                    lda CCZ_SpriteAdrListLo         ; 
                    adc #<TabSpriteDataPtr          ; 
                    sta CCZ_SpriteAdrListLo         ; 
                    lda CCZ_SpriteAdrListHi         ; 
                    adc #>TabSpriteDataPtr          ; 
                    sta CCZ_SpriteAdrListHi         ; (38/39) points to desired object pointer
                    
                    ldy #$00                        ; 
                    lda (CCZ_SpriteAdrList),y       ; 
                    sta CCZ_SpriteDataLo            ; 
                    iny                             ; 
                    lda (CCZ_SpriteAdrList),y       ; 
                    sta CCZ_SpriteDataHi            ; (30/31) points to desired object data
                    
.SpriteHeader       ldy #CC_SpriteHdrLook           ; sprite attributes
                    lda (CCZ_SpriteData),y          ; 
                    sta CC_WaS_SpriteAttrib,x       ; Bit7: X-expand Bit6: Y-expand Bit5: Spr/BG-Prio Bit4: MultiColor Bits3-0: Color 0
                    
.GetSpriteCols      ldy #CC_SpriteHdrNumCols        ; 
                    lda (CCZ_SpriteData),y          ; sprite: number of columns
                    sta CCZ_CopySpriteCols          ; 
                    
                    asl a                           ; *2
                    asl a                           ; *4
                    sta CC_WaS_SpriteCols,x         ; 
                    
.GetSpriteRows      ldy #CC_SpriteHdrNumRows        ; 
                    lda (CCZ_SpriteData),y          ; sprite: number of rows
                    sta CC_WaS_SpriteRows,x         ; 
                    
                    txa                             ; 
                    lsr a                           ; /2
                    lsr a                           ; /4
                    lsr a                           ; /8
                    lsr a                           ; /16
                    lsr a                           ; /32 - sprite number
                    sta CCW_CopySpriteNo            ; 
                    
                    tay                             ; 
                    
.FlipSpriteStorage  lda CCZ_SpritesDataPtr,y        ; this sprites data pointer
                    eor #$08                        ; 1st store position  ($20 $21 $22 $23 $24 $25 $26 $27) - $800-$9c0
                    sta CCZ_SpriteStoreLo           ; 2nd store position  ($28 $29 $2a $2b $2c $2d $2e $2f) - $a00-$bc0
                    lda #$00                        ; 
                    sta CCZ_SpriteStoreHi           ; each sprite has 2 slots - copy 1st to alternate before switch to it avoids flicker
                    
                    asl CCZ_SpriteStoreLo           ; *2
                    rol CCZ_SpriteStoreHi           ; 
                    asl CCZ_SpriteStoreLo           ; *4
                    rol CCZ_SpriteStoreHi           ; 
                    asl CCZ_SpriteStoreLo           ; *8
                    rol CCZ_SpriteStoreHi           ; 
                    asl CCZ_SpriteStoreLo           ; *16
                    rol CCZ_SpriteStoreHi           ; 
                    asl CCZ_SpriteStoreLo           ; *32
                    rol CCZ_SpriteStoreHi           ; 
                    asl CCZ_SpriteStoreLo           ; *64 - $a00 $a40 $a80 $ac0 $b00 $b40 $b80 $bc0  ($880 - $cff)
                    rol CCZ_SpriteStoreHi           ; 
                    
.SetSpritePtrRoom   clc                             ; add base address sprite storage
                    lda CCZ_SpriteStoreLo           ; 
                    adc #<CC_SpritePtrRoomBase      ; 
                    sta CCZ_SpriteStoreLo           ; 
                    lda CCZ_SpriteStoreHi           ; 
                    adc #>CC_SpritePtrRoomBase      ; 
ModSpriteData       = *-1
                    sta CCZ_SpriteStoreHi           ; (32/33) points to desired object target storage at $c800 - $c9ff
                    
.PassHeader         clc                             ; 
                    lda CCZ_SpriteDataLo            ; 
                    adc #CC_SpriteHdrLen            ; (30/31) point behind header bytes
                    sta CCZ_SpriteDataLo            ; 
                    bcc .SpriteData                 ; 
                    inc CCZ_SpriteDataHi            ; (30/31) points to desired object data
                    
.SpriteData         lda #$00                        ; 
                    sta CCZ_CopySpriteRows          ; 
.CopySpriteData     ldy #$00                        ; 
.ChkSpriteCols      cpy CCZ_CopySpriteCols          ; 
                    bcs .GetFiller                  ; greater/equal - fill up with $00
                    
.GetSpriteData      lda (CCZ_SpriteData),y          ; from object data
                    jmp .SetSpriteData              ; 
                    
.GetFiller          lda #$00                        ; fill sprite column  02/03 with $00
                    
.SetSpriteData      sta (CCZ_SpriteStore),y         ; fill sprite columns 01-02-03
                    
                    iny                             ; 
                    cpy #$03                        ; last column
                    bcc .ChkSpriteCols              ; no - next
                    
                    inc CCZ_CopySpriteRows          ; 
                    lda CCZ_CopySpriteRows          ; 
                    cmp #$15                        ; 
                    beq .FlopSpriteStorage          ; max 20 rows
                    
                    cmp CC_WaS_SpriteRows,x         ; max rows this sprite
                    bcs .SetFillTab                 ; greater equal - fill missing rows with 00
                    
                    clc                             ; 
                    lda CCZ_SpriteDataLo            ; 
                    adc CCZ_CopySpriteCols          ; 
                    sta CCZ_SpriteDataLo            ; 
                    bcc .SetNextRow                 ; 
                    inc CCZ_SpriteDataHi            ; 
                    jmp .SetNextRow                 ; point to next copy data
                    
.SetFillTab         lda #<TabCopySpriteFiller       ; 
                    sta CCZ_SpriteDataLo            ; 
                    lda #>TabCopySpriteFiller       ; 
                    sta CCZ_SpriteDataHi            ; (30/31) points to fill up object data - $00 $00 $00
                    
.SetNextRow         clc                             ; 
                    lda CCZ_SpriteStoreLo           ; 
                    adc #$03                        ; $03 bytes per row
                    sta CCZ_SpriteStoreLo           ; 
                    bcc .CopySpriteData             ; 
                    inc CCZ_SpriteStoreHi           ; 
                    jmp .CopySpriteData             ; 
                    
.FlopSpriteStorage  ldy CCW_CopySpriteNo            ; this sprites data pointer - can be switched now as data is copied
                    lda CCZ_SpritesDataPtr,y        ; 1st store position  ($20 $21 $22 $23 $24 $25 $26 $27) - $800-$9c0
                    eor #$08                        ; 2nd store position  ($28 $29 $2a $2b $2c $2d $2e $2f) - $a00-$bc0
                    sta CCZ_SpritesDataPtr,y        ; sprite data pointer will be copied in next IRQ now
                    
.Attributes         lda CC_WaS_SpriteAttrib,x       ; Bit7: X-expand Bit6: Y-expand Bit5: Spr/BG-Prio Bit4: MultiColor Bits3-0: Color 0
                    and #CC_SpriteLookColors        ; isolate colors
.SetColor           sta SP0COL,y                    ; VIC 2 - $D027 = Color Sprite 0(-7)
                    
.ChkExpandX         lda CC_WaS_SpriteAttrib,x       ; Bit7: X-expand Bit6: Y-expand Bit5: Spr/BG-Prio Bit4: MultiColor Bits3-0: Color 0
                    and #CC_SpriteLookXpandX        ; Bit7: X-expand test
                    bne .GetExpandX                 ; not set
                    
.ClrExpandX         lda TabSelectABit,y             ; clear
                    eor #$ff                        ; flip
                    and XXPAND                      ; VIC 2 - $D01D = Sprite X Expansion
                    jmp .SetExpandX                 ; 
                    
.GetExpandX         lda XXPAND                      ; VIC 2 - $D01D = Sprite X Expansion
                    asl CC_WaS_SpriteCols,x         ; double sprite columns
                    ora TabSelectABit,y             ; 
.SetExpandX         sta XXPAND                      ; VIC 2 - $D01D = Sprite X Expansion
                    
.ChkExpandY         lda CC_WaS_SpriteAttrib,x       ; Bit7: X-expand Bit6: Y-expand Bit5: Spr/BG-Prio Bit4: MultiColor Bits3-0: Color 0
                    and #CC_SpriteLookXpandY        ; Bit6: Y-expand test
                    bne .GetExpandY                 ; not set
                    
.ClrExpandY         lda TabSelectABit,y             ; 
                    eor #$ff                        ; flip
                    and YXPAND                      ; VIC 2 - $D017 = Sprite Y Expansion Register
                    jmp .SetExpandY                 ; 
                    
.GetExpandY         lda YXPAND                      ; VIC 2 - $D017 = Sprite Y Expansion Register
                    ora TabSelectABit,y             ; 
                    asl CC_WaS_SpriteRows,x         ; double sprite rows
.SetExpandY         sta YXPAND                      ; VIC 2 - $D017 = Sprite Y Expansion Register
                    
.ChkBackgPrio       lda CC_WaS_SpriteAttrib,x       ; Bit7: X-expand Bit6: Y-expand Bit5: Spr/BG-Prio Bit4: MultiColor Bits3-0: Color 0
                    and #CC_SpriteLookPrioBG        ; Bit5: sprite background prio
                    bne .ClrBackgPrio               ; not set
                    
.GetBackgPrio       lda SPBGPR                      ; VIC 2 - $D01B = Sprite to Foreground Priority
                    ora TabSelectABit,y             ; 
                    jmp .SetBackgPrio               ; 
                    
.ClrBackgPrio       lda TabSelectABit,y             ; 
                    eor #$ff                        ; 
                    and SPBGPR                      ; VIC 2 - $D01B = Sprite to Foreground Priority
.SetBackgPrio       sta SPBGPR                      ; VIC 2 - $D01B = Sprite to Foreground Priority
                    
.ChkMultiColor      lda CC_WaS_SpriteAttrib,x       ; Bit7: X-expand Bit6: Y-expand Bit5: Spr/BG-Prio Bit4: MultiColor Bits3-0: Color 0
                    and #CC_SpriteLookMultiC        ; Bit4: multi color test
                    bne .ClrMultiColor              ; not set
                    
.GetMultiColor      lda SPMC                        ; VIC 2 - $D01C = Sprite Multicolor
                    ora TabSelectABit,y             ; 
                    jmp .SetMultiColor              ; 
                    
.ClrMultiColor      lda TabSelectABit,y             ; 
                    eor #$ff                        ; 
                    and SPMC                        ; VIC 2 - $D01C = Sprite Multicolor
.SetMultiColor      sta SPMC                        ; VIC 2 - $D01C = Sprite Multicolor
                    
CopySpriteDataX     pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
; SearchKeyInList   Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
SearchKeyInList     subroutine
                    sta CCW_KeyPickedNo             ; 
                    
                    lda CC_WaS_PlayerSpriteNo,x     ; 
                    beq .SetKeyPlayer1              ; 
                    
.SetKeyPlayer2      lda CCL_Player2KeysAmount       ; count start: 00
                    clc                             ; 
                    adc #CCL_PlayersKeyListLen      ; prepare comparison as xr for player2 starts with key list 2 offset
                    sta CCW_KeyListAmount           ; 
                    ldx #CCL_PlayersKeyListLen      ; key list 2 offset
                    jmp .ChkCollection              ; 
                    
.SetKeyPlayer1      lda CCL_Player1KeysAmount       ; count start: 00
                    sta CCW_KeyListAmount           ; 
                    ldx #$00                        ; key list 1 offset
                    
.ChkCollection      cpx CCW_KeyListAmount           ; 
                    beq .NotFound                   ; 
                    
                    lda CCL_PlayersKeysCollect,x    ; 
                    cmp CCW_KeyPickedNo             ; 
                    beq .Found                      ; 
                    
                    inx                             ; 
                    jmp .ChkCollection              ; 
                    
.NotFound           sec                             ; 
                    rts                             ; 
                    
.Found              clc                             ; 
SearchKeyInListX    rts                             ; 
; ------------------------------------------------------------------------------------------------------------- ;
; Randomizer        Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
Randomizer          subroutine
                    lda CCW_RndSeed03
                    ror a
                    
                    lda CCW_RndSeed02
                    ror a
                    sta CCW_RndSeed01
                    
                    lda #$00
                    rol a
                    eor CCW_RndSeed02
                    sta CCW_RndSeed02
                    
                    lda CCW_RndSeed01
                    eor CCW_RndSeed03
                    sta CCW_RndSeed03
                    
                    eor CCW_RndSeed02
                    sta CCW_RndSeed02
                    
RandomizerX         rts
; ------------------------------------------------------------------------------------------------------------- ;
; GetKeyJoyVal      Function: 
;                   Parms   : ac=joystick port number
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
GetKeyJoyVal        subroutine
                    pha
                    sta CCW_JoyPortNo
                    txa
                    pha
                    
.Keyboard           lda #$ff                        ; prepare read  if A=$ff and B=$00
                    sta CIDDRA                      ; CIA 1 - $DC02 = Data Direction A
                    lda #$00                        ; prepare read  if A=$ff and B=$00
                    sta CIDDRB                      ; CIA 1 - $DC03 = Data Direction B
                    
                    lda #$7f                        ; .####### = check keyboard matrix column - 0 for col to read / 1 for col to ignore
                    sta CIAPRA                      ; CIA 1 - $DC00 = Data Port A - write to    A
                    
                    lda CIAPRB                      ; CIA 1 - $DC01 = Data Port B - read  from  B
                    and #$80                        ; check which key in column 7 was pressed
                    beq .SetStopYes                 ; STOP key pressed
                    
.SetStopNo          lda #$00
                    jmp .PutStop
                    
.SetStopYes         lda #CCW_KeyGotYes
.PutStop            sta CCW_KeyGotStop              ; 1=STOP key pressed
                    
                    lda CCW_JoyPortNo
                    eor #$01                        ; swap parm
                    tax
                    
                    lda #$00
                    sta CIDDRA,x                    ; CIA 1 - $DC02 = Data Direction A
                    lda CIAPRA,x                    ; CIA 1 - $DC00 = Data Port A
                    sta CCW_JoyPortNo               ; data value joystick port A/B
                    
                    and #$0f                        ; isolate joystick moves = Bit 0-3: 0=up/down/left/right
                    tax
                    lda TabJoyDir,x
                    sta CCW_JoyGotDir
                    
                    lda CCW_JoyPortNo               ; data value joystick port A/B
                    and #$10                        ; isolate joystick fire  = Bit 4  : 0=fire
                    eor #$10                        ; .hbu019. - flip to 1
                    bne .ChkFireOld                 ; .hbu019.
                    
                    sta CCW_JoySavFire              ; .hbu019.
                    jmp GetKeyJoyValX               ; .hbu019.
                    
.ChkFireOld         cmp CCW_JoySavFire              ; .hbu019.
                    beq GetKeyJoyValX               ; .hbu019.

.SetFireYes         sta CCW_JoyGotFire              ; .hbu019. - 1=FIRE pressed
                    sta CCW_JoySavFire              ; .hbu019.
                    
GetKeyJoyValX       pla
                    tax
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
; SetCtrlSprtPtr    Function: Set the move control screen pointer for sprites
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
SetCtrlSprtPtr      subroutine
                    pha
                    tya
                    pha
                    
                    clc
                    lda CC_WaS_SpritePosX,x         ; 
                    adc CC_WaS_SpriteStepX,x        ; 
                    sta CCW_CtrlScrnColNo           ; 
                    and #$03                        ; ......##
                    sta CCW_CtrlScrnColB0_1         ; Bit 0-1 of CCW_CtrlScrnColNo
                    
                    lda CCW_CtrlScrnColNo           ; 
                    lsr a                           ; /2
                    lsr a                           ; /4
                    sec                             ; 
                    sbc #$04                        ; 
                    sta CCW_CtrlScrnColNo           ; 
                    
                    clc                             ; 
                    lda CC_WaS_SpritePosY,x         ; 
                    adc CC_WaS_SpriteStepY,x        ; 
                    sta CCW_CtrlScrnRowNo           ; 
                    and #$07                        ; .....###
                    sta CCW_CtrlScrnColB0_2         ; Bit 0-2 of CCW_CtrlScrnRowNo
                    
                    lda CCW_CtrlScrnRowNo           ; 
                    lsr a                           ; /2
                    lsr a                           ; /4
                    lsr a                           ; /8
                    sta CCW_CtrlScrnRowNo           ; 
                    
                    jmp SetCtrlScrnPtrRow           ; set control screen pointer
; ------------------------------------------------------------------------------------------------------------- ;
; SetCtrlScrnPtr    Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
SetCtrlScrnPtr      subroutine
                    pha
                    tya
                    pha
                    
SetCtrlScrnPtrRow   subroutine                      ; global entry point
.AddRow             ldy CCW_CtrlScrnRowNo           ; 
                    lda TabCtrlScrRowsLo,y          ; 
                    sta CCZ_CtrlScreenLo            ; 
                    lda TabCtrlScrRowsHi,y          ; 
                    sta CCZ_CtrlScreenHi            ; 
                    
                    asl CCZ_CtrlScreenLo            ; *2
                    rol CCZ_CtrlScreenHi            ; 
                    
                    clc                             ; add control data screen base address
                    lda CCZ_CtrlScreenLo            ; 
                    adc #<CC_ScreenMoveCtrl         ; 
                    sta CCZ_CtrlScreenLo            ; 
                    lda CCZ_CtrlScreenHi            ; 
                    adc #>CC_ScreenMoveCtrl         ; 
                    sta CCZ_CtrlScreenHi            ; 
                    
.AddCol             lda CCW_CtrlScrnColNo           ; 
                    asl a                           ; *2
                    clc                             ; 
                    adc CCZ_CtrlScreenLo            ; 
                    sta CCZ_CtrlScreenLo            ; 
                    bcc SetCtrlScrnPtrX             ; 
                    inc CCZ_CtrlScreenHi            ; point to control screen output address $c000-$c7ff
                    
SetCtrlScrnPtrX     pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
; SetRoomDataPtr    Function: 
;                   Parms   : ac=Room number - Counter start: $00
;                   Returns : pointer to room data
; ------------------------------------------------------------------------------------------------------------- ;
SetRoomDataPtr      subroutine
                    sta CCZ_RoomDataLo              ; room number
                    lda #$00                        ; 
                    sta CCZ_RoomDataHi              ; 
                    
                    asl CCZ_RoomDataLo              ; 
                    rol CCZ_RoomDataHi              ; *2
                    asl CCZ_RoomDataLo              ; 
                    rol CCZ_RoomDataHi              ; *4
                    asl CCZ_RoomDataLo              ; 
                    rol CCZ_RoomDataHi              ; *8 - CC_Obj_RoomDataLen - length of each room object data
                    
.SetAdrLvlGame      clc                             ; 
                    lda CCZ_RoomDataLo              ; 
                    adc #<CC_LevelGameData          ; castle GAME room data - starts at $7900
                    sta CCZ_RoomDataLo              ; 
                    lda CCZ_RoomDataHi              ; 
                    adc #>CC_LevelGameData          ; 
                    sta CCZ_RoomDataHi              ; 
                    
SetRoomDataPtrX     rts
; ------------------------------------------------------------------------------------------------------------- ;
; SetRoomDoorPtr    Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
SetRoomDoorPtr      subroutine
                    sta CCW_RoomTargDoorCount       ; enter: number of doors in target room
                    
                    ldy #CC_Obj_RoomDoorNoLo        ; Offset 04: Pointer to RoomDoorCount
                    lda (CCZ_RoomData),y            ; RoomDataPtr: RoomPtrDoorCntLo
                    sta CCZ_RoomItemModLo           ; 
                    iny                             ; CC_Obj_RoomDoorNoLo
                    lda (CCZ_RoomData),y            ; RoomDataPtr: RoomPtrDoorCntHi
                    sta CCZ_RoomItemModHi           ; 
                    
                    ldy #$00
                    lda (CCZ_RoomDoorMod),y         ; DoorNumDoors: number of doors in target room - count start at 01
                    
                    pha                             ; save number of doors
                    
                    lda CCW_RoomTargDoorCount       ; number of doors in target room
                    asl a                           ; *2
                    asl a                           ; *4
                    asl a                           ; *8 - each door entry has a length of 08 bytes
                    
                    clc                             ; 
                    adc #$01                        ; +1 - is door count
                    adc CCZ_RoomItemModLo           ; 
                    sta CCZ_RoomItemModLo           ; 
                    lda CCZ_RoomItemModHi           ; 
                    adc #$00                        ; 
                    sta CCZ_RoomItemModHi           ; 40/41 points to start of door data
                    
                    pla                             ; restore number of doors
                    sta CCW_RoomTargDoorCount       ; return: target room number of doors
                    
SetRoomDoorPtrX     rts
; ------------------------------------------------------------------------------------------------------------- ;
; NMI Routine       Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
NMI                 subroutine
                    pha                             ; 
                    
                    lda #CCW_KeyGotYes              ; 
                    sta CCW_KeyGotRestore           ; restore key pressed  01=pressed
                    
                    pla                             ; 
                    
NMIX                rti                             ; 
; ------------------------------------------------------------------------------------------------------------- ;
; IRQ Routine       Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
IRQ                 subroutine
                    pha                             ; 
                    tya                             ; 
                    pha                             ; 
                    txa                             ; 
                    pha                             ; 
                    
                    cld                             ; 
                    
                    lda VICIRQ                      ; VIC 2 - $D019 = VIC Interrupt Flag - 1=clear latched flag
                    and #$01                        ; raster compare
                    bne .ClearRaster                ; 
                    
                    jmp .ChkRaster                  ; 
                    
.ClearRaster        lda VICIRQ                      ; VIC 2 - $D019 = VIC Interrupt Flag - 1=clear latched flag
                    sta VICIRQ                      ; clear
                    
.SetExitLayout      ldx CCW_RasterColorNo           ; 
                    lda TabRasterColorPos-1,x       ; 
                    
                    nop                             ; wait
                    nop                             ; 
                    nop                             ; 
                    nop                             ; 
                    nop                             ; 
                    nop                             ; 
                    
                    sta BGCOL0                      ; VIC 2 - $D021 = Background Color 0
                    
                    cpx #$00                        ; 
                    beq .MoveSprites                ; 
                    
                    jmp .SetExitColor               ; 
                    
.MoveSprites        lda CCZ_Sprite00PosX            ; 
                    sta SP0X                        ; VIC 2 - $D000 = Sprite 0 PosX
                    lda CCZ_Sprite01PosX            ; 
                    sta SP1X                        ; VIC 2 - $D002 = Sprite 1 PosX
                    lda CCZ_Sprite02PosX            ; 
                    sta SP2X                        ; VIC 2 - $D004 = Sprite 2 PosX
                    lda CCZ_Sprite03PosX            ; 
                    sta SP3X                        ; VIC 2 - $D006 = Sprite 3 PosX
                    lda CCZ_Sprite04PosX            ; 
                    sta SP4X                        ; VIC 2 - $D008 = Sprite 4 PosX
                    lda CCZ_Sprite05PosX            ; 
                    sta SP5X                        ; VIC 2 - $D00A = Sprite 5 PosX
                    lda CCZ_Sprite06PosX            ; 
                    sta SP6X                        ; VIC 2 - $D00C = Sprite 6 PosX
                    lda CCZ_Sprite07PosX            ; 
                    sta SP7X                        ; VIC 2 - $D00E = Sprite 7 PosX
                    
                    lda CCZ_Sprite00PosY            ; 
                    sta SP0Y                        ; VIC 2 - $D001 = Sprite 0 PosY
                    lda CCZ_Sprite01PosY            ; 
                    sta SP1Y                        ; VIC 2 - $D003 = Sprite 1 PosY
                    lda CCZ_Sprite02PosY            ; 
                    sta SP2Y                        ; VIC 2 - $D005 = Sprite 2 PosY
                    lda CCZ_Sprite03PosY            ; 
                    sta SP3Y                        ; VIC 2 - $D007 = Sprite 3 PosY
                    lda CCZ_Sprite04PosY            ; 
                    sta SP4Y                        ; VIC 2 - $D009 = Sprite 4 PosY
                    lda CCZ_Sprite05PosY            ; 
                    sta SP5Y                        ; VIC 2 - $D00B = Sprite 5 PosY
                    lda CCZ_Sprite06PosY            ; 
                    sta SP6Y                        ; VIC 2 - $D00D = Sprite 6 PosY
                    lda CCZ_Sprite07PosY            ; 
                    sta SP7Y                        ; VIC 2 - $D00F = Sprite 7 PosY
                    
                    lda CCZ_SpritesMSBY             ; 
                    sta MSIGX                       ; VIC 2 - $D010 = MSBs Sprites 0-7 PosX
                    
.EnabSprites        lda CCZ_SpritesEnab             ; 
                    sta SPENA                       ; VIC 2 - $D015 = Sprite Enable
                    
;.SetVICMemoryBank   lda CCZ_CIABankCtrl             ; .hbu015.
;                    sta CI2PRA                      ; .hbu015.

.SetVICMemoryScreen lda CCZ_VICMemCtrl              ; 
                    sta VMCSB                       ; VIC 2 - $D018 = VIC-II Chip Memory Control
                    
                    lda CCZ_ColorBorder             ; 
                    sta EXTCOL                      ; VIC 2 - $D020 = Border Color
                    lda CCW_RasterColorSav          ; 
                    sta BGCOL0                      ; VIC 2 - $D021 = Background Color 0
                    
                    lda CCZ_VICModeCtrl             ; 
                    sta SCROLX                      ; VIC 2 - $D016 = Control Register 2 (and Horizontal Fine Scrolling)
                    
.SetSpriteRoomPtr   lda CCZ_Sprite00DataPtr         ; 
                    sta CC_SpritePtrRoom00          ; SCREEN - sprite 0 data pointer
                    lda CCZ_Sprite01DataPtr         ; 
                    sta CC_SpritePtrRoom01          ; SCREEN - sprite 1 data pointer
                    lda CCZ_Sprite02DataPtr         ; 
                    sta CC_SpritePtrRoom02          ; SCREEN - sprite 2 data pointer
                    lda CCZ_Sprite03DataPtr         ; 
                    sta CC_SpritePtrRoom03          ; SCREEN - sprite 3 data pointer
                    lda CCZ_Sprite04DataPtr         ; 
                    sta CC_SpritePtrRoom04          ; SCREEN - sprite 4 data pointer
                    lda CCZ_Sprite05DataPtr         ; 
                    sta CC_SpritePtrRoom05          ; SCREEN - sprite 5 data pointer
                    lda CCZ_Sprite06DataPtr         ; 
                    sta CC_SpritePtrRoom06          ; SCREEN - sprite 6 data pointer
                    lda CCZ_Sprite07DataPtr         ; 
                    sta CC_SpritePtrRoom07          ; SCREEN - sprite 7 data pointer
                    
.ChkIRQCounter      lda CCW_CountIRQs               ; counted down to $00 with every IRQ
                    beq .SetExitColor               ; 
                    
                    dec CCW_CountIRQs               ; counted down to $00 with every IRQ
                    
.SetExitColor       inx                             ; 
                    inx                             ; 
                    cpx CCW_RasterColorMax          ; max set in EscapeHandler reached
                    beq .GetScanLine                ; 
                    bcc .GetScanLine                ; 
                    
                    ldx #$00                        ; 
.GetScanLine        lda TabRasterColorPos,x         ; 
                    sta RASTER                      ; VIC 2 - $D012 = Read: Raster Scan Line / Write: Line for Raster IRQ
                    stx CCW_RasterColorNo           ; 
                    
.ChkRaster          lda CIAICR                      ; CIA 1 - $DC0D = Interrupt Control
                    and #$01                        ; 
                    beq IRQX                        ; 
                    
                    jsr IRQ_Sfx                     ; handle sfx
                    
IRQX                pla                             ; 
                    tax                             ; 
                    pla                             ; 
                    tay                             ; 
                    pla                             ; 
                    
                    rti                             ; 
; ------------------------------------------------------------------------------------------------------------- ;
; IRQ_Sfx           Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
IRQ_Sfx             subroutine
                    lda CCW_Tune2PlayCtrlCut2
                    bne .DecCutLo02
                    
                    lda CCW_Tune2PlayCtrlCut3
                    beq .GetNextPotion
                    
                    dec CCW_Tune2PlayCtrlCut3
.DecCutLo02         dec CCW_Tune2PlayCtrlCut2
                    
                    lda CCW_Tune2PlayCtrlCut2
                    ora CCW_Tune2PlayCtrlCut3
                    beq .GetNextPotion
                    
                    jmp IRQ_SfxX
                    
.GetNextPotion      ldy #$00
                    lda (CCZ_SoundData),y           ; point to sound effect / demo music
                    
                    lsr a                           ; /2
                    lsr a                           ; /4
                    
                    tax                             ; 
                    lda TabTune2PlayCopyLen,x       ; 
                    
                    tax                             ; 
                    tay                             ; 
                    
.CopyNext           dey                             ; 
                    bmi .SetNextPortion             ; 
                    
                    lda (CCZ_SoundData),y           ; point to sound effect / demo music
                    sta TabTune2Play,y              ; 
                    jmp .CopyNext                   ; 
                    
.SetNextPortion     clc
                    txa
                    adc CCZ_SoundDataLo             ; 
                    sta CCZ_SoundDataLo             ; 
                    bcc .GetControl
                    inc CCZ_SoundDataHi             ; point to next portion of sound effect / demo music
                    
.GetControl         lda TabTune2PlayCtrl            ; 
                    lsr a                           ; /2
                    lsr a                           ; /4
                    
.ChkControl00       cmp #$00
                    bne .ChkControl01
                    
                    jsr IRQ_NextVoice
                    
                    lda TabTune2PlayCtrl
                    and #$03
                    tax
                    
                    lda TabTune2PlayCutLo
                    clc
                    adc CCW_Tune2PlayCutLo,x
                    tax
                    
                    ldy #$00
                    lda TabTune2Play01,x
                    sta (CCZ_SidVoiceAdr),y         ; pointer SID Oscillators 1-3 addresses
                    sta (CCZ_SidVoiceVal),y         ; pointer SID Oscillators 1-3 set of values
                    
                    iny
                    lda TabTune2Play02,x
                    sta (CCZ_SidVoiceAdr),y         ; pointer SID Oscillators 1-3 addresses
                    sta (CCZ_SidVoiceVal),y         ; pointer SID Oscillators 1-3 set of values
                    
                    ldy #$04
                    lda (CCZ_SidVoiceVal),y         ; pointer SID Oscillators 1-3 set of values
                    ora #$01
                    sta (CCZ_SidVoiceAdr),y         ; pointer SID Oscillators 1-3 addresses
                    sta (CCZ_SidVoiceVal),y         ; pointer SID Oscillators 1-3 set of values
                    jmp .GetNextPotion
                    
.ChkControl01       cmp #$01
                    bne .ChkControl02
                    
                    jsr IRQ_NextVoice               ; 
                    
                    ldy #$04
                    lda (CCZ_SidVoiceVal),y         ; pointer SID Oscillators 1-3 set of values
                    and #$fe
                    sta (CCZ_SidVoiceVal),y         ; pointer SID Oscillators 1-3 set of values
                    sta (CCZ_SidVoiceAdr),y         ; pointer SID Oscillators 1-3 addresses
                    jmp .GetNextPotion
                    
.ChkControl02       cmp #$02
                    bne .ChkControl03
                    
                    lda TabTune2PlayCutLo
                    sta CCW_Tune2PlayCtrlCut2
                    jmp IRQ_SfxX
                    
.ChkControl03       cmp #$03
                    bne .ChkControl04
                    
                    lda TabTune2PlayCutLo
                    sta CCW_Tune2PlayCtrlCut3
                    jmp IRQ_SfxX
                    
.ChkControl04       cmp #$04
                    bne .ChkControl05
                    
                    jsr IRQ_NextVoice
                    
                    ldy #$02
.CopyWrkTune        cpy #$04
                    beq .CopyLastPart
                    
.CopyFirstPart      lda TabTune2PlayBlock,y
                    sta (CCZ_SidVoiceAdr),y         ; pointer SID Oscillators 1-3 addresses
                    sta (CCZ_SidVoiceVal),y         ; pointer SID Oscillators 1-3 set of values
                    jmp .SetNext
                    
.CopyLastPart       lda (CCZ_SidVoiceVal),y         ; pointer SID Oscillators 1-3 set of values
                    and #$01
                    ora TabTune2PlayBlock,y
                    sta (CCZ_SidVoiceAdr),y         ; pointer SID Oscillators 1-3 addresses
                    sta (CCZ_SidVoiceVal),y         ; pointer SID Oscillators 1-3 set of values
                    
.SetNext            iny
                    cpy #$07
                    bcc .CopyWrkTune
                    jmp .GetNextPotion
                    
.ChkControl05       cmp #$05
                    bne .ChkControl06
                    
                    lda TabTune2PlayCutLo
                    sta CUTLO                       ; SID - $D415 = Filter Cutoff Frequency (lowh byte)
                    sta TabSidCutLo                 ; 
                    
                    lda TabTune2PlayCutHi
                    sta CUTHI                       ; SID - $D416 = Filter Cutoff Frequency (high byte)
                    sta TabSidCutHi                 ; 
                    
                    lda TabTune2PlayCtrl
                    and #$03                        ; ......##
                    tax
                    lda TabSelectABit,x
                    ora TabTune2PlayRes
                    sta RESON                       ; SID - $D417 = Filter Resonance Control Register
                    
                    sta TabSidRes
                    lda TabSidVolume
                    and #$0f                        ; ....####
                    ora TabTune2PlayVol
                    sta TabSidVolume
                    sta SIGVOL                      ; SID - $D418 = Volume and Filter Select
                    jmp .GetNextPotion
                    
.ChkControl06       cmp #$06
                    bne .ChkControl07
                    
                    lda TabTune2PlayCtrl
                    and #$03
                    tax
                    
                    lda TabTune2PlayCutLo
                    sta CCW_Tune2PlayCutLo,x
                    jmp .GetNextPotion
                    
.ChkControl07       cmp #$07
                    bne .ChkControl08
                    
                    lda TabSidVolume
                    and #$f0                        ; ####....
                    ora TabTune2PlayCutLo
                    sta TabSidVolume
                    sta SIGVOL                      ; SID - $D418 = Volume and Filter Select
                    jmp .GetNextPotion
                    
.ChkControl08       cmp #$08
                    bne .ChkDemo
                    
                    lda TabTune2PlayCutLo
                    sta CCW_Tune2PlayTime
                    asl a                           ; *2
                    asl a                           ; *4
                    ora #$03                        ; ......##
                    sta TIMAHI                      ; CIA 1 - $DC05 = Timer A (high byte)
                    jmp .GetNextPotion
                    
.ChkDemo            lda CCW_DemoFlag                ; 
                    cmp #CCW_DemoYes                ; 
                    beq .InitDemo
                    
                    lda #CCW_InitSfxNoInit          ; init
                    sta CCW_InitSfxNoWrk
                    lda #$00
                    sta CIACRA                      ; CIA 1 - $DC0E = Control A
                    
                    lda #$7f
                    sta CIAICR                      ; CIA 1 - $DC0D = Interrupt Control
                    lda CIAICR                      ; CIA 1 - $DC0D = Interrupt Control
                    jmp IRQ_SfxX
                    
.InitDemo           lda #<CCL_MusicDataStart        ; 
                    sta CCZ_SoundDataLo             ; 
                    lda #>CCL_MusicDataStart        ; 
                    sta CCZ_SoundDataHi             ; 
                    
                    lda #$02
                    sta CCW_Tune2PlayCtrlCut3
                    
                    lda TabSidRes
                    and #$f0                        ; ####....
                    sta RESON                       ; SID - $D417 = Filter Resonance Control
                    sta TabSidRes
                    
IRQ_SfxX            rts
; ------------------------------------------------------------------------------------------------------------- ;
; IRQ_NextVoice     Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
IRQ_NextVoice       subroutine
                    lda TabTune2PlayCtrl            ; 
                    and #$03                        ; ......##
                    asl a                           ; *2
                    tax                             ; 
                    
                    lda TabTune2PlayVocAdr,x        ; SID ocillator addresses
                    sta CCZ_SidVoiceAdrLo           ; 
                    lda TabTune2PlayVocAdr+1,x      ; 
                    sta CCZ_SidVoiceAdrHi           ; 
                    
                    lda TabSidVoicesData,x          ; SID oscillator values
                    sta CCZ_SidVoiceValLo           ; 
                    lda TabSidVoicesData+1,x        ; 
                    sta CCZ_SidVoiceValHi           ; 
                    
IRQ_NextVoiceX      rts
; ------------------------------------------------------------------------------------------------------------- ;
; InitTuneVoices    Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
InitTuneVoices      subroutine
                    ldx #$0e                        ; ....###.
.GetValues          lda TabSidVoice1Control,x       ; 
                    and #$fe                        ; #######.
                    sta TabSidVoice1Control,x       ; 
                    sta VCREG1,x                    ; SID - $D404 = Oscillator 1 Control
                    
                    sec                             ; 
                    txa                             ; 
                    sbc #$07                        ; 
                    tax                             ; 
                    bcs .GetValues                  ; 
                    
InitTuneVoicesX     rts                             ; 
; ------------------------------------------------------------------------------------------------------------- ;
; InitSoundFx       Function: set IRQ sfx pointer to the requested sound data
;                   Parms   : ac - sound effect number
;                   Returns : xr - not modified
; ------------------------------------------------------------------------------------------------------------- ;
InitSoundFx         subroutine
                    pha
                    sta CCW_InitSfxNo               ; effect no
                    tya
                    pha
                    
                    lda CCW_DemoFlag                ; 
                    cmp #CCW_DemoYes                ; 
                    beq InitSoundFxX                ; no soundeffects for demo
                    
                    lda CCW_InitSfxNoWrk
                    bpl InitSoundFxX
                    
                    lda CCW_InitSfxNo
                    sta CCW_InitSfxNoWrk
                    asl a
                    tay
                    lda TabSoundsDataPtr,y          ; Table SoundFX Data Pointer
                    sta CCZ_SoundDataLo             ; 
                    lda TabSoundsDataPtr+1,y
                    sta CCZ_SoundDataHi             ; point to sound effect / demo music
                    
                    lda #$00
                    sta VCREG1                      ; SID - $D404 = Oscillator 1 Control
                    sta VCREG2                      ; SID - $D40B = Oscillator 2 Control
                    sta VCREG3                      ; SID - $D412 = Oscillator 3 Control
                    
                    sta RESON                       ; SID - $D417 = Filter Resonance Control
                    sta CCW_Tune2PlayCtrlCut2
                    sta CCW_Tune2PlayCtrlCut3
                    
                    lda #$0f
                    sta SIGVOL                      ; SID - $D418 = Volume and Filter Select
                    
                    lda #$18
                    sta CCW_Tune2PlayCutLo
                    sta CCW_Tune2PlayCutLo + 1
                    sta CCW_Tune2PlayCutLo + 2
                    
                    lda #CCW_Tune2PlayTimeInit
                    sta CCW_Tune2PlayTime
                    
                    asl a
                    asl a                           ; *4
                    ora #$03
                    sta TIMAHI                      ; CIA 1 - $DC05 = Timer A (high byte)
                    
                    lda #$81
                    sta CIAICR                      ; CIA 1 - $DC0D = Interrupt Control
                    lda #$01
                    sta CIACRA                      ; CIA 1 - $DC0E = Control A
                    
InitSoundFxX        pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
; SwitchScreenOn    Function: Switch display on again
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
SwitchScreenOn      subroutine
                    lda SCROLY                      ; VIC 2 - $D011 = VIC Control Register 1 (and Vertical Fine Scrolling)
.ScreenOn           ora #$10                        ; ...#.... - Bit 4: screen background color - 1=visible again
                    sta SCROLY                      ; 
                    
SwitchScreenOnX     rts                             ;
; ------------------------------------------------------------------------------------------------------------- ;
; SwitchScreenOff   Function: Switch display off
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
SwitchScreenOff     subroutine
                    lda SCROLY                      ; VIC 2 - $D011 = VIC Control Register 1 (and Vertical Fine Scrolling)
.ScreenOff          and #$ef                        ; ###.#### - Bit 4: Screen Disable - 0=disabled
                    sta SCROLY                      ; VIC 2 - $D011 = VIC Control Register 1 (and Vertical Fine Scrolling)
                    
SwitchScreenOffX    rts                             ; 
; ------------------------------------------------------------------------------------------------------------- ;
; WaitSomeTime      Function: Wait a variable amount of time
;                   Parms   : ac=Wait time
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
WaitSomeTime        subroutine
                    sta CCW_CountDynWait            ; 
                    
                    ldx #$06                        ; 
.WaitI              lda CCW_CountDynWait            ; 
                    sta CCW_CountIRQs               ; 
                    
.Wait               lda CCW_CountIRQs               ; counted down to $00 with every IRQ
                    bne .Wait                       ; 
                    
                    dex                             ; 
                    bne .WaitI                      ; 
                    
WaitSomeTimeX       rts
; ------------------------------------------------------------------------------------------------------------- ;
; WaitJoyKeyRlse    Function: Wait for joystick to be released to avoid permanent action
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
WaitJoyKeyRlse      subroutine
                    pha
                    
.WaitI              lda #CCW_CountIRQsGame          ; 
                    sta CCW_CountIRQs               ; counted down to $00 with every IRQ
.Wait               lda CCW_CountIRQs               ; counted down to $00 with every IRQ
                    bne .Wait                       ; 
                    
                    lda #$00                        ; jostick port
                    jsr GetKeyJoyVal                ; 
                    
                    lda CCW_JoyGotDir               ; 
                    bpl .WaitI                      ; still moved
                    
WaitJoyKeyRlseX     pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
; AdjustRoomDataPtrs Function: Make castle data file movable by adjusting the room data pointers
;                    Parms   : 
;                    Returns : 
;                    Id      : .hbu014.
; ------------------------------------------------------------------------------------------------------------- ;
AdjustRoomDataPtrs  subroutine
                    lda #<CC_LevelGameVars          ; point to level room variables
                    sta CCZ_RoomItemLo              ; 
                    lda #>CC_LevelGameVars          ; 
                    sta CCZ_RoomItemHi              ; 
                    
.XitPicPtr          ldy #CCL_XitPicDataPtrHi - CC_LevelGameVars ; exit picture
                    jsr AdjustPtr                   ; 

                    inc CCZ_RoomItemHi              ; point to CC_LevelGameData

.NextRoom           ldy #CC_Obj_Room                ; 
                    lda (CCZ_RoomItem),y            ; room object
.ChkEndOfData       and #CC_Obj_RoomEoData          ; 
                    bne AdjustRoomDataPtrsX         ; EndOfRoomsData
                    
                    ldy #CC_Obj_RoomDoorNoHi        ; only the high bytes need an unpdate
                    jsr AdjustPtr                   ; the data offsets remain the ame
                    
                    ldy #CC_Obj_RoomDoorIdHi        ; 
                    jsr AdjustPtr                   ; 
                    
.SetNextRoom        clc                             ; 
                    lda CCZ_RoomItemLo              ; 
                    adc #CC_Obj_RoomDataLen         ; $08 = length of each room data entry
                    sta CCZ_RoomItemLo              ; 
                    bcc .NextRoom                   ; 
                    inc CCZ_RoomItemHi              ; 
.GoNextRoom         bne .NextRoom                   ; 
                    
AdjustRoomDataPtrsX rts                             ; 
; ------------------------------------------------------------------------------------------------------------- ;
AdjustPtr           lda (CCZ_RoomItem),y            ; room object
                    sec                             ; 
                    sbc #$79                        ; high byte original load address
                    clc
                    adc #>CC_LevelGameData          ; new game level load address
                    sta (CCZ_RoomItem),y            ; room object
                    
AdjustPtrX          rts                             ; 
; ------------------------------------------------------------------------------------------------------------- ;
; RestoreColorRam   Function: Restore map color ram
;                   Parms   : 
;                   Returns : 
;                   Id      : .hbu015.
; ------------------------------------------------------------------------------------------------------------- ;
RestoreColorRam     subroutine
                    lda CCZ_RestoreColor            ; do not restore colors the first time ...
                    bne .SetRestorePtrs             ; 
                    
                    inc CCZ_RestoreColor            ; 
                    
.ChkPlayer2Text     lda CCW_RoomP2Enters            ; ... but set header text
                    beq .SetPlayer2Text             ; 
                    
                    lda #CC_Player2MapTxtGridCol    ; 
                    
.SetPlayer2Text     sta TextTwoUp                   ; 
                    
                    lda TabMapP_TextPtr             ; "one up" / "two up"
                    sta CCZ_RoomItemLo              ; 
                    lda TabMapP_TextPtr+1           ; 
                    sta CCZ_RoomItemHi              ; 
.PaintPlayersText   jsr RoomTextLine                ; 
                    
.Exit               rts                             ; 
                    
.SetRestorePtrs     lda #<CC_SpriteDataMap          ; 
                    sta CCZ_CopyFromLo              ; 
                    lda #>CC_SpriteDataMap          ; 
                    sta CCZ_CopyFromHi              ; point to colour ram
                    
                    lda #<COLORAM                   ; 
                    sta CCZ_CopyTargLo              ; 
                    lda #>COLORAM                   ; 
                    sta CCZ_CopyTargHi              ; point to target ram
                    
CC_Player1MapTxtOff = ($27 * CC_GridWidth * $02 * CC_PlayersMapRow) + (CC_Player1MapCol * CC_GridWidth * $02) + CC_GridColOff
CC_Player2MapTxtOff = ($27 * CC_GridWidth * $02 * CC_PlayersMapRow) + (CC_Player2MapCol * CC_GridWidth * $02) + CC_GridColOff
                    
                    ldx #DatObjTimeDataLen          ; 
                    lda #$00                        ; 
.ClearTime          sta CC_ScreenMapGfx + CC_Player1MapTxtOff,x ; the time frame targets p1/p2 must be cleared
                    sta CC_ScreenMapGfx + CC_Player2MapTxtOff,x ; as type0 ojects are overlayed with the background
.SetNextPos         dex                             ; 
                    bpl .ClearTime                  ; 
                    
RestoreColorRamX    jmp CopyColorRam                ; 
; ------------------------------------------------------------------------------------------------------------- ;
; SaveColorRam      Function: Save map color ram to map sprite area - area is shared with room color ramm
;                   Parms   : 
;                   Returns : 
;                   Id      : .hbu015.
; ------------------------------------------------------------------------------------------------------------- ;
SaveColorRam        subroutine
.SetSavePtrs        lda #<COLORAM                   ; 
                    sta CCZ_CopyFromLo              ; 
                    lda #>COLORAM                   ; 
                    sta CCZ_CopyFromHi              ; point to colour ram
                    
                    lda #<CC_SpriteDataMap          ; 
                    sta CCZ_CopyTargLo              ; 
                    lda #>CC_SpriteDataMap          ; 
                    sta CCZ_CopyTargHi              ; point to target ram
; ------------------------------------------------------------------------------------------------------------- ;
CopyColorRam        subroutine                    
                    ldx #$04                        ; pages
                    ldy #$00                        ; bytes
.CopyColors         lda (CCZ_CopyFrom),y            ; copy colors
                    sta (CCZ_CopyTarg),y            ; 
                    iny                             ; 
                    bne .CopyColors                 ; 
                    
                    inc CCZ_CopyFromHi              ; point to colour ram
                    inc CCZ_CopyTargHi              ; point to colour ram
                    
                    dex                             ; 
                    bne .CopyColors                 ; 
                    
CopyColorRamX       rts                             ; 
; ------------------------------------------------------------------------------------------------------------- ;
; RoomDataSave      Function: Save player status / original room data to be able to restore it after a death
;                   Parms   : 
;                   Returns : 
;                   Id      : .hbu017.
; ------------------------------------------------------------------------------------------------------------- ;
RoomDataSave        subroutine
                    ldy #$03                        ; 
.SavPlayersRoomNo   lda CCL_PlayersTargetRoomNo,y   ; save target rooms and doors for both players
                    sta CCL_PlayersSaveRoomNo,y     ; 
                    dey                             ; 
                    bpl .SavPlayersRoomNo           ; 
                    
.SavKeyAmount       lda CCL_Player1KeysAmount       ; save amount of collected keys for both players
                    sta CCL_Player1SaveKeyAmnt      ; 
                    lda CCL_Player2KeysAmount       ; 
                    sta CCL_Player2SaveKeyAmnt      ; 
                    
                    lda CCZ_RoomDataStartLo         ; 
                    sta CCZ_RoomCopyFromLo          ; 
                    lda CCZ_RoomDataStartHi         ; 
                    sta CCZ_RoomCopyFromHi          ; 
                    
                    lda #<StoreRoomData             ; 
                    sta CCZ_RoomCopyTargLo          ; 
                    lda #>StoreRoomData             ; 
                    sta CCZ_RoomCopyTargHi          ; 
                    
                    iny                             ; 
.SavPlayersRoomData lda (CCZ_RoomCopyFrom),y        ; 
                    sta (CCZ_RoomCopyTarg),y        ; 
                    
.SetSavTargPtr      inc CCZ_RoomCopyTargLo          ; 
                    bne .SetSavFromPtr              ; 
                    inc CCZ_RoomCopyTargHi          ; 
                    
.SetSavFromPtr      inc CCZ_RoomCopyFromLo          ; 
                    bne .ChkSavFromPtr              ; 
                    inc CCZ_RoomCopyFromHi          ; 
                    
.ChkSavFromPtr      lda CCZ_RoomCopyFromLo          ; 
                    cmp CCZ_RoomDataEndLo           ; 
                    bne .SavPlayersRoomData         ; 
                    
                    lda CCZ_RoomCopyFromHi          ; 
                    cmp CCZ_RoomDataEndHi           ; 
                    bne .SavPlayersRoomData         ; 
                    
RoomDataSaveX       rts
; ------------------------------------------------------------------------------------------------------------- ;
; RoomDataRestore   Function: Restore original room data after a players death
;                   Parms   : 
;                   Returns : 
;                   Id      : .hbu017.
; ------------------------------------------------------------------------------------------------------------- ;
RoomDataRestore     subroutine
                    lda #<StoreRoomData             ; 
                    sta CCZ_RoomCopyFromLo          ; 
                    lda #>StoreRoomData             ; 
                    sta CCZ_RoomCopyFromHi          ; 
                    
                    lda CCZ_RoomDataStartLo         ; 
                    sta CCZ_RoomCopyTargLo          ; 
                    lda CCZ_RoomDataStartHi         ; 
                    sta CCZ_RoomCopyTargHi          ; 
                    
                    ldy #$00                        ; 
.GetPlayersRoomData lda (CCZ_RoomCopyFrom),y        ; 
                    sta (CCZ_RoomCopyTarg),y        ; 
                    
.SetGetTargPtr      inc CCZ_RoomCopyTargLo          ; 
                    bne .SetGetFromPtr              ; 
                    inc CCZ_RoomCopyTargHi          ; 
                    
.SetGetFromPtr      inc CCZ_RoomCopyFromLo          ; 
                    bne .ChkGetFromPtr              ; 
                    inc CCZ_RoomCopyFromHi          ; 
                    
.ChkGetFromPtr      lda CCZ_RoomCopyTargLo          ; 
                    cmp CCZ_RoomDataEndLo           ; 
                    bne .GetPlayersRoomData         ; 
                    
                    lda CCZ_RoomCopyTargHi          ; 
                    cmp CCZ_RoomDataEndHi           ; 
                    bne .GetPlayersRoomData         ; 
                    
RoomDataRestoreX    rts                             ; 
; ------------------------------------------------------------------------------------------------------------- ;
; WarmStart         Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
WarmStart           subroutine
.WaitBeam           lda SCROLY                      ; .hbu008. - wait for raster beam to be off the display
                    bpl .WaitBeam                   ; .hbu008.
                    
                    lda #$00                        ; 
                    sta SCROLY                      ; VIC 2 - $D011 = VIC Control Register 1 (and Vertical Fine Scrolling)
                    
                    sei                             ; interrupts off
                    
                    lda #$7f                        ; 
                    sta CI2ICR                      ; CIA 2 - $DD0D = Interrupt Control Register
                    lda CI2ICR                      ; CIA 2 - $DD0D = Interrupt Control Register
                    
                    lda #$07                        ; 
                    sta D6510                       ; CPU Port Data Direction Register
                    
                    lda #B_Koff                     ; -> basic=off io=on kernel=off
                    sta R6510                       ; CPU Port Data Register
                    
                    lda #<IRQ                       ; 
                    sta VBRK                        ; KERNEL - $FFFE = Maskable Interrupt Request / Break Hardware Vector
                    lda #>IRQ                       ; 
                    sta VBRK + 1                    ; IRQ vector
                    
                    lda #<NMI                       ; 
                    sta VNMI                        ; KERNEL - $FFFA = Non-Maskable Interrupt Hardware Vector
                    lda #>NMI                       ; 
                    sta VNMI + 1                    ; NMI vector
                    
                    ldx #$00                        ; 
                    lda #$20                        ; 
.SetSprtDataPtr     sta CCZ_SpritesDataPtr,x        ; CCZ_SpritesDataPtr - data pointers sprite 0-7 to $20-$27
                    inx                             ; 
                    cpx #$08                        ; 
                    bcs .InitIO                     ; 
                    
                    adc #$01                        ; 
                    jmp .SetSprtDataPtr             ; 
                    
.InitIO             lda #$18                        ; Bit4: 1=multicolor bitmap mode  Bit 3: 1=40 columns
                    sta SCROLX                      ; VIC 2 - $D016 = Control Register 2 (and Horizontal Fine Scrolling)
                    sta CCZ_VICModeCtrl             ; 
                    
                    lda #$00                        ; 
                    sta RASTER                      ; VIC 2 - $D012 = Read: Raster Scan Line / Write: Line for Raster IRQ
                    
.SetScreens         lda #CC_VIC_ScreensGfx          ; ..## - Bits 4-7: Screen base address $0c00-$0fe7 + base in $DD00 ($c000-$ffff)
                    sta CCZ_VICMemCtrl              ; #... - Bits 2-3: Bitmap base address $2000-$27ff + base in $DD00 ($c000-$ffff)
                    
                    lda #$01                        ; 
                    sta IRQMASK                     ; VIC 2 - $D01A = IRQ Mask
                    
                    lda #$ff                        ; 
                    sta VICIRQ                      ; VIC 2 - $D019 = VIC Interrupt Flag - 1=clear latched flag
                    
                    lda #BLACK                      ;  
                    sta CCZ_ColorBorder             ; 
                    sta CCW_RasterColorSav          ; 
                    
.SetMultiColors     lda #CC_MultiColor1Players      ; player 1/2 multicolor 0
                    sta SPMC0                       ; VIC 2 - $D025 = Sprite Multicolor Register 0
                    
                    lda #CC_MultiColor2Players      ; player 1/2 multicolor 1
                    sta SPMC1                       ; VIC 2 - $D026 = Sprite Multicolor Register 1
                    
                    lda #$03                        ; 
                    sta C2DDRA                      ; CIA 2 - $DD02 = Data Direction A
                    
                    lda #CC_ScreenBankIdRoom        ; 
                    sta CI2PRA                      ; .hbu015.
;                    sta CCZ_CIABankCtrl             ; .hbu015.
                    
                    lda #$00                        ; 
                    sta CIACRA                      ; CIA 1 - $DC0E = Control A
                    sta CI2CRA                      ; CIA 2 - $DD0E = Control A
                    sta CIACRB                      ; CIA 1 - $DC0F = Control B
                    sta CI2CRB                      ; CIA 2 - $DD0F = Control B
                    
                    lda #$7f                        ; .#######
                    sta CIAICR                      ; CIA 1 - $DC0D = Interrupt Control
                    lda CIAICR                      ; CIA 1 - $DC0D = Interrupt Control
                    
                    cli                             ; interrupts on
                    
.SpritesOff         lda #$00                        ; disable all
                    sta CCZ_SpritesEnab             ; sprites 0-7 enable
                    
                    lda #$3b                        ; Bit 5: 1=bitmap graphics  Bit 4: 1=unblank screen  Bit 3: 1=25 row display
                    sta SCROLY                      ; VIC 2 - $D011 = VIC Control Register 1 (and Vertical Fine Scrolling)
                    
.InitTimer          lda #$ff                        ; ########
                    sta TIMALO                      ; CIA 1 - $DC04 = Timer A (low byte)
                    
                    lda CCW_Tune2PlayTime           ; $14 - ...#.#..
                    asl a                           ; 
                    asl a                           ; $50 - .#.#....
                    ora #$03                        ; 
                    sta TIMAHI                      ; CIA 1 - $DC05 = Timer A (high byte)
                    
                    lda #CCW_InitSfxNoInit          ; init
                    sta CCW_InitSfxNoWrk            ; 
                    
                    lda CCW_Tune2PlayDemo           ; 
                    cmp #CCW_Tune2PlayDemoYes       ; 
                    bne WarmStartX                  ; 
                    
                    ldx #$18                        ; 
.InitSid            lda TabSidVoices,x              ; voice 01-03 register values/filter/volume
                    sta FRELO1,x                    ; SID - $D400 = Oscillator 1 Frequency Control (low byte)
                    dex                             ; 
                    bpl .InitSid                    ; 
                    
                    lda #$81                        ; #......# - set bits with 1/enable timer A interrupts
                    sta CIAICR                      ; CIA 1 - $DC0D = Interrupt Control
                    lda #$01                        ; 
                    sta CIACRA                      ; CIA 1 - $DC0E = Control A
                    
WarmStartX          rts
; ------------------------------------------------------------------------------------------------------------- ;
Sounds              include inc\CC_DataSounds.asm   ; Sound Effects
Tables              include inc\CC_DataTables.asm   ; Tables
Texts               include inc\CC_DataTexts.asm    ; Texts/Load Control Screen Lines
Sprites             include inc\CC_DataSprites.asm  ; Sprite Data and Numbers
; ------------------------------------------------------------------------------------------------------------- ;
; Next routines are used only once in ColdStart - can be overwritten after execution
; ------------------------------------------------------------------------------------------------------------- ;
StoreRoomData       = *                             ; .hbu017. - save area for restorable original room data
; ------------------------------------------------------------------------------------------------------------- ;
ColdStart           subroutine                      ; where it all starts
                    jsr CopyObjectData              ; move object data
                    
                    lda #<(CC_ScreenRoomGfx - $07 * $140) ; start with the non used pointers of a page
                    sta CCZ_GenHiResTabLo           ; 
                    lda #>(CC_ScreenRoomGfx - $07 * $140) ; 
                    sta CCZ_GenHiResTabHi           ; 
                    
                    ldx #($19 * $08)                ; set starting point behind the valid 25 row pointers
.PutTabHiresVal     lda CCZ_GenHiResTabLo           ; table with offsets for graphic output
                    sta CC_TabHiResRowLo,x          ; 
                    lda CCZ_GenHiResTabHi           ; 
                    sta CC_TabHiResRowHi,x          ; 
                    inx                             ; 
                    cpx #($19 * $08)                ; 
                    beq .PrepOptLodScrn             ; 
                    
                    txa                             ; 
                    and #$07                        ; 
                    beq .SetNextHiresRow            ; switch values every 8 bytes
                    
.SetNextHiresCol    inc CCZ_GenHiResTabLo           ; 
                    bne .PutTabHiresVal             ; 
                    inc CCZ_GenHiResTabHi           ; 
                    jmp .PutTabHiresVal             ; 
                    
.SetNextHiresRow    clc                             ; 
                    lda CCZ_GenHiResTabLo           ; 
                    adc #<($28 * $08 - $07)         ; $00 - $27 = $28 (40) colums a $08 bytes
                    sta CCZ_GenHiResTabLo           ; 
                    
                    lda CCZ_GenHiResTabHi           ; 
                    adc #>($28 * $08 - $07)         ; are $140 (320) bytes for each multicolor row 
                    sta CCZ_GenHiResTabHi           ; 
                    jmp .PutTabHiresVal             ; 
                    
                    jsr WarmStart                   ; 
.PrepOptLodScrn     jsr SetLevelScreen              ; set up game options / castle load screen and control table
                    
.SetSaveReplaceHdr  lda #$40                        ; .hbu011. - "@" - overwrite existing file
                    sta CCW_DiskFileReplHdr + 0     ; .hbu011.
                    lda #$30                        ; .hbu011. - "0"
                    sta CCW_DiskFileReplHdr + 1     ; .hbu011.
                    lda #$3a                        ; .hbu011. - ":"
                    sta CCW_DiskFileReplHdr + 2     ; .hbu011.
                    
                    jsr InitHiResSpriteWAs          ; initialize the hires screen and sprite work area
                    
.LoadFirstCastle    ldx #CC_LoadCtrlNoFile * CC_LoadCtrlEntryLen ; load screen ctrl tab offset 1st castle data file name
ColdStartX          jmp MainLoop                    ; 
; ------------------------------------------------------------------------------------------------------------- ;
; CopyObjectData    Function: Copy object data to ObjectStore - make original object storage useable
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
CopyObjectData      subroutine
                    lda #<TabObjectDataOrigin       ; from objects load address
                    sta CCZ_CopyFromLo              ; 
                    lda #>TabObjectDataOrigin       ; 
                    sta CCZ_CopyFromHi
                    
                    lda #<CC_ObjectData             ; to objects target address
                    sta CCZ_CopyTargLo              ; 
                    lda #>CC_ObjectData             ; 
                    sta CCZ_CopyTargHi              ; 
                    
                    ldx #$10                        ; number of pages
                    ldy #$00                        ; number of bytes
.CopyPages          lda (CCZ_CopyFrom),y            ; 
                    sta (CCZ_CopyTarg),y            ; 
                    iny                             ; 
                    bne .CopyPages                  ; 
                    
                    inc CCZ_CopyFromHi              ; set next page
                    inc CCZ_CopyTargHi              ; 
                    
                    dex                             ; number of pages
                    bne .CopyPages                  ; 
                    
CopyObjectDataX     rts                             ; 
; ------------------------------------------------------------------------------------------------------------- ;
; SetLevelScreen    Function: Set up game options and castle load screen / fill the row control table
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
SetLevelScreen      subroutine
                    lda #<CC_ScreenText             ; game options and castle load data
                    sta CCZ_ScreenLoadLo            ; 
                    lda #>CC_ScreenText             ; game options and castle load data
                    sta CCZ_ScreenLoadHi            ; 
                    
                    ldx #$04                        ; number of pages from $0400 - $07ff
                    ldy #$00                        ; number of bytes
                    lda #" "                        ; 
.BlankOut           sta (CCZ_ScreenLoad),y          ; text screen memory blanked out
                    iny                             ; 
                    bne .BlankOut                   ; 
                    
                    inc CCZ_ScreenLoadHi            ; next page
                    dex                             ; page counter
                    bne .BlankOut                   ; 
                    
                    lda #$00                        ; 
                    sta CCW_LoadCtrlTabOffWrk       ; actual screen control table offset
                    
                    lda #<ScreenLineData            ; text game options/level load screen
                    sta CCZ_ScreenLoadFixLo         ; 
                    lda #>ScreenLineData            ; 
                    sta CCZ_ScreenLoadFixHi         ; 
                    
.ScreenLineNext     ldy #ScreenLineCol              ; text line start column
                    lda (CCZ_ScreenLoadFix),y       ; 
                    cmp #ScreenLineDataEnd          ; 
                    beq .SetCursor                  ; all lines displayed
                    
                    ldy #ScreenLineId               ; control table entry number
                    lda (CCZ_ScreenLoadFix),y       ; 
                    cmp #ScreenLineIdNoSelect       ; info lines cannot be cursor selected
                    beq .ScreenLineOutInit          ; bypass setup of a screen control tab entry
                    
                    ldy #$00                        ; start pos in screen row
                    ldx CCW_LoadCtrlTabOffWrk       ; actual screen control table offset
.ScreenCtrlTabFill  lda (CCZ_ScreenLoadFix),y       ; 
                    sta CC_ScreenLoadCtrl,x         ; fill screen control table
                    inx                             ; 
                    iny                             ; screen row number
                    cpy #ScreenLineHeaderLen        ; 
                    bcc .ScreenCtrlTabFill          ; 
                    
                    inx
                    stx CCW_LoadCtrlTabOffWrk       ; actual screen control table offset
                    
.ScreenLineOutInit  ldy #ScreenLineRow              ; screen row number
                    lda (CCZ_ScreenLoadFix),y       ; 
                    tax                             ; 
                    
                    clc                             ; add row number to load screen start position
                    lda TabCtrlScrRowsLo,x          ; 
                    adc #<CC_ScreenText             ; game options and castle load data
                    sta CCZ_ScreenLoadLo            ; 
                    lda TabCtrlScrRowsHi,x          ; 
                    adc #>CC_ScreenText             ; game options and castle load data
                    sta CCZ_ScreenLoadHi            ; 
                    
                    clc                             ; add column number to load screen start position
                    lda CCZ_ScreenLoadLo            ; 
                    ldy #ScreenLineCol              ; screen column nuber
                    adc (CCZ_ScreenLoadFix),y       ; 
                    sta CCZ_ScreenLoadLo            ; 
                    bcc .AddTopRowOffset            ; text doesn't start in row $00
                    inc CCZ_ScreenLoadHi            ; 
                    
.AddTopRowOffset    ldy #$00                        ; first chr
                    clc                             ; 
                    lda CCZ_ScreenLoadFixLo         ; 
                    adc #ScreenLineRowTopOff        ; 
                    sta CCZ_ScreenLoadFixLo         ; 
                    bcc .ScreenLineOut              ; 
                    inc CCZ_ScreenLoadFixHi         ; 
                    
.ScreenLineOut      lda (CCZ_ScreenLoadFixLo),y     ; 
                    and #$3f                        ; ..###### - switch to lower case
                    sta (CCZ_ScreenLoad),y          ; 
                    lda (CCZ_ScreenLoadFix),y       ; 
                    bmi .ScreenLineEnd              ; end of line if capitalized
                    
                    iny                             ; next chr
                    jmp .ScreenLineOut              ; 
                    
.ScreenLineEnd      clc                             ; 
                    iny                             ; 
                    tya                             ; length of this line
                    adc CCZ_ScreenLoadFixLo         ; add to screen pointer
                    sta CCZ_ScreenLoadFixLo         ; 
                    bcc .ScreenLineNext             ; 
                    inc CCZ_ScreenLoadFixHi         ; 
                    
.GoNextLine         jmp .ScreenLineNext             ; 
                    
.SetCursor          ldx CC_LoadCtrlCrsrRow          ; add row number to load screen start position
                    clc                             ; 
                    lda #<CC_ScreenText             ; game options and castle load data
                    adc TabCtrlScrRowsLo,x          ; 
                    sta CCZ_ScreenLoadLo            ; 
                    lda #>CC_ScreenText             ; game options and castle load data
                    adc TabCtrlScrRowsHi,x          ; 
                    sta CCZ_ScreenLoadHi            ; 
                    
                    ldy CC_LoadCtrlCrsrCol          ; 
                    dey                             ; 
                    dey                             ; 
                    lda #">"                        ; mark
                    sta (CCZ_ScreenLoad),y          ; 
                    
                    clc
                    ldx #ScreenLineLives            ; add unlimited lives screen row number to load screen start position
                    lda #<CC_ScreenText             ; game options and castle load data
                    adc TabCtrlScrRowsLo,x          ; 
                    sta CCZ_ScreenLoadLo            ; 
                    lda #>CC_ScreenText             ; game options and castle load data
                    adc TabCtrlScrRowsHi,x          ; 
                    sta CCZ_ScreenLoadHi            ; 
                    
                    ldy #ScreenLineLivesOff - ScreenLineLivesTxt + ScreenLineLivesLoc         ; screen offset start "off"
.MarkLivesOff       lda (CCZ_ScreenLoad),y          ;
                    ora #$80                        ; inverse
                    sta (CCZ_ScreenLoad),y          ; 
                    iny                             ; 
                    cpy ##ScreenLineLivesOff - ScreenLineLivesTxt + ScreenLineLivesLoc + $03  ; screen offset end "off"
                    bcc .MarkLivesOff               ; 
                    
.ReadDirectory      lda #CCW_DiskFileIdDir          ; $0:Z* - all castle data files names start with 'z'
                    sta CCW_DiskFileNameId + 0      ; 
                    lda #"0"                        ; 
                    sta CCW_DiskFileNameId + 1      ; 
                    lda #":"                        ; 
                    sta CCW_DiskFileNameId + 2      ; 
                    lda #CCW_DiskFileIdCastle       ; 
                    sta CCW_DiskFileNameId + 3      ; 
                    lda #"*"                        ; 
                    sta CCW_DiskFileNameId + 4      ; 
                    
                    lda #$05                        ; 
                    sta CCW_DiskFileNameLen         ; 
                    lda #CC_LevelGameID             ; .hbu012.
                    sta CCW_DiskFileTargetId        ; 
                    
                    jsr PrepareIO                   ; 
                    jsr LoadLevelData               ; load z* file names to $7800
                    jsr WarmStart                   ; 
                    
                    lda #<CC_LevelGame              ; .hbu012. - point to directory list output
                    sta CCZ_DirListLo               ; 
                    lda #>CC_LevelGame              ; .hbu012.
                    sta CCZ_DirListHi               ; 
                    
                    lda #CC_LoadCtrlRowDynMin       ; start row of dynamically filled screen area
                    sta CCW_LoadCtrlDynAreaRow      ; 
                    
                    lda #CC_LoadCtrlAreaLe          ; default start column of left output area
                    sta CCW_LoadCtrlDynAreaCol      ; 
                    
.ChkEndOfData       lda CCZ_DirListHi               ; 
                    cmp CCW_DiskFileEndAdrHi        ; address: end of loaded directory data
                    bcc .GetData                    ; lower
                    bne .GoExit                     ; higher - finish
                    
                    lda CCZ_DirListLo               ; equal
                    cmp CCW_DiskFileEndAdrLo        ; address: end of loaded directory data
                    bcs .GoExit                     ; equal or higher - finish
                    
.GetData            ldy #$00                        ; 
                    lda (CCZ_DirList),y             ; from $9800
                    iny                             ; 
                    ora (CCZ_DirList),y             ; 
                    bne .PassHeader                 ; $00 $00 = EndOfDirData
                    
.GoExit             jmp .Exit                       ; finish
                    
.PassHeader         clc                             ; 
                    lda CCZ_DirListLo               ; 
                    adc #$04                        ; header length
                    sta CCZ_DirListLo               ;
                    bcc .FindStart                  ; 
                    inc CCZ_DirListHi               ; 
                    
.FindStart          ldy #$00                        ; 
                    lda (CCZ_DirList),y             ; 
                    bne .ChkStartApost              ; 
                    
                    inc CCZ_DirListLo               ; 
                    bne .ChkEndOfData               ; 
                    inc CCZ_DirListHi               ; 
                    jmp .ChkEndOfData               ; 
                    
.ChkStartApost      cmp #$22                        ; " - name starter char
                    bne .SetNextChr
                    
                    iny                             ; start of filename
                    lda (CCZ_DirList),y             ; get next chr
ChkStart_Z          cmp #"Z"                        ; $5a - sort out the disk name
                    beq .FoundName
                    
.SetNextChr         inc CCZ_DirListLo               ; get next chr
                    bne .FindStart                  ; 
                    inc CCZ_DirListHi               ; 
                    jmp .FindStart                  ; 
                    
.FoundName          ldx CCW_LoadCtrlTabOffWrk       ; actual screen control table offset
                    lda CCW_LoadCtrlDynAreaCol      ; 
                    sta CC_ScreenLoadCtrl,x         ; 
                    
                    lda CCW_LoadCtrlDynAreaRow      ; 
                    sta CC_LoadCtrlRow,x            ; 
                    
                    lda #CC_LoadCtrlIdFile          ; type: dynamic castle data file entry
                    sta CC_LoadCtrlId,x             ; 
                    
                    ldx CCW_LoadCtrlDynAreaRow      ; 
                    clc                             ; 
                    lda TabCtrlScrRowsLo,x          ; 
                    adc #$00                        ; 
                    sta CCZ_ScreenLoadDynLo         ; 
                    lda TabCtrlScrRowsHi,x          ; 
                    adc #$04                        ; 
                    sta CCZ_ScreenLoadDynHi         ; 
                    
                    ldx CCW_LoadCtrlDynAreaCol      ; 
                    dex                             ; 
                    dex                             ; 
                    clc                             ; 
                    txa                             ; 
                    adc CCZ_ScreenLoadDynLo         ; 
                    sta CCZ_ScreenLoadDynLo         ; 
                    bcc .ChkEndApostI               ; 
                    inc CCZ_ScreenLoadDynHi         ; 
                    
.ChkEndApostI       ldy #$02                        ; bypass the "Z
.ChkEndApost        lda (CCZ_ScreenLoad),y          ; 
                    cmp #$22                        ; "
                    beq .StoreFileLen               ; 
                    
                    and #$3f                        ; ..###### - switch to lower case
.ScreenOut          sta (CCZ_ScreenLoadDyn),y       ; 
                    iny                             ; 
                    jmp .ChkEndApost                ; 
                    
.StoreFileLen       ldx CCW_LoadCtrlTabOffWrk       ; actual screen control table offset
                    tya                             ; 
                    sta CC_LoadCtrlFiNamLen,x       ; 
                    dec CC_LoadCtrlFiNamLen,x       ; 
                    
.NextCtrlEntry      inx                             ; 
                    inx                             ; 
                    inx                             ; 
                    inx                             ; each control entry is 4 bytes long
                    stx CCW_LoadCtrlTabOffWrk       ; actual screen control table offset - point to next entry
                    
                    clc                             ; 
                    tya                             ; 
                    adc CCZ_ScreenLoadLo            ; 
                    sta CCZ_ScreenLoadLo            ; 
                    bcc .ChkLeftArea                ; 
                    inc CCZ_ScreenLoadHi            ; 
                    
.ChkLeftArea        lda CCW_LoadCtrlDynAreaCol      ; 
                    cmp #CC_LoadCtrlAreaLe          ; default start column of left  output area
                    bne .SetLeftArea                ; 
                    
.SetRightArea       lda #CC_LoadCtrlAreaRi          ; default start column of right output area
                    sta CCW_LoadCtrlDynAreaCol      ; 
.GoGetNextChr       jmp .SetNextChr                 ; 
                    
.SetLeftArea        lda #CC_LoadCtrlAreaLe          ; 
                    sta CCW_LoadCtrlDynAreaCol      ; 
                    inc CCW_LoadCtrlDynAreaRow      ; 
                    lda CCW_LoadCtrlDynAreaRow      ; 
                    cmp #CC_LoadCtrlRowDynMax       ; end row of dynamically filled screen area
                    bcc .GoGetNextChr
                    
.Exit               ldx CCW_LoadCtrlTabOffWrk       ; actual screen control table offset
                    dex                             ; 
                    dex                             ; 
                    dex                             ; 
                    dex                             ; each control entry is 4 bytes long
                    stx CCW_LoadCtrlTabOffMax       ; save offset of last control data entry
                    
                    lda #CC_LoadCtrlNoLives * CC_LoadCtrlEntryLen ; init pointer to unlim lives on/off entry
                    sta CCW_LoadCtrlTabOffWrk       ; actual screen control table offset
                    
SetLevelScreenX     rts                             ; 
; ------------------------------------------------------------------------------------------------------------- ;
Objects             include inc\CC_DataObjects.asm  ; Object Data and Numbers
; ------------------------------------------------------------------------------------------------------------- ;
