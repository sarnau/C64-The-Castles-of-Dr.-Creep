; ------------------------------------------------------------------------------------------------------------- ;
; The Castles of Dr Creep - OBJECT.PRG: Game Code from $0800 to $7919
; ------------------------------------------------------------------------------------------------------------- ;
; Memory Map
; ------------------------------------------------------------------------------------------------------------- ;
; $0000 - $00ff:  Zero Page Values
; $0200 - $02ff:  <not used>
; $0300 - $03ff:  <not used>
; $0400 - $07e8:  Video Screen 1 - Displays Game Options and Castle Load File Names
;
; $0800 - $77ff:  Game Code - Initial load up to 7919
;
; $7800 - $97ff:  Game Level Data / Demo Music
; $9800 - $b7ff:  Game Store Data
; $b800 - $b8ff:  Best Times
;
; $b900 - $b9ff:  <not used>
; $ba00 - $baff:  Row Control Data for Game Options and Castle Load Screen
; $bb00 - $bbff:  Pointer HiRes Screen Rows: High
; $bc00 - $bcff:  Pointer HiRes Screen Rows: Low
; $bd00 - $bdff:  Sprite         Work Areas - $08 Blocks of $20 Bytes
; $be00 - $beff:  Object Status  Work Areas - $20 Blocks of $08 Bytes
; $bf00 - $bfff:  Object Dynamic Work Areas - $20 Blocks of $08 Bytes
;
; $c000 - $c7ff:  Sprite Move Control Screen
; $c800 - $c9ff:  Sprite Data Area 1
; $ca00 - $cbff:  Sprite Data Area 2
; $cc00 - $cfe8:  Video Screen 2 - Holds Color Values for Multicolour HiRes Screen
; $cff8 - $cfff:  Sprites Data Pointer
; $e000 - $fff9:  Multicolour HiRes Screen
; $fffa - $fffb:  Vector: NMI
; $fffc - $fffd:  Vector: <not set> System Reset
; $fffe - $ffff:  Vector: IRQ
; ------------------------------------------------------------------------------------------------------------- ;
                    * equ $0800                   ; Start address
; ------------------------------------------------------------------------------------------------------------- ;
; compiler settings                                                                                             ;
; ------------------------------------------------------------------------------------------------------------- ;
                    incdir  ..\..\..\inc            ; C64 System Includes
                      
C64CIA1             include cia1.asm                ; Complex Interface Adapter (CIA) #1 Registers  $DC00-$DC0F
C64CIA2             include cia2.asm                ; Complex Interface Adapter (CIA) #2 Registers  $DD00-$DD0F
C64SID              include sid.asm                 ; Sound Interface Device (SID) Registers        $D400-$D41C
C64VicII            include vic.asm                 ; Video Interface Chip (VIC-II) Registers       $D000-$D02E
C64Kernel           include kernel.asm              ; Kernel Vectors
C64Colors           include color.asm               ; Colour RAM Address / Colours
C64Memory           include mem.asm                 ; Memory Layout
;                     
InGameVars          include inc\CC_Vars.asm         ; Loaded Data Mapping
ZeroPage            include inc\CC_Zpg.asm          ; Zero Page Equates
Objects             include inc\CC_Objs.asm         ; Room Item Mapping
WorkAreas           include inc\CC_WAs.asm          ; Work Areas Mapping
ScreenLocs          include inc\CC_Scrns.asm        ; Screen Locations
BestTimes           include inc\CC_Times.asm        ; Best Times Mapping
; ------------------------------------------------------------------------------------------------------------- ;
J_0800              jmp ColdStart
; ------------------------------------------------------------------------------------------------------------- ;
; ID Jump Table -   Dispatched from: PaintRoomItems
; ------------------------------------------------------------------------------------------------------------- ;
ID_03_08            jmp RoomDoor                    ; Door              - wrong initial pointer to $730c
ID_06_08            jmp RoomFloor                   ; Floor             - wrong initial pointer to $246a
ID_09_08            jmp RoomPole                    ; SlidingPole       - wrong initial pointer to $2047
ID_08_08            jmp RoomLadder                  ; Ladder
ID_0f_08            jmp RoomBell                    ; DoorBell          - wrong initial pointer to $752a
ID_12_08            jmp RoomLightMach               ; LighningMachine
ID_15_08            jmp RoomForceFi                 ; ForceField
ID_18_08            jmp RoomMummy                   ; Mummy
ID_1b_08            jmp RoomKey                     ; Key
ID_1e_08            jmp RoomLock                    ; Lock
ID_21_08            jmp RoomDrawObject              ; DrawObject        - never used in castle data
ID_24_08            jmp RoomGun                     ; RayGun
ID_27_08            jmp RoomMatter                  ; MatterTransmitter
ID_2a_08            jmp RoomTrap                    ; TrapDoor
ID_2d_08            jmp RoomWalk                    ; MovingSideWalk
ID_30_08            jmp RoomFrank                   ; Frankenstein
ID_33_08            jmp RoomTextLine                ; TextLine
ID_36_08            jmp RoomGraphic                 ; Graphic
; ------------------------------------------------------------------------------------------------------------- ;
FlgSfxOnOff         .byte $00                       ; switch sound effects off/on $01=off
; ------------------------------------------------------------------------------------------------------------- ;
                    .byte $80                       ; flags not used
                    .byte $40
                    .byte $20
                    .byte $10
; ------------------------------------------------------------------------------------------------------------- ;
ObjWAUseCount       .byte $00                       ; max $20 entries a 08 bytes in object work area
; ------------------------------------------------------------------------------------------------------------- ;
Mask_80_b           .byte $80
Mask_40_b           .byte $40
Mask_20_b           .byte $20
; ------------------------------------------------------------------------------------------------------------- ;
ObjMoveAuto         .word DoorOpen                  ; Object Type $00: Door
ObjMoveManual       .word DoorLeave
                    
                    .word $0000                     ; Object Type $01: Door Bell
                    .word BellPress
                    
                    .word LightMachPole             ; Object Type $02: Lightning Machine Ball
                    .word $0000
                    
                    .word $0000                     ; Object Type $03: Lightning Machine Switch
                    .word LightMachSwitch
                    
                    .word ForceFiClose              ; Object Type $04: Force Field
                    .word ForceFiSwitch
                    
                    .word MummyBirth                ; Object Type $05: Mummy
                    .word MummyTouchAnkh
                    
                    .word $0000                     ; Object Type $06: Key
                    .word KeyPickUp
                    
                    .word $0000                     ; Object Type $07: Lock
                    .word LockOpen
                    
                    .word RayGunMove                ; Object Type $08: Ray Gun
                    .word $0000
                    
                    .word $0000                     ; Object Type $09: Ray Gun Switch
                    .word RayGunSwitch
                    
                    .word MatterTrXmit              ; Object Type $0a: Matter Transmitter Reciever Oval
                    .word MatterTrBooth
                    
                    .word TrapDoorOpen              ; Object Type $0b: Trap Door
                    .word $0000
                    
                    .word $0000                     ; Object Type $0c: Trap Door Switch
                    .word $0000
                    
                    .word SideWalkMove              ; Object Type $0d: Side Walk
                    .word SideWalkStepOn
                    
                    .word $0000                     ; Object Type $0e: Side Walk Switch
                    .word SideWalkSwitch
                    
                    .word $0000                     ; Object Type $0f: Frankenstein
                    .word $0000
; ------------------------------------------------------------------------------------------------------------- ;
Mask_80             .byte $80
Mask_40             .byte $40
Mask_20             .byte $20
Mask_10             .byte $10
Mask_08             .byte $08
Mask_04             .byte $04
Mask_02             .byte $02
Mask_01             .byte $01
; ------------------------------------------------------------------------------------------------------------- ;
Mask_80_a           .byte $80                       ; obsolete
Mask_40_a           .byte $40                       ; obsolete
Mask_20_a           .byte $20                       ; obsolete
Mask_10_a           .byte $10                       ; obsolete
Mask_01_a           .byte $01                       ; obsolete
; ------------------------------------------------------------------------------------------------------------- ;
SprtMove            .word PlayerMove                ; Sprite Type $00: Player
SprtSprtKill        .word PlayerSprtKill            ; Sprite Type $00: Player
SprtBkgrKill        .word PlayerTrapKill            ; Sprite Type $00: Player
TabSprtPrio         .byte $00                       ; Flag: Collision priority $00-low 
TabSprtMortal       .byte $01                       ; Flag: Mortals - 1=Player/Mummy/Frank
                    
                    .word LightMachMove             ; Sprite Type $01: Lightning Machine
                    .word LightMachKill             ; Sprite Type $01: Lightning Machine
                    .word $0000                     ; 
                    .byte $04                       ; Flag: Collision priority $00-low 
                    .byte $00                       ; Flag: Immortals - 0=Light/Force/Gun
                    
                    .word ForceFiMove               ; Sprite Type $02: Force Field
                    .word ForceFiSprtKill           ; Sprite Type $02: Force Field
                    .word $0000                     ; 
                    .byte $03                       ; Flag: Collision priority $00-low 
                    .byte $00                       ; Flag: Immortals - 0=Light/Force/Gun
                    
                    .word MummyMove                 ; Sprite Type $03: Mummy
                    .word MummySprtKill             ; Sprite Type $03: Mummy
                    .word MummyTrapKill             ; Sprite Type $03: Mummy
                    .byte $02                       ; Flag: Collision priority $00-low 
                    .byte $01                       ; Flag: Mortals - 1=Player/Mummy/Frank
                    
                    .word RayBeamMove               ; Sprite Type $04: Ray Gun Beam
                    .word $0000                     ; 
                    .word RayBeamObjKill            ; Sprite Type $04: Ray Gun Beam
                    .byte $04                       ; Flag: Collision priority $00-low 
                    .byte $00                       ; Flag: Immortals - 0=Light/Force/Gun
                    
                    .word FrankMove                 ; Sprite Type $05: Frank N Forter
                    .word FrankSprtKill             ; Sprite Type $05: Frank N Forter
                    .word FrankTrapKill             ; Sprite Type $05: Frank N Forter
                    .byte $00                       ; Flag: Collision priority $00-low 
                    .byte $01                       ; Flag: Mortals - 1=Player/Mummy/Frank
                    
                    .byte $80                       ; EndOfJumpTab / TabValues
; ------------------------------------------------------------------------------------------------------------- ;
Mask_80_c           .byte $80
Mask_40_c           .byte $40
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
ColdStart           lda #$40
                    sta $30
                    lda #$d7
                    sta $31
                    
                    ldx #$c8
.PutTabHiresVal     lda $30                         ; table with offsets for graphic output
                    sta CC_TabHiResRowLo,x
                    lda $31
                    sta CC_TabHiResRowHi,x
                    inx
                    cpx #$c8
                    beq .SetTabCtrlOffI
                    
                    txa
                    and #$07
                    beq .SetNextHiresRow            ; switch values evey 8 bytes
                    
.SetNextHiresCol    inc $30
                    bne .PutTabHiresVal
                    inc $31
                    jmp .PutTabHiresVal
                    
.SetNextHiresRow    clc
                    lda $30
                    adc #$39
                    sta $30
                    lda $31
                    adc #$01                        ; $140 bytes for each multicolor row 
                    sta $31
                    
                    jmp .PutTabHiresVal
                    
.SetTabCtrlOffI     lda #$00
                    sta $30
                    sta $31
                    
                    ldx #$00
.SetNextCtrlRow     lda $30                         ; table with offsets for control data output
                    sta TabCtrlScrRowsLo,x
                    lda $31
                    sta TabCtrlScrRowsHi,x
                    
                    clc
                    lda $30
                    adc #$28                        ; next screen row low
                    sta $30
                    bcc .SetNextCtrlCol                  
                    inc $31                         ; next screen row high
                    
.SetNextCtrlCol     inx
                    cpx #$20
                    bcc .SetNextCtrlRow
                    
                    jsr Restart                     ; was: jsr S_2c10 (whole section $2c10-$2e1b with len $20b obsolete)
                    jsr SetLvlLoadScrn
                    
                    lda FlgSfxOnOff
                    cmp #$01                        ; off
                    beq .GetLevelData               ; no sound effects
                    
.CpySoundsI         lda #<SetLvlLoadScrn
                    sta $30
                    lda #>SetLvlLoadScrn
                    sta $31
                    lda #<TabSoundsDataCpy
                    sta $32
                    lda #>TabSoundsDataCpy
                    
                    sta $33
                    ldy #$00
.CpySounds          lda ($32),y                     ; copy from $77f7 - $7af7
                    sta ($30),y                     ;      to   $7572 - $7872: kill SetLvlLoadScrn - real end at $7694
                    iny
                    bne .CpySounds
                    
                    inc $31
                    inc $33
                    lda $31
                    cmp #$78
                    bcc .CpySounds
                    
                    ldx #$10                        ; screen entry number first castle data file name
                    jsr LoadCastleData              ; normally: zTutorial / yTutorial
                    jmp .SetColdReady
                    
.GetLevelData       jsr CpyLod2GmeLvl               ; get a fresh copy of castle data from load store
                    
.SetColdReady       lda #$00
                    sta FlgColdReady
                    
ColdStartX          jmp MainLoop
; ------------------------------------------------------------------------------------------------------------- ;
FlgColdReady        .byte $01
; ------------------------------------------------------------------------------------------------------------- ;
; Restart           Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
Restart             pha
                    txa
                    pha
                    
                    lda #$00
                    sta SCROLY                      ; VIC 2 - $D011 = VIC Control Register 1 (and Vertical Fine Scrolling)
                    
                    sei                             ; interrupts off
                    
                    lda #$7f
                    sta CI2ICR                      ; CIA 2 - $DD0D = Interrupt Control Register
                    lda CI2ICR                      ; CIA 2 - $DD0D = Interrupt Control Register
                    
                    lda #$07
                    sta $00                         ; D6510 - CPU Port Data Direction Register
                    lda #$05                        ; 
                    sta $01                         ; R6510 - CPU Port Data Register -> basic=off io=on kernel=off
                    
                    lda #<IRQ
                    sta VBRK                        ; KERNEL - $FFFE = Maskable Interrupt Request / Break Hardware Vector
                    lda #>IRQ
                    sta VBRK + 1                    ; IRQ vector
                    
                    lda #<NMI
                    sta VNMI                        ; KERNEL - $FFFA = Non-Maskable Interrupt Hardware Vector
                    lda #>NMI
                    sta VNMI + 1                    ; NMI vector
                    
                    ldx #$00
                    lda #$20
.SetSprtDataPtr     sta $26,x                       ; CC_ZPgSprt__DatP - data pointers sprite 0-7 to $20-$27
                    inx
                    cpx #$08
                    bcs .InitIO
                    
                    adc #$01
                    jmp .SetSprtDataPtr
                    
.InitIO             lda #$18                        ; Bit4: 1=multicolor bitmap mode  Bit 3: 1=40 columns
                    sta SCROLX                      ; VIC 2 - $D016 = Control Register 2 (and Horizontal Fine Scrolling)
                    sta $25                         ; CC_ZPgVICControl
                    
                    lda #$00
                    sta RASTER                      ; VIC 2 - $D012 = Read: Raster Scan Line / Write: Line for Raster IRQ
                    
                    lda #$30                        ; Bits 4-7: Screen base address: 3=$0c00-$0fe7 + base in $DD00 ($c000-$ffff)
                    and #$f0                        ; 
                    ora #$08                        ; Bits 2-3: Bitmap base address: 4=$2000-$27ff + base in $DD00 ($c000-$ffff)
                    sta $22                         ; CC_ZPgVICMemCtrl
                    
                    lda #$01
                    sta IRQMASK                     ; VIC 2 - $D01A = IRQ Mask
                    
                    lda #$ff
                    sta VICIRQ                      ; VIC 2 - $D019 = VIC Interrupt Flag - 1=clear latched flag
                    
                    lda #$00
                    sta $23                         ; CC_ZPgColrBorder
                    sta SavBkgrColor
                    
                    lda #$0a
                    sta SPMC0                       ; VIC 2 - $D025 = Sprite Multicolor Register 0
                    
                    lda #$0d
                    sta SPMC1                       ; VIC 2 - $D026 = Sprite Multicolor Register 1
                    
                    lda #$03
                    sta C2DDRA                      ; CIA 2 - $DD02 = Data Direction A
                    
                    lda #$00
                    sta CI2PRA                      ; CIA 2 - $DD00 = Data Port A  Bits 0-1: 00 = $c000-$ffff - VIC-II chip mem bank 3
                    
                    lda #$00
                    sta CIACRA                      ; CIA 1 - $DC0E = Control A
                    sta CI2CRA                      ; CIA 2 - $DD0E = Control A
                    sta CIACRB                      ; CIA 1 - $DC0F = Control B
                    sta CI2CRB                      ; CIA 2 - $DD0F = Control B
                    
                    lda #$7f
                    sta CIAICR                      ; CIA 1 - $DC0D = Interrupt Control
                    lda CIAICR                      ; CIA 1 - $DC0D = Interrupt Control
                    
                    cli                             ; interrupts on
                    
                    lda #$01
                    cmp FlgSkip
                    beq .InitTimer
                    
                    sta FlgSkip
                    lda #$ff
                    sta $21                         ; CC_ZPgSprt__Enab - sprites 0-7 enable
                    
                    lda #$02
                    sta WrkCountIRQs                ; counted down to $00 with every IRQ
.Wait               lda WrkCountIRQs                ; counted down to $00 with every IRQ
                    bne .Wait
                    
.InitTimer          lda #$00
                    sta $21                         ; CC_ZPgSprt__Enab - sprites 0-7 enable
                    
                    lda #$3b                        ; Bit 5: 1=bitmap graphics  Bit 4: 1=unblank screen  Bit 3: 1=25 row display
                    sta SCROLY                      ; VIC 2 - $D011 = VIC Control Register 1 (and Vertical Fine Scrolling)
                    
                    lda #$ff
                    sta TIMALO                      ; CIA 1 - $DC04 = Timer A (low byte)
                    
                    lda WrkTime
                    asl a
                    asl a                           ; *4
                    ora #$03
                    sta TIMAHI                      ; CIA 1 - $DC05 = Timer A (high byte)
                    
                    lda #$ff
                    sta WrkSFX
                    
                    lda FlgPlayDemoMusic
                    cmp #$01
                    bne RestartX
                    
                    ldx #$18
.InitSid            lda TabVoice01Vals,x
                    sta FRELO1,x                    ; SID - $D400 = Oscillator 1 Frequency Control (low byte)
                    dex
                    bpl .InitSid
                    
                    lda #$81
                    sta CIAICR                      ; CIA 1 - $DC0D = Interrupt Control
                    lda #$01
                    sta CIACRA                      ; CIA 1 - $DC0E = Control A
                    
RestartX            pla
                    tax
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
FlgSkip             .byte $00
; ------------------------------------------------------------------------------------------------------------- ;
; CpyLod2GmeLvl     Function: Get a fresh copy of level data from level load store
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
CpyLod2GmeLvl       pha
                    tya
                    pha
                    
                    ldy #$00
                    lda #<CC_LvlGame
                    sta $30
                    lda #>CC_LvlGame                ; copy level data
                    sta $31
                    
                    lda #<CC_LvlStor
                    sta $32
                    lda #>CC_LvlStor
                    sta $33
                    
                    lda CC_LvlLastPGame             ; $7800 : no of bytes in last page  (counter starts at 1)
                    sta $34
                    lda CC_LvlPagesGame             ; $7801 : no of pages  max: 20      (whole data must fit into 7800 - 97ff)
                    sta $35
                    beq .CopyLastPage               ; no page data to copy
                    
.CopyPages          lda ($30),y                     ; from $9800-
                    sta ($32),y                     ; to   $7800-
                    iny
                    bne .CopyPages
                    
                    inc $31
                    inc $33
                    dec $35                         ; number of pages
                    bne .CopyPages
                    
.CopyLastPage       cpy $34
                    beq CpyLod2GmeLvlX              ; no more data in last page
                    
                    lda ($30),y                     ; from $9800-
                    sta ($32),y                     ; to   $7800-
                    iny
                    jmp .CopyLastPage
                    
CpyLod2GmeLvlX      pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
; IRQ Routine       Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
IRQ                 pha                             ; Maskable Interrupt Request
                    tya
                    pha
                    txa
                    pha
                    
                    cld
                    lda VICIRQ                      ; VIC 2 - $D019 = VIC Interrupt Flag - 1=clear latched flag
                    and #$01                        ; raster compare
                    bne .ClearRaster
                    
                    jmp .ChkRaster
                    
.ClearRaster        lda VICIRQ                      ; VIC 2 - $D019 = VIC Interrupt Flag - 1=clear latched flag
                    sta VICIRQ                      ; clear
                    
.SetExitLayout      ldx PtrBkgrColor
                    lda SavBkgrColor,x
                    
                    nop
                    nop
                    nop
                    nop
                    nop
                    nop
                    
                    sta BGCOL0                      ; VIC 2 - $D021 = Background Color 0
                    
                    cpx #$00
                    beq .MoveSprites
                    
                    jmp .SetExitColor
                    
.MoveSprites        lda $10                         ; CC_ZPgSprt00PosX
                    sta SP0X                        ; VIC 2 - $D000 = Sprite 0 PosX
                    lda $11                         ; CC_ZPgSprt00PosX
                    sta SP1X                        ; VIC 2 - $D002 = Sprite 1 PosX
                    lda $12                         ; CC_ZPgSprt00PosX
                    sta SP2X                        ; VIC 2 - $D004 = Sprite 2 PosX
                    lda $13                         ; CC_ZPgSprt00PosX
                    sta SP3X                        ; VIC 2 - $D006 = Sprite 3 PosX
                    lda $14                         ; CC_ZPgSprt00PosX
                    sta SP4X                        ; VIC 2 - $D008 = Sprite 4 PosX
                    lda $15                         ; CC_ZPgSprt00PosX
                    sta SP5X                        ; VIC 2 - $D00A = Sprite 5 PosX
                    lda $16                         ; CC_ZPgSprt00PosX
                    sta SP6X                        ; VIC 2 - $D00C = Sprite 6 PosX
                    lda $17                         ; CC_ZPgSprt00PosX
                    sta SP7X                        ; VIC 2 - $D00E = Sprite 7 PosX
                    lda $18                         ; CC_ZPgSprt00PosY
                    
                    sta SP0Y                        ; VIC 2 - $D001 = Sprite 0 PosY
                    lda $19                         ; CC_ZPgSprt00PosY
                    sta SP1Y                        ; VIC 2 - $D003 = Sprite 1 PosY
                    lda $1a                         ; CC_ZPgSprt00PosY
                    sta SP2Y                        ; VIC 2 - $D005 = Sprite 2 PosY
                    lda $1b                         ; CC_ZPgSprt00PosY
                    sta SP3Y                        ; VIC 2 - $D007 = Sprite 3 PosY
                    lda $1c                         ; CC_ZPgSprt00PosY
                    sta SP4Y                        ; VIC 2 - $D009 = Sprite 4 PosY
                    lda $1d                         ; CC_ZPgSprt00PosY
                    sta SP5Y                        ; VIC 2 - $D00B = Sprite 5 PosY
                    lda $1e                         ; CC_ZPgSprt00PosY
                    sta SP6Y                        ; VIC 2 - $D00D = Sprite 6 PosY
                    lda $1f                         ; CC_ZPgSprt00PosY
                    sta SP7Y                        ; VIC 2 - $D00F = Sprite 7 PosY
                    
                    lda $20                         ; CC_ZPgSprt__MSBY
                    sta MSIGX                       ; VIC 2 - $D010 = MSBs Sprites 0-7 PosX
                    
.EnabSprites        lda $21                         ; CC_ZPgSprt__Enab
                    sta SPENA                       ; VIC 2 - $D015 = Sprite Enable
                    
.SetVICMemory       lda $22                         ; CC_ZPgVICMemCtrl
                    sta VMCSB                       ; VIC 2 - $D018 = VIC-II Chip Memory Control
                    
                    lda $23                         ; CC_ZPgColrBorder
                    sta EXTCOL                      ; VIC 2 - $D020 = Border Color
                    lda SavBkgrColor
                    sta BGCOL0                      ; VIC 2 - $D021 = Background Color 0
                    
                    lda $25                         ; CC_ZPgVICControl
                    sta SCROLX                      ; VIC 2 - $D016 = Control Register 2 (and Horizontal Fine Scrolling)
                    
.SetSpritePtr       lda $26                         ; CC_ZPgSprt00DatP
                    sta CC_SprtPtr00                ; SCREEN - sprite 0 data pointer
                    lda $27                         ; CC_ZPgSprt01DatP
                    sta CC_SprtPtr01                ; SCREEN - sprite 1 data pointer
                    lda $28                         ; CC_ZPgSprt02DatP
                    sta CC_SprtPtr02                ; SCREEN - sprite 2 data pointer
                    lda $29                         ; CC_ZPgSprt03DatP
                    sta CC_SprtPtr03                ; SCREEN - sprite 3 data pointer
                    lda $2a                         ; CC_ZPgSprt04DatP
                    sta CC_SprtPtr04                ; SCREEN - sprite 4 data pointer
                    lda $2b                         ; CC_ZPgSprt05DatP
                    sta CC_SprtPtr05                ; SCREEN - sprite 5 data pointer
                    lda $2c                         ; CC_ZPgSprt06DatP
                    sta CC_SprtPtr06                ; SCREEN - sprite 6 data pointer
                    lda $2d                         ; CC_ZPgSprt07DatP
                    sta CC_SprtPtr07                ; SCREEN - sprite 7 data pointer
                    
.DecIRQCounter      lda WrkCountIRQs                ; counted down to $00 with every IRQ
                    beq .SetExitColor
                    
                    dec WrkCountIRQs                ; counted down to $00 with every IRQ
                    
.SetExitColor       inx
                    inx
                    cpx MaxBkgrColor                ; set in EscapeHandler to $06
                    beq .GetScanLine
                    bcc .GetScanLine
                    
                    ldx #$00
.GetScanLine        lda TabExitScrnVals,x
                    sta RASTER                      ; VIC 2 - $D012 = Read: Raster Scan Line / Write: Line for Raster IRQ
                    stx PtrBkgrColor
                    
.ChkRaster          lda CIAICR                      ; CIA 1 - $DC0D = Interrupt Control
                    and #$01
                    beq IRQX
                    
                    jsr IRQ_SFX                     ; handle sfx
                    
IRQX                pla
                    tax
                    pla
                    tay
                    pla
                    rti
; ------------------------------------------------------------------------------------------------------------- ;
PtrBkgrColor        .byte $00
MaxBkgrColor        .byte $00
SavBkgrColor        .byte $00
                    
TabExitScrnVals     .byte $00                       ; standard background layout for all exit screens
                    
                    .byte DK_GREY
                    .byte $a2                       ; raster scan line: start DK_GREY
                    .byte BROWN
                    .byte $ca                       ; raster scan line: start BROWN
                    .byte DK_GREY
                    .byte $d2                       ; raster scan line: start DK_GREY
; ------------------------------------------------------------------------------------------------------------- ;
; NMI Routine       Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
NMI                 pha
                    
                    lda #$01
                    sta FlgRestoreKey               ; restore key pressed  01=pressed
                    
                    pla
                    rti
; ------------------------------------------------------------------------------------------------------------- ;
FlgRestoreKey       .byte $00
; ------------------------------------------------------------------------------------------------------------- ;
; MainLoop          Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
MainLoop            jsr DemoHandler
                    jsr GameHandler
                    jmp MainLoop
; ------------------------------------------------------------------------------------------------------------- ;
; DemoHandler       Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
DemoHandler         pha
                    tya
                    pha
                    txa
                    pha
                    
.DemoI              lda #$00
                    sta FlgNextSong
                    lda #$03
                    sta SavDemoShowTitle            ; title screen after every 03 rooms
                    lda #CC_LvlStorID
                    sta FlgRoomLoadAdr              ; $00=$7800 $01=$9800 $02=$b800
                    
                    lda #$00
                    sta SavNumFirePress
                    sta SavDemoRoomNo
                    
.Demo               inc SavDemoShowTitle            ; false - demo doesn't start with room one
                    lda SavDemoShowTitle
                    and #$03                        ; isolate Bits: 0-1
                    sta SavDemoShowTitle
                    beq .ShowTitle
                    
                    inc SavDemoRoomNo
                    lda SavDemoRoomNo
                    jsr SetRoomShapePtr
                    
                    ldy #CC_RoomColor
                    lda ($42),y                     ; RoomDataPtr
                    bit Mask_40_c                   ; CC_EoRoomData - end of room data
                    beq .PaintRoom
                    
                    lda #$00
                    sta SavDemoRoomNo               ; restart at first room
                    
.PaintRoom          jsr PaintRoom
                    
                    jmp .ScreenOn
                    
.ShowTitle          jsr InitHiResSprtWA             ; initialize the hires screen and sprite work area
                    
                    lda #<RoomTitleScreen
                    sta $3e
                    lda #>RoomTitleScreen
                    sta $3f
.PaintTitle         jsr PaintRoomItems
                    
.ScreenOn           lda SCROLY                      ; VIC 2 - $D011 = VIC Control Register 1 (and Vertical Fine Scrolling)
                    ora #$10                        ;   Bit 4: screen background color   1=visible again
                    sta SCROLY                      ; VIC 2 - $D011 = VIC Control Register 1 (and Vertical Fine Scrolling)
                    
                    lda FlgPlayDemoMusic
                    cmp #$01
                    beq .SetTitleWait
                    
                    lda SavDemoShowTitle
                    bne .SetTitleWait
                    
                    lda FlgNextSong
                    bne .SetNextSongNo
                    inc FlgNextSong
                    
.SetTitleWait       lda #$c8
                    sta WrkDemoTitleWait
                    
.ChkTitle           lda SavDemoShowTitle
                    beq .Wait
                    
                    jsr ActionHandler
                    
                    jmp .GetKeyJoyVal
                    
.Wait               lda WrkCountIRQs                ; counted down to $00 with every IRQ
                    bne .Wait                  
                    lda #$02
                    sta WrkCountIRQs                ; reeinit to default
                    
.GetKeyJoyVal       lda SavNumFirePress
                    jsr GetKeyJoyVal
                    
                    lda FlgJoyFire
                    beq .ChkKeyStop                 ; 0=not pressed
                    
.ExitDemo           jmp .ExitDemoOnFire             ; 1=FIRE
                    
.ChkKeyStop         lda SavNumFirePress
                    eor #$01
                    sta SavNumFirePress
                    
                    lda FlgKeyStop
                    cmp #$01
                    beq .ShowLodOptScrn
                    
                    dec WrkDemoTitleWait
                    bne .ChkTitle
                    
                    jmp .Demo
                    
.ShowLodOptScrn     jsr TxtScrnHandler             ; set options / load castle data screen handler
                    
                    lda SavResumeResult
                    cmp #$01
                    beq .ExitDemo
                    
                    jmp .DemoI
                    
.SetNextSongNo      inc SavDemoMusicNo
                    ldx #$06
                    stx LoadFileNamLen
.CopySongName       dex
                    bmi .SetSongLoadAdr
                    
                    lda SavDemoMusicName,x
                    sta LoadFileNameId,x
                    jmp .CopySongName
                    
.SetSongLoadAdr     lda #$00
                    sta LoadFileAdrFlag             ; entry 1: $7800
                    
                    jsr PrepareIO
                    jsr VerifyDisk                  ; obsolete 
                    
                    cmp #$00
                    bne .SongLoadBad
                    
.SongLoadRetry      jsr LoadLevelData
                    jsr READST                      ; KERNEL - $FFB7 = read I/O status word
                    
                    cmp #$40                        ; EndOfData input file
                    beq .GoWaitRestart
                    
                    lda SavDemoMusicNo
                    cmp #$30
                    beq .SongLoadBad
                    
                    lda #$30
                    sta SavDemoMusicNo
                    sta LoadFileMusicNo
                    jmp .SongLoadRetry
                    
.SongLoadBad        lda #$24
                    sta CC_LvlXPicFlag
                    
.GoWaitRestart      jsr WaitRestart
                    
                    lda #$02
                    sta $44
                    lda #$78
                    sta $45
                    
                    ldx #$0e
.InitOsc_123        lda TabVoice01Ctrl,x
                    and #$fe
                    sta TabVoice01Ctrl,x
                    sta VCREG1,x                    ; SID - $D404 = Oscillator 1 Control
                    
                    sec
                    txa
                    sbc #$07
                    tax
                    bcs .InitOsc_123
                    
                    lda TabSidRes
                    and #$f0
                    sta RESON                       ; SID - $D417 = Filter Resonance Control
                    sta TabSidRes
                    
                    lda #$00
                    sta WrkCutLoCtrl02
                    sta WrkCutLoCtrl03
                    
                    lda #$14
                    sta WrkTime
                    asl a
                    asl a
                    ora #$03
                    sta TIMAHI                      ; CIA 1 - $DC05 = Timer A (high byte)
                    
                    lda #$01
                    sta FlgPlayDemoMusic
                    
                    lda #$81
                    sta CIAICR                      ; CIA 1 - $DC0D = Interrupt Control
                    lda #$01
                    sta CIACRA                      ; CIA 1 - $DC0E = Control A
                    jmp .Demo
                    
.ExitDemoOnFire     lda #$00
                    sta FlgPlayDemoMusic
                    
                    lda #CC_LvlGameID
                    sta FlgRoomLoadAdr              ; $00=$7800 $01=$9800 $02=$b800
                    
                    lda #$00
                    sta CIACRA                      ; CIA 1 - $DC0E = Control A
                    
                    lda #$7f
                    sta CIAICR                      ; CIA 1 - $DC0D = Interrupt Control
                    lda CIAICR                      ; CIA 1 - $DC0D = Interrupt Control
                    
                    ldx #$0e
.InitOsc_123Fire    lda TabVoice01Ctrl,x
                    and #$fe
                    sta TabVoice01Ctrl,x
                    sta VCREG1,x                    ; SID - $D404 = Oscillator 1 Control
                    
                    sec
                    txa
                    sbc #$07
                    tax
                    bcs .InitOsc_123Fire
                    
DemoHandlerX        pla
                    tax
                    pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
SavDemoShowTitle    .byte $85
FlgRoomLoadAdr      .byte $00
SavNumFirePress     .byte $a0
SavDemoRoomNo       .byte $b0
WrkDemoTitleWait    .byte $a0
SavDemoMusicName    .byte $4d                       ; music
                    .byte $55
                    .byte $53
                    .byte $49
                    .byte $43
SavDemoMusicNo      .byte $30                       ; 0
FlgNextSong         .byte $ff
; ------------------------------------------------------------------------------------------------------------- ;
RoomTitleScreen     .word RoomDrawObject
                    
                    .byte $08                       ; NumObjects: 8
                    .byte NoObjDoorNormal           ; ObjectID  :     = Door
                    .byte $10                       ; StartPos  : Col = 10
                    .byte $58                       ; StartPos  : Row = 58
                    .byte $14                       ; NextPos   : Col + 14
                    .byte $00                       ; NextPos   : Row + 00
                    .byte $00                       ; EndOfData
                    
                    .byte $6d
                    .byte $2a                       ; pointer to $2a6d - Room: TextLine
                    
                    .byte $28                       ; StartPos  : Col = 28
                    .byte $30                       ; StartPos  : Row = 30
                    .byte ORANGE                    ; ColorNo   :
                    .byte $21                       ; Format    : 21 = normal/normal size
                    .byte $54                       ; Text      : (max 20 chr) = the castles oF
                    .byte $48
                    .byte $45
                    .byte $20
                    .byte $43
                    .byte $41
                    .byte $53
                    .byte $54
                    .byte $4c
                    .byte $45
                    .byte $53
                    .byte $20
                    .byte $4f
                    .byte $c6                       ; EndOfLine = Bit 7 set
                    
                    .byte $30                       ; StartPos  : Col = 30
                    .byte $40                       ; StartPos  : Row = 40
                    .byte LT_GREEN                  ; ColorNo   :
                    .byte $22                       ; Format    : 22 = normal/double size
                    .byte $44                       ; Text      : (max 20 chr) = doctor creeP
                    .byte $4f
                    .byte $43
                    .byte $54
                    .byte $4f
                    .byte $52
                    .byte $20
                    .byte $43
                    .byte $52
                    .byte $45
                    .byte $45
                    .byte $d0                       ; EndOfLine = Bit 7 set
                    
                    .byte $34                       ; StartPos  : Col = 34
                    .byte $80                       ; StartPos  : Row = 80
                    .byte YELLOW                    ; ColorNo   :
                    .byte $21                       ; Format    : 21 = normal/normal size
                    .byte $42                       ; Text      : (max 20 chr) = by ed hobbS
                    .byte $59
                    .byte $20
                    .byte $45
                    .byte $44
                    .byte $20
                    .byte $48
                    .byte $4f
                    .byte $42
                    .byte $42
                    .byte $d3                       ; EndOfLine = Bit 7 set
                    
                    .byte $10                       ; StartPos  : Col = 10
                    .byte $c0                       ; StartPos  : Row = c0
                    .byte GREY                      ; ColorNo   :
                    .byte $21                       ; Format    : 21 = normal/normal size
                    .byte $42                       ; Text      : (max 20 chr) = br0derbund  softwarE
                    .byte $52
                    .byte $30
                    .byte $44
                    .byte $45
                    .byte $52
                    .byte $42
                    .byte $55
                    .byte $4e
                    .byte $44
                    .byte $20
                    .byte $20
                    .byte $53
                    .byte $4f
                    .byte $46
                    .byte $54
                    .byte $57
                    .byte $41
                    .byte $52
                    .byte $c5                       ; EndOfLine = Bit 7 set
                    
                    .byte $00                       ; EndOfText
                    
                    .byte $00                       ; EndOfData
                    .byte $00
; ------------------------------------------------------------------------------------------------------------- ;
; GameHandler       Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
GameHandler         pha
                    tya
                    pha
                    txa
                    pha
                    
                    lda SavResumeResult
                    cmp #$01
                    bne .CopyGameLevelI
                    
                    lda #$00
                    sta SavResumeResult
                    
                    lda CC_LvlXPicFlag
                    ora #$01
                    sta CC_LvlXPicFlag
                    jmp .ChkP_Health
                    
.CopyGameLevelI     ldy #$00
                    
                    lda #<CC_LvlStor
                    sta $30
                    lda #>CC_LvlStor
                    sta $31
                    lda #<CC_LvlGame
                    sta $32
                    lda #>CC_LvlGame                ; copy level data
                    sta $33
                    
                    lda CC_LvlLastPSave             ; $9800 : no of bytes in last page  (counter starts at 1)
                    sta $34
                    lda CC_LvlPagesSave             ; $9801 : no of pages  max: 20      (whole data must fit into 7800 - 97ff)
                    sta $35
                    beq .CopyGameLevelLP
                    
.CopyGameLevel      lda ($30),y                     ; from  CC_LvlLastPSave = $9800
                    sta ($32),y                     ; to    CC_LvlLastPGame = $7800
                    iny
                    bne .CopyGameLevel
                    
                    inc $31
                    inc $33
                    dec $35
                    bne .CopyGameLevel
                    
.CopyGameLevelLP    cpy $34
                    beq .SetPlayer2
                    
                    lda ($30),y
                    sta ($32),y
                    iny
                    jmp .CopyGameLevelLP
                    
.SetPlayer2         lda SavNumFirePress
                    sta CC_LvlP2Active              ; $7812 : player 2 pressed fire at start
                    
                    ldy #$07
                    lda #$00
.InitTime           sta CC_LvlP1TimMil,y            ; $7855 : milliseconds
                    dey
                    bpl .InitTime
                    
                    lda #$00
                    sta CC_LvlP1AtDoor
                    sta CC_LvlP2AtDoor
                    lda CC_LvlP1StrtRoom            ; $7803 : count start: entry 00 of ROOM list
                    sta CC_LvlP1TargRoom            ; $7809 : count start: entry 00 of ROOM list
                    lda CC_LvlP2StrtRoom            ; $7804 : count start: entry 00 of ROOM list
                    sta CC_LvlP2TargRoom            ; $780a : count start: entry 00 of ROOM list
                    lda CC_LvlP1StrtDoor            ; $7805 : count start: entry 00 of Room DOOR list
                    sta CC_LvlP1TargDoor            ; $780b : count start: entry 00 of Room DOOR list
                    lda CC_LvlP2StrtDoor            ; $7806 : count start: entry 00 of Room DOOR list
                    sta CC_LvlP2TargDoor            ; $780c : count start: entry 00 of Room DOOR list
                    
                    lda #$00
                    sta CC_LvlP1Active              ; $7812 : player 1 pressed fire at start
                    
                    lda #CC_LVLP_Alive
                    sta CC_LvlP1Health              ; $780f : 00=dead  01=alive
                    
                    lda CC_LvlP2Active              ; $7812 : player 2 pressed fire at start
                    cmp #CC_LVLP_In
                    beq .MarkP2ALive
                    
.MarkP2Dead         lda #CC_LVLP_Dead
                    sta CC_LvlP2Health              ; $7810 : 00=dead  01=alive
                    
                    lda #CC_LVLP_Inactive           ; player 2 does not participate
                    sta CC_LvlP2Status
                    jmp .ChkP_Health
                    
.MarkP2ALive        lda #CC_LVLP_Alive
                    sta CC_LvlP2Health              ; $7810 : 00=dead  01=alive
                    
.ChkP_Health        lda CC_LvlP1Health              ; $780f : 00=dead  01=alive
                    cmp #CC_LVLP_Alive
                    beq .ChkP1Alive01
                    
                    lda CC_LvlP2Health              ; $7810 : 00=dead  01=alive
                    cmp #CC_LVLP_Alive
                    beq .ChkP1Alive01
                    
.AllPlayersDead     jmp GameHandlerX
                    
.ChkP1Alive01       lda CC_LvlP1Health              ; $780f : 00=dead  01=alive
                    cmp #CC_LVLP_Alive
                    bne .ChkP1Alive02
                    
.ChkP2Alive         lda CC_LvlP2Health              ; $7810 : 00=dead  01=alive
                    cmp #CC_LVLP_Alive
                    bne .ChkP1Alive02
                    
.ChkSameRoom        lda CC_LvlP1TargRoom            ; $7809 : count start: entry 00 of ROOM list
                    cmp CC_LvlP2TargRoom            ; $780a : count start: entry 00 of ROOM list
                    bne .SetDiffRooms
                    
.SetSameRoom        lda #$01                        ; 01=yes - both players enter the same room
                    sta FlgP1CanEnter
                    sta FlgP2CanEnter
                    jmp .HandleMapRooms             ; show map / handle rooms
                    
.SetDiffRooms       ldx CC_LvlP1Active              ; both players enter different rooms
                    lda #$00                        ; 00=no
                    sta FlgP_CanEnter,x
                    txa
                    eor #$01                        ; flip player
                    tax
                    lda #$01                        ; 01=yes
                    sta FlgP_CanEnter,x
                    jmp .HandleMapRooms             ; show map / handle rooms
                    
.ChkP1Alive02       lda CC_LvlP1Health              ; $780f : 00=dead  01=alive
                    cmp #CC_LVLP_Alive
                    beq .OnlyP1Enters
                    
.OnlyP2Enters       lda #$01                        ; player one already dead
                    sta FlgP2CanEnter
                    lda #$00                        ; 00=no
                    sta FlgP1CanEnter
                    jmp .HandleMapRooms             ; show map / handle rooms
                    
.OnlyP1Enters       lda #$01                        ; yes
                    sta FlgP1CanEnter
                    lda #$00
                    sta FlgP2CanEnter
                    
.HandleMapRooms     jsr MapHandler
                    jsr RoomHandler
                    jsr InitHiResSprtWA             ; initialize the hires screen and sprite work area
                    
                    lda #$00
                    sta FlgGameOverP_
                    
                    ldx #$00                        ; player one
.HandlePlayers      lda FlgP_CanEnter,x
                    cmp #$01                        ; 01=yes
                    bne .SetNextPlayer
                    
                    lda CC_LvlP_Status,x
                    cmp #CC_LVLP_Accident
                    beq .ChkUnlimLives
                    
                    lda CC_LvlP1AtDoor,x
                    cmp #$01
                    bne .SetNextPlayer
                    
                    stx SavGamePlayerNo
                    jsr EscapeHandler
                    
                    lda CC_LvlXPicFlag
                    and #$01
                    bne .SetP_Dead
                    
                    lda UnlimLivesOnOff
                    cmp #$ff
                    beq .SetP_Dead
                    
                    lda OldDatScrnTabOff
                    cmp #$ff
                    beq .SetP_Dead
                    
                    txa
                    asl a
                    asl a                           ; *4
                    
                    clc
                    adc #<CC_LvlP_Times ; $55
                    sta $30
                    lda #>CC_LvlP_Times ; $78
                    adc #$00
                    sta $31
                    
                    ldy #$03
.CpyBestTime        lda ($30),y
                    sta SavBestTimeAka,y
                    dey
                    bpl .CpyBestTime
                    
                    stx SavBestTimePNo
                    jsr NewBestTime
                    
                    jmp .SetP_Dead
                    
.ChkUnlimLives      lda UnlimLivesOnOff
                    cmp #$ff                        ; $ff=on
                    beq .ResetTargRoom
                    
.DecP_Lives         dec CC_LvlP_NumLives,x          ; $7807 : 00=dead
                    lda CC_LvlP_NumLives,x          ; $7807 : 00=dead
                    beq .SetP_Dead
                    
.ResetTargRoom      lda CC_LvlP_StrtRoom,x          ; $7803 : count start: entry 00 of ROOM list
                    sta CC_LvlP_TargRoom,x          ; $7809 : count start: entry 00 of ROOM list
                    lda CC_LvlP_StrtDoor,x          ; $7805 : count start: entry 00 of Room DOOR list
                    sta CC_LvlP_TargDoor,x          ; $780b : count start: entry 00 of Room DOOR list
                    jmp .SetNextPlayer
                    
.SetP_Dead          lda #CC_LVLP_Dead
                    sta CC_LvlP_Health,x            ; $780f : 00=dead  01=alive
                    lda #$01
                    sta FlgGameOverP_
                    
.SetNextPlayer      inx                             ; player two
                    cpx #$02
                    bcc .HandlePlayers
                    
                    lda FlgGameOverP_
                    cmp #$01
                    bne .GoChkP_Health
                    
                    jsr InitHiResSprtWA             ; initialize the hires screen and sprite work area
                    
                    lda #<TextGameOver
                    sta $3e
                    lda #>TextGameOver
                    sta $3f
                    jsr RoomTextLine                ; Room: TextLine
                    
                    lda CC_LvlP2Active              ; $7812 : player 2 pressed fire at start
                    cmp #CC_LVLP_Out
                    beq .SetScnVisible
                    
.ChkP1Alive03       lda CC_LvlP1Health
                    cmp #CC_LVLP_Alive
                    beq .ChkP2Alive01
                    
.GameOverP1         lda #<TextGameOverP1
                    sta $3e
                    lda #>TextGameOverP1
                    sta $3f
                    jsr RoomTextLine                ; Room: TextLine
                    
.ChkP2Alive01       lda CC_LvlP2Health              ; $7810 : 00=dead  01=alive
                    cmp #CC_LVLP_Alive
                    beq .SetScnVisible
                    
.GameOverP2         lda #<TextGameOverP2
                    sta $3e
                    lda #>TextGameOverP2
                    sta $3f
                    jsr RoomTextLine                ; Room: TextLine
                    
.SetScnVisible      lda SCROLY                      ; VIC 2 - $D011 = VIC Control Register 1 (and Vertical Fine Scrolling)
                    ora #$10                        ;   Bit 4: Screen Disable   1=visible again
                    sta SCROLY                      ; VIC 2 - $D011 = VIC Control Register 1 (and Vertical Fine Scrolling)
                    
                    lda #$23                        ; dynamic wait time
                    jsr DynWait
                    
.GoChkP_Health      jmp .ChkP_Health
                    
GameHandlerX        pla
                    tax
                    pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
                    .byte $b4
FlgGameOverP_       .byte $a0
                    .byte $89
; ------------------------------------------------------------------------------------------------------------- ;
TextGameOver        .byte $3c                       ; StartPos  : Col = 3c
                    .byte $38                       ; StartPos  : Row = 38
                    .byte LT_RED                    ; ColorNo   :
                    .byte $22                       ; Format    : 22 = normal/double size
                    .byte $47                       ; Text      : (max 20 chr) = game oveR
                    .byte $41
                    .byte $4d
                    .byte $45
                    .byte $20
                    .byte $4f
                    .byte $56
                    .byte $45
                    .byte $d2                       ; EndOfLine = Bit 7 set
                    
                    .byte $00                       ; EndOfText = 00
                    
TextGameOverP1      .byte $30                       ; StartPos  : Col = 30
                    .byte $68                       ; StartPos  : Row = 68
                    .byte YELLOW                    ; ColorNo   :
                    .byte $21                       ; Format    : 21 = normal/normal size
                    .byte $46                       ; Text      : (max 20 chr) =      ; for player 1
                    .byte $4f
                    .byte $52
                    .byte $20
                    .byte $50
                    .byte $4c
                    .byte $41
                    .byte $59
                    .byte $45
                    .byte $52
                    .byte $20
                    .byte $b1                       ; EndOfLine = Bit 7 set
                    
                    .byte $00                       ; EndOfText = 00
                    
TextGameOverP2      .byte $30                       ; StartPos  : Col = 30
                    .byte $80                       ; StartPos  : Row = 80
                    .byte ORANGE                    ; ColorNo   :
                    .byte $21                       ; Format    : 21 = normal/normal size
                    .byte $46                       ; Text      : (max 20 chr) =      ; for player 2
                    .byte $4f
                    .byte $52
                    .byte $20
                    .byte $50
                    .byte $4c
                    .byte $41
                    .byte $59
                    .byte $45
                    .byte $52
                    .byte $20
                    .byte $b2                       ; EndOfLine = Bit 7 set
                    
                    .byte $00                       ; EndOfText = 00
; ------------------------------------------------------------------------------------------------------------- ;
; MapHandler        Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
MapHandler          pha
                    tya
                    pha
                    txa
                    pha
                    
.InitScrnSprtWA     jsr InitHiResSprtWA             ; initialize the hires screen and sprite work area
                    
                    lda #$00
                    sta SP0COL                      ; VIC 2 - $D027 = Color Sprite 0
                    sta SP1COL                      ; VIC 2 - $D028 = Color Sprite 1
                    
                    lda #$00
                    sta SavPlayerNum
.NextPlayer         ldx SavPlayerNum
                    lda FlgP_CanEnter,x             ; 00=no 01=yes
                    cmp #$01
                    beq .GetTargetRoomNo
                    
                    jmp .SetNextPlayer
                    
.GetTargetRoomNo    lda CC_LvlP_TargRoom,x          ; $7809 : count start: entry 00 of ROOM list
                    jsr SetRoomShapePtr
                    
                    ldy #CC_RoomColor
                    lda ($42),y                     ; RoomDataPtr: RoomColorNo
                    ora Mask_80_c                   ; Bit 7=1 - room visited
                    sta ($42),y                     ;         - mark it
                    
                    lda CC_LvlP_TargDoor,x          ; $780b : count start: entry 00 of Room DOOR list
                    jsr SetRoomDoorPtr
                    
                    ldy #CC_DoorInWall
                    lda ($40),y                     ; CC_RoomDoorPtr: door direction in map wall
                    and #$03                        ; isolate Bits 0-1 - 0=n 1=e 2=s 3=w
                    sta SavMapDoorInWall
                    
                    jsr SpriteInitWA
                    txa                             ; $00, $20, $40, $60, $80, $a0, $c0 or $e0 = block offset
                    
                    lsr a
                    lsr a
                    lsr a
                    lsr a
                    lsr a                           ; /32 = sprite number
                    sta SavSpriteNum
                    
                    ldy #CC_RoomMapPosX
                    lda ($42),y                     ; RoomDataPtr: CC_RoomMapPosX
                    ldy #CC_DoorMapOffX
                    clc
                    adc ($40),y                     ; CC_RoomDoorPtr:  CC_DoorMapOffX
                    
                    clc
                    ldy SavMapDoorInWall
                    adc TabOffDoorNSWall,y
                    sec
                    sbc #$04
                    asl a
                    ldy SavSpriteNum
                    sta CC_ZPgSprt__PosX,y          ; PosX sprites 0-7
                    bcc .GetMask
                    
                    lda Mask_01to80,y
                    ora $20                         ; CC_ZPgSprt__MSBY - sprites 0-7 MSB PosY
                    jmp .PutMSBY
                    
.GetMask            lda Mask_01to80,y
                    eor #$ff
                    and $20                         ; CC_ZPgSprt__MSBY - sprites 0-7 MSB PosY
                    
.PutMSBY            sta $20                         ; CC_ZPgSprt__MSBY - sprites 0-7 MSB PosY
                    clc
                    ldy #CC_RoomMapPosY
                    lda ($42),y                     ; RoomDataPtr: CC_RoomMapPosY
                    ldy #CC_DoorMapOffY
                    adc ($40),y                     ; CC_RoomDoorPtr:  CC_DoorMapOffY
                    
                    clc
                    ldy SavMapDoorInWall
                    adc TabOffDoorEWWall,y
                    clc
                    adc #$32
                    
                    ldy SavSpriteNum
                    sta CC_ZPgSprt__PosY,y          ; PosY sprites 0-7
                    ldy SavMapDoorInWall
                    lda TabArrowSpriteNo,y
                    sta CC_WASprtImgNo,x
                    
                    jsr CopySpriteData              ; set shape / expand and copy sprite data of a given number to its memory location
                    
                    ldy SavSpriteNum
                    lda Mask_01to80,y
                    ora $21                         ; CC_ZPgSprt__Enab - sprites 0-7 enable
                    sta $21                         ; CC_ZPgSprt__Enab - sprites 0-7 enable
                    
                    ldy SavPlayerNum
                    ldx CC_LvlP1NumLives,y          ; $7807
                    lda TabTextPlrColor,x           ; color according to livescount: 03=light green 02=yellow 01=light red
                    sta TextOneUpColor
                    sta TextTwoUpColor
                    tya
                    asl a                           ; *2
                    tax
                    lda PtrTextPlayers,x            ; "one uP / two uP"
                    sta $3e
                    lda PtrTextPlayers+1,x
                    sta $3f
                    jsr RoomTextLine                ; Room: TextLine
                    
                    tya                             ; player number
                    asl a                           ; *2
                    asl a                           ; *4
                    clc
                    adc #<CC_LvlP_Times
                    sta $3e
                    lda #$00
                    adc #>CC_LvlP_Times
                    sta $3f                         ; ($3e/$3f) points to player1/2 castle escape times
                    
                    jsr FillObjTimFrame
                    
                    clc
                    lda TabTimeObjPosX,y
                    adc #$08
                    sta PrmPntObj0PosX
                    lda #$10
                    sta PrmPntObj0PosY
                    lda #NoObjTimeFrame             ; object: Time Frame - $93
                    sta PrmPntObj0No
                    lda #$00
                    sta PrmPntObj_Type
                    
.PaintTime          jsr PaintObject
                    
.SetNextPlayer      inc SavPlayerNum
                    lda SavPlayerNum
                    cmp #$02
                    beq .GoPaintMap
                    
                    jmp .NextPlayer
                    
.GoPaintMap         jsr PaintMapRooms
                    
                    lda #$00
                    sta WrkSwitch
                    
                    lda #$01
                    sta FlgP1Enters
                    sta FlgP2Enters
                    
                    lda FlgP1CanEnter               ; 00=no 01=yes
                    cmp #$01
                    beq .MarkEnterP1
                    
                    lda FlgP2CanEnter               ; 00=no 01=yes
                    cmp #$01
                    bne .BlackArrow
                    
                    lda #$00
                    sta FlgP2Enters
                    jmp .BlackArrow
                    
.MarkEnterP1        lda #$00
                    sta FlgP1Enters
                    
                    lda FlgP2CanEnter               ; 00=no 01=yes
                    cmp #$01
                    bne .BlackArrow
                    
.MarkEnterP2        lda #$00
                    sta FlgP2Enters
                    
                    lda CC_LvlP1TargDoor            ; $780b : count start: entry 00 of Room DOOR list
                    cmp CC_LvlP2TargDoor            ; $780c : count start: entry 00 of Room DOOR list
                    bne .BlackArrow
                    
                    lda #$01
                    sta WrkSwitch
                    
.WhiteArrow         lda #WHITE
                    sta SP0COL                      ; VIC 2 - $D027 = Color Sprite 0
                    sta SP1COL                      ; VIC 2 - $D028 = Color Sprite 1
                    jmp .ScreenOn
                    
.BlackArrow         lda #BLACK
                    sta SP0COL                      ; VIC 2 - $D027 = Color Sprite 0
                    sta SP1COL                      ; VIC 2 - $D028 = Color Sprite 1
                    
.ScreenOn           lda SCROLY                      ; VIC 2 - $D011 = VIC Control Register 1 (and Vertical Fine Scrolling)
                    ora #$10                        ;   Bit 4: Screen Disable   1=visible again
                    sta SCROLY                      ; VIC 2 - $D011 = VIC Control Register 1 (and Vertical Fine Scrolling)
                    
                    lda #$01
                    sta FlgNoUse
                    
                    lda #$00
                    sta FlgRestoreKey               ; restore key pressed  01=pressed
                    
                    lda TabBlinkTimeP1
                    sta WrkBlinkTimeP1
                    
                    lda TabBlinkTimeP2
                    sta WrkBlinkTimeP2
                    
                    lda #$00
                    sta SavPlayerNum
                    
.SetIRQCount        lda #$01
                    sta WrkCountIRQs                ; counted down to $00 with every IRQ
                    
                    ldx SavPlayerNum
                    lda WrkSwitch
                    cmp #$01
                    beq .ChkRestoreKey
                    
                    dec WrkBlinkTimeP_,x
                    bne .ChkRestoreKey
                    
                    lda TabBlinkTimeP_,x
                    sta WrkBlinkTimeP_,x
                    
                    cpx #$00
                    beq .FlipArrow0Color
                    
                    lda FlgP1CanEnter               ; 00=no 01=yes
                    cmp #$01
                    beq .FlipArrow1Color
                    
.FlipArrow0Color    lda SP0COL                      ; VIC 2 - $D027 = Color Sprite 0
                    eor #$01
                    sta SP0COL                      ; VIC 2 - $D027 = Color Sprite 0
                    jmp .ChkRestoreKey
                    
.FlipArrow1Color    lda SP1COL                      ; VIC 2 - $D028 = Color Sprite 1
                    eor #$01
                    sta SP1COL                      ; VIC 2 - $D028 = Color Sprite 1
                    
.ChkRestoreKey      lda FlgRestoreKey               ; restore key pressed  01=pressed
                    cmp #$01
                    bne .PickPlayerNo
                    
                    lda #$00
                    sta FlgRestoreKey               ; restore key pressed  01=pressed
                    
                    lda #$00
                    sta FlgNoUse
.GoMainLoop         jmp MainLoop
                    
.PickPlayerNo       txa
                    
                    jsr GetKeyJoyVal
                    
                    lda FlgJoy_NoUse
                    cmp #$01
                    bne .ChkStopKey                 ; always
                    
                    lda #$01
                    sta T_2e02
                    jsr S_2c08                      ; zeroes - false
                    
                    jmp .InitScrnSprtWA
                    
.ChkStopKey         lda FlgKeyStop
                    cmp #$01
                    bne .ChkJoystFire
                    
                    jsr SaveGame
                    
                    jmp .InitScrnSprtWA
                    
.ChkJoystFire       lda FlgJoyFire
                    beq .ChkP1Enters
                    
                    lda #$01
                    sta FlgP1Enters,x
                    
.ChkP1Enters        lda FlgP1Enters
                    cmp #$01
                    bne .FlipPlayerNo
                    
                    lda FlgP2Enters
                    cmp #$01
                    beq .GetJoystVal
                    
.FlipPlayerNo       lda SavPlayerNum
                    eor #$01
                    sta SavPlayerNum
                    
.Wait               lda WrkCountIRQs                ; counted down to $00 with every IRQ
                    bne .Wait
                    
                    jmp .SetIRQCount
                    
.GetJoystVal        lda #$00                        ; joystick port
                    jsr GetKeyJoyVal
                    
                    lda FlgJoyFire
                    bne .GetJoystVal
                    
                    lda #$01
                    jsr GetKeyJoyVal
                    
                    lda FlgJoyFire
                    bne .GetJoystVal
                    
                    lda #NoSndMapPing               ; sound: Map Enter Ping - $09
                    jsr InitSoundFX
                    
                    lda #$00
                    sta FlgNoUse
                    
MapHandlerX         pla
                    tax
                    pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
FlgP_CanEnter       = *
FlgP1CanEnter       .byte $a0
FlgP2CanEnter       .byte $a0
WrkSwitch           .byte $ca
FlgP1Enters         .byte $a0
FlgP2Enters         .byte $af
                    
WrkBlinkTimeP_      = *
WrkBlinkTimeP1      .byte $80
WrkBlinkTimeP2      .byte $cf
                    
FlgNoUse            .byte $00
                    
TabBlinkTimeP_      = *
TabBlinkTimeP1      .byte $06
TabBlinkTimeP2      .byte $0f
                    
TabTimeObjPosX      .byte $10
                    .byte $74
                    
                    .byte $17
                    .byte $18
                    
SavPlayerNum        .byte $ff
                    
SavSpriteNum        .byte $a0
SavMapDoorInWall    .byte $a0
                    
TabOffDoorNSWall    .byte $ff
                    .byte $02
                    .byte $ff
                    .byte $fb
                    
TabOffDoorEWWall    .byte $f6
                    .byte $fe
                    .byte $06
                    .byte $fe
                    
TabArrowSpriteNo    .byte NoSprArrDo                ; sprite: Arrow: Down Up    - $14
                    .byte NoSprArrLe                ; sprite: Arrow: Down Left  - $15
                    .byte NoSprArrUp                ; sprite: Arrow: Down Up    - $12
TabTextPlrColor     = *                             ; lives count color tab - 1
                    .byte NoSprArrRi                ; sprite: Arrow: Down Right - $13
                    
                    .byte LT_RED                    ; 
                    .byte YELLOW                    ; 
                    .byte LT_GREEN                  ; 
; ------------------------------------------------------------------------------------------------------------- ;
PtrTextPlayers      .word TextOneUp
                    .word TextTwoUp
; ------------------------------------------------------------------------------------------------------------- ;
TextOneUp           .byte $10
                    .byte $00
TextOneUpColor      .byte WHITE
                    .byte $22
                    .byte $4f                       ; one uP
                    .byte $4e
                    .byte $45
                    .byte $20
                    .byte $55
                    .byte $d0
                    .byte $00
                    
TextTwoUp           .byte $74
                    .byte $00
TextTwoUpColor      .byte WHITE
                    .byte $22
                    .byte $54                       ; two uP
                    .byte $57
                    .byte $4f
                    .byte $20
                    .byte $55
                    .byte $d0
                    .byte $00
; ------------------------------------------------------------------------------------------------------------- ;
; PaintMapRooms     Function: Paint the castles map of chambers
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
PaintMapRooms       pha
                    tya
                    pha
                    txa
                    pha
                    
                    lda #<(CC_LvlGame+CC_LvlGameData)
                    sta $42
                    lda #>(CC_LvlGame+CC_LvlGameData)
                    sta $43
                    
.NextRoom           ldy #$00
                    lda ($42),y                     ; $7900 = start of room definitions after the game parms
                    bit Mask_40_c                   ; Bit6 = 1 - EndOfRoom
                    beq .ChkVisit
                    
                    jmp PaintMapRoomsX              ; set = exit
                    
.ChkVisit           bit Mask_80_c                   ; Bit7 = 1 - visited so paint it
                    bne .Room
                    
                    jmp .SetNextRoom
                    
.Room               and #$0f                        ; isolate CC_RoomColor
                    sta ColObjMapFiller                ; Map Room: Color for Filler Square
                    
                    ldy #CC_RoomMapPosX
                    lda ($42),y                     ; CC_RoomMapPosX
                    sta SavRoomMapPosX
                    ldy #CC_RoomMapPosY
                    lda ($42),y                     ; CC_RoomMapPosY
                    sta SavRoomMapPosY
                    
                    ldy #CC_RoomSize
                    lda ($42),y                     ; CC_RoomSize - Bits:  ..xx xyyy - min 2*2  max 7*7
                    and #$07
                    sta SavRoomSizeYYY
                    
                    lda ($42),y                     ; CC_RoomSize - Bits:  ..xx xyyy - min 2*2  max 7*7
                    lsr a
                    lsr a
                    lsr a
                    and #$07
                    sta SavRoomSizeXXX
                    
                    lda #$00
                    sta PrmPntObj_Type
                    
                    lda SavRoomMapPosY
                    sta PrmPntObj0PosY
                    lda #NoObjMapFiller             ; object: Map Room - Color Filler Square: 1*8 - $0a
                    sta PrmPntObj0No
                    
                    lda SavRoomSizeYYY
                    sta WrkRoomSizeYYY
                    
.ColorRoom          lda SavRoomSizeXXX
                    sta WrkRoomSizeXXX
                    lda SavRoomMapPosX
                    sta PrmPntObj0PosX
                    
.PaintSquare        jsr PaintObject
                    
                    clc
                    lda PrmPntObj0PosX
                    adc #$04
                    sta PrmPntObj0PosX
                    
                    dec WrkRoomSizeXXX
                    bne .PaintSquare
                    
                    clc
                    lda PrmPntObj0PosY
                    adc #$08
                    sta PrmPntObj0PosY
                    
                    dec WrkRoomSizeYYY
                    bne .ColorRoom
                    
                    lda SavRoomMapPosX
                    sta PrmPntObj1PosX
                    lda SavRoomMapPosY
                    sta PrmPntObj1PosY
                    lda #$01
                    sta PrmPntObj_Type
                    
                    lda SavRoomSizeXXX
                    sta WrkRoomSizeXXX
                    lda #NoObjMapWallNS             ; object: Map Wall - n/s - $0b
                    sta PrmPntObj1No
                    
.PaintWallN         jsr PaintObject
                    
                    clc
                    lda PrmPntObj1PosX
                    adc #$04
                    sta PrmPntObj1PosX
                    dec WrkRoomSizeXXX
                    bne .PaintWallN
                    
                    lda SavRoomMapPosX
                    sta PrmPntObj1PosX
                    lda SavRoomSizeYYY
                    asl a
                    asl a
                    asl a                           ; *8
                    clc
                    adc SavRoomMapPosY
                    sec
                    sbc #$03
                    sta PrmPntObj1PosY
                    
                    lda SavRoomSizeXXX
                    sta WrkRoomSizeXXX
                    
.PaintWallS         jsr PaintObject
                    
                    clc
                    lda PrmPntObj1PosX
                    adc #$04
                    sta PrmPntObj1PosX
                    dec WrkRoomSizeXXX
                    bne .PaintWallS
                    
                    lda SavRoomMapPosX
                    sta PrmPntObj1PosX
                    lda SavRoomMapPosY
                    sta PrmPntObj1PosY
                    lda #NoObjMapWallW              ; object: Map Wall - w long - $0c
                    sta PrmPntObj1No
                    lda SavRoomSizeYYY
                    sta WrkRoomSizeXXX
                    
.PaintWallW         jsr PaintObject
                    
                    clc
                    lda PrmPntObj1PosY
                    adc #$08
                    sta PrmPntObj1PosY
                    dec WrkRoomSizeXXX
                    bne .PaintWallW
                    
                    lda SavRoomSizeXXX
                    asl a
                    asl a
                    clc
                    adc SavRoomMapPosX
                    sec
                    sbc #$04
                    sta PrmPntObj1PosX
                    
                    lda SavRoomMapPosY
                    sta PrmPntObj1PosY
                    lda #NoObjMapWallE              ; object: Map Wall - e long - $0d
                    sta PrmPntObj1No
                    lda SavRoomSizeYYY
                    sta WrkRoomSizeXXX
                    
.PaintWallE         jsr PaintObject
                    
                    clc
                    lda PrmPntObj1PosY
                    adc #$08
                    sta PrmPntObj1PosY
                    dec WrkRoomSizeXXX
                    bne .PaintWallE
                    
                    lda #$00
                    jsr SetRoomDoorPtr
                    
                    lda SavTargRoomDoors
                    sta WrkRoomSizeXXX
                    
.ChkSizeXXX         lda WrkRoomSizeXXX
                    bne .GetDoorWall
                    
.SetNextRoom        clc
                    lda $42
                    adc #CC_RoomLen                 ; $08 = length of each room data entry
                    sta $42
                    bcc .GoNextRoom
                    inc $43
                    
.GoNextRoom         jmp .NextRoom
                    
.GetDoorWall        ldy #CC_DoorInWall
                    lda ($40),y                     ; CC_RoomDoorPtr
                    and #$03
                    bne .ChkDoorS
                    
                    lda SavRoomMapPosY
                    sta PrmPntObj1PosY
                    jmp .GetPosX
                    
.ChkDoorS           cmp #CC_DoInWallSouth
                    bne .PushDoor
                    
                    lda SavRoomSizeYYY
                    asl a
                    asl a
                    asl a                           ; *8
                    clc
                    adc SavRoomMapPosY
                    sec
                    sbc #$03
                    sta PrmPntObj1PosY
                    
.GetPosX            lda SavRoomMapPosX
                    ldy #CC_DoorMapOffX
                    clc
                    adc ($40),y                     ; CC_RoomDoorPtr
                    sta PrmPntObj1PosX
                    and #$02
                    beq .DoorNS
                    
                    eor PrmPntObj1PosX
                    sta PrmPntObj1PosX
                    lda #NoObjMapDoorNSRi           ; object: Map Door - N/S Right - $0f
                    jmp .SetObjNo
                    
.DoorNS             lda #NoObjMapDoorNSLe           ; object: Map Door - N/S Left  - $0e
                    jmp .SetObjNo
                    
.PushDoor           pha
                    
                    lda SavRoomMapPosY
                    clc
                    ldy #CC_DoorMapOffY
                    adc ($40),y                     ; CC_RoomDoorPtr
                    sta PrmPntObj1PosY
                    
.PullDoor           pla
                    cmp #CC_DoInWallWest
                    beq .DoorW
                    
                    lda SavRoomSizeXXX
                    asl a
                    asl a
                    clc
                    adc SavRoomMapPosX
                    sec
                    sbc #$04
                    sta PrmPntObj1PosX
                    
                    lda #NoObjMapDoorEWRi           ; object: Map Door - E/W Right - $11
                    jmp .SetObjNo
                    
.DoorW              lda SavRoomMapPosX
                    sta PrmPntObj1PosX
                    lda #NoObjMapDoorEWLe           ; object: Map Door - E/W Left  - $10
                    
.SetObjNo           sta PrmPntObj1No
                    
.PaintDoor          jsr PaintObject
                    
                    clc
                    lda $40
                    adc #$08
                    sta $40
                    bcc .GoDecRoomXXX
                    inc $41
                    
.GoDecRoomXXX       dec WrkRoomSizeXXX
                    jmp .ChkSizeXXX
                    
PaintMapRoomsX      pla
                    tax
                    pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
WrkRoomSizeXXX      .byte $a0
WrkRoomSizeYYY      .byte $b1
SavRoomMapPosX      .byte $a0
SavRoomMapPosY      .byte $8c
SavRoomSizeXXX      .byte $a0
SavRoomSizeYYY      .byte $a0
; ------------------------------------------------------------------------------------------------------------- ;
; PaintRoom         Function: Paint a single castle chamber
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
PaintRoom           pha
                    tya
                    pha
                    txa
                    pha
                    
                    jsr InitHiResSprtWA             ; initialize the hires screen and sprite work area
                    
                    lda #<CC_ScrnMoveCtrl
                    sta $30
                    lda #>CC_ScrnMoveCtrl
                    sta $31                         ; ($30/$31) points to screen area $C000 - $C7ff
                    
                    ldy #$00
.BlankC000I         lda #$00
.BlankC000          sta ($30),y
                    iny
                    bne .BlankC000
                    inc $31
                    lda $31
                    cmp #$c8
                    bcc .BlankC000I
                    
                    lda FlgP1CanEnter               ; 00=no 01=yes
                    cmp #$01
                    beq .SetP1
                    
.SetP2              ldx #$01
                    jmp .ChkDemo
                    
.SetP1              ldx #$00
.ChkDemo            lda FlgRoomLoadAdr              ; $00=$7800 $01=$9800 $02=$b800
                    cmp #CC_LvlStorID
                    bne .SetGameRoom
                    
.SetDemoRoom        lda SavDemoRoomNo
                    jmp .GetRoomDataPtr
                    
.SetGameRoom        lda CC_LvlP1TargRoom,x          ; $7809 : count start: entry 00 of ROOM list
                    
.GetRoomDataPtr     jsr SetRoomShapePtr
                    
                    ldy #CC_RoomColor
                    lda ($42),y                     ; ($41/$42) points to room data
                    and #$0f                        ; isolate colors
                    sta ColObjFloorStart                ; object: floor start
                    asl a
                    asl a
                    asl a
                    asl a                           ; color moved to left  nibble
                    ora ColObjFloorStart                ; color set   to right nyblle
                    
                    sta ColObjFloorStart                ; object: floor start
                    sta ColObjFloorMid                ; object: floor mid
                    sta ColObjFloorEnd                ; object: floor end
                    
                    sta ColLadderPaFl01              ; object: floor ladder passes
                    sta ColLadderPaFl03              ; object: floor ladder passes
                    
                    sta ColObjTrapMov011              ; object: floor trap door open 01
                    sta ColObjTrapMov012              ; object: floor trap door open 01
                    sta ColObjTrapMov013              ; object: floor trap door open 01
                    
                    sta ColObjTrapMov021              ; object: floor trap door open 02
                    sta ColObjTrapMov022              ; object: floor trap door open 02
                    sta ColObjTrapMov023              ; object: floor trap door open 02
                    
                    sta ColObjTrapMov031              ; object: floor trap door open 03
                    sta ColObjTrapMov032              ; object: floor trap door open 03
                    sta ColObjTrapMov033              ; object: floor trap door open 03
                    
                    sta ColObjTrapMov041              ; object: floor trap door open 04
                    sta ColObjTrapMov042              ; object: floor trap door open 04
                    sta ColObjTrapMov043              ; object: floor trap door open 04
                    
                    sta ColObjTrapMov051              ; object: floor trap door open 05
                    sta ColObjTrapMov052              ; object: floor trap door open 05
                    sta ColObjTrapMov053              ; object: floor trap door open 05
                    
                    sta ColObjTrapMov061              ; object: floor trap door open 06
                    sta ColObjTrapMov062              ; object: floor trap door open 06
                    sta ColObjTrapMov063              ; object: floor trap door open 06
                    
                    ldy #$07
.ColorMSW           sta ColObjWalkMov011,y              ; object: moving sidewalk 01
                    sta ColObjWalkMov021,y              ; object: moving sidewalk 02
                    sta ColObjWalkMov031,y              ; object: moving sidewalk 03
                    sta ColObjWalkMov041,y              ; object: moving sidewalk 04
                    dey
                    bpl .ColorMSW
                    
                    and #$0f
                    ora #$10
                    sta ColObjPoleCover                ; object: front floor piece to cover pole
                    lda ColObjFloorEnd                ; object: floor end
                    
                    and #$f0
                    ora #$01
                    sta ColObjLadderFl                ; object: floor end
                    sta ColLadderPaFl02              ; object: floor ladder passes
                    
.SetGameData        ldy #CC_RoomDoorIdLo
                    lda ($42),y                     ; ($42/$43) points to room data
                    sta $3e
                    iny                             ; CC_RoomDoorIdHi
                    lda ($42),y                     ; ($42/$43) points to room data
                    sta $3f                         ; ($3e/$3f) points to room door id of game data $7800 (03 08)
                    
                    lda FlgRoomLoadAdr              ; $00=$7800 $01=$9800 $02=$b800
                    cmp #CC_LvlStorID
                    bne .GoPainRoomItems
                    
.SetDemoData        clc
                    lda $3f
                    adc #$20                        ; point to game stor data at $9800
                    sta $3f                         ; ($3e/$3f) points to room door id of load data $9800 (03 08)
                    
.GoPainRoomItems    jsr PaintRoomItems
                    
PaintRoomX          pla
                    tax
                    pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
; RoomHandler       Function: Control the action within a chamber
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
RoomHandler         pha
                    tya
                    pha
                    txa
                    pha
                    
                    jsr PaintRoom                   ; display the room first
                    
                    ldx #$00
.Players            lda FlgP_CanEnter,x             ; 00=no 01=yes
                    cmp #$01
                    bne .NextPlayer
                    
                    stx SavPlayerNo
                    jsr RunIntoRoom
                    
.NextPlayer         inx
                    cpx #$02
                    bcc .Players                    ; lower - next
                    
                    lda #$01
                    sta SavNoUse                    ; bad: not checked
                    lda #$00
                    sta FlgRestoreKey               ; restore key pressed  01=pressed
                    
                    lda SCROLY                      ; VIC 2 - $D011 = VIC Control Register 1 (and Vertical Fine Scrolling)
                    ora #$10                        ;   Bit 4: Screen Disable   1=visible again
                    sta SCROLY
                    
.ActionHandler      jsr ActionHandler
                    
                    lda FlgJoy_NoUse
                    cmp #$01                        ; bad: should never happen
                    bne .ChkStop                    ; always
                    
                    lda #$00
                    sta T_2e02
                    jsr S_2c08                      ; zeroes - false
                    
.ChkStop            lda FlgKeyStop
                    cmp #$01
                    bne .ChkRestore
                    
.WaitI01            lda #$03
                    sta WrkCountIRQs
.Wait01             lda WrkCountIRQs                ; counted down to $00 with every IRQ
                    bne .Wait01
                    
                    jsr GetKeyJoyVal
                    
                    lda FlgKeyStop
                    cmp #$01
                    beq .WaitI01
                    
                    ldx #$03
.SaveTime           lda TODTEN,x                    ; CIA 1 - $DC08 = Time of Day Clock Tenths of Seconds
                    sta SavCIA1ToD,x
                    lda TO2TEN,x                    ; CIA 2 - $DD08 = Time of Day Clock Tenths of Seconds
                    sta SavCIA2ToD,x
                    dex
                    bpl .SaveTime
                    
.ChkJoystick        lda #$00
                    jsr GetKeyJoyVal
                    
                    lda FlgKeyStop
                    cmp #$01
                    bne .ChkJoystick
                    
.WaitI02            lda #$03
                    sta WrkCountIRQs
.Wait02             lda WrkCountIRQs                ; counted down to $00 with every IRQ
                    bne .Wait02
                    
                    jsr GetKeyJoyVal
                    
                    lda FlgKeyStop
                    cmp #$01
                    beq .WaitI02
                    
                    ldx #$03
.RestoreTime        lda SavCIA1ToD,x
                    sta TODTEN,x                    ; CIA 1 - $DC08 = Time of Day Clock Tenths of Seconds
                    lda SavCIA2ToD,x
                    sta TO2TEN,x                    ; CIA 2 - $DD08 = Time of Day Clock Tenths of Seconds
                    dex
                    bpl .RestoreTime
                    
.ChkRestore         lda FlgRestoreKey               ; restore key pressed  01=pressed
                    cmp #$01
                    bne .ChkP1Status
                    
                    lda #$00
                    sta FlgRestoreKey               ; restore key pressed  01=pressed
                    
                    ldx #$01
.ChkP_Status        lda CC_LvlP_Status,x
                    cmp #CC_LVLP_Survive
                    bne .SetNextPlayer
                    
                    lda #CC_LVLP_Accident
                    sta CC_LvlP_Status,x
                    ldy SavP_OffSprWA,x
                    lda CC_WASprtFlag,y             ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    ora Mask_40                     ;            $10=action   $20=death          $40=dead           $80=init
                    sta CC_WASprtFlag,y
.SetNextPlayer      dex
                    bpl .ChkP_Status
                    
.ChkP1Status        lda CC_LvlP1Status
                    cmp #CC_LVLP_Survive
                    bne .ChkP2Status
                    
                    lda #$00
                    sta CC_LvlP1Active              ; $7812 : player 1 pressed fire at start
                    jmp .ActionHandler
                    
.ChkP2Status        lda CC_LvlP2Status
                    cmp #CC_LVLP_Survive
                    bne .ChkP_StatusExI
                    
                    lda #$01
                    sta CC_LvlP1Active              ; $7812 : player 1 pressed fire at start
                    
.GoActionHandler    jmp .ActionHandler
                    
.ChkP_StatusExI     ldx #$00
.ChkP_StatusEx      lda CC_LvlP_Status,x
                    cmp #CC_LVLP_IORoom
                    beq .GoActionHandler
                    
                    cmp #CC_LVLP_IOStart
                    beq .GoActionHandler
                    
                    inx
                    cpx #$02
                    bcc .ChkP_StatusEx
                    
                    lda #$00
                    sta SavNoUse                    ; bad: not checked
                    
                    ldx #$1e                        ; time amount
.FinishAnimation    jsr ActionHandler               ; allow pending animations (death/leave-enter room) to finish
                    dex
                    bne .FinishAnimation
                    
RoomHandlerX        pla
                    tax
                    pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
SavNoUse            .byte $00
SavCIA1ToD          .byte $a8                       ; CIA 1 - $DC08 = Time of Day Clock: Tenths of Seconds
                    .byte $a0                       ;                                    Seconds
                    .byte $a0                       ;                                    Minutes
                    .byte $a0                       ;                                    Hours
                    
SavCIA2ToD          .byte $a0                       ; CIA 2 - $DD08 = Time of Day Clock: Tenths of Seconds
                    .byte $a0                       ;                                    Seconds
                    .byte $c5                       ;                                    Minutes
                    .byte $a2                       ;                                    Hours
; ------------------------------------------------------------------------------------------------------------- ;
; PaintRoomItems    Function: 
;                   Parms   : Pointer ($3e/$3f) to CC_IDLow of CC_LvlGame
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
PaintRoomItems      pha
                    tya
                    pha
                    
.SetPtr             ldy #CC_IDLow                   ; ID low
                    lda ($3e),y                     ; ($3e/$3f) points to room item id of game data $7900
                    sta .___ObjAdrLo
                    iny                             ; ID high
                    lda ($3e),y                     ; DoorDataPtr
                    sta .___ObjAdrHi
                    
                    clc
                    lda $3e
                    adc #$02
                    sta $3e
                    bcc .ChkEoD
                    inc $3f                         ; point behind 2 byte pointer
                    
.ChkEoD             lda .___ObjAdrHi
                    beq PaintRoomItemsX             ; 00=EndOfRoomData
                    
.JsrObjIDTab        .byte $20                       ; jsr selected room item sub routine (init: jsr $1601)
.___ObjAdrLo        .byte $01                       ;   from jump table at
.___ObjAdrHi        .byte $16                       ;   $0803 - $0836
                    
                    jmp .SetPtr
                    
PaintRoomItemsX     pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
; RoomDrawObject    Function: Paint chamber objects - Never called from: PaintRoomItems - Used in: RoomTitleScreen
;                   Parms   : Pointer ($3e/$3f) to CC_DrawObject of CC_LvlGame
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
RoomDrawObject      pha
                    tya
                    pha
                    
                    lda #$00
                    sta PrmPntObj_Type
                    
.NextObject         ldy #CC_DrawObject
                    lda ($3e),y                     ; DrawObjectDataPtr
                    beq .Exit
                    
                    sta WrkObjCount
                    
                    ldy #CC_ObjID
                    lda ($3e),y                     ; DrawObjectDataPtr
                    sta PrmPntObj0No
                    
                    ldy #CC_ObjPosX
                    lda ($3e),y                     ; DrawObjectDataPtr
                    sta PrmPntObj0PosX
                    ldy #CC_ObjPosY
                    lda ($3e),y                     ; DrawObjectDataPtr
                    sta PrmPntObj0PosY
                    
.PaintNextObject    jsr PaintObject
                    
                    dec WrkObjCount
                    beq .GoNextObject
                    
                    clc
                    ldy #CC_ObjNextX
                    lda PrmPntObj0PosX
                    adc ($3e),y                     ; DrawObjectDataPtr
                    sta PrmPntObj0PosX
                    ldy #CC_ObjNextY
                    clc
                    lda PrmPntObj0PosY
                    adc ($3e),y                     ; DrawObjectDataPtr
                    sta PrmPntObj0PosY
                    jmp .PaintNextObject
                    
.GoNextObject       clc
                    lda $3e
                    adc #CC_ObjectLen               ; $06 = length graphic data entry
                    sta $3e
                    bcc .NextObject
                    inc $3f
                    jmp .NextObject
                    
.Exit               inc $3e
                    bne RoomDrawObjectX
                    inc $3f
                    
RoomDrawObjectX     pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
WrkObjCount         .byte $a0
; ------------------------------------------------------------------------------------------------------------- ;
; RoomFloor         Function: Paint a chambers floors - Called from: PaintRoomItems
;                   Parms   : Pointer ($3e/$3f) to CC_Floor of CC_LvlGame
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
RoomFloor           pha
                    tya
                    pha
                    
.NextFloor          ldy #CC_FloorLength
                    lda ($3e),y                     ; FloorDataPtr
                    sta SavFloorLength
                    bne .Floor                      ; 00=EndOfFloors
                    
                    inc $3e
                    bne .Exit
                    inc $3f                         ; ($3e/$3f) point behind EndOfFloorData
                    
.Exit               jmp RoomFloorX                  ; all floors handled
                    
.Floor              ldy #CC_FloorPosX
                    lda ($3e),y                     ; FloorDataPtr
                    sta PrmPntObj0PosX
                    ldy #CC_FloorPosY
                    lda ($3e),y                     ; FloorDataPtr
                    sta PrmPntObj0PosY
                    lda #$01
                    sta WrkFloorLength
                    
                    lda PrmPntObj0PosX
                    lsr a
                    lsr a
                    sec
                    sbc #$04
                    sta CtrlScrnColNo
                    
                    lda PrmPntObj0PosY
                    lsr a
                    lsr a
                    lsr a
                    sta CtrlScrnRowNo
                    
                    jsr SetCtrlScrnPtr              ; ($3c/$3d) point to control screen output address $c000-$c7ff
                    
.PaintFloor         lda WrkFloorLength
                    cmp #$01                        ; start
                    beq .FloorStart                 ; yes
                    
                    cmp SavFloorLength
                    beq .FloorEnd
                    
.FloorMid           lda #NoObjFloorMid              ; object: floor middle tile - $1c
                    jmp .SetObj
                    
.FloorStart         lda #NoObjFloorStart            ; object: floor start  tile - $1b
                    jmp .SetObj
                    
.FloorEnd           lda #NoObjFloorEnd              ; object: floor end    tile - $1d
.SetObj             sta PrmPntObj0No
                    
                    lda #$00
                    sta PrmPntObj_Type
                    
                    jsr PaintObject
                    
                    lda #$01
                    sta CtrlFloorLength
.FloorCtrl          lda WrkFloorLength
                    cmp #$01                        ; start
                    beq .CtrlChkStart
                    
                    cmp SavFloorLength
                    beq .CtrlChkEnd                 ; end
                    
.CtrlMid            lda #CC_CtrlFloorMid            ; ctrlObj: floor middle
                    jmp .SetCtrl
                    
.CtrlChkStart       lda CtrlFloorLength
                    cmp #$01
                    bne .CtrlMid
                    
                    lda #CC_CtrlFloorStrt           ; ctrlObj: floor start
                    jmp .SetCtrl
                    
.CtrlChkEnd         lda CtrlFloorLength
                    cmp SavObj0Cols
                    bne .CtrlMid
                    
                    lda #CC_CtrlFloorEnd            ; ctrlObj: floor end
.SetCtrl            ldy #$00
                    ora ($3c),y
                    sta ($3c),y                     ; ($3c/$3d) point to control screen output address $c000-$c7ff
                    
                    inc CtrlFloorLength
                    clc
                    lda $3c
                    adc #$02                        ; unpdate only every second position
                    sta $3c
                    bcc .CtrlChkDone
                    inc $3d                         ; ($3c/$3d) point to control screen output address $c000-$c7ff
                    
.CtrlChkDone        lda CtrlFloorLength
                    cmp SavObj0Cols
                    bcc .FloorCtrl                  ; lower
                    beq .FloorCtrl                  ; equal
                    
                    lda SavObj0Cols
                    asl a
                    asl a
                    clc
                    adc PrmPntObj0PosX
                    sta PrmPntObj0PosX
                    
                    inc WrkFloorLength
                    lda WrkFloorLength
                    cmp SavFloorLength
                    beq .GoPaintFloor
                    bcs .SetNextFloor               ; floor handled completely
                    
.GoPaintFloor       jmp .PaintFloor
                    
.SetNextFloor       lda $3e
                    clc
                    adc #CC_FloorLen                ; $03 = floor data entry length
                    sta $3e
                    bcc .GoNextFloor
                    inc $3f
                    
.GoNextFloor        jmp .NextFloor
                    
RoomFloorX          pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
WrkFloorLength      .byte $a0
CtrlFloorLength     .byte $a0
SavFloorLength      .byte $a9
; ------------------------------------------------------------------------------------------------------------- ;
; RoomPole          Function: Paint a chambers poles - Called from: PaintRoomItems
;                   Parms   : Pointer ($3e/$3f) to CC_Pole of CC_LvlGame
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
RoomPole            pha
                    tya
                    pha
                    
.NextPole           ldy #CC_PoleLength
                    lda ($3e),y                     ; PoleDataPtr
                    bne .Pole
                    
                    inc $3e
                    bne .Exit
                    inc $3f                         ; ($3e/$3f) point behind EndOfPoleData
                    
.Exit               jmp RoomPoleX
                    
.Pole               sta WrkSliPoleLength
                    ldy #CC_PolePosX
                    lda ($3e),y                     ; PoleDataPtr
                    sta PrmPntObj0PosX
                    ldy #CC_PolePosY
                    lda ($3e),y                     ; PoleDataPtr
                    sta PrmPntObj0PosY
                    
                    lda PrmPntObj0PosX
                    lsr a
                    lsr a
                    sec
                    sbc #$04
                    sta CtrlScrnColNo
                    
                    lda PrmPntObj0PosY
                    lsr a
                    lsr a
                    lsr a
                    sta CtrlScrnRowNo
                    
                    jsr SetCtrlScrnPtr              ; ($3c/$3d) point to control screen output address $c000-$c7ff
                    
.ChkFloor           ldy #$00
                    lda ($3c),y
                    and #CC_CtrlFloorMid            ; detect any kind of floor type
                    beq .ObjPole
                    
                    sec
                    lda PrmPntObj0PosX
                    sbc #$04
                    sta PrmPntObj1PosX
                    lda PrmPntObj0PosY
                    sta PrmPntObj1PosY
                    lda #NoObjPolePassFl            ; object: pole pass floor        - $25
                    sta PrmPntObj1No
                    
.ObjFrontCover      lda #NoObjPoleFront             ; object: pole front floor piece - $27
                    sta PrmPntObj0No
                    lda #$02
                    sta PrmPntObj_Type
                    
                    jmp .PaintPole
                    
.ObjPole            lda #NoObjPole                  ; object: pole - $24
                    sta PrmPntObj0No
                    lda #$00
                    sta PrmPntObj_Type
                    
.PaintPole          jsr PaintObject
                    
.PoleCtrl           ldy #$00
                    lda ($3c),y
                    ora #CC_CtrlPole
                    sta ($3c),y
                    dec WrkSliPoleLength
                    bne .NextCtrlRow
                    
                    clc
                    lda $3e
                    adc #CC_PoleLen                 ; $03 = pole data entry length
                    sta $3e
                    bcc .GoNextPole
                    inc $3f                         ; ($3e/$3f) point to next pole
                    
.GoNextPole         jmp .NextPole
                    
.NextCtrlRow        clc
                    lda PrmPntObj0PosY
                    adc #$08
                    sta PrmPntObj0PosY
                    clc
                    lda $3c
                    adc #$50
                    sta $3c
                    bcc .GoChkFloor
                    inc $3d                         ; ($3c/$3d) point to next control screen row
                    
.GoChkFloor         jmp .ChkFloor
                    
RoomPoleX           pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
WrkSliPoleLength    .byte $80
; ------------------------------------------------------------------------------------------------------------- ;
; RoomLadder        Function: Paint a chambers ladders - Called from: PaintRoomItems
;                   Parms   : Pointer ($3e/$3f) to CC_Ladder of CC_LvlGame
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
RoomLadder          pha
                    tya
                    pha
                    
.NextLadder         ldy #CC_LadderLength
                    lda ($3e),y                     ; LadderDataPtr
                    bne .Ladder
                    
                    inc $3e
                    bne .Exit
                    inc $3f                         ; ($3e/$3f) point behind EndOfLadderData
                    
.Exit               jmp RoomLadderX
                    
.Ladder             sta SavLadderLenght
                    ldy #CC_LadderPosX
                    lda ($3e),y                     ; LadderDataPtr
                    sta PrmPntObj0PosX
                    ldy #CC_LadderPosY
                    lda ($3e),y                     ; LadderDataPtr
                    sta PrmPntObj0PosY
                    
                    lda PrmPntObj0PosX
                    lsr a
                    lsr a
                    sec
                    sbc #$04
                    sta CtrlScrnColNo
                    
                    lda PrmPntObj0PosY
                    lsr a
                    lsr a
                    lsr a
                    sta CtrlScrnRowNo
                    
                    jsr SetCtrlScrnPtr              ; ($3c/$3d) point to control screen output address $c000-$c7ff
                    
.ChkFloor           ldy #$00
                    lda ($3c),y
                    and #CC_CtrlFloorMid            ; detect any kind of floor type
                    bne .PassFloor
                    
                    lda #$00
                    sta PrmPntObj_Type
                    
                    lda SavLadderLenght
                    cmp #$01
                    beq .ObjLadderTop
                    
.ObjLadderMid       lda #NoObjLadderMid             ; object: ladder mid - $28
                    sta PrmPntObj0No
                    jmp .PaintLadder1
                    
.ObjLadderTop       lda #NoObjLadderTop             ; object: ladder top - $2b
                    sta PrmPntObj0No
                    jmp .PaintLadder1
                    
.PassFloor          lda #$02
                    sta PrmPntObj_Type
                    
                    lda SavLadderLenght
                    cmp #$01                        ; bottom
                    bne .ObjLadderPass
                    
.ObjLadderEnd       lda #NoObjLadderFloor           ; object: ladder on floor    - $29
                    sta PrmPntObj0No
                    lda #NoObjLaddrWipeOn           ; object: ladder clear floor - $2a
                    sta PrmPntObj1No
                    
                    lda PrmPntObj0PosX
                    sta PrmPntObj1PosX
                    lda PrmPntObj0PosY
                    sta PrmPntObj1PosY
                    
.PaintLadder1       jsr PaintObject
                    
                    jmp .ChkCtrlTop
                    
.ObjLadderPass      lda #NoObjLaddrPassFl           ; object: ladder pass floor  - $2c
                    sta PrmPntObj0No
                    lda #NoObjLaddrWipePa           ; object: ladder clear floor - $2d
                    sta PrmPntObj1No
                    sec
                    lda PrmPntObj0PosX
                    sbc #$04
                    sta PrmPntObj0PosX
                    sta PrmPntObj1PosX
                    lda PrmPntObj0PosY
                    sta PrmPntObj1PosY
                    
.PaintLadder2       jsr PaintObject
                    
                    clc
                    lda PrmPntObj0PosX
                    adc #$04
                    sta PrmPntObj0PosX
                    
.ChkCtrlTop         lda SavLadderLenght
                    ldy #CC_LadderLength
                    cmp ($3e),y                     ; LadderDataPtr
                    beq .LadderDec                  ; top and bottom of ladder consist of part1 only
                    
.LadderPart1        ldy #$00                        ; not set for TopOfLadder and BottomOfLadder
                    lda ($3c),y
                    ora #CC_CtrlLadderBot
                    sta ($3c),y
                    
.LadderDec          dec SavLadderLenght             ; mark top ladder
                    bne .LadderPart2
                    
                    clc
                    lda $3e
                    adc #CC_LadderLen               ; $03 = ladder data entry length
                    sta $3e
                    bcc .GoNextLadder
                    inc $3f                         ; ($3e/$3f) point to next ladder
                    
.GoNextLadder       jmp .NextLadder
                    
.LadderPart2        ldy #$00
                    lda ($3c),y
                    ora #CC_CtrlLadderTop           ; ladder consist of two parts
                    sta ($3c),y
                    
.NextCtrlRow        clc
                    lda PrmPntObj0PosY
                    adc #$08
                    sta PrmPntObj0PosY
                    clc
                    lda $3c
                    adc #$50
                    sta $3c
                    bcc .GoChkFloor
                    inc $3d                         ; ($3c/$3d) point to next control screen row
                    
.GoChkFloor         jmp .ChkFloor
                    
RoomLadderX         pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
SavLadderLenght     .byte $d2
; ------------------------------------------------------------------------------------------------------------- ;
; InitHiResSprtWA   Function: Init the hires screen and sprite work areas
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
InitHiResSprtWA     pha
                    tya
                    pha
                    
                    lda FlgSfxOnOff
                    cmp #$01                        ; off
                    beq .HiResI                     ; no sound effects / no screen blanking
                    
                    lda SCROLY                      ; VIC 2 - $D011 = VIC Control Register 1 (and Vertical Fine Scrolling)
                    and #$ef                        ;   Bit 4: Screen Disable   0=disabled
                    sta SCROLY                      ; VIC 2 - $D011 = VIC Control Register 1 (and Vertical Fine Scrolling)
                    
.HiResI             lda #$00                        ; all sprites off
                    sta $21                         ; CC_ZPgSprt__Enab - sprites 0-7 enable
                    
                    lda #<(CC_BitmapRam + $1f00)
                    sta $30
                    lda #>(CC_BitmapRam + $1f00)
                    sta $31
                    
                    ldy #$f9                        ; $fff9 - amount first page (leave interrupt pointers intact)
.HiResV             lda #$00
.HiRes              sta ($30),y                     ; clear hires grafic screen at $e000 - $fff9
                    dey
                    cpy #$ff
                    bne .HiRes
                    
                    dec $31
                    lda $31
                    cmp #>CC_BitmapRam
                    bcs .HiResV
                    
                    ldy #$00
.SprtWrk            lda Mask_01
                    sta CC_WASprtFlag,y             ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    tya                             ;            $10=action   $20=death          $40=dead           $80=init
                    clc
                    adc #CC_SprWALen ; $20
                    tay
                    bne .SprtWrk
                    
                    lda #$00
                    sta ObjWAUseCount               ; max $20 entries a 08 bytes in object work area
                    sta MaxBkgrColor                ; for IRQ exit screen layout
                    sta SavBkgrColor                ; for IRQ exit screen layout
                    sta $23                         ; CC_ZPgColrBorder - VIC II Border Color
                    
InitHiResSprtWAX    pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
; DynWait           Function: Wait a variable amount of time
;                   Parms   : ac=Wait time
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
DynWait             sta SavDynWaitTime
                    pha
                    txa
                    pha
                    
                    ldx #$06
.WaitI              lda SavDynWaitTime
                    sta WrkCountIRQs
.Wait               lda WrkCountIRQs                ; counted down to $00 with every IRQ
                    bne .Wait
                    
                    dex
                    bne .WaitI
                    
DynWaitX            pla
                    tax
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
SavDynWaitTime      .byte $a0
; ------------------------------------------------------------------------------------------------------------- ;
; EscapeHandler     Function: Success screen and picture and goodbye waves
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
EscapeHandler       pha
                    tya
                    pha
                    txa
                    pha
                    
                    jsr InitHiResSprtWA             ; initialize the hires screen and sprite work area
                    
                    lda #$06
                    sta MaxBkgrColor                ; for IRQ exit screen layout
                    
                    lda CC_LvlXPicFlag
                    and #CC_LvlXPicYes
                    beq .SetEscapeText              ; do not show escape picture
                    
.VictoryPicture     lda CC_LvlXPicPtrLo             ; $785f : points to (36/08) entry in level data
                    sta $3e
                    lda CC_LvlXPicPtrHi             ; $7860 : points to (36/08) entry in level data
                    sta $3f
                    jsr PaintRoomItems
                    
.SetEscapeText      clc
                    lda SavGamePlayerNo
                    adc #$31
                    sta TextEscapePNo
                    lda #<TextEscape
                    sta $3e
                    lda #>TextEscape
                    sta $3f
                    jsr RoomTextLine                ; Room: TextLine
                    
.SetEscapeTime      lda SavGamePlayerNo
                    asl a
                    asl a                           ; *4
                    clc
                    adc #<CC_LvlP_Times
                    sta $3e
                    lda #$00
                    adc #>CC_LvlP_Times
                    sta $3f
                    
                    jsr FillObjTimFrame
                    
                    lda #NoObjTimeFrame             ; object: Time - Empty Frame - $93
                    sta PrmPntObj0No
                    lda #$68
                    sta PrmPntObj0PosX
                    lda #$18
                    sta PrmPntObj0PosY
                    lda #$00
                    sta PrmPntObj_Type
                    
.PaintEscapeText    jsr PaintObject
                    
                    lda SCROLY                      ; VIC 2 - $D011 = VIC Control Register 1 (and Vertical Fine Scrolling)
                    ora #$10                        ;   Bit 4: Screen Disable   1=visible again
                    and #$7f                        ;   Bit 7: Bit 8 of raster compare register $D012    0=
                    sta SCROLY                      ; VIC 2 - $D011 = VIC Control Register 1 (and Vertical Fine Scrolling)
                    
                    ldy SavGamePlayerNo
                    ldx SavP_OffSprWA,y
                    lda #$87
                    sta CC_WASprtPosY,x
                    lda #$08
                    sta CC_WASprtPosX,x
                    
                    jsr Randomizer
                    
                    and #$0e                        ; ....###.
                    beq .GetLeave
                    
.GetStay            lda #$00                        ; offset TabActionType 1: player waves first before leaving
                    jmp .SetLeave
                    
.GetLeave           lda #$08                        ; offset TabActionType 2: player leaves completely first and returns to wave goodbye
.SetLeave           sta SavType
                    
                    lda #$00
                    sta SavDuration
                    
.ActionPhases       lda SavDuration
                    bne .ChkAction
                    
                    ldy SavType
                    lda TabDuration,y
                    bne .SetDuration
                    
.GoExit             jmp .Exit
                    
.SetDuration        sta SavDuration
                    lda TabAction,y
                    sta SavActionType
                    
                    clc
                    lda SavType
                    adc #$02
                    sta SavType
                    
.ChkAction          lda SavActionType
                    cmp #$01                        ; $00=run right $01=run left $02=wave
                    bcc .RunRight
                    beq .RunLeft
                    
.Wave               inc CC_WASprtImgNo,x            ; sprite: Player: Wave Good Bye Phases
                    lda CC_WASprtImgNo,x
                    cmp #NoSprPlrWavGBMax           ; sprite: Player: Wave Good Bye Phase 03 + 2 - $9b
                    bcs .WaveGBStart
                    
                    cmp #NoSprPlrWavGBMin           ; sprite: Player: Wave Good Bye Phase 01     - $97
                    bcs .SetActionImgNo
                    
.WaveGBStart        lda #NoSprPlrWavGBMin           ; sprite: Player: Wave Good Bye Phase 01     - $97
                    jmp .SetActionImgNo
                    
.RunRight           inc CC_WASprtPosX,x
                    inc CC_WASprtImgNo,x
                    lda CC_WASprtImgNo,x
                    cmp #NoSprPlrMovLeMax           ; sprite: Player: Move Left  Phase 03 + 1 - $06
                    bcs .RunLeftStart
                    
                    cmp #NoSprPlrMovLeMin           ; sprite: Player: Move Left  Phase 01 -     $03
                    bcs .SetActionImgNo
                    
.RunLeftStart       lda #NoSprPlrMovLeMin           ; sprite: Player: Move Left  Phase 01 -     $03
                    jmp .SetActionImgNo
                    
.RunLeft            dec CC_WASprtPosX,x
                    inc CC_WASprtImgNo,x
                    lda CC_WASprtImgNo,x
                    cmp #NoSprPlrMovLeMin           ; sprite: Player: Move Left  Phase 01 -     $03
                    bcc .SetActionImgNo
                    
.RunRightStart      lda #NoSprPlrMovRiMin           ; sprite: Player: Move Right Phase 01 -     $00
.SetActionImgNo     sta CC_WASprtImgNo,x
                    txa
                    lsr a
                    lsr a
                    lsr a
                    lsr a
                    lsr a                           ; /32 = sprite number
                    tay
                    
                    sei
                    lda CC_WASprtPosX,x
                    sec
                    sbc #$10
                    asl a
                    
                    clc
                    adc #$18
                    sta CC_ZPgSprt__PosX,y          ; PosX sprites 0-7
                    
                    lda CC_WASprtPosX,x
                    cmp #$84
                    bcs .Set20
                    
                    lda Mask_01to80,y
                    eor #$ff
                    and $20                         ; CC_ZPgSprt__MSBY - sprites 0-7 MSB PosY
                    jmp .SetMSBPosY
                    
.Set20              lda Mask_01to80,y
                    ora $20                         ; CC_ZPgSprt__MSBY - sprites 0-7 MSB PosY
.SetMSBPosY         sta $20                         ; CC_ZPgSprt__MSBY - sprites 0-7 MSB PosY
                    cli
                    
                    lda CC_WASprtPosY,x
                    clc
                    adc #$32
                    sta CC_ZPgSprt__PosY,y          ; PosY sprites 0-7
                    
                    jsr CopySpriteData              ; set shape / expand and copy sprite data of a given number to its memory location
                    
                    lda Mask_01to80,y
                    ora $21
                    sta $21                         ; CC_ZPgSprt__Enab - sprites 0-7 enable
                    lda SavGamePlayerNo
                    beq .GetP1Color
                    
.GetP2Color         lda TabColorP2
                    jmp .SetP_Color
                    
.GetP1Color         lda TabColorP1
.SetP_Color         sta SP0COL,y                    ; VIC 2 - $D027 = Color Sprite 0(-7)
                    
                    dec SavDuration
                    
                    lda #$02
                    sta WrkCountIRQs
.Wait               lda WrkCountIRQs                ; counted down to $00 with every IRQ
                    bne .Wait
                    
                    jmp .ActionPhases
                    
.Exit               lda #$0a                        ; dynamic wait time
                    jsr DynWait
                    
EscapeHandlerX      pla
                    tax
                    pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
SavGamePlayerNo     .byte $b5
; ------------------------------------------------------------------------------------------------------------- ;
TextEscape          .byte $20                       ; StartPos  : Col = 20
                    .byte $00                       ; StartPos  : Row = 00
                    .byte LT_GREEN                  ; ColorNo   :
                    .byte $22                       ; Format    : 22 = normal/double size
                    .byte $50                       ; Text      : (max 20 chr) = player
                    .byte $4c
                    .byte $41
                    .byte $59
                    .byte $45
                    .byte $52
                    .byte $20
TextEscapePNo       .byte $20                       ; player number
                    .byte $20
                    .byte $45                       ; escapeS
                    .byte $53
                    .byte $43
                    .byte $41
                    .byte $50
                    .byte $45
                    .byte $d3                       ; EndOfLine = Bit 7 set
                    
                    .byte $38                       ; StartPos  : Col = 38
                    .byte $18                       ; StartPos  : Row = 18
                    .byte YELLOW                    ; ColorNo   :
                    .byte $21                       ; Format    : 21 = normal/normal size
                    .byte $54                       ; Text      : (max 20 chr) = time
                    .byte $49
                    .byte $4d
                    .byte $45
                    .byte $ba                       ; EndOfLine = Bit 7 set
                    
                    .byte $00                       ; EndOfText = 00
; ------------------------------------------------------------------------------------------------------------- ;
TabActionType       = *
TabDuration         .byte $80                       ; duration - action type 1: enter/stop/wave/leave
TabAction           .byte $00                       ; flag: run right
                    
                    .byte $19                       ; duration
                    .byte $02                       ; flag: wave
                    
                    .byte $2d                       ; duration
                    .byte $00                       ; flag: run right
                    
                    .byte $00                       ; duration 00 - end type 1
                    .byte $00
                    
                    .byte $ac                       ; duration - action type 2: enter/leave/reenter/wave/leave
                    .byte $00                       ; flag: run right
                    
                    .byte $2c                       ; duration
                    .byte $01                       ; flag: run left
                    
                    .byte $19                       ; duration
                    .byte $02                       ; flag: wave goodbye
                    
                    .byte $2d                       ; duration
                    .byte $00                       ; flag: run right
                    
                    .byte $00                       ; duration 00 - end type 2
                    .byte $00
                    
SavActionType       .byte $a5
SavDuration         .byte $a0
SavType             .byte $a0
; ------------------------------------------------------------------------------------------------------------- ;
; RoomGraphic       Function: Paint the EndOfGame Picture - Called from: PaintRoomItems after EscapeHandler
;                   Parms   : Pointer ($3e/$3f) to CC_Graphic of CC_LvlGame
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
RoomGraphic         pha
                    tya
                    pha
                    txa
                    pha
                    
                    lda $3e
                    sta ObjRoomDyn
                    lda $3f
                    sta ObjRoomDyn+1                ; set object pointer to castle graphic data pointer
                    
                    lda #$00
                    sta PrmPntObj_Type
                    
                    lda #NoObjRoomDyn               ; object: ObjRoomDyn - $16
                    sta PrmPntObj0No
                    
                    ldy #CC_GfxRows
                    lda ($3e),y                     ; GraphicDataPtr
                    
                    sec
                    sbc #$01                        ; rows - 1 ...
                    lsr a
                    lsr a
                    lsr a                           ; ... / 8 ...
                    sta $32
                    inc $32                         ; ... + 1 ...
                    
                    ldy #CC_GfxCols
                    lda ($3e),y                     ; GraphicDataPtr
                    
                    tax
                    lda #$00
                    sta $30
                    sta $31
.Cols               cpx #$00                        ; ... * cols ...
                    beq .ColsX
                    
                    clc
                    lda $30
                    adc $32
                    sta $30
                    
                    lda $31
                    adc #$00
                    sta $31
                    
                    dex
                    jmp .Cols
                    
.ColsX              asl $30
                    rol $31                         ; ... * 2 = length color data in ($30/$31) so far
                    
                    ldy #CC_GfxRows
                    lda ($3e),y                     ; GraphicDataPtr
                    tax                  
                    ldy #CC_GfxCols
.Rows               cpx #$00                        ; ... + (rows * cols) ... (data length)
                    beq .RowsX
                    
                    clc
                    lda $30
                    adc ($3e),y                     ; GraphicDataPtr
                    sta $30
                    lda $31
                    adc #$00
                    sta $31
                    dex
                    jmp .Rows
                    
.RowsX              clc
                    lda #CC_GfxHeaderLen            ; ... + $03 ... (header length)
                    adc $30
                    sta $30
                    lda #$00
                    adc $31
                    sta $31                         ; = complete lenght of graphic header + data + color info
                    
                    clc
                    lda $3e
                    adc $30
                    sta $3e                         ; add to GraphicDataPtr
                    
                    lda $3f
                    adc $31
                    sta $3f                         ; ($3e/$3f) point behind GraphicData to Graphic Position List
                    
.NextGraphicPos     ldy #CC_GfxPosX
                    lda ($3e),y                     ; GraphicDataPtr
                    bne .SetPosition
                    
.EndOfPosList       clc
                    lda $3e
                    adc #$01
                    sta $3e
                    lda $3f
                    adc #$00
                    sta $3f                         ; ($3e/$3f) point behind EndOfGraphicData
                    jmp RoomGraphicX
                    
.SetPosition        sta PrmPntObj0PosX
                    iny                             ; CC_GfxPosY
                    lda ($3e),y                     ; GraphicDataPtr
                    sta PrmPntObj0PosY
                    
.PaintGraphic       jsr PaintObject
                    
                    clc
                    lda $3e
                    adc #CC_GfxPointerLen           ; $02 = graphic piece position data entry length
                    sta $3e
                    lda $3f
                    adc #$00
                    sta $3f
                    jmp .NextGraphicPos
                    
RoomGraphicX        pla
                    tax
                    pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
; NewBestTime       Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
NewBestTime         pha
                    tya
                    pha
                    txa
                    pha
                    
                    lda CC_LvlP2Active              ; $7812 : player 2 pressed fire at start
                    cmp #CC_LVLP_Out
                    beq .SetOnePlayer
                    
.SetTwoPlayer       lda #<(CC_BestTwoTimeLo-1)
                    sta $30
                    lda #>(CC_BestTwoTimeLo-1)
                    sta $31                         ; $b840
                    jmp .SetMaxEntries
                    
.SetOnePlayer       lda #<(CC_BestOneTimeLo-1)
                    sta $30
                    lda #>(CC_BestOneTimeLo-1)
                    sta $31                         ; $b804
                    
.SetMaxEntries      lda #CC_BestEntryMax
                    sta WrkBestTimeNo
                    
.ReadTimeI          ldy #$03
.ReadTime           lda ($30),y
                    cmp SavBestTimeAka,y
                    bcc .NextEntryAdr
                    
                    bne .ChkP2Active
                    
                    jmp .NextTimeVal
                    
.NextEntryAdr       clc
                    lda $30
                    adc #CC_BestEntryLen
                    sta $30
                    bcc .NextEntryNo
                    inc $31
                    
.NextEntryNo        dec WrkBestTimeNo
                    bne .ReadTimeI
                    
                    jmp NewBestTimeX
                    
.NextTimeVal        dey
                    bne .ReadTime
                    
.ChkP2Active        lda CC_LvlP2Active              ; $7812 : player 2 pressed fire at start
                    cmp #CC_LVLP_Out
                    beq .PosOnePlayer
                    
.PosTwoPlayer       ldy #$73                        ; offset end of data two player
                    lda #$68
                    sta BestTimesPosX
                    jmp .PosAdr
                    
.PosOnePlayer       ldy #$37                        ; offset end of data one player
                    lda #$18
                    sta BestTimesPosX
                    
.PosAdr             sec
                    lda #CC_BestEntryMax
                    sbc WrkBestTimeNo
                    asl a
                    asl a
                    asl a                           ; *8
                    
                    clc
                    adc #$38                        ; block length = CC_BestEntryLen * CC_BestEntryMax - 4
                    sta BestTimesPosY
                    
                    sec
                    lda #CC_BestEntryMax
                    sbc WrkBestTimeNo
                    tax
                    lda TabLineColorsBT,x
                    sta BestTimesColor
                    
                    sec
                    lda $30
                    sbc #$02                        ; correction - set real address
                    sta SavBestTimeLo
                    lda $31
                    sbc #$00
                    sta SavBestTimeHi
                    
.CopyEntryI         dec WrkBestTimeNo
                    beq .InsertAkaI
                    
                    lda #CC_BestEntryLen
                    sta WrkBestEntryLen
.CopyEntry          lda CC_BestTimes,y
                    sta CC_BestTimes+CC_BestEntryLen,y
                    dey
                    dec WrkBestEntryLen
                    bne .CopyEntry
                    
                    jmp .CopyEntryI
                    
.InsertAkaI         ldy #$03                        ; initials length + 1
.InsertAka          lda SavBestTimeAka,y
                    sta ($30),y
                    dey
                    bne .InsertAka
                    
                    lda SavBestTimeLo
                    sta $30
                    lda SavBestTimeHi
                    sta $31
                    
                    lda #$00
                    ldy #$00
                    sta ($30),y
                    
                    jsr ShowBestTimes
                    
                    lda #<TextHiScore
                    sta $3e
                    lda #>TextHiScore
                    sta $3f
                    
                    ldx SavBestTimePNo
                    lda TabTextPNo,x
                    sta TextHiScorePNo
                    jsr RoomTextLine                ; Room: TextLine
                    
                    lda #$03
                    sta BestTimesMaxLen
                    
                    lda #$01                        ; normal height
                    sta BestTimesFormat
                    
                    lda SCROLY                      ; VIC 2 - $D011 = VIC Control Register 1 (and Vertical Fine Scrolling)
                    ora #$10                        ;   Bit 4: Screen Disable   1=visible again
                    sta SCROLY                      ; VIC 2 - $D011 = VIC Control Register 1 (and Vertical Fine Scrolling)
                    
                    jsr NewHighScoreID
                    
                    ldy #$00
                    lda SavBestTimeLo
                    sta $30
                    lda SavBestTimeHi
                    sta $31
                    
.SetTimeI           cpy BestTimesInpLen
                    bcc .GetTime
                    
                    lda #" "
                    jmp .SetTime
                    
.GetTime            lda BestTimesLine,y
.SetTime            sta ($30),y
                    iny
                    cpy #$03
                    bcc .SetTimeI
                    
                    ldx OldDatScrnTabOff
                    ldy CC_TextScrnRowY,x
                    clc
                    lda TabCtrlScrRowsLo,y
                    adc CC_TextScrnRowX,x
                    sta $30
                    lda TabCtrlScrRowsHi,y
                    adc #$00
                    ora #$04
                    sta $31
                    
                    lda #"Y"
                    sta SaveFileNameId
                    
                    ldy #$0e
.GetSaveFileNam     lda ($30),y
                    and #$7f
                    cmp #" "
                    bcs .SetSaveFileNam
                    
                    ora #$40
.SetSaveFileNam     sta SaveFileName,y
                    dey
                    bpl .GetSaveFileNam
                    
                    lda CC_TextScrnLen,x
                    sta SaveFileNameLen
                    lda #$02
                    sta SaveFileAdrFlag             ; $00=$7800  $01=$9800  $02=$b800
                    
                    jsr PrepareIO
                    jsr VerifyDisk                  ; obsolete 
                    
                    cmp #$00
                    bne .GoRestart
                    
                    jsr SaveFile
.GoRestart          jsr WaitRestart
                    
NewBestTimeX        pla
                    tax
                    pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
SavBestTimeAka      .byte $cd
                    .byte $a5
                    .byte $aa
                    .byte $d0
SavBestTimePNo      .byte $b6
WrkBestTimeNo       .byte $a0
WrkBestEntryLen     .byte $a5
                    .byte $a0
TabTextPNo          .byte $b1                       ; for TextHiScorePNo - bit 8 set for EndOfLine
                    .byte $b2
SavBestTimeLo       .byte $a0
SavBestTimeHi       .byte $a0
; ------------------------------------------------------------------------------------------------------------- ;
TextHiScore         .byte $40                       ; StartPos  : Col = 40
                    .byte $a0                       ; StartPos  : Row = a0
                    .byte LT_BLUE                   ; ColorNo   :
                    .byte $22                       ; Format    : 22 = normal/double size
                    .byte $50                       ; Text      : (max 20 chr) = player_
                    .byte $4c
                    .byte $41
                    .byte $59
                    .byte $45
                    .byte $52
                    .byte $20
TextHiScorePNo      .byte $a0                       ; EndOfLine = Bit 7 set
                    
                    .byte $14                       ; StartPos  : Col = 20
                    .byte $b8                       ; StartPos  : Row = 00
                    .byte GREY                      ; ColorNo   :
                    .byte $21                       ; Format    : 21 = normal/normal size
                    .byte $45                       ; Text      : (max 20 chr) = enter your initialS
                    .byte $4e
                    .byte $54
                    .byte $45
                    .byte $52
                    .byte $20
                    .byte $59
                    .byte $4f
                    .byte $55
                    .byte $52
                    .byte $20
                    .byte $49
                    .byte $4e
                    .byte $49
                    .byte $54
                    .byte $49
                    .byte $41
                    .byte $4c
                    .byte $d3                       ; EndOfLine = Bit 7 set
                    
                    .byte $18                       ; StartPos  : Col = 18
                    .byte $c0                       ; StartPos  : Row = c0
                    .byte GREY                      ; ColorNo   :
                    .byte $21                       ; Format    : 21 = normal/normal size
                    .byte $46                       ; Text      : (max 20 chr) = followed bY
                    .byte $4f
                    .byte $4c
                    .byte $4c
                    .byte $4f
                    .byte $57
                    .byte $45
                    .byte $44
                    .byte $20
                    .byte $42
                    .byte $d9                       ; EndOfLine = Bit 7 set
                    
                    .byte $78                       ; StartPos  : Col = 78
                    .byte $c0                       ; StartPos  : Row = c0
                    .byte GREY                      ; ColorNo   :
                    .byte $31                       ; Format    : 31 = reverse/normal size
                    .byte $52                       ; Text      : (max 20 chr) = returN
                    .byte $45
                    .byte $54
                    .byte $55
                    .byte $52
                    .byte $ce                       ; EndOfLine = Bit 7 set
                    
                    .byte $00                       ; EndOfText = 00
; ------------------------------------------------------------------------------------------------------------- ;
; ShowBestTimes     Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
ShowBestTimes       pha
                    tya
                    pha
                    txa
                    pha
                    
                    jsr InitHiResSprtWA             ; initialize the hires screen and sprite work area
                    
                    ldx OldDatScrnTabOff
                    ldy CC_TextScrnRowY,x
                    
                    clc
                    lda TabCtrlScrRowsLo,y
                    adc CC_TextScrnRowX,x
                    sta $30
                    lda TabCtrlScrRowsHi,y
                    adc #$00
                    ora #$04
                    sta $31
                    
.CopyCastleNameI    ldy CC_TextScrnLen,x
                    dey
                    dey                             ; real length
                    lda ($30),y
                    sta CC_BestTimes+CC_BestLenUsedHi,y
.CopyCastleName     dey
                    bmi .StartCastleName
                    
                    lda ($30),y
                    and #$7f
                    sta CC_BestTimes+CC_BestLenUsedHi,y
                    jmp .CopyCastleName
                    
.StartCastleName    lda #<(CC_BestTimes+CC_BestLenUsedHi)
                    sta $3e
                    lda #>(CC_BestTimes+CC_BestLenUsedHi)
                    sta $3f
                    
                    sec
                    lda #$15                        ; line length
                    sbc CC_TextScrnLen,x
                    asl a
                    asl a                           ; *4
                    clc
                    adc #$10
                    sta PaintTextPosX
                    lda #$10
                    sta PaintTextPosY               ; put castle name to middle of line
                    
                    lda #WHITE
                    sta PaintTextColor
                    
                    lda #CC_TextHightDbl
                    sta PaintTextFormat
                    
.PaintCastleName    jsr PaintText
                    
                    lda #$18
                    sta PaintTextPosX
                    ldx #$00
                    lda #$21                        ; normal/normal height
                    sta PaintTextFormat
                    
.SetStartRow        lda #$00
                    sta CC_BestTimes+CC_BestLenUsedHi+CC_TextScrnMaxL
                    
                    lda #$38
                    sta PaintTextPosY
                    
.GetRowColor        ldy CC_BestTimes+CC_BestLenUsedHi+CC_TextScrnMaxL
                    lda TabLineColorsBT,y
                    sta PaintTextColor
                    
                    lda CC_BestOneID,x
                    cmp #CC_EoBestTimes
                    beq .Empty
                    
                    sta CC_BestTimes+CC_BestLenUsedHi
                    lda CC_BestOneID+1,x
                    sta CC_BestTimes+CC_BestLenUsedHi+1
                    lda CC_BestOneID+2,x
                    jmp .MarkEoL
                    
.Empty              lda #"."
                    sta CC_BestTimes+CC_BestLenUsedHi
                    sta CC_BestTimes+CC_BestLenUsedHi+1
.MarkEoL            ora #CC_TextEoLine
                    sta CC_BestTimes+CC_BestLenUsedHi+2
                    
                    lda #<(CC_BestTimes+CC_BestLenUsedHi)
                    sta $3e
                    lda #>(CC_BestTimes+CC_BestLenUsedHi)
                    sta $3f
                    
.PaintId            jsr PaintText
                    
                    lda CC_BestOneID,x
                    cmp #CC_EoBestTimes
                    beq .SetNextRow
                    
                    clc
                    txa
                    adc #$04                        ; time offset
                    sta $3e
                    lda #>CC_BestTimes
                    adc #$00
                    sta $3f
                    
                    jsr FillObjTimFrame
                    
                    lda PaintTextPosX
                    clc
                    adc #$20
                    sta PrmPntObj0PosX
                    lda PaintTextPosY
                    sta PrmPntObj0PosY
                    lda #$00
                    sta PrmPntObj_Type
                    lda #NoObjTimeFrame             ; object: Empty Time Frame - $93
                    sta PrmPntObj0No
                    
.PaintTime          jsr PaintObject
                    
.SetNextRow         clc
                    lda PaintTextPosY
                    adc #$08
                    sta PaintTextPosY
                    
                    clc
                    txa
                    adc #CC_BestEntryLen
                    tax
                    
                    inc CC_BestTimes+CC_BestLenUsedHi+CC_TextScrnMaxL
                    lda CC_BestTimes+CC_BestLenUsedHi+CC_TextScrnMaxL
                    cmp #CC_BestEntryMax
                    bcs .ChkRight
                    
                    jmp .GetRowColor
                    
.ChkRight           lda PaintTextPosX
                    cmp #$18                        ; left column  - one player data
                    bne .SetHeader                  ; $68 = right column processed too - complete
                    
                    lda #$68                        ; right column - two player data
                    sta PaintTextPosX
                    jmp .SetStartRow
                    
.SetHeader          lda #<TextBestTimes
                    sta $3e
                    lda #>TextBestTimes
                    sta $3f
.PaintHeader        jsr RoomTextLine
                    
ShowBestTimesX      pla
                    tax
                    pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
TextBestTimes       .byte $28                       ; StartPos  : Col = 28
                    .byte $00                       ; StartPos  : Row = 00
                    .byte YELLOW                    ; ColorNo   :
                    .byte $21                       ; Format    : 21 = normal/normal size
                    .byte $42                       ; Text      : (max 20 chr) = best times foR
                    .byte $45
                    .byte $53
                    .byte $54
                    .byte $20
                    .byte $54
                    .byte $49
                    .byte $4d
                    .byte $45
                    .byte $53
                    .byte $20
                    .byte $46
                    .byte $4f
                    .byte $d2                       ; EndOfLine = Bit 7 set
                    
                    .byte $18                       ; StartPos  : Col = 18
                    .byte $28                       ; StartPos  : Row = 28
                    .byte LT_GREEN                  ; ColorNo   :
                    .byte $21                       ; Format    : 21 = normal/normal size
                    .byte $31                       ; Text      : (max 20 chr) = 1 player  2 playerS
                    .byte $20
                    .byte $50
                    .byte $4c
                    .byte $41
                    .byte $59
                    .byte $45
                    .byte $52
                    .byte $20
                    .byte $20
                    .byte $32
                    .byte $20
                    .byte $50
                    .byte $4c
                    .byte $41
                    .byte $59
                    .byte $45
                    .byte $52
                    .byte $d3                       ; EndOfLine = Bit 7 set
                    
                    .byte $00                       ; EndOfText = 00
; ------------------------------------------------------------------------------------------------------------- ;
TabLineColorsBT     .byte WHITE                     ; line colors for best times display
                    .byte YELLOW
                    .byte YELLOW
                    .byte ORANGE
                    .byte ORANGE
                    .byte ORANGE
                    .byte LT_RED
                    .byte LT_RED
                    .byte LT_RED
                    .byte LT_RED
; ------------------------------------------------------------------------------------------------------------- ;
; VerifyDisk        Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
VerifyDisk          pha
                    tya
                    pha
                    txa
                    pha
                    
                    lda #$0f
                    ldx #$08
                    ldy #$0f                        ; command channel
                    jsr SETLFS                      ; KERNEL - $FFBA = set logical file parameters
                    
                    lda #$01
                    ldx #<VerifyIni ; $28
                    ldy #>VerifyIni ; $1f           ; "i" - Initialize
                    
                    jsr SETNAM                      ; KERNEL - $FFBD = set filename parameters
                    jsr OPEN                        ; KERNEL - $FFC0 = open a logical file
                    
                    lda #$0f                        ; command channel
                    jsr CLOSE                       ; KERNEL - $FFC3 = close a logical file
                    
                    lda #$02
                    ldx #$08
                    ldy #$00
                    jsr SETLFS                      ; KERNEL - $FFBA = set logical file parameters
                    
                    lda #$01
                    ldx #<VerifyDir ; $19
                    ldy #>VerifyDir ; $1f           ; "$" - directory
                    
                    jsr SETNAM                      ; KERNEL - $FFBD = set filename parameters
                    jsr OPEN                        ; KERNEL - $FFC0 = open a logical file
                    
                    jsr READST                      ; KERNEL - $FFB7 = read I/O status word
                    cmp #$00                        ; OK
                    bne .SetFailResult
                    
                    ldx #$02
                    jsr CHKIN                       ; KERNEL - $FFC6 = define an input channel
                    jsr READST                      ; KERNEL - $FFB7 = read I/O status word
                    cmp #$00                        ; OK
                    bne .SetFailResult
                    
                    ldy #$08
.MstrPart1          lda TextDungeonMstr,y
                    dey
                    bne .MstrPart1
                    
                    ldy #$00
.MstrPart2          lda TextDungeonMstr,y
                    eor TextDungeonMstr,y
                    and #$7f
                    bne .Bad
                    
                    lda TextDungeonMstr,y
                    and #$80
                    bne .SetGoodResult
                    
                    iny
                    jmp .MstrPart2
                    
.Bad                jsr READST                      ; KERNEL - $FFB7 = read I/O status word
                    cmp #$00
                    bne .SetFailResult
                    
.SetBadResult       lda #$01
                    jmp .StoreResult
                    
.SetFailResult      lda #$02
                    jmp .StoreResult
                    
.SetGoodResult      lda #$00
.StoreResult        sta VerifyResult
                    
                    lda #$02
                    jsr CLOSE                       ; KERNEL - $FFC3 = close a logical file
                    
VerifyDiskX         pla
                    tax
                    pla
                    tay
                    pla
                    lda VerifyResult
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
VerifyDir           .byte $24                       ; "$" - Directory Disk
TextDungeonMstr     .byte $44                       ; dungeonmasteR
                    .byte $55
                    .byte $4e
                    .byte $47
                    .byte $45
                    .byte $4f
                    .byte $4e
                    .byte $4d
                    .byte $41
                    .byte $53
                    .byte $54
                    .byte $45
                    .byte $d2
VerifyResult        .byte $a0
VerifyIni           .byte $49                       ; "i" - Initialize Disk
; ------------------------------------------------------------------------------------------------------------- ;
; IRQ_SFX           Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
IRQ_SFX             pha
                    tya
                    pha
                    txa
                    pha
                    
                    lda WrkCutLoCtrl02
                    bne .DecCutLo02
                    
                    lda WrkCutLoCtrl03
                    beq .GetNextPotion
                    
                    dec WrkCutLoCtrl03
.DecCutLo02         dec WrkCutLoCtrl02
                    
                    lda WrkCutLoCtrl02
                    ora WrkCutLoCtrl03
                    beq .GetNextPotion
                    
                    jmp IRQ_SFXX
                    
.GetNextPotion      ldy #$00
                    lda ($44),y                     ; ($44/$45) points to sound effect / demo music
                    
                    lsr a
                    lsr a                           ; /4
                    
                    tax
                    lda TabCopyAmount,x
                    
                    tax
                    tay
                    
.CopyNext           dey
                    bmi .SetNextPortion
                    
                    lda ($44),y                     ; ($44/$45) points to sound effect / demo music
                    sta WrkTuneToPlay,y
                    jmp .CopyNext
                    
.SetNextPortion     clc
                    txa
                    adc $44
                    sta $44
                    bcc .GetControl
                    inc $45                         ; ($44/$45) points to netx portion of sound effect / demo music
                    
.GetControl         lda WrkTuneControl
                    lsr a
                    lsr a                           ; /4
                    
.ChkControl00       cmp #$00
                    bne .ChkControl01
                    
                    jsr IRQ_NextVoice
                    
                    lda WrkTuneControl
                    and #$03
                    tax
                    
                    lda WrkTuneCutLo
                    clc
                    adc TabTuneCutLo,x
                    tax
                    
                    ldy #$00
                    lda TabTunes01,x
                    sta ($46),y                     ; ($46/$47) pointer SID Oscillators 1-3 addresses
                    sta ($48),y                     ; ($48/$49) pointer SID Oscillators 1-3 set of values
                    
                    iny
                    lda TabTunes02,x
                    sta ($46),y                     ; ($46/$47) pointer SID Oscillators 1-3 addresses
                    sta ($48),y                     ; ($48/$49) pointer SID Oscillators 1-3 set of values
                    
                    ldy #$04
                    lda ($48),y                     ; ($48/$49) pointer SID Oscillators 1-3 set of values
                    ora #$01
                    sta ($46),y                     ; ($46/$47) pointer SID Oscillators 1-3 addresses
                    sta ($48),y                     ; ($48/$49) pointer SID Oscillators 1-3 set of values
                    jmp .GetNextPotion
                    
.ChkControl01       cmp #$01
                    bne .ChkControl02
                    
                    jsr IRQ_NextVoice
                    
                    ldy #$04
                    lda ($48),y                     ; ($48/$49) pointer SID Oscillators 1-3 set of values
                    and #$fe
                    sta ($48),y                     ; ($48/$49) pointer SID Oscillators 1-3 set of values
                    sta ($46),y                     ; ($46/$47) pointer SID Oscillators 1-3 addresses
                    jmp .GetNextPotion
                    
.ChkControl02       cmp #$02
                    bne .ChkControl03
                    
                    lda WrkTuneCutLo
                    sta WrkCutLoCtrl02
                    jmp IRQ_SFXX
                    
.ChkControl03       cmp #$03
                    bne .ChkControl04
                    
                    lda WrkTuneCutLo
                    sta WrkCutLoCtrl03
                    jmp IRQ_SFXX
                    
.ChkControl04       cmp #$04
                    bne .ChkControl05
                    
                    jsr IRQ_NextVoice
                    
                    ldy #$02
.CopyWrkTune        cpy #$04
                    beq .CopyLastPart
                    
.CopyFirstPart      lda WrkTuneBlock,y
                    sta ($46),y                     ; ($46/$47) pointer SID Oscillators 1-3 addresses
                    sta ($48),y                     ; ($48/$49) pointer SID Oscillators 1-3 set of values
                    jmp .SetNext
                    
.CopyLastPart       lda ($48),y                     ; ($48/$49) pointer SID Oscillators 1-3 set of values
                    and #$01
                    ora WrkTuneBlock,y
                    sta ($46),y                     ; ($46/$47) pointer SID Oscillators 1-3 addresses
                    sta ($48),y                     ; ($48/$49) pointer SID Oscillators 1-3 set of values
                    
.SetNext            iny
                    cpy #$07
                    bcc .CopyWrkTune
                    jmp .GetNextPotion
                    
.ChkControl05       cmp #$05
                    bne .ChkControl06
                    
                    lda WrkTuneCutLo
                    sta CUTLO                       ; SID - $D415 = Filter Cutoff Frequency (lowh byte)
                    sta SavTuneCutLo                ; not used
                    
                    lda WrkTuneCutHi
                    sta CUTHI                       ; SID - $D416 = Filter Cutoff Frequency (high byte)
                    sta SavTuneCutHi                ; not used
                    
                    lda WrkTuneControl
                    and #$03
                    tax
                    lda Mask_01to80,x
                    ora WrkTuneReson
                    sta RESON                       ; SID - $D417 = Filter Resonance Control Register
                    
                    sta TabSidRes
                    lda SavVolume
                    and #$0f
                    ora WrkTuneVolume
                    sta SavVolume
                    sta SIGVOL                      ; SID - $D418 = Volume and Filter Select
                    jmp .GetNextPotion
                    
.ChkControl06       cmp #$06
                    bne .ChkControl07
                    
                    lda WrkTuneControl
                    and #$03
                    tax
                    
                    lda WrkTuneCutLo
                    sta TabTuneCutLo,x
                    jmp .GetNextPotion
                    
.ChkControl07       cmp #$07
                    bne .ChkControl08
                    
                    lda SavVolume
                    and #$f0
                    ora WrkTuneCutLo
                    sta SavVolume
                    sta SIGVOL                      ; SID - $D418 = Volume and Filter Select
                    jmp .GetNextPotion
                    
.ChkControl08       cmp #$08
                    bne .ChkDemo
                    
                    lda WrkTuneCutLo
                    sta WrkTime
                    asl a
                    asl a                           ; *4
                    ora #$03
                    sta TIMAHI                      ; CIA 1 - $DC05 = Timer A (high byte)
                    jmp .GetNextPotion
                    
.ChkDemo            lda FlgRoomLoadAdr              ; $00=$7800 $01=$9800 $02=$b800
                    cmp #CC_LvlStorID
                    beq .InitDemo
                    
                    lda #$ff
                    sta WrkSFX
                    lda #$00
                    sta CIACRA                      ; CIA 1 - $DC0E = Control A
                    
                    lda #$7f
                    sta CIAICR                      ; CIA 1 - $DC0D = Interrupt Control
                    lda CIAICR                      ; CIA 1 - $DC0D = Interrupt Control
                    jmp IRQ_SFXX
                    
.InitDemo           lda #<CC_DmoMusicStart
                    sta $44
                    lda #>CC_DmoMusicStart
                    sta $45
                    
                    lda #$02
                    sta WrkCutLoCtrl03
                    
                    lda TabSidRes
                    and #$f0
                    sta RESON                       ; SID - $D417 = Filter Resonance Control
                    sta TabSidRes
                    
IRQ_SFXX            pla
                    tax
                    pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
; IRQ_NextVoice     Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
IRQ_NextVoice       pha
                    txa
                    pha
                    
                    lda WrkTuneControl
                    and #$03
                    asl a                           ; *2
                    tax
                    
                    lda AdrOscillators,x            ; SID ocillator addresses
                    sta $46
                    lda AdrOscillators+1,x
                    sta $47
                    
                    lda AdrTabVoiceVals,x           ; SID oscillator values
                    sta $48
                    lda AdrTabVoiceVals+1,x
                    sta $49
                    
IRQ_NextVoiceX      pla
                    tax
                    pla
                    
WrkTuneBlock        = *                             ; referenced with yr start offset of $02 in  .CopyWrkTune
                    
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
WrkTuneToPlay       = *
WrkTuneControl      .byte $99
WrkTuneCutLo        .byte $a0
WrkTuneCutHi        .byte $c1
WrkTuneReson        .byte $c6
WrkTuneVolume       .byte $ce
                    .byte $a2
                    .byte $aa
                    
TabCopyAmount       .byte $02
                    .byte $01
                    .byte $02
                    .byte $02
                    .byte $06
                    .byte $05
                    .byte $02
                    .byte $02
                    .byte $02
                    .byte $01
                    
WrkCutLoCtrl02      .byte $00
WrkCutLoCtrl03      .byte $00
FlgPlayDemoMusic    .byte $00
                    
AdrOscillators      .word FRELO1                    ;  $D400 - Oscillator 1 Frequency Control (low byte)
                    .word FRELO2                    ;  $D407 - Oscillator 2 Frequency Control (low byte)
                    .word FRELO3                    ;  $D40E - Oscillator 3 Frequency Control (low byte)
                    
AdrTabVoiceVals     .word TabVoice01Vals
                    .word TabVoice02Vals
                    .word TabVoice03Vals
                                      
TabVoice01Vals      .byte $a0
                    .byte $a9
                    .byte $b5
                    .byte $a0
TabVoice01Ctrl      .byte $e5                       ; Oscillator 1 control register
                    .byte $a0
                    .byte $86
                    
TabVoice02Vals      .byte $a0
                    .byte $80
                    .byte $ba
                    .byte $ce
TabVoice02Ctrl      .byte $8d                       ; Oscillator 2 control register
                    .byte $a0
                    .byte $82
                    
TabVoice03Vals      .byte $a0
                    .byte $b8
                    .byte $bc
                    .byte $a0
TabVoice03Ctrl      .byte $b0                       ; Oscillator 3 control register
                    .byte $a0
                    .byte $cc
                    
SavTuneCutLo        .byte $a0
SavTuneCutHi        .byte $b0
TabSidRes           .byte $84
                    
SavVolume           .byte $0f
TabTuneCutLo        .byte $0c
                    .byte $0c
                    .byte $0c
                    
WrkTime             .byte $14
                    
TabTunes01          .byte $0c
                    .byte $1c
                    .byte $2d
                    .byte $3e
                    .byte $51
                    .byte $66
                    .byte $7b
                    .byte $91
                    .byte $a9
                    .byte $c3
                    .byte $dd
                    .byte $fa
                    .byte $18
                    .byte $38
                    .byte $5a
                    .byte $7d
                    .byte $a3
                    .byte $cc
                    .byte $f6
                    .byte $23
                    .byte $53
                    .byte $86
                    .byte $bb
                    .byte $f4
                    .byte $30
                    .byte $70
                    .byte $b4
                    .byte $fb
                    .byte $47
                    .byte $98
                    .byte $ed
                    .byte $47
                    .byte $a7
                    .byte $0c
                    .byte $77
                    .byte $e9
                    .byte $61
                    .byte $e1
                    .byte $68
                    .byte $f7
                    .byte $8f
                    .byte $30
                    .byte $da
                    .byte $8f
                    .byte $4e
                    .byte $18
                    .byte $ef
                    .byte $d2
                    .byte $c3
                    .byte $c3
                    .byte $d1
                    .byte $ef
                    .byte $1f
                    .byte $60
                    .byte $b5
                    .byte $1e
                    .byte $9c
                    .byte $31
                    .byte $df
                    .byte $a5
                    .byte $87
                    .byte $86
                    .byte $a2
                    .byte $df
                    .byte $3e
                    .byte $c1
                    .byte $6b
                    .byte $3c
                    .byte $39
                    .byte $63
                    .byte $be
                    .byte $4b
                    .byte $0f
                    .byte $0c
                    .byte $45
                    .byte $bf
                    .byte $7d
                    .byte $83
                    .byte $d6
                    .byte $79
                    .byte $73
                    .byte $c7
                    .byte $7c
                    .byte $97
                    .byte $1e
                    .byte $18
                    .byte $8b
                    .byte $7e
                    .byte $fa
                    .byte $06
                    .byte $ac
                    .byte $f3
                    .byte $e6
                    .byte $8f
                    .byte $f8
                    .byte $2e
                    
TabTunes02          .byte $01
                    .byte $01
                    .byte $01
                    .byte $01
                    .byte $01
                    .byte $01
                    .byte $01
                    .byte $01
                    .byte $01
                    .byte $01
                    .byte $01
                    .byte $01                  
                    .byte $02
                    .byte $02
                    .byte $02
                    .byte $02
                    .byte $02
                    .byte $02
                    .byte $02
                    .byte $03
                    .byte $03
                    .byte $03
                    .byte $03
                    .byte $03
                    .byte $04
                    .byte $04
                    .byte $04
                    .byte $04
                    .byte $05
                    .byte $05
                    .byte $05
                    .byte $06
                    .byte $06
                    .byte $07
                    .byte $07
                    .byte $07
                    .byte $08
                    .byte $08
                    .byte $09
                    .byte $09
                    .byte $0a
                    .byte $0b
                    .byte $0b
                    .byte $0c
                    .byte $0d
                    .byte $0e
                    .byte $0e
                    .byte $0f
                    .byte $10
                    .byte $11
                    .byte $12
                    .byte $13
                    .byte $15
                    .byte $16
                    .byte $17
                    .byte $19
                    .byte $1a
                    .byte $1c
                    .byte $1d
                    .byte $1f
                    .byte $21
                    .byte $23
                    .byte $25
                    .byte $27
                    .byte $2a
                    .byte $2c
                    .byte $2f
                    .byte $32
                    .byte $35
                    .byte $38
                    .byte $3b
                    .byte $3f
                    .byte $43
                    .byte $47
                    .byte $4b
                    .byte $4f
                    .byte $54
                    .byte $59
                    .byte $5e
                    .byte $64
                    .byte $6a
                    .byte $70
                    .byte $77
                    .byte $7e
                    .byte $86
                    .byte $8e
                    .byte $96
                    .byte $9f
                    .byte $a8
                    .byte $b3
                    .byte $bd
                    .byte $c8
                    .byte $d4
                    .byte $e1
                    .byte $ee
                    .byte $fd
; ------------------------------------------------------------------------------------------------------------- ;
; InitSoundFX       Function: set IRQ sfx pointer ($44/$45) to the requested sound data
;                   Parms   : ac - sound effect number
;                   Returns : xr - not modified
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
InitSoundFX         pha
                    sta SavSFX                      ; effect no
                    tya
                    pha
                    
                    lda FlgRoomLoadAdr              ; $00=$7800 $01=$9800 $02=$b800
                    cmp #CC_LvlStorID
                    beq InitSoundFXX                ; no soundeffects for demo
                    
                    lda FlgSfxOnOff
                    cmp #$01                        ; off
                    beq InitSoundFXX                ; no sound effects
                    
                    lda WrkSFX
                    bpl InitSoundFXX
                    
                    lda SavSFX
                    sta WrkSFX
                    asl a
                    tay
                    lda TabSoundsDataPtr,y          ; Table SoundFX Data Pointer
                    sta $44
                    lda TabSoundsDataPtr+1,y
                    sta $45                         ; ($44/$45) points to sound effect / demo music
                    
                    lda #$00
                    sta VCREG1                      ; SID - $D404 = Oscillator 1 Control
                    sta VCREG2                      ; SID - $D40B = Oscillator 2 Control
                    sta VCREG3                      ; SID - $D412 = Oscillator 3 Control
                    
                    sta RESON                       ; SID - $D417 = Filter Resonance Control
                    sta WrkCutLoCtrl02
                    sta WrkCutLoCtrl03
                    
                    lda #$0f
                    sta SIGVOL                      ; SID - $D418 = Volume and Filter Select
                    
                    lda #$18
                    sta TabTuneCutLo
                    sta TabTuneCutLo+1
                    sta TabTuneCutLo+2
                    
                    lda #$14
                    sta WrkTime
                    
                    asl a
                    asl a                           ; *4
                    ora #$03
                    sta TIMAHI                      ; CIA 1 - $DC05 = Timer A (high byte)
                    
                    lda #$81
                    sta CIAICR                      ; CIA 1 - $DC0D = Interrupt Control
                    lda #$01
                    sta CIACRA                      ; CIA 1 - $DC0E = Control A
                    
InitSoundFXX        pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
SavSFX              .byte $a0
WrkSFX              .byte $ff
; ------------------------------------------------------------------------------------------------------------- ;
; TxtScrnHandler    Function: Control the game options / load castle data files actions
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
TxtScrnHandler      pha                             ; game options / load castle data
                    tya
                    pha
                    txa
                    pha
                    
.InitAll            lda #$0b                        ; ....#.## Bit 5: 0=text mode Bit 3: 1=25 rows  Bits 0-2: vertical fine scrolling
                    sta SCROLY                      ; VIC 2 - $D011 = VIC Control Register 1 (and Vertical Fine Scrolling)
                    
                    lda #$03
                    sta C2DDRA                      ; CIA 2 - $DD02 = Data Direction A
                    sta CI2PRA                      ; CIA 2 - $DD00 = Data Port A   Bits 0-1: 11 = $0000-$3fff - VIC-II chip mem bank 0
                    
                    lda #$00
                    sta $21                         ; CC_ZPgSprt__Enab - sprites 0-7 off
                    
                    lda #$14                        ; Bits 4-7: Screen base address: 1=$0400-$07e7 + base in $DD00 ($0000-$3fff)
                                                    ; Bits 2-3: Char   base address: 2=$1000-$17ff + base in $DD00 ($0000-$3fff)
                    sta $22                         ; CC_ZPgVICMemCtrl
                    
                    lda #<COLORAM
                    sta $30
                    lda #>COLORAM
                    sta $31                         ; $d800 - color ram
                    
                    ldy #$00
.SetColorRamI       lda #WHITE
.SetColorRam        sta ($30),y
                    iny
                    bne .SetColorRam
                    
                    inc $31
                    lda $31
                    cmp #$dc
                    bcc .SetColorRamI
                    
                    lda SCROLY                      ; VIC 2 - $D011 = VIC Control Register 1 (and Vertical Fine Scrolling)
                    ora #$10                        ;   Bit 4: Screen Disable   1=visible again
                    sta SCROLY                      ; VIC 2 - $D011 = VIC Control Register 1 (and Vertical Fine Scrolling)
                    
.GetJoyVal          lda #$00                        ; joystick 2
                    jsr GetKeyJoyVal
                    
                    lda FlgJoyFire
                    bne .Fire
                    
                    lda SavJoyDir
                    and #$fb                        ; #### #.##
                    bne .GetJoyVal
                    
                    ldx WrkDatScrnTabOff
                    clc
                    ldy CC_TextScrnRowY,x
                    lda TabCtrlScrRowsLo,y
                    adc #$00
                    sta $30
                    lda TabCtrlScrRowsHi,y
                    adc #$04
                    sta $31
                    
                    ldy CC_TextScrnRowX,x
                    dey
                    dey
                    lda #" "
                    sta ($30),y
                    
                    lda SavJoyDir
                    beq .Up                         ; CC_WAJoyMoveU
                    
                    lda WrkDatScrnTabOff
                    cmp MaxDatScrnTabOff
                    bne .NextFilePos
                    
.FirstFilePos       lda #$00
                    jmp .StoreFilePos
                    
.NextFilePos        clc
                    adc #$04
                    jmp .StoreFilePos
                    
.Up                 lda WrkDatScrnTabOff
                    bne .PrevFilePos
                    
                    lda MaxDatScrnTabOff
                    jmp .StoreFilePos
                    
.PrevFilePos        sec
                    sbc #$04
                    
.StoreFilePos       sta WrkDatScrnTabOff
                    
                    tax
                    ldy CC_TextScrnRowY,x
                    clc
                    lda TabCtrlScrRowsLo,y
                    adc #$00
                    sta $30
                    lda TabCtrlScrRowsHi,y
                    adc #$04
                    sta $31
                    
                    ldy CC_TextScrnRowX,x
                    dey
                    dey
                    lda #">"
                    sta ($30),y
                    
                    jmp .GoGetJoyVal
                    
.Fire               ldx WrkDatScrnTabOff
                    lda CC_TextScrnType,x
                    bne .ChkDynFile                 ; CC_TextScrnLives
                    
.LivesOnOff         lda UnlimLivesOnOff
                    eor #$ff
                    sta UnlimLivesOnOff
                    
                    clc
                    ldy CC_TextScrnRowY,x
                    lda TabCtrlScrRowsLo,y
                    adc #$00
                    sta $30
                    lda TabCtrlScrRowsHi,y
                    adc #$04
                    sta $31
                    
                    lda CC_TextScrnRowX,x
                    clc
                    adc #$11
                    tay
                    ldx #$00
.FlipLives          cpx #$02                        ; omit the "/" separator
                    beq .NextFlip
                    
.Flip               lda ($30),y
                    eor #$80                        ; flip the reverse on/off bit
                    sta ($30),y
                    
.NextFlip           inx
                    iny
                    cpx #$06                        ; length of "on/off"
                    bcc .FlipLives
                    
.GoGetJoyVal        jsr WaitJoyKeyRlse
                    jmp .GetJoyVal
                    
.ChkDynFile         cmp #CC_TextScrnFile
                    bne .ChkResume
                    
                    ldx WrkDatScrnTabOff            ; screen entry number castle data file name
                    jsr LoadCastleData
                    
.GoInitAll          jmp .InitAll
                    
.ChkResume          cmp #CC_TextScrnResum
                    bne .CheckTimes
                    
                    jsr ResumeGameFile
                    
                    lda SavResumeResult
                    cmp #$01
                    bne .GoInitAll
                    
.CheckTimes         cmp #CC_TextScrnTimes
                    bne .Exit                       ; CC_TextScrnExit not checked yet and left over
                    
                    lda OldDatScrnTabOff
                    cmp #$ff
                    beq .GoInitAll
                    
                    jsr Restart
                    jsr ShowBestTimes
                    
                    lda #<TextExit
                    sta $3e
                    lda #>TextExit
                    sta $3f
                    jsr RoomTextLine                ; Room: TextLine
                    
                    lda SCROLY                      ; VIC 2 - $D011 = VIC Control Register 1 (and Vertical Fine Scrolling)
                    ora #$10                        ;   Bit 4: Screen Disable   1=visible again
                    sta SCROLY                      ; VIC 2 - $D011 = VIC Control Register 1 (and Vertical Fine Scrolling)
                    
                    lda #$00
                    sta BestTimesMaxLen
                    
                    jsr NewHighScoreID
                    jmp .InitAll
                    
.Exit               jsr WaitJoyKeyRlse
                    jsr Restart
                    
TxtScrnHandlerX     pla
                    tax
                    pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
; WaitJoyKeyRlse    Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
WaitJoyKeyRlse      pha
                    
.WaitI              lda #$02
                    sta WrkCountIRQs                ; counted down to $00 with every IRQ
.Wait               lda WrkCountIRQs                ; counted down to $00 with every IRQ
                    bne .Wait
                    
                    lda #$00                        ; jostick 2
                    jsr GetKeyJoyVal
                    
                    lda SavJoyDir
                    bpl .WaitI                      ; still moved
                    
                    lda FlgJoyFire
                    bne .WaitI                      ; still pressed
                    
WaitJoyKeyRlseX     pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
WrkDatScrnTabOff    .byte $a0
OldDatScrnTabOff    .byte $ff
MaxDatScrnTabOff    .byte $a0
UnlimLivesOnOff     .byte $00
; ------------------------------------------------------------------------------------------------------------- ;
TextExit            .byte $10                       ; StartPos  : Col = 20
                    .byte $c0                       ; StartPos  : Row = 00
                    .byte GREY                      ; ColorNo   :
                    .byte $21                       ; Format    : 21 = normal/normal size
                    .byte $50                       ; Text      : (max 20 chr) = presS
                    .byte $52
                    .byte $45
                    .byte $53
                    .byte $d3
                    
                    .byte $78                       ; StartPos  : Col = 20
                    .byte $c0                       ; StartPos  : Row = 00
                    .byte GREY                      ; ColorNo   :
                    .byte $21                       ; Format    : 21 = normal/normal size
                    .byte $54                       ; Text      : (max 20 chr) = to exiT
                    .byte $4f
                    .byte $20
                    .byte $45
                    .byte $58
                    .byte $49
                    .byte $d4
                    
                    .byte $40                       ; StartPos  : Col = 20
                    .byte $c0                       ; StartPos  : Row = 00
T_23b2              .byte GREY                      ; ColorNo   :
                    .byte $31                       ; Format    : 31 = reverse/normal size
                    .byte $52                       ; Text      : (max 20 chr) = returN
                    .byte $45
                    .byte $54
                    .byte $55
                    .byte $52
                    .byte $ce
                    
T_23ba              .byte $00
; ------------------------------------------------------------------------------------------------------------- ;
; LoadCastleData    Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
LoadCastleData      pha
                    tya
                    pha
                    
                    cpx OldDatScrnTabOff
                    bne .GetNewFile                 ; new file requested
                    
                    jmp LoadCastleDataX             ; castle data already loaded
                    
.GetNewFile         lda #"Z" ; $5a                  ; z = castle data file id
                    sta LoadFileNameId
                    ldy CC_TextScrnRowY,x
                    lda TabCtrlScrRowsLo,y
                    sta $30
                    lda TabCtrlScrRowsHi,y
                    ora #$04
                    sta $31
                    clc
                    lda $30
                    adc CC_TextScrnRowX,x
                    sta $30
                    bcc .CpyFileNameI
                    inc $31
                    
.CpyFileNameI       ldy #$00
.CpyFileName        lda ($30),y                     ; screen file name store
                    cmp #$20                        ; blank
                    bcs .PutFileName                ; equal or higher
                    
                    ora #$40                        ; from screen code to chr code
.PutFileName        sta LoadFileName,y
                    iny
                    cpy #$0f                        ; max lenght file name
                    bcc .CpyFileName
                    
                    ldy CC_TextScrnLen,x
                    sty LoadFileNamLen
                    lda #$01
                    sta LoadFileAdrFlag             ; entry 2: $9800
                    
                    jsr PrepareIO
                    jsr VerifyDisk                  ; obsolete 
                    
                    cmp #$00
                    bne .Failed
                    
                    jsr LoadLevelData
                    jsr READST                      ; KERNEL - $FFB7 = read I/O status word
                    cmp #$40                        ; end of file
                    beq .HighScore
                    
.Failed             jsr WaitRestart
                    jmp LoadCastleDataX
                    
.HighScore          lda #"Y"                        ; y = castle data high scores id
                    sta LoadFileNameId
                    lda #$02
                    sta LoadFileAdrFlag             ; entry 3: $b800
                    
                    jsr LoadLevelData
                    jsr READST                      ; KERNEL - $FFB7 = read I/O status word
                    cmp #$40                        ; end of file
                    beq .LoadedBoth
                    
                    lda #CC_BestLenUsedHi
                    sta CC_BestLenHi
                    lda #CC_BestLenUsedLo
                    sta CC_BestLenLo
                    
.InitHighScoreI     ldy #CC_BestLenUsedHi - CC_BestLenHdr - 1
                    lda #CC_EoBestTimes
.InitHighScore      sta CC_BestPlayers,y
                    dey
                    bpl .InitHighScore
                    
.LoadedBoth         jsr WaitRestart
                    
.FileInvI           ldy CC_TextScrnRowY,x            ; init file inversion pointer
                    lda TabCtrlScrRowsLo,y
                    sta $30
                    lda TabCtrlScrRowsHi,y
                    ora #$04
                    sta $31
                    clc
                    lda CC_TextScrnRowX,x
                    adc $30
                    sta $30
                    bcc .FileRevI
                    inc $31
                    
.FileRevI           stx SavNewDatFilePos            ; init file reversion pointer
                    ldx OldDatScrnTabOff            ; old file name (still reversed)
                    ldy CC_TextScrnRowY,x
                    lda TabCtrlScrRowsLo,y
                    sta $32
                    lda TabCtrlScrRowsHi,y
                    ora #$04
                    sta $33
                    clc
                    lda $32
                    adc CC_TextScrnRowX,x
                    sta $32
                    bcc .FileInvRevI
                    inc $33
                    
.FileInvRevI        ldy #$0f                        ; max length file name
                    ldx SavNewDatFilePos
.FileInvRev         lda OldDatScrnTabOff
                    cmp #$ff                        ; none loaded so far
                    beq .FileInv
.FileRev            lda ($32),y
                    and #$7f
                    sta ($32),y                     ; reverse old file name
.FileInv            lda ($30),y
                    ora #$80
                    sta ($30),y                     ; inverse new file name
                    dey
                    bpl .FileInvRev
                    
                    stx OldDatScrnTabOff
                    
LoadCastleDataX     pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
SavNewDatFilePos    .byte $86
; ------------------------------------------------------------------------------------------------------------- ;
; ResumeGameFile    Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
ResumeGameFile      pha
                    txa
                    pha
                    
                    jsr Restart
                    
                    lda #$01
                    sta FlgSavResGame               ; 1=resume a game
                    
                    jsr SaveResumeGame
                    
                    ldx BestTimesInpLen
                    beq ResumeGameFileX
                    
.CopyFileName       dex
                    bmi .ResumeInit
                    
                    lda BestTimesLine,x
                    sta LoadFileNameId,x
                    jmp .CopyFileName
                    
.ResumeInit         lda BestTimesInpLen
                    sta LoadFileNamLen
                    lda #$00
                    sta LoadFileAdrFlag             ; $00=$7800  $01=$9800  $02=$b800
                    
                    jsr PrepareIO
                    jsr VerifyDisk                  ; obsolete 
                    
                    cmp #$01
                    beq .Resume
                    
                    jsr WaitRestart
                    
                    jmp ResumeGameFileX
                    
.Resume             jsr LoadLevelData
                    jsr READST                      ; KERNEL - $FFB7 = read I/O status word
                    
                    sta SavResumeStatus
                    
                    jsr WaitRestart
                    
                    lda SavResumeStatus
                    cmp #$40
                    bne ResumeGameFileX
                    
                    lda #$01
                    sta SavResumeResult
                    
ResumeGameFileX     pla
                    tax
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
SavResumeResult     .byte $00
SavResumeStatus     .byte $90
; ------------------------------------------------------------------------------------------------------------- ;
; SaveGame          Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
SaveGame            pha
                    txa
                    pha
                    lda #$00
                    sta FlgSavResGame               ; 0=save a game
                    
                    jsr SaveResumeGame
                    
                    ldx BestTimesInpLen
                    beq SaveGameX
                    
.CopyFileName       dex
                    bmi .SaveInit
                    
                    lda BestTimesLine,x
                    sta SaveFileNameId,x
                    jmp .CopyFileName
                    
.SaveInit           lda BestTimesInpLen
                    sta SaveFileNameLen
                    lda #$00
                    sta SaveFileAdrFlag             ; $00=$7800  $01=$9800  $02=$b800
                    
                    jsr PrepareIO
                    jsr VerifyDisk                  ; obsolete 
                    
                    cmp #$01
                    bne .GoRestart
                    
                    jsr SaveFile
                    jsr READST                      ; KERNEL - $FFB7 = read I/O status word --> $FE07
                    
                    cmp #$00
                    bne .GoRestart
                    
                    jsr WaitRestart
                    jmp SaveGameX
                    
.GoRestart          jsr WaitRestart
                    
                    cmp #$00
                    beq .TxtMasterInit
                    
                    lda #<TextIOError
                    sta $3e
                    lda #>TextIOError
                    jmp .TxtMasterStore
                    
.TxtMasterInit      lda #<TextMasterDisk
                    sta $3e
                    lda #>TextMasterDisk
.TxtMasterStore     sta $3f
                    
                    jsr InitHiResSprtWA             ; initialize the hires screen and sprite work area
                    jsr RoomTextLine                ; Room: TextLine
                    
                    lda SCROLY                      ; VIC 2 - $D011 = VIC Control Register 1 (and Vertical Fine Scrolling)
                    ora #$10                        ;   Bit 4: Screen Disable   1=visible again
                    sta SCROLY                      ; VIC 2 - $D011 = VIC Control Register 1 (and Vertical Fine Scrolling)
                    
                    lda #$23                        ; dynamic wait time
                    jsr DynWait
                    
SaveGameX           pla
                    tax
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
TextMasterDisk      .byte $10                       ; StartPos  : Col = 20
                    .byte $40                       ; StartPos  : Row = 00
                    .byte LT_RED                    ; ColorNo   :
                    .byte $22                       ; Format    : 22 = normal/double size
                    .byte $59                       ; Text      : (max 20 chr) = you cannot save youR
                    .byte $4f
                    .byte $55
                    .byte $20
                    .byte $43
                    .byte $41
                    .byte $4e
                    .byte $4e
                    .byte $4f
                    .byte $54
                    .byte $20
                    .byte $53
                    .byte $41
                    .byte $56
                    .byte $45
                    .byte $20
                    .byte $59
                    .byte $4f
                    .byte $55
                    .byte $d2
                    
                    .byte $24                       ; StartPos  : Col = 20
                    .byte $58                       ; StartPos  : Row = 00
                    .byte LT_RED                    ; ColorNo   :
                    .byte $22                       ; Format    : 22 = normal/double size
                    .byte $50                       ; Text      : (max 20 chr) = position to thE
                    .byte $4f
                    .byte $53
                    .byte $49
                    .byte $54
                    .byte $49
                    .byte $4f
                    .byte $4e
                    .byte $20
                    .byte $54
                    .byte $4f
                    .byte $20
                    .byte $54
                    .byte $48
                    .byte $c5
                    
                    .byte $34                       ; StartPos  : Col = 20
                    .byte $70                       ; StartPos  : Row = 00
                    .byte LT_RED                    ; ColorNo   :
                    .byte $22                       ; Format    : 22 = normal/double size
                    .byte $4d                       ; Text      : (max 20 chr) = master disK
                    .byte $41
                    .byte $53
                    .byte $54
                    .byte $45
                    .byte $52
                    .byte $20
                    .byte $44
                    .byte $49
                    .byte $53
                    .byte $cb
                    
                    .byte $00
                    
TextIOError         .byte $3c                       ; StartPos  : Col = 20
                    .byte $50                       ; StartPos  : Row = 00
                    .byte LT_RED                    ; ColorNo   :
                    .byte $22                       ; Format    : 22 = normal/double size
                    .byte $49                       ; Text      : (max 20 chr) = i/o erroR
                    .byte $2f
                    .byte $4f
                    .byte $20
                    .byte $45
                    .byte $52
                    .byte $52
                    .byte $4f
                    .byte $d2
                    
                    .byte $00
; ------------------------------------------------------------------------------------------------------------- ;
; SaveResumeGame    Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
SaveResumeGame      pha
                    
                    jsr InitHiResSprtWA             ; initialize the hires screen and sprite work area
                    
                    lda #<TextSavFilNam
                    sta $3e
                    lda #>TextSavFilNam
                    sta $3f
                    jsr PaintRoomItems
                    
                    lda FlgSavResGame               ; 0=save 1=resume a game
                    beq .SaveGame
                    
.ResumeGame         lda #<TextResumeGame
                    sta $3e
                    lda #>TextResumeGame
                    sta $3f
                    jmp .PaintScreen
                    
.SaveGame           lda #<TextSaveGame
                    sta $3e
                    lda #>TextSaveGame
                    sta $3f
                    
.PaintScreen        jsr PaintRoomItems
                    
                    lda SCROLY                      ; VIC 2 - $D011 = VIC Control Register 1 (and Vertical Fine Scrolling)
                    ora #$10                        ;   Bit 4: Screen Disable   1=visible again
                    sta SCROLY                      ; VIC 2 - $D011 = VIC Control Register 1 (and Vertical Fine Scrolling)
                    lda #$20
                    sta BestTimesPosX
                    lda #$48
                    sta BestTimesPosY
                    lda #$10
                    sta BestTimesMaxLen
                    
                    lda #$01
                    sta BestTimesColor
                    lda #$02
                    sta BestTimesFormat
                    
                    jsr NewHighScoreID
                    
SaveResumeGameX     pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
FlgSavResGame       .byte $a0
; ------------------------------------------------------------------------------------------------------------- ;
TextSaveGame        .byte $6d
                    .byte $2a                       ; pointer to $2a6d - Room: TextLine
                    
                    .byte $2c                       ; StartPos  : Col = 2c
                    .byte $00                       ; StartPos  : Row = 00
                    .byte WHITE                     ; ColorNo   :
                    .byte $22                       ; Format    : 22 = normal/double size
                    .byte $53                       ; Text      : (max 20 chr) = save positioN
                    .byte $41
                    .byte $56
                    .byte $45
                    .byte $20
                    .byte $50
                    .byte $4f
                    .byte $53
                    .byte $49
                    .byte $54
                    .byte $49
                    .byte $4f
                    .byte $ce                       ; EndOfLine = Bit 7 set
                    
                    .byte $00                       ; EndOfText
                    
                    .byte $00                       ; EndOfData
                    .byte $00
; ------------------------------------------------------------------------------------------------------------- ;
TextResumeGame      .byte $6d
                    .byte $2a                       ; pointer to $2a6d - Room: TextLine
                    
                    .byte $34                       ; StartPos  : Col = 34
                    .byte $00                       ; StartPos  : Row = 00
                    .byte WHITE                     ; ColorNo   :
                    .byte $22                       ; Format    : 22 = normal/double size
                    .byte $52                       ; Text      : (max 20 chr) = resume gamE
                    .byte $45
                    .byte $53
                    .byte $55
                    .byte $4d
                    .byte $45
                    .byte $20
                    .byte $47
                    .byte $41
                    .byte $4d
                    .byte $c5                       ; EndOfLine = Bit 7 set
                    
                    .byte $00                       ; EndOfText
                    
                    .byte $00                       ; EndOfData
                    .byte $00
; ------------------------------------------------------------------------------------------------------------- ;
TextSavFilNam       .byte $6d
                    .byte $2a                       ; pointer to $2a6d - Room: TextLine
                    
                    .byte $1c                       ; StartPos  : Col = 1c
                    .byte $30                       ; StartPos  : Row = 30
                    .byte LT_GREEN                  ; ColorNo   :
                    .byte $21                       ; Format    : 21 = normal/normal size
                    .byte $54                       ; Text      : (max 20 chr) = type in file namE
                    .byte $59
                    .byte $50
                    .byte $45
                    .byte $20
                    .byte $49
                    .byte $4e
                    .byte $20
                    .byte $46
                    .byte $49
                    .byte $4c
                    .byte $45
                    .byte $20
                    .byte $4e
                    .byte $41
                    .byte $4d
                    .byte $c5                       ; EndOfLine = Bit 7 set
                    
                    .byte $18                       ; StartPos  : Col = 18
                    .byte $38                       ; StartPos  : Row = 38
                    .byte LT_GREEN                  ; ColorNo   :
                    .byte $21                       ; Format    : 21 = normal/normal size
                    .byte $46                       ; Text      : (max 20 chr) = followed bY
                    .byte $4f
                    .byte $4c
                    .byte $4c
                    .byte $4f
                    .byte $57
                    .byte $45
                    .byte $44
                    .byte $20
                    .byte $42
                    .byte $d9                       ; EndOfLine = Bit 7 set
                    
                    .byte $78                       ; StartPos  : Col = 78
                    .byte $38                       ; StartPos  : Row = 38
                    .byte LT_GREEN                  ; ColorNo   :
                    .byte $31                       ; Format    : 21 = normal/normal size
                    .byte $52                       ; Text      : (max 20 chr) = returN
                    .byte $45
                    .byte $54
                    .byte $55
                    .byte $52
                    .byte $ce                       ; EndOfLine = Bit 7 set
                    
                    .byte $20                       ; StartPos  : Col = 20
                    .byte $78                       ; StartPos  : Row = 78
                    .byte LT_RED                    ; ColorNo   :
                    .byte $21                       ; Format    : 21 = normal/normal size
                    .byte $50                       ; Text      : (max 20 chr) = press
                    .byte $52
                    .byte $45
                    .byte $53
                    .byte $53
                    
                    .byte $20                       ; blank - placeholder filled with "restorE" below
                    .byte $20
                    .byte $20
                    .byte $20
                    .byte $20
                    .byte $20
                    .byte $20
                    .byte $20
                    .byte $20
                    
                    .byte $54                       ; tO
                    .byte $cf                       ; EndOfLine = Bit 7 set
                    
                    .byte $50                       ; StartPos  : Col = 50
                    .byte $78                       ; StartPos  : Row = 78
                    .byte LT_RED                    ; ColorNo   :
                    .byte $31                       ; Format    : 31 = reverse/normal size
                    .byte $52                       ; Text      : (max 20 chr) = restorE
                    .byte $45
                    .byte $53
                    .byte $54
                    .byte $4f
                    .byte $52
                    .byte $c5                       ; EndOfLine = Bit 7 set
                    
                    .byte $48                       ; StartPos  : Col = 48
                    .byte $80                       ; StartPos  : Row = 80
                    .byte LT_RED                    ; ColorNo   :
                    .byte $21                       ; Format    : 21 = normal/normal size
                    .byte $43                       ; Text      : (max 20 chr) = canceL
                    .byte $41
                    .byte $4e
                    .byte $43
                    .byte $45
                    .byte $cc                       ; EndOfLine = Bit 7 set
                    
                    .byte $00                       ; EndOfText
                    
                    .byte $00                       ; EndOfData
                    .byte $00
; ------------------------------------------------------------------------------------------------------------- ;
; NewHighScoreID    Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
NewHighScoreID      pha
                    txa
                    pha
                    
                    lda #$00
                    sta FlgRestoreKey               ; restore key pressed  01=pressed
                    
                    lda BestTimesColor
                    sta PaintTextColor
                    
                    lda BestTimesFormat
                    ora #CC_TextNormal              ; normal (not reversed)
                    sta PaintTextFormat
                    
                    lda BestTimesPosX
                    sta PaintTextPosX
                    lda BestTimesPosY
                    sta PaintTextPosY
                    
                    lda # "-"
                    sta TextInputCursor
                    ldx BestTimesMaxLen
.SetInputMark       cpx #$00
                    beq .SetInLen
                    
                    jsr PaintSingleChar
                    
                    dex
                    clc
                    lda PaintTextPosX
                    adc #$08
                    sta PaintTextPosX
                    jmp .SetInputMark
                    
.SetInLen           stx BestTimesInpLen             ; 00
.NextInitial        lda BestTimesInpLen
                    cmp BestTimesMaxLen
                    beq .NoCursor
                    
.RotateCursor       inc WrkInputCursorNo
                    lda WrkInputCursorNo
                    and #$03                        ; only 4 different forms
                    tax
                    lda TabInputCursor,x
                    sta TextInputCursor
                    
                    lda BestTimesInpLen
                    asl a
                    asl a
                    asl a                           ; *8
                    clc
                    adc BestTimesPosX
                    sta PaintTextPosX
                    
.PaintCursor        jsr PaintSingleChar
                    
.NoCursor           jsr GetInputKey
                    
                    cmp #$80                        ; bad key
                    bne .ChkKeyDelete
                    
                    lda FlgRestoreKey               ; restore key pressed  01=pressed
                    cmp #$01
                    beq .KeyRestore
                    
                    lda #$03
                    sta WrkCountIRQs                ; counted down to $00 with every IRQ
.WaitKey            lda WrkCountIRQs
                    bne .WaitKey
                    
                    jmp .NextInitial
                    
.KeyRestore         lda #$00
                    sta BestTimesInpLen
                    
.WaitI              lda #$00
                    sta FlgRestoreKey               ; restore key pressed  01=pressed
                    
                    lda #$03
                    sta WrkCountIRQs                ; counted down to $00 with every IRQ
.WaitRestore        lda WrkCountIRQs
                    bne .WaitRestore
                    
                    lda FlgRestoreKey               ; restore key pressed  01=pressed
                    cmp #$00                        ; still pressed
                    bne .WaitI
                    
                    jmp NewHighScoreIDX             ; exit if RESTORE pressed
                    
.ChkKeyDelete       cmp #$08
                    bne .ChkKeyReturn
                    
                    lda BestTimesInpLen
                    cmp BestTimesMaxLen
                    beq .ChkInputLen
                    
                    lda #"-"
                    sta TextInputCursor
                    
                    jsr PaintSingleChar
                    
.ChkInputLen        lda BestTimesInpLen
                    beq .GoNextInitial
                    
                    dec BestTimesInpLen
.GoNextInitial      jmp .NextInitial
                    
.ChkKeyReturn       cmp #$0d
                    bne .ChkInputMax
                    
                    jmp NewHighScoreIDX
                    
.ChkInputMax        ldx BestTimesInpLen
                    cpx BestTimesMaxLen
                    beq .GoNextInitial
                    
                    sta BestTimesLine,x
                    inx
                    stx BestTimesInpLen
                    sta TextInputCursor
                    
.PaintInitial       jsr PaintSingleChar
                    
                    jmp .NextInitial
                    
NewHighScoreIDX     pla
                    tax
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
; PaintSingleChar   Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
PaintSingleChar     pha
                    
                    lda TextInputCursor
                    ora #$80                        ; set end of line
                    sta TextInputCursor
                    
                    lda #<TextInputCursor
                    sta $3e
                    lda #>TextInputCursor
                    sta $3f
                    
                    jsr PaintText
                    
PaintSingleCharX    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
BestTimesPosX       .byte $a0
BestTimesPosY       .byte $a0
BestTimesColor      .byte $a4
BestTimesFormat     .byte $b2
BestTimesMaxLen     .byte $a0
BestTimesInpLen     .byte $ff
BestTimesLine       .byte $a0
                    .byte $e5
                    .byte $b2
                    .byte $a4
                    .byte $b2
                    .byte $a0
                    .byte $c8
                    .byte $c4
                    .byte $96
                    .byte $a0
                    .byte $cc
                    .byte $a0
                    .byte $a0
                    .byte $b2
                    .byte $a0
                    .byte $a0
                    .byte $a0
                    .byte $a5
                    .byte $a0
                    .byte $a0
                    
TextInputCursor     .byte $ff                       ; one byte only
                    
WrkInputCursorNo    .byte $b9
TabInputCursor      .byte $6c
                    .byte $7b
                    .byte $7e
                    .byte $7c
; ------------------------------------------------------------------------------------------------------------- ;
; GetInputKey       Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
GetInputKey         pha
                    tya
                    pha
                    txa
                    pha
                    
                    lda #$00
                    sta PtrKeyValues
                    sta PtrTabKeys
                    
                    lda #$fe                        ; check keyboard matrix row - 0 for row to read / 1 for row to ignore
                    sta KeyMatrixRowMask            ; #######. = row 0 (CRSR_D/F5/F3/F1/F7/CRSR_R/RETURN/DELETE)
                    
                    lda #$ff                        ; prepare read  if A=$ff and B=$00
                    sta CIDDRA                      ; CIA 1 - $DC02 = Data Direction A
                    lda #$00                        ; prepare read  if A=$ff and B=$00
                    sta CIDDRB                      ; CIA 1 - $DC03 = Data Direction B
                    
.ReadNextKeyRow     lda KeyMatrixRowMask
                    sta CIAPRA                      ; CIA 1 - $DC00 = Data Port A - write to    A
                    lda CIAPRB                      ; CIA 1 - $DC01 = Data Port B - read  from  B
                    sta KeyMatrixColMask            ; check which key in row 0 was pressed
                    
                    lda #$07
                    sta WrkRowBitNo                 ; check all 8 bits
.ChkRow             lsr KeyMatrixColMask            ; shift out key bits startig with Bit0
                    bcs .SetNextRow                 ; 1= not pressed
                    
                    ldx PtrTabKeys
                    lda TabKeys,x
                    bmi .SetNextRow                 ; illegal key
                    
                    ldx PtrKeyValues
                    sta WrkKeyValues,x
                    inx
                    stx PtrKeyValues
                    cpx #$03
                    beq .KeyNew                     ; exit if 3 keys found
                    
.SetNextRow         inc PtrTabKeys
                    dec WrkRowBitNo
                    bpl .ChkRow
                    
                    sec                             ; set to be shure only one row eill be checked
                    rol KeyMatrixRowMask            ; no key pressed in this row - set next
                    bcs .ReadNextKeyRow             ; still one row left to check
                    
.KeyNew             ldx #$00
.KeyNewChk          cpx PtrKeyValues
                    beq .SetBad
                    
                    ldy #$00
.KeyOldChk          cpy PtrSavKeyValues
                    beq .SetGood
                    
                    lda SavKeyValues,y
                    cmp WrkKeyValues,x
                    beq .KeyNewNext
                    
                    iny
                    jmp .KeyOldChk
                    
.KeyNewNext         inx
                    jmp .KeyNewChk
                    
.SetBad             lda #$80
                    jmp .KeyStore
                    
.SetGood            lda WrkKeyValues,x
.KeyStore           sta WrkRowBitNo
                    
                    ldx PtrKeyValues
                    stx PtrSavKeyValues
.KeyCopy            dex
                    bmi GetInputKeyX
                    
                    lda WrkKeyValues,x
                    sta SavKeyValues,x
                    jmp .KeyCopy
                    
GetInputKeyX        pla
                    tax
                    pla
                    tay
                    pla
                    lda WrkRowBitNo
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
TabKeys             = *
KeyMatrixColBit0    .byte $08 ; good: DELETE
                    .byte $0d ; good: RETURN
                    .byte $08 ; good: CRSR_R - mapped to DELETE
                    .byte $80 ; bad : F7
                    .byte $80 ; bad : F1
                    .byte $80 ; bad : F3
                    .byte $80 ; bad : F5
                    .byte $80 ; bad : CRSR_D
                    
KeyMatrixColBit1    .byte $33 ; good: 3
                    .byte $57 ; good: W
                    .byte $41 ; good: A
                    .byte $34 ; good: 4
                    .byte $5a ; good: Z
                    .byte $53 ; good: S
                    .byte $45 ; good: E
                    .byte $80 ; bad : LSHIFT
                     
KeyMatrixColBit2    .byte $35 ; good: 5 
                    .byte $52 ; good: R
                    .byte $44 ; good: D
                    .byte $36 ; good: 6
                    .byte $43 ; good: C
                    .byte $46 ; good: F
                    .byte $54 ; good: T
                    .byte $58 ; good: X
                    
KeyMatrixColBit3    .byte $37 ; good: 7
                    .byte $59 ; good: Y
                    .byte $47 ; good: G
                    .byte $38 ; good: 8
                    .byte $42 ; good: B
                    .byte $48 ; good: H
                    .byte $55 ; good: U
                    .byte $56 ; good: V
                    
KeyMatrixColBit4    .byte $39 ; good: 9
                    .byte $49 ; good: I
                    .byte $4a ; good: J
                    .byte $30 ; good: 0
                    .byte $4d ; good: M
                    .byte $4b ; good: K
                    .byte $4f ; good: O
                    .byte $4e ; good: N
                     
KeyMatrixColBit5    .byte $2b ; good: +
                    .byte $50 ; good: P
                    .byte $4c ; good: L
                    .byte $2d ; good: -
                    .byte $2e ; good: .
                    .byte $3a ; good: :
                    .byte $40 ; good: @
                    .byte $2c ; good: ,
                    
KeyMatrixColBit6    .byte $80 ; bad : LIRA
                    .byte $2a ; good: *
                    .byte $3b ; good: ;
                    .byte $80 ; bad : HOME
                    .byte $80 ; bad : RSHIFT
                    .byte $3d ; good: =
                    .byte $80 ; bad : ^
                    .byte $2f ; good: /
                    
KeyMatrixColBit7    .byte $31 ; good: 1
                    .byte $08 ; good: <- 
                    .byte $80 ; bad : CTRL
                    .byte $32 ; good: 2
                    .byte $20 ; good: SPACE
                    .byte $80 ; bad : C=
                    .byte $51 ; good: Q
                    .byte $80 ; bad : STOP
                    
PtrKeyValues        .byte $a0
WrkKeyValues        .byte $a0
                    .byte $d2
                    .byte $a0
PtrSavKeyValues     .byte $00
SavKeyValues        .byte $b2
                    .byte $c6
                    .byte $c8
KeyMatrixRowMask    .byte $a0
KeyMatrixColMask    .byte $ae
PtrTabKeys          .byte $a0
WrkRowBitNo         .byte $ff
; ------------------------------------------------------------------------------------------------------------- ;
; SaveFile          Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
SaveFile            pha
                    tya
                    pha
                    txa
                    pha
                    
                    lda #$02
                    ldx #$08
                    ldy #$00
                    jsr SETLFS                      ; KERNEL - $FFBA = set logical file parameters
                    
                    clc
                    lda SaveFileNameLen
                    adc #$03
                    ldx #$d3
                    ldy #$28
                    jsr SETNAM                      ; KERNEL - $FFBD = set filename parameters
                    
                    lda SaveFileAdrFlag             ; $00=$7800  $01=$9800  $02=$b800
                    asl a
                    tax
                    lda SaveFileAdr,x
                    sta $30
                    lda SaveFileAdr+1,x
                    sta $31                         ; KERNEL SAVE - start address registers
                    
                    clc
                    ldy #$00
                    lda ($30),y
                    adc $30
                    tax                             ; KERNEL SAVE - EndOfSaveData address low
                    iny
                    lda ($30),y
                    adc $31
                    tay                             ; KERNEL SAVE - EndOfSaveData address high
                    
                    lda #$30                        ; KERNEL SAVE - start address registers
                    jsr SAVE                        ; KERNEL - $FFD8 = save to a device
                    
SaveFileX           pla
                    tax
                    pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
SaveFileAdrFlag     .byte $a0                       ; $00=$7800  $01=$9800  $02=$b800
SaveFileNameLen     .byte $ff
                    .byte $40
                    .byte $30
                    .byte $3a
SaveFileNameId      .byte $f0                       ; 16 byte disk file name buffer
SaveFileName        .byte $b0
                    .byte $b1
                    .byte $b2
                    .byte $a0
                    .byte $f0
                    .byte $a0
                    .byte $96
                    .byte $a0
                    .byte $a0
                    .byte $b8
                    .byte $a0
                    .byte $85
                    .byte $a0
                    .byte $d3
                    .byte $a0
SaveFileAdr         .word CC_LvlGame
                    .word CC_LvlStor
                    .word CC_LvlTimes
; ------------------------------------------------------------------------------------------------------------- ;
; LoadLevelData     Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
LoadLevelData       pha
                    tya
                    pha
                    txa
                    pha
                    
                    lda #$02
                    ldx #$08
                    ldy #$00
                    jsr SETLFS                      ; KERNEL - $FFBA = set logical file parameters
                    
                    lda LoadFileNamLen
                    ldx #<LoadFileNameId
                    ldy #>LoadFileNameId
                    jsr SETNAM                      ; KERNEL - $FFBD = set filename parameters
                    
                    lda #$00                        ; Flag: $00=Load $01=Check
                    ldx LoadFileAdrFlag             ; Load address HIGH offset
                    ldy TabPutAdr,x                 ; Load address HIGH
                    ldx #$00                        ; Load address LOW
                    jsr LOAD                        ; KERNEL - $FFD5 = load from device
                    
                    stx LoadFileEoDLo
                    sty LoadFileEoDHi
                    
LoadLevelDataX      pla
                    tax
                    pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
TabPutAdr           .byte >CC_LvlGame               ; to $7800  - active level
                    .byte >CC_LvlStor               ; to $9800  - loaded level data
                    .byte >CC_LvlTimes              ; to $b800  - best times
; ------------------------------------------------------------------------------------------------------------- ;
; PrepareIO         Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
PrepareIO           pha
                    tya
                    pha
                    txa
                    pha
                    
                    lda #$00                        ; all IRQ sources=OFF
                    sta IRQMASK                     ; VIC 2 - $D01A = IRQ Mask
                    lda #$7f
                    sta CIAICR                      ; CIA 1 - $DC0D = Interrupt Control
                    lda CIAICR                      ; CIA 1 - $DC0D = Interrupt Control
                    
                    lda #$07
                    sta $00                         ; D6510 - CPU Port Data Direction Register
                    lda #$06                        ; 
                    sta $01                         ; R6510 - CPU Port Data Register -> basic=off io=on kernel=on
                    jsr IOINIT                      ; KERNEL - $FF84 = init I/O devices
                    
                    lda #$07
                    sta $00                         ; D6510 - CPU Port Data Direction Register
                    lda #$06                        ; 
                    sta $01                         ; R6510 - CPU Port Data Register -> basic=off io=on kernel=on
                    
                    lda SCROLY                      ; VIC 2 - $D011 = VIC Control Register 1 (and Vertical Fine Scrolling)
                    and #$20                        ;   Bit 5: Enable bitmap graphics mode  1=enable
                    beq PrepareIOX                  ;   not set
                    
                    lda C2DDRA                      ; CIA 2 - $DD02 = Data Direction A
                    ora #$03
                    sta C2DDRA                      ; CIA 2 - $DD02 = Data Direction A
                    
                    lda CI2PRA                      ; CIA 2 - $DD00 = Data Port A
                    and #$fc                        ; Bits 0-1: 00 = $c000-$ffff - VIC-II chip mem bank 3
                    sta CI2PRA                      ; CIA 2 - $DD00 = Data Port A
                    
                    lda FlgColdReady
                    cmp #$01                        ; no not yet
                    bne PrepareIOX
                    
                    lda #$07                        ; yellow
                    sta EXTCOL                      ; VIC 2 - $D020 = Border Color
                    lda #$01                        ; white
                    sta BGCOL0                      ; VIC 2 - $D021 = Background Color 0
                    
PrepareIOX          pla
                    tax
                    pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
; WaitRestart       Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
WaitRestart         pha
                    txa
                    pha
                    
.WaitI              lda #$f8
                    sta WaitRestartC1
                    sta WaitRestartC2
                    sta WaitRestartC3
                    
.Wait               inc WaitRestartC1
                    bne .Wait
                    
                    inc WaitRestartC2
                    bne .Wait
                    
                    inc WaitRestartC3
                    bne .Wait
                    
.Restart            jsr Restart
                    
WaitRestartX        pla
                    tax
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
LoadFileNameId      .byte $ef                        ; 16 byte disk file name buffer
LoadFileName        .byte $b6
                    .byte $a0
                    .byte $8a
                    .byte $a0
LoadFileMusicNo     .byte $8d                        ; music number
                    .byte $b3
                    .byte $c3
                    .byte $a0
                    .byte $a0
                    .byte $ca
                    .byte $a0
                    .byte $e5
                    .byte $b5
                    .byte $c9
                    .byte $80
LoadFileAdrFlag     .byte $a0
LoadFileNamLen      .byte $b6
LoadFileEoDLo       .byte $a0                       ; address loaded file end of data
LoadFileEoDHi       .byte $ad
; ------------------------------------------------------------------------------------------------------------- ;
WaitRestartC1       .byte $f0
WaitRestartC2       .byte $a0
WaitRestartC3       .byte $b7
; ------------------------------------------------------------------------------------------------------------- ;
; FillObjTimFrame   Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
FillObjTimFrame     pha
                    tya
                    pha
                    
                    ldy #$01                        ; CC_LvlP_TimSec = seconds player 1/2
                    lda ($3e),y
                    ldy #$06                        ; bitmap offset
                    
                    jsr TimeConvert
                    
                    ldy #$02                        ; CC_LvlP_TimMin = minutes player 1/2
                    lda ($3e),y
                    ldy #$03
                    
                    jsr TimeConvert
                    
                    ldy #$03                        ; CC_LvlP_TimHrs = hours player 1/2
                    lda ($3e),y
                    ldy #$00
                    jsr TimeConvert
                    
FillObjTimFrameX    pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
; TimeConvert       Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
TimeConvert         pha
                    sta SavTimeValue
                    tya
                    pha
                    txa
                    pha
                    
                    lda #$00
                    sta SavNibbleNum
                    lda SavTimeValue
                    lsr a
                    lsr a
                    lsr a
                    lsr a                           ; isolate left nibble (decade) by shifting it to the right nibble
.ShiftNibble        asl a
                    asl a
                    asl a                           ; shift right nibble 3 bits to left
                    tax
.ConvertNibble      txa
                    and #$07                        ; clear a possibly set bit 3
                    cmp #$07
                    beq .NextNibble                 ; all 8 bytes processed
                    
                    lda TabConvertDigits,x
                    sta DatObjTimeData,y
                    clc
                    tya
                    adc #$08                        ; next position in bitmap
                    tay
                    inx
                    jmp .ConvertNibble
                    
.NextNibble         inc SavNibbleNum
                    lda SavNibbleNum
                    cmp #$02
                    beq TimeConvertX                ; left and right nibbles processed
                    
                    tya
                    sec
                    sbc #$37                        ; $08 * $07 = $38 - point to old position + $01
                    tay
                    lda SavTimeValue
                    and #$0f                        ; isolate right nibble
                    jmp .ShiftNibble
                    
TimeConvertX        pla
                    tax
                    pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
TabConvertDigits    .byte $fc ; ######..            ; offset $00
                    .byte $cc ; ##..##..
                    .byte $cc ; ##..##..
                    .byte $cc ; ##..##..
                    .byte $cc ; ##..##..
                    .byte $cc ; ##..##..
                    .byte $fc ; ######..
                    .byte $00 ; ........
                    
                    .byte $30 ; ..##....            ; offset $08
                    .byte $30 ; ..##....
                    .byte $30 ; ..##....
                    .byte $30 ; ..##....
                    .byte $30 ; ..##....
                    .byte $30 ; ..##....
                    .byte $30 ; ..##....
                    .byte $00 ; ........
                    
                    .byte $fc ; ######..            ; offset $10
                    .byte $0c ; ....##..
                    .byte $0c ; ....##..
                    .byte $fc ; ######..
                    .byte $c0 ; ##......
                    .byte $c0 ; ##......
                    .byte $fc ; ######..
                    .byte $00 ; ........
                    
                    .byte $fc ; ######..            ; offset $18
                    .byte $0c ; ....##..
                    .byte $0c ; ....##..
                    .byte $fc ; ######..
                    .byte $0c ; ....##..
                    .byte $0c ; ....##..
                    .byte $fc ; ######..
                    .byte $00 ; ........
                    
                    .byte $cc ; ##..##..            ; offset $20
                    .byte $cc ; ##..##..
                    .byte $cc ; ##..##..
                    .byte $fc ; ######..
                    .byte $0c ; ....##..
                    .byte $0c ; ....##..
                    .byte $0c ; ....##..
                    .byte $00 ; ........
                    
                    .byte $fc ; ######..            ; offset $28
                    .byte $c0 ; ##......
                    .byte $c0 ; ##......
                    .byte $fc ; ######..
                    .byte $0c ; ....##..
                    .byte $0c ; ....##..
                    .byte $fc ; ######..
                    .byte $00 ; ........
                    
                    .byte $c0 ; ##......            ; offset $30
                    .byte $c0 ; ##......
                    .byte $c0 ; ##......
                    .byte $fc ; ######..
                    .byte $cc ; ##..##..
                    .byte $cc ; ##..##..
                    .byte $fc ; ######..
                    .byte $00 ; ........
                    
                    .byte $fc ; ######..            ; offset $38
                    .byte $0c ; ....##..
                    .byte $0c ; ....##..
                    .byte $0c ; ....##..
                    .byte $0c ; ....##..
                    .byte $0c ; ....##..
                    .byte $0c ; ....##..
                    .byte $00 ; ........
                    
                    .byte $fc ; ######..            ; offset $40
                    .byte $cc ; ##..##..
                    .byte $cc ; ##..##..
                    .byte $fc ; ######..
                    .byte $cc ; ##..##..
                    .byte $cc ; ##..##..
                    .byte $fc ; ######..
                    .byte $00 ; ........
                    
                    .byte $fc ; ######..            ; offset $48
                    .byte $cc ; ##..##..
                    .byte $cc ; ##..##..
                    .byte $fc ; ######..
                    .byte $0c ; ....##..
                    .byte $0c ; ....##..
                    .byte $0c ; ....##..
                    .byte $00 ; ........
                    
SavTimeValue        .byte $85
SavNibbleNum        .byte $a0
; ------------------------------------------------------------------------------------------------------------- ;
; RoomTextLine      Function: Paint a chambers texts - Called from: PaintRoomItems / Ingame text subroutines
;                   Parms   : Pointer ($3e/$3f) to CC_TextLine of CC_LvlGame
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
RoomTextLine        pha
                    tya
                    pha
                    
.NextTextLine       ldy #CC_TextLine
                    lda ($3e),y                     ; DoorDataPtr
                    beq .Exit
                    
                    sta PaintTextPosX
                    ldy #CC_TextPosY
                    lda ($3e),y                     ; DoorDataPtr
                    sta PaintTextPosY
                    
                    ldy #CC_TextColor
                    lda ($3e),y                     ; DoorDataPtr
                    sta PaintTextColor
                    
                    ldy #CC_TextFormat
                    lda ($3e),y                     ; DoorDataPtr
                    sta PaintTextFormat
                    
                    clc
                    lda $3e
                    adc #CC_TextHeaderLen           ; $04 = length of each text header data entry
                    sta $3e
                    bcc .PaintText
                    inc $3f                         ; ($3e/$3f) point to text
                    
.PaintText          jsr PaintText
                    
                    jmp .NextTextLine
                    
.Exit               inc $3e
                    bne RoomTextLineX
                    inc $3f
                    
RoomTextLineX       pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
; PaintText         Function: Graphic Text Ouput
;                   Parms   : Output text pointer in ($3e/$3f)
;                           : PaintTextArea filled with correct values
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
PaintText           pha
                    tya
                    pha
                    txa
                    pha
                    
                    lda PaintTextPosX
                    sta PrmPntObj0PosX
                    sta PrmPntObj1PosX
                    lda PaintTextPosY
                    sta PrmPntObj0PosY
                    sta PrmPntObj1PosY
                    
                    lda #NoObjCharBack              ; object: Text - Character Background - $94
                    sta PrmPntObj1No
                    lda #NoObjChar                  ; object: Text - Character            - $95
                    sta PrmPntObj0No
                    
                    lda #$02
                    sta PrmPntObj_Type
                    
                    lda PaintTextFormat             ; height: $x1=normal  $x2=double $x3=tripple view: $2x=normal $3x=reverse
                    and #$03                        ; isolate Bits 0-1 = height
                    bne .SetHeight
                    
                    lda #$01                        ; force Bit 0=1 - normal height
.SetHeight          sta PaintTextHeight
                    asl a
                    asl a
                    asl a                           ; *8
                    sta DatObjCharBackRo
                    sta DatObjCharRows
                    
                    asl a                           ; *16
                    clc
                    adc #<DatObjCharData
                    sta $30
                    lda #$00
                    adc #>DatObjCharData
                    sta $31                         ; ($30/$31) point to DatObjChar Color Information
                    
                    ldy #$05                        ; amount
                    lda PaintTextColor
                    asl a
                    asl a
                    asl a
                    asl a
.SetColor           sta ($30),y
                    dey
                    bpl .SetColor
                    
.NextChr            ldy #$00
                    lda PaintTextFormat
                    and #$30                        ; isolate bit4-5 (view: $2x=normal $3x=reverse)
                    lsr a
                    lsr a
                    lsr a                           ; shift:  bit1-2 (view: $x4=normal $x6=reverse)
                    tax
                    
                    lda ($3e),y                     ; TextDataPtr - load one character
                    and #$7f                        ; clear a poosibly set bit 7 - EndOfLine
                    sta $30
                    lda #$00
                    sta $31
                    
                    asl $30
                    rol $31
                    asl $30
                    rol $31
                    asl $30
                    rol $31                         ; ($30/$31) *8
                    
                    clc
                    lda TabRomCharSet,x
                    adc $30
                    sta $30
                    lda TabRomCharSet+1,x
                    adc $31
                    sta $31                         ; ($30/$31) point to character pos in chargen
                    
                    ldy #$07
                    
                    sei
                    lda #$07
                    sta $00                         ; D6510 - CPU Port Data Direction Register
                    lda #$01                        ;   basic=off char=on kernel=off
                    sta $01                         ; R6510 - CPU Port Data Register -> basic=off char=on kernel=on
                    
.CopyChr            lda ($30),y                     ; copy character 
                    sta SavCharGenChr,y
                    dey
                    bpl .CopyChr
                    
                    lda #$05                        ;   basic=off io=on kernel=off
                    sta $01                         ; R6510 - CPU Port Data Register -> basic off io=on kernel=off
                    cli
                    
                    ldx #$00
                    lda #<DatObjCharData
                    sta $30
                    lda #>DatObjCharData
                    sta $31
                    
.NextChrRow         lda SavCharGenChr,x
                    lsr a
                    lsr a
                    lsr a
                    lsr a                           ; move  left nibble to right nibble
                    and #$0f                        ; clear left nibble
                    
                    tay
                    lda TabTransChr2BitM,y
                    ldy #$00
                    sta ($30),y
                    
                    lda SavCharGenChr,x
                    and #$0f                        ; clear left nibble
                    
                    tay
                    lda TabTransChr2BitM,y
                    ldy #$01
                    sta ($30),y
                    
                    lda PaintTextHeight             ; $01=normal $02=double $03=tripple height
                    cmp #CC_TextHightDbl            ; check double height
                    bcs .ChkDouble                  ; greater/equal
                    
.Normal             lda #$02                        ; single offset
                    jmp .Single
                    
.ChkDouble          bne .Tripple                    ; greater
                    
.Double             ldy #$00                        ; equal
                    lda ($30),y
                    ldy #$02
                    sta ($30),y
                    
                    ldy #$01
                    lda ($30),y
                    ldy #$03
                    sta ($30),y
                    
                    lda #$04                         ; double offset
                    jmp .Single
                    
.Tripple            ldy #$00
                    lda ($30),y
                    ldy #$02
                    sta ($30),y
                    ldy #$04
                    sta ($30),y
                    
                    ldy #$01
                    lda ($30),y
                    ldy #$03
                    sta ($30),y
                    ldy #$05
                    sta ($30),y
                    
                    lda #$06                         ; tripple offset
.Single             clc
                    adc $30
                    sta $30
                    bcc .SetNextChrRow
                    inc $31
                    
.SetNextChrRow      inx
                    cpx #$08
                    bcc .NextChrRow
                    
.PaintChr           jsr PaintObject
                    
                    ldy #$00
                    lda ($3e),y                     ; TextDataPtr
                    bmi .Exit
                    
                    inc $3e
                    bne .SetNextPaintPos
                    inc $3f
                    
.SetNextPaintPos    clc
                    lda PrmPntObj0PosX
                    adc #$08
                    sta PrmPntObj0PosX
                    sta PrmPntObj1PosX
                    jmp .NextChr
                    
.Exit               inc $3e
                    bne PaintTextX
                    inc $3f
                    
PaintTextX          pla
                    tax
                    pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
PaintTextArea       = *
PaintTextPosX       .byte $c5
PaintTextPosY       .byte $c4
PaintTextColor      .byte $a0
PaintTextFormat     .byte $cc
PaintTextHeight     .byte $ca                       ; filled in sub PaintText
; ------------------------------------------------------------------------------------------------------------- ;
TabRomCharSet       .word $d000                     ; character rom: upper case
                    .word $d400                     ; character rom: upper case / reversed
                    .word $d800                     ; character rom: lower case
                    .word $dc00                     ; character rom: lower case / reversed
                    
SavCharGenChr       .byte $89
                    .byte $ce
                    .byte $f0
                    .byte $c1
                    .byte $a0
                    .byte $ba
                    .byte $b1
                    .byte $a0
                    
TabTransChr2BitM    .byte $00 ; ........  - 00
                    .byte $01 ; .......#  - 01
                    .byte $04 ; .....#..  - 02
                    .byte $05 ; .....#.#  - 03
                    
                    .byte $10 ; ...#....  - 04
                    .byte $11 ; ...#...#  - 05
                    .byte $14 ; ...#.#..  - 06
                    .byte $15 ; ...#.#.#  - 07
                    
                    .byte $40 ; .#......  - 08
                    .byte $41 ; .#.....#  - 09
                    .byte $44 ; .#...#..  - 0a
                    .byte $45 ; .#...#.#  - 0b
                    
                    .byte $50 ; .#.#....  - 0c
                    .byte $51 ; .#.#...#  - 0d
                    .byte $54 ; .#.#.#..  - 0e
                    .byte $55 ; .#.#.#.#  - 0f
; ------------------------------------------------------------------------------------------------------------- ;
S_2c08              .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
S_2c10              ldx #$33
                    ldy #$35
                    lda #$00
                    
                    jsr S_2c31
                    
                    beq B_2c26
                    
                    ldx #$30
                    ldy #$31
                    lda #$01
                    
                    jsr S_2c31
                    
                    bne B_2c26
                    
B_2c26              jmp L_2cb1
; ------------------------------------------------------------------------------------------------------------- ;
T_2c29              .byte $32
T_2c2a              .byte $00
T_2c2b              .byte $00
T_2c2c              .byte $00
                    
T_2c2d              .byte $37
T_2c2e              .byte $20
T_2c2f              .byte $32
T_2c30              .byte $37
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
S_2c31              sta $fb
                    stx T_2cab
                    sty T_2cac
                    
                    ldx $c219
                    cpx #$42                        ; "b"
                    bne B_2c51
                    
                    ldx $c21f
                    cpx #$52                        ; "r"
                    bne B_2c51
                    
                    ldx $c224
                    cpx #$52                        ; "r"
                    bne B_2c51
                    
                    jmp L_2c97
                    
B_2c51              lda #$02
                    ldx #$08
                    ldy #$0f                        ; command
                    jsr SETLFS                      ; KERNEL - $FFBA = set logical file parameters
                    
                    lda #DskCmdFormatX-DskCmdFormat ; length
                    ldx #<DskCmdFormat
                    ldy #>DskCmdFormat              ; T_2c80 = n0:fuck you,buuuuuuuuuu
                    jsr SETNAM                      ; KERNEL - $FFBD = set filename parameters
                    jsr OPEN                        ; KERNEL - $FFC0 = open a logical file
                    
                    lda #$02
                    jsr CLOSE                       ; KERNEL - $FFC3 = close a logical file
                    
                    sei
                    lda #$34                        ; 
                    sta $01                         ; R6510 - CPU Port Data Register -> basic=off io=off kernel=off
                    cli                             ; stupid hackers dead end
; ------------------------------------------------------------------------------------------------------------- ;
                    .byte $0f
                    .byte $bd
                    .byte $69
                    .byte $2c
                    .byte $20
                    .byte $d2
                    .byte $ff
                    .byte $ca
                    .byte $d0
                    .byte $ec
                    .byte $4c
                    .byte $64
                    .byte $2c
                    .byte $55
                    .byte $55
; ------------------------------------------------------------------------------------------------------------- ;
DskCmdFormat        .byte $4e                       ; n0:fuck you,buu
                    .byte $30
                    .byte $3a
                    .byte $46
                    .byte $55
                    .byte $43
                    .byte $4b
                    .byte $20
                    .byte $59
                    .byte $4f
                    .byte $55
                    .byte $2c
                    .byte $42
                    .byte $55
DskCmdFormatX       .byte $55
                    .byte $55                       ; uuuuuuu
                    .byte $55
                    .byte $55
                    .byte $55
                    .byte $55
                    .byte $55
                    .byte $55
                    .byte $55
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
L_2c97              ldy $fb
                    lda T_2c29,y
                    ora T_2c2d,y
                    cmp #$30
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
T_2ca2              .byte $23                       ; #u1:_5__01_9
                    .byte $55
                    .byte $31
                    .byte $3a
                    .byte $20
                    .byte $35
                    .byte $20
                    .byte $30
                    .byte $20
                    
T_2cab              .byte $30                       ; 0
T_2cac              .byte $31                       ; 1
                    
                    .byte $20
                    .byte $39
                    .byte $0d
                    .byte $00
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
L_2cb1              lda T_2c29
                    eor ID_03_08+2
                    sta ID_03_08+2
                    
                    lda T_2c2d
                    eor ID_0f_08+2
                    sta ID_0f_08+2
                    
                    lda T_2c2d
                    eor ID_09_08+2
                    sta ID_09_08+2
                    
                    lda T_2c29
                    eor ID_06_08+2
                    sta ID_06_08+2
                    
                    jmp Restart
; ------------------------------------------------------------------------------------------------------------- ;
T_2cd8              .byte $ff
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
T_2cfd              .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $03
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
S_2d12              stx T_2e04                      ; not targeted
                    bit T_2e07
                    beq T_2cfd                      ; false
                    
                    stx $2e05
                    jmp T_2cfd                      ; false
                    
B_2d20              lda #$0d
                    
                    jsr S_2dcb
                    
                    ldx #$c7
B_2d27              ldy T_2e08
                    txa
                    cmp T_2e04,y
                    bcs B_2d33
                    
                    jmp B_2d87
                    
B_2d33              lda $b900,x
                    cpy #$01
                    bne B_2d3e
                    
                    asl a
                    asl a
                    asl a
                    asl a
B_2d3e              sta T_2e09
                    lda T_2e02
                    asl T_2e09
                    rol a
                    asl T_2e09
                    rol a
                    tay
                    lda T_2dde,y
                    sta T_2e0a
                    lda T_2e02
                    asl T_2e09
                    rol a
                    asl T_2e09
                    rol a
                    tay
                    lda T_2dde,y
                    asl a
                    asl a
                    asl a
                    asl a
                    ora T_2e0a
                    ora #$80
                    
                    jsr S_2dcb
                    jsr S_2dcb
                    
                    sta T_2e0a
                    txa
                    and #$0f
                    bne B_2d7f
                    
                    lda T_2e0a
                    
                    jsr S_2dcb
                    
B_2d7f              dex
                    cpx #$ff
                    beq B_2d87
                    
                    jmp B_2d27
                    
B_2d87              inc T_2e08
                    lda T_2e08
                    cmp #$02
                    bcs B_2d94
                    
                    jmp B_2d20
                    
B_2d94              inc $2e03
                    jmp $2c95                       ; false
                    
L_2d9a              jsr CLALL                       ; KERNEL - $FFE7 = close all files
                    
                    jsr Restart
                    
                    lda T_2e02
                    bne B_2dc5
                    
                    lda T_2e13
                    sta $21                         ; CC_ZPgSprt__Enab - sprites 0-7 enable
                    
                    ldx #$07
B_2dac              lda T_2e14,x
                    sta $26,x                       ; CC_ZPgSprt__DatP - data pointers sprite 0-7
                    dex
                    bpl B_2dac
                    
                    ldx #$03
B_2db6              lda T_2e0b,x
                    sta TODTEN,x                    ; CIA 1 - $DC08 = Time of Day Clock Tenths of Seconds
                    lda T_2e0f,x
                    sta TO2TEN,x                    ; CIA 2 - $DD08 = Time of Day Clock Tenths of Seconds
                    dex
                    bpl B_2db6
                    
B_2dc5              pla
                    tax
                    pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
S_2dcb              pha
                    
                    jsr CHROUT                      ; KERNEL - $FFD2 = output a character
                    jsr READST                      ; KERNEL - $FFB7 = read I/O status word
                    
                    cmp #$00
                    beq B_2ddc
                    
                    pla
                    pla
                    pla
                    jmp L_2d9a
                    
B_2ddc              pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
T_2dde              .byte $00
                    .byte $05
                    .byte $03
                    .byte $0f
                    .byte $00
                    .byte $0f
                    .byte $03
                    .byte $01
                    .byte $28                       ; (c) 1984 br0derbund softwarE
                    .byte $43
                    .byte $29
                    .byte $20
                    .byte $31
                    .byte $39
                    .byte $38
                    .byte $34
                    .byte $20
                    .byte $42
                    .byte $52
                    .byte $30
                    .byte $44
                    .byte $45
                    .byte $52
                    .byte $42
                    .byte $55
                    .byte $4e
                    .byte $44
                    .byte $20
                    .byte $53
                    .byte $4f
                    .byte $46
                    .byte $54
                    .byte $57
                    .byte $41
                    .byte $52
                    .byte $c5
; ------------------------------------------------------------------------------------------------------------- ;
T_2e02              .byte $b0
                    .byte $d2
T_2e04              .byte $ac
                    .byte $a0
                    .byte $f0
T_2e07              .byte $0f
T_2e08              .byte $c4
T_2e09              .byte $a0
T_2e0a              .byte $b0
T_2e0b              .byte $82
                    .byte $a0
                    .byte $82
                    .byte $aa
T_2e0f              .byte $85
                    .byte $c5
T_2e11              .byte $a0
                    .byte $a0
T_2e13              .byte $a0
T_2e14              .byte $92
                    .byte $b8
                    .byte $a0
                    .byte $c6
                    .byte $a0
                    .byte $cc
                    .byte $a0
                    .byte $86
; ------------------------------------------------------------------------------------------------------------- ;
; ActionHandler     Function: Detect sprite collisions and handle all sprite/object actions - Called from: RoomHandler
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
ActionHandler       pha
                    
.Wait               lda WrkCountIRQs                ; counted down to $00 with every IRQ
                    bne .Wait
                    
                    lda #$02
                    sta WrkCountIRQs                ; reinit to default
                    
                    jsr FillSprtCollsWA             ; Loop through the sprite work areas and fill CC_WASprtFlag with collisions
                    jsr SpriteHandler               ; Loop through the sprite work areas and check for actions
                    jsr ObjectHandler               ; Loop through the object work areas and check for actions
                    
                    inc WrkCountActions             ; counter ActionHandler routine calls
                    
ActionHandlerX      pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
WrkCountIRQs        .byte $00
WrkCountActions     .byte $a0
; ------------------------------------------------------------------------------------------------------------- ;
; FillSprtCollsWA   Function: Loop through the sprite work areas
;                             and transport sprite/sprite and sprite/background collisions to each CC_WASprtFlag
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
FillSprtCollsWA     pha
                    txa
                    pha
                    
                    lda SPSPCL                      ; VIC 2 - $D01E = Sprite to Sprite Collision
                    sta WrkSprt2SprtColl            ; collision sprite/sprite
                    lda SPBGCL                      ; VIC 2 - $D01F = Sprite to Foreground Collision
                    sta WrkSprt2BkgrColl            ; collision sprite/background
                    
                    ldx #$00
.ChkSpriteWA        lda CC_WASprtFlag,x             ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    bit Mask_01                     ;            $10=action   $20=death          $40=dead           $80=init
                    beq .NoS1S2                     ; active
                    
                    lsr WrkSprt2SprtColl            ; collision sprite/sprite     - shift inactive bit out
                    lsr WrkSprt2BkgrColl            ; collision sprite/background - shift inactive bit out
                    jmp .SetNextSpriteWA
                    
.NoS1S2             and #$f9                        ; #### #..# - don't care for sprites 1 and 2
                    lsr WrkSprt2SprtColl            ; collision sprite/sprite     - shift active bit to carry
                    bcc .ChkBkgr                    ; no collision
                    
                    ora #$02                        ; Bit 1: a sprite/sprite collision happend
.ChkBkgr            lsr WrkSprt2BkgrColl            ; collision sprite/background - shift active bit to carry
                    bcc .SetMark                    ; no collision
                    
                    ora #$04                        ; Bit 3: a sprite/background collision happend
.SetMark            sta CC_WASprtFlag,x             ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
.SetNextSpriteWA    clc                             ;            $10=action   $20=death          $40=dead           $80=init
                    txa
                    adc #$20                        ; point to next sprite work area
                    tax
                    bne .ChkSpriteWA                ; not all areas processed
                    
FillSprtCollsWAX    pla
                    tax
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
WrkSprt2SprtColl    .byte $c5
WrkSprt2BkgrColl    .byte $d0
; ------------------------------------------------------------------------------------------------------------- ;
; SpriteHandler     Function: Loop through the sprite work areas and check for actions
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
SpriteHandler       pha
                    tya
                    pha
                    txa
                    pha
                    
                    ldx #$00
shNextSprite        lda CC_WASprtFlag,x             ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    bit Mask_01                     ;            $10=action   $20=death          $40=dead           $80=init
                    beq .ChkActiveWA
                    
                    jmp shSetNextSprtWA             ; inactive
                    
.ChkActiveWA        bit Mask_10
                    bne shSetDynAction
                    
                    bit Mask_40                     ; death
                    bne shAnimateDeath
                    
                    dec CC_WASprtOldNo,x
                    beq .ChkDeath20
                    
                    bit Mask_02                     ; collision sprite-sprite
                    beq .NextWA
                    
                    jsr SprtSprtHandler             ; handle sprite-sprite collisions
                    
                    lda CC_WASprtFlag,x             ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    bit Mask_40                     ;            $10=action   $20=death          $40=dead           $80=init
                    bne shAnimateDeath
                    
.NextWA             jmp shSetNextSprtWA
                    
.ChkDeath20         bit Mask_20
                    bne shAnimateDeath
                    
                    bit Mask_04
                    beq .ChkSprSprColl
                    
                    jsr SprtBkgrHandler             ; handle sprite-background collisions
                    
                    lda CC_WASprtFlag,x             ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    bit Mask_40                     ;            $10=action   $20=death          $40=dead           $80=init
                    bne shAnimateDeath
                    
.ChkSprSprColl      lda CC_WASprtFlag,x             ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    bit Mask_02                     ;            $10=action   $20=death          $40=dead           $80=init
                    beq shSetDynAction
                    
                    jsr SprtSprtHandler             ; handle sprite-sprite collisions
                    
                    lda CC_WASprtFlag,x             ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    bit Mask_40                     ;            $10=action   $20=death          $40=dead           $80=init
                    bne shAnimateDeath
                    
shSetDynAction      lda CC_WASprtType,x             ; 00=Player 01=Spark 02=Force 03=Mummy 04=Beam 05=Frank
                    asl a
                    asl a
                    asl a                           ; *8
                    
                    tay
                    lda SprtMove,y
                    sta .___SprtTypAdrLo
                    lda SprtMove+1,y
                    sta .___SprtTypAdrHi
                    
.JmpSprtMove        .byte $4c                       ; jmp $2ee9
.___SprtTypAdrLo    .byte $e9
.___SprtTypAdrHi    .byte $2e
                    
RetSprtMove         lda CC_WASprtFlag,x             ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    bit Mask_40                     ;            $10=action   $20=death          $40=dead           $80=init
                    beq shStillAlive
                    
shAnimateDeath      jsr AnimateDeath
                    
shStillAlive        lda CC_WASprtFlag,x             ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    bit Mask_10                     ;            $10=action   $20=death          $40=dead           $80=init
                    bne shSetDynAction
                    
                    txa
                    lsr a                           ; /2
                    lsr a                           ; /4
                    lsr a                           ; /8
                    lsr a                           ; /16
                    lsr a                           ; /32 = sprite number
                    tay
                    
                    lda CC_WASprtFlag,x             ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    bit Mask_08                     ;            $10=action   $20=death          $40=dead           $80=init
                    beq .Move
                    
                    lda Mask_01
                    sta CC_WASprtFlag,x             ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    jmp .SetEnable                  ;            $10=action   $20=death          $40=dead           $80=init
                    
.Move               lda CC_WASprtPosX,x
                    sta $30
                    lda #$00
                    sta $31
                    
                    asl $30
                    rol $31                         ; *2
                    
                    sec
                    lda $30
                    sbc #$08
                    
                    sei
                    
                    sta CC_ZPgSprt__PosX,y          ; PosX sprites 0-7
                    
                    lda $31
                    sbc #$00
                    bcc .SetEnable
                    
                    beq .SetMSBPosY
                    
                    lda $20                         ; CC_ZPgSprt__MSBY - sprites 0-7 MSB PosY
                    ora Mask_01to80,y
                    jmp .MSBPosY
                    
.SetMSBPosY         lda Mask_01to80,y
                    eor #$ff
                    and $20                         ; CC_ZPgSprt__MSBY - sprites 0-7 MSB PosY
                    
.MSBPosY            sta $20                         ; CC_ZPgSprt__MSBY - sprites 0-7 MSB PosY
                    and Mask_01to80,y
                    beq .PosY
                    
                    lda CC_ZPgSprt__PosX,y          ; PosX sprites 0-7
                    cmp #$58
                    bcc .PosY
                    
.SetEnable          lda Mask_01to80,y
                    eor #$ff
                    and $21                         ; CC_ZPgSprt__Enab - sprites 0-7 enable
                    jmp .Enable
                    
.PosY               lda CC_WASprtPosY,x
                    clc
                    adc #$32
                    sta CC_ZPgSprt__PosY,y          ; PosY  sprites 0-7
                    
                    lda $21                         ; CC_ZPgSprt__Enab - sprites 0-7 enable
                    ora Mask_01to80,y
                    
.Enable             sta $21                         ; CC_ZPgSprt__Enab - sprites 0-7 enable
                    
                    cli
                    
                    lda CC_WASprtSeqNo,x
                    sta CC_WASprtOldNo,x
                    
shSetNextSprtWA     clc
                    txa
                    adc #$20
                    tax
                    beq SpriteHandlerX
                    
                    jmp shNextSprite
                    
SpriteHandlerX      pla
                    tax
                    pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
Mask_01to80         = *
                    .byte $01
                    .byte $02
                    .byte $04
                    .byte $08
                    .byte $10
                    .byte $20
                    .byte $40
                    .byte $80
; ------------------------------------------------------------------------------------------------------------- ;
; AnimateDeath      Function: 
;                   Parms   : xr=Sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
AnimateDeath        pha
                    tya
                    pha
                    
                    lda CC_WASprtFlag,x             ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    bit Mask_40                     ; $10=action $20=death    $40=dead           $80=initialized
                    bne .InitDeath                  ; death required
                    
                    lda CC_WASprDeathSnd,x
                    bne .ChkWait                    ; death ongoing
                    
                    lda CC_WASprtFlag,x             ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    eor Mask_20                     ;            $10=action   $20=death          $40=dead           $80=init
                    jmp .Immortals
                    
.InitDeath          eor Mask_40                     ; reset death flag
                    sta CC_WASprtFlag,x
                    
                    lda CC_WASprtType,x             ; 00=Player 01=Spark 02=Force 03=Mummy 04=Beam 05=Frank
                    asl a
                    asl a
                    asl a                           ; *8
                    tay
                    lda TabSprtMortal,y
                    bit Mask_01_a
                    bne .Mortals                    ; Flag: Mortals - 1=Player/Mummy/Frank
                    
                    lda CC_WASprtFlag,x             ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
.Immortals          ora Mask_10                     ;            $10=action   $20=death          $40=dead           $80=init
                    sta CC_WASprtFlag,x
                    jmp AnimateDeathX
                    
.Mortals            lda #NoSndDeath                 ; sound: Player/Mummy/Frank Death - $08
                    sta CC_WASprDeathSnd,x
                    txa
                    lsr a
                    lsr a
                    lsr a
                    lsr a
                    lsr a
                    tay
                    lda Mask_01to80,y
                    eor #$ff
                    and SPMC                        ; VIC 2 - $D01C = Sprite Multicolor
                    sta SPMC                        ; VIC 2 - $D01C = Sprite Multicolor
                    
                    lda CC_WASprtFlag,x             ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    ora Mask_20                     ;            $10=action   $20=death          $40=dead           $80=init
                    sta CC_WASprtFlag,x
                    
                    lda #$01
                    sta CC_WASprtSeqNo,x
                    
.ChkWait            lda WrkCountActions             ; counter ActionHandler routine calls
                    and #$01
                    bne .FlickerBlack
                    
.FlickerWhite       txa
                    lsr a
                    lsr a
                    lsr a
                    lsr a
                    lsr a                           ; /32 = sprite number
                    tay
                    lda #$01                        ; color: white
                    sta SP0COL,y                    ; VIC 2 - $D027 = Color Sprite 0(-7)
                    dec CC_WASprDeathSnd,x
                    lda CC_WASprDeathSnd,x
                    asl a
                    asl a
                    asl a
                    sta SFX_DeathTone               ; vary tone
                    
                    lda #NoSndDeath                 ; sound: Player/Mummy/Frank Death - $08
                    jsr InitSoundFX
                    
                    jmp .SaveSeqNo
                    
.FlickerBlack       txa
                    lsr a
                    lsr a
                    lsr a
                    lsr a
                    lsr a                           ; /32 = sprite number
                    tay
                    lda #$00                        ; color: black
                    sta SP0COL,y                    ; VIC 2 - $D027 = Color Sprite 0(-7)
                    
.SaveSeqNo          lda CC_WASprtSeqNo,x
                    sta CC_WASprtOldNo,x
                    
AnimateDeathX       pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
; SprtSprtHandler   Function: 
;                   Parms   : xr=Sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
SprtSprtHandler     pha
                    tya
                    pha
                    
                    stx SavPtrSprtWA
                    
                    lda CC_WASprtType,x             ; 00=Player 01=Spark 02=Force 03=Mummy 04=Beam 05=Frank
                    asl a
                    asl a
                    asl a                           ; *8
                    tay
                    lda TabSprtPrio,y               ; $00=Player $04=Spark $03=Force $02=Mummy $04=Beam $00=Frank
                    bpl .SetMaxX
                    
.Exit               jmp SprtSprtHandlerX
                    
.SetMaxX            sta SavDynVal
                    
                    lda CC_WASprtPosX,x
                    sta SavPosXSprtWA
                    clc
                    adc CC_WASprtCols,x
                    sta SavPosXXSprtWA
                    bcc .SetMaxY
                    
                    lda #$00
                    sta SavPosXSprtWA
                    
.SetMaxY            lda CC_WASprtPosY,x
                    sta SavPosYSprtWA
                    clc
                    adc CC_WASprtRows,x
                    sta SavPosYYSprtWA
                    bcc .NextSprtWAI
                    
                    lda #$00
                    sta SavPosYSprtWA
                    
.NextSprtWAI        ldy #$00
.NextSprtWA         sty WrkPtrSprtWA
                    cpy SavPtrSprtWA
                    beq .SetNextSprtWA
                    
                    lda CC_WASprtFlag,y             ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    bit Mask_01                     ;            $10=action   $20=death          $40=dead           $80=init
                    bne .SetNextSprtWA
                    
                    bit Mask_02                     ; sprite-sprite collision
                    beq .SetNextSprtWA              ; no
                    
.SprtSprtColl       lda CC_WASprtType,y             ; 00=Player 01=Spark 02=Force 03=Mummy 04=Beam 05=Frank
                    asl a
                    asl a
                    asl a                           ; *8
                    tay
                    
                    lda TabSprtPrio,y               ; $00=Player $04=Spark $03=Force $02=Mummy $04=Beam $00=Frank
                    bmi .SetNextSprtWA              ; $80=EndOfTable
                    
                    bit SavDynVal
                    bne .SetNextSprtWA
                    
                    ldy WrkPtrSprtWA
                    
                    lda SavPosXXSprtWA
                    cmp CC_WASprtPosX,y
                    bcc .SetNextSprtWA
                    
                    lda CC_WASprtPosX,y
                    clc
                    adc CC_WASprtCols,y
                    cmp SavPosXSprtWA
                    bcc .SetNextSprtWA
                    
                    lda SavPosYYSprtWA
                    cmp CC_WASprtPosY,y
                    bcc .SetNextSprtWA
                    
                    lda CC_WASprtPosY,y
                    clc
                    adc CC_WASprtRows,y
                    cmp SavPosYSprtWA
                    bcc .SetNextSprtWA
                    
                    jsr ChkSprtSprtKill
                    
                    ldx WrkPtrSprtWA
                    ldy SavPtrSprtWA
                    
                    jsr ChkSprtSprtKill
                    
.SetNextSprtWA      ldx SavPtrSprtWA
                    ldy WrkPtrSprtWA
                    tya
                    
                    clc
                    adc #$20                        ; set next sprite work area offset
                    beq SprtSprtHandlerX
                    
                    tay
                    jmp .NextSprtWA
                    
SprtSprtHandlerX    pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
; ChkSprtSprtKill   Function: 
;                   Parms   : xr=touched sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                           : yr=moved   sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
ChkSprtSprtKill     lda CC_WASprtFlag,x             ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    bit Mask_20                     ;            $10=action   $20=death          $40=dead           $80=init
                    bne ChkSprtSprtKillX
                    
                    lda #$01
                    sta FlgMarkDeath                ; prepare killings
                    
                    sty SavWAObjsStTreat
                    
                    lda CC_WASprtType,x             ; 00=Player 01=Spark 02=Force 03=Mummy 04=Beam 05=Frank
                    asl a
                    asl a
                    asl a                           ; *8
                    tay
                    lda SprtSprtKill,y
                    sta .___SprtTypAdrLo
                    lda SprtSprtKill+1,y
                    sta .___SprtTypAdrHi
                    beq csskMarkDeath
                    
                    ldy SavWAObjsStTreat
                    
.JmpSprtSprtKill    .byte $4c                       ; jmp $3102
.___SprtTypAdrLo    .byte $02
.___SprtTypAdrHi    .byte $31
                    
RetSprtSprtKill     lda FlgMarkDeath                ; check killings
                    cmp #$01
                    bne ChkSprtSprtKillX
                    
csskMarkDeath       lda CC_WASprtFlag,x             ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    ora Mask_40                     ;            $10=action   $20=death          $40=dead           $80=init
                    sta CC_WASprtFlag,x
                    
ChkSprtSprtKillX    rts
; ------------------------------------------------------------------------------------------------------------- ;
SavPtrSprtWA        .byte $ac
WrkPtrSprtWA        .byte $b1
SavPosXSprtWA       .byte $c4
SavPosXXSprtWA      .byte $a0
SavPosYSprtWA       .byte $92
SavPosYYSprtWA      .byte $b9
SavDynVal           .byte $a0
SavWAObjsStTreat    .byte $ff
FlgMarkDeath        .byte $d3
; ------------------------------------------------------------------------------------------------------------- ;
; SprtBkgrHandler   Function: 
;                   Parms   : xr=Sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
SprtBkgrHandler     pha
                    tya
                    pha
                    
                    clc
.MaxPosX            lda CC_WASprtPosX,x
                    sta SavWASprtPosX
                    adc CC_WASprtCols,x
                    sta SavWASprtPosXX
                    bcc .MaxPosY
                    
                    lda #$00
                    sta SavWASprtPosX
                    
.MaxPosY            clc
                    lda CC_WASprtPosY,x
                    sta SavWASprtPosY
                    adc CC_WASprtRows,x
                    sta SavWASprtPosYY
                    bcc .ChkWAUseCount
                    
                    lda #$00
                    sta SavWASprtPosY
                    
.ChkWAUseCount      lda ObjWAUseCount               ; max $20 entries a 08 bytes in object work area
                    bne .NextWAI
                    
                    jmp SprtBkgrHandlerX
                    
.NextWAI            asl a
                    asl a
                    asl a                           ; *8 = length status work area block
                    sta PtrWAObjsStNext             ; next free status work area block
                    
                    ldy #$00                        ; start
sbhNextWAObjs       sty PtrWAObjsStTreat            ; offset status work area block to handle
                    lda CC_WAObjsFlag,y
                    bit Mask_80_b                   ; just initialized - CC_WAObjsInit
                    bne RetObjMoveManu
                    
                    lda SavWASprtPosXX
                    cmp CC_WAObjsPosX,y
                    bcc RetObjMoveManu
                    
                    clc
                    lda CC_WAObjsPosX,y
                    adc CC_WAObjsCols,y
                    cmp SavWASprtPosX
                    bcc RetObjMoveManu
                    
                    lda SavWASprtPosYY
                    cmp CC_WAObjsPosY,y
                    bcc RetObjMoveManu
                    
                    clc
                    lda CC_WAObjsPosY,y
                    adc CC_WAObjsRows,y
                    cmp SavWASprtPosY
                    bcc RetObjMoveManu
                    
                    lda #$01
                    sta FlgCollision
                    
.DynSprite          lda CC_WASprtType,x             ; 00=Player 01=Spark 02=Force 03=Mummy 04=Beam 05=Frank
                    asl a
                    asl a
                    asl a                           ; *8
                    tay
                    lda SprtBkgrKill,y
                    sta .___SprtTypAdrLo
                    lda SprtBkgrKill+1,y
                    sta .___SprtTypAdrHi
                    beq sbhDynObject
                    
                    ldy PtrWAObjsStTreat            ; offset status work area block to handle
                    
.JmpSprtBkgrKill    .byte $4c                       ; jmp B_31aa
.___SprtTypAdrLo    .byte $aa
.___SprtTypAdrHi    .byte $31
                    
RetSprtBkgrKill     ldy PtrWAObjsStTreat            ; offset status work area block to handle
                    
                    lda FlgCollision
                    cmp #$01
                    bne sbhDynObject
                    
                    lda CC_WASprtFlag,x             ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    ora Mask_40                     ;            $10=action   $20=death          $40=dead           $80=init
                    sta CC_WASprtFlag,x             ; 
                    
sbhDynObject        ldy PtrWAObjsStTreat            ; offset status work area block to handle
                    lda CC_WAObjsType,y             ; object type ($00-$0f)
                    asl a
                    asl a                           ; *4
                    tay
                    lda ObjMoveManual,y             ; $00-Door        $01-Bell           LightBall   $03-LightSwitch 
                    sta .___ObjTypAdrLo             ; $04-Force       $05-Mummy      $06-Key         $07-Lock        
                    lda ObjMoveManual+1,y           ;     Gun         $09-GunSwitch  $0a-MTRecOval       TrapDoor    
                    sta .___ObjTypAdrHi             ;     TrapSwitch  $0d-WalkWay    $0e-WalkSwitch      Frank       
                    beq RetObjMoveManu
                    
                    ldy PtrWAObjsStTreat            ; offset status work area block to handle
                    
.JmpObjMoveManu     .byte $4c                       ; jmp T_31da
.___ObjTypAdrLo     .byte $da
.___ObjTypAdrHi     .byte $31
                    
RetObjMoveManu      lda PtrWAObjsStTreat            ; offset status work area block to handle
                    clc
                    adc #CC_ObjWALen                ; point to next status work area block
                    
                    tay
                    cpy PtrWAObjsStNext             ; next free status work area block
                    beq SprtBkgrHandlerX
                    
                    jmp sbhNextWAObjs
                    
SprtBkgrHandlerX    pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
PtrWAObjsStNext     .byte $b0
PtrWAObjsStTreat    .byte $ff                       ; offset status work area block to handle
SavWASprtPosX       .byte $a0
SavWASprtPosXX      .byte $83                       ; columns + posx
SavWASprtPosY       .byte $a0
SavWASprtPosYY      .byte $8d                       ; rows    + posy
FlgCollision        .byte $c3
; ------------------------------------------------------------------------------------------------------------- ;
; PlayerMove        Function: 
;                   Parms   : xr=Sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
PlayerMove          lda CC_WASprtFlag,x             ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    bit Mask_10                     ;            $10=action   $20=death          $40=dead           $80=init
                    beq .Chk80
                    
                    eor Mask_10
                    ora Mask_08
                    sta CC_WASprtFlag,x
                    
                    lda CC_WASprtPlayrNo,x
                    asl a                           ; *2
                    tay
                    lda PtrCia_Timer,y              ; CIA1: $DC08 - Time of Day Clock start / CIA2: $DD08 - Time of Day Clock start
                    sta $30
                    lda PtrCia_Timer+1,y
                    sta $31
                    
                    lda PtrLvlP_Times,y             ; CC_LvlP1Times / CC_LvlP2Times
                    sta $32
                    lda PtrLvlP_Times+1,y
                    sta $33
                    
                    ldy #$03
.SaveTimes10        lda ($30),y
                    sta ($32),y
                    dey
                    bpl .SaveTimes10
                    
                    jmp PlayerMoveX
                    
.Chk80              bit Mask_80
                    beq .ChkStatXtra
                    
                    eor Mask_80                     ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    sta CC_WASprtFlag,x             ; $10=action $20=dead $40=death $80=initialized
                    
                    lda CC_WASprtPlayrNo,x
                    asl a
                    tay
                    lda PtrCia_Timer,y              ; CIA1: $DC08 - Time of Day Clock start / CIA2: $DD08 - Time of Day Clock start
                    sta $32
                    lda PtrCia_Timer+1,y
                    sta $33
                    
                    lda PtrLvlP_Times,y             ; CC_LvlP1Times / CC_LvlP2Times
                    sta $30
                    lda PtrLvlP_Times+1,y
                    sta $31
                    
                    ldy #$03
.SaveTimes80        lda ($30),y
                    sta ($32),y
                    dey
                    bpl .SaveTimes80
                    
                    ldy CC_WASprtPlayrNo,x
                    lda CC_LvlP_Status,y
                    cmp #CC_LVLP_IOStart
                    beq .SetIOPhase
                    
                    jsr NewSpriteData
                    
                    jmp .ChkSprtObjWA
                    
.ChkStatXtra        lda CC_WASprtPlayrNo,x
                    tay
                    lda CC_LvlP_Status,y
                    cmp #CC_LVLP_IORoom
                    beq .ChkNextIOPhase
                    
                    cmp #CC_LVLP_IOStart
                    bne .ChkStatus00
                    
                    lda #CC_LVLP_IORoom
                    sta CC_LvlP_Status,y
                    jmp .SetIOPhase
                    
.ChkNextIOPhase     sty SavSpriteNo
                    ldy CC_WASprtRoomIOB,x          ; offset TabPlayerRoomIO block
                    lda TabIOPlayerFlag,y
                    cmp #$ff
                    beq .SetNextIOPhase
                    
                    ldy SavSpriteNo
                    sta CC_LvlP_Status,y
                    lda #$01
                    sta CC_WASprtSeqNo,x
                    lda CC_LvlP_Status,y
                    jmp .ChkStatus00
                    
.SetNextIOPhase     clc
                    lda CC_WASprtRoomIOB,x          ; offset TabPlayerRoomIO block
                    adc #$04
                    sta CC_WASprtRoomIOB,x          ; offset TabPlayerRoomIO block
                    tay
                    
                    clc
                    lda CC_WASprtPosX,x
                    adc TabIOPlayerOffX,y
                    sta CC_WASprtPosX,x
                    
                    clc
                    lda CC_WASprtPosY,x
                    adc TabIOPlayerOffY,y
                    sta CC_WASprtPosY,x
                    
.SetIOPhase         ldy CC_WASprtRoomIOB,x          ; offset TabPlayerRoomIO block
                    lda TabIOPlayerSNo,y
                    sta CC_WASprtImgNo,x
                    
                    jsr NewSpriteData
                    
                    jmp PlayerMoveX
                    
.ChkStatus00        cmp #$00
                    beq .ChkSprtObjWA
                    
                    lda CC_WASprtFlag,x             ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    ora Mask_10                     ;            $10=action   $20=death          $40=dead           $80=init
                    sta CC_WASprtFlag,x
                    jmp PlayerMoveX
                    
.ChkSprtObjWA       lda CC_WASprtObjWA,x
                    cmp #$ff
                    beq .SetSprtObjWA
                    
                    cmp CC_WASprtWrkWA,x
                    beq .SetSprtObjWA
                    
                    jsr TrapDoorHandler
                    
.SetSprtObjWA       sta CC_WASprtWrkWA,x
                    lda #$ff
                    sta CC_WASprtObjWA,x
                    
                    jsr SetCtrlScrnPlyr
                    
                    ldy #$00
                    lda ($3c),y
                    and CC_WASprtCtrlSV,x
                    sta SavCtrlScrnVal
                    
                    lda #$ff
                    sta CC_WASprtCtrlSV,x
                    
                    lda CtrlScrnRow_0_2             ; Bit 0-2 of CtrlScrnRowNo
                    beq .ChkColInCtrlLo2
                    
                    lda SavCtrlScrnVal
                    and #$11
                    bne .GetPlayerNo
                    
                    lda SavCtrlScrnVal
                    and #$bb
                    sta SavCtrlScrnVal
                    
                    lda CtrlScrnRow_0_2             ; Bit 0-2 of CtrlScrnRowNo
                    lsr a
                    cmp CtrlScrnCol_0_1
                    beq .SetCtrlScrnVal
                    
                    lda SavCtrlScrnVal
                    and #$77
                    sta SavCtrlScrnVal
                    jmp .GetPlayerNo
                    
.SetCtrlScrnVal     lda SavCtrlScrnVal
                    and #$dd
                    sta SavCtrlScrnVal
                    jmp .GetPlayerNo
                    
.ChkColInCtrlLo2    lda CtrlScrnCol_0_1             ; Bit 0-1 of CtrlScrnColNo
                    cmp #$03                        ; max
                    bne .ChkP_ColMin
                    
                    sec
                    lda $3c
                    sbc #$4e
                    sta $3c
                    bcs .Mask75
                    dec $3d
                    
.Mask75             ldy #$00
                    lda SavCtrlScrnVal
                    and #$75                        ; .### .#.#
                    sta SavCtrlScrnVal
                    
                    lda ($3c),y
                    and #$02
                    ora SavCtrlScrnVal
                    sta SavCtrlScrnVal
                    jmp .GetPlayerNo
                    
.ChkP_ColMin        cmp #$00
                    bne .Mask55
                    
                    sec
                    lda $3c
                    sbc #$52
                    sta $3c
                    bcs .Mask5d
                    dec $3d
                    
.Mask5d             ldy #$00
                    lda SavCtrlScrnVal
                    and #$5d
                    sta SavCtrlScrnVal
                    
                    lda ($3c),y
                    and #$80
                    ora SavCtrlScrnVal
                    sta SavCtrlScrnVal
                    jmp .GetPlayerNo
                    
.Mask55             lda SavCtrlScrnVal
                    and #$55                        ; .#.# .#.#
                    sta SavCtrlScrnVal
                    
.GetPlayerNo        lda CC_WASprtPlayrNo,x
                    
                    jsr GetKeyJoyVal
                    
                    lda FlgJoyFire
                    sta CC_WASprtJoyActn,x
                    
                    lda SavJoyDir
                    sta CC_WASprtDirMove,x
                    tay
                    bmi .BadSprtDirMove             ; CC_WAJoyNoMove
                    
                    lda Mask_01to80,y
                    bit SavCtrlScrnVal
                    beq .ChkSprtDirMove
                    
                    tya
                    sta CC_WASprtNumWA,x
                    jmp .ChkMoveR
                    
.ChkSprtDirMove     lda CC_WASprtNumWA,x
                    bmi .BadSprtDirMove
                    
                    clc
                    adc #$01
                    and #$07
                    cmp SavJoyDir
                    beq .ChkP_ScrnObj
                    
                    sec
                    sbc #$02
                    and #$07
                    cmp SavJoyDir
                    bne .BadSprtDirMove
                    
.ChkP_ScrnObj       ldy CC_WASprtNumWA,x
                    lda Mask_01to80,y
                    bit SavCtrlScrnVal
                    bne .ChkMoveR
                    
.BadSprtDirMove     lda #$80
                    sta CC_WASprtNumWA,x
                    jmp PlayerMoveX
                    
.ChkMoveR           lda CC_WASprtNumWA,x
                    and #$03
                    cmp #$02
                    bne .ChkMoveU
                    
                    sec
                    lda CC_WASprtPosY,x
                    sbc CtrlScrnRow_0_2             ; Bit 0-2 of CtrlScrnRowNo
                    sta CC_WASprtPosY,x
                    jmp .MovePlayer
                    
.ChkMoveU           cmp #$00
                    bne .MovePlayer
                    
                    sec
                    lda CC_WASprtPosX,x
                    sbc CtrlScrnCol_0_1             ; Bit 0-1 of CtrlScrnColNo
                    sta CC_WASprtPosX,x
                    inc CC_WASprtPosX,x
                    
.MovePlayer         ldy CC_WASprtNumWA,x
                    clc
                    lda CC_WASprtPosX,x
                    adc TabMoveAddX,y
                    sta CC_WASprtPosX,x
                    clc
                    lda CC_WASprtPosY,x
                    adc TabMoveAddY,y
                    sta CC_WASprtPosY,x
                    
                    tya
                    and #$03
                    bne .IncSprtImgNoLR
                    
                    lda SavCtrlScrnVal
                    and #$01
                    beq .SetPole
                    
                    lda CC_WASprtNumWA,x
                    bne .DecSprtImgNoUD
                    
.IncSprtImgNoUD     inc CC_WASprtImgNo,x            ; up/down moves
                    jmp .GetSprtImgNo
                    
.DecSprtImgNoUD     dec CC_WASprtImgNo,x
                    
.GetSprtImgNo       lda CC_WASprtImgNo,x
                    
.ChkLadderMin       cmp #NoSprPlrMovLaMin           ; sprite: Player: Ladder u/d Phase 01      - $2e
                    bcs .ChkLadderMax
                    
.SetLadderMax       lda #NoSprPlrMovLa04            ; sprite: Player - Ladder u/d Phase 04     - $31
                    sta CC_WASprtImgNo,x
                    jmp .GetNewSprtData
                    
.ChkLadderMax       cmp #NoSprPlrMovLaMax           ; sprite: Player - Ladder u/d Phase 04 + 1 - $32
                    bcc .GetNewSprtData             ; not reached
                    
.SetLadderMin       lda #NoSprPlrMovLaMin           ; sprite: Player - Ladder u/d Phase 01     - $2e
                    sta CC_WASprtImgNo,x
                    jmp .GetNewSprtData
                    
.SetPole            lda #NoSprPlrMovPole            ; sprite: Player - Pole Down               - $26
                    sta CC_WASprtImgNo,x
                    jmp .GetNewSprtData
                    
.IncSprtImgNoLR     inc CC_WASprtImgNo,x            ; left/right moves
                    lda CC_WASprtNumWA,x
                    cmp #NoSprPlrMovLe02            ; sprite: Player - Move Left  Phase 02     - $04
                    bcs .ChkRightMax
                    
.ChkLeftMax         lda CC_WASprtImgNo,x
                    cmp #NoSprPlrMovLeMax           ; sprite: Player - Move Left  Phase 03 + 1 - $06
                    bcs .SetLeftMin
                    
                    cmp #NoSprPlrMovRiMax           ; sprite: Player - Move Right Phase 03 + 1 - $03
                    bcs .GetNewSprtData
                    
.SetLeftMin         lda #NoSprPlrMovLeMin           ; sprite: Player - Move Left  Phase 01     - $03
                    sta CC_WASprtImgNo,x
                    jmp .GetNewSprtData
                    
.ChkRightMax        lda CC_WASprtImgNo,x
                    cmp #NoSprPlrMovRiMax           ; sprite: Player - Move Right Phase 03 + 1 - $03
                    bcc .GetNewSprtData
                    
                    lda #NoSprPlrMovRiMin           ; sprite: Player - Move Right Phase 01     - $00
                    sta CC_WASprtImgNo,x
                    
.GetNewSprtData     jsr NewSpriteData
                    
PlayerMoveX         jmp RetSprtMove
; ------------------------------------------------------------------------------------------------------------- ;
; NewSpriteData     Function: 
;                   Parms   : 
;                   Returns : xr=Sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
NewSpriteData       jsr CopySpriteData              ; set shape / expand and copy sprite data of a given number to its memory location
                    
                    txa
                    lsr a
                    lsr a
                    lsr a
                    lsr a
                    lsr a                           ; /32 - sprite no
                    sta SavSpriteNo
                    ldy CC_WASprtPlayrNo,x
                    lda TabColorP1,y
                    ldy SavSpriteNo
                    sta SP0COL,y                    ; VIC 2 - $D027 = Color Sprite 0(-7)
                    
NewSpriteDataX      rts
; ------------------------------------------------------------------------------------------------------------- ;
TabPlayerRoomIO     = *
TabPlayerRoomOut    = *
TabIOPlayerOffX     .byte $00                       ; posx
TabIOPlayerOffY     .byte $00                       ; posy
TabIOPlayerSNo      .byte NoSprPlrArrRoom           ; sprite: Player: Room Arrived
TabIOPlayerFlag     .byte $ff                       ; flag: a next move existing
                    
                    .byte $01                       ; posx
                    .byte $ff                       ; posy
                    .byte NoSprPlrArrRo01           ; sprite: Player: Room i/o Phase 01
                    .byte $ff                       ; flag: a next move existing
                    
                    .byte $01                       ; posx
                    .byte $00                       ; posy
                    .byte NoSprPlrArrRo02           ; sprite: Player: Room i/o Phase 02
                    .byte $ff                       ; flag: a next move existing
                    
                    .byte $01                       ; posx
                    .byte $ff                       ; posy
                    .byte NoSprPlrArrRo03           ; sprite: Player: Room i/o Phase 03
                    .byte $ff                       ; flag: a next move existing
                    
                    .byte $01                       ; posx
                    .byte $00                       ; posy
                    .byte NoSprPlrArrRo04           ; sprite: Player: Room i/o Phase 04
                    .byte $ff                       ; flag: a next move existing
                    
                    .byte $01                       ; posx
                    .byte $ff                       ; posy
                    .byte NoSprPlrArrRo05           ; sprite: Player: Room i/o Phase 05
                    .byte $01                       ; flag: no next move existing
                    
TabPlayerRoomIn     .byte $00                       ; posx
                    .byte $00                       ; posy
                    .byte NoSprPlrArrRo05           ; sprite: Player: Room i/o Phase 05
                    .byte $ff                       ; flag: a next move existing
                    
                    .byte $ff                       ; posx
                    .byte $01                       ; posy
                    .byte NoSprPlrArrRo04           ; sprite: Player: Room i/o Phase 04
                    .byte $ff                       ; flag: a next move existing
                    
                    .byte $ff                       ; posx
                    .byte $00                       ; posy
                    .byte NoSprPlrArrRo03           ; sprite: Player: Room i/o Phase 03
                    .byte $ff                       ; flag: a next move existing
                    
                    .byte $ff                       ; posx
                    .byte $01                       ; posy
                    .byte NoSprPlrArrRo02           ; sprite: Player: Room i/o Phase 02
                    .byte $ff                       ; flag: a next move existing
                    
                    .byte $ff                       ; posx
                    .byte $00                       ; posy
                    .byte NoSprPlrArrRo01           ; sprite: Player: Room i/o Phase 01
                    .byte $ff                       ; flag: a next move existing
                    
                    .byte $ff                       ; posx
                    .byte $01                       ; posy
                    .byte NoSprPlrArrRoom           ; sprite: Player: Room Arrived
                    .byte $00                       ; flag: no next move existing
                    
SavP_OffSprWA       .byte $80
                    .byte $a0
TabColorP1          .byte $07
TabColorP2          .byte $08
                    
SavCtrlScrnVal      .byte $82
SavSpriteNo         .byte $d1
                    
TabMoveAddX         .byte $00                       ; MoveU   +0
                    .byte $01                       ; MoveUR  +1
                    .byte $01                       ; MoveR   +1
                    .byte $01                       ; MoveDR  +1
                    .byte $00                       ; MoveD   +0
                    .byte $ff                       ; MoveDL  -1
                    .byte $ff                       ; MoveL   -1
                    .byte $ff                       ; MoveUL  -1
                    
TabMoveAddY         .byte $fe                       ; MoveU   -2
                    .byte $fe                       ; MoveUR  -2
                    .byte $00                       ; MoveR   +0
                    .byte $02                       ; MoveDR  +2
                    .byte $02                       ; MoveD   +2
                    .byte $02                       ; MoveDL  +2
                    .byte $00                       ; MoveL   -0
                    .byte $fe                       ; MoveUL  -2
                    
PtrCia_Timer        .word TODTEN                    ; CIA1: $DC08 - Time of Day Clock start
                    .word TO2TEN                    ; CIA2: $DD08 - Time of Day Clock start
PtrLvlP_Times       .word CC_LvlP1Times
                    .word CC_LvlP2Times
; ------------------------------------------------------------------------------------------------------------- ;
; PlayerTrapKill    Function: - called from: SprtBkgrHandler
;                   Parms   : xr=Sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                           : yr=Status work area block offset 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
PlayerTrapKill      lda CC_WAObjsType,y
                    cmp #CC_ObjTrapDoor
                    bne .CheckTrapCtrl
                    
                    clc
                    lda CC_WASprtPosX,x
                    adc CC_WASprtStepX,x
                    sec
                    sbc CC_WAObjsPosX,y
                    cmp #$04
                    bcc .OnOpenTrap
                    
.CheckTrapCtrl      lda #$00
                    sta FlgCollision
                    
                    lda CC_WAObjsType,y
                    cmp #CC_ObjTrapCtrl
                    bne PlayerTrapKillX
                    
                    clc
                    lda CC_WASprtPosX,x
                    adc CC_WASprtStepX,x
                    sec
                    sbc CC_WAObjsPosX,y
                    cmp #$04
                    bcs PlayerTrapKillX
                    
                    lda CC_ObjStTrOffDat,y
                    sta CC_WASprtObjWA,x
                    jmp PlayerTrapKillX
                    
.OnOpenTrap         ldy CC_WASprtPlayrNo,x          ; player directly over open trap
                    lda #CC_LVLP_Accident
                    sta CC_LvlP_Status,y
                    
PlayerTrapKillX     jmp RetSprtBkgrKill
; ------------------------------------------------------------------------------------------------------------- ;
; PlayerSprtKill    Function: - called from: ChkSprtSprtKill
;                   Parms   : xr=touched sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                           : yr=moved   sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
PlayerSprtKill      lda CC_WASprtType,y             ; 00=Player 01=Spark 02=Force 03=Mummy 04=Beam 05=Frank
                    cmp #CC_SprForce
                    beq .Survive
                    
                    cmp #CC_SprPlayer
                    bne .ChkAccident
                    
                    lda CC_WASprtImgNo,y            ; sprite number
                    cmp #NoSprPlrMovLaMin           ; sprite: Player - Ladder Up Phase 01 - $2e
                    beq .ChkLadderUp
                    
                    cmp #NoSprPlrMovLa02            ; sprite: Player - Ladder Up Phase 02 - $2f
                    beq .ChkLadderUp
                    
                    cmp #NoSprPlrMovLa03            ; sprite: Player - Ladder Up Phase 03 - $30
                    beq .ChkLadderUp
                    
                    cmp #NoSprPlrMovLa04            ; sprite: Player - Ladder Up Phase 04 - $31
                    beq .ChkLadderUp
                    
                    cmp #NoSprPlrMovPole            ; sprite: Player - Pole Down          - $26
                    bne .Survive
                    
.ChkLadderUp        lda CC_WASprtImgNo,x            ; sprite number
                    cmp #NoSprPlrMovLa01            ; sprite: Player - Ladder Up Phase 01 - $2e
                    beq .ChkPosY
                    
                    cmp #NoSprPlrMovLa02            ; sprite: Player - Ladder Up Phase 02 - $2f
                    beq .ChkPosY
                    
                    cmp #NoSprPlrMovLa03            ; sprite: Player - Ladder Up Phase 03 - $30
                    beq .ChkPosY
                    
                    cmp #NoSprPlrMovLa04            ; sprite: Player - Ladder Up Phase 04 - $31
                    beq .ChkPosY
                    
                    cmp #NoSprPlrMovPole            ; sprite: Player - Pole Down          - $26
                    bne .Survive
                    
.ChkPosY            lda CC_WASprtPosY,y
                    cmp CC_WASprtPosY,x
                    beq .Survive
                    
                    bcc .MarkFE
                    
.MarkEF             lda #$ef
                    sta CC_WASprtCtrlSV,x
                    jmp .Survive
                    
.MarkFE             lda #$fe
                    sta CC_WASprtCtrlSV,x
                    
.Survive            lda #$00
                    sta FlgMarkDeath
                    jmp PlayerSprtKillX
                    
.ChkAccident        ldy CC_WASprtPlayrNo,x
                    lda CC_LvlP_Status,y
                    cmp #CC_LVLP_Survive
                    bne .Survive
                    
                    lda #CC_LVLP_Accident
                    sta CC_LvlP_Status,y
                    
PlayerSprtKillX     jmp RetSprtSprtKill
; ------------------------------------------------------------------------------------------------------------- ;
; RunIntoRoom       Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
RunIntoRoom         pha
                    tya
                    pha
                    txa
                    pha
                    
                    jsr SpriteInitWA
                    
                    ldy SavPlayerNo
                    txa
                    sta SavP_OffSprWA,y
                    
                    lda CC_LvlP_TargDoor,y          ; $780b : count start: entry 00 of Room DOOR list
                    asl a
                    asl a
                    asl a                           ; *8 - length of each door entry
                    clc
                    adc SavDoorDataLo
                    sta $40
                    lda SavDoorDataHi
                    adc #$00
                    sta $41                         ; ($40/$41) point to players target door data
                    
                    ldy #CC_DoorInWall
                    lda ($40),y                     ; CC_RoomDoorPtr
                    and #CC_DoorOpen                ; Bit 7: 1=door already open
                    beq .DoorClosed                 ; door not open
                    
.DoorOpen           lda #CC_LVLP_IOStart
                    ldy SavPlayerNo
                    sta CC_LvlP_Status,y
                    
                    clc
                    ldy #CC_DoorPosX
                    lda ($40),y                     ; CC_RoomDoorPtr
                    adc #$0b
                    sta CC_WASprtPosX,x
                    clc
                    ldy #CC_DoorPosY
                    lda ($40),y                     ; CC_RoomDoorPtr
                    adc #$0c
                    sta CC_WASprtPosY,x
                    
                    lda #$18                        ; offset TabPlayerRoomIn
                    sta CC_WASprtRoomIOB,x          ; offset TabPlayerRoomIO block
                    lda #$03
                    sta CC_WASprtSeqNo,x
                    jmp .SetWrkValues
                    
.DoorClosed         lda #CC_LVLP_Survive
                    ldy SavPlayerNo
                    sta CC_LvlP_Status,y
                    
                    ldy #CC_DoorPosX
                    lda ($40),y                     ; CC_RoomDoorPtr
                    clc
                    adc #$06
                    sta CC_WASprtPosX,x
                    ldy #CC_DoorPosY
                    lda ($40),y                     ; CC_RoomDoorPtr
                    clc
                    adc #$0f
                    sta CC_WASprtPosY,x
                    
.SetWrkValues       lda #$03
                    sta CC_WASprtStepX,x
                    lda #$11
                    sta CC_WASprtStepY,x
                    
                    lda #$80
                    sta CC_WASprtNumWA,x
                    lda SavPlayerNo
                    sta CC_WASprtPlayrNo,x
                    
                    lda #NoSprPlrMovRiMin           ; sprite: Player - Move Right Phase 01 - $00
                    sta CC_WASprtImgNo,x
                    
                    lda #$ff
                    sta CC_WASprtWrkWA,x
                    sta CC_WASprtObjWA,x
                    sta CC_WASprtCtrlSV,x
                    
RunIntoRoomX        pla
                    tax
                    pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
SavPlayerNo         .byte $ba
; ------------------------------------------------------------------------------------------------------------- ;
; LightMachMove     Function: 
;                   Parms   : xr=Sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
LightMachMove       lda CC_WASprtFlag,x             ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    bit Mask_10                     ;            $10=action   $20=death          $40=dead           $80=init
                    beq .ChkInit
                    
                    eor Mask_10
                    ora Mask_08
                    sta CC_WASprtFlag,x
                    jmp LightMachMoveX
                    
.ChkInit            bit Mask_80
                    beq .Rnd
                    
                    eor Mask_80                     ; reset init
                    sta CC_WASprtFlag,x
                    
.Rnd                jsr Randomizer
                    
                    and #$03
                    sta CC_WASprtSeqNo,x
                    inc CC_WASprtSeqNo,x
                    
                    jsr Randomizer
                    
                    and #$03
                    clc
                    adc #NoSprSpaMovMin             ; sprite: Lightning Machine Spark - Phase 01 - $39
                    cmp CC_WASprtImgNo,x
                    bne .SetSpriteNo
                    
                    clc
                    adc #$01
                    cmp #NoSprSpaMovMax             ; sprite: Lightning Machine Spark - Phase 04 - $3d
                    bcc .SetSpriteNo
                    
                    lda #NoSprSpaMovMin             ; sprite: Lightning Machine Spark - Phase 01 - $39
.SetSpriteNo        sta CC_WASprtImgNo,x
                    
                    jsr CopySpriteData              ; set shape / expand and copy sprite data of a given number to its memory location
                    
LightMachMoveX       jmp RetSprtMove
; ------------------------------------------------------------------------------------------------------------- ;
; LightMachKill     Function: - called from: ChkSprtSprtKill
;                   Parms   : xr=touched sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                           : yr=moved   sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
LightMachKill       lda #$00
                    sta FlgMarkDeath
                    
LightMachKillX      jmp RetSprtSprtKill
; ------------------------------------------------------------------------------------------------------------- ;
; InitSprtSpark     Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
InitSprtSpark       pha
                    tya
                    pha
                    txa
                    pha
                    tay
                    
                    jsr SpriteInitWA
                    
                    lda #CC_SprSpark
                    sta CC_WASprtType,x             ; 00=Player 01=Spark 02=Force 03=Mummy 04=Beam 05=Frank
                    
                    lda CC_WAObjsPosY,y
                    clc
                    adc #$08
                    sta CC_WASprtPosY,x
                    
                    lda CC_WAObjsPosX,y
                    sta CC_WASprtPosX,x
                    
                    lda CC_ObjStLMBallNo,y
                    sta CC_WASprtNumWA,x
                    
InitSprtSparkX      pla
                    tax
                    pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
; ForceFiMove       Function: 
;                   Parms   : xr=Sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
ForceFiMove         lda CC_WASprtFlag,x             ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    bit Mask_10                     ;            $10=action   $20=death          $40=dead           $80=init
                    beq .Chk80
                    
                    eor Mask_10
                    ora Mask_08
                    sta CC_WASprtFlag,x
                    jmp ForceFiMoveX
                    
.Chk80              bit Mask_80
                    beq .ChkFieldStatus
                    
                    eor Mask_80
                    sta CC_WASprtFlag,x
                    
.ChkFieldStatus     ldy CC_WASprtNumWA,x
                    lda TabFFActive,y
                    cmp #$01
                    bne .FieldOpen
                    
.FieldClose         lda CC_WASprtDirMove,x
                    cmp #CC_WAJoyMoveUR
                    beq .ChkForceField
                    
                    lda #CC_WAJoyMoveUR
                    sta CC_WASprtDirMove,x
                    
                    jsr SetCtrlScrnPlyr
                    
                    sec
                    lda $3c
                    sbc #$02
                    sta $3c
                    bcs .MarkFieldClose
                    dec $3d
                    
.MarkFieldClose     ldy #$00
                    lda ($3c),y
                    and #CC_CtrlFFLeft
                    sta ($3c),y
                    ldy #$04
                    lda ($3c),y
                    and #CC_CtrlFFRight
                    sta ($3c),y
                    jmp .GetThin
                    
.ChkForceField      lda CC_WASprtImgNo,x
                    cmp #NoSprForMov01              ; sprite: Force Field - Phase 01 (thin)  - $35
                    bne .GetThin
                    
.GetThick           lda #NoSprForMov02              ; sprite: Force Field - Phase 02 (thick) - $3d
                    jmp .SetImage
                    
.GetThin            lda #NoSprForMov01              ; sprite: Force Field - Phase 01 (thin)  - $35
                    jmp .SetImage
                    
.FieldOpen          lda CC_WASprtDirMove,x
                    cmp #CC_WAJoyMoveUR
                    bne ForceFiMoveX
                    
                    lda #CC_WAJoyMoveU
                    sta CC_WASprtDirMove,x
                    jsr SetCtrlScrnPlyr
                    
                    sec
                    lda $3c
                    sbc #$02
                    sta $3c
                    bcs .MarkFieldOpen
                    dec $3d
                    
.MarkFieldOpen      ldy #$00
                    lda ($3c),y
                    ora #CC_CtrlFloorStrt
                    sta ($3c),y
                    
                    ldy #$04
                    lda ($3c),y
                    ora #CC_CtrlFloorEnd
                    sta ($3c),y
                    
.GetOpen            lda #NoSprForMov03              ; sprite: Force Field - Phase 03 (open) - $41
.SetImage           sta CC_WASprtImgNo,x
                    
                    jsr CopySpriteData              ; set shape / expand and copy sprite data of a given number to its memory location
                    
ForceFiMoveX        jmp RetSprtMove
; ------------------------------------------------------------------------------------------------------------- ;
; ForceFiSprtKill   Function: - called from: ChkSprtSprtKill
;                   Parms   : xr=touched sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                           : yr=moved   sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
ForceFiSprtKill     lda #$00
                    sta FlgMarkDeath
                    
ForceFiSprtKillX    jmp RetSprtSprtKill
; ------------------------------------------------------------------------------------------------------------- ;
; InitSprtForce     Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
InitSprtForce       pha                             ; force field sprite work area
                    tya
                    pha
                    txa
                    pha
                    
                    jsr SpriteInitWA
                    
                    lda #CC_SprForce
                    sta CC_WASprtType,x             ; 00=Player 01=Spark 02=Force 03=Mummy 04=Beam 05=Frank
                    
                    ldy #CC_FFFieldPosX
                    lda ($3e),y                     ; ForceDataPtr
                    sta CC_WASprtPosX,x
                    ldy #CC_FFFieldPosY
                    lda ($3e),y                     ; ForceDataPtr
                    clc
                    adc #$02
                    sta CC_WASprtPosY,x
                    
                    lda #NoSprForMov01              ; sprite: Force Field - Phase 01 (thin)  - $35
                    sta CC_WASprtImgNo,x
                    
                    lda WrkForceFieldNo
                    sta CC_WASprtNumWA,x
                    
                    lda #CC_WAJoyMoveU
                    sta CC_WASprtDirMove,x
                    lda #$04
                    sta CC_WASprtSeqNo,x
                    lda #$02
                    sta CC_WASprtStepX,x
                    lda #$19
                    sta CC_WASprtStepY,x
                    
InitSprtForceX      pla
                    tax
                    pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
; MummyMove         Function: 
;                   Parms   : xr=Sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
MummyMove           lda CC_WASprtFlag,x             ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    bit Mask_10                     ;            $10=action   $20=death          $40=dead           $80=init
                    beq .Chk80
                    
                    eor Mask_10
                    ora Mask_08
                    sta CC_WASprtFlag,x
                    jmp MummyMoveX
                    
.Chk80              bit Mask_80
                    beq .ChkSprtPlayerNo
                    
                    eor Mask_80
                    sta CC_WASprtFlag,x
                    
                    lda CC_WASprtDirMove,x
                    beq .ChkSprtPlayerNo
                    
                    lda #NoSprMumMovLeMin           ; sprite: Mummy - Move Left   Pase 01 - $4b
                    sta CC_WASprtImgNo,x
                    
                    jsr CopySpriteData              ; set shape / expand and copy sprite data of a given number to its memory location
                    
.ChkSprtPlayerNo    lda CC_WASprtPlayrNo,x
                    cmp #$ff
                    beq .SetRoomIOB
                    
                    cmp CC_WASprtRoomIOB,x          ; offset TabPlayerRoomIO block
                    beq .SetRoomIOB
                    
                    jsr TrapDoorHandler
                    
.SetRoomIOB         sta CC_WASprtRoomIOB,x          ; offset TabPlayerRoomIO block
                    lda #$ff
                    sta CC_WASprtPlayrNo,x
                    
                    clc
                    lda SavMumDataPtrLo
                    adc CC_WASprtJoyActn,x
                    sta $40
                    lda SavMumDataPtrHi
                    adc #$00
                    sta $41
                    
                    lda CC_WASprtDirMove,x
                    bne .ChkP_Alive
                    
                    inc CC_WASprtNumWA,x
                    ldy CC_WASprtNumWA,x
                    lda TabOMummySNo,y
                    cmp #$ff
                    beq .SetDirMove
                    
                    sta CC_WASprtImgNo,x
                    clc
                    lda CC_WASprtPosX,x
                    adc TabOMummyOffX,y
                    sta CC_WASprtPosX,x
                    clc
                    lda CC_WASprtPosY,x
                    adc TabOMummyOffY,y
                    sta CC_WASprtPosY,x
                    
                    lda CC_WASprtNumWA,x
                    asl a
                    asl a
                    adc #$24
                    sta SFX_MummyOutTone            ; vary tone
                    
                    lda #NoSndMummyOut              ; sound: Mummy Out - $0b
                    jsr InitSoundFX
                    
                    jmp .SetSprite
                    
.SetDirMove         lda #CC_WAJoyMoveUR
                    sta CC_WASprtDirMove,x
                    
                    clc
                    ldy #CC_MummyWallPosX
                    lda ($40),y                     ; CC_MummyDataPtr
                    adc #$04
                    sta CC_WASprtPosX,x
                    clc
                    ldy #CC_MummyWallPosY
                    lda ($40),y                     ; CC_MummyDataPtr
                    adc #$07
                    sta CC_WASprtPosY,x
                    
                    lda #$02
                    sta CC_WASprtSeqNo,x
                    
.ChkP_Alive         lda CC_LvlP1Status
                    cmp #CC_LVLP_Survive
                    beq .SetP1
                    
                    lda CC_LvlP2Status
                    cmp #CC_LVLP_Survive
                    beq .SetP2
                    
                    jmp MummyMoveX
                    
.SetP1              ldy #$00
                    jmp .GetP_
                    
.SetP2              ldy #$01
.GetP_              lda SavP_OffSprWA,y
                    tay
                    
                    jsr SetCtrlScrnPlyr
                    
                    sec
                    lda CC_WASprtPosX,x
                    sbc CC_WASprtPosX,y
                    bcs .ChkDirRight
                    
                    eor #$ff
                    adc #$01
.ChkDirRight        cmp #CC_WASprtRight
                    bcc MummyMoveX
                    
                    inc CC_WASprtImgNo,x
                    lda CC_WASprtPosX,x
                    cmp CC_WASprtPosX,y
                    bcs .ChkMummyStatus
                    
                    ldy #CC_MummyStatus
                    lda ($3c),y
                    and #CC_MummyDead
                    beq MummyMoveX
                    
                    inc CC_WASprtPosX,x
                    
                    lda CC_WASprtImgNo,x
                    cmp #NoSprMumMovRiMin           ; sprite: Mummy - Move Right  Pase 01     - $4e
                    bcc .SetStartR
                    
                    cmp #NoSprMumMovRiMax           ; sprite: Mummy - Move Right  Pase 03 + 1 - $51
                    bcc .SavMommyPos
                    
.SetStartR          lda #NoSprMumMovRiMin           ; sprite: Mummy - Move Right  Pase 01     - $4e
                    sta CC_WASprtImgNo,x
                    jmp .SavMommyPos
                    
.ChkMummyStatus     ldy #CC_MummyStatus
                    lda ($3c),y
                    and #$40
                    beq MummyMoveX
                    
                    dec CC_WASprtPosX,x
                    lda CC_WASprtImgNo,x
                    cmp #NoSprMumMovLeMin           ; sprite: Mummy - Move Left   Pase 01 - $4b
                    bcc .SetStartL
                    
                    cmp #NoSprMumMovRiMin           ; sprite: Mummy - Move Right  Pase 01 - $4e
                    bcc .SavMommyPos
                    
.SetStartL          lda #NoSprMumMovLeMin           ; sprite: Mummy - Move Left   Pase 01 - $4b
                    sta CC_WASprtImgNo,x
                    
.SavMommyPos        ldy #CC_MummySprtPosX
                    lda CC_WASprtPosX,x
                    sta ($40),y                     ; CC_RoomDoorPtr
                    ldy #CC_MummySprtPosY
                    lda CC_WASprtPosY,x
                    sta ($40),y                     ; CC_RoomDoorPtr
                    
.SetSprite          jsr CopySpriteData              ; set shape / expand and copy sprite data of a given number to its memory location
                    
MummyMoveX          jmp RetSprtMove
; ------------------------------------------------------------------------------------------------------------- ;
; MummyTrapKill     Function: - called from: SprtBkgrHandler
;                   Parms   : xr=Sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                           : yr=Status work area block offset 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
MummyTrapKill       sty SavPtrMummyWA
                    lda CC_WAObjsType,y
                    cmp #CC_ObjTrapDoor
                    bne .Survive
                    
                    clc
                    lda CC_WASprtPosX,x
                    adc CC_WASprtStepX,x
                    sec
                    sbc CC_WAObjsPosX,y
                    cmp #$04
                    bcs .Survive
                    
                    clc
                    lda SavTrapDataPtrLo
                    adc CC_ObjStTrOffDat,y
                    sta $40
                    lda SavTrapDataPtrHi
                    adc #$00
                    sta $41
                    
                    ldy #$00
                    lda ($40),y                     ; CC_TrapDataPtr
                    bit Mask_01_e
                    beq .Survive
                    
                    clc
                    lda SavMumDataPtrLo
                    adc CC_WASprtJoyActn,x
                    sta $40
                    lda SavMumDataPtrHi
                    adc #$00
                    sta $41
                    
                    ldy #$00
                    lda #CC_MummyGone
                    sta ($40),y                     ; CC_TrapDataPtr
                    jmp MummyTrapKillX
                    
.Survive            ldy SavPtrMummyWA
                    lda #$00
                    sta FlgCollision
                    
                    lda CC_WAObjsType,y
                    cmp #CC_ObjTrapCtrl
                    bne MummyTrapKillX
                    
                    clc
                    lda CC_WASprtPosX,x
                    adc CC_WASprtStepX,x
                    sec
                    sbc CC_WAObjsPosX,y
                    cmp #$04
                    bcs MummyTrapKillX
                    
                    lda CC_ObjStTrOffDat,y
                    sta CC_WASprtPlayrNo,x
                    
MummyTrapKillX      jmp RetSprtBkgrKill
; ------------------------------------------------------------------------------------------------------------- ;
; MummySprtKill     Function: - called from: ChkSprtSprtKill
;                   Parms   : xr=touched sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                           : yr=moved   sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
MummySprtKill       lda CC_WASprtType,y             ; 00=Player 01=Spark 02=Force 03=Mummy 04=Beam 05=Frank
                    beq .Survive                    ; CC_SprPlayer
                    
                    cmp #CC_SprFrank
                    bne .SetDataPtr
                    
.Survive            lda #$00
                    sta FlgMarkDeath
                    jmp MummySprtKillX
                    
.SetDataPtr         clc
                    lda SavMumDataPtrLo
                    adc CC_WASprtJoyActn,x
                    sta $40
                    lda SavMumDataPtrHi
                    adc #$00
                    sta $41
                    
                    ldy #CC_MummyStatus
                    lda #CC_MummyGone
                    sta ($40),y                     ; CC_MummyDataPtr
                    
MummySprtKillX      jmp RetSprtSprtKill
; ------------------------------------------------------------------------------------------------------------- ;
; InitSprtMummy     Function: 
;                   Parms   : ac=Flag mummy out
;                           : xr=Sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
InitSprtMummy       pha
                    sta FlgMummyOut
                    tya
                    pha
                    txa
                    pha
                    tay
                    
                    jsr SpriteInitWA
                    
                    lda #CC_SprMummy
                    sta CC_WASprtType,x             ; 00=Player 01=Spark 02=Force 03=Mummy 04=Beam 05=Frank
                    
                    lda #$ff
                    sta CC_WASprtRoomIOB,x          ; offset TabPlayerRoomIO block
                    sta CC_WASprtPlayrNo,x
                    
                    lda CC_ObjStMuPtrWA,y
                    sta CC_WASprtJoyActn,x
                    
                    clc
                    adc SavMumDataPtrLo             ; saved MummyDataPtrLo
                    sta $40
                    lda SavMumDataPtrHi             ; saved MummyDataPtrHi
                    adc #$00
                    sta $41                         ; ($40/$41) point to mummy data
                    
                    lda #$05
                    sta CC_WASprtStepX,x
                    lda #$11
                    sta CC_WASprtStepY,x
                    
                    lda #$ff
                    sta CC_WASprtImgNo,x
                    
                    lda FlgMummyOut
                    bne .MummyOut
                    
.MummyIn            lda #CC_WAJoyMoveU
                    sta CC_WASprtDirMove,x
                    
                    lda #$ff
                    sta CC_WASprtNumWA,x
                    lda #$04
                    sta CC_WASprtSeqNo,x
                    
                    ldy #CC_MummyWallPosX
                    clc
                    lda ($40),y                     ; CC_RoomDoorPtr
                    adc #$0d
                    sta CC_WASprtPosX,x
                    
                    clc
                    ldy #CC_MummyWallPosY
                    lda ($40),y                     ; CC_RoomDoorPtr
                    adc #$08
                    sta CC_WASprtPosY,x
                    jmp InitSprtMummyX
                    
.MummyOut           lda #CC_WAJoyMoveUR
                    sta CC_WASprtDirMove,x
                    
                    ldy #CC_MummySprtPosX
                    lda ($40),y                     ; CC_RoomDoorPtr
                    sta CC_WASprtPosX,x
                    
                    ldy #CC_MummySprtPosY
                    lda ($40),y                     ; CC_RoomDoorPtr
                    sta CC_WASprtPosY,x
                    
                    lda #$02
                    sta CC_WASprtSeqNo,x
                    
InitSprtMummyX      pla
                    tax
                    pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
FlgMummyOut         .byte $b3
TabOMummySNo        .byte NoSprMumMovOu01           ; sprite: Mummy - Out Of Wall Pase 01 - $45
                    .byte NoSprMumMovOu02           ; sprite: Mummy - Out Of Wall Pase 02 - $46
                    .byte NoSprMumMovOu03           ; sprite: Mummy - Out Of Wall Pase 03 - $47
                    .byte NoSprMumMovOu04           ; sprite: Mummy - Out Of Wall Pase 04 - $48
                    .byte NoSprMumMovOu05           ; sprite: Mummy - Out Of Wall Pase 05 - $49
                    .byte NoSprMumMovOu06           ; sprite: Mummy - Out Of Wall Pase 06 - $4a
                    .byte NoSprMumMovOu06           ; sprite: Mummy - Out Of Wall Pase 06 - $4a
                    .byte $ff                       ; EndOfMove
                    
TabOMummyOffX       .byte $00
                    .byte $fe
                    .byte $fe
                    .byte $fe
                    .byte $fe
                    .byte $fe
                    .byte $fe
                    .byte $00
TabOMummyOffY       .byte $00
                    .byte $00
                    .byte $00
                    .byte $02
                    .byte $02
                    .byte $02
                    .byte $02
                    .byte $00
SavPtrMummyWA       .byte $ba
; ------------------------------------------------------------------------------------------------------------- ;
; RayBeamMove       Function: 
;                   Parms   : xr=Sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
RayBeamMove         lda CC_WASprtFlag,x             ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    bit Mask_10                     ;            $10=action   $20=death          $40=dead           $80=init
                    beq .Chk80
                    
                    eor Mask_10
                    ora Mask_08
                    sta CC_WASprtFlag,x
                    lda CC_WASprtDirMove,x
                    
                    clc
                    adc SavGunDataPtrLo
                    sta $40
                    lda SavGunDataPtrHi
                    adc #$00
                    sta $41
                    
                    ldy #$00
                    lda #$ff
                    eor Mask_40_d
                    and ($40),y                     ; CC_GunDataPtr
                    sta ($40),y                     ; CC_GunDataPtr
                    jmp RayBeamMoveX
                    
.Chk80              bit Mask_80
                    beq .Move
                    
                    eor Mask_80                     ;            $10=action   $20=death          $40=dead           $80=init
                    sta CC_WASprtFlag,x             ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    
.Move               clc
                    lda CC_WASprtPosX,x
                    adc CC_WASprtNumWA,x
                    sta CC_WASprtPosX,x
                    cmp #$b0
                    bcs .SetFlag10
                    
                    cmp #$08
                    bcs RayBeamMoveX
                    
.SetFlag10          lda CC_WASprtFlag,x             ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    ora Mask_10                     ;            $10=action   $20=death          $40=dead           $80=init
                    sta CC_WASprtFlag,x
                    
RayBeamMoveX        jmp RetSprtMove
; ------------------------------------------------------------------------------------------------------------- ;
; RayBeamObjKill    Function: 
;                   Parms   : xr=Sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                           : yr=
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
RayBeamObjKill      lda CC_WAObjsType,y
                    cmp #CC_ObjLightBall
                    beq RayBeamObjKillX
                    
                    cmp #CC_ObjFrank
                    beq RayBeamObjKillX
                    
                    cmp #CC_ObjGun
                    bne .Survive
                    
                    lda CC_WASprtDirMove,x
                    cmp CC_ObjStGuPtrWA,y
                    bne RayBeamObjKillX
                    
.Survive            lda #$00
                    sta FlgCollision
                    
RayBeamObjKillX     jmp RetSprtBkgrKill
; ------------------------------------------------------------------------------------------------------------- ;
; InitSprtBeam      Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
InitSprtBeam        pha
                    tya
                    pha
                    txa
                    pha
                    tay
                    
                    clc
                    lda CC_ObjStGuPtrWA,y
                    adc #$07
                    and #$f8
                    lsr a
                    adc #$2c
                    sta SFX_GunShotTone             ; vary tone
                    
                    lda #NoSndGunShot               ; sound: Ray Gun Shot - $00
                    jsr InitSoundFX
                    jsr SpriteInitWA
                    
                    lda #CC_SprBeam
                    sta CC_WASprtType,x             ; 00=Player 01=Spark 02=Force 03=Mummy 04=Beam 05=Frank
                    lda CC_WAObjsPosX,y
                    sta CC_WASprtPosX,x
                    
                    clc
                    lda CC_WAObjsPosY,y
                    adc #$05
                    sta CC_WASprtPosY,x
                    
                    lda #NoSprRayMov01              ; sprite: Ray Gun - Beam - $6c
                    sta CC_WASprtImgNo,x
                    
                    lda CC_ObjStGuPtrWA,y
                    sta CC_WASprtDirMove,x
                    
                    ldy #CC_GunDirection
                    lda ($40),y                     ; CC_Gun
                    bit Mask_01_d                   ; test direction
                    beq .MoveBeamRight
                    
.MoveBeamLeft       sec
                    lda CC_WASprtPosX,x
                    sbc #$08
                    sta CC_WASprtPosX,x
                    
                    lda #$fc
                    sta CC_WASprtNumWA,x
                    jmp .SetSpriteData
                    
.MoveBeamRight      clc
                    lda CC_WASprtPosX,x
                    adc #$08
                    sta CC_WASprtPosX,x
                    
                    lda #$04
                    sta CC_WASprtNumWA,x
                    
.SetSpriteData      jsr CopySpriteData              ; set shape / expand and copy sprite data of a given number to its memory location
                    
InitSprtBeamX       pla
                    tax
                    pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
; FrankMove         Function: 
;                   Parms   : xr=Sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
FrankMove           lda CC_WASprtFlag,x             ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    bit Mask_10                     ;            $10=action   $20=death          $40=dead           $80=init
                    beq .Chk80
                    
                    eor Mask_10
                    ora Mask_08
                    sta CC_WASprtFlag,x
                    jmp FrankMoveX
                    
.Chk80              bit Mask_80
                    beq .SetFrankDatPtr
                    
                    eor Mask_80
                    sta CC_WASprtFlag,x
                    
.SetFrankDatPtr     clc
                    lda SavFrStDataPtrLo
                    adc CC_WASprtWork,x             ; offset actual Frank data
                    sta $40
                    lda SavFrStDataPtrHi
                    adc #$00
                    sta $41
                    
                    lda CC_WASprtStatus,x           ; stores CC_FrStCoffDir
                    bit Mask_02_g                   ; CC_WASprtRight or CC_WASprtLeft
                    bne .ChkRoomIO                  ; Frank has left his coffin
                    
                    lda FlgRoomLoadAdr              ; $00=$7800 $01=$9800 $02=$b800
                    cmp #CC_LvlStorID
                    bne .ChkFrankToAwake
                    
                    jmp FrankMoveX
                    
.ChkFrankToAwake    lda #$01
                    sta WrkPlayerNo
.NextPlayer01       ldy WrkPlayerNo
                    lda CC_LvlP_Status,y
                    cmp #CC_LVLP_Survive            ; player still alive
                    bne .SetNextPlayer01            ; no
                    
                    lda SavP_OffSprWA,y
                    tay
                    sec
                    lda CC_WASprtPosY,x             ; Frank
                    sbc CC_WASprtPosY,y             ; Player
                    cmp #$04
                    bcs .SetNextPlayer01            ; wrong row
                    
                    sec
                    lda CC_WASprtPosX,x             ; Frank
                    sbc CC_WASprtPosX,y             ; Player
                    bcc .ChkFrankOutLe              ; left side
                    
.ChkFrankOutRi      lda CC_WASprtStatus,x           ; right side
                    bit Mask_01_g                   ; CC_WAJoyMoveUR  CC_WAJoyMoveDR  CC_WAJoyMoveDL  CC_WAJoyMoveUL
                    beq .SetNextPlayer01
                    
                    jmp .MarkFrankOut
                    
.ChkFrankOutLe      lda CC_WASprtStatus,x
                    bit Mask_01_g                   ; CC_WAJoyMoveUR  CC_WAJoyMoveDR  CC_WAJoyMoveDL  CC_WAJoyMoveUL
                    beq .MarkFrankOut
                    
.SetNextPlayer01    dec WrkPlayerNo
                    bpl .NextPlayer01
                    
                    jmp FrankMoveX
                    
.MarkFrankOut       ora Mask_02_g                   ; CC_FrStAwake
                    sta CC_WASprtStatus,x
                    
                    ldy #CC_FrStCoffDir
                    sta ($40),y                     ; CC_FrankDataPtr
                    
                    lda #$80
                    sta CC_WASprtJoyActn,x
                    
                    lda #NoSndFrankOut              ; sound: Frank Out - $07
                    jsr InitSoundFX
                    
.ChkRoomIO          lda CC_WASprtRoomIOB,x          ; offset TabPlayerRoomIO block
                    cmp #$ff                        ; object handled already
                    beq .PutIOB                     ; yes
                    
                    cmp CC_WASprtObjWA,x            ; object to handle
                    beq .PutIOB                     ; no
                    
                    jsr TrapDoorHandler             ; Trap Door Switch touched
                    
.PutIOB             sta CC_WASprtObjWA,x
                    lda #$ff
                    sta CC_WASprtRoomIOB,x          ; offset TabPlayerRoomIO block
                    
                    jsr SetCtrlScrnPlyr
                    
                    ldy #$00
                    lda ($3c),y
                    and CC_WASprtPlayrNo,x
                    sta SavP_CScrnVal
                    
                    lda #$ff
                    sta CC_WASprtPlayrNo,x
                    
                    lda SavP_CScrnVal
                    bne .ChkScrnValI
                    
                    lda #$80
                    sta CC_WASprtJoyActn,x
                    jmp .ChkJoyDir
                    
.ChkScrnValI        ldy #$06
                    lda #$00
                    sta WrkPlayerNo
.ChkScrnVal         lda Mask_01to80,y               ; flags: $02 $08 $20 $80
                    bit SavP_CScrnVal               ; $01 $04 $10 $40 - control screen types (ladder ground pole ground)
                    beq .ChkScrnValNext
                    
                    inc WrkPlayerNo
                    sty SavScrnValBitPos
                    
.ChkScrnValNext     dey
                    dey
                    bpl .ChkScrnVal
                    
                    lda WrkPlayerNo
.ChkValFound01      cmp #$01
                    bne .ChkValFound02
                    
                    lda SavScrnValBitPos
                    sta CC_WASprtJoyActn,x          ; $00=up $02=right $04=down $06=left $80=
                    jmp .ChkJoyDir
                    
.ChkValFound02      cmp #$02
                    bne .MoveTabInitI               ; found03 - Ladder/Pole crosses
                    
                    lda SavScrnValBitPos
                    sec
                    sbc #$04                        ; $fc $fe $00 $02
                    and #$07                        ; $04 $06 $00 $02
                    tay
                    lda Mask_01to80,y               ; $10 $40 $01 $04
                    bit SavP_CScrnVal
                    beq .MoveTabInitI
                    
                    ldy CC_WASprtJoyActn,x          ; $00=up $02=right $04=down $06=left $80=
                    bmi .MoveTabInitI
                    
                    lda Mask_01to80,y
                    bit SavP_CScrnVal
                    beq .MoveTabInitI
                    
                    jmp .ChkJoyDir                  ; no direction checks for pole bottom
                    
.MoveTabInitI       lda #$ff
                    ldy #$03
.MoveTabInit        sta TabP_PosXY,y
                    dey
                    bpl .MoveTabInit
                    
.NextPlayer02I      lda #$01
                    sta WrkPlayerNo
.NextPlayer02       ldy WrkPlayerNo
                    lda CC_LvlP_Status,y
                    cmp #CC_LVLP_Survive
                    bne .SetNextPlayer02
                    
.ChkPosX            lda SavP_OffSprWA,y
                    tay
                    sec
                    lda CC_WASprtPosX,y
                    sbc CC_WASprtPosX,x             ; Frank
                    bcs .SelTabPos01                ; larger/equal  - Frank on Players left side
                    
                    eor #$ff
                    adc #$01                        ; make positive - Frank on Players right side
.SelTabPos03        ldy #$03
                    jmp .ChkTabPosX
                    
.SelTabPos01        ldy #$01
.ChkTabPosX         cmp TabP_PosXY,y
                    bcs .ChkPosY
                    
.SetTabPosX         sta TabP_PosXY,y                ; $01 or $03 - Frank on left or right
                    
.ChkPosY            ldy WrkPlayerNo
                    lda SavP_OffSprWA,y
                    tay
                    sec
                    lda CC_WASprtPosY,y             ; Player
                    sbc CC_WASprtPosY,x             ; Frank
                    bcs .SelTabPos02                ; larger/equal  - Frank above Player
                    
                    eor #$ff
                    adc #$01                        ; make positive - Frank below Player
.SelTabPos00        ldy #$00
                    jmp .ChkTabPosY
                    
.SelTabPos02        ldy #$02
.ChkTabPosY         cmp TabP_PosXY,y
                    bcs .SetNextPlayer02
                    
.SetTabPosY         sta TabP_PosXY,y                ; $00 or $02 - above or below
                    
.SetNextPlayer02    dec WrkPlayerNo
                    bpl .NextPlayer02
                    
                    lda #$ff
                    sta WrkP_PosVal
.LoopP_PosXYI       lda #$00
                    sta SavP_PosVal
                    lda #$ff
                    sta SavP_PosPtr
                    
                    ldy #$03
.LoopP_PosXY        lda TabP_PosXY,y
                    cmp WrkP_PosVal
                    bcs .NextP_PosXY                ; new value lower than saved value
                    
                    cmp SavP_PosVal
                    bcc .NextP_PosXY                ; new value higher than actual value
                    
                    sta SavP_PosVal                 ; save actual value
                    sty SavP_PosPtr                 ; save actual pointer
                    
.NextP_PosXY        dey
                    bpl .LoopP_PosXY
                    
                    lda SavP_PosPtr
                    cmp #$ff                        ; nothing found
                    bne .ChkCScrnVal
                    
                    lda #$80
                    sta CC_WASprtJoyActn,x          ; $00=up $02=right $04=down $06=left $80=
                    jmp .ChkJoyDir
                    
.ChkCScrnVal        asl a                           ; SavP_PosPtr *2 - $00=up $02=right $04=down $06=left
                    tay
                    lda Mask_01to80,y
                    bit SavP_CScrnVal
                    bne .SetJoyDir
                    
                    lda SavP_PosVal
                    sta WrkP_PosVal
                    jmp .LoopP_PosXYI
                    
.SetJoyDir          tya                             ; $00=up $02=right $04=down $06=left
                    sta CC_WASprtJoyActn,x
.ChkJoyDir          lda CC_WASprtJoyActn,x          ; $00=up $02=right $04=down $06=left $80=
                    and #$02
                    beq .ChkJoyUpDo
                    
.JoyLeRi            sec
                    lda CC_WASprtPosY,x
                    sbc CtrlScrnRow_0_2             ; Bit 0-2 of CtrlScrnRowNo
                    sta CC_WASprtPosY,x
                    
                    inc CC_WASprtImgNo,x
                    
                    lda CC_WASprtJoyActn,x          ; $00=up $02=right $04=down $06=left $80=
                    cmp #$02
                    beq .MoveRight
                    
.MoveLeft           dec CC_WASprtPosX,x
                    
                    lda CC_WASprtImgNo,x
                    cmp #NoSprFraMovLeMin           ; sprite: Frank - Move Left  Pase 01
                    bcc .MoveLeftImg01
                    
                    cmp #NoSprFraMovLeMax           ; sprite: Frank - Move Left  Pase 03
                    bcc .SetSpriteData
                    
.MoveLeftImg01      lda #NoSprFraMovLeMin ;         ; sprite: Frank - Move Left  Pase 01 - $87
                    sta CC_WASprtImgNo,x
                    jmp .SetSpriteData
                    
.MoveRight          inc CC_WASprtPosX,x
                    
                    lda CC_WASprtImgNo,x
                    cmp #NoSprFraMovRiMin           ; sprite: Frank - Move Right Pase 01
                    bcc .MoveRightImg01
                    
                    cmp #NoSprFraMovRiMax           ; sprite: Frank - Move Right  Pase 03
                    bcc .SetSpriteData
                    
.MoveRightImg01     lda #NoSprFraMovRiMin           ; sprite: Frank - Move Right Pase 01
                    sta CC_WASprtImgNo,x
                    jmp .SetSpriteData
                    
.ChkJoyUpDo         lda CC_WASprtJoyActn,x          ; $00=up $02=right $04=down $06=left $80=
                    bmi .UpdFrankGameDat
                    
.JoyUpDo            sec                             ; center on ladder/pole
                    lda CC_WASprtPosX,x
                    sbc CtrlScrnCol_0_1             ; Bit 0-1 of CtrlScrnColNo
                    sta CC_WASprtPosX,x
                    inc CC_WASprtPosX,x
                    
                    ldy #$00
                    lda ($3c),y
                    and #$01                        ; #CC_CtrlLadderBot
                    bne .ChkJoyUp                   ; ladder
                    
.SetSprtPole        lda #NoSprFraMovPole            ; sprite: Frank - Pole Down
                    sta CC_WASprtImgNo,x
                    
.MovePoleDown       clc
                    lda CC_WASprtPosY,x
                    adc #$02                        ; speed down
                    sta CC_WASprtPosY,x
                    jmp .SetSpriteData
                    
.ChkJoyUp           lda CC_WASprtJoyActn,x          ; $00=up $02=right $04=down $06=left $80=
                    bne .MoveFrankDown
                    
.MoveFrankUp        sec
                    lda CC_WASprtPosY,x
                    sbc #$02
                    sta CC_WASprtPosY,x
                    jmp .SetSpriteNo
                    
.MoveFrankDown      clc
                    lda CC_WASprtPosY,x
                    adc #$02
                    sta CC_WASprtPosY,x
                    
.SetSpriteNo        lda CC_WASprtPosY,x
                    and #$06
                    lsr a
                    clc
                    adc #NoSprFraMovLaMin           ; sprite: Frank - Ladder u/d Phase 01 - $8b
                    sta CC_WASprtImgNo,x
                    
.SetSpriteData      jsr CopySpriteData              ; set shape / expand and copy sprite data of a given number to its memory location
                    
.UpdFrankGameDat    lda CC_WASprtJoyActn,x          ; $00=up $02=right $04=down $06=left $80=
                    ldy #CC_FrStSprtDir
                    sta ($40),y                     ; CC_FrankDataPtr
                    
                    lda CC_WASprtPosX,x
                    ldy #CC_FrStSprtPosX
                    sta ($40),y                     ; CC_FrankDataPtr
                    
                    lda CC_WASprtPosY,x
                    ldy #CC_FrStSprtPosY
                    sta ($40),y                     ; CC_FrankDataPtr
                    
                    lda CC_WASprtImgNo,x
                    ldy #CC_FrStSprtNo
                    sta ($40),y                     ; CC_FrankDataPtr
                    
FrankMoveX          jmp RetSprtMove
; ------------------------------------------------------------------------------------------------------------- ;
; FrankTrapKill     Function: - called from: SprtBkgrHandler
;                   Parms   : xr=Sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                           : yr=Status work area block offset 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
FrankTrapKill       clc
                    lda CC_WASprtPosX,x
                    adc CC_WASprtStepX,x
                    sec
                    sbc CC_WAObjsPosX,y
                    cmp #$04
                    bcc .Contact
                    
.NoContact          lda #$00
                    sta FlgCollision
.Exit               jmp FrankTrapKillX
                    
.Contact            lda CC_WAObjsType,y
                    cmp #CC_ObjTrapDoor
                    beq .TrapDoor
                    
                    lda #$00
                    sta FlgCollision
                    
                    lda CC_WAObjsType,y
                    cmp #CC_ObjTrapCtrl
                    bne FrankTrapKillX
                    
                    lda CC_ObjStTrOffDat,y
                    sta CC_WASprtRoomIOB,x          ; offset TabPlayerRoomIO block
                    jmp FrankTrapKillX
                    
.TrapDoor           clc
                    lda SavTrapDataPtrLo
                    adc CC_ObjStTrOffDat,y
                    sta $40
                    lda SavTrapDataPtrHi
                    adc #$00
                    sta $41
                    
                    ldy #CC_TrapMode
                    lda ($40),y                     ; CC_TrapDataPtr
                    bit Mask_01_e                   ; CC_TrapOpen
                    beq .NoContact
                    
                    clc
.TrapDoorOpen       lda SavFrStDataPtrLo
                    adc CC_WASprtNumWA,x
                    sta $40
                    lda SavFrStDataPtrHi
                    adc #$00
                    sta $41
                    
                    ldy #CC_FrStCoffDir
                    lda Mask_02_g
                    eor #$ff
                    and ($40),y                     ; CC_RoomDoorPtr
                    ora Mask_04_g                   ; CC_FrStGone - death
                    sta ($40),y
                    sta CC_WASprtDirMove,x
                    
FrankTrapKillX      jmp RetSprtBkgrKill
; ------------------------------------------------------------------------------------------------------------- ;
; FrankSprtKill     Function: - called from: ChkSprtSprtKill
;                   Parms   : xr=touched sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                           : yr=moved   sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
FrankSprtKill       lda CC_WASprtDirMove,x
                    bit Mask_02_g                   ; CC_WASprtLeft or CC_WASprtRight
                    beq .GoMarkAlive
                    
                    lda CC_WASprtType,y             ; 00=Player 01=Spark 02=Force 03=Mummy 04=Beam 05=Frank
                    beq .GoMarkAlive                ; CC_SprPlayer
                    
                    cmp #CC_SprForce
                    beq .GoMarkAlive
                    
                    cmp #CC_SprMummy
                    beq .GoMarkAlive
                    
                    cmp #CC_SprFrank
                    beq .ChkPole
                    
                    clc                             ; Spark and Beam left over
                    lda SavFrStDataPtrLo
                    adc CC_WASprtNumWA,x
                    sta $40
                    lda SavFrStDataPtrHi
                    adc #$00
                    sta $41
                    
                    ldy #$00
                    lda Mask_02_g
                    eor #$ff
                    and ($40),y                     ; CC_FrankDataPtr
                    ora Mask_04_g                   ; mark death
                    sta ($40),y
                    jmp FrankSprtKillX
                    
.ChkPole            lda CC_WASprtImgNo,x
                    cmp #NoSprFraMovPole            ; sprite: Frank: Pole down   - $8a
                    bcc .ChkRight
                    
                    cmp #NoSprFraStaCoff;           ; sprite: Frank: Coffin wait - $8f
                    bcs .ChkRight
                    
                    lda CC_WASprtImgNo,y
                    cmp #NoSprFraMovPole            ; sprite: Frank: Pole down   - $8a
                    bcc .MarkAlive
                    
                    cmp #NoSprFraStaCoff            ; sprite: Frank: Coffin wait - $8f
                    bcs .MarkAlive
                    
                    lda CC_WASprtPosY,x
                    cmp CC_WASprtPosY,y
                    beq .MarkAlive
                    
                    bcs .ClrBit0
                    
                    lda CC_WASprtPlayrNo,x
.ClrBit4            and #$ef                        ; ###. ####
                    sta CC_WASprtPlayrNo,x
                    jmp .MarkAlive
                    
.ClrBit0            lda CC_WASprtPlayrNo,x
                    and #$fe                        ; #### ###.
                    sta CC_WASprtPlayrNo,x
                    
.GoMarkAlive        jmp .MarkAlive
                    
.ChkRight           lda CC_WASprtImgNo,x
                    cmp #NoSprFraMovRiMin           ; sprite: Frank - Move Right Phase 01 - $84
                    bcc .MarkAlive
                    
                    cmp #NoSprFraMovPole            ; sprite: Frank - Pole down           - $8a
                    bcs .MarkAlive
                    
                    lda CC_WASprtImgNo,y
                    cmp #NoSprFraMovRiMin           ; sprite: Frank - Move Right Phase 01 - $84
                    bcc .MarkAlive
                    
                    cmp #NoSprFraMovPole            ; sprite: Frank - Pole down           - $8a
                    bcs .MarkAlive
                    
                    lda CC_WASprtPosX,x
                    cmp CC_WASprtPosX,y
                    bcs .ClrBit6
                    
.ClrBit2            lda CC_WASprtPlayrNo,x
                    and #$fb                        ; #### #.##
                    sta CC_WASprtPlayrNo,x
                    jmp .MarkAlive
                    
.ClrBit6            lda CC_WASprtPlayrNo,x
                    and #$bf                        ; #.## ####
                    sta CC_WASprtPlayrNo,x
                    
.MarkAlive          lda #$00
                    sta FlgMarkDeath
                    
FrankSprtKillX      jmp RetSprtSprtKill
; ------------------------------------------------------------------------------------------------------------- ;
; SetFrStSpriteWA   Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
SetFrStSpriteWA     pha
                    tya
                    pha
                    txa
                    pha
                    
                    ldy #CC_FrStCoffDir
                    lda ($3e),y                     ; FrankensteinDataPtr
                    bit Mask_04_g
                    bne SetFrStSpriteWAX            ; frankenstein already dead
                    
                    jsr SpriteInitWA
                    
                    lda #CC_SprFrank
                    sta CC_WASprtType,x             ; 00=Player 01=Spark 02=Force 03=Mummy 04=Beam 05=Frank
                    lda PtrFrStWorkData
                    sta CC_WASprtNumWA,x
                    
                    ldy #CC_FrStCoffDir
                    lda ($3e),y                     ; FrankensteinDataPtr
                    sta CC_WASprtDirMove,x
                    bit Mask_02_g
                    bne .FrankOut
                    
.FrankIn            ldy #CC_FrStCoffPosX
                    lda ($3e),y                     ; FrankensteinDataPtr
                    sta CC_WASprtPosX,x
                    ldy #CC_FrStCoffPosY
                    lda ($3e),y                     ; FrankensteinDataPtr
                    clc
                    adc #$07
                    sta CC_WASprtPosY,x
                    
                    lda #NoSprFraStaCoff            ; sprite: Frank - Coffin wait - $8f
                    sta CC_WASprtImgNo,x
                    jmp .SetSprite
                    
.FrankOut           ldy #CC_FrStSprtPosX
                    lda ($3e),y                     ; FrankensteinDataPtr
                    sta CC_WASprtPosX,x
                    ldy #CC_FrStSprtPosY
                    lda ($3e),y                     ; FrankensteinDataPtr
                    sta CC_WASprtPosY,x
                    
                    ldy #CC_FrStSprtNo
                    lda ($3e),y                     ; FrankensteinDataPtr
                    sta CC_WASprtImgNo,x
                    
                    ldy #CC_FrStSprtDir
                    lda ($3e),y                     ; FrankensteinDataPtr
                    sta CC_WASprtJoyActn,x
                    
.SetSprite          lda #$03
                    sta CC_WASprtStepX,x
                    lda #$11
                    sta CC_WASprtStepY,x
                    
                    jsr CopySpriteData              ; set shape / expand and copy sprite data of a given number to its memory location
                    
                    lda #$ff
                    sta CC_WASprtPlayrNo,x
                    sta CC_WASprtObjWA,x
                    sta CC_WASprtRoomIOB,x          ; offset TabPlayerRoomIO block
                    
                    lda #$02
                    sta CC_WASprtSeqNo,x
                    sta CC_WASprtOldNo,x
                    
SetFrStSpriteWAX    pla
                    tax
                    pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
WrkPlayerNo         .byte $85
SavScrnValBitPos    .byte $a0
TabP_PosXY          .byte $a5                        ; set if Frank is below    Player - $00 gives $00=up
                    .byte $c4                        ; set if Frank is left  of Player - $01 gives $02=right
                    .byte $85                        ; set if Frank is above    Player - $02 gives $04=down
                    .byte $c1                        ; set if Frank is right of Player - $03 gives $06=left
WrkP_PosVal         .byte $ba
SavP_PosVal         .byte $c9
SavP_PosPtr         .byte $a0
SavP_CScrnVal       .byte $85
; ------------------------------------------------------------------------------------------------------------- ;
; SpriteInitWA      Function: 
;                   Parms   : 
;                   Returns : xr=Sprite WA offset ($00, $20, $40, $60, $80, $a0, $c0, $e0)
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
SpriteInitWA        pha                             ; initialize the work area blocks - $20 bytes each
                    tya
                    pha
                    ldx #$00
.NextBlock          lda CC_WASprtFlag,x             ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    bit Mask_01                     ; already initialized?
                    bne .InitI                      ; no
                    
                    txa
                    clc
                    adc #CC_SprWALen                ; point to next block of data
                    tax
                    bne .NextBlock                  ; check all 8 blocks
                    
                    sec                             ; nothing to init
                    jmp SpriteInitWAX
                    
.InitI              ldy #CC_SprWALen                ; amount
                    lda #$00
.Init               sta CC_WASprtBlock,x            ; variable block start
                    inx
                    dey
                    bne .Init
                    
                    txa
                    sec
                    sbc #CC_SprWALen                ; reset to start
                    tax
                    lda Mask_80
                    sta CC_WASprtFlag,x             ; 80=initialized
                    lda #$01
                    sta CC_WASprtOldNo,x
                    sta CC_WASprtSeqNo,x
                    clc                             ; a block was initialized
                    
SpriteInitWAX       pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
; ObjectHandler     Function: Loop through the object work areas and check for actions
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
ObjectHandler       pha
                    tya
                    pha
                    txa
                    pha
                    
                    lda #$00
                    sta WrkWAUseCount
ohNextObjWA         lda WrkWAUseCount
                    cmp ObjWAUseCount               ; max $20 entries a 08 bytes in object work area
                    bcc .NextObjWA
                    
                    jmp ObjectHandlerX              ; exit
                    
.NextObjWA          asl a
                    asl a
                    asl a                           ; *8 - length of each entry
                    tax
                    lda CC_WAObjsFlag,x
.Chk40              bit Mask_40_b                   ; action completed - CC_WAObjsReady
                    beq ohChk20                     ; no: complete
                    
.ObjectType         lda CC_WAObjsType,x             ; object type ($00-$0f)
                    asl a
                    asl a                           ; *4
                    tay
                    lda ObjMoveAuto,y               ; $00-Door           -Bell       $02-LightBall      -LightSwitch
                    sta .___ObjTypAdrLo             ; $04-Force       $05-Mummy          Key            -Lock
                    lda ObjMoveAuto+1,y             ; $08-Gun            -GunSwitch  $0a-MTRecOval   $0b-TrapDoor
                    sta .___ObjTypAdrHi             ;    -TrapSwitch  $0d-WalkWay       -WalkSwitch     -Frank
                    beq ohSet40
                    
.JmpObjMoveAuto     .byte $4c                       ; jmp T_3f85
.___ObjTypAdrLo     .byte $85
.___ObjTypAdrHi     .byte $3f
                    
RetObjMoveAuto      jmp ohChk20I                    ; common return point of many sub routines - cannot be local
                    
ohSet40             lda CC_WAObjsFlag,x
                    eor Mask_40_b                   ; action completed - CC_WAObjsReady
                    sta CC_WAObjsFlag,x
                    
ohChk20I            lda CC_WAObjsFlag,x
ohChk20             bit Mask_20_b                   ; move - CC_WAObjsMove
                    beq .GoChkNextObjWA
                    
                    jsr PaintWAObjTyp1
                    
                    dec ObjWAUseCount               ; max $20 entries of $08 bytes in object work area
                    
                    lda ObjWAUseCount               ; max $20 entries of $08 bytes in object work area
                    asl a
                    asl a
                    asl a                           ; *8 - length of each work area entry
                    sta .___WAAmount
                    
.CpxWAUsed          .byte $e0                       ; cpx #$00
.___WAAmount        .byte $00
                    
                    beq ObjectHandlerX              ; exit
                    
                    tay
                    lda #CC_ObjWALen
                    sta WrkWABlkCount
.Copy               lda CC_WAObjsBlock,y
                    sta CC_WAObjsBlock,x
                    
                    lda CC_WAObjsStatus,y
                    sta CC_WAObjsStatus,x
                    
                    inx
                    iny
                    dec WrkWABlkCount
                    bne .Copy
                    
.GoChkNextObjWA     inc WrkWAUseCount
                    jmp ohNextObjWA
                    
ObjectHandlerX      pla
                    tax
                    pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
WrkWABlkCount       .byte $d8
WrkWAUseCount       .byte $84
; ------------------------------------------------------------------------------------------------------------- ;
; DoorOpen          Function: - Called from: ObjectHandler
;                   Parms   : xr=Object status area offset ($00, $08, $10, $18, ...)
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
DoorOpen            lda CC_ObjStDoFlag,x
                    bne .Sound                      ; CC_ObjDoorOpen
                    
                    lda #CC_ObjDoorOpen
                    sta CC_ObjStDoFlag,x            ; flag: door is open
                    
                    lda #$0e                        ; door lift count
                    sta CC_ObjStDoLift,x
                    lda CC_ObjStDoNo,x
                    asl a
                    asl a
                    asl a                           ; *8 - length of each door data entry
                    clc
                    adc SavDoorDataLo
                    sta $40
                    lda SavDoorDataHi
                    adc #$00
                    sta $41                         ; ($40/$41) point to target door data
                    
.MarkFromDoor       ldy #CC_DoorInWall
                    lda ($40),y
                    ora #CC_DoInWallOpen            ; set Bit 7 = door open
                    sta ($40),y                     ; mark actual door of actual room
                    
                    ldy #CC_DoorToDoorNo
                    lda ($40),y
                    pha
                    ldy #CC_DoorToRoomNo
                    lda ($40),y
                    
                    jsr SetRoomShapePtr
                    pla
                    jsr SetRoomDoorPtr
                    
.MarkToDoor         ldy #CC_DoorInWall
                    lda ($40),y
                    ora #CC_DoInWallOpen            ; set Bit 7 = door open
                    sta ($40),y                     ; mark target door of target room
                    
.Sound              sec
                    lda #$10
                    sbc CC_ObjStDoLift,x
                    sta SFX_OpenDoorTone            ; vary tone
                    
                    lda #NoSndOpenDoor              ; sound: Open Door - $03
                    jsr InitSoundFX
                    
                    lda CC_ObjStDoLift,x
                    beq .IsOpen                     ; door fully opened
                    
                    dec CC_ObjStDoLift,x            ; dor lift counter
                    
                    clc
                    adc CC_WAObjsPosY,x
                    sta PrmPntObj1PosY
                    lda CC_WAObjsPosX,x
                    sta PrmPntObj1PosX
                    
                    lda #NoObjBlank                 ; object: various - Blank Line - $7c
                    sta PrmPntObj1No
                    lda #$01
                    sta PrmPntObj_Type
                    
.PaintLiftGate      jsr PaintObject                 ; blank grate line by line bottom up
                    
                    jmp DoorOpenX
                    
.IsOpen             lda CC_WAObjsFlag,x
                    eor Mask_40_b                   ; action completed - CC_WAObjsReady
                    sta CC_WAObjsFlag,x
                    
                    ldy #$05
                    lda CC_ObjStDoTColor,x          ; target room color
.OpenColor          sta ColObjDoorGround,y              ; color open doors floor
                    dey
                    bpl .OpenColor
                    
                    lda #NoObjDoorGround            ; object: Open Doors Floor - $08
                    sta PrmPntObj0No
                    
                    lda CC_WAObjsPosX,x
                    sta PrmPntObj0PosX
                    lda CC_WAObjsPosY,x
                    sta PrmPntObj0PosY
                    
.PaintFloor         jsr PaintWAObjTyp0
                    
DoorOpenX           jmp RetObjMoveAuto
; ------------------------------------------------------------------------------------------------------------- ;
; DoorLeave         Function: - called from: SprtBkgrHandler
;                   Parms   : xr=Sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                           : yr=Status work area block offset 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
DoorLeave           sty SavPtrWADoorSt              ; YR=PtrWAObjsStTreat (offset status work area block to handle)
                    
                    lda CC_ObjStDoFlag,y            ; shut=00 open=01
                    beq .Exit
                    
                    lda CC_WASprtType,x             ; 00=Player 01=Spark 02=Force 03=Mummy 04=Beam 05=Frank
                    beq .Player
                    
.Exit               jmp DoorLeaveX
                    
.Player             lda CC_WASprtDirMove,x
                    cmp #CC_WAJoyMoveUR
                    bne DoorLeaveX
                    
                    ldy CC_WASprtPlayrNo,x
                    lda CC_LvlP_Status,y
                    cmp #CC_LVLP_Survive
                    bne DoorLeaveX
                    
                    lda #CC_LVLP_IOStart
                    sta CC_LvlP_Status,y
                    
                    lda #$00
                    sta CC_WASprtRoomIOB,x          ; offset TabPlayerRoomIO block
                    
                    lda #$03
                    sta CC_WASprtSeqNo,x
                    
                    ldy SavPtrWADoorSt
                    lda CC_ObjStDoNo,y
                    asl a
                    asl a
                    asl a                           ; *8
                    clc
                    adc SavDoorDataLo
                    sta $40
                    lda SavDoorDataHi
                    adc #$00
                    sta $41
                    
                    ldy #CC_DoorPosY
                    clc
                    lda ($40),y                     ; CC_RoomDoorPtr
                    adc #$0f
                    sta CC_WASprtPosY,x
                    ldy #CC_DoorPosX
                    clc
                    lda ($40),y                     ; CC_RoomDoorPtr
                    adc #$06
                    sta CC_WASprtPosX,x
                    
                    ldy #CC_DoorType
                    lda ($40),y                     ; CC_RoomDoorPtr
                    beq .NormalDoor
                    
.ExitDoor           ldy CC_WASprtPlayrNo,x
                    lda #$01
                    sta CC_LvlP1AtDoor,y
                    
.NormalDoor         ldy #CC_DoorToDoorNo
                    lda ($40),y                     ; CC_RoomDoorPtr
                    sta SavToDoorNo
                    ldy #CC_DoorToRoomNo
                    lda ($40),y                     ; CC_RoomDoorPtr
                    sta SavToRoomNo
                    
                    jsr SetRoomShapePtr
                    
                    ldy #CC_RoomColor
                    lda ($42),y                     ; RoomDataPtr
                    ora Mask_80_c                   ; CC_RoVisited
                    sta ($42),y
                    
                    ldy CC_WASprtPlayrNo,x
                    lda SavToRoomNo
                    sta CC_LvlP_TargRoom,y          ; $7809 : count start: entry 00 of ROOM list
                    lda SavToDoorNo
                    sta CC_LvlP_TargDoor,y          ; $780b : count start: entry 00 of Room DOOR list
                    
DoorLeaveX          ldy SavPtrWADoorSt
                    jmp RetObjMoveManu
; ------------------------------------------------------------------------------------------------------------- ;
; RoomDoor          Function: Paint a chambers door - Called from: PaintRoomItems
;                   Parms   : Pointer ($3e/$3f) to CC_Door of CC_LvlGame
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
RoomDoor            pha
                    tya
                    pha
                    txa
                    pha
                    
                    ldy #CC_DoorCount
                    lda ($3e),y                     ; DoorDataPtr
                    sta SavDoorCount                ; CC_DoorCount = number of doors in room
                    inc $3e
                    bne .SavPtr
                    inc $3f                         ; ($3e/$3f) point to door data
                    
.SavPtr             lda $3e
                    sta SavDoorDataLo
                    lda $3f
                    sta SavDoorDataHi
                    
                    lda #$00
                    sta WrkDoorCount
                    
.ChkNextDoor        lda WrkDoorCount
                    cmp SavDoorCount
                    bne .NextDoor
                    
                    jmp RoomDoorX                   ; all room doors handled
                    
.NextDoor           ldy #CC_DoorType                ; $00=normal $01=exit
                    lda ($3e),y
                    tax
                    lda TabDoorObjType,x            ; object: door - $06=normal $96=exit
                    sta PrmPntObj0No
                    
                    ldy #CC_DoorPosX
                    lda ($3e),y                     ; DoorDataPtr
                    sta PrmPntObj0PosX
                    ldy #CC_DoorPosY
                    lda ($3e),y                     ; DoorDataPtr
                    sta PrmPntObj0PosY
                    lda #$00
                    sta PrmPntObj_Type
                    
.PaintDoor          jsr PaintObject
                    jsr ObjectInitWA                ; XR=ObjectWAOffset
                    
                    clc
                    lda PrmPntObj0PosX
                    adc #$04
                    sta PrmPntObj0PosX
                    clc
                    lda PrmPntObj0PosY
                    adc #$10
                    sta PrmPntObj0PosY
                    
                    lda WrkDoorCount
                    sta CC_ObjStDoNo,x
                    lda #CC_ObjDoor
                    sta CC_WAObjsType,x
                    
                    ldy #CC_DoorToRoomNo
                    lda ($3e),y                     ; DoorDataPtr
                    
                    jsr SetRoomShapePtr
                    
                    ldy #CC_RoomColor
                    lda ($42),y                     ; TargetRoomDataPtr
                    and #$0f
                    sta CC_ObjStDoTColor,x
                    asl a
                    asl a
                    asl a
                    asl a
                    ora CC_ObjStDoTColor,x
                    sta CC_ObjStDoTColor,x
                    
                    ldy #CC_DoorInWall
                    lda ($3e),y                     ; DoorDataPtr
                    and #CC_DoInWallOpen            ; isolate Bit 7
                    bne .Open                       ; 1=door open
                    
                    lda #NoObjDoorGrate             ; object: door grating - $07
                    jmp .SetObjNo
                    
.Open               lda #CC_ObjDoorOpen
                    sta CC_ObjStDoFlag,x
                    
                    ldy #$05
                    lda CC_ObjStDoTColor,x          ; color
.OpenColor          sta ColObjDoorGround,y              ; object: door open
                    dey
                    bpl .OpenColor
                    
                    lda #NoObjDoorGround            ; object: Open Door Ground - $08
.SetObjNo           sta PrmPntObj0No
                    
.PaintGrtGrnd       jsr PaintWAObjTyp0              ; grating or ground
                    
                    clc
                    lda $3e
                    adc #CC_DoorLen                 ; $08 = length of each door data entry
                    sta $3e
                    bcc .SetCount
                    inc $3f
                    
.SetCount           inc WrkDoorCount
                    jmp .ChkNextDoor
                    
RoomDoorX           pla
                    tax
                    pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
WrkDoorCount        .byte $a0
SavDoorCount        .byte $a0
TabDoorObjType      .byte NoObjDoorNormal           ; object: Door Normal - $06
                    .byte NoObjDoorExit             ; object: Door Exit   - $96
SavDoorDataLo       .byte $ac
SavDoorDataHi       .byte $b4
SavPtrWADoorSt      .byte $a0
SavToRoomNo         .byte $9e
SavToDoorNo         .byte $a0
; ------------------------------------------------------------------------------------------------------------- ;
; BellPress         Function: - called from: SprtBkgrHandler
;                   Parms   : xr=Sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                           : yr=Status work area block offset 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
BellPress           stx SavPtrWABellSt              ; YR=PtrWAObjsStTreat (offset status work area block to handle)
                    
                    lda CC_WASprtType,x             ; 00=Player 01=Spark 02=Force 03=Mummy 04=Beam 05=Frank
                    bne BellPressX                  ; only a player can press the button
                    
                    lda CC_WASprtJoyActn,x
                    beq BellPressX                  ; CC_WAJoyNoFire
                    
                    clc
                    lda CC_WASprtPosX,x
                    adc CC_WASprtStepX,x
                    sec
                    sbc CC_WAObjsPosX,y
                    cmp #$0c
                    bcs BellPressX
                    
                    lda CC_WASprtPlayrNo,x
                    tax
                    lda CC_LvlP_Status,x
                    cmp #CC_LVLP_Survive
                    bne BellPressX
                    
                    ldx #$00
.GetWADoor          lda CC_WAObjsType,x
                    bne .SetNextWA                  ; no door
                    
                    lda CC_ObjStDoNo,x
                    cmp CC_ObjStBeDoorNo,y
                    beq .Found
                    
.SetNextWA          clc
                    txa
                    adc #$08
                    tax
                    jmp .GetWADoor
                    
.Found              lda CC_ObjStDoFlag,x
                    bne BellPressX                  ; CC_ObjDoorOpen
                    
                    lda CC_WAObjsFlag,x
                    ora Mask_40_b                   ; action completed - CC_WAObjsReady
                    sta CC_WAObjsFlag,x
                    
BellPressX          ldx SavPtrWABellSt
                    jmp RetObjMoveManu
; ------------------------------------------------------------------------------------------------------------- ;
; RoomBell          Function: Paint a chambers door bells - Called from: PaintRoomItems
;                   Parms   : Pointer ($3e/$3f) to CC_DoorBell of CC_LvlGame
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
RoomBell            pha
                    tya
                    pha
                    txa
                    pha
                    
                    ldy #CC_BellCount
                    lda ($3e),y                     ; BellDataPtr
                    sta WrkBellCount
                    
                    inc $3e
                    bne .ChkBellCount
                    inc $3f                         ; ($3e/$3f) point to bell data
                    
.ChkBellCount       lda WrkBellCount
                    beq RoomBellX
                    
                    jsr ObjectInitWA                ; XR=ObjectWAOffset
                    
                    lda #CC_ObjBell
                    sta CC_WAObjsType,x
                    
                    ldy #CC_BellPosX
                    lda ($3e),y                     ; BellDataPtr
                    sta PrmPntObj0PosX
                    ldy #CC_BellPosY
                    lda ($3e),y                     ; BellDataPtr
                    sta PrmPntObj0PosY
                    
                    lda #NoObjDoorBell              ; object: Door Bell - $09
                    sta PrmPntObj0No
                    
                    ldy #CC_BellForDoorNo
                    lda ($3e),y                     ; BellDataPtr
                    sta CC_ObjStBeDoorNo,x
                    
                    ldy #CC_ObjDoor 
.FindColor          lda CC_WAObjsType,y
                    bne .SetNextEntry               ; no door (type=CC_ObjDoor)
                    
.ObjWADoor          lda CC_ObjStDoNo,y              ;   doornumber Door
                    cmp CC_ObjStBeDoorNo,x          ; = doornumber Bell
                    bne .SetNextEntry
                    
                    lda CC_ObjStDoTColor,y          ; target room color
                    jmp .BellColorI
                    
.SetNextEntry       tya
                    clc
                    adc #CC_ObjWALen                ; select next work area entry
                    tay
                    jmp .FindColor
                    
.BellColorI         ldy #$08
.BellColor          sta ColObjDoorBell01,y
                    dey
                    bpl .BellColor
                    
                    lsr a
                    lsr a
                    lsr a
                    lsr a
                    ora #$10                        ; right nybbel to white
.KnobColor          sta ColObjDoorBell02
                    
.PaintBell          jsr PaintWAObjTyp0
                    
                    clc
                    lda $3e
                    adc #CC_DoorBellLen             ; $03 = length of each bell data entry
                    sta $3e
                    bcc .BellCountDec
                    inc $3f
                    
.BellCountDec       dec WrkBellCount
                    jmp .ChkBellCount
                    
RoomBellX           pla
                    tax
                    pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
WrkBellCount        .byte $a0
SavPtrWABellSt      .byte $ff
; ------------------------------------------------------------------------------------------------------------- ;
; LightMachPole     Function: - Called from: ObjectHandler
;                   Parms   : xr=Object status area offset ($00, $08, $10, $18, ...)
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
LightMachPole       clc
                    lda SavLMDataPtrLo
                    adc CC_ObjStLMBallNo,x          ; $00 $08 $10 $18 $20 ...
                    sta $40
                    lda SavLMDataPtrHi
                    adc #$00
                    sta $41
                    
                    lda CC_ObjStLMModeBa,x
                    cmp #CC_ObjModeOn
                    beq .SparkIsOn
                    
.SparkIsOff         lda #CC_ObjModeOn
                    sta CC_ObjStLMModeBa,x
                    
                    jsr InitSprtSpark
                    
                    jmp .PoleMotion
                    
.SparkIsOn          ldy #CC_LMMode
                    lda ($40),y                     ; CC_RoomDoorPtr
                    bit Mask_40_h                   ; CC_LMBallOn
                    bne .SwitchedOn
                    
.SwitchedOff        lda #CC_ObjModeOff
                    sta CC_ObjStLMModeBa,x
                    
                    lda CC_WAObjsFlag,x
                    eor Mask_40_b                   ; action completed - CC_WAObjsReady
                    sta CC_WAObjsFlag,x
                    
                    lda #$55                        ; green
                    sta DatObjLiMaPole01
                    sta DatObjLiMaPole02
                    
                    lda #$00
                    sta PrmPntObj_Type
                    
                    ldy #CC_LMPosX
                    lda ($40),y                     ; CC_LightMachPtr
                    sta PrmPntObj0PosX
                    ldy #CC_LMPosY
                    lda ($40),y                     ; CC_LightMachPtr
                    sta PrmPntObj0PosY
                    
                    lda #NoObjLiMaPoleOff           ; object: Lightning Machine Pole Off - $34
                    sta PrmPntObj0No
                    
                    ldy #CC_LMPoleLenght
                    lda ($40),y                     ; CC_LightMachPtr
                    sta WrkLMPoleLength
.Pole               lda WrkLMPoleLength
                    beq .SearchWAI
                    
.PaintPoleOff       jsr PaintObject
                    
                    clc
                    lda PrmPntObj0PosY
                    adc #$08
                    sta PrmPntObj0PosY
                    dec WrkLMPoleLength
                    jmp .Pole
                    
.SearchWAI          ldy #$00
.SearchWA           lda CC_WASprtType,y             ; 00=Player 01=Spark 02=Force 03=Mummy 04=Beam 05=Frank
                    cmp #CC_SprSpark
                    bne .NextWA
                    
                    lda CC_WASprtFlag,y             ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    bit Mask_01                     ;            $10=action   $20=death          $40=dead           $80=init
                    bne .NextWA
                    
                    lda CC_WASprtNumWA,y
                    cmp CC_ObjStLMBallNo,x
                    beq .FoundWA
                    
.NextWA             tya
                    clc
                    adc #$20
                    tay
                    jmp .SearchWA
                    
.FoundWA            lda CC_WASprtFlag,y             ; $00=active $01=inactive $02=coll_sprt/sprt $04=coll_sprt/bkgr $08=
                    ora Mask_10                     ;            $10=action   $20=death          $40=dead           $80=init
                    sta CC_WASprtFlag,y
                    jmp LightMachPoleX
                    
.SwitchedOn         lda WrkCountActions             ; counter ActionHandler routine calls
                    and #$03
                    beq .PoleMotion
                    
                    jmp LightMachPoleX
                    
.PoleMotion         inc CC_ObjStLMMotion,x
                    lda CC_ObjStLMMotion,x
                    cmp #$03
                    bcc .PolePasesI                 ; lower
                    
                    lda #$00
                    sta CC_ObjStLMMotion,x
                    
.PolePasesI         sta WrkLMPoleMotion
                    ldy #CC_LMPosX
                    lda ($40),y                     ; CC_LightMachPtr
                    sta PrmPntObj0PosX
                    ldy #CC_LMPosY
                    lda ($40),y                     ; CC_LightMachPtr
                    sta PrmPntObj0PosY
                    
                    lda #$00
                    sta PrmPntObj_Type
                    lda #NoObjLiMaPoleOff           ; object: Lightning Machine Pole Off - $34
                    sta PrmPntObj0No
                    
                    ldy #CC_LMPoleLenght
                    lda ($40),y                     ; CC_LightMachPtr
                    sta WrkLMPoleLength
                    
.PolePases          lda WrkLMPoleLength
                    beq LightMachPoleX
                    
                    lda WrkLMPoleMotion
                    beq .PolePhase00
                    
                    cmp #$01
                    beq .PolePhase01
                    
.PolePhase02        lda #$66                        ; blue
                    sta DatObjLiMaPole01
                    lda #$01                        ; white
                    sta DatObjLiMaPole02
                    jmp .PaintPoleOn
                    
.PolePhase00        lda #$16                        ; white/blue
                    sta DatObjLiMaPole01
                    lda #$06                        ; blue
                    sta DatObjLiMaPole02
                    jmp .PaintPoleOn
                    
.PolePhase01        lda #$61                        ; blue/white
                    sta DatObjLiMaPole01
                    lda #$06                        ; blue
                    sta DatObjLiMaPole02
                    
.PaintPoleOn        jsr PaintObject
                    
                    inc WrkLMPoleMotion
                    lda WrkLMPoleMotion
                    cmp #$03
                    bcc .SetNextPolePart            ; lower
                    
                    lda #$00
                    sta WrkLMPoleMotion
                    
.SetNextPolePart    clc
                    lda PrmPntObj0PosY
                    adc #$08
                    sta PrmPntObj0PosY
                    dec WrkLMPoleLength
                    jmp .PolePases
                    
LightMachPoleX      jmp RetObjMoveAuto
; ------------------------------------------------------------------------------------------------------------- ;
WrkLMPoleLength     .byte $a5
WrkLMPoleMotion     .byte $a0
; ------------------------------------------------------------------------------------------------------------- ;
; RoomLightMach     Function: Paint a chambers lightning machines - Called from: PaintRoomItems
;                   Parms   : Pointer ($3e/$3f) to CC_LightMachine of CC_LvlGame
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
RoomLightMach       pha
                    tya
                    pha
                    txa
                    pha
                    
                    lda $3e
                    sta SavLMDataPtrLo
                    lda $3f
                    sta SavLMDataPtrHi
                    
                    lda #$00
                    sta WrkSwitchBallNo
                    
.NextLM             ldy #$00
                    lda ($3e),y                     ; LightDataPtr
                    bit Mask_20_h
                    beq .LightMac
                    
                    inc $3e
                    bne .Exit
                    inc $3f                         ; ($3e/$3f) point behind EndOfLightData
                    
.Exit               jmp RoomLightMachX
                    
.LightMac           jsr ObjectInitWA                ; XR=ObjectWAOffset
                    
                    lda WrkSwitchBallNo
                    sta CC_ObjStLMBallNo,x
                    
                    ldy #CC_LMMode
                    lda ($3e),y                     ; LightDataPtr
                    bit Mask_80_h                   ; switch: down
                    beq .SetWrkBall
                    
                    ldy #CC_LMPosX
                    lda ($3e),y                     ; LightDataPtr
                    sta PrmPntObj0PosX
                    ldy #CC_LMPosY
                    lda ($3e),y                     ; LightDataPtr
                    sta PrmPntObj0PosY
                    lda #$00
                    sta PrmPntObj_Type
                    lda #NoObjLiMaSwFrame           ; object: Lightning Machine Switch Frame - $36
                    sta PrmPntObj0No
                    
.PaintLMSFrame      jsr PaintObject
                    
                    clc
                    lda PrmPntObj0PosX
                    adc #$04
                    sta PrmPntObj0PosX
                    clc
                    lda PrmPntObj0PosY
                    adc #$08
                    sta PrmPntObj0PosY
                    
                    lda #CC_ObjLightCtrl
                    sta CC_WAObjsType,x
                    
                    ldy #CC_LMMode
                    lda ($3e),y                     ; LightDataPtr
                    bit Mask_40_h                   ; ball: on
                    bne .SwitchUp
                    
.SwitchDown         lda #NoObjLiMaSwDown            ; object: Lightning Machine Switch Down - $38
                    jmp .SetSwitch
                    
.SwitchUp           lda #NoObjLiMaSwUp              ; object: Lightning Machine Switch Up   - $37
.SetSwitch          sta PrmPntObj0No
                    
                    jsr PaintWAObjTyp0
                    
                    jmp .WrkBallNoInc
                    
.SetWrkBall         lda #CC_ObjLightBall
                    sta CC_WAObjsType,x
                    
                    ldy #CC_LMPosX
                    lda ($3e),y                     ; LightDataPtr
                    sta PrmPntObj0PosX
                    ldy #CC_LMPosY
                    lda ($3e),y                     ; LightDataPtr
                    sta PrmPntObj0PosY
                    
                    lda #$00
                    sta PrmPntObj_Type
                    
                    lda #NoObjLiMaPoleOn            ; object: Lightning Machine Pole On - $32
                    sta PrmPntObj0No
                    
                    ldy #CC_LMPoleLenght
                    lda ($3e),y                     ; LightDataPtr
                    sta WrkPoleLength
                    sta CC_ObjStLMPoleLe,x
                    
.Pole               lda WrkPoleLength
                    beq .Ball
                    
.PaintPole          jsr PaintObject
                    
                    clc
                    lda PrmPntObj0PosY
                    adc #$08
                    sta PrmPntObj0PosY
                    dec WrkPoleLength
                    jmp .Pole
                    
.Ball               sec
                    lda PrmPntObj0PosX
                    sbc #$04
                    sta PrmPntObj0PosX
                    lda #NoObjLiMaBall              ; object: Lightning Machine Ball - $33
                    sta PrmPntObj0No
                    
                    jsr PaintWAObjTyp0
                    
                    ldy #CC_LMMode
                    lda ($3e),y                     ; LightDataPtr
                    bit Mask_40_h                   ; ball: on
                    beq .WrkBallNoInc
                    
                    lda CC_WAObjsFlag,x
                    ora Mask_40_b                   ; action completed - CC_WAObjsReady
                    sta CC_WAObjsFlag,x
                    
.WrkBallNoInc       clc
                    lda WrkSwitchBallNo
                    adc #$08                        ; set next ball
                    sta WrkSwitchBallNo
                    
                    clc
                    lda $3e
                    adc #CC_LightMachLen            ; $08 = lightning machine data entry length
                    sta $3e
                    bcc .GoNextLM
                    inc $3f
                    
.GoNextLM           jmp .NextLM
                    
RoomLightMachX      pla
                    tax
                    pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
WrkSwitchBallNo     .byte $95
WrkPoleLength       .byte $80
; ------------------------------------------------------------------------------------------------------------- ;
; LightMachSwitch   Function: - called from: SprtBkgrHandler
;                   Parms   : xr=Sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                           : yr=Status work area block offset 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
LightMachSwitch     lda CC_WASprtType,x             ; 00=Player 01=Spark 02=Force 03=Mummy 04=Beam 05=Frank
                    bne .Exit
                    
                    clc
                    lda CC_WASprtPosX,x
                    adc CC_WASprtStepX,x
                    sec
                    sbc CC_WAObjsPosX,y
                    cmp #$04
                    bcs .Exit
                    
                    lda CC_WASprtDirMove,x
                    beq .Switch                     ; CC_WAJoyMoveU
                    
                    cmp #CC_WAJoyMoveD
                    beq .Switch
                    
.Exit               jmp LightMachSwitchX
                    
.Switch             lda #$00
                    sta PtrLMSelList
                    
                    clc
                    lda SavLMDataPtrLo
                    adc CC_ObjStLMBallNo,y
                    sta $30
                    lda SavLMDataPtrHi
                    adc #$00
                    sta $31
                    
                    sty SavLMPtrStWA                ; offset status work area block to handle
                    
                    ldy #CC_LMMode
                    lda ($30),y
                    bit Mask_40_h                   ; CC_LMBallOn
                    bne .Check
                    
                    lda CC_WASprtDirMove,x
                    bne .Exit                       ; not CC_WAJoyMoveU
                    
                    jmp .SetSwitchOn
                    
.Check              lda CC_WASprtDirMove,x
                    beq .Exit                       ; CC_WAJoyMoveU
                    
.SetSwitchOn        lda ($30),y
                    eor Mask_40_h                   ; set CC_LMBallOn
                    sta ($30),y
                    
.SelctionList       lda PtrLMSelList
                    cmp #$04                        ; length selection list
                    bcs .GoKlick                    ; greater/equal
                    
                    clc
                    lda #$04
                    adc PtrLMSelList
                    tay
                    lda ($30),y
                    cmp #CC_ObjBallNoUse
                    bne .HandleBall
                    
.GoKlick            jmp .Klick
                    
.HandleBall         sta WrkLMBallNo
                    clc
                    adc SavLMDataPtrLo
                    sta $32
                    lda SavLMDataPtrHi
                    adc #$00
                    sta $33
                    
                    ldy #CC_LMMode
                    lda ($32),y
                    eor Mask_40_h                   ; set CC_LMBallOn
                    sta ($32),y
                    
                    ldy #$00
.SearchWA           lda CC_WAObjsType,y
                    cmp #CC_ObjLightBall
                    bne .SetNextWA
                    
                    lda CC_ObjStLMBallNo,y
                    cmp WrkLMBallNo
                    beq .FoundWA
                    
.SetNextWA          tya
                    clc
                    adc #$08
                    tay
                    jmp .SearchWA
                    
.FoundWA            lda CC_WAObjsFlag,y
                    ora Mask_40_b                   ; action completed - CC_WAObjsReady
                    sta CC_WAObjsFlag,y
                    
                    inc PtrLMSelList
                    jmp .SelctionList
                    
.Klick              ldy #CC_LMMode
                    lda ($30),y
                    bit Mask_40_h                   ; CC_LMBallOn
                    bne .KlickOn
                    
.KlickOff           lda #$2f
                    sta SFX_LightSwTone             ; vary sound
                    
                    lda #NoObjLiMaSwDown            ; object: Lightning Machine Switch Down - $38
                    jmp .SetSwitch
                    
.KlickOn            lda #$23
                    sta SFX_LightSwTone             ; vary sound
                    
                    lda #NoObjLiMaSwUp              ; object: Lightning Machine Switch Up   - $37
.SetSwitch          sta PrmPntObj0No
                    
                    ldy SavLMPtrStWA                ; offset status work area block to handle
                    lda CC_WAObjsPosX,y
                    sta PrmPntObj0PosX
                    lda CC_WAObjsPosY,y
                    sta PrmPntObj0PosY
                    stx SavLMPtrSprtWA
                    ldx SavLMPtrStWA                ; offset status work area block to handle
                    
.PaintSwitch        jsr PaintWAObjTyp0
                    
                    ldx SavLMPtrSprtWA
                    ldy SavLMPtrStWA                ; offset status work area block to handle
                    
                    lda #NoSndLiMacSwitch           ; sound: Lightning Machine Switch - $06
                    jsr InitSoundFX
                    
LightMachSwitchX    jmp RetObjMoveManu
; ------------------------------------------------------------------------------------------------------------- ;
PtrLMSelList        .byte $99
SavLMPtrStWA        .byte $80
SavLMPtrSprtWA      .byte $a0
WrkLMBallNo         .byte $c8
SavLMDataPtrLo      .byte $a0
SavLMDataPtrHi      .byte $ce
Mask_80_h           .byte $80
Mask_40_h           .byte $40
Mask_20_h           .byte $20
; ------------------------------------------------------------------------------------------------------------- ;
; ForceFiClose      Function: - Called from: ObjectHandler
;                   Parms   : xr=Object status area offset ($00, $08, $10, $18, ...)
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
ForceFiClose        dec CC_ObjStFoSecond,x
                    bne ForceFiCloseX               ; no second has passed by
                    
                    dec CC_ObjStFoTimer,x
                    ldy CC_ObjStFoTimer,x
                    lda TabFFPingHeight,y
                    sta SFX_ForcePngTone            ; vary tone
                    
                    lda #NoSndForcePing             ; sound: Close Force Field Ping - $02
                    jsr InitSoundFX
                    
                    ldy #$00
.FillTimer          tya
                    cmp CC_ObjStFoTimer,x
                    bcc .Black
                    
.White              lda #$55                        ; .#.#.#.# - pattern force field switch timer square
                    jmp .FillSquare
                    
.Black              lda #$00                        ; ........ - pattern force field switch timer square
.FillSquare         sta DatObjFoFiTime01,y
                    iny
                    cpy #CC_FoTimerStart
                    bcc .FillTimer
                    
                    lda CC_WAObjsPosX,x
                    sta PrmPntObj0PosX
                    lda CC_WAObjsPosY,x
                    sta PrmPntObj0PosY
                    
                    lda #NoObjLoFiTimer             ; object: Force Field Timer Square - $40
                    sta PrmPntObj0No
                    lda #$00
                    sta PrmPntObj_Type
                    
.PaintTimer         jsr PaintObject
                    
                    lda CC_ObjStFoTimer,x
                    beq .TimeIsUp
                    
                    lda #$1e
                    sta CC_ObjStFoSecond,x          ; reinit second counter
                    jmp ForceFiCloseX
                    
.TimeIsUp           lda CC_WAObjsFlag,x
                    eor Mask_40_b                   ; action completed - CC_WAObjsReady
                    sta CC_WAObjsFlag,x
                    
                    ldy CC_ObjStFoNo,x
                    lda #$01
                    sta TabFFActive,y
                    
ForceFiCloseX       jmp RetObjMoveAuto
; ------------------------------------------------------------------------------------------------------------- ;
; ForceFiSwitch     Function: - called from: SprtBkgrHandler
;                   Parms   : xr=Sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                           : yr=Status work area block offset 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
ForceFiSwitch       lda CC_WASprtType,x             ; 00=Player 01=Spark 02=Force 03=Mummy 04=Beam 05=Frank
                    bne ForceFiSwitchX
                    
                    lda CC_WASprtJoyActn,x
                    beq ForceFiSwitchX
                    
                    lda #$0c
                    sta SFX_ForcePngTone            ; vary sound
                    
                    lda #NoSndForcePing             ; sound: Close Force Field Ping - $02
                    jsr InitSoundFX
                    
                    lda CC_WAObjsFlag,y
                    ora Mask_40_b                   ; action completed - CC_WAObjsReady
                    sta CC_WAObjsFlag,y
                    
                    lda #$1e
                    sta CC_ObjStFoSecond,y          ; init second counter
                    lda #CC_FoTimerStart
                    sta CC_ObjStFoTimer,y
                    
                    lda #$55                        ; .#.#.#.# - pattern force field switch timer square
                    sta DatObjFoFiTime01
                    sta DatObjFoFiTime02
                    sta DatObjFoFiTime03
                    sta DatObjFoFiTime04
                    sta DatObjFoFiTime05
                    sta DatObjFoFiTime06
                    sta DatObjFoFiTime07
                    sta DatObjFoFiTime08
                    
                    lda CC_WAObjsPosX,y
                    sta PrmPntObj1PosX
                    lda CC_WAObjsPosY,y
                    sta PrmPntObj1PosY
                    
                    lda CC_WAObjsNo,y
                    sta PrmPntObj1No
                    lda #$01
                    sta PrmPntObj_Type
                    
.PaintSwitch        jsr PaintObject
                    
                    lda CC_ObjStFoNo,y
                    tay
                    lda #$00
                    sta TabFFActive,y
                    
ForceFiSwitchX      jmp RetObjMoveManu
; ------------------------------------------------------------------------------------------------------------- ;
; RoomForceFi       Function: Paint a chambers force fields - Called from: PaintRoomItems
;                   Parms   : Pointer ($3e/$3f) to CC_ForceField of CC_LvlGame
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
RoomForceFi         pha
                    tya
                    pha
                    txa
                    pha
                    
                    lda #$00
                    sta WrkForceFieldNo
                    
.NextForceField     ldy #CC_FFSwitchPosX
                    lda ($3e),y                     ; ForceDataPtr
                    bne .ForceField
                    
                    inc $3e
                    bne .Exit
                    inc $3f                         ; ($3e/$3f) point behind EndOfForceFieldData
                    
.Exit               jmp RoomForceFiX
                    
.ForceField         jsr ObjectInitWA                ; XR=ObjectWAOffset
                    
                    lda #CC_ObjForce
                    sta CC_WAObjsType,x
                    
                    ldy #CC_FFSwitchPosX
                    lda ($3e),y                     ; ForceDataPtr
                    sta PrmPntObj0PosX
                    ldy #CC_FFSwitchPosY
                    lda ($3e),y                     ; ForceDataPtr
                    sta PrmPntObj0PosY
                    
                    lda #NoObjLoFiSwitch            ; object: Force Field Switch - $3f
                    sta PrmPntObj0No
                    lda #$00
                    sta PrmPntObj_Type
                    
.PaintSwitch        jsr PaintObject
                    
                    clc
                    lda PrmPntObj0PosX
                    adc #$04
                    sta PrmPntObj0PosX
                    clc
                    lda PrmPntObj0PosY
                    adc #$08
                    sta PrmPntObj0PosY
                    
                    lda #NoObjLoFiTimer             ; object: Force Field Timer Square - $40
                    sta PrmPntObj0No
                    
                    ldy #$07
                    lda #$55
.ColorTimer         sta DatObjFoFiTime01,y
                    dey
                    bpl .ColorTimer
                    
.PaintTimer         jsr PaintWAObjTyp0
                    
                    lda WrkForceFieldNo
                    sta CC_ObjStFoNo,x
                    tay
                    lda #$01
                    sta TabFFActive,y
                    
                    jsr InitSprtForce
                    
                    ldy #CC_FFFieldPosX
                    lda ($3e),y                     ; ForceDataPtr
                    sta PrmPntObj0PosX
                    ldy #CC_FFFieldPosY
                    lda ($3e),y                     ; ForceDataPtr
                    sta PrmPntObj0PosY
                    
                    lda #NoObjLoFiHead              ; object: Force Field Head - $3e
                    sta PrmPntObj0No
                    lda #$00
                    sta PrmPntObj_Type
                    
.PaintHead          jsr PaintObject
                    
                    inc WrkForceFieldNo
                    
                    clc
                    lda $3e
                    adc #CC_ForceFieldLen           ; $04 = force field data entry length
                    sta $3e
                    bcc .GoForceField
                    inc $3f
                    
.GoForceField       jmp .NextForceField
                    
RoomForceFiX        pla
                    tax
                    pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
WrkForceFieldNo     .byte $ba
TabFFActive         .byte $a0
                    .byte $a4
                    .byte $b2
                    .byte $fe
                    .byte $a0
                    .byte $a0
TabFFPingHeight     .byte $3a
                    .byte $39
                    .byte $37
                    .byte $35
                    .byte $33
                    .byte $32
                    .byte $30
                    .byte $2e
; ------------------------------------------------------------------------------------------------------------- ;
; MummyBirth        Function: - Called from: ObjectHandler
;                   Parms   : xr=Object status area offset ($00, $08, $10, $18, ...)
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
MummyBirth          lda WrkCountActions             ; counter ActionHandler routine calls
                    and #$03
                    bne MummyBirthX                 ; no switch yet
                    
                    dec CC_ObjStMuTimer,x
                    bne .ChkColor
                    
                    lda CC_WAObjsFlag,x
                    eor Mask_40_b                   ; action completed - CC_WAObjsReady
                    sta CC_WAObjsFlag,x
                    jmp .AnkhBlue
                    
.ChkColor           lda CC_ObjStMuAColor,x
                    cmp #$66                        ; blue
                    bne .AnkhBlue
                    
.AnkhWhite          lda #$11                        ; white
                    jmp .AnkhSetColorI
                    
.AnkhBlue           lda #$66                        ; blue
.AnkhSetColorI      ldy #$05
.AnkhSetColor       sta ColObjMummyAnkh,y
                    dey
                    bpl .AnkhSetColor
                    
                    sta CC_ObjStMuAColor,x
                    lda CC_WAObjsPosX,x
                    sta PrmPntObj0PosX
                    lda CC_WAObjsPosY,x
                    sta PrmPntObj0PosY
                    lda CC_WAObjsNo,x
                    sta PrmPntObj0No
                    
.PaintAnkh          jsr PaintWAObjTyp0
                    
MummyBirthX         jmp RetObjMoveAuto
; ------------------------------------------------------------------------------------------------------------- ;
; MummyTouchAnkh    Function: - called from: SprtBkgrHandler
;                   Parms   : xr=Sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                           : yr=Status work area block offset 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
MummyTouchAnkh      stx SavMuPtrSprtWA
                    sty SavMuPtrObjStWa
                    
                    lda CC_WASprtType,x             ; 00=Player 01=Spark 02=Force 03=Mummy 04=Beam 05=Frank
                    bne .Exit                       ; no player
                    
                    clc
                    lda CC_WASprtPosX,x
                    adc CC_WASprtStepX,x
                    sec
                    sbc CC_WAObjsPosX,y
                    cmp #$08
                    bcs .Exit
                    
                    clc
                    lda SavMumDataPtrLo
                    adc CC_ObjStMuPtrWA,y
                    sta $40
                    lda SavMumDataPtrHi
                    adc #$00
                    sta $41
                    
                    ldy #CC_MummyStatus
                    lda ($40),y                     ; CC_RoomDoorPtr
                    cmp #CC_MummyIn
                    beq .Birth
                    
.Exit               jmp MummyTouchAnkhX
                    
.Birth              lda #CC_MummyOut
                    ldy #CC_MummyStatus
                    sta ($40),y                     ; CC_RoomDoorPtr
                    
                    clc
                    ldy #CC_MummyWallPosX
                    lda ($40),y                     ; CC_RoomDoorPtr
                    adc #$04
                    ldy #CC_MummySprtPosX
                    sta ($40),y                     ; CC_RoomDoorPtr
                    
                    clc
                    ldy #CC_MummyWallPosY
                    lda ($40),y                     ; CC_RoomDoorPtr
                    adc #$07
                    ldy #CC_MummySprtPosY
                    sta ($40),y                     ; CC_RoomDoorPtr
                    
                    ldy SavMuPtrObjStWa
                    lda CC_WAObjsFlag,y
                    ora Mask_40_b                   ; action completed - CC_WAObjsReady
                    sta CC_WAObjsFlag,y
                    
                    lda #CC_MuTimerStart
                    sta CC_ObjStMuTimer,y
                    
                    lda #$66
                    sta CC_ObjStMuAColor,y
                    
                    ldy #CC_MummyWallPosX
                    lda ($40),y                     ; CC_RoomDoorPtr
                    clc
                    adc #$04
                    sta PrmPntObj1PosX
                    
                    ldy #CC_MummyWallPosY
                    lda ($40),y                     ; CC_RoomDoorPtr
                    clc
                    adc #$08
                    sta PrmPntObj1PosY
                    
                    lda #$03
                    sta WrkMuWallRows
                    
                    lda #NoObjMummyWall             ; object: Mummy Wall Brick - $42
                    sta PrmPntObj1No
                    lda #$01
                    sta PrmPntObj_Type
                    
.PaintWall          jsr PaintObject
                    
                    clc
                    lda PrmPntObj1PosX
                    adc #$04
                    sta PrmPntObj1PosX
                    dec WrkMuWallRows
                    bne .PaintWall
                    
                    lda #NoObjMummyOut              ; object: Mummy Wall Open  - $43
                    sta PrmPntObj0No
                    
                    sec
                    lda PrmPntObj1PosX
                    sbc #$0c
                    sta PrmPntObj0PosX
                    lda PrmPntObj1PosY
                    sta PrmPntObj0PosY
                    lda #$00
                    sta PrmPntObj_Type
                    
.PaintOpening       jsr PaintObject
                    
                    ldx SavMuPtrObjStWa
                    lda #$00
                    jsr InitSprtMummy
                    
MummyTouchAnkhX     ldx SavMuPtrSprtWA
                    ldy SavMuPtrObjStWa
                    jmp RetObjMoveManu
; ------------------------------------------------------------------------------------------------------------- ;
SavMuPtrSprtWA      .byte $ff
SavMuPtrObjStWa     .byte $a0
WrkMuWallRows       .byte $b5
; ------------------------------------------------------------------------------------------------------------- ;
; RoomMummy         Function: Paint a chambers mummies - Called from: PaintRoomItems
;                   Parms   : Pointer ($3e/$3f) to CC_Mummy of CC_LvlGame
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
RoomMummy           pha
                    tya
                    pha
                    txa
                    pha
                    
                    lda #$00
                    sta PtrMumWorkData
                    
                    lda $3e
                    sta SavMumDataPtrLo
                    lda $3f
                    sta SavMumDataPtrHi
                    
.NextMummy          ldy #CC_Mummy
                    lda ($3e),y                     ; MummyDataPtr
                    cmp #$00
                    bne .Mummy
                    
                    inc $3e
                    bne .Exit
                    inc $3f                         ; ($3e/$3f) point behind EndOfMummyData
                    
.Exit               jmp RoomMummyX
                    
.Mummy              jsr ObjectInitWA                ; XR=ObjectWAOffset
                    
                    lda #CC_ObjMummy
                    sta CC_WAObjsType,x
                    
                    ldy #CC_MummyAnkhPosX
                    lda ($3e),y                     ; MummyDataPtr
                    sta PrmPntObj0PosX
                    ldy #CC_MummyAnkhPosY
                    lda ($3e),y                     ; MummyDataPtr
                    sta PrmPntObj0PosY
                    
                    lda #NoObjMummyAnkh             ; object: Mummy Ankh - $44
                    sta PrmPntObj0No
                    lda PtrMumWorkData
                    sta CC_ObjStMuPtrWA,x
                    
                    ldy #$05
                    lda #$66                        ; blue
                    sta CC_ObjStMuAColor,x
.ColorAnkh          sta ColObjMummyAnkh,y
                    dey
                    bpl .ColorAnkh
                    
.PaintAnkh          jsr PaintWAObjTyp0
                    
                    lda #$03
                    sta WrkMumWallRows              ; 3 brick rows per wall
                    
                    ldy #CC_MummyWallPosY
                    lda ($3e),y                     ; MummyDataPtr
                    sta PrmPntObj0PosY
                    lda #$00
                    sta PrmPntObj_Type
                    
                    lda #NoObjMummyWall             ; object: Mummy Wall Brick - $42
                    sta PrmPntObj0No
                    
.PaintWallRowI      lda #$05
                    sta WrkMumWallBricks            ; 5 bricks per row
                    ldy #CC_MummyWallPosX
                    lda ($3e),y                     ; MummyDataPtr
                    sta PrmPntObj0PosX
                    
.PaintWallBrick     jsr PaintObject
                    
                    clc
                    lda PrmPntObj0PosX
                    adc #$04
                    sta PrmPntObj0PosX
                    
                    dec WrkMumWallBricks
                    bne .PaintWallBrick
                    
                    clc
                    lda PrmPntObj0PosY
                    adc #$08
                    sta PrmPntObj0PosY
                    
                    dec WrkMumWallRows
                    bne .PaintWallRowI
                    
                    ldy #CC_MummyStatus             ; $01=in  $02=out $04=dead
                    lda ($3e),y                     ; MummyDataPtr
                    cmp #CC_MummyIn
                    beq .MummyIn
                    
                    ldy #CC_MummyWallPosX
                    lda ($3e),y                     ; MummyDataPtr
                    clc
                    adc #$04
                    sta PrmPntObj1PosX
                    ldy #CC_MummyWallPosY
                    lda ($3e),y                     ; MummyDataPtr
                    clc
                    adc #$08
                    sta PrmPntObj1PosY
                    
                    lda #$01
                    sta PrmPntObj_Type
                    lda #NoObjMummyWall             ; object: Mummy Wall Brick - $42
                    sta PrmPntObj1No
                    
                    lda #$03
                    sta WrkMumWallRows              ; 3 brick rows per wall
                    
.PaintOpenBrick     jsr PaintObject
                    
                    clc
                    lda PrmPntObj1PosX
                    adc #$04
                    sta PrmPntObj1PosX
                    
                    dec WrkMumWallRows
                    bne .PaintOpenBrick
                    
                    lda PrmPntObj1PosX
                    sec
                    sbc #$0c
                    sta PrmPntObj0PosX
                    lda PrmPntObj1PosY
                    sta PrmPntObj0PosY
                    
                    lda #NoObjMummyOut              ; object: Mummy Wall Open - $43
                    sta PrmPntObj0No
                    lda #$00
                    sta PrmPntObj_Type
                    
.PaintWallOpen      jsr PaintObject
                    
                    ldy #CC_MummyStatus             ; $01=in  $02=out $04=dead
                    lda ($3e),y                     ; MummyDataPtr
                    cmp #CC_MummyOut
                    bne .MummyIn
                    
.MummyOut           lda #$ff
                    jsr InitSprtMummy
                    
.MummyIn            lda $3e
                    clc
                    adc #CC_MummyLen                ; $07 = mummy data entry length
                    sta $3e
                    bcc .GoNextMummy
                    inc $3f
                    
.GoNextMummy        clc
                    lda PtrMumWorkData
                    adc #$07
                    sta PtrMumWorkData
                    jmp .NextMummy
                    
RoomMummyX          pla
                    tax
                    pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
SavMumDataPtrLo     .byte $a0
SavMumDataPtrHi     .byte $cc
PtrMumWorkData      .byte $a5
WrkMumWallRows      .byte $90
WrkMumWallBricks    .byte $a0
; ------------------------------------------------------------------------------------------------------------- ;
; KeyPickUp         Function: - called from: SprtBkgrHandler
;                   Parms   : xr=Sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                           : yr=Status work area block offset 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
KeyPickUp           sty SavKeyPtrStWA
                    lda CC_WASprtType,x             ; 00=Player 01=Spark 02=Force 03=Mummy 04=Beam 05=Frank
                    bne KeyPickUpX                  ; no player
                    
                    ldy CC_WASprtPlayrNo,x
                    lda CC_LvlP_Status,y
                    cmp #CC_LVLP_Survive
                    bne KeyPickUpX
                    
                    lda CC_WASprtJoyActn,x
                    beq KeyPickUpX
                    
                    lda #NoSndKeyPing               ; sound: Pick Up Key Ping - $0c
                    jsr InitSoundFX
                    
                    ldy SavKeyPtrStWA
                    lda CC_WAObjsFlag,y
                    ora Mask_20_b                   ; move - CC_WAObjsMove
                    sta CC_WAObjsFlag,y
                    
                    clc
                    lda SavKeyDataPtrLo
                    adc CC_ObjStKeData,y
                    sta $40
                    lda SavKeyDataPtrHi
                    adc #$00
                    sta $41
                    
                    ldy #CC_KeyStatus
                    lda #CC_KeyAway
                    sta ($40),y
                    
                    ldy #CC_KeyColor
                    lda ($40),y
                    sta PtrKeyWorkData
                    
                    lda CC_WASprtPlayrNo,x
                    beq .Player1
                    
.Player2            ldy CC_LvlP2KeyAmnt             ; $7814 : count start: 01
                    inc CC_LvlP2KeyAmnt             ; $7814 : count start: 01
                    lda PtrKeyWorkData
                    sta CC_LvlP2KeyColct,y          ; $7835 : 7 entries - stored unsorted as they were collected
                    jmp KeyPickUpX
                    
.Player1            ldy CC_LvlP1KeyAmnt             ; $7813 : count start: 01
                    inc CC_LvlP1KeyAmnt             ; $7813 : count start: 01
                    lda PtrKeyWorkData
                    sta CC_LvlP1KeyColct,y          ; $7815 : 7 entries - stored unsorted as they were collected
                    
KeyPickUpX          jmp RetObjMoveManu
; ------------------------------------------------------------------------------------------------------------- ;
; RoomKey           Function: Paint a chambers keys - Called from: PaintRoomItems
;                   Parms   : Pointer ($3e/$3f) to CC_Key of CC_LvlGame
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
RoomKey             pha
                    tya
                    pha
                    txa
                    pha
                    
                    lda $3e
                    sta SavKeyDataPtrLo
                    lda $3f
                    sta SavKeyDataPtrHi
                    
                    lda #$00
                    sta PtrKeyWorkData
                    
.NextKey            ldy #CC_Key
                    lda ($3e),y                     ; KeyDataPtr
                    bne .Key
                    
                    inc $3e
                    bne .Exit
                    inc $3f                         ; ($3e/$3f) point behind EndOfKeyData
                    
.Exit               jmp RoomKeyX
                    
.Key                ldy #CC_KeyStatus
                    lda ($3e),y                     ; DoorDataPtr
                    beq .SetNextKeyWAPos
                    
                    jsr ObjectInitWA                ; XR=ObjectWAOffset
                    
                    lda #CC_ObjKey
                    sta CC_WAObjsType,x
                    
                    ldy #CC_KeyPosX
                    lda ($3e),y                     ; KeyDataPtr
                    sta PrmPntObj0PosX
                    ldy #CC_KeyPosY
                    lda ($3e),y                     ; KeyDataPtr
                    sta PrmPntObj0PosY
                    
                    ldy #CC_KeyStatus
                    lda ($3e),y                     ; KeyDataPtr
; ------------------------------------------------------------------------------------------------------------- ;
; Reason  : Make Key Object Definitions moveable
; Solution: Recalc the old key no $51-$57 which are coming from the castles data file
;         : to the new object numbers starting with: NoObjKeyTab
; ID      : .hbu001.
; ------------------------------------------------------------------------------------------------------------- ;                  
                    and #$0f                        ; .hbu001. - isolate colors
                    sec                             ; .hbu001.
                    adc #NoObjKeyTab                ; .hbu001. - add new offset

                    sta PrmPntObj0No                ; object: Keys 1-7
                    lda PtrKeyWorkData
                    sta CC_ObjStKeData,x
                    
.PaintKey           jsr PaintWAObjTyp0
                    
.SetNextKeyWAPos    clc
                    lda PtrKeyWorkData
                    adc #$04
                    sta PtrKeyWorkData
                    
                    clc
                    lda $3e
                    adc #CC_KeyLen                  ; $04 = key data entry length
                    sta $3e
                    bcc .NextKey
                    inc $3f
                    jmp .NextKey
                    
RoomKeyX            pla
                    tax
                    pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
PtrKeyWorkData      .byte $a0
SavKeyDataPtrLo     .byte $98
SavKeyDataPtrHi     .byte $a0
SavKeyPtrStWA       .byte $a0
; ------------------------------------------------------------------------------------------------------------- ;
; LockOpen          Function: - called from: SprtBkgrHandler
;                   Parms   : xr=Sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                           : yr=Status work area block offset 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
LockOpen            stx SavPtrLockWA
                    lda CC_WASprtType,x             ; 00=Player 01=Spark 02=Force 03=Mummy 04=Beam 05=Frank
                    bne LockOpenX                   ; no player
                    
                    lda CC_WASprtPlayrNo,x
                    tax
                    lda CC_LvlP_Status,x
                    cmp #CC_LVLP_Survive
                    bne LockOpenX
                    
                    ldx SavPtrLockWA
                    lda CC_WASprtJoyActn,x
                    beq LockOpenX
                    
                    lda CC_ObjStLoColor,y
                    jsr ChkKeyList
                    bcs LockOpenX                   ; key not yet collected
                    
                    ldx #$00
.SearchWA           lda CC_WAObjsType,x
                    bne .SetNextWA
                    
                    lda CC_ObjStDoNo,x              ;   door number
                    cmp CC_ObjStLoDoorNo,y          ; = lock door number
                    beq .Found
                    
.SetNextWA          txa
                    clc
                    adc #$08
                    tax
                    jmp .SearchWA
                    
.Found              lda CC_ObjStLoDoorNo,x
                    bne LockOpenX
                    
                    lda CC_WAObjsFlag,x
                    ora Mask_40_b                   ; action completed - CC_WAObjsReady
                    sta CC_WAObjsFlag,x
                    
LockOpenX           ldx SavPtrLockWA
                    jmp RetObjMoveManu
; ------------------------------------------------------------------------------------------------------------- ;
; RoomLock          Function: Paint a chambers locks - Called from: PaintRoomItems
;                   Parms   : Pointer ($3e/$3f) to CC_Lock of CC_LvlGame
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
RoomLock            pha
                    tya
                    pha
                    txa
                    pha
                    
.NextLock           ldy #$00
                    lda ($3e),y                     ; LockDataPtr
                    beq .Exit
                    
                    jsr ObjectInitWA                ; XR=ObjectWAOffset
                    
                    lda #CC_ObjLock
                    sta CC_WAObjsType,x
                    
                    ldy #CC_LockPosX
                    lda ($3e),y                     ; LockDataPtr
                    sta PrmPntObj0PosX
                    ldy #CC_LockPosY
                    lda ($3e),y                     ; LockDataPtr
                    sta PrmPntObj0PosY
                    
                    ldy #CC_LockColor
                    lda ($3e),y                     ; LockDataPtr
                    asl a
                    asl a
                    asl a
                    asl a
                    ora ($3e),y                     ; LockDataPtr
                    
                    ldy #$08
.ColorLock          sta ColObjLock,y
                    dey
                    bpl .ColorLock
                    
                    lda #NoObjLock                  ; object: Lock - $58
                    sta PrmPntObj0No
                    
                    ldy #CC_LockColor
                    lda ($3e),y                     ; LockDataPtr
                    sta CC_ObjStLoColor,x
                    ldy #CC_LockForDoor
                    lda ($3e),y                     ; LockDataPtr
                    sta CC_ObjStLoDoorNo,x
                    
.PaintLock          jsr PaintWAObjTyp0
                    
                    clc
                    lda $3e
                    adc #CC_LockLen                 ; $05 = lock data entry length
                    sta $3e
                    bcc .NextLock
                    inc $3f
                    jmp .NextLock
                    
.Exit               inc $3e
                    bne RoomLockX
                    inc $3f
                    
RoomLockX           pla
                    tax
                    pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
SavPtrLockWA        .byte $c2
; ------------------------------------------------------------------------------------------------------------- ;
; RayGunMove        Function: - Called from: ObjectHandler
;                   Parms   : xr=Object status area offset ($00, $08, $10, $18, ...)
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
RayGunMove          lda WrkCountActions             ; counter ActionHandler routine calls
                    and #$03
                    beq .Gun
                    
.Exit               jmp RayGunMoveX
                    
.Gun                clc
                    lda SavGunDataPtrLo
                    adc CC_ObjStGuPtrWA,x
                    sta $40
                    lda SavGunDataPtrHi
                    adc #$00
                    sta $41
                    
                    lda CC_WAObjsFlag,x
                    bit Mask_80_b                   ; initialized only - CC_WAObjsInit
                    beq .ChkDemo
                    
                    jmp .SetPos
                    
.ChkDemo            lda FlgRoomLoadAdr              ; $00=$7800 $01=$9800 $02=$b800
                    cmp #CC_LvlStorID
                    beq .Exit                       ; demo
                    
                    ldy #CC_GunDirection
                    lda ($40),y
                    bit Mask_20_d                   ; CC_Stop
                    bne .ChkMoveUp
                    
                    lda #$ff
                    sta PtrGunWorkData
                    lda #$00
                    sta WrkGunMoveDir
                    
                    lda #$01                        ; start with player 2
                    sta WrkGunPlayerNo
.SetGunMoveDir      ldy WrkGunPlayerNo
                    lda CC_LvlP_Status,y
                    cmp #CC_LVLP_Survive
                    bne .SetNextPlayer
                    
                    lda SavP_OffSprWA,y
                    tay
                    sec
                    lda CC_WASprtPosY,y
                    sbc CC_WAObjsPosY,x
                    bcs .ChkGunPos                  ; still positive
                    
                    eor #$ff                        ; negative: flip bits and ...
                    adc #$01                        ; ... add 1 = switch negative sign
                    
.ChkGunPos          cmp PtrGunWorkData
                    bcs .SetNextPlayer
                    
                    sta PtrGunWorkData
                    
                    lda CC_WASprtPosY,y
                    cmp #$c8
                    bcs .SetGunMoveUp
                    
                    cmp CC_WAObjsPosY,x
                    bcs .SetGunMoveDown
                    
.SetGunMoveUp       lda Mask_04_d                   ; CC_GunMoveUp   - player 1 wins if still alive
                    sta WrkGunMoveDir
                    jmp .SetNextPlayer
                    
.SetGunMoveDown     lda Mask_02_d                   ; CC_GunMoveDown - player 1 wins if still alive
                    sta WrkGunMoveDir
                    
.SetNextPlayer      dec WrkGunPlayerNo
                    bpl .SetGunMoveDir
                    
                    lda #$ff
                    eor Mask_04_d                   ; CC_GunMoveUp
                    eor Mask_02_d                   ; CC_GunMoveDown
                    
                    ldy #CC_GunDirection
                    and ($40),y                     ; CC_GunDataPtr
                    ora WrkGunMoveDir 
                    sta ($40),y                     ; CC_GunDataPtr
                    
.ChkMoveUp          ldy #CC_GunDirection
                    lda ($40),y                     ; CC_GunDataPtr
                    bit Mask_04_d
                    beq .ChkMoveDown
                    
                    ldy #CC_GunPosY
                    lda ($40),y                     ; CC_GunDataPtr
                    ldy #CC_GunPolePosY
                    cmp ($40),y                     ; CC_GunDataPtr
                    beq .MoveStop
                    
.Up                 sec
                    sbc #$01
                    ldy #CC_GunPosY
                    sta ($40),y                     ; CC_GunDataPtr
                    
                    lda #$5c                        ; gun moves up: control - green/grey
                    jsr ColorGunSwitch
                    jmp .SetPos
                    
.ChkMoveDown        bit Mask_02_d                   ; CC_GunMoveDown
                    bne .MoveDown
                    
.MoveStop           lda #$cc                        ; gun has stopped: control - grey/grey
                    jsr ColorGunSwitch
                    jmp .Stop
                    
.MoveDown           ldy #CC_GunPosY
                    lda ($40),y                     ; CC_GunDataPtr
                    cmp CC_ObjStGuBoP,x             ; BottomOfPole
                    bcs .MoveStop
                    
.Down               clc
                    adc #$01
                    sta ($40),y                     ; CC_GunDataPtr
                    
                    lda #$c2                        ; gun moves down: control - grey/red
                    jsr ColorGunSwitch
                    
.SetPos             lda CC_WAObjsPosX,x
                    sta PrmPntObj0PosX
                    
                    ldy #CC_GunPosY
                    lda ($40),y                     ; CC_GunDataPtr
                    sta PrmPntObj0PosY
                    
                    ldy #CC_GunDirection
                    lda ($40),y                     ; CC_GunDataPtr
                    bit Mask_01_d                   ; CC_GunPointLeft - Bit0=0: point right  Bit0=1:point left 
                    beq .TabGunObjNoRi
                    
.TabGunObjNoLe      lda #$04                        ; table offset to left  gun object numbers
                    jmp .SetMoveDir
                    
.TabGunObjNoRi      lda #$00                        ; table offset to right gun object numbers
.SetMoveDir         sta WrkGunMoveDir
                    
                    ldy #CC_GunPosY
                    lda ($40),y                     ; CC_GunDataPtr
                    and #$03
                    ora WrkGunMoveDir
                    tay
                    lda TabGunObjNo,y
                    sta PrmPntObj0No
                    
.PaintGun           jsr PaintWAObjTyp0
                    
.Stop               ldy #CC_GunDirection
                    lda ($40),y                     ; CC_GunDataPtr
                    bit Mask_20_d                   ; CC_GunMoveStop
                    beq .ChkMax
                    
                    eor Mask_20_d                   ; CC_GunMoveStop
                    sta ($40),y                     ; CC_GunDataPtr
                    bit Mask_08_d                   ; CC_GunMoveFire - player pressed the gun control
                    bne .ChkFire
                    
                    jmp RayGunMoveX
                    
.ChkMax             lda PtrGunWorkData              ; max six guns allowed
                    cmp #$05
                    bcs RayGunMoveX
                    
.ChkFire            ldy #CC_GunDirection
                    lda ($40),y                     ; CC_GunDataPtr
                    bit Mask_40_d                   ; CC_GunShoots
                    bne RayGunMoveX
                    
.Fire               jsr InitSprtBeam
                    
                    ora Mask_40_d                   ; CC_GunShoots
                    sta ($40),y                     ; CC_GunDataPtr
                    
RayGunMoveX         jmp RetObjMoveAuto
; ------------------------------------------------------------------------------------------------------------- ;
; RoomGun           Function: Paint a chambers ray guns - Called from: PaintRoomItems
;                   Parms   : Pointer ($3e/$3f) to CC_Gun of CC_LvlGame
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
RoomGun             pha
                    tya
                    pha
                    txa
                    pha
                    
                    lda $3e
                    sta SavGunDataPtrLo
                    lda $3f
                    sta SavGunDataPtrHi
                    
                    lda #$00
                    sta PtrGunWorkData
                    
.NextGun            ldy #CC_Gun
                    lda ($3e),y                     ; GunDataPtr
                    bit Mask_80_d
                    beq .Gun
                    
                    inc $3e
                    bne .Exit
                    inc $3f                         ; ($3e/$3f) point behind EndOfRayGunData
                    
.Exit               jmp RoomGunX
                    
.Gun                lda #$ff                        ; senseless - results in $00/$01 as before
                    eor Mask_40_d
                    and ($3e),y                     ; CC_GunDirection
                    sta ($3e),y                     ; CC_GunDirection
                    
                    ldy #CC_GunPolePosX
                    lda ($3e),y                     ; GunDataPtr
                    sta PrmPntObj0PosX
                    ldy #CC_GunPolePosY
                    lda ($3e),y                     ; GunDataPtr
                    sta PrmPntObj0PosY
                    
                    lda #$00
                    sta PrmPntObj_Type
                    
                    ldy #CC_GunDirection
                    lda ($3e),y                     ; GunDataPtr
                    bit Mask_01_d
                    bne .PoleLeft
                    
.PoleRight          lda #NoObjGunPoleRi             ; object: Ray Gun Pole for Shooting Right - $60
                    jmp .SetGunPole
                    
.PoleLeft           lda #NoObjGunPoleLe             ; object: Ray Gun Pole for Shooting Left  - $5f
.SetGunPole         sta PrmPntObj0No
                    
                    ldy #CC_GunPoleLength
                    lda ($3e),y                     ; GunDataPtr
                    sta WrkGunPoleLength
                    
.Pole               lda WrkGunPoleLength
                    beq .ChkWa
                    
                    jsr PaintObject
                    
                    clc
                    lda PrmPntObj0PosY
                    adc #$08
                    sta PrmPntObj0PosY
                    
                    dec WrkGunPoleLength
                    jmp .Pole
                    
.ChkWa              ldy #CC_GunDirection
                    lda ($3e),y                     ; GunDataPtr
                    bit Mask_10_d
                    bne .SetWrkSwitch
                    
.SetWrkGun          jsr ObjectInitWA                ; XR=ObjectWAOffset
                    
                    lda #CC_ObjGun
                    sta CC_WAObjsType,x
                    
                    lda PtrGunWorkData
                    sta CC_ObjStGuPtrWA,x
                    lda CC_WAObjsFlag,x
                    ora Mask_40_b                   ; action completed - CC_WAObjsReady
                    sta CC_WAObjsFlag,x
                    
                    ldy #CC_GunPoleLength
                    lda ($3e),y                     ; GunDataPtr
                    asl a
                    asl a
                    asl a                           ; *8
                    ldy #CC_GunPolePosY
                    clc
                    adc ($3e),y                     ; GunDataPtr
                    sec
                    sbc #$0b
                    sta CC_ObjStGuBoP,x             ; save BottomOfPole
                    
                    ldy #CC_GunDirection
                    lda ($3e),y                     ; GunDataPtr
                    bit Mask_01_d
                    bne .GunPosLeft
                    
.GunPosRight        clc
                    ldy #CC_GunPolePosX
                    lda ($3e),y                     ; GunDataPtr
                    adc #$04
                    jmp .SetGunPos
                    
.GunPosLeft         sec
                    ldy #CC_GunPolePosX
                    lda ($3e),y                     ; GunDataPtr
                    sbc #$08
                    
.SetGunPos          sta CC_WAObjsPosX,x
                    
.SetWrkSwitch       jsr ObjectInitWA                ; XR=ObjectWAOffset
                    
                    lda #CC_ObjGunCtrl
                    sta CC_WAObjsType,x
                    
                    ldy #CC_GunSwitchPosX
                    lda ($3e),y                     ; GunDataPtr
                    sta PrmPntObj0PosX
                    ldy #CC_GunSwitchPosY
                    lda ($3e),y                     ; GunDataPtr
                    sta PrmPntObj0PosY
                    
                    lda #NoObjGunSwitch             ; object: Ray Gun Operator - $6d
                    sta PrmPntObj0No
                    
.PaintOperator      jsr PaintWAObjTyp0
                    
                    lda PtrGunWorkData
                    sta CC_ObjStGuPtrWA,x
                    
                    clc
                    lda $3e
                    adc #CC_RayGunLen               ; $07 = ray gun data entry length
                    sta $3e
                    bcc .GoNextGun
                    inc $3f
                    
.GoNextGun          clc
                    lda PtrGunWorkData
                    adc #$07
                    sta PtrGunWorkData
                    jmp .NextGun
                    
RoomGunX            pla
                    tax
                    pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
SavGunDataPtrLo     .byte $80
SavGunDataPtrHi     .byte $b7
PtrGunWorkData      .byte $a0
WrkGunPoleLength     = *
WrkGunMoveDir       .byte $80
WrkGunPlayerNo      .byte $c2
                    
Mask_80_d           .byte $80
Mask_40_d           .byte $40
Mask_20_d           .byte $20
Mask_10_d           .byte $10
Mask_08_d           .byte $08
Mask_04_d           .byte $04
Mask_02_d           .byte $02
Mask_01_d           .byte $01
                    
TabGunObjNo         .byte NoObjGunMovRi04           ; object: Ray Gun - Shoot Right Phase 04 - $64
                    .byte NoObjGunMovRi01           ; object: Ray Gun - Shoot Right Phase 01 - $61
                    .byte NoObjGunMovRi02           ; object: Ray Gun - Shoot Right Phase 02 - $62
                    .byte NoObjGunMovRi03           ; object: Ray Gun - Shoot Right Phase 03 - $63
                    
                    .byte NoObjGunMovLe04           ; object: Ray Gun - Shoot Left  Phase 04 - $68
                    .byte NoObjGunMovLe01           ; object: Ray Gun - Shoot Left  Phase 01 - $65
                    .byte NoObjGunMovLe02           ; object: Ray Gun - Shoot Left  Phase 02 - $66
                    .byte NoObjGunMovLe03           ; object: Ray Gun - Shoot Left  Phase 03 - $67
; ------------------------------------------------------------------------------------------------------------- ;
; RayGunSwitch      Function: - called from: SprtBkgrHandler
;                   Parms   : xr=Sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                           : yr=Status work area block offset 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
RayGunSwitch        sty SavGunPtrStWA               ; offset status work area block to handle
                    
                    lda CC_WASprtType,x             ; 00=Player 01=Spark 02=Force 03=Mummy 04=Beam 05=Frank
                    bne RayGunSwitchX               ; no player
                    
                    clc
                    lda CC_WASprtPosX,x
                    adc CC_WASprtStepX,x
                    sec
                    sbc CC_WAObjsPosX,y
                    cmp #$08
                    bcs RayGunSwitchX
                    
                    ldy CC_WASprtPlayrNo,x
                    lda CC_LvlP_Status,y
                    cmp #CC_LVLP_Survive
                    bne RayGunSwitchX
                    
                    ldy SavGunPtrStWA
                    clc
                    lda SavGunDataPtrLo
                    adc CC_ObjStGuPtrWA,y
                    sta $40
                    lda SavGunDataPtrHi
                    adc #$00
                    sta $41
                    
                    lda #$ff
                    eor Mask_04_d                   ; CC_GunMoveUp
                    eor Mask_02_d                   ; CC_GunMoveDown
                    
                    ldy #CC_GunDirection
                    and ($40),y                     ; GunDataPtr
                    ldy CC_WASprtDirMove,x
                    bne .ChkJoyDown                 ; not CC_WAJoyMoveU
                    
.MoveUp             ora Mask_04_d                   ; set CC_GunMoveUp
                    jmp .MoveStop
                    
.ChkJoyDown         cpy #CC_WAJoyMoveD
                    bne .ChkBad
                    
.MoveDown           ora Mask_02_d                   ; set CC_GunMoveDown
                    jmp .MoveStop
                    
.ChkBad             cpy #CC_WAJoyNoMove
                    bne RayGunSwitchX
                    
.MoveStop           ora Mask_20_d                   ; set CC_GunMoveStop
                    
                    ldy #CC_GunDirection
                    sta ($40),y                     ; GunDataPtr
                    
                    lda CC_WASprtJoyActn,x
                    beq .NoFire                     ; CC_WAJoyNoFire
                    
.MoveFire           lda ($40),y                     ; GunDataPtr
                    ora Mask_08_d                   ; set CC_GunMoveFire
                    jmp .SetMove
                    
.NoFire             lda #$ff
                    eor Mask_08_d                   ; CC_GunMoveFire
                    and ($40),y                     ; 
                    
.SetMove            sta ($40),y                     ; GunDataPtr
                    
RayGunSwitchX       jmp RetObjMoveManu
; ------------------------------------------------------------------------------------------------------------- ;
; ColorGunSwitch    Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
ColorGunSwitch      pha
                    sta SavGunCtrlColor
                    tya
                    pha
                    
                    lda SavGunCtrlColor
                    sta ColObjGunOper01
                    sta ColObjGunOper02
                    
                    ldy #CC_GunSwitchPosX
                    lda ($40),y                     ; CC_RoomDoorPtr
                    sta PrmPntObj0PosX
                    ldy #CC_GunSwitchPosY
                    lda ($40),y                     ; CC_RoomDoorPtr
                    sta PrmPntObj0PosY
                    
                    lda #$00
                    sta PrmPntObj_Type
                    lda #NoObjGunOper               ; object: Ray Gun: Operator - $6e
                    sta PrmPntObj0No
                    
.TopArrow           jsr PaintObject
                    
                    lda SavGunCtrlColor
                    asl a
                    asl a
                    asl a
                    asl a                           ; move right to left nibble / right nibble = $0
                    sta ColObjGunOper01
                    sta ColObjGunOper02
                    
                    clc
                    lda PrmPntObj0PosY
                    adc #$10
                    sta PrmPntObj0PosY
                    
.BottomArrow        jsr PaintObject
                    
ColorGunSwitchX     pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
SavGunPtrStWA       .byte $9f
SavGunCtrlColor     .byte $a7
; ------------------------------------------------------------------------------------------------------------- ;
; MatterTrXmit      Function: - Called from: ObjectHandler
;                   Parms   : xr=Object status area offset ($00, $08, $10, $18, ...)
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
MatterTrXmit        lda WrkCountActions             ; counter ActionHandler routine calls
                    and #$01
                    bne MatterTrXmitX
                    
                    jsr Randomizer
                    
                    and #$3f
                    sta SFX_MatterXTone             ; vary sound
                    
                    lda #NoSndMaTrXmit              ; sound: Matter Transmitter Transmit - $04
                    jsr InitSoundFX
                    
                    lda WrkCountActions             ; counter ActionHandler routine calls
                    and #$03
                    beq .GetOvalColor
                    
                    lda #$01                        ; oval flip color white
                    jmp .SetColor
                    
.GetOvalColor       lda CC_ObjStMaColor,x
.SetColor           asl a
                    asl a
                    asl a
                    asl a                       
                    sta DatObjXmitRcOv01
                    sta DatObjXmitRcOv02
                    sta DatObjXmitRcOv03
                    sta DatObjXmitRcOv04
                    
                    lda CC_ObjStMaOvalX,x
                    sta PrmPntObj0PosX
                    lda CC_ObjStMaOvalY,x
                    sta PrmPntObj0PosY
                    
                    lda #$00
                    sta PrmPntObj_Type
                    lda #NoObjXmitRecOv             ; object: Matter Transmitter Receiver Oval - $72
                    sta PrmPntObj0No
                    
.PaintOval          jsr PaintObject
                    
                    lda WrkCountActions             ; counter ActionHandler routine calls
                    and #$03
                    beq .GetBoothColor
                    
                    lda #$00                        ; booth flip color white
                    jmp .PaintBoothBack
                    
.GetBoothColor      lda CC_ObjStMaColor,x
                    
.PaintBoothBack     jsr ColorMTBackWall
                    
                    lda WrkCountActions             ; counter ActionHandler routine calls
                    and #$03
                    bne MatterTrXmitX
                    
                    dec CC_ObjStMaTimer,x
                    bne MatterTrXmitX
                    
                    lda CC_WAObjsFlag,x
                    eor Mask_40_b                   ; action completed - CC_WAObjsReady
                    sta CC_WAObjsFlag,x
                    
MatterTrXmitX       jmp RetObjMoveAuto
; ------------------------------------------------------------------------------------------------------------- ;
; MatterTrBooth     Function: - called from: SprtBkgrHandler
;                   Parms   : xr=Sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                           : yr=Status work area block offset 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
MatterTrBooth       lda CC_WAObjsFlag,y
                    bit Mask_40_b                   ; action completed - CC_WAObjsReady
                    bne .Exit
                    
                    lda CC_WASprtType,x             ; 00=Player 01=Spark 02=Force 03=Mummy 04=Beam 05=Frank
                    bne .Exit                       ; no player
                    
                    sty SavMTPtrStWA
                    
                    ldy CC_WASprtPlayrNo,x
                    lda CC_LvlP_Status,y
                    cmp #CC_LVLP_Survive
                    bne .Exit
                    
                    ldy SavMTPtrStWA
                    lda CC_ObjStMaDPtrHi,y
                    sta $40
                    lda CC_ObjStMaDPtrLo,y
                    sta $41
                    
                    lda CC_WASprtJoyActn,x
                    bne .Transmit
                    
                    lda CC_WASprtDirMove,x
                    bne .Exit                       ; not CC_WAJoyMoveU
                    
                    lda WrkCountActions             ; counter ActionHandler routine calls
                    and #$0f
                    bne .Exit
                    
                    ldy #CC_MTBoothColor
                    lda ($40),y                     ; CC_MTDataPtr
                    
                    clc
                    adc #$01
                    sta ($40),y                     ; CC_MTDataPtr
                    
                    asl a                           ; *2
                    adc #$03                        ; header data length
                    tay                             ; CC_MTRec01PosX
                    lda ($40),y                     ; CC_MTDataPtr
                    bne .SetExitColor
                    
.SetStartColor      lda #$00                        ; init color
                    ldy #CC_MTBoothColor
                    sta ($40),y                     ; CC_MTDataPtr
                    
.SetExitColor       ldy #CC_MTBoothColor
                    lda ($40),y                     ; CC_MTDataPtr
                    clc
                    adc #$32
                    sta SFX_MatterSTone             ; vary sound
                    
                    lda #NoSndMaTrSelect            ; sound: Matter Transmitter Select Receiver Oval - $05
                    jsr InitSoundFX
                    
                    lda ($40),y                     ; CC_MTDataPtr
                    clc
                    adc #$02                        ; bypass black/white
                    stx SavMTBoothColor
                    ldx SavMTPtrStWA
                    
                    jsr ColorMTBackWall
                    
                    ldx SavMTBoothColor
.Exit               jmp MatterTrBoothX
                    
.Transmit           ldy SavMTPtrStWA
                    lda CC_WAObjsFlag,y
                    ora Mask_40_b                   ; action completed - CC_WAObjsReady
                    sta CC_WAObjsFlag,y
                    
                    lda #CC_MaTimerStart
                    sta CC_ObjStMaTimer,y
                    
                    ldy #CC_MTBoothColor
                    lda ($40),y                     ; CC_MTDataPtr
                    clc
                    adc #$02                        ; bypass black/white
                    ldy SavMTPtrStWA
                    sta CC_ObjStMaColor,y
                    
                    ldy #CC_MTBoothColor
                    lda ($40),y                     ; CC_MTDataPtr
                    asl a                           ; *2
                    adc #$03                        ; header data length
                    
.SetTargetOval      tay                             ; CC_MTRec__PosX
                    lda ($40),y                     ; CC_MTDataPtr
                    pha
                    
                    iny                             ; CC_MTRec__PosY
                    lda ($40),y                     ; CC_MTDataPtr
                    ldy SavMTPtrStWA
                    sta CC_ObjStMaOvalY,y
                    clc
                    adc #$07
                    sta CC_WASprtPosY,x
                    pla
                    sta CC_ObjStMaOvalX,y
                    sta CC_WASprtPosX,x
                    
MatterTrBoothX      jmp RetObjMoveManu
; ------------------------------------------------------------------------------------------------------------- ;
; RoomMatter        Function: Paint a chambers matter transmitter - Called from: PaintRoomItems
;                   Parms   : Pointer ($3e/$3f) to CC_Transmitter of CC_LvlGame
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
RoomMatter          pha
                    tya
                    pha
                    txa
                    pha
                    
                    ldy #CC_MTBoothPosX
                    lda ($3e),y                     ; MatterDataPtr
                    sta PrmPntObj1PosX
                    ldy #CC_MTBoothPosY
                    lda ($3e),y                     ; MatterDataPtr
                    clc
                    adc #$18
                    sta PrmPntObj1PosY
                    
                    lda #NoObjFloorMid              ; object: Floor Mid Tile - $1c
                    sta PrmPntObj1No
                    lda #$01
                    sta PrmPntObj_Type
                    lda #$03
                    sta WrkCounter
                    
.PaintFloor         jsr PaintObject
                    
                    clc
                    lda PrmPntObj1PosX
                    adc #$04
                    sta PrmPntObj1PosX
                    dec WrkCounter
                    bne .PaintFloor
                    
                    ldy #CC_MTBoothPosX
                    lda ($3e),y                     ; MatterDataPtr
                    sta PrmPntObj0PosX
                    ldy #CC_MTBoothPosY
                    lda ($3e),y                     ; MatterDataPtr
                    sta PrmPntObj0PosY
                    
                    lda #NoObjXmitBooth             ; object: Matter Transmitter Booth - $6f
                    sta PrmPntObj0No
                    lda #$00
                    sta PrmPntObj_Type
                    
.PaintBooth         jsr PaintObject
                    
                    clc
                    lda PrmPntObj0PosX
                    adc #$0c
                    sta PrmPntObj0PosX
                    clc
                    lda PrmPntObj0PosY
                    adc #$18
                    sta PrmPntObj0PosY
                    
                    lda #NoObjFloorMid              ; object: Floor Mid Tile - $1c
                    sta PrmPntObj0No
                    
                    jsr PaintObject
                    jsr ObjectInitWA                ; XR=ObjectWAOffset
                    
                    lda #CC_ObjMatRecOval
                    sta CC_WAObjsType,x
                    
                    ldy #CC_MTBoothPosX
                    clc
                    lda ($3e),y                     ; MatterDataPtr
                    adc #$04
                    sta PrmPntObj0PosX
                    
                    ldy #CC_MTBoothPosY
                    lda ($3e),y                     ; MatterDataPtr
                    clc
                    adc #$18
                    sta PrmPntObj0PosY
                    
                    lda #NoObjXmit                  ; object: Matter Transmitter - $70
                    sta PrmPntObj0No
                    
                    lda $3e                         ; MatterDataPtrHi
                    sta CC_ObjStMaDPtrHi,x
                    lda $3f                         ; MatterDataPtrLo
                    sta CC_ObjStMaDPtrLo,x          ; save booth data pointer to object work area
                    
                    jsr PaintWAObjTyp0
                    
                    ldy #CC_MTBoothColor
                    lda ($3e),y                     ; MatterDataPtr
                    clc
                    adc #$02                        ; bypass black and white
                    jsr ColorMTBackWall
                    
                    lda #$00
                    sta PrmPntObj_Type
                    lda #NoObjXmitRecOv             ; object: Matter Transmitter Receiver Oval - $72
                    sta PrmPntObj0No
                    
                    lda #$20                        ; color
                    sta WrkCounter
.RecOvals           ldy #CC_MTRec01PosX
                    lda ($3e),y                     ; MatterDataPtr
                    beq .Exit
                    
                    lda WrkCounter
                    sta DatObjXmitRcOv01
                    sta DatObjXmitRcOv02
                    sta DatObjXmitRcOv03
                    sta DatObjXmitRcOv04
                    
                    ldy #CC_MTRec01PosX
                    lda ($3e),y                     ; MatterDataPtr
                    sta PrmPntObj0PosX
                    ldy #CC_MTRec01PosY
                    lda ($3e),y                     ; MatterDataPtr
                    sta PrmPntObj0PosY
                    
.PaintRecOval       jsr PaintObject
                    
                    clc
                    lda $3e
                    adc #CC_XmitOvalLen             ; $02 = xmit receiver oval data entry length
                    sta $3e
                    bcc .NextColor
                    inc $3f
                    
.NextColor          clc
                    lda WrkCounter
                    adc #$10                        ; next color
                    sta WrkCounter
                    jmp .RecOvals
                    
.Exit               clc
                    lda $3e
                    adc #CC_XmitBoothLen + 1        ; $03 = xmit booth data entry length
                    sta $3e
                    bcc RoomMatterX
                    inc $3f
                    
RoomMatterX         pla
                    tax
                    pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
; ColorMTBackWall   Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
ColorMTBackWall     pha
                    sta WrkBackWallColor
                    tya
                    pha
                    
                    lda WrkBackWallColor
                    asl a
                    asl a
                    asl a
                    asl a
                    ora #$0a
                    
                    sta ColObjXmitBack01
                    sta ColObjXmitBack02
                    sta ColObjXmitBack03
                    
                    lda #$0f
                    sta ColObjXmitBack04
                    sta ColObjXmitBack05
                    sta ColObjXmitBack06
                    
                    lda CC_ObjStMaDPtrHi,x          ; saved MatterDataPtrLo
                    sta $40
                    lda CC_ObjStMaDPtrLo,x          ; saved MatterDataPtrHi
                    sta $41                         ; ($40/$41) point to matter transmitter data
                    
                    ldy #CC_MTBoothPosX
                    lda ($40),y                     ; CC_RoomDoorPtr
                    clc
                    adc #$04
                    sta PrmPntObj0PosX
                    ldy #CC_MTBoothPosY
                    lda ($40),y                     ; CC_RoomDoorPtr
                    sta PrmPntObj0PosY
                    
                    lda #$00
                    sta PrmPntObj_Type
                    lda #NoObjXmitBack              ; object: Matter Transmitter Booth Back Wall - $71
                    sta PrmPntObj0No
                    
.PaintBackWall      jsr PaintObject
                    
                    clc
                    lda PrmPntObj0PosY
                    adc #$08
                    sta PrmPntObj0PosY
                    lda #$01
                    sta ColObjXmitBack04
                    sta ColObjXmitBack05
                    sta ColObjXmitBack06
                    
                    jsr PaintObject
                    
                    clc
                    lda PrmPntObj0PosY
                    adc #$08
                    sta PrmPntObj0PosY
                    
                    jsr PaintObject
                    
ColorMTBackWallX    pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
SavMTBoothColor     .byte $a0
SavMTPtrStWA        .byte $ff
WrkCounter          .byte $d5
WrkBackWallColor    .byte $c3
; ------------------------------------------------------------------------------------------------------------- ;
; TrapDoorOpen      Function: - Called from: ObjectHandler
;                   Parms   : xr=Object status area offset ($00, $08, $10, $18, ...)
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
TrapDoorOpen        clc
                    lda CC_ObjStTrOffDat,x
                    adc SavTrapDataPtrLo
                    sta $40
                    lda SavTrapDataPtrHi
                    adc #$00
                    sta $41
                    
                    lda CC_ObjStTrStatus,x
                    beq .ChkOpenMax                 ; CC_TrClosed
                    
.SetNextOpen        ldy #CC_TrapDoorPosX
                    lda ($40),y                     ; CC_TrapDoorDataPtr
                    sta PrmPntObj1PosX
                    ldy #CC_TrapDoorPosY
                    lda ($40),y                     ; CC_TrapDoorDataPtr
                    sta PrmPntObj1PosY
                    lda CC_ObjStTrObjNo,x           ; object: Trap Door Phases
                    sta PrmPntObj1No
                    
                    jsr SetTrapSound
                    
                    lda #$01
                    sta PrmPntObj_Type
                    
.PaintOpen          jsr PaintObject
                    
                    lda CC_ObjStTrObjNo,x
                    cmp #NoObjTrapMovMax            ; object: Trap Door Open Max - $78
                    bne .OpenNext
                    
.SetBase            clc
                    ldy #CC_TrapDoorPosX
                    lda ($40),y                     ; CC_TrapDoorDataPtr
                    adc #$04
                    sta PrmPntObj0PosX
                    ldy #CC_TrapDoorPosY
                    lda ($40),y                     ; CC_TrapDoorDataPtr
                    sta PrmPntObj0PosY
                    lda #NoObjTrapMovBas            ; object: Trap Door Base Line if Open - $79
                    sta PrmPntObj0No
                    
.PaintBase          jsr PaintWAObjTyp0
                    
                    jmp .Complete
                    
.ChkOpenMax         lda CC_ObjStTrObjNo,x
                    cmp #NoObjTrapMovMax            ; object: Trap Door Open Max - $78
                    bne .SetNextClose
                    
                    jsr PaintWAObjTyp1
                    
.SetNextClose       ldy #CC_TrapDoorPosX
                    lda ($40),y                     ; CC_TrapDoorDataPtr
                    sta PrmPntObj0PosX
                    ldy #CC_TrapDoorPosY
                    lda ($40),y                     ; CC_TrapDoorDataPtr
                    sta PrmPntObj0PosY
                    lda CC_ObjStTrObjNo,x           ; object: Trap Door Phases
                    sta PrmPntObj0No
                    
                    jsr SetTrapSound
                    
                    lda #$00
                    sta PrmPntObj_Type
                    
.PaintClose         jsr PaintObject
                    
.ChkCloseMax        lda CC_ObjStTrObjNo,x
                    cmp #NoObjTrapMovMin            ; object: Trap Door Shut Max - $73
                    beq .Complete
                    
.CloseNext          dec CC_ObjStTrObjNo,x           ; shut the door a bit more
                    jmp TrapDoorOpenX
                    
.OpenNext           inc CC_ObjStTrObjNo,x           ; open the door a bit more
                    jmp TrapDoorOpenX
                    
.Complete           lda CC_WAObjsFlag,x
                    eor Mask_40_b                   ; action completed - CC_WAObjsReady
                    sta CC_WAObjsFlag,x
                    
TrapDoorOpenX       jmp RetObjMoveAuto
; ------------------------------------------------------------------------------------------------------------- ;
; SetTrapSound      Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
SetTrapSound        pha
                    
; ------------------------------------------------------------------------------------------------------------- ;
; Reason  : Make Trap Door Open/Close Pase Definitions moveable
; Solution: Switch the tone hight algorithm
; ID      : .hbu002.
; ------------------------------------------------------------------------------------------------------------- ;                  
                    clc                             ; .hbu002.
                    adc #$2b                        ; .hbu002. - add tone hight
                    sec                             ; .hbu002.
                    sbc #NoObjTrapMovMin            ; .hbu002. - subtract min
                    sta SFX_TrapSwTone              ; vary tone
                    
                    lda #NoSndTrapSwitch            ; sound: Trap Door Switch - $01
                    jsr InitSoundFX
                    
SetTrapSoundX       pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
; RoomTrap          Function: Paint a chambers trap doors - Called from: PaintRoomItems
;                   Parms   : Pointer ($3e/$3f) to CC_TrapDoor of CC_LvlGame
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
RoomTrap            pha
                    tya
                    pha
                    txa
                    pha
                    
                    lda $3e
                    sta SavTrapDataPtrLo
                    lda $3f
                    sta SavTrapDataPtrHi
                    
                    lda #$00
                    sta PtrTrapWorkData
                    
.NextTrap           ldy #CC_TrapDoor
                    lda ($3e),y                     ; TrapDoorDataPtr
                    bit Mask_80_e
                    beq .Trap
                    
                    inc $3e
                    bne .Exit
                    inc $3f                         ; ($3e/$3f) point behind EndOfTrapDoorData
                    
.Exit               jmp RoomTrapX
                    
.Trap               jsr ObjectInitWA                ; XR=ObjectWAOffset
                    
                    lda #CC_ObjTrapDoor
                    sta CC_WAObjsType,x
                    lda PtrTrapWorkData
                    sta CC_ObjStTrOffDat,x
                    
                    ldy #CC_TrapMode
                    lda ($3e),y                     ; TrapDoorDataPtr
                    bit Mask_01_e                   ; $00=closed  $01=open
                    bne .TrapOpen
                    
.TrapClosed         lda #$c0                        ; color grey2
                    sta ColObjTrapSw01              ; trap control top
                    lda #$55                        ; color green
                    sta ColObjTrapSw02              ; trap control bottom
                    jmp .TrapCtrl
                    
.TrapOpen           ldy #CC_TrapDoorPosX
                    lda ($3e),y                     ; TrapDoorDataPtr
                    sta PrmPntObj1PosX
                    ldy #CC_TrapDoorPosY
                    lda ($3e),y                     ; TrapDoorDataPtr
                    sta PrmPntObj1PosY
                    
                    lda #$01
                    sta PrmPntObj_Type
                    lda #NoObjTrapOpen              ; object: Trap Door Open - $7b
                    sta PrmPntObj1No
                    
.PaintDoor          jsr PaintObject
                    
                    clc
                    lda PrmPntObj1PosX
                    adc #$04
                    sta PrmPntObj0PosX
                    lda PrmPntObj1PosY
                    sta PrmPntObj0PosY
                    
                    lda #NoObjTrapMovBas            ; object: Trap Door Base Line if Open - $79
                    sta PrmPntObj0No
                    
                    jsr PaintWAObjTyp0
                    
                    lda #$20                        ; color red
                    sta ColObjTrapSw01              ; trap control top
                    lda #$cc                        ; color grey2
                    sta ColObjTrapSw02              ; trap control bottom
                    
                    ldy #CC_TrapDoorPosX
                    lda ($3e),y                     ; TrapDoorDataPtr
                    lsr a
                    lsr a                           ; *4
                    sec
                    sbc #$04
                    sta CtrlScrnColNo
                    
                    ldy #CC_TrapDoorPosY
                    lda ($3e),y                     ; TrapDoorDataPtr
                    lsr a
                    lsr a
                    lsr a                           ; *8
                    sta CtrlScrnRowNo
                    
                    jsr SetCtrlScrnPtr              ; ($3c/$3d) point to control screen output address $c000-$c7ff
                    
                    ldy #$00
                    lda ($3c),y
                    and #CC_CtrlTrapLeft
                    sta ($3c),y                     ; mark trap start - resets floor to CC_CtrlFloorEnd
                    
                    ldy #$04
                    lda ($3c),y
                    and #CC_CtrlTrapRight
                    sta ($3c),y                     ; mark trap end   - resets floor to CC_CtrlFloorStrt
                    
.TrapCtrl           jsr ObjectInitWA                ; XR=ObjectWAOffset
                    
                    lda #CC_ObjTrapCtrl
                    sta CC_WAObjsType,x
                    
                    ldy #CC_TrapCtrlPosX
                    lda ($3e),y                     ; TrapDoorDataPtr
                    sta PrmPntObj0PosX
                    ldy #CC_TrapCtrlPosY
                    lda ($3e),y                     ; TrapDoorDataPtr
                    sta PrmPntObj0PosY
                    
                    lda #NoObjTrapSwitch            ; object: Trap Door Control - $7a
                    sta PrmPntObj0No
                    lda PtrTrapWorkData
                    sta CC_ObjStTrOffDat,x
                    
.PaintControl       jsr PaintWAObjTyp0
                    
                    clc
                    lda PtrTrapWorkData
                    adc #$05
                    sta PtrTrapWorkData
                    
                    clc
                    lda $3e
                    adc #CC_TrapDoorLen             ; $05 = trap door data entry length
                    sta $3e
                    bcc .GoNextTrap
                    inc $3f
                    
.GoNextTrap         jmp .NextTrap
                    
RoomTrapX           pla
                    tax
                    pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
; TrapDoorHandler   Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
TrapDoorHandler     pha
                    sta SavOffTDObjWA
                    tya
                    pha
                    txa
                    pha
                    
                    lda $40
                    sta SavZpg40
                    lda $41
                    sta SavZpg41
                    lda $3c
                    sta SavZpg3c
                    lda $3d
                    sta SavZpg3d
                    
                    clc
                    lda SavTrapDataPtrLo
                    adc SavOffTDObjWA
                    sta $40
                    lda SavTrapDataPtrHi
                    adc #$00
                    sta $41
                    
                    ldy #CC_TrapMode
                    lda ($40),y                     ; CC_TrapdataPtr
                    eor Mask_01_e                   ; flip trap door mode
                    sta ($40),y                     ; CC_TrapdataPtr
                    
                    ldx #$00
.FindTrapWA         lda CC_WAObjsType,x
                    cmp #CC_ObjTrapDoor
                    bne .SetNextObjWA
                    
                    lda CC_ObjStTrOffDat,x
                    cmp SavOffTDObjWA
                    beq .FoundTrapWA
                    
.SetNextObjWA       txa
                    clc
                    adc #CC_ObjWALen
                    tax
                    jmp .FindTrapWA
                    
.FoundTrapWA        lda CC_WAObjsFlag,x
                    ora Mask_40_b                   ; action completed - CC_WAObjsReady
                    sta CC_WAObjsFlag,x
                    
                    ldy #CC_TrapMode
                    lda ($40),y                     ; CC_TrapdataPtr
                    bit Mask_01_e                   ; CC_TrapOpen
                    bne .TrapOpen
                    
.TrapClosed         lda #CC_TrClosed
                    sta CC_ObjStTrStatus,x
                    lda #NoObjTrapMovMax            ; object: Trap Door Shut Complete - $78
                    sta CC_ObjStTrObjNo,x
                    
                    lda #$c0                        ; grey
                    sta ColObjTrapSw01              ; trap control top
                    lda #$55                        ; green
                    sta ColObjTrapSw02              ; trap control bottom
                    
                    ldy #CC_TrapDoorPosX
                    lda ($40),y                     ; CC_TrapdataPtr
                    lsr a
                    lsr a
                    sec
                    sbc #$04
                    sta CtrlScrnColNo
                    ldy #CC_TrapDoorPosY
                    lda ($40),y                     ; CC_TrapdataPtr
                    lsr a
                    lsr a
                    lsr a
                    sta CtrlScrnRowNo
                    
                    jsr SetCtrlScrnPtr              ; ($3c/$3d) point to control screen output address $c000-$c7ff
                    
                    ldy #$00
                    lda ($3c),y
                    ora #CC_CtrlFloorStrt
                    sta ($3c),y
                    
                    ldy #$04
                    lda ($3c),y
                    ora #CC_CtrlFloorEnd
                    sta ($3c),y
                    
                    jmp .SetTrapCtrl
                    
.TrapOpen           lda #CC_TrapOpen
                    sta CC_ObjStTrStatus,x
                    lda #NoObjTrapMovMin            ; object: Trap Door - Open Complete - $73
                    sta CC_ObjStTrObjNo,x
                    
                    lda #$20                        ; red
                    sta ColObjTrapSw01              ; trap control top
                    lda #$cc                        ; grey
                    sta ColObjTrapSw02              ; trap control bottom
                    
                    ldy #CC_TrapDoorPosX
                    lda ($40),y                     ; CC_TrapdataPtr
                    lsr a
                    lsr a
                    sec
                    sbc #$04
                    sta CtrlScrnColNo
                    ldy #CC_TrapDoorPosY
                    lda ($40),y                     ; CC_TrapdataPtr
                    lsr a
                    lsr a
                    lsr a
                    sta CtrlScrnRowNo
                    
                    jsr SetCtrlScrnPtr              ; ($3c/$3d) point to control screen output address $c000-$c7ff
                    
                    ldy #$00
                    lda ($3c),y
                    and #CC_CtrlTrapLeft            ; trap open: start - resets floor to CC_CtrlFloorEnd
                    sta ($3c),y
                    
                    ldy #$04
                    lda ($3c),y
                    and #CC_CtrlTrapRight           ; trap open: end   - resets floor to CC_CtrlFloorStrt
                    sta ($3c),y
                    
.SetTrapCtrl        ldy #CC_TrapCtrlPosX
                    lda ($40),y                     ; CC_TrapdataPtr
                    sta PrmPntObj0PosX
                    ldy #CC_TrapCtrlPosY
                    lda ($40),y                     ; CC_TrapdataPtr
                    sta PrmPntObj0PosY
                    lda #NoObjTrapSwitch            ; object: Trap Door Control - $7a
                    sta PrmPntObj0No
                    lda #$00
                    sta PrmPntObj_Type
                    
.PaintTrapCtrl      jsr PaintObject
                    
                    lda SavZpg40
                    sta $40
                    lda SavZpg41
                    sta $41
                    lda SavZpg3c
                    sta $3c
                    lda SavZpg3d
                    sta $3d
                    
TrapDoorHandlerX    pla
                    tax
                    pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
PtrTrapWorkData     .byte $a5
SavOffTDObjWA       .byte $a0
SavZpg40            .byte $a0
SavZpg41            .byte $a0
SavZpg3c            .byte $a0
SavZpg3d            .byte $80
SavTrapDataPtrLo    .byte $a5
SavTrapDataPtrHi    .byte $a0
                    
Mask_80_e           .byte $80
Mask_01_e           .byte $01
; ------------------------------------------------------------------------------------------------------------- ;
; SideWalkMove      Function: - Called from: ObjectHandler
;                   Parms   : xr=Object status area offset ($00, $08, $10, $18, ...)
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
SideWalkMove        clc
                    lda SavWalkDataPtrLo
                    adc CC_ObjStMWOffDat,x
                    sta $40
                    lda SavWalkDataPtrHi
                    adc #$00
                    sta $41
                    
                    ldy #CC_WalkMode
                    lda ($40),y                     ; CC_SideWalkDataPtr
                    bit Mask_04_f                   ; CC_WalkPressP1
                    beq .ChkFireButnP2
                    
                    bit Mask_10_f                   ; set here if p1 pressed fire
                    beq .ChkMove
                    
.ChkFireButnP2      bit Mask_08_f                   ; CC_WalkPressP2
                    beq .Walk
                    
                    bit Mask_20_f                   ; set here if p2 pressed fire
                    bne .Walk
                    
.ChkMove            bit Mask_01_f
                    beq .SetMove
                    
                    eor Mask_01_f                   ; flip Bit0
                    eor Mask_02_f                   ; flip Bit1
                    sta ($40),y                     ; CC_SideWalkDataPtr
                    
.SetMoveStop        lda #$c0                        ; color: grey=stop
                    sta ColObjWalkSw01              ; walk control left
                    sta ColObjWalkSw02              ; walk control right
                    
                    lda #$1e
                    sta SFX_WalkSwTone              ; vary sound
                    jmp .Control
                    
.SetMove            ora Mask_01_f
                    sta ($40),y                     ; CC_SideWalkDataPtr
                    bit Mask_02_f                   ; move left/right
                    beq .SetCtrlRight
                    
.SetCtrlLeft        lda #$50                        ; color: green=move left
                    sta ColObjWalkSw01              ; walk control left
                    lda #$c0                        ; color: grey=inactive
                    sta ColObjWalkSw02              ; walk control right
                    
                    lda #$18
                    sta SFX_WalkSwTone              ; vary sound
                    jmp .Control
                    
.SetCtrlRight       lda #$c0                        ; color: grey=inactive
                    sta ColObjWalkSw01              ; walk control left
                    lda #$20                        ; color: left=move right
                    sta ColObjWalkSw02              ; walk control right
                    
                    lda #$24
                    sta SFX_WalkSwTone              ; vary sound
                    
.Control            ldy #CC_WalkCtrlPosX
                    lda ($40),y                     ; CC_SideWalkDataPtr
                    sta PrmPntObj0PosX
                    ldy #CC_WalkCtrlPosY
                    lda ($40),y                     ; CC_SideWalkDataPtr
                    sta PrmPntObj0PosY
                    
                    lda #NoObjWalkSwitch            ; object: Moving Sidewalk Control - $82
                    sta PrmPntObj0No
                    lda #$00
                    sta PrmPntObj_Type
                    
.PaintControl       jsr PaintObject
                    
                    lda #NoSndWalkSwitch            ; sound: Moving Sidewalk Switch - $0a
                    jsr InitSoundFX
                    
.Walk               ldy #CC_WalkMode
                    lda #$ff
                    eor Mask_10_f
                    eor Mask_20_f
                    and ($40),y                     ; CC_SideWalkDataPtr
                    bit Mask_04_f                   ; CC_WalkPressP1
                    beq .ChkFireP2
                    
.FireP1             ora Mask_10_f
                    eor Mask_04_f                   ; reset
                    
.ChkFireP2          bit Mask_08_f                   ; CC_WalkPressP2
                    beq .SetFire
                    
.FireP2             ora Mask_20_f
                    eor Mask_08_f                   ; reset
                    
.SetFire            sta ($40),y                     ; CC_SideWalkDataPtr
                    bit Mask_01_f
                    beq SideWalkMoveX               ; stopped
                    
                    lda WrkCountActions             ; counter ActionHandler routine calls
                    and #$01
                    bne SideWalkMoveX
                    
                    lda CC_WAObjsNo,x
                    sta PrmPntObj0No
                    lda ($40),y                     ; CC_SideWalkDataPtr
                    bit Mask_02_f
                    bne .MoveWalkLeft               ; CC_WalkMoveL
                    
.MoveWalkRight      inc PrmPntObj0No
                    lda PrmPntObj0No
                    cmp #NoObjWalkMovMax            ; object: Moving Sidewalk Max      - $82
                    bcc .SetWalk
                    
                    lda #NoObjWalkMov01             ; object: Moving Sidewalk Phase 01 - $7e
                    sta PrmPntObj0No
                    jmp .SetWalk
                    
.MoveWalkLeft       dec PrmPntObj0No
                    lda PrmPntObj0No
                    cmp #NoObjWalkMovMin            ; object: Moving Sidewalk Min      - $7e
                    bcs .SetWalk
                    
                    lda #NoObjWalkMov04             ; object: Moving Sidewalk Phase 04 - $81
                    sta PrmPntObj0No
                    
.SetWalk            lda CC_WAObjsPosX,x
                    sta PrmPntObj0PosX
                    lda CC_WAObjsPosY,x
                    sta PrmPntObj0PosY
                    
.PaintWalk          jsr PaintWAObjTyp0
                    
SideWalkMoveX       jmp RetObjMoveAuto
; ------------------------------------------------------------------------------------------------------------- ;
; SideWalkStepOn    Function: - called from: SprtBkgrHandler
;                   Parms   : xr=Sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                           : yr=Status work area block offset 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
SideWalkStepOn      clc
                    lda SavWalkDataPtrLo
                    adc CC_ObjStMWOffDat,y
                    sta $40
                    lda SavWalkDataPtrHi
                    adc #$00
                    sta $41
                    
                    sty SavSWPtrStWA
                    
                    ldy #CC_WalkMode
                    lda ($40),y                     ; CC_SideWalkDataPtr
                    bit Mask_01_f                   ; moves left/right if set
                    beq SideWalkStepOnX             ; stopped
                    
                    lda CC_WASprtType,x             ; 00=Player 01=Spark 02=Force 03=Mummy 04=Beam 05=Frank
                    beq .HandlePlayer
                    
                    cmp #CC_SprMummy                ; Mummy
                    beq .HandleEnemy
                    
                    cmp #CC_SprFrank                ; Frankenstein
                    beq .HandleEnemy
                    
                    jmp SideWalkStepOnX
                    
.HandlePlayer       lda CC_WASprtImgNo,x
                    cmp #$06
                    bcs SideWalkStepOnX
                    
.HandleEnemy        clc
                    lda CC_WASprtPosX,x
                    adc CC_WASprtStepX,x
                    ldy SavSWPtrStWA
                    sec
                    sbc CC_WAObjsPosX,y
                    bcc SideWalkStepOnX
                    
                    cmp #$20                        ; length sidewalk
                    bcs SideWalkStepOnX
                    
                    ldy #CC_WalkMode
                    lda ($40),y                     ; CC_SideWalkDataPtr
                    bit Mask_02_f                   ; set if moves left
                    beq .MarkPacePos                ; speed up
                    
.MarkPaceNeg        lda #$ff                        ; slow down - make it impossible to pass
                    jmp .SetPace
                    
.MarkPacePos        lda #$01
.SetPace            sta WrkSWPace
                    lda CC_WASprtType,x             ; 00=Player 01=Spark 02=Force 03=Mummy 04=Beam 05=Frank
                    bne .DoublePace
                    
                    lda WrkCountActions             ; counter ActionHandler routine calls
                    and #$07
                    bne .AddPace
                    
.DoublePace         asl WrkSWPace
.AddPace            clc
                    lda CC_WASprtPosX,x
                    adc WrkSWPace
                    sta CC_WASprtPosX,x
                    
SideWalkStepOnX     jmp RetObjMoveManu
; ------------------------------------------------------------------------------------------------------------- ;
; RoomWalk          Function: Paint a chambers moving sidewalks - Called from: PaintRoomItems
;                   Parms   : Pointer ($3e/$3f) to CC_SideWalk of CC_LvlGame
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
RoomWalk            pha
                    tya
                    pha
                    txa
                    pha
                    
                    lda $3e
                    sta SavWalkDataPtrLo
                    lda $3f
                    sta SavWalkDataPtrHi
                    
                    lda #$00
                    sta PtrWalkWorkData
                    
.NextWalk           ldy #CC_SideWalk
                    lda ($3e),y                     ; WalkDataPtr
                    bit Mask_80_f
                    beq .Walk
                    
                    inc $3e
                    bne .Exit
                    inc $3f                         ; ($3e/$3f) point behind EndOfSideWalkData
                    
.Exit               jmp RoomWalkX
                    
.Walk               lda #$ff
                    eor Mask_04_f
                    eor Mask_08_f
                    eor Mask_10_f
                    eor Mask_20_f
                    and ($3e),y                     ; WalkDataPtr
                    sta ($3e),y                     ; WalkDataPtr
                    
                    jsr ObjectInitWA                ; XR=ObjectWAOffset
                    
                    lda #CC_ObjWalkWay
                    sta CC_WAObjsType,x
                    
                    lda PtrWalkWorkData
                    sta CC_ObjStMWOffDat,x
                    
                    lda CC_WAObjsFlag,x
                    ora Mask_40_b                   ; action completed - CC_WAObjsReady
                    sta CC_WAObjsFlag,x
                    
                    ldy #CC_WalkPosX
                    lda ($3e),y                     ; WalkDataPtr
                    sta PrmPntObj1PosX
                    ldy #CC_WalkPosY
                    lda ($3e),y                     ; WalkDataPtr
                    sta PrmPntObj1PosY
                    
                    lda #NoObjWalkBlank             ; object: Moving Sidewalk Background - $7d
                    sta PrmPntObj1No
                    lda #$01
                    sta PrmPntObj_Type
                    
.PaintBack          jsr PaintObject
                    
                    lda PrmPntObj1PosX
                    sta PrmPntObj0PosX
                    lda PrmPntObj1PosY
                    sta PrmPntObj0PosY
                    
                    lda #NoObjWalkMov01             ; object: Moving Sidewalk Phase 01 - $7e
                    sta PrmPntObj0No
                    
.PaintWalk          jsr PaintWAObjTyp0
                    jsr ObjectInitWA                ; XR=ObjectWAOffset
                    
                    lda #CC_ObjWalkCtrl
                    sta CC_WAObjsType,x
                    lda PtrWalkWorkData
                    sta CC_ObjStMWOffDat,x
                    
                    ldy #CC_WalkCtrlPosX
                    lda ($3e),y                     ; WalkDataPtr
                    sta PrmPntObj0PosX
                    ldy #CC_WalkCtrlPosY
                    lda ($3e),y                     ; WalkDataPtr
                    sta PrmPntObj0PosY
                    
                    lda #NoObjWalkSwitch            ; object: Moving Sidewalk Control - $82
                    sta PrmPntObj0No
                    lda #$00
                    sta PrmPntObj_Type
                    
                    ldy #CC_WalkMode
                    lda ($3e),y                     ; WalkDataPtr
                    bit Mask_01_f
                    bne .ChkDir
                    
.Halt               lda #$c0                        ; color grey2
                    sta ColObjWalkSw01              ; walk control left
                    sta ColObjWalkSw02              ; walk control right
                    jmp .PaintControl
                    
.ChkDir             bit Mask_02_f
                    bne .MoveLeft
                    
.MovesRight         lda #$c0                        ; color grey2
                    sta ColObjWalkSw01              ; walk control left
                    lda #$20                        ; color red
                    sta ColObjWalkSw02              ; walk control right
                    jmp .PaintControl
                    
.MoveLeft           lda #$50                        ; color green
                    sta ColObjWalkSw01              ; walk control left
                    lda #$c0
                    sta ColObjWalkSw02              ; walk control right
                    
.PaintControl       jsr PaintObject
                    
                    ldy #CC_WalkCtrlPosX
                    lda ($3e),y                     ; WalkDataPtr
                    clc
                    adc #$04
                    sta PrmPntObj0PosX
                    ldy #CC_WalkCtrlPosY
                    lda ($3e),y                     ; WalkDataPtr
                    clc
                    adc #$08
                    sta PrmPntObj0PosY
                    
                    lda #NoObjWalkSpot              ; object: Moving Sidewalk Hot Spot - $83
                    sta PrmPntObj0No
                    
.PaintHotSpot       jsr PaintWAObjTyp0
                    
                    clc
                    lda PtrWalkWorkData
                    adc #$05
                    sta PtrWalkWorkData
                    
                    clc
                    lda $3e
                    adc #CC_SideWalkLen             ; $05 = sidewalk data entry length
                    sta $3e
                    bcc .GoNextWalk
                    inc $3f
                    
.GoNextWalk         jmp .NextWalk
                    
RoomWalkX           pla
                    tax
                    pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
; SideWalkSwitch    Function: - called from: SprtBkgrHandler
;                   Parms   : xr=Sprite work area block offset ($00 $20 $40 $60 $80 $a0 $c0 $e0)
;                           : yr=Status work area block offset 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
SideWalkSwitch      lda CC_WASprtType,x             ; 00=Player 01=Spark 02=Force 03=Mummy 04=Beam 05=Frank
                    bne SideWalkSwitchX             ; no player
                    
                    lda CC_WASprtJoyActn,x
                    beq SideWalkSwitchX             ; no fire button pressed
                    
                    clc
                    lda SavWalkDataPtrLo
                    adc CC_ObjStMWOffDat,y
                    sta $40
                    lda SavWalkDataPtrHi
                    adc #$00
                    sta $41
                    
                    lda CC_WASprtPlayrNo,x
                    beq .MarkPlayer1
                    
.MarkPlayer2        lda Mask_08_f
                    jmp .SetMarkPlayer
                    
.MarkPlayer1        lda Mask_04_f
.SetMarkPlayer      ldy #CC_WalkMode
                    ora ($40),y
                    sta ($40),y                     ; CC_RoomDoorPtr
                    
SideWalkSwitchX     jmp RetObjMoveManu
; ------------------------------------------------------------------------------------------------------------- ;
Mask_80_f           .byte $80
Mask_20_f           .byte $20
Mask_10_f           .byte $10
Mask_08_f           .byte $08
Mask_04_f           .byte $04
Mask_02_f           .byte $02
Mask_01_f           .byte $01
                    
PtrWalkWorkData     .byte $a4
WrkSWPace           .byte $b9
SavWalkDataPtrLo    .byte $a0
SavWalkDataPtrHi    .byte $b6
SavSWPtrStWA        .byte $a0
; ------------------------------------------------------------------------------------------------------------- ;
; RoomFrank         Function: Paint a chambers frankensteins - Called from: PaintRoomItems
;                   Parms   : Pointer ($3e/$3f) to CC_Frankenstein of CC_LvlGame
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
RoomFrank           pha
                    tya
                    pha
                    txa
                    pha
                    
                    lda $3e
                    sta SavFrStDataPtrLo
                    lda $3f
                    sta SavFrStDataPtrHi
                    
                    lda #$00
                    sta PtrFrStWorkData
                    
.NextFrank          ldy #CC_Frankenstein
                    lda ($3e),y                     ; FrankensteinDataPtr
                    bit Mask_80_g
                    beq .Frank
                    
                    inc $3e
                    bne .Exit
                    inc $3f                         ; ($3e/$3f) point behind EndOfFrankensteinData
                    
.Exit               jmp RoomFrankX
                    
.Frank              ldy #CC_FrStCoffPosX
                    lda ($3e),y                     ; FrankensteinDataPtr
                    sta PrmPntObj1PosX
                    clc
                    ldy #CC_FrStCoffPosY
                    lda ($3e),y                     ; FrankensteinDataPtr
                    adc #$18
                    sta PrmPntObj1PosY
                    
                    lda #NoObjFrankCover            ; object: Frank Blank Out Start of Floor - $92
                    sta PrmPntObj1No
                    lda #$01
                    sta PrmPntObj_Type
                    
.PaintBlank         jsr PaintObject
                    
                    lda PrmPntObj1PosX
                    lsr a
                    lsr a
                    sec
                    sbc #$04
                    sta CtrlScrnColNo
                    
                    lda PrmPntObj1PosY
                    lsr a
                    lsr a
                    lsr a
                    sta CtrlScrnRowNo
                    
                    jsr SetCtrlScrnPtr              ; ($3c/$3d) point to control screen output address $c000-$c7ff
                    
                    ldy #CC_FrStCoffDir
                    lda ($3e),y                     ; FrankensteinDataPtr
                    bit Mask_01_g
                    bne .ScrnSetOutPtr
                    
.ScrnCoffinRight    lda #CC_CtrlFrStRight
                    jmp .ScrnSetCoffin
                    
.ScrnSetOutPtr      sec
                    lda $3c
                    sbc #$02
                    sta $3c
                    bcs .ScrnCoffinLeft
                    dec $3d
                    
.ScrnCoffinLeft     lda #CC_CtrlFrStLeft
.ScrnSetCoffin      sta SavScrnCoffin
                    
                    ldy #$04
.ScrnSetData        lda ($3c),y
                    and SavScrnCoffin
                    sta ($3c),y                     ; mark coffin r/l - resets floor to CC_CtrlFloorStrt/CC_CtrlFloorEnd
                    dey
                    dey
                    bpl .ScrnSetData
                    
                    jsr ObjectInitWA                ; XR=ObjectWAOffset
                    
                    lda #CC_ObjFrank
                    sta CC_WAObjsType,x
                    
                    ldy #CC_FrStCoffPosX
                    lda ($3e),y                     ; FrankensteinDataPtr
                    sta PrmPntObj0PosX
                    ldy #CC_FrStCoffPosY
                    lda ($3e),y                     ; FrankensteinDataPtr
                    sta PrmPntObj0PosY
                    
                    ldy #CC_FrStCoffDir
                    lda ($3e),y                     ; FrankensteinDataPtr
                    bit Mask_01_g
                    bne .CoffinLeft
                    
.CoffinRight        lda #NoObjFrankCoffRi           ; object: Frank Coffin Open Right - $90
                    jmp .SetCoffin
                    
.CoffinLeft         lda #NoObjFrankCoffLe           ; object: Frank Coffin Open Left  - $91
.SetCoffin          sta PrmPntObj0No
                    
.PaintCoffin        jsr PaintWAObjTyp0
                    
                    ldy #CC_FrStCoffDir
                    lda ($3e),y                     ; FrankensteinDataPtr
                    bit Mask_01_g
                    bne .SetSpriteWA
                    
                    clc
                    lda PrmPntObj0PosX
                    adc #$04
                    sta PrmPntObj0PosX
                    clc
                    lda PrmPntObj0PosY
                    adc #$18
                    sta PrmPntObj0PosY
                    
                    lda #NoObjFloorMid              ; object: Floor Mid Tile - $1c
                    sta PrmPntObj0No
                    lda #$00
                    sta PrmPntObj_Type
                    
.PaintFloor         jsr PaintObject
.SetSpriteWA        jsr SetFrStSpriteWA
                    
                    clc
                    lda $3e
                    adc #CC_FrankLen                ; $07 = frank data entry length
                    sta $3e
                    bcc .GoNextFrank
                    inc $3f
                    
.GoNextFrank        clc
                    lda PtrFrStWorkData
                    adc #CC_FrankLen                ; $07 = frank data entry length
                    sta PtrFrStWorkData
                    jmp .NextFrank
                    
RoomFrankX          pla
                    tax
                    pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
SavFrStDataPtrLo    .byte $90
SavFrStDataPtrHi    .byte $a0
PtrFrStWorkData     .byte $c1
SavScrnCoffin       .byte $a0
                    
Mask_80_g           .byte $80
Mask_04_g           .byte $04
Mask_02_g           .byte $02
Mask_01_g           .byte $01
; ------------------------------------------------------------------------------------------------------------- ;
; ObjectInitWA      Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
ObjectInitWA        pha
                    tya
                    pha
                    
                    lda ObjWAUseCount               ; max $20 entries a 08 bytes in object work area
                    cmp #CC_ObjWAMax
                    bne .InitI
                    
                    sec                             ; init failed - no free space left
                    jmp ObjectInitWAX               ; exit
                    
.InitI              inc ObjWAUseCount               ; max $20 entries a 08 bytes in object work area
                    asl a
                    asl a
                    asl a                           ; *8 - entry length of 8 bytes
                    tax
                    ldy #CC_ObjWALen
                    lda #$00
.Init               sta CC_WAObjsType,x
                    sta CC_WAObjsStatus,x
                    inx
                    dey
                    bne .Init
                    
                    txa
                    sec
                    sbc #CC_ObjWALen                ; set XR to start of work area block
                    tax
                    lda Mask_80_b
                    sta CC_WAObjsFlag,x             ; 80=just_initialized
                    
                    clc                             ; init successfull
                    
ObjectInitWAX       pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
; PaintWAObjTyp0    Function: Paint a object work area object of type 0 (with color info)
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
PaintWAObjTyp0      pha
                    
                    lda CC_WAObjsFlag,x
                    bit Mask_80_b                   ; just initialized - CC_WAObjsInit
                    bne .SetType00
                    
.SetType02          lda #$02
                    sta PrmPntObj_Type
                    lda CC_WAObjsPosX,x
                    sta PrmPntObj1PosX
                    lda CC_WAObjsPosY,x
                    sta PrmPntObj1PosY
                    lda CC_WAObjsNo,x
                    sta PrmPntObj1No
                    jmp .Paint
                    
.SetType00          lda #$00
                    sta PrmPntObj_Type
                    
.Paint              jsr PaintObject
                    
                    lda Mask_80_b
                    eor #$ff
                    and CC_WAObjsFlag,x
                    sta CC_WAObjsFlag,x
                    
                    lda PrmPntObj0No
                    sta CC_WAObjsNo,x
                    
                    lda PrmPntObj0PosX
                    sta CC_WAObjsPosX,x
                    
                    lda PrmPntObj0PosY
                    sta CC_WAObjsPosY,x
                    
                    lda SavObj0Cols
                    sta CC_WAObjsCols,x
                    
                    lda SavObj0Rows
                    sta CC_WAObjsRows,x
                    asl CC_WAObjsCols,x
                    asl CC_WAObjsCols,x             ; *4
                    
PaintWAObjTyp0X     pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
; PaintWAObjTyp1    Function: Paint a object work area object of type 0 (without color info)
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
PaintWAObjTyp1      pha
                    
                    lda CC_WAObjsFlag,x
                    bit Mask_80_b                   ; just initialized - CC_WAObjsInit
                    bne PaintWAObjTyp1X
                    
                    lda #$01
                    sta PrmPntObj_Type
                    lda CC_WAObjsNo,x
                    sta PrmPntObj1No
                    lda CC_WAObjsPosX,x
                    sta PrmPntObj1PosX
                    lda CC_WAObjsPosY,x
                    sta PrmPntObj1PosY
                    
                    jsr PaintObject
                    
                    lda CC_WAObjsFlag,x
                    ora Mask_80_b                   ; just initialized - CC_WAObjsInit
                    sta CC_WAObjsFlag,x
                    
PaintWAObjTyp1X     pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
; PaintObject       Function: Paint all objects of type any type - 00=with color info 01=without color info 02=
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
PaintObject         pha
                    tya
                    pha
                    txa
                    pha
                    
.ChkTypes01         lda PrmPntObj_Type
                    cmp #$00
                    bne .Type01or02
                    
                    jmp .Type00
                    
.Type01or02         lda PrmPntObj1No
                    sta $38
                    lda #$00
                    sta $39
                    
                    asl $38
                    rol $39
                    clc
                    lda $38
                    adc #<TabObjectDataPtr
                    sta $38
                    lda $39
                    adc #>TabObjectDataPtr
                    sta $39                         ; ($38/$39) points to object data pointer
                    
                    ldy #$00
                    lda ($38),y
                    sta $30
                    iny
                    lda ($38),y
                    sta $31                         ; ($30/$31) points to type 1o2 object data
                    
                    ldy #$00
                    lda ($30),y                     ; ($30/$31) points to type 1o2 object data
                    sta SavObj1Cols
                    ldy #$01
                    lda ($30),y
                    sta SavObj1Rows
                    sta WrkObj1Rows
                    
                    clc
                    lda PrmPntObj1PosY
                    adc SavObj1Rows
                    sta SavObj1YY
                    
                    dec SavObj1YY
                    
                    sec
                    lda PrmPntObj1PosX
                    sbc #$10
                    bcs .SameObj1Row
                    
                    sta WrkObj1PosXx                ; PosX - $10
                    lda #$ff
                    jmp .SetObj1UFlow
                    
.SameObj1Row        sta WrkObj1PosXx                ; PosX - $10
                    
                    lda #$00
.SetObj1UFlow       sta WrkObj1PosXxU
                    
                    lda WrkObj1PosXx                ; PosX - $10
                    lsr a
                    lsr a
                    sta WrkObj1PosXm4
                    
                    lda WrkObj1PosXxU
                    and #$c0
                    ora WrkObj1PosXm4
                    sta WrkObj1PosXm4
                    
                    asl WrkObj1PosXx                ; PosX - $10
                    rol WrkObj1PosXxU
                    
                    clc
                    lda WrkObj1PosXm4
                    adc SavObj1Cols
                    sta WrkObj1PosX
                    
                    dec WrkObj1PosX
                    
                    lda #$00
                    sta WrkObj1Switch
                    
                    clc
                    lda $30
                    adc #$03                        ; object header length
                    sta $30
                    bcc .ChkTypes02
                    inc $31                         ; ($30/$31) points to type 1 object data
                    
.ChkTypes02         lda PrmPntObj_Type
                    cmp #$01
                    bne .Type00
                    
                    jmp .GetObj1PrmY01
                    
.Type00             lda PrmPntObj0No                ; object number
                    sta $38
                    lda #$00
                    sta $39
                    
                    asl $38
                    rol $39                         ; *2
                    
                    clc
                    lda $38
                    adc #<TabObjectDataPtr
                    sta $38
                    lda $39
                    adc #>TabObjectDataPtr
                    sta $39                         ; ($38/$39) points to object data pointer
                    
                    ldy #$00
                    lda ($38),y
                    sta $32
                    iny
                    lda ($38),y
                    sta $33                         ; ($32/$33) points to type 0 object data
                    
                    ldy #$00
                    lda ($32),y                     ; ($32/$33) points to type 0 object data
                    sta SavObj0Cols
                    ldy #$01
                    lda ($32),y                     ; ($32/$33) points to type 0 object data
                    sta SavObj0Rows
                    sta WrkObj0Rows
                    
                    clc
                    lda PrmPntObj0PosY
                    adc SavObj0Rows
                    sta SavObj0YY
                    
                    dec SavObj0YY
                    
                    sec
                    lda PrmPntObj0PosX
                    sbc #$10
                    bcs .SameObj0Row
                    
                    sta WrkObj0PosXx                ; PosX - $10
                    lda #$ff
                    jmp .SetObj0UFlow
                    
.SameObj0Row        sta WrkObj0PosXx                ; PosX - $10
                    
                    lda #$00
.SetObj0UFlow       sta WrkObj0PosXxU               ; $00 or $ff
                    
                    lda WrkObj0PosXx                ; PosX - $10
                    lsr a
                    lsr a                           ; *4
                    sta WrkObj0PosXm4
                    
                    lda WrkObj0PosXxU               ; $00 or $ff
                    and #$c0
                    ora WrkObj0PosXm4
                    sta WrkObj0PosXm4
                    
                    asl WrkObj0PosXx                ; PosX - $10
                    rol WrkObj0PosXxU               ; $00 or $ff => *2
                    
                    clc
                    lda WrkObj0PosXm4
                    adc SavObj0Cols
                    sta WrkObj0PosX
                    
                    dec WrkObj0PosX
                    
                    lda #$00
                    sta WrkObj0Switch
                    
                    clc
                    lda $32
                    adc #$03                        ; object header length
                    sta $32
                    bcc .GetPrmPosY
                    inc $33                         ; ($32/$33) points to type 0 object data
                    
.GetPrmPosY         lda PrmPntObj0PosY
                    sta WrkObj0PosY
                    cmp #$dc
                    bcs .GetPosYFF
                    
                    lda #$00
                    jmp .SetPosYTo38
                    
.GetPosYFF          lda #$ff
.SetPosYTo38        sta $38
                    
                    lsr $38
                    ror WrkObj0PosY
                    lsr $38
                    ror WrkObj0PosY
                    lsr $38
                    ror WrkObj0PosY                 ; /8
                    
                    lda SavObj0Rows
                    sec
                    sbc #$01
                    lsr a
                    lsr a
                    lsr a                           ; /8
                    
                    clc
                    adc WrkObj0PosY
                    sta SavObj0PosY
                    
                    lda WrkObj0PosY
                    bpl .GetCtrlScrnRow
                    
                    lda #$00
                    sec
                    sbc WrkObj0PosY
                    
.GetCtrlScrnRow     tax
                    lda TabCtrlScrRowsLo,x
                    sta WrkCtrlScrRowsLo
                    lda TabCtrlScrRowsHi,x
                    sta WrkCtrlScrRowsHi
                    
                    lda WrkObj0PosY
                    bpl .GetPrmPosX
                    
                    sec
                    lda #$00
                    sbc WrkCtrlScrRowsLo
                    sta WrkCtrlScrRowsLo
                    lda #$00
                    sbc WrkCtrlScrRowsHi
                    sta WrkCtrlScrRowsHi
                    
.GetPrmPosX         lda PrmPntObj0PosX
                    sec
                    sbc #$10
                    sta $38
                    bcs .GetPosX00
                    
                    lda #$ff
                    jmp .SetPosXTo39
                    
.GetPosX00          lda #$00
.SetPosXTo39        sta $39
                    
                    lsr $39
                    ror $38
                    lsr $39
                    ror $38                         ; /4
                    
                    sta $39
                    
                    clc
                    lda WrkCtrlScrRowsLo
                    adc $38                         ; (object PosX - $10) / 4
                    sta WrkCtrlScrRowsLo
                    lda WrkCtrlScrRowsHi
                    adc $39
                    sta WrkCtrlScrRowsHi
                    
.ChkType02          lda PrmPntObj_Type
                    cmp #$02
                    beq .GetObj0PrmY02
                    
                    cmp #$00
                    bne .GetObj1PrmY01
                    
.GetType0PrmY01     lda PrmPntObj0PosY
                    sta CntObjPosY
                    
                    lda SavObj0YY
                    sta CntObjPosYY
                    
                    jmp .SetHiResPtr
                    
.GetObj1PrmY01      lda PrmPntObj1PosY
                    sta CntObjPosY
                    
                    lda SavObj1YY
                    sta CntObjPosYY
                    
                    jmp .SetHiResPtr
                    
.GetObj0PrmY02      lda PrmPntObj0PosY
                    cmp PrmPntObj1PosY
                    beq .GetObj0PrmY03
                    
                    bcc .ChkType1Max
                    
                    cmp #$dc
                    bcc .GetObj1PrmY02
                    
                    lda PrmPntObj1PosY
                    cmp #$dc
                    bcs .GetObj1PrmY02
                    
                    jmp .GetObj0PrmY03
                    
.ChkType1Max        lda PrmPntObj1PosY
                    cmp #$dc
                    bcc .GetObj0PrmY03
                    
                    lda PrmPntObj0PosY
                    cmp #$dc
                    bcs .GetObj0PrmY03
                    
.GetObj1PrmY02      lda PrmPntObj1PosY
                    jmp .SetObj0PrmY03
                    
.GetObj0PrmY03      lda PrmPntObj0PosY
.SetObj0PrmY03      sta CntObjPosY
                    
                    lda SavObj0YY
                    cmp SavObj1YY
                    beq .GetObj1SavYY02
                    
                    bcc .GetObj1SavYY01
                    
                    cmp #$dc
                    bcc .GetObj0SavYY
                    
                    lda SavObj1YY
                    cmp #$dc
                    bcc .GetObj1SavYY02
                    
                    jmp .GetObj0SavYY
                    
.GetObj1SavYY01     lda SavObj1YY
                    cmp #$dc
                    bcc .GetObj1SavYY02
                    
                    lda SavObj0YY
                    cmp #$dc
                    bcs .GetObj1SavYY02
                    
.GetObj0SavYY       lda SavObj0YY
                    sta CntObjPosYY
                    jmp .SetHiResPtr
                    
.GetObj1SavYY02     lda SavObj1YY
                    sta CntObjPosYY
                    
.SetHiResPtr        lda CntObjPosY
                    sta WrkRows
                    
                    tax
                    lda CC_TabHiResRowLo,x          ; hires screen row (PosY)
                    sta $34
                    lda CC_TabHiResRowHi,x          ; hires screen row (PosY)
                    sta $35                         ; ($34/$35) points to hires screen graphic output row
                    
.AllObjectsOut      lda PrmPntObj_Type
                    cmp #$00
                    beq .ChkType01_01
                    
                    lda WrkObj1Rows
                    beq .ChkType01_01
                    
                    lda WrkObj1Switch
                    cmp #$01
                    beq .DecObj1Rows
                    
                    lda WrkRows
                    cmp PrmPntObj1PosY
                    bne .ChkType01_01
                    
                    lda #$01
                    sta WrkObj1Switch
                    
.DecObj1Rows        dec WrkObj1Rows
                    lda WrkRows
                    cmp #$c8
                    bcs .NextObj1Col
                    
                    lda WrkObj1PosXm4
                    sta CntObjPosX
                    
                    clc
                    lda $34                         ; ($34/$35) points to hires screen graphic output row
                    adc WrkObj1PosXx                ; PosX - $10
                    sta $36
                    lda $35
                    adc WrkObj1PosXxU
                    sta $37
                    
                    ldy #$00
.ChkObj1ColMax      lda CntObjPosX
                    cmp #$28                        ; max $28 (40) columns per row
                    bcs .ChkCntObj1PosX
                    
.Type1ObjectOut     lda ($30),y                     ; (30/31) points to object type 1 or 2 data
                    eor #$ff
                    and ($36),y
                    sta ($36),y                     ; ($36/$37) points to hires screen graphic output col
                    
.ChkCntObj1PosX     lda CntObjPosX
                    cmp WrkObj1PosX
                    beq .NextObj1Col
                    
                    clc
                    lda $36
                    adc #$07                        ; next block
                    sta $36
                    bcc .IncObj1PosX
                    inc $37                         ; ($36/$37) points to hires screen graphic output col
                    
.IncObj1PosX        inc CntObjPosX
                    iny
                    jmp .ChkObj1ColMax
                    
.NextObj1Col        clc
                    lda $30
                    adc SavObj1Cols
                    sta $30
                    bcc .ChkType01_01
                    inc $31
                    
.ChkType01_01       lda PrmPntObj_Type
                    cmp #$01
                    beq .ChkObj0YY
                    
                    lda WrkObj0Rows
                    beq .ChkObj0YY
                    
                    lda WrkObj0Switch
                    cmp #$01
                    beq .DecWrkObj0Rows
                    
                    lda WrkRows
                    cmp PrmPntObj0PosY
                    bne .ChkObj0YY
                    
                    lda #$01
                    sta WrkObj0Switch
                    
.DecWrkObj0Rows     dec WrkObj0Rows
                    lda WrkRows
                    cmp #$c8
                    bcs .NextTyp0DataCol
                    
                    lda WrkObj0PosXm4
                    sta CntObjPosX
                    
                    lda $34                         ; ($34/$35) points to hires screen graphic output row
                    clc
                    adc WrkObj0PosXx                ; PosX - $10
                    sta $36
                    lda $35
                    adc WrkObj0PosXxU               ; $00 or $ff
                    sta $37                         ; ($36/$37) points to hires screen graphic output col
                    
                    ldy #$00
.ChkTyp0MaxPosX     lda CntObjPosX
                    cmp #$28                        ; max $28 (40) columns per row
                    bcs .ChkTyp0PosX
                    
.Type0ObjectOut     lda ($32),y                     ; (32/33) points to object type 0 data
                    ora ($36),y
                    sta ($36),y                     ; ($36/$37) points to hires screen graphic output col
                    
.ChkTyp0PosX        lda CntObjPosX
                    cmp WrkObj0PosX
                    beq .NextTyp0DataCol
                    
.NextTyp0OutCol     clc
                    lda $36
                    adc #$07
                    sta $36
                    bcc .NextColPosX
                    inc $37                         ; ($36/$37) points to hires screen graphic output col
                    
.NextColPosX        iny
                    inc CntObjPosX
                    jmp .ChkTyp0MaxPosX
                    
.NextTyp0DataCol    clc
                    lda $32
                    adc SavObj0Cols
                    sta $32
                    bcc .ChkObj0YY
                    inc $33                         ; (32/33) points to object type 0 data
                    
.ChkObj0YY          lda WrkRows
                    cmp CntObjPosYY
                    beq .AllObjectsFin              ; finished
                    
                    inc WrkRows
                    
                    lda WrkRows
                    and #$07
                    beq .SetNextHiresRow
                    
.SetNextHiresCol    inc $34                         ; ($34/$35) points to hires screen graphic output row
                    bne .GoAllObjectsOut
                    inc $35                         ; point to next hires column in row
                    jmp .GoAllObjectsOut
                    
.SetNextHiresRow    clc
                    lda $34                         ; ($34/$35) points to hires screen graphic output row
                    adc #$39
                    sta $34
                    lda $35
                    adc #$01                        ; $140 bytes for each multicolor row 
                    sta $35
                    
.GoAllObjectsOut    jmp .AllObjectsOut
                    
.AllObjectsFin      = *
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
HandleObj0Colors    lda PrmPntObj_Type
                    cmp #$01
                    bne Obj0VideoColors             ; only for objects of type 0
                    
                    jmp PaintObjectX
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
Obj0VideoColors     lda PrmPntObj0PosY              ; spread compressed color info to video ram
                    and #$07
                    beq .GetSwitch00_01
                    
.GetSwitch01_01     lda #$01
                    jmp .SetSwitch_01
                    
.GetSwitch00_01     lda #$00
.SetSwitch_01       sta WrkSwitch00
                    
                    lda WrkObj0PosY
                    sta WrkRows
                    
                    clc
                    lda #<CC_ScreenRam
                    adc WrkCtrlScrRowsLo
                    sta $30
                    lda #>CC_ScreenRam
                    adc WrkCtrlScrRowsHi
                    sta $31                         ; ($30/$31) points to $cc00 - screen storage for object type 0 colors
                    
.FillVideoColors    lda WrkRows
                    cmp #$19                        ; max $19 (25) screen rows
                    bcs .ChkMaxPosY
                    
                    ldy #$00
                    lda WrkObj0PosXm4
                    sta CntObjPosX
                    
.ChkMaxPosX         lda CntObjPosX
                    cmp #$28                        ; max $28 (40) columns per row
                    bcs .NextObjPosX
                    
.CopyToVideoRam     lda ($32),y                     ; ($32/$33) points to type  0 object screen ram color data
                    sta ($30),y                     ; ($30/$31) points to type  0 object screen ram
                    
.NextObjPosX        iny
                    lda CntObjPosX
                    cmp WrkObj0PosX
                    beq .ChkMaxPosY
                    
                    inc CntObjPosX
                    jmp .ChkMaxPosX
                    
.ChkMaxPosY         lda WrkRows
                    cmp SavObj0PosY
                    beq .ChkSwitch
                    
                    inc WrkRows
                    
                    clc
                    lda $32
                    adc SavObj0Cols
                    sta $32
                    bcc .SetNextColorRow
                    inc $33
                    
                    jmp .SetNextColorRow
                    
.ChkSwitch          lda WrkSwitch00
                    cmp #$01
                    bne .SetNextObjCol
                    
                    lda #$00
                    sta WrkSwitch00
                    
                    lda WrkRows
                    cmp #$ff
                    beq .SetNextColorRow
                    
                    cmp #$18
                    bcs .SetNextObjCol
                    
.SetNextColorRow    clc
                    lda $30
                    adc #$28                        ; $28 columns per screen row
                    sta $30
                    bcc .FillVideoColors
                    inc $31
                    
                    jmp .FillVideoColors
                    
.SetNextObjCol      clc
                    lda $32
                    adc SavObj0Cols
                    sta $32
                    bcc Obj0RamColors
                    inc $33
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
Obj0RamColors       lda PrmPntObj0PosY              ; copy temp colors to color ram
                    and #$07
                    beq .GetSwitch00
                    
.GetSwitch01        lda #$01
                    jmp .SetSwitch
                    
.GetSwitch00        lda #$00
.SetSwitch          sta WrkSwitch00
                    
                    lda WrkObj0PosY
                    sta WrkRows
                    
                    clc
                    lda #<COLORAM
                    adc WrkCtrlScrRowsLo
                    sta $30
                    lda #>COLORAM
                    adc WrkCtrlScrRowsHi
                    sta $31                         ; ($30/$31) points to colour ram
                    
.FillCoRamColors    lda WrkRows
                    cmp #$19                        ; max $19 (25) screen rows
                    bcs .ChkMaxPosY
                    
                    ldy #$00
                    lda WrkObj0PosXm4
                    sta CntObjPosX
                    
.ChkMaxPosXRam      lda CntObjPosX
                    cmp #$28                        ; max $28 (40) columns per row
                    bcs .NextObjPosX
                    
.CopyToColorRam     lda ($32),y                     ; ($32/$33) points to type 0 object color ram data
                    sta ($30),y                     ; ($30/$31) points to colour ram
                    
.NextObjPosX        iny
                    lda CntObjPosX
                    cmp WrkObj0PosX
                    beq .ChkMaxPosY
                    
                    inc CntObjPosX
                    jmp .ChkMaxPosXRam
                    
.ChkMaxPosY         lda WrkRows
                    cmp SavObj0PosY
                    beq .ChkSwitch
                    
                    inc WrkRows
                    
                    clc
                    lda $32
                    adc SavObj0Cols
                    sta $32
                    bcc .SetNextColorRow
                    inc $33
                    
                    jmp .SetNextColorRow
                    
.ChkSwitch          lda WrkSwitch00
                    cmp #$01
                    bne PaintObjectX
                    
                    lda #$00
                    sta WrkSwitch00
                    
                    lda WrkRows
                    cmp #$ff
                    beq .SetNextColorRow
                    
                    cmp #$18
                    bcs PaintObjectX
                    
.SetNextColorRow    clc
                    lda $30
                    adc #$28
                    sta $30
                    bcc .FillCoRamColors
                    inc $31
                    
                    jmp .FillCoRamColors
                    
PaintObjectX        pla
                    tax
                    pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
WrkRows             .byte $a0
CntObjPosY          .byte $94
CntObjPosYY         .byte $a9
PrmPntObj_Type      .byte $8a
CntObjPosX          .byte $cf
                    
PrmPntObj0No        .byte $9e
PrmPntObj0PosY      .byte $a0
PrmPntObj0PosX      .byte $c5
                    
SavObj0YY           .byte $ff
SavObj0Cols         .byte $c5
SavObj0Rows         .byte $e5
WrkObj0Rows         .byte $a0
WrkObj0PosXx        .byte $a0
WrkObj0PosXxU       .byte $9e
WrkObj0PosXm4       .byte $95
WrkObj0PosX         .byte $b9
WrkObj0Switch       .byte $90
                    
PrmPntObj1No        .byte $80
PrmPntObj1PosY      .byte $b8
PrmPntObj1PosX      .byte $c5
                    
SavObj1YY           .byte $a0
SavObj1Cols         .byte $af
SavObj1Rows         .byte $ba
WrkObj1Rows         .byte $d5
WrkObj1PosXx        .byte $a0
WrkObj1PosXxU       .byte $a0
WrkObj1PosXm4       .byte $d0
WrkObj1PosX         .byte $d9
WrkObj1Switch       .byte $8a
                    
WrkObj0PosY         .byte $e6
SavObj0PosY         .byte $b1
                    
WrkCtrlScrRowsLo    .byte $a0
WrkCtrlScrRowsHi    .byte $ff
                    
WrkSwitch00         .byte $a0
; ------------------------------------------------------------------------------------------------------------- ;
TabCtrlScrRowsLo    .byte $a5 ; $00                 ; control screen row offsets low with high=00
                    .byte $a0 ; $28
                    .byte $f0 ; $50
                    .byte $a0 ; $78
                    .byte $a0 ; $a0
                    .byte $a1 ; $c8
                    .byte $a0 ; $f0
                    
                    .byte $a0 ; $18                 ; control screen row offsets low with high=01
                    .byte $a0 ; $40
                    .byte $80 ; $68
                    .byte $a0 ; $90
                    .byte $a0 ; $b8
                    .byte $98 ; $e0
                    
                    .byte $a0 ; $08                 ; control screen row offsets low with high=02
                    .byte $cc ; $30
                    .byte $b7 ; $58
                    .byte $a0 ; $80
                    .byte $a0 ; $a8
                    .byte $b0 ; $d0
                    .byte $85 ; $f8
                    
                    .byte $c4 ; $20                 ; control screen row offsets low with high=03
                    .byte $ad ; $48
                    .byte $a0 ; $70
                    .byte $83 ; $98
                    .byte $a0 ; $c0
                    .byte $e8 ; $e8
                    
                    .byte $a0 ; $10                 ; control screen row offsets low with high=04
                    .byte $a0 ; $38
                    .byte $c3 ; $60
                    .byte $d5 ; $88
                    .byte $fb ; $b0
                    .byte $d0 ; $d8
                    
TabCtrlScrRowsHi    .byte $a0 ; $00                 ; control screen row offsets high
                    .byte $e0 ; $00
                    .byte $c4 ; $00
                    .byte $e9 ; $00
                    .byte $a0 ; $00
                    .byte $af ; $00
                    .byte $c3 ; $00
                    
                    .byte $a0 ; $01
                    .byte $b5 ; $01
                    .byte $d3 ; $01
                    .byte $89 ; $01
                    .byte $c2 ; $01
                    .byte $94 ; $01
                    
                    .byte $c4 ; $02
                    .byte $a0 ; $02
                    .byte $c3 ; $02
                    .byte $a0 ; $02
                    .byte $d6 ; $02
                    .byte $a0 ; $02
                    .byte $88 ; $02
                    
                    .byte $a0 ; $03
                    .byte $a0 ; $03
                    .byte $c5 ; $03
                    .byte $a0 ; $03
                    .byte $86 ; $03
                    .byte $a0 ; $03
                    
                    .byte $89 ; $04
                    .byte $a0 ; $04
                    .byte $f5 ; $04
                    .byte $b6 ; $04
                    .byte $c3 ; $04
                    .byte $97 ; $04
; ------------------------------------------------------------------------------------------------------------- ;
; CopySpriteData    Function: Set shape / expand and copy sprite data of a given number to its memory location
;                   Parms   : xr=sprite workarea block offset ($00, $20, $40, $60, $80, $a0, $c0, $e0)
;                   Returns : xr=sprite workarea block offset ($00, $20, $40, $60, $80, $a0, $c0, $e0)
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
CopySpriteData      pha
                    tya
                    pha
                    
                    lda CC_WASprtImgNo,x            ; sprite image number
                    sta $38
                    lda #$00
                    sta $39
                    
                    asl $38                         ; *2
                    rol $39
                    
                    clc
                    lda $38
                    adc #<TabSpriteDataPtr
                    sta $38
                    lda $39
                    adc #>TabSpriteDataPtr
                    sta $39                         ; (38/39) points to desired object pointer
                    
                    ldy #$00
                    lda ($38),y
                    sta $30
                    iny
                    lda ($38),y
                    sta $31                         ; (30/31) points to desired object data
                    
                    ldy #$02
                    lda ($30),y                     ; sprite: shape/color
                    sta CC_WASprtAttr,x             ; Bit7: X-expand Bit6: Y-expand Bit5: Spr/BG-Prio Bit4: MultiColor Bits3-0: Color 0
                    ldy #$00
                    lda ($30),y                     ; sprite: number of columns
                    sta SavSprtNumCols
                    
                    asl a
                    asl a                           ; *4
                    sta CC_WASprtCols,x
                    
                    ldy #$01
                    lda ($30),y                     ; sprite: number of rows
                    sta CC_WASprtRows,x
                    
                    txa
                    lsr a                           ; /2
                    lsr a                           ; /4
                    lsr a                           ; /8
                    lsr a                           ; /16
                    lsr a                           ; /32 - sprite number
                    sta SavSprtNo
                    
                    tay
                    lda CC_ZPgSprt__DatP,y          ; sprites data pointers 0-7 ($20 $21 $2a $2b $24 $25 $26 $27) - $800-$9c0
                    eor #$08                        ; point to store position   ($28 $29 $2a $2b $2c $2d $2e $2f) - $a00-$bc0
                    sta $32
                    lda #$00
                    sta $33
                    
                    asl $32
                    rol $33                         ; *2
                    asl $32
                    rol $33                         ; *4
                    asl $32
                    rol $33                         ; *8
                    asl $32
                    rol $33                         ; *16
                    asl $32
                    rol $33                         ; *32
                    asl $32
                    rol $33                         ; *64 - $a00 $a40 $a80 $ac0 $b00 $b40 $b80 $bc0  ($880 - $cff)
                    
                    clc
                    lda $32
                    adc #<CC_SprtPtrsBase
                    sta $32
                    lda $33
                    adc #>CC_SprtPtrsBase
                    sta $33                         ; (32/33) points to desired object target storage at $c800 - $c9ff
                    
                    clc
                    lda $30
                    adc #$03                        ; (30/31) point behind control bytes
                    sta $30
                    bcc .M01
                    inc $31                         ; (30/31) points to desired object data
                    
.M01                lda #$00
                    sta SavWorkNumRows
.CopyI              ldy #$00
.Copy               cpy SavSprtNumCols
                    bcs .Copy00                     ; greater/equal
                    
                    lda ($30),y                     ; from object data
                    jmp .CopyData
                    
.Copy00             lda #$00                        ; fill sprite column        03 with 00
.CopyData           sta ($32),y                     ; fill sprite columns 01-02-03
                    iny
                    cpy #$03                        ; last column
                    bcc .Copy                       ; no - next
                    
                    inc SavWorkNumRows
                    lda SavWorkNumRows
                    cmp #$15
                    beq .Extra                      ; max 20 rows - set color0 and shape extras
                    
                    cmp CC_WASprtRows,x             ; max rows this sprite
                    bcs .SetFillTab                 ; greater equal - fill missing rows with 00
                    
                    clc
                    lda $30
                    adc SavSprtNumCols
                    sta $30
                    bcc .SetNextRow
                    inc $31
                    jmp .SetNextRow                 ; point to next copy data
                    
.SetFillTab         lda #<SavSprtFillUp
                    sta $30
                    lda #>SavSprtFillUp
                    sta $31                         ; (30/31) points to fill up object data - $00 $00 $00
                    
.SetNextRow         clc
                    lda $32
                    adc #$03                        ; 03 bytes per row
                    sta $32
                    bcc .CopyI
                    inc $33
                    jmp .CopyI
                    
.Extra              ldy SavSprtNo
                    lda CC_ZPgSprt__DatP,y          ; point to store position   ($28 $29 $2a $2b $2c $2d $2e $2f) - $a00-$bc0
                    eor #$08                        ; sprites data pointers 0-7 ($20 $21 $2a $2b $24 $25 $26 $27) - $800-$9c0
                    sta CC_ZPgSprt__DatP,y
                    
.Color              lda CC_WASprtAttr,x             ; Bit7: X-expand Bit6: Y-expand Bit5: Spr/BG-Prio Bit4: MultiColor Bits3-0: Color 0
                    and #$0f                        ; isolate colors
.SetColor           sta SP0COL,y                    ; VIC 2 - $D027 = Color Sprite 0(-7)
                    
.XExpand            lda CC_WASprtAttr,x             ; Bit7: X-expand Bit6: Y-expand Bit5: Spr/BG-Prio Bit4: MultiColor Bits3-0: Color 0
                    bit Mask_80_a                   ; test Bit7: X-expand
                    bne .SetXExpand                 ; not set
                    
.ClrXExpand         lda Mask_01to80,y
                    eor #$ff
                    and XXPAND                      ; VIC 2 - $D01D = Sprite X Expansion
                    jmp .SavXExpand
                    
.SetXExpand         lda XXPAND                      ; VIC 2 - $D01D = Sprite X Expansion
                    asl CC_WASprtCols,x             ; double sprite columns
                    ora Mask_01to80,y
                    
.SavXExpand         sta XXPAND                      ; VIC 2 - $D01D = Sprite X Expansion
                    
.YExpand            lda CC_WASprtAttr,x             ; Bit7: X-expand Bit6: Y-expand Bit5: Spr/BG-Prio Bit4: MultiColor Bits3-0: Color 0
                    bit Mask_40_a                   ; test Bit6: Y-expand
                    bne .SetYExpand                 ; not set
                    
.ClrYExpand         lda Mask_01to80,y
                    eor #$ff
                    and YXPAND                      ; VIC 2 - $D017 = Sprite Y Expansion Register
                    jmp .SavYExpand
                    
.SetYExpand         lda YXPAND                      ; VIC 2 - $D017 = Sprite Y Expansion Register
                    ora Mask_01to80,y
                    asl CC_WASprtRows,x             ; double sprite rows
                    
.SavYExpand         sta YXPAND                      ; VIC 2 - $D017 = Sprite Y Expansion Register
                    
.SprBgPrio          lda CC_WASprtAttr,x             ; Bit7: X-expand Bit6: Y-expand Bit5: Spr/BG-Prio Bit4: MultiColor Bits3-0: Color 0
                    bit Mask_20_a                   ; test Bit5: Spr/BG-Prio
                    bne .ClrSprBgPrio               ; not set
                    
.SetSprBgPrio       lda SPBGPR                      ; VIC 2 - $D01B = Sprite to Foreground Priority
                    ora Mask_01to80,y
                    jmp .SavSprBgPrio
                    
.ClrSprBgPrio       lda Mask_01to80,y
                    eor #$ff
                    and SPBGPR                      ; VIC 2 - $D01B = Sprite to Foreground Priority
                    
.SavSprBgPrio       sta SPBGPR                      ; VIC 2 - $D01B = Sprite to Foreground Priority
                    
.MultiColor         lda CC_WASprtAttr,x             ; Bit7: X-expand Bit6: Y-expand Bit5: Spr/BG-Prio Bit4: MultiColor Bits3-0: Color 0
                    bit Mask_10_a                   ; test Bit4: MultiColor
                    bne .ClrMultiColor              ; not set
                    
.SetMultiColor      lda SPMC                        ; VIC 2 - $D01C = Sprite Multicolor
                    ora Mask_01to80,y
                    jmp .SavMultiColor
                    
.ClrMultiColor      lda Mask_01to80,y
                    eor #$ff
                    and SPMC                        ; VIC 2 - $D01C = Sprite Multicolor
                    
.SavMultiColor      sta SPMC                        ; VIC 2 - $D01C = Sprite Multicolor
                    
CopySpriteDataX     pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
SavSprtNo           .byte $8c
SavSprtFillUp       .byte $00, $00, $00             ; sprite filler row up to $14 (20)
SavWorkNumRows      .byte $a0
SavSprtNumCols      .byte $8a
; ------------------------------------------------------------------------------------------------------------- ;
; ChkKeyList        Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
ChkKeyList          pha
                    sta SavKeyToFind
                    tya
                    pha
                    
                    lda CC_WASprtPlayrNo,x
                    beq .CheckP1
                    
.CheckP2            lda CC_LvlP2KeyAmnt              ; $7814 : count start: 01
                    sta SavP_KeyAmount
                    lda #<CC_LvlP2KeyColct ; $35
                    sta $30
                    lda #>CC_LvlP2KeyColct ; $78
                    sta $31
                    jmp .ChkCollectionI
                    
.CheckP1            lda CC_LvlP1KeyAmnt              ; $7813 : count start: 01
                    sta SavP_KeyAmount
                    lda #<CC_LvlP1KeyColct ; $15
                    sta $30
                    lda #>CC_LvlP2KeyColct ;$78
                    sta $31
                    
.ChkCollectionI     ldy #$00
.ChkCollection      cpy SavP_KeyAmount
                    beq .NotFound
                    
                    lda ($30),y
                    cmp SavKeyToFind
                    beq .Found
                    
                    iny
                    jmp .ChkCollection
                    
.NotFound           sec
                    jmp ChkKeyListX
.Found              clc
                    
ChkKeyListX         pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
SavP_KeyAmount      .byte $b5
SavKeyToFind        .byte $d4
; ------------------------------------------------------------------------------------------------------------- ;
; Randomizer        Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
Randomizer          lda RndSeed03
                    ror a
                    
                    lda RndSeed02
                    ror a
                    sta RndSeed01
                    
                    lda #$00
                    rol a
                    eor RndSeed02
                    sta RndSeed02
                    
                    lda RndSeed01
                    eor RndSeed03
                    sta RndSeed03
                    
                    eor RndSeed02
                    sta RndSeed02
                    
RandomizerX         rts
; ------------------------------------------------------------------------------------------------------------- ;
RndSeed01           .byte $a0
RndSeed02           .byte $c6
RndSeed03           .byte $57
; ------------------------------------------------------------------------------------------------------------- ;
; GetKeyJoyVal      Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
GetKeyJoyVal        pha
                    sta SavJoystickNo
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
                    
.SetStopYes         lda #$01
.PutStop            sta FlgKeyStop                  ; 1=STOP key pressed
                    
.Joystick           lda #$00
                    sta FlgJoy_NoUse
                    
                    lda SavJoystickNo
                    eor #$01                        ; swap parm: 0=1  1=0
                    tax
                    
                    lda #$00
                    sta CIDDRA,x                    ; CIA 1 - $DC02 = Data Direction A
                    lda CIAPRA,x                    ; CIA 1 - $DC00 = Data Port A
                    sta SavJoystickNo               ; value   joystick port A/B
                    
                    and #$0f                        ; isolate joystick moves = Bit 0-3: 0=up/down/left/right
                    tax
                    lda TabJoyDir,x
                    sta SavJoyDir
                    
                    lda SavJoystickNo
                    and #$10                        ; isolate joystick fire  = Bit 4  : 0=fire
                    bne .SetFireNo
                    
.SetFireYes         lda #$01
                    jmp .PutFire
                    
.SetFireNo          lda #$00
.PutFire            sta FlgJoyFire                  ; 1=FIRE pressed
                    
GetKeyJoyValX       pla
                    tax
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
SavJoyDir           .byte $82
FlgJoyFire          .byte $a0
SavJoystickNo       .byte $bf
                                                    ; rldu
TabJoyDir           .byte $80                       ; ....
                    .byte $80                       ; ...#
                    .byte $80                       ; ..#.
                    .byte $80                       ; ..##
                    .byte $80                       ; .#..
                    .byte $03                       ; .#.#  - right + down
                    .byte $01                       ; .##.  - right + up
                    .byte $02                       ; .###  - right
                    .byte $80                       ; #...
                    .byte $05                       ; #..#  - left  + down
                    .byte $07                       ; #.#.  - left  + up
                    .byte $06                       ; #.##  - left
                    .byte $80                       ; ##..
                    .byte $04                       ; ##.#  - down
                    .byte $00                       ; ###.  - up
                    .byte $80                       ; ####
                    
FlgKeyStop          .byte $00                       ; stop key pressed  1=pressed
FlgJoy_NoUse        .byte $00
; ------------------------------------------------------------------------------------------------------------- ;
; SetCtrlScrnPlyr   Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
SetCtrlScrnPlyr     pha
                    tya
                    pha
                    
                    clc
                    lda CC_WASprtPosX,x
                    adc CC_WASprtStepX,x
                    sta CtrlScrnColNo
                    and #$03
                    sta CtrlScrnCol_0_1             ; Bit 0-1 of CtrlScrnColNo
                    
                    lda CtrlScrnColNo
                    lsr a
                    lsr a                           ; *4
                    sec
                    sbc #$04
                    sta CtrlScrnColNo
                    
                    clc
                    lda CC_WASprtPosY,x
                    adc CC_WASprtStepY,x
                    sta CtrlScrnRowNo
                    and #$07
                    sta CtrlScrnRow_0_2             ; Bit 0-2 of CtrlScrnRowNo
                    
                    lda CtrlScrnRowNo
                    lsr a
                    lsr a
                    lsr a                           ; *8
                    sta CtrlScrnRowNo
                    
                    jmp scspStart
; ------------------------------------------------------------------------------------------------------------- ;
; SetCtrlScrnPtr    Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
SetCtrlScrnPtr      pha
                    tya
                    pha
                    
scspStart           ldy CtrlScrnRowNo               ; global entry point SetCtrlScrnPlyr
                    lda TabCtrlScrRowsLo,y
                    sta $3c
                    lda TabCtrlScrRowsHi,y
                    sta $3d
                    
                    asl $3c
                    rol $3d                         ; pointer *2
                    
                    clc
                    lda $3c
                    adc #<CC_ScrnMoveCtrl
                    sta $3c
                    lda $3d
                    adc #>CC_ScrnMoveCtrl
                    sta $3d                         ; add base address $C000
                    
                    lda CtrlScrnColNo
                    asl a
                    clc
                    adc $3c
                    sta $3c
                    bcc SetCtrlScrnPtrX
                    inc $3d                         ; ($3c/$3d) point to control screen output address $c000-$c7ff
                    
SetCtrlScrnPtrX     pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
CtrlScrnColNo       .byte $ac
CtrlScrnRowNo       .byte $85
CtrlScrnCol_0_1     .byte $c8
CtrlScrnRow_0_2     .byte $a0
; ------------------------------------------------------------------------------------------------------------- ;
; SetRoomShapePtr   Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
SetRoomShapePtr     pha                             ; point (42/43) to the rooms shape data
                    sta $42
                    lda #$00
                    sta $43
                    
                    asl $42
                    rol $43                         ; *2
                    asl $42
                    rol $43                         ; *4
                    asl $42
                    rol $43                         ; *8
                    
.SetAdrLvlGame      clc
                    lda $42
                    adc #<(CC_LvlGame+CC_LvlGameData)
                    sta $42                         ; pointer (42/43) multiplied by 8
                    lda $43
                    adc #>(CC_LvlGame+CC_LvlGameData) ; $79  ; castle GAME room data high - starts at $7900
                    sta $43
                    
.ChkAdrLvlLoad      lda FlgRoomLoadAdr              ; $00=$7800 $01=$9800 $02=$b800
                    cmp #CC_LvlStorID
                    bne SetRoomShapePtrX
                    
.SetAdrLvlLoad      clc
                    lda $43
                    adc #>(CC_LvlStor-CC_LvlGame)   ; castle LOAD room data high - starts at $9900
                    sta $43
                    
SetRoomShapePtrX    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
; SetRoomDoorPtr    Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
SetRoomDoorPtr      pha                             ; point (40/41) to target rooms door data
                    sta SavTargRoomDoors            ; enter: target room number
                    tya
                    pha
                    
                    ldy #$04                        ; Offset 04: Pointer to RoomDoorCount
                    lda ($42),y                     ; RoomDataPtr: RoomPtrDoorCntLo
                    sta $40
                    iny
                    lda ($42),y                     ; RoomDataPtr: RoomPtrDoorCntHi
                    sta $41
                    
                    ldy #$00
                    lda ($40),y                     ; DoorNumDoors: number of doors in target room - count start at 01
                    pha
                    lda SavTargRoomDoors
                    asl a
                    asl a
                    asl a                           ; *8 - each door entry has a length of 08 bytes
                    clc
                    adc #$01                        ; +1 - door count
                    adc $40
                    sta $40
                    lda $41
                    adc #$00
                    sta $41                         ; 40/41 points to start of door data
                    
SetRoomDoorPtrX     pla
                    sta SavTargRoomDoors            ; return: target room number of doors
                    pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
SavTargRoomDoors    .byte $a1
; ------------------------------------------------------------------------------------------------------------- ;
TabSpriteDataPtr    = *

SprPlrMovRi01       dc.w DatPlrMovLe01   ; Player: Move Right Phase 01
SprPlrMovRi02       dc.w DatPlrMovLe02   ; Player: Move Right Phase 02
SprPlrMovRi03       dc.w DatPlrMovLe03   ; Player: Move Right Phase 03
                                         
SprPlrMovLe01       dc.w DatPlrMovRi01   ; Player: Move Left  Phase 01
SprPlrMovLe02       dc.w DatPlrMovRi02   ; Player: Move Left  Phase 02
SprPlrMovLe03       dc.w DatPlrMovRi03   ; Player: Move Left  Phase 03
                                         
SprPlrMovPole       dc.w DatPlrMovPole   ; Player: Pole Down
                                         
SprPlrMovLa01       dc.w DatPlrMovLa01   ; Player: Ladder u/d Phase 01
SprPlrMovLa02       dc.w DatPlrMovLa02   ; Player: Ladder u/d Phase 02
SprPlrMovLa03       dc.w DatPlrMovLa03   ; Player: Ladder u/d Phase 03
SprPlrMovLa04       dc.w DatPlrMovLa04   ; Player: Ladder u/d Phase 04
                                         
SprPlrWavGB01       dc.w DatPlrWavGB01   ; Player: Wave Good Bye Phase 01
SprPlrWavGB02       dc.w DatPlrWavGB02   ; Player: Wave Good Bye Phase 02
SprPlrWavGB03       dc.w DatPlrWavGB01   ; Player: Wave Good Bye Phase 01
SprPlrWavGB04       dc.w DatPlrWavGB04   ; Player: Wave Good Bye Phase 03
                                         
SprPlrArrRoom       dc.w DatPlrArrRo     ; Player: Room Arrived
SprPlrArrRo01       dc.w DatPlrArrRo01   ; Player: Room i/o Phase 01
SprPlrArrRo02       dc.w DatPlrArrRo02   ; Player: Room i/o Phase 02
SprPlrArrRo03       dc.w DatPlrArrRo03   ; Player: Room i/o Phase 03
SprPlrArrRo04       dc.w DatPlrArrRo04   ; Player: Room i/o Phase 04
SprPlrArrRo05       dc.w DatPlrArrRo05   ; Player: Room i/o Phase 05
                                         
SprMumMovLe01       dc.w DatMumMovLe01   ; Mummy: Move Left   Pase 01
SprMumMovLe02       dc.w DatMumMovLe02   ; Mummy: Move Left   Pase 02
SprMumMovLe03       dc.w DatMumMovLe03   ; Mummy: Move Left   Pase 03
                                         
SprMumMovRi01       dc.w DatMumMovRi01   ; Mummy: Move Right  Pase 01
SprMumMovRi02       dc.w DatMumMovRi02   ; Mummy: Move Right  Pase 02
SprMumMovRi03       dc.w DatMumMovRi03   ; Mummy: Move Right  Pase 03
                                         
SprMumMovOu01       dc.w DatMumMovOu01   ; Mummy: Out Of Wall Pase 01
SprMumMovOu02       dc.w DatMumMovOu02   ; Mummy: Out Of Wall Pase 02
SprMumMovOu03       dc.w DatMumMovOu03   ; Mummy: Out Of Wall Pase 03
SprMumMovOu04       dc.w DatMumMovOu04   ; Mummy: Out Of Wall Pase 04
SprMumMovOu05       dc.w DatMumMovOu05   ; Mummy: Out Of Wall Pase 05
SprMumMovOu06       dc.w DatMumMovOu06   ; Mummy: Out Of Wall Pase 06
                                         
SprFraMovRi01       dc.w DatFraMovRi01   ; Frankenstein: Move Right Pase 01
SprFraMovRi02       dc.w DatFraMovRi02   ; Frankenstein: Move Right Pase 02
SprFraMovRi03       dc.w DatFraMovRi03   ; Frankenstein: Move Right Pase 03

SprFraMovLe01       dc.w DatFraMovLe01   ; Frankenstein: Move Left  Pase 01
SprFraMovLe02       dc.w DatFraMovLe02   ; Frankenstein: Move Left  Pase 02
SprFraMovLe03       dc.w DatFraMovLe03   ; Frankenstein: Move Left  Pase 03
                                         
SprFraMovPole       dc.w DatFraMovPole   ; Frankenstein: Pole Down
                                         
SprFraMovLa01       dc.w DatFraMovLa01   ; Frankenstein: Ladder u/d Phase 01
SprFraMovLa02       dc.w DatFraMovLa02   ; Frankenstein: Ladder u/d Phase 02
SprFraMovLa03       dc.w DatFraMovLa03   ; Frankenstein: Ladder u/d Phase 03
SprFraMovLa04       dc.w DatFraMovLa04   ; Frankenstein: Ladder u/d Phase 04

SprFraStaCoff       dc.w DatFraStaCoff   ; Frankenstein: In Coffin
                                         
SprForMov01         dc.w DatForMov01     ; Force Field: Phase 01 (thin)
SprForMov02         dc.w DatForMov02     ; Force Field: Phase 02 (thick)
SprForMov03         dc.w DatForMov03     ; Force Field: Phase 03 (off)
                                         
SprSpaMov01         dc.w DatSpaMov01     ; Lightning Machine: Phase 01
SprSpaMov02         dc.w DatSpaMov02     ; Lightning Machine: Phase 02
SprSpaMov03         dc.w DatSpaMov03     ; Lightning Machine: Phase 03
SprSpaMov04         dc.w DatSpaMov04     ; Lightning Machine: Phase 04
                                         
SprRayMov01         dc.w DatRayMov01     ; Ray Gun: Beam
                                         
SprArrUp            dc.w DatArrUp        ; Arrow: Up
SprArrRi            dc.w DatArrRi        ; Arrow: Right
SprArrDo            dc.w DatArrDo        ; Arrow: Down
SprArrLe            dc.w DatArrLe        ; Arrow: Left
; ------------------------------------------------------------------------------------------------------------- ;
NoSprPlrMovLe01     equ  (SprPlrMovLe01   - TabSpriteDataPtr) / 2
NoSprPlrMovLe02     equ  (SprPlrMovLe02   - TabSpriteDataPtr) / 2
NoSprPlrMovLe03     equ  (SprPlrMovLe03   - TabSpriteDataPtr) / 2

NoSprPlrMovRiMin    equ  NoSprPlrMovRi01
NoSprPlrMovRiMax    equ  NoSprPlrMovRi03 + 1

NoSprPlrMovRi01     equ  (SprPlrMovRi01   - TabSpriteDataPtr) / 2
NoSprPlrMovRi02     equ  (SprPlrMovRi02   - TabSpriteDataPtr) / 2
NoSprPlrMovRi03     equ  (SprPlrMovRi03   - TabSpriteDataPtr) / 2

NoSprPlrMovLeMin    equ  NoSprPlrMovLe01
NoSprPlrMovLeMax    equ  NoSprPlrMovLe03 + 1

NoSprPlrMovLa01     equ  (SprPlrMovLa01   - TabSpriteDataPtr) / 2
NoSprPlrMovLa02     equ  (SprPlrMovLa02   - TabSpriteDataPtr) / 2
NoSprPlrMovLa03     equ  (SprPlrMovLa03   - TabSpriteDataPtr) / 2
NoSprPlrMovLa04     equ  (SprPlrMovLa04   - TabSpriteDataPtr) / 2

NoSprPlrMovLaMin    equ  NoSprPlrMovLa01
NoSprPlrMovLaMax    equ  NoSprPlrMovLa04 + 1

NoSprPlrMovPole     equ  (SprPlrMovPole   - TabSpriteDataPtr) / 2

NoSprPlrArrRoom     equ  (SprPlrArrRoom   - TabSpriteDataPtr) / 2
NoSprPlrArrRo01     equ  (SprPlrArrRo01   - TabSpriteDataPtr) / 2
NoSprPlrArrRo02     equ  (SprPlrArrRo02   - TabSpriteDataPtr) / 2
NoSprPlrArrRo03     equ  (SprPlrArrRo03   - TabSpriteDataPtr) / 2
NoSprPlrArrRo04     equ  (SprPlrArrRo04   - TabSpriteDataPtr) / 2
NoSprPlrArrRo05     equ  (SprPlrArrRo05   - TabSpriteDataPtr) / 2

NoSprPlrWavGB01     equ  (SprPlrWavGB01   - TabSpriteDataPtr) / 2
NoSprPlrWavGB02     equ  (SprPlrWavGB02   - TabSpriteDataPtr) / 2
NoSprPlrWavGB03     equ  (SprPlrWavGB01   - TabSpriteDataPtr) / 2
NoSprPlrWavGB04     equ  (SprPlrWavGB04   - TabSpriteDataPtr) / 2 - 1 
                    
NoSprPlrWavGBMin    equ  NoSprPlrWavGB01
NoSprPlrWavGBMax    equ  NoSprPlrWavGB04 + 2

NoSprMumMovLe01     equ  (SprMumMovLe01   - TabSpriteDataPtr) / 2
NoSprMumMovLe02     equ  (SprMumMovLe02   - TabSpriteDataPtr) / 2
NoSprMumMovLe03     equ  (SprMumMovLe03   - TabSpriteDataPtr) / 2

NoSprMumMovLeMin    equ  NoSprMumMovLe01
NoSprMumMovLeMax    equ  NoSprMumMovLe03 + 1

NoSprMumMovRi01     equ  (SprMumMovRi01   - TabSpriteDataPtr) / 2
NoSprMumMovRi02     equ  (SprMumMovRi02   - TabSpriteDataPtr) / 2
NoSprMumMovRi03     equ  (SprMumMovRi03   - TabSpriteDataPtr) / 2
                    
NoSprMumMovRiMin    equ  NoSprMumMovRi01
NoSprMumMovRiMax    equ  NoSprMumMovRi03 + 1

NoSprMumMovOu01     equ  (SprMumMovOu01   - TabSpriteDataPtr) / 2
NoSprMumMovOu02     equ  (SprMumMovOu02   - TabSpriteDataPtr) / 2
NoSprMumMovOu03     equ  (SprMumMovOu03   - TabSpriteDataPtr) / 2
NoSprMumMovOu04     equ  (SprMumMovOu04   - TabSpriteDataPtr) / 2
NoSprMumMovOu05     equ  (SprMumMovOu05   - TabSpriteDataPtr) / 2
NoSprMumMovOu06     equ  (SprMumMovOu06   - TabSpriteDataPtr) / 2
                    
NoSprMumMovOuMin    equ  NoSprMumMovOu01
NoSprMumMovOuMax    equ  NoSprMumMovOu06 + 1
                    
NoSprFraMovRi01     equ  (SprFraMovRi01   - TabSpriteDataPtr) / 2
NoSprFraMovRi02     equ  (SprFraMovRi02   - TabSpriteDataPtr) / 2
NoSprFraMovRi03     equ  (SprFraMovRi03   - TabSpriteDataPtr) / 2

NoSprFraMovRiMin    equ  NoSprFraMovRi01
NoSprFraMovRiMax    equ  NoSprFraMovRi03 + 1

NoSprFraMovLe01     equ  (SprFraMovLe01   - TabSpriteDataPtr) / 2
NoSprFraMovLe02     equ  (SprFraMovLe02   - TabSpriteDataPtr) / 2
NoSprFraMovLe03     equ  (SprFraMovLe03   - TabSpriteDataPtr) / 2

NoSprFraMovLeMin    equ  NoSprFraMovLe01
NoSprFraMovLeMax    equ  NoSprFraMovLe03 + 1

NoSprFraMovLa01     equ  (SprFraMovLa01   - TabSpriteDataPtr) / 2
NoSprFraMovLa02     equ  (SprFraMovLa02   - TabSpriteDataPtr) / 2
NoSprFraMovLa03     equ  (SprFraMovLa03   - TabSpriteDataPtr) / 2
NoSprFraMovLa04     equ  (SprFraMovLa04   - TabSpriteDataPtr) / 2

NoSprFraMovLaMin    equ  NoSprFraMovLa01
NoSprFraMovLaMax    equ  NoSprFraMovLa04 + 1
                    
NoSprFraMovPole     equ  (SprFraMovPole   - TabSpriteDataPtr) / 2

NoSprFraStaCoff     equ  (SprFraStaCoff   - TabSpriteDataPtr) / 2
                    
NoSprSpaMov01       equ  (SprSpaMov01     - TabSpriteDataPtr) / 2
NoSprSpaMov02       equ  (SprSpaMov02     - TabSpriteDataPtr) / 2
NoSprSpaMov03       equ  (SprSpaMov03     - TabSpriteDataPtr) / 2
NoSprSpaMov04       equ  (SprSpaMov04     - TabSpriteDataPtr) / 2
                    
NoSprSpaMovMin      equ  NoSprSpaMov01
NoSprSpaMovMax      equ  NoSprSpaMov04 + 1
                    
NoSprForMov01       equ  (SprForMov01     - TabSpriteDataPtr) / 2
NoSprForMov02       equ  (SprForMov02     - TabSpriteDataPtr) / 2
NoSprForMov03       equ  (SprForMov03     - TabSpriteDataPtr) / 2
                    
NoSprRayMov01       equ  (SprRayMov01     - TabSpriteDataPtr) / 2
                    
NoSprArrUp          equ  (SprArrUp        - TabSpriteDataPtr) / 2
NoSprArrRi          equ  (SprArrRi        - TabSpriteDataPtr) / 2
NoSprArrDo          equ  (SprArrDo        - TabSpriteDataPtr) / 2
NoSprArrLe          equ  (SprArrLe        - TabSpriteDataPtr) / 2
; ------------------------------------------------------------------------------------------------------------- ;
DatPlrMovLe01       .byte $02      ; cols (in bytes)
                    .byte $14      ; rows
                    .byte $07      ; Bit7: X-expand Bit6: Y-expand Bit5: Spr/BG-Prio Bit4: MultiColor Bits3-0: Color 0
                    .byte $02, $00 ; ......#.........
                    .byte $0a, $80 ; ....#.#.#.......
                    .byte $0a, $80 ; ....#.#.#.......
                    .byte $0a, $80 ; ....#.#.#.......
                    .byte $0a, $80 ; ....#.#.#.......
                    .byte $02, $00 ; ......#.........
                    .byte $01, $40 ; .......#.#......
                    .byte $05, $50 ; .....#.#.#.#....
                    .byte $11, $44 ; ...#...#.#...#..
                    .byte $11, $44 ; ...#...#.#...#..
                    .byte $81, $48 ; #......#.#..#...
                    .byte $01, $40 ; .......#.#......
                    .byte $03, $c0 ; ......####......
                    .byte $03, $c0 ; ......####......
                    .byte $0f, $c0 ; ....######......
                    .byte $0c, $f8 ; ....##..#####...
                    .byte $0c, $08 ; ....##......#...
                    .byte $0c, $08 ; ....##......#...
                    .byte $08, $00 ; ....#...........
                    .byte $28, $00 ; ..#.#...........
                    
DatPlrMovLe02       .byte $02
                    .byte $14
                    .byte $07
                    .byte $02, $00 ; ......#.........
                    .byte $0a, $80 ; ....#.#.#.......
                    .byte $0a, $80 ; ....#.#.#.......
                    .byte $0a, $80 ; ....#.#.#.......
                    .byte $0a, $80 ; ....#.#.#.......
                    .byte $02, $00 ; ......#.........
                    .byte $01, $40 ; .......#.#......
                    .byte $01, $50 ; .......#.#.#....
                    .byte $01, $50 ; .......#.#.#....
                    .byte $01, $50 ; .......#.#.#....
                    .byte $95, $60 ; #..#.#.#.##.....
                    .byte $01, $40 ; .......#.#......
                    .byte $03, $c0 ; ......####......
                    .byte $0c, $c0 ; ....##..##......
                    .byte $0f, $c0 ; ....######......
                    .byte $03, $d0 ; ......####.#....
                    .byte $00, $d0 ; ........##.#....
                    .byte $00, $d0 ; ........##.#....
                    .byte $00, $80 ; ........#.......
                    .byte $02, $80 ; ......#.#.......
                    
DatPlrMovLe03       .byte $02
                    .byte $14
                    .byte $07
                    .byte $02, $00 ; ......#.........
                    .byte $0a, $80 ; ....#.#.#.......
                    .byte $0a, $80 ; ....#.#.#.......
                    .byte $0a, $80 ; ....#.#.#.......
                    .byte $0a, $80 ; ....#.#.#.......
                    .byte $02, $00 ; ......#.........
                    .byte $01, $40 ; .......#.#......
                    .byte $81, $54 ; #......#.#.#.#..
                    .byte $15, $42 ; ...#.#.#.#....#.
                    .byte $01, $40 ; .......#.#......
                    .byte $01, $40 ; .......#.#......
                    .byte $01, $40 ; .......#.#......
                    .byte $0f, $c0 ; ....######......
                    .byte $3c, $c0 ; ..####..##......
                    .byte $30, $30 ; ..##......##....
                    .byte $30, $30 ; ..##......##....
                    .byte $20, $0c ; ..#.........##..
                    .byte $a0, $08 ; #.#.........#...
                    .byte $00, $28 ; ..........#.#...
                    .byte $00, $20 ; ..........#.....
                    
DatPlrMovRi01       .byte $02
                    .byte $14
                    .byte $07
                    .byte $00, $80 ; ........#.......
                    .byte $02, $a0 ; ......#.#.#.....
                    .byte $02, $a0 ; ......#.#.#.....
                    .byte $02, $a0 ; ......#.#.#.....
                    .byte $02, $a0 ; ......#.#.#.....
                    .byte $00, $80 ; ........#.......
                    .byte $01, $40 ; .......#.#......
                    .byte $05, $50 ; .....#.#.#.#....
                    .byte $11, $44 ; ...#...#.#...#..
                    .byte $11, $44 ; ...#...#.#...#..
                    .byte $21, $42 ; ..#....#.#....#.
                    .byte $01, $40 ; .......#.#......
                    .byte $03, $c0 ; ......####....##
                    .byte $03, $c0 ; ......####......
                    .byte $03, $f0 ; ......######....
                    .byte $2f, $30 ; ..#.####..##....
                    .byte $20, $30 ; ..#.......##....
                    .byte $20, $30 ; ..#.......##....
                    .byte $00, $20 ; ..........#.....
                    .byte $00, $28 ; ..........#.#...
                    
DatPlrMovRi02       .byte $02
                    .byte $14
                    .byte $07
                    .byte $00, $80 ; ........#.......
                    .byte $02, $a0 ; ......#.#.#.....
                    .byte $02, $a0 ; ......#.#.#.....
                    .byte $02, $a0 ; ......#.#.#.....
                    .byte $02, $a0 ; ......#.#.#.....
                    .byte $00, $80 ; ........#.......
                    .byte $01, $40 ; .......#.#......
                    .byte $05, $40 ; .....#.#.#......
                    .byte $05, $40 ; .....#.#.#......
                    .byte $05, $40 ; .....#.#.#......
                    .byte $09, $56 ; ....#..#.#.#.##.
                    .byte $01, $40 ; .......#.#......
                    .byte $03, $c0 ; ......####......
                    .byte $03, $30 ; ......##..##....
                    .byte $03, $f0 ; ......######....
                    .byte $0b, $c0 ; ....#.####......
                    .byte $0b, $00 ; ....#.##........
                    .byte $0b, $00 ; ....#.##........
                    .byte $02, $00 ; ......#.........
                    .byte $02, $80 ; ......#.#.......
                    
DatPlrMovRi03       .byte $02
                    .byte $14
                    .byte $07
                    .byte $00, $80 ; ........#.......
                    .byte $02, $a0 ; ......#.#.#.....
                    .byte $02, $a0 ; ......#.#.#.....
                    .byte $02, $a0 ; ......#.#.#.....
                    .byte $02, $a0 ; ......#.#.#.....
                    .byte $00, $80 ; ........#.......
                    .byte $01, $40 ; .......#.#......
                    .byte $15, $42 ; ...#.#.#.#....#.
                    .byte $81, $54 ; #......#.#.#.#..
                    .byte $01, $40 ; .......#.#......
                    .byte $01, $40 ; .......#.#......
                    .byte $01, $40 ; .......#.#......
                    .byte $03, $f0 ; ......######....
                    .byte $03, $3c ; ......##..####..
                    .byte $0c, $0c ; ....##......##..
                    .byte $0c, $0c ; ....##......##..
                    .byte $30, $08 ; ..##........#...
                    .byte $20, $0a ; ..#.........#.#.
                    .byte $28, $00 ; ..#.#...........
                    .byte $08, $00 ; ....#...........
                    
DatPlrMovLa01       .byte $02
                    .byte $14
                    .byte $07
                    .byte $00, $08 ; ............#...
                    .byte $00, $04 ; .............#..
                    .byte $02, $84 ; ......#.#....#..
                    .byte $0a, $a4 ; ....#.#.#.#..#..
                    .byte $2a, $a4 ; ..#.#.#.#.#..#..
                    .byte $4a, $a0 ; .#..#.#.#.#.....
                    .byte $42, $80 ; .#....#.#.......
                    .byte $41, $40 ; .#.....#.#......
                    .byte $15, $50 ; ...#.#.#.#.#....
                    .byte $05, $50 ; .....#.#.#.#....
                    .byte $05, $50 ; .....#.#.#.#....
                    .byte $05, $50 ; .....#.#.#.#....
                    .byte $0f, $f0 ; ....########....
                    .byte $0f, $fc ; ....##########..
                    .byte $0c, $0c ; ....##......##..
                    .byte $0c, $0c ; ....##......##..
                    .byte $32, $c0 ; ..##..#.##......
                    .byte $3c, $00 ; ..####..........
                    .byte $3a, $00 ; ..###.#.........
                    .byte $02, $00 ; ......#.........
                    
DatPlrMovLa02        .byte $02
                    .byte $14
                    .byte $07
                    .byte $00, $00 ; ................
                    .byte $00, $00 ; ................
                    .byte $02, $88 ; ......#.#...#...
                    .byte $0a, $a4 ; ....#.#.#.#..#..
                    .byte $0a, $a4 ; ....#.#.#.#..#..
                    .byte $0a, $a4 ; ....#.#.#.#..#..
                    .byte $22, $84 ; ..#...#.#....#..
                    .byte $11, $40 ; ...#...#.#......
                    .byte $15, $50 ; ...#.#.#.#.#....
                    .byte $05, $50 ; .....#.#.#.#....
                    .byte $05, $50 ; .....#.#.#.#....
                    .byte $05, $50 ; .....#.#.#.#....
                    .byte $0f, $f0 ; ....########....
                    .byte $0f, $f0 ; ....########....
                    .byte $30, $0c ; ..##........##..
                    .byte $30, $0c ; ..##........##..
                    .byte $30, $0c ; ..##........##..
                    .byte $20, $08 ; ..#.........#...
                    .byte $0a, $a0 ; ....#.#.#.#.....
                    .byte $00, $00 ; ................
                    
DatPlrMovLa03        .byte $02
                    .byte $14
                    .byte $07
                    .byte $20, $00 ; ..#.............
                    .byte $10, $00 ; ...#............
                    .byte $12, $80 ; ...#..#.#.......
                    .byte $1a, $a0 ; ...##.#.#.#.....
                    .byte $1a, $a8 ; ...##.#.#.#.#...
                    .byte $0a, $a1 ; ....#.#.#.#....#
                    .byte $02, $81 ; ......#.#......#
                    .byte $01, $41 ; .......#.#.....#
                    .byte $05, $54 ; .....#.#.#.#.#..
                    .byte $05, $50 ; .....#.#.#.#....
                    .byte $05, $50 ; .....#.#.#.#....
                    .byte $05, $50 ; .....#.#.#.#....
                    .byte $0f, $f0 ; ....########....
                    .byte $3f, $f0 ; ..##########....
                    .byte $30, $30 ; ..##......##....
                    .byte $30, $30 ; ..##......##....
                    .byte $08, $3c ; ....#.....####..
                    .byte $00, $3c ; ..........####..
                    .byte $00, $ac ; ........#.#.##..
                    .byte $00, $08 ; ............#...
                    
DatPlrMovLa04        .byte $02
                    .byte $14
                    .byte $07
                    .byte $00, $00 ; ................
                    .byte $00, $00 ; ................
                    .byte $22, $80 ; ..#...#.#.......
                    .byte $1a, $a0 ; ...##.#.#.#.....
                    .byte $1a, $a0 ; ...##.#.#.#.....
                    .byte $1a, $a0 ; ...##.#.#.#.....
                    .byte $12, $88 ; ...#..#.#...#...
                    .byte $01, $44 ; .......#.#...#..
                    .byte $05, $54 ; .....#.#.#.#.#..
                    .byte $05, $50 ; .....#.#.#.#....
                    .byte $05, $50 ; .....#.#.#.#....
                    .byte $05, $50 ; .....#.#.#.#....
                    .byte $0f, $f0 ; ....########....
                    .byte $0f, $f0 ; ....########....
                    .byte $30, $0c ; ..##........##..
                    .byte $30, $0c ; ..##........##..
                    .byte $30, $0c ; ..##........##..
                    .byte $20, $0c ; ..#.........##..
                    .byte $0a, $a0 ; ....#.#.#.#.....
                    .byte $00, $00 ; ................
                    
DatPlrMovPole       .byte $02
                    .byte $14
                    .byte $07
                    .byte $02, $00 ; ......#.........
                    .byte $04, $40 ; .....#...#......
                    .byte $12, $10 ; ...#..#....#....
                    .byte $1a, $90 ; ...##.#.#..#....
                    .byte $1a, $90 ; ...##.#.#..#....
                    .byte $1a, $90 ; ...##.#.#..#....
                    .byte $12, $10 ; ...#..#....#....
                    .byte $15, $50 ; ...#.#.#.#.#....
                    .byte $05, $40 ; .....#.#.#......
                    .byte $05, $40 ; .....#.#.#......
                    .byte $05, $40 ; .....#.#.#......
                    .byte $05, $40 ; .....#.#.#......
                    .byte $05, $40 ; .....#.#.#......
                    .byte $0f, $c0 ; ....######......
                    .byte $0f, $c0 ; ....######......
                    .byte $3c, $f0 ; ..####..####....
                    .byte $30, $30 ; ..##......##....
                    .byte $0c, $c0 ; ....##..##......
                    .byte $02, $00 ; ......#.........
                    .byte $08, $80 ; ....#...#.......
                    
DatPlrArrRo         .byte $02
                    .byte $14
                    .byte $07
                    .byte $00, $80 ; ........#.......
                    .byte $02, $a0 ; ......#.#.#.....
                    .byte $02, $a0 ; ......#.#.#.....
                    .byte $02, $a0 ; ......#.#.#.....
                    .byte $02, $a0 ; ......#.#.#.....
                    .byte $00, $80 ; ........#.......
                    .byte $01, $40 ; .......#.#......
                    .byte $05, $48 ; .....#.#.#..#...
                    .byte $21, $50 ; ..#....#.#.#....
                    .byte $01, $40 ; .......#.#......
                    .byte $01, $40 ; .......#.#......
                    .byte $01, $40 ; .......#.#......
                    .byte $03, $c0 ; ......####......
                    .byte $03, $f0 ; ......######....
                    .byte $03, $30 ; ......##..##....
                    .byte $0c, $30 ; ....##....##....
                    .byte $0c, $20 ; ....##....#.....
                    .byte $08, $20 ; ....#.....#.....
                    .byte $0a, $00 ; ....#.#.........
                    .byte $02, $00 ; ......#.........
                    
DatPlrArrRo01       .byte $02
                    .byte $11
                    .byte $07
                    .byte $00, $80 ; ........#.......
                    .byte $02, $a0 ; ......#.#.#.....
                    .byte $02, $a0 ; ......#.#.#.....
                    .byte $02, $a0 ; ......#.#.#.....
                    .byte $00, $80 ; ........#.......
                    .byte $01, $40 ; .......#.#......
                    .byte $05, $50 ; .....#.#.#.#....
                    .byte $05, $50 ; .....#.#.#.#....
                    .byte $05, $50 ; .....#.#.#.#....
                    .byte $09, $68 ; ....#..#.##.#...
                    .byte $03, $c0 ; ......####......
                    .byte $03, $c0 ; ......####......
                    .byte $03, $f0 ; ......######....
                    .byte $0f, $30 ; ....####..##....
                    .byte $08, $30 ; ....#.....##....
                    .byte $08, $20 ; ....#.....#.....
                    .byte $00, $20 ; ..........#.....
                    
DatPlrArrRo02       .byte $02
                    .byte $0d
                    .byte $07
                    .byte $02, $80 ; ......#.#.......
                    .byte $02, $80 ; ......#.#.......
                    .byte $02, $80 ; ......#.#.......
                    .byte $02, $00 ; ......#.........
                    .byte $01, $40 ; .......#.#......
                    .byte $05, $40 ; .....#.#.#......
                    .byte $09, $60 ; ....#..#.##.....
                    .byte $01, $40 ; .......#.#......
                    .byte $03, $c0 ; ......####......
                    .byte $03, $f0 ; ......######....
                    .byte $0b, $c0 ; ....#.####......
                    .byte $0a, $00 ; ....#.#.........
                    .byte $02, $80 ; ......#.#.......
                    
DatPlrArrRo03       .byte $02
                    .byte $0a
                    .byte $07
                    .byte $02, $80 ; ......#.#.......
                    .byte $02, $80 ; ......#.#.......
                    .byte $02, $00 ; ......#.........
                    .byte $01, $40 ; .......#.#......
                    .byte $05, $60 ; .....#.#.##.....
                    .byte $01, $40 ; .......#.#......
                    .byte $03, $c0 ; ......####......
                    .byte $03, $30 ; ......##..##....
                    .byte $03, $30 ; ......##..##....
                    .byte $02, $20 ; ......#...#.....
                    
DatPlrArrRo04       .byte $02
                    .byte $07
                    .byte $07
                    .byte $00, $80 ; ........#.......
                    .byte $00, $a0 ; ........#.#.....
                    .byte $00, $40 ; .........#......
                    .byte $01, $50 ; .......#.#.#....
                    .byte $00, $c0 ; ........##......
                    .byte $02, $c0 ; ......#.##......
                    .byte $00, $c0 ; ........##......
                    
DatPlrArrRo05       .byte $02
                    .byte $04
                    .byte $07
                    .byte $00, $00 ; ................
                    .byte $01, $00 ; .......#........
                    .byte $03, $00 ; ......##........
                    .byte $02, $00 ; ......#.........
                    
DatPlrWavGB01       .byte $02
                    .byte $15
                    .byte $07
                    .byte $00, $08 ; ............#...
                    .byte $02, $08 ; ......#.....#...
                    .byte $0a, $84 ; ....#.#.#....#..
                    .byte $0a, $84 ; ....#.#.#....#..
                    .byte $0a, $84 ; ....#.#.#....#..
                    .byte $0a, $84 ; ....#.#.#....#..
                    .byte $02, $04 ; ......#......#..
                    .byte $05, $50 ; .....#.#.#.#....
                    .byte $15, $40 ; ...#.#.#.#......
                    .byte $45, $40 ; .#...#.#.#......
                    .byte $45, $40 ; .#...#.#.#......
                    .byte $45, $40 ; .#...#.#.#......
                    .byte $25, $40 ; ..#..#.#.#......
                    .byte $0f, $c0 ; ....######......
                    .byte $0f, $c0 ; ....######......
                    .byte $0c, $c0 ; ....##..##......
                    .byte $0c, $c0 ; ....##..##......
                    .byte $0c, $c0 ; ....##..##......
                    .byte $0c, $c0 ; ....##..##......
                    .byte $28, $a0 ; ..#.#...#.#.....
                    .byte $20, $20 ; ..#.......#.....
                    
DatPlrWavGB02       .byte $02
                    .byte $15
                    .byte $07
                    .byte $00, $02 ; ..............#.
                    .byte $02, $02 ; ......#.......#.
                    .byte $0a, $81 ; ....#.#.#......#
                    .byte $0a, $84 ; ....#.#.#....#..
                    .byte $0a, $84 ; ....#.#.#....#..
                    .byte $0a, $84 ; ....#.#.#....#..
                    .byte $02, $04 ; ......#......#..
                    .byte $05, $50 ; .....#.#.#.#....
                    .byte $15, $40 ; ...#.#.#.#......
                    .byte $45, $40 ; .#...#.#.#......
                    .byte $45, $40 ; .#...#.#.#......
                    .byte $45, $40 ; .#...#.#.#......
                    .byte $25, $40 ; ..#..#.#.#......
                    .byte $0f, $c0 ; ....######......
                    .byte $0f, $c0 ; ....######......
                    .byte $0c, $c0 ; ....##..##......
                    .byte $0c, $c0 ; ....##..##......
                    .byte $0c, $c0 ; ....##..##......
                    .byte $0c, $c0 ; ....##..##......
                    .byte $28, $a0 ; ..#.#...#.#.....
                    .byte $20, $20 ; ..#.......#.....
                    
DatPlrWavGB04       .byte $02
                    .byte $15
                    .byte $07
                    .byte $00, $20 ; ..........#.....
                    .byte $02, $20 ; ......#...#.....
                    .byte $0a, $90 ; ....#.#.#..#....
                    .byte $0a, $84 ; ....#.#.#....#..
                    .byte $0a, $84 ; ....#.#.#....#..
                    .byte $0a, $84 ; ....#.#.#....#..
                    .byte $02, $04 ; ......#......#..
                    .byte $05, $50 ; .....#.#.#.#....
                    .byte $15, $40 ; ...#.#.#.#......
                    .byte $45, $40 ; .#...#.#.#......
                    .byte $45, $40 ; .#...#.#.#......
                    .byte $45, $40 ; .#...#.#.#......
                    .byte $25, $40 ; ..#..#.#.#......
                    .byte $0f, $c0 ; ....######......
                    .byte $0f, $c0 ; ....######......
                    .byte $0c, $c0 ; ....##..##......
                    .byte $0c, $c0 ; ....##..##......
                    .byte $0c, $c0 ; ....##..##......
                    .byte $0c, $c0 ; ....##..##......
                    .byte $28, $a0 ; ..#.#...#.#.....
                    .byte $20, $20 ; ..#.......#.....
                    
DatFraMovRi01       .byte $02
                    .byte $14
                    .byte $0c
                    .byte $01, $50 ; .......#.#.#....
                    .byte $03, $f0 ; ......######....
                    .byte $03, $f0 ; ......######....
                    .byte $03, $f0 ; ......######....
                    .byte $03, $f0 ; ......######....
                    .byte $00, $c0 ; ........##......
                    .byte $02, $a0 ; ......#.#.#.....
                    .byte $0a, $88 ; ....#.#.#...#...
                    .byte $22, $88 ; ..#...#.#...#...
                    .byte $22, $8c ; ..#...#.#...##..
                    .byte $32, $80 ; ..##..#.#.......
                    .byte $01, $40 ; .......#.#......
                    .byte $02, $80 ; ......#.#.......
                    .byte $02, $80 ; ......#.#.......
                    .byte $02, $a0 ; ......#.#.#.....
                    .byte $02, $20 ; ......#...#.....
                    .byte $08, $20 ; ....#.....#.....
                    .byte $0f, $20 ; ....####..#.....
                    .byte $0f, $3c ; ....####..####..
                    .byte $00, $3c ; ..........####..
                    
DatFraMovRi02       .byte $02
                    .byte $14
                    .byte $0c
                    .byte $01, $50 ; .......#.#.#....
                    .byte $03, $f0 ; ......######....
                    .byte $03, $f0 ; ......######....
                    .byte $03, $f0 ; ......######....
                    .byte $03, $f0 ; ......######....
                    .byte $00, $c0 ; ........##......
                    .byte $02, $a0 ; ......#.#.#.....
                    .byte $0a, $88 ; ....#.#.#...#...
                    .byte $22, $88 ; ..#...#.#...#...
                    .byte $22, $8c ; ..#...#.#...##..
                    .byte $32, $80 ; ..##..#.#.......
                    .byte $01, $40 ; .......#.#......
                    .byte $02, $80 ; ......#.#.......
                    .byte $02, $20 ; ......#...#.....
                    .byte $02, $20 ; ......#...#.....
                    .byte $02, $80 ; ......#.#.......
                    .byte $0e, $00 ; ....###.........
                    .byte $0e, $00 ; ....###.........
                    .byte $03, $c0 ; ......####......
                    .byte $03, $c0 ; ......####......
                    
DatFraMovRi03       .byte $02
                    .byte $14
                    .byte $0c
                    .byte $01, $50 ; .......#.#.#....
                    .byte $03, $f0 ; ......######....
                    .byte $03, $f0 ; ......######....
                    .byte $03, $f0 ; ......######....
                    .byte $03, $f0 ; ......######....
                    .byte $00, $c0 ; ........##......
                    .byte $02, $a0 ; ......#.#.#.....
                    .byte $0a, $88 ; ....#.#.#...#...
                    .byte $22, $88 ; ..#...#.#...#...
                    .byte $22, $8c ; ..#...#.#...##..
                    .byte $32, $80 ; ..##..#.#.......
                    .byte $01, $40 ; .......#.#......
                    .byte $02, $80 ; ......#.#.......
                    .byte $02, $a0 ; ......#.#.#.....
                    .byte $02, $20 ; ......#...#.....
                    .byte $08, $20 ; ....#.....#.....
                    .byte $08, $3c ; ....#.....####..
                    .byte $08, $3c ; ....#.....####..
                    .byte $0f, $00 ; ....####........
                    .byte $0f, $00 ; ....####........
                    
DatFraMovLe01       .byte $02
                    .byte $14
                    .byte $0c
                    .byte $05, $40 ; .....#.#.#......
                    .byte $0f, $c0 ; ....######......
                    .byte $0f, $c0 ; ....######......
                    .byte $0f, $c0 ; ....######......
                    .byte $0f, $c0 ; ....######......
                    .byte $03, $00 ; ......##........
                    .byte $02, $a0 ; ......#.#.#.....
                    .byte $0a, $88 ; ....#.#.#...#...
                    .byte $22, $88 ; ..#...#.#...#...
                    .byte $22, $8c ; ..#...#.#...##..
                    .byte $32, $80 ; ..##..#.#.......
                    .byte $01, $40 ; .......#.#......
                    .byte $02, $80 ; ......#.#.......
                    .byte $02, $80 ; ......#.#.......
                    .byte $0a, $80 ; ....#.#.#.......
                    .byte $08, $80 ; ....#...#.......
                    .byte $08, $20 ; ....#.....#.....
                    .byte $08, $f0 ; ....#...####....
                    .byte $3c, $f0 ; ..####..####....
                    .byte $3c, $00 ; ..####..####....
                    
DatFraMovLe02       .byte $02
                    .byte $14
                    .byte $0c
                    .byte $05, $40 ; .....#.#.#......
                    .byte $0f, $c0 ; ....######......
                    .byte $0f, $c0 ; ....######......
                    .byte $0f, $c0 ; ....######......
                    .byte $0f, $c0 ; ....######......
                    .byte $03, $00 ; ......##........
                    .byte $02, $a0 ; ......#.#.#.....
                    .byte $0a, $88 ; ....#.#.#...#...
                    .byte $22, $88 ; ..#...#.#...#...
                    .byte $22, $8c ; ..#...#.#...##..
                    .byte $32, $80 ; ..##..#.#.......
                    .byte $01, $40 ; .......#.#......
                    .byte $02, $80 ; ......#.#.......
                    .byte $08, $80 ; ....#...#.......
                    .byte $08, $80 ; ....#...#.......
                    .byte $02, $80 ; ......#.#.......
                    .byte $00, $b0 ; ........#.##....
                    .byte $00, $b0 ; ........#.##....
                    .byte $03, $c0 ; ......####......
                    .byte $03, $c0 ; ......####......
                    
DatFraMovLe03       .byte $02
                    .byte $14
                    .byte $0c
                    .byte $05, $40 ; .....#.#.#......
                    .byte $0f, $c0 ; ....######......
                    .byte $0f, $c0 ; ....######......
                    .byte $0f, $c0 ; ....######......
                    .byte $0f, $c0 ; ....######......
                    .byte $03, $00 ; ......##........
                    .byte $02, $a0 ; ......#.#.#.....
                    .byte $0a, $88 ; ....#.#.#...#...
                    .byte $22, $88 ; ..#...#.#...#...
                    .byte $22, $8c ; ..#...#.#...##..
                    .byte $32, $80 ; ..##..#.#.......
                    .byte $01, $40 ; .......#.#......
                    .byte $02, $80 ; ......#.#.......
                    .byte $0a, $80 ; ....#.#.#.......
                    .byte $08, $80 ; ....#...#.......
                    .byte $08, $20 ; ....#.....#.....
                    .byte $3c, $20 ; ..####....#.....
                    .byte $3c, $20 ; ..####....#.....
                    .byte $00, $f0 ; ........####....
                    .byte $00, $f0 ; ........####....
                    
DatFraMovPole       .byte $02
                    .byte $14
                    .byte $0c
                    .byte $03, $00 ; ......##........
                    .byte $08, $80 ; ....#...#.......
                    .byte $25, $60 ; ..#..#.#.##.....
                    .byte $2f, $e0 ; ..#.#######.....
                    .byte $2f, $e0 ; ..#.#######.....
                    .byte $2f, $e0 ; ###.#######.....
                    .byte $23, $20 ; ..#...##..#.....
                    .byte $2a, $a0 ; ..#.#.#.#.#.....
                    .byte $0a, $80 ; ....#.#.#.......
                    .byte $0a, $80 ; ....#.#.#.......
                    .byte $0a, $80 ; ....#.#.#.......
                    .byte $0a, $80 ; ....#.#.#.......
                    .byte $0a, $80 ; ....#.#.#.......
                    .byte $05, $40 ; .....#.#.#......
                    .byte $0a, $80 ; ....#.#.#.......
                    .byte $28, $a0 ; ..#.#...#.#.....
                    .byte $20, $20 ; ..#.......#.....
                    .byte $08, $80 ; ....#...#.......
                    .byte $0f, $c0 ; ....######......
                    .byte $0c, $c0 ; ....##..##......
                    
DatFraMovLa01       .byte $02
                    .byte $14
                    .byte $0c
                    .byte $00, $0c ; ............##..
                    .byte $00, $80 ; ........#.......
                    .byte $05, $58 ; .....#.#.#.##...
                    .byte $0f, $f8 ; ....#########...
                    .byte $3f, $80 ; ..#######.......
                    .byte $8f, $f0 ; #...########....
                    .byte $83, $c0 ; #.....####......
                    .byte $82, $80 ; #.....#.#.......
                    .byte $2a, $a0 ; ..#.#.#.#.#.....
                    .byte $0a, $a0 ; ....#.#.#.#.....
                    .byte $0a, $a0 ; ....#.#.#.#.....
                    .byte $0a, $a0 ; ....#.#.#.#.....
                    .byte $05, $50 ; .....#.#.#.#....
                    .byte $02, $80 ; ......#.#.......
                    .byte $02, $20 ; ......#...#.....
                    .byte $02, $08 ; ......#.....#...
                    .byte $02, $3c ; ......#...####..
                    .byte $02, $3c ; ......#...####..
                    .byte $03, $c0 ; ......####......
                    .byte $03, $c0 ; ......####......
                    
DatFraMovLa02       .byte $02
                    .byte $14
                    .byte $0c
                    .byte $00, $00 ; ................
                    .byte $00, $00 ; ................
                    .byte $05, $5c ; .....#.#.#.###..
                    .byte $0f, $f8 ; ....#########...
                    .byte $0f, $f8 ; ....#########...
                    .byte $0f, $f8 ; ....#########...
                    .byte $33, $c8 ; ..##..####..#...
                    .byte $22, $80 ; ..#...#.#.......
                    .byte $2a, $a0 ; ..#.#.#.#.#.....
                    .byte $0a, $a0 ; ....#.#.#.#.....
                    .byte $0a, $a0 ; ....#.#.#.#.....
                    .byte $0a, $a0 ; ....#.#.#.#.....
                    .byte $05, $50 ; .....#.#.#.#....
                    .byte $02, $80 ; ......#.#.......
                    .byte $02, $80 ; ......#.#.......
                    .byte $02, $80 ; ......#.#.......
                    .byte $02, $80 ; ......#.#.......
                    .byte $03, $c0 ; ......####......
                    .byte $03, $c0 ; ......####......
                    .byte $00, $00 ; ................
                    
DatFraMovLa03       .byte $02
                    .byte $14
                    .byte $0c
                    .byte $30, $00 ; ..##............
                    .byte $20, $00 ; ..#.............
                    .byte $25, $50 ; ..#..#.#.#.#....
                    .byte $2f, $f0 ; ..#.########....
                    .byte $2f, $fc ; ..#.##########..
                    .byte $0f, $f2 ; ....########..#.
                    .byte $03, $c2 ; ......####....#.
                    .byte $02, $82 ; ......#.#.....#.
                    .byte $0a, $a8 ; ....#.#.#.#.#...
                    .byte $0a, $a0 ; ....#.#.#.#.....
                    .byte $0a, $a0 ; ....#.#.#.#.....
                    .byte $0a, $a0 ; ....#.#.#.#.....
                    .byte $05, $50 ; .....#.#.#.#....
                    .byte $02, $80 ; ......#.#.......
                    .byte $08, $80 ; ....#...#.......
                    .byte $02, $80 ; ......#.#.......
                    .byte $3c, $80 ; ..####..#.......
                    .byte $3c, $80 ; ..####..#.......
                    .byte $03, $c0 ; ......####....##
                    .byte $03, $c0 ; ......####......
                    
DatFraMovLa04       .byte $02
                    .byte $14
                    .byte $0c
                    .byte $00, $00 ; ................
                    .byte $00, $00 ; ................
                    .byte $35, $50 ; ..##.#.#.#.#..##
                    .byte $2f, $f0 ; ..#.########....
                    .byte $2f, $f0 ; ..#.########....
                    .byte $2f, $f0 ; ..#.########....
                    .byte $23, $cc ; ..#...####..##..
                    .byte $02, $88 ; ......#.#...#...
                    .byte $0a, $a8 ; ....#.#.#.#.#...
                    .byte $0a, $a0 ; ....#.#.#.#.....
                    .byte $0a, $a0 ; ....#.#.#.#.....
                    .byte $0a, $a0 ; ....#.#.#.#.....
                    .byte $05, $50 ; .....#.#.#.#....
                    .byte $02, $80 ; ......#.#.......
                    .byte $02, $80 ; ......#.#.......
                    .byte $02, $80 ; ......#.#.......
                    .byte $02, $80 ; ......#.#.......
                    .byte $03, $c0 ; ......####......
                    .byte $03, $c0 ; ......####......
                    .byte $00, $00 ; ................
                    
DatFraStaCoff       .byte $02
                    .byte $14
                    .byte $0c
                    .byte $01, $50 ; .......#.#.#....
                    .byte $03, $f0 ; ......######....
                    .byte $03, $f0 ; ......######....
                    .byte $03, $f0 ; ......######....
                    .byte $03, $f0 ; ......######....
                    .byte $00, $c0 ; ........##......
                    .byte $02, $a0 ; ......#.#.#.....
                    .byte $0a, $a0 ; ....#.#.#.#.....
                    .byte $0a, $a0 ; ....#.#.#.#.....
                    .byte $0a, $a0 ; ....#.#.#.#.....
                    .byte $0a, $b0 ; ....#.#.#.##....
                    .byte $0d, $40 ; ....##.#.#......
                    .byte $02, $80 ; ......#.#.......
                    .byte $02, $80 ; ......#.#.......
                    .byte $02, $80 ; ......#.#.......
                    .byte $02, $80 ; ......#.#.......
                    .byte $02, $d0 ; ......#.##.#....
                    .byte $02, $f0 ; ......#.####....
                    .byte $03, $c0 ; ......####......
                    .byte $03, $c0 ; ......####......
                    
DatMumMovOu01       .byte $01
                    .byte $02
                    .byte $11
                    .byte $1e ; ...####.
                    .byte $3e ; ..#####.
                    
DatMumMovOu02       .byte $02
                    .byte $04
                    .byte $11
                    .byte $f7, $c0 ; ####.#####......
                    .byte $ff, $c0 ; ##########......
                    .byte $1f, $c0 ; ...#######......
                    .byte $3f, $80 ; ..#######.......
                    
DatMumMovOu03       .byte $02
                    .byte $06
                    .byte $11
                    .byte $01, $fc ; .......#######..
                    .byte $63, $fc ; .##...########..
                    .byte $f7, $fc ; ####.#########..
                    .byte $ff, $fc ; ##############..
                    .byte $1f, $fc ; ...###########..
                    .byte $3f, $80 ; ..#######.......
                    
DatMumMovOu04       .byte $03
                    .byte $06
                    .byte $11
                    .byte $01, $fc, $00 ; .......#######..........
                    .byte $63, $ff, $00 ; .##...##########........
                    .byte $f7, $ff, $c0 ; ####.###.###.#####......
                    .byte $ff, $ff, $c0 ; ##################......
                    .byte $1f, $fe, $00 ; ...############.........
                    .byte $3f, $80, $00 ; ..#######...............
                    
DatMumMovOu05       .byte $03
                    .byte $06
                    .byte $11
                    .byte $01, $fc, $00 ; .......#######..........
                    .byte $63, $ff, $00 ; .##...##########........
                    .byte $f7, $ff, $fc ; ####.#################..
                    .byte $ff, $ff, $fc ; ######################..
                    .byte $1f, $fe, $00 ; ...############.........
                    .byte $3f, $80, $00 ; ..#######...............
                    
DatMumMovOu06       .byte $03
                    .byte $06
                    .byte $11
                    .byte $01, $fc, $00 ; .......#######..........
                    .byte $63, $ff, $03 ; .##...##########......##
                    .byte $f7, $ff, $ff ; ####.###################
                    .byte $ff, $ff, $fe ; #######################.
                    .byte $1f, $fe, $00 ; ...############.........
                    .byte $3f, $80, $00 ; ..#######...............
                    
DatMumMovLe01       .byte $02
                    .byte $14
                    .byte $11
                    .byte $00, $30 ; ..........##....
                    .byte $00, $f8 ; ........#####...
                    .byte $00, $f8 ; ........#####...
                    .byte $00, $f8 ; ........#####...
                    .byte $00, $f8 ; ........#####...
                    .byte $00, $38 ; ..........###...
                    .byte $0f, $f8 ; ....#########...
                    .byte $00, $fc ; ........######..
                    .byte $0f, $fc ; ....##########..
                    .byte $00, $3c ; ..........####..
                    .byte $00, $3c ; ..........####..
                    .byte $00, $3c ; ..........####..
                    .byte $00, $3c ; ..........####..
                    .byte $00, $7c ; .........#####..
                    .byte $00, $6e ; .........##.###.
                    .byte $00, $66 ; .........##..##.
                    .byte $00, $c6 ; ........##...##.
                    .byte $00, $cf ; ........##..####
                    .byte $03, $cf ; ......####..####
                    .byte $03, $c0 ; ......####......
                    
DatMumMovLe02       .byte $02
                    .byte $14
                    .byte $11
                    .byte $00, $30 ; ..........##....
                    .byte $00, $f8 ; ........#####...
                    .byte $00, $f8 ; ........#####...
                    .byte $00, $f8 ; ........#####...
                    .byte $00, $f8 ; ........#####...
                    .byte $0e, $38 ; ....###...###...
                    .byte $01, $f8 ; .......######...
                    .byte $00, $3c ; ..........####..
                    .byte $01, $fc ; .......#######..
                    .byte $0e, $3c ; ....###...####..
                    .byte $00, $3c ; ..........####..
                    .byte $00, $3c ; ..........####..
                    .byte $00, $3c ; ..........####..
                    .byte $00, $3c ; ..........####..
                    .byte $00, $3c ; ..........####..
                    .byte $00, $f8 ; ........#####...
                    .byte $00, $fc ; ........######..
                    .byte $00, $0c ; ............##..
                    .byte $00, $3c ; ..........####..
                    .byte $00, $3c ; ..........####..
                    
DatMumMovLe03       .byte $02
                    .byte $14
                    .byte $11
                    .byte $00, $30 ; ..........##....
                    .byte $00, $f8 ; ........#####...
                    .byte $00, $f8 ; ........#####...
                    .byte $00, $f8 ; ........#####...
                    .byte $00, $f8 ; ........#####...
                    .byte $00, $38 ; ..........###...
                    .byte $00, $f8 ; ........#####...
                    .byte $0f, $3c ; ....####..####..
                    .byte $0f, $fc ; ....##########..
                    .byte $00, $3c ; ..........####..
                    .byte $00, $3c ; ..........####..
                    .byte $00, $3c ; ..........####..
                    .byte $00, $3c ; ..........####..
                    .byte $00, $3c ; ..........####..
                    .byte $00, $36 ; ..........##.##.
                    .byte $00, $36 ; ..........##.##.
                    .byte $00, $33 ; ..........##..##
                    .byte $00, $f3 ; ........####..##
                    .byte $00, $f7 ; ........####.###
                    .byte $00, $07 ; .............###
                    
DatMumMovRi01       .byte $03, $14, $11 ;
                    .byte $00, $0c, $00 ; ............##..........
                    .byte $00, $1f, $00 ; ...........#####........
                    .byte $00, $1f, $00 ; ...........#####........
                    .byte $00, $1f, $00 ; ...........#####........
                    .byte $00, $1f, $00 ; ...........#####........
                    .byte $00, $1c, $00 ; ...........###..........
                    .byte $00, $1f, $f0 ; ...........#########....
                    .byte $00, $3c, $00 ; ..........####..........
                    .byte $00, $3f, $f0 ; ..........######........
                    .byte $00, $3c, $00 ; ..........####..........
                    .byte $00, $3c, $00 ; ..........####..........
                    .byte $00, $3c, $00 ; ..........####..........
                    .byte $00, $3c, $00 ; ..........####..........
                    .byte $00, $3e, $00 ; ..........#####.........
                    .byte $00, $76, $00 ; .........###.##.........
                    .byte $00, $66, $00 ; .........##..##.........
                    .byte $00, $63, $00 ; .........##...##........
                    .byte $00, $f3, $00 ; ........####..##........
                    .byte $00, $f3, $c0 ; ........####..##........
                    .byte $00, $03, $c0 ; ..............####......
                    
DatMumMovRi02       .byte $03, $14, $11
                    .byte $00, $0c, $00 ; ............##..........
                    .byte $00, $1f, $00 ; ...........#####........
                    .byte $00, $1f, $00 ; ...........#####........
                    .byte $00, $1f, $00 ; ...........#####........
                    .byte $00, $1f, $00 ; ...........#####........
                    .byte $00, $1c, $70 ; ...........###...###....
                    .byte $00, $1f, $80 ; ...........######.......
                    .byte $00, $3c, $00 ; ..........####..........
                    .byte $00, $3f, $80 ; ..........#######.......
                    .byte $00, $3c, $f0 ; ..........####..####....
                    .byte $00, $3c, $00 ; ..........####..........
                    .byte $00, $3c, $00 ; ..........####..........
                    .byte $00, $3c, $00 ; ..........####..........
                    .byte $00, $3c, $00 ; ..........####..........
                    .byte $00, $3c, $00 ; ..........####..........
                    .byte $00, $1f, $00 ; ..........######........
                    .byte $00, $1f, $00 ; ..........######........
                    .byte $00, $30, $00 ; ..........##............
                    .byte $00, $3c, $00 ; ..........####..........
                    .byte $00, $3c, $00 ; ..........####..........
                    
DatMumMovRi03       .byte $03, $14, $11 ;
                    .byte $00, $0c, $00 ; ............##..........
                    .byte $00, $1f, $00 ; ...........#####........
                    .byte $00, $1f, $00 ; ...........#####........
                    .byte $00, $1f, $00 ; ...........#####........
                    .byte $00, $1f, $00 ; ...........#####........
                    .byte $00, $1c, $00 ; ...........###..........
                    .byte $00, $1f, $00 ; ...........#####........
                    .byte $00, $3c, $f0 ; ..........####..####....
                    .byte $00, $3f, $f0 ; ..........##########....
                    .byte $00, $3c, $00 ; ..........####..........
                    .byte $00, $3c, $00 ; ..........####..........
                    .byte $00, $3c, $00 ; ..........####..........
                    .byte $00, $3c, $00 ; ..........####..........
                    .byte $00, $3c, $00 ; ..........####..........
                    .byte $00, $6c, $00 ; .........##.##..........
                    .byte $00, $6c, $00 ; .........##.##..........
                    .byte $00, $cc, $00 ; ........##..##..........
                    .byte $00, $cf, $00 ; ........##..####........
                    .byte $00, $ef, $00 ; ........###.####........
                    .byte $00, $e0, $00 ; ........###.............
                    
DatRayMov01         .byte $02
                    .byte $01
                    .byte $02
                    .byte $aa, $aa ; #.#.#.#.#.#.#.#.
                    
DatForMov01         .byte $01 ;
                    .byte $0e
                    .byte $71
                    .byte $00 ; ........
                    .byte $03 ; ......##
                    .byte $0c ; ....##..
                    .byte $33 ; ..##..##
                    .byte $0c ; ....##..
                    .byte $33 ; ..##..##
                    .byte $0c ; ....##..
                    .byte $33 ; ..##..##
                    .byte $0c ; ....##..
                    .byte $33 ; ..##..##
                    .byte $0c ; ....##..
                    .byte $33 ; ..##..##
                    .byte $0c ; ....##..
                    .byte $30 ; ..##....
                    
DatForMov02         .byte $01
                    .byte $0e
                    .byte $71
                    .byte $00 ; ........
                    .byte $02 ; ......#.
                    .byte $05 ; .....#.#
                    .byte $2a ; ..#.#.#.
                    .byte $15 ; ...#.#.#
                    .byte $2a ; ..#.#.#.
                    .byte $15 ; ...#.#.#
                    .byte $2a ; ..#.#.#.
                    .byte $15 ; ...#.#.#
                    .byte $2a ; ..#.#.#.
                    .byte $15 ; ...#.#.#
                    .byte $2a ; ..#.#.#.
                    .byte $10 ; ...#....
                    .byte $20 ; ..#.....
                    
DatForMov03         .byte $01
                    .byte $01
                    .byte $31
                    .byte $00 ; ........
                    
DatSpaMov01         .byte $03
                    .byte $0f
                    .byte $71
                    .byte $00, $00, $00 ; ........................
                    .byte $00, $0c, $00 ; ............##..........
                    .byte $04, $02, $00 ; .....#........#.........
                    .byte $08, $01, $00 ; ....#..........#........
                    .byte $30, $01, $00 ; ..##...........#........
                    .byte $20, $00, $80 ; ..#.............#.......
                    .byte $30, $00, $80 ; ..##............#.......
                    .byte $48, $01, $00 ; .#..#..........#........
                    .byte $44, $02, $00 ; .#...#........#.........
                    .byte $22, $01, $00 ; ..#...#........#........
                    .byte $21, $00, $80 ; ..#....#........#.......
                    .byte $22, $00, $80 ; ..#...#.........#.......
                    .byte $02, $00, $80 ; ......#.........#.......
                    .byte $01, $00, $80 ; .......#........#.......
                    .byte $00, $00, $00 ; ........................
                    
DatSpaMov02         .byte $03
                    .byte $0f
                    .byte $71
                    .byte $00, $00, $00 ; ........................
                    .byte $00, $40, $00 ; .........#..............
                    .byte $00, $40, $20 ; .........#........#.....
                    .byte $00, $40, $20 ; .........#........#.....
                    .byte $00, $87, $c0 ; ........#....#####......
                    .byte $00, $8a, $00 ; ........#...#.#.........
                    .byte $00, $52, $00 ; .........#.#..#.........
                    .byte $00, $31, $00 ; ..........##...#........
                    .byte $00, $48, $80 ; .........#..#...#.......
                    .byte $01, $88, $10 ; .......##...#......#....
                    .byte $01, $08, $10 ; .......#....#......#....
                    .byte $01, $08, $10 ; .......#....#......#....
                    .byte $01, $00, $20 ; .......#..........#.....
                    .byte $00, $80, $20 ; ........#.........#.....
                    .byte $00, $80, $10 ; ........#..........#....
                    
DatSpaMov03         .byte $03
                    .byte $0f
                    .byte $71
                    .byte $00, $c0, $00 ; ........##..............
                    .byte $01, $30, $08 ; .......#..##........#...
                    .byte $02, $00, $04 ; ......#..............#..
                    .byte $04, $00, $02 ; .....#................#.
                    .byte $04, $00, $01 ; .....#.................#
                    .byte $03, $80, $02 ; ......###.............#.
                    .byte $00, $40, $04 ; .........#...........#..
                    .byte $00, $20, $08 ; ..........#.........#...
                    .byte $00, $10, $08 ; ...........#........#...
                    .byte $00, $28, $14 ; ..........#.#......#.#..
                    .byte $00, $48, $12 ; .........#..#......#..#.
                    .byte $00, $48, $12 ; .........#..#......#..#.
                    .byte $00, $20, $01 ; ..........#............#
                    .byte $00, $00, $01 ; .......................#
                    .byte $00, $00, $00 ; ........................
                    
DatSpaMov04         .byte $03
                    .byte $0f
                    .byte $71
                    .byte $02, $00, $00 ; ......#.................
                    .byte $02, $00, $00 ; ......#.................
                    .byte $02, $00, $00 ; ......#.................
                    .byte $01, $48, $00 ; .......#.#..#...........
                    .byte $00, $84, $00 ; ........#....#..........
                    .byte $00, $04, $00 ; .............#..........
                    .byte $00, $08, $00 ; ............#...........
                    .byte $00, $10, $00 ; ...........#............
                    .byte $00, $10, $00 ; ...........#............
                    .byte $00, $0e, $00 ; ............###.........
                    .byte $00, $01, $00 ; ...............#........
                    .byte $00, $01, $00 ; ...............#........
                    .byte $00, $01, $00 ; ...............#........
                    .byte $00, $01, $00 ; ...............#........
                    .byte $00, $00, $00 ; ........................
                    
DatArrUp            .byte $02
                    .byte $0a
                    .byte $30
                    .byte $08, $00 ; ....#...........
                    .byte $1c, $00 ; ...###..........
                    .byte $3e, $00 ; ..#####.........
                    .byte $7f, $00 ; .#######........
                    .byte $ff, $80 ; #########.......
                    .byte $1c, $00 ; ...###..........
                    .byte $1c, $00 ; ...###..........
                    .byte $1c, $00 ; ...###..........
                    .byte $1c, $00 ; ...###..........
                    .byte $1c, $00 ; ...###..........
                    
DatArrRi            .byte $02
                    .byte $09
                    .byte $30
                    .byte $04, $00 ; .....#..........
                    .byte $06, $00 ; .....##.........
                    .byte $07, $00 ; .....###........
                    .byte $ff, $80 ; #########.......
                    .byte $ff, $c0 ; ##########......
                    .byte $ff, $80 ; #########.......
                    .byte $07, $00 ; .....###........
                    .byte $06, $00 ; .....##.........
                    .byte $04, $00 ; .....#..........
                    
DatArrDo            .byte $02
                    .byte $0a
                    .byte $30
                    .byte $1c, $00 ; ...###..........
                    .byte $1c, $00 ; ...###..........
                    .byte $1c, $00 ; ...###..........
                    .byte $1c, $00 ; ...###..........
                    .byte $1c, $00 ; ...###..........
                    .byte $ff, $80 ; #########.......
                    .byte $7f, $00 ; .#######........
                    .byte $3e, $00 ; ..#####.........
                    .byte $1c, $00 ; ...###..........
                    .byte $08, $00 ; ....#...........
                    
DatArrLe            .byte $02
                    .byte $09
                    .byte $30
                    .byte $08, $00 ; ....#...........
                    .byte $18, $00 ; ...##...........
                    .byte $38, $00 ; ..###...........
                    .byte $7f, $c0 ; .#########......
                    .byte $ff, $c0 ; ##########......
                    .byte $7f, $c0 ; .#########......
                    .byte $38, $00 ; ..###...........
                    .byte $18, $00 ; ...##...........
                    .byte $08, $00 ; ....#...........
; ------------------------------------------------------------------------------------------------------------- ;
TabObjectDataPtr    = *                     ; 

ObjDoorNormal       dc.w DatObjDoorNormal  ; Door: Normal
ObjDoorGrate        dc.w DatObjDoorGrate   ; Door: Grating
ObjDoorGround       dc.w DatObjDoorGround  ; Door: Open
                    
ObjDoorBell         dc.w DatObjDoorBell    ; Door Bell
                    
ObjMapFiller        dc.w DatObjMapFiller   ; Map Room: Color Filler Square: 1*8
ObjMapWallNS        dc.w DatObjMapWallNS   ; Map Wall: N/S
ObjMapWallW         dc.w DatObjMapWallW    ; Map Wall: W
ObjMapWallE         dc.w DatObjMapWallE    ; Map Wall: E
                    
ObjMapDoorNSLe      dc.w DatObjMapDoNSLe   ; Map Door: N/S Left
ObjMapDoorNSRi      dc.w DatObjMapDoNSRi   ; Map Door: N/S Right
ObjMapDoorEWLe      dc.w DatObjMapDoEWLe   ; Map Door: E/W Left
ObjMapDoorEWRi      dc.w DatObjMapDoEWRi   ; Map Door: E/W Right
                    
ObjRoomDyn          dc.w $0000             ; Dynamically filled in RoomGraphic
                    
ObjFloorStart       dc.w DatObjFloorStart  ; Floor: Start
ObjFloorMid         dc.w DatObjFloorMid    ; Floor: Mid
ObjFloorEnd         dc.w DatObjFloorEnd    ; Floor: End
                    
ObjPole             dc.w DatObjPole        ; Pole:
ObjPolePassFl       dc.w DatObjPolePaFl    ; Pole: Pass Floor
                    
ObjPoleFront        dc.w DatObjPoleCover   ; Pole:  Front Floor Piece to cover Pole
                    
ObjLadderMid        dc.w DatObjLadderMid   ; Ladder: Mid
ObjLadderFloor      dc.w DatObjLadderFl    ; Ladder: On    Floor
ObjLadderWipeOn     dc.w DatObjLadderXOn   ; Ladder: Blank Floor for On
ObjLadderTop        dc.w DatObjLadderTop   ; Ladder: Top
ObjLadderPassFl     dc.w DatLadderPaFl     ; Ladder: Pass  Floor
ObjLadderWipePa     dc.w DatObjLadderXPa   ; Ladder: Blank Floor for Pass
                    
ObjLiMaPoleOn       dc.w DatObjLiMaPoleOn  ; Lightning Machine: Pole Switched On
ObjLiMaBall         dc.w DatObjLiMaBall    ; Lightning Machine: Ball
ObjLiMaPoleOff      dc.w DatObjLiMaPole    ; Lightning Machine: Pole Switched Off
                    
ObjLiMaSwFrame      dc.w DatObjLiMaSwFrm   ; Lightning Machine: Switch Frame
ObjLiMaSwUp         dc.w DatObjLiMaSwUp    ; Lightning Machine: Switch Up
ObjLiMaSwDown       dc.w DatObjLiMaSwDo    ; Lightning Machine: Switch Down
                    
ObjLoFiHead         dc.w DatObjFoFiHead    ; Force Field: Head
ObjLoFiSwitch       dc.w DatObjFoFiSwitch  ; Force Field: Switch
ObjLoFiTimer        dc.w DatObjFoFiTime    ; Force Field: Switch Timer Square
                    
ObjMummyWall        dc.w DatObjMummyWall   ; Mummy: Wall Brick
ObjMummyOut         dc.w DatObjMummyOut    ; Mummy: Wall Open
ObjMummyAnkh        dc.w DatObjMummyAnkh   ; Mummy: Ankh
                    
ObjKeyWhite         dc.w DatObjKeyWhite    ; Key: White
ObjKeyRed           dc.w DatObjKeyRed      ; Key: Red
ObjKeyCyan          dc.w DatObjKeyCyan     ; Key: Cyan
ObjKeyPurple        dc.w DatObjKeyPurple   ; Key: Purple
ObjKeyGreen         dc.w DatObjKeyGreen    ; Key: Green
ObjKeyBlue          dc.w DatObjKeyBlue     ; Key: Blue
ObjKeyYellow        dc.w DatObjKeyYellow   ; Key: Yellow
                    
ObjLock             dc.w DatObjLock        ; Lock:
                    
ObjGunPoleLe        dc.w DatObjGunPoleLe   ; Ray Gun: Shoot Left  Pole
ObjGunPoleRi        dc.w DatObjGunPoleRi   ; Ray Gun: Shoot Right Pole
ObjGunMovRi01       dc.w DatObjGunMovRi01  ; Ray Gun: Shoot Right Phase 01
ObjGunMovRi02       dc.w DatObjGunMovRi02  ; Ray Gun: Shoot Right Phase 02
ObjGunMovRi03       dc.w DatObjGunMovRi03  ; Ray Gun: Shoot Right Phase 03
ObjGunMovRi04       dc.w DatObjGunMovRi04  ; Ray Gun: Shoot Right Phase 04
ObjGunMovLe01       dc.w DatObjGunMovLe01  ; Ray Gun: Shoot Left  Phase 01
ObjGunMovLe02       dc.w DatObjGunMovLe02  ; Ray Gun: Shoot Left  Phase 02
ObjGunMovLe03       dc.w DatObjGunMovLe03  ; Ray Gun: Shoot Left  Phase 03
ObjGunMovLe04       dc.w DatObjGunMovLe04  ; Ray Gun: Shoot Left  Phase 04
                    
ObjGunSwitch        dc.w DatObjGunSwitch   ; Ray Gun: Operator
ObjGunOper          dc.w DatObjGunOper     ; Ray Gun: Operator Arrow
                    
ObjXmitBooth        dc.w DatObjXmitBooth   ; Matter Transmitter: Booth
ObjXmit             dc.w DatObjXmit        ;
ObjXmitBack         dc.w DatObjXmitBack    ; Matter Transmitter: Back Wall
ObjXmitRecOv        dc.w DatObjXmitRcOv    ; Matter Transmitter: Receiver Oval
                    
ObjTrapMov01        dc.w DatObjTrapMov01   ; Trap Door: Open 01
ObjTrapMov02        dc.w DatObjTrapMov02   ; Trap Door: Open 02
ObjTrapMov03        dc.w DatObjTrapMov03   ; Trap Door: Open 03
ObjTrapMov04        dc.w DatObjTrapMov04   ; Trap Door: Open 04
ObjTrapMov05        dc.w DatObjTrapMov05   ; Trap Door: Open 05
ObjTrapMov06        dc.w DatObjTrapMov06   ; Trap Door: Open 06
ObjTrapMovBas       dc.w DatObjTrapMovBas  ; Trap Door: Base Line if open
ObjTrapSwitch       dc.w DatObjTrapSw      ; Trap Door: Control
ObjTrapOpen         dc.w DatObjTrapOpen    ; Trap Door: Open
                    
ObjBlank            dc.w DatObjBlank       ; Various: Blank Line
                    
ObjWalkBlank        dc.w DatObjWalkBlank   ; Moving Sidewalk: Background
ObjWalkMov01        dc.w DatObjWalkMov01   ; Moving Sidewalk: Phase 01
ObjWalkMov02        dc.w DatObjWalkMov02   ; Moving Sidewalk: Phase 02
ObjWalkMov03        dc.w DatObjWalkMov03   ; Moving Sidewalk: Phase 03
ObjWalkMov04        dc.w DatObjWalkMov04   ; Moving Sidewalk: Phase 04
ObjWalkSwitch       dc.w DatObjWalkSw      ; Moving Sidewalk: Control
ObjWalkSpot         dc.w DatObjWalkSpot    ; Moving Sidewalk: Hot Spot (Joystck Fire detection)
                    
ObjFrankCoffRi      dc.w DatObjFrankCofRi  ; Frankenstein: Coffin Open Right
ObjFrankCoffLe      dc.w DatObjFrankCofLe  ; Frankenstein: Coffin Open Left
ObjFrankCover       dc.w DatObjFrankCover  ; Frankenstein: Coffin Preparation (Blank out StartOfFloor)
                    
ObjTimeFrame        dc.w DatObjTime        ; Time: Empty Frame
                    
ObjCharBack         dc.w DatObjCharBack    ; Text: Character Background
ObjChar             dc.w DatObjChar        ; Text: Character
                    
ObjDoorExit         dc.w DatObjDoorExit    ; Door: Exit
; ------------------------------------------------------------------------------------------------------------- ;
NoObjDoorNormal     = (ObjDoorNormal   - TabObjectDataPtr) / 2
NoObjDoorExit       = (ObjDoorExit     - TabObjectDataPtr) / 2

NoObjDoorGrate      = (ObjDoorGrate    - TabObjectDataPtr) / 2
NoObjDoorGround     = (ObjDoorGround   - TabObjectDataPtr) / 2
                                        
NoObjDoorBell       = (ObjDoorBell     - TabObjectDataPtr) / 2
                                        
NoObjMapFiller      = (ObjMapFiller    - TabObjectDataPtr) / 2
NoObjMapWallNS      = (ObjMapWallNS    - TabObjectDataPtr) / 2
NoObjMapWallW       = (ObjMapWallW     - TabObjectDataPtr) / 2
NoObjMapWallE       = (ObjMapWallE     - TabObjectDataPtr) / 2
                                        
NoObjMapDoorNSLe    = (ObjMapDoorNSLe  - TabObjectDataPtr) / 2
NoObjMapDoorNSRi    = (ObjMapDoorNSRi  - TabObjectDataPtr) / 2
NoObjMapDoorEWLe    = (ObjMapDoorEWLe  - TabObjectDataPtr) / 2
NoObjMapDoorEWRi    = (ObjMapDoorEWRi  - TabObjectDataPtr) / 2
                                        
NoObjRoomDyn        = (ObjRoomDyn      - TabObjectDataPtr) / 2
                                      
NoObjFloorStart     = (ObjFloorStart   - TabObjectDataPtr) / 2
NoObjFloorMid       = (ObjFloorMid     - TabObjectDataPtr) / 2
NoObjFloorEnd       = (ObjFloorEnd     - TabObjectDataPtr) / 2
                                        
NoObjPole           = (ObjPole         - TabObjectDataPtr) / 2
NoObjPolePassFl     = (ObjPolePassFl   - TabObjectDataPtr) / 2
                                      
NoObjPoleFront      = (ObjPoleFront    - TabObjectDataPtr) / 2
                                        
NoObjLadderMid      = (ObjLadderMid    - TabObjectDataPtr) / 2
NoObjLadderFloor    = (ObjLadderFloor  - TabObjectDataPtr) / 2
NoObjLaddrWipeOn    = (ObjLadderWipeOn - TabObjectDataPtr) / 2
NoObjLadderTop      = (ObjLadderTop    - TabObjectDataPtr) / 2
NoObjLaddrPassFl    = (ObjLadderPassFl - TabObjectDataPtr) / 2
NoObjLaddrWipePa    = (ObjLadderWipePa - TabObjectDataPtr) / 2
                                      
NoObjLiMaPoleOn     = (ObjLiMaPoleOn   - TabObjectDataPtr) / 2
NoObjLiMaBall       = (ObjLiMaBall     - TabObjectDataPtr) / 2
NoObjLiMaPoleOff    = (ObjLiMaPoleOff  - TabObjectDataPtr) / 2
                                      
NoObjLiMaSwFrame    = (ObjLiMaSwFrame  - TabObjectDataPtr) / 2
NoObjLiMaSwUp       = (ObjLiMaSwUp     - TabObjectDataPtr) / 2
NoObjLiMaSwDown     = (ObjLiMaSwDown   - TabObjectDataPtr) / 2
                                      
NoObjLoFiHead       = (ObjLoFiHead     - TabObjectDataPtr) / 2
NoObjLoFiSwitch     = (ObjLoFiSwitch   - TabObjectDataPtr) / 2
NoObjLoFiTimer      = (ObjLoFiTimer    - TabObjectDataPtr) / 2
                                        
NoObjMummyWall      = (ObjMummyWall    - TabObjectDataPtr) / 2
NoObjMummyOut       = (ObjMummyOut     - TabObjectDataPtr) / 2
NoObjMummyAnkh      = (ObjMummyAnkh    - TabObjectDataPtr) / 2
                                        
NoObjKeyTab         equ  ((ObjKeyWhite  - TabObjectDataPtr) / 2) - 2 ; start number - old key no: 51-57 - see code .hbu001.
NoObjKeyWhite       equ  NoObjKeyTab  + 0
NoObjKeyRed         equ  NoObjKeyTab  + 1
NoObjKeyCyan        equ  NoObjKeyTab  + 2
NoObjKeyPurple      equ  NoObjKeyTab  + 3
NoObjKeyGreen       equ  NoObjKeyTab  + 4
NoObjKeyBlue        equ  NoObjKeyTab  + 5
NoObjKeyYellow      equ  NoObjKeyTab  + 6
                    
NoObjLock           = (ObjLock         - TabObjectDataPtr) / 2
                                        
NoObjGunPoleLe      = (ObjGunPoleLe    - TabObjectDataPtr) / 2
NoObjGunPoleRi      = (ObjGunPoleRi    - TabObjectDataPtr) / 2
NoObjGunMovRi01     = (ObjGunMovRi01   - TabObjectDataPtr) / 2
NoObjGunMovRi02     = (ObjGunMovRi02   - TabObjectDataPtr) / 2
NoObjGunMovRi03     = (ObjGunMovRi03   - TabObjectDataPtr) / 2
NoObjGunMovRi04     = (ObjGunMovRi04   - TabObjectDataPtr) / 2
NoObjGunMovLe01     = (ObjGunMovLe01   - TabObjectDataPtr) / 2
NoObjGunMovLe02     = (ObjGunMovLe02   - TabObjectDataPtr) / 2
NoObjGunMovLe03     = (ObjGunMovLe03   - TabObjectDataPtr) / 2
NoObjGunMovLe04     = (ObjGunMovLe04   - TabObjectDataPtr) / 2
                    
NoObjGunMovRiMin    = NoObjGunMovRi01
NoObjGunMovRiMax    = NoObjGunMovRi04 + 1
NoObjGunMovLeMin    = NoObjGunMovLe01
NoObjGunMovLeMax    = NoObjGunMovLe04 + 1
                                        
NoObjGunSwitch      = (ObjGunSwitch    - TabObjectDataPtr) / 2
NoObjGunOper        = (ObjGunOper      - TabObjectDataPtr) / 2
                                        
NoObjXmitBooth      = (ObjXmitBooth    - TabObjectDataPtr) / 2
NoObjXmit           = (ObjXmit         - TabObjectDataPtr) / 2
NoObjXmitBack       = (ObjXmitBack     - TabObjectDataPtr) / 2
NoObjXmitRecOv      = (ObjXmitRecOv    - TabObjectDataPtr) / 2
                                        
NoObjTrapMov01      = (ObjTrapMov01    - TabObjectDataPtr) / 2
NoObjTrapMov02      = (ObjTrapMov02    - TabObjectDataPtr) / 2
NoObjTrapMov03      = (ObjTrapMov03    - TabObjectDataPtr) / 2
NoObjTrapMov04      = (ObjTrapMov04    - TabObjectDataPtr) / 2
NoObjTrapMov05      = (ObjTrapMov05    - TabObjectDataPtr) / 2
NoObjTrapMov06      = (ObjTrapMov06    - TabObjectDataPtr) / 2
NoObjTrapMovBas     = (ObjTrapMovBas   - TabObjectDataPtr) / 2
NoObjTrapSwitch     = (ObjTrapSwitch   - TabObjectDataPtr) / 2
NoObjTrapOpen       = (ObjTrapOpen     - TabObjectDataPtr) / 2
                    
NoObjTrapMovMin     = NoObjTrapMov01
NoObjTrapMovMax     = NoObjTrapMov06
                                        
NoObjBlank          = (ObjBlank        - TabObjectDataPtr) / 2
                                        
NoObjWalkBlank      = (ObjWalkBlank    - TabObjectDataPtr) / 2
NoObjWalkMov01      = (ObjWalkMov01    - TabObjectDataPtr) / 2
NoObjWalkMov02      = (ObjWalkMov02    - TabObjectDataPtr) / 2
NoObjWalkMov03      = (ObjWalkMov03    - TabObjectDataPtr) / 2
NoObjWalkMov04      = (ObjWalkMov04    - TabObjectDataPtr) / 2
NoObjWalkSwitch     = (ObjWalkSwitch   - TabObjectDataPtr) / 2
NoObjWalkSpot       = (ObjWalkSpot     - TabObjectDataPtr) / 2
                    
NoObjWalkMovMin     = NoObjWalkMov01
NoObjWalkMovMax     = NoObjWalkMov04 + 1
                                        
NoObjFrankCoffRi    = (ObjFrankCoffRi  - TabObjectDataPtr) / 2
NoObjFrankCoffLe    = (ObjFrankCoffLe  - TabObjectDataPtr) / 2
NoObjFrankCover     = (ObjFrankCover   - TabObjectDataPtr) / 2
                                        
NoObjTimeFrame      = (ObjTimeFrame    - TabObjectDataPtr) / 2
                                        
NoObjCharBack       = (ObjCharBack     - TabObjectDataPtr) / 2
NoObjChar           = (ObjChar         - TabObjectDataPtr) / 2
; ------------------------------------------------------------------------------------------------------------- ;
DatObjDoorNormal    .byte $05                     ; cols (in bytes)
                    .byte $20                     ; rows         
                    .byte $00                     ; EndOfHeader - always $00
                    .byte $55, $51, $55, $45, $55 ; .#.#.#.#.#.#...#.#.#.#.#.#...#.#.#.#.#.#
                    .byte $55, $51, $55, $45, $55 ; .#.#.#.#.#.#...#.#.#.#.#.#...#.#.#.#.#.#
                    .byte $15, $51, $55, $45, $54 ; ...#.#.#.#.#...#.#.#.#.#.#...#.#.#.#.#..
                    .byte $15, $51, $55, $45, $54 ; ...#.#.#.#.#...#.#.#.#.#.#...#.#.#.#.#..
                    .byte $45, $50, $55, $05, $51 ; .#...#.#.#.#.....#.#.#.#.....#.#.#.#...#
                    .byte $45, $54, $55, $15, $51 ; .#...#.#.#.#.#...#.#.#.#...#.#.#.#.#.#..
                    .byte $51, $54, $55, $15, $45 ; .#.#...#.#.#.#...#.#.#.#...#.#.#.#...#.#
                    .byte $51, $54, $55, $15, $45 ; .#.#...#.#.#.#...#.#.#.#...#.#.#.#...#.#
                    .byte $54, $54, $00, $15, $15 ; .#.#.#...#.#.#.............#.#.#...#.#.#
                    .byte $54, $10, $00, $04, $15 ; .#.#.#.....#.................#.....#.#.#
                    .byte $55, $00, $00, $00, $55 ; .#.#.#.#.........................#.#.#.#
                    .byte $55, $00, $00, $00, $55 ; .#.#.#.#.........................#.#.#.#
                    .byte $55, $40, $00, $01, $55 ; .#.#.#.#.#.....................#.#.#.#.#
                    .byte $55, $40, $00, $01, $55 ; .#.#.#.#.#.....................#.#.#.#.#
                    .byte $00, $00, $00, $00, $00 ; ........................................
                    .byte $00, $00, $00, $00, $00 ; ........................................
                    .byte $55, $00, $00, $00, $55 ; .#.#.#.#.........................#.#.#.#
                    .byte $55, $00, $00, $00, $55 ; .#.#.#.#.........................#.#.#.#
                    .byte $55, $00, $00, $00, $55 ; .#.#.#.#.........................#.#.#.#
                    .byte $55, $00, $00, $00, $55 ; .#.#.#.#.........................#.#.#.#
                    .byte $55, $00, $00, $00, $55 ; .#.#.#.#.........................#.#.#.#
                    .byte $55, $00, $00, $00, $55 ; .#.#.#.#.........................#.#.#.#
                    .byte $00, $00, $00, $00, $00 ; ........................................
                    .byte $00, $00, $00, $00, $00 ; ........................................
                    .byte $55, $00, $00, $00, $55 ; .#.#.#.#.........................#.#.#.#
                    .byte $55, $00, $00, $00, $55 ; .#.#.#.#.........................#.#.#.#
                    .byte $55, $00, $00, $00, $55 ; .#.#.#.#.........................#.#.#.#
                    .byte $55, $00, $00, $00, $55 ; .#.#.#.#.........................#.#.#.#
                    .byte $55, $00, $00, $00, $55 ; .#.#.#.#.........................#.#.#.#
                    .byte $55, $00, $00, $00, $55 ; .#.#.#.#.........................#.#.#.#
                    .byte $55, $00, $00, $00, $55 ; .#.#.#.#.........................#.#.#.#
                    .byte $55, $00, $00, $00, $55 ; .#.#.#.#.........................#.#.#.#
                    .byte $40, $40, $40, $40, $40 ; colors - video ram byte count = (((rows - 1) / 8) + 1) * cols
                    .byte $40, $40, $40, $40, $40 ;
                    .byte $40, $40, $40, $40, $40 ;          color ram byte count = (((rows - 1) / 8) + 1) * cols
                    .byte $40, $40, $40, $40, $40 ;
                    
DatObjDoorExit      .byte $05
                    .byte $20
                    .byte $00
                    .byte $00, $00, $28, $00, $00 ; ..................#.#...................
                    .byte $00, $00, $aa, $00, $00 ; ................#.#.#.#.................
                    .byte $00, $00, $aa, $00, $00 ; ................#.#.#.#.................
                    .byte $00, $02, $be, $80, $00 ; ..............#.#.#####.#...............
                    .byte $00, $0a, $ff, $a0, $00 ; ............#.#.#########.#.............
                    .byte $00, $0a, $ff, $a0, $00 ; ............#.#.#########.#.............
                    .byte $00, $2b, $ff, $e8, $00 ; ..........#.#.#############.#...........
                    .byte $00, $af, $ff, $fa, $00 ; ........#.#.#################.#.........
                    .byte $00, $af, $ff, $fa, $00 ; ........#.#.#################.#.........
                    .byte $02, $bf, $ff, $fe, $80 ; ......#.#.#####################.#.......
                    .byte $0a, $ff, $ff, $ff, $a0 ; ....#.#.#########################.#.....
                    .byte $0a, $ff, $ff, $ff, $a0 ; ....#.#.#########################.#.....
                    .byte $2b, $ff, $ff, $ff, $e8 ; ..#.#.#############################.#...
                    .byte $aa, $aa, $aa, $aa, $aa ; #.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.
                    .byte $aa, $aa, $aa, $aa, $aa ; #.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.
                    .byte $aa, $80, $00, $02, $aa ; #.#.#.#.#.....................#.#.#.#.#.
                    .byte $15, $00, $00, $00, $54 ; ...#.#.#.........................#.#.#..
                    .byte $15, $00, $00, $00, $54 ; ...#.#.#.........................#.#.#..
                    .byte $15, $00, $00, $00, $54 ; ...#.#.#.........................#.#.#..
                    .byte $15, $00, $00, $00, $54 ; ...#.#.#.........................#.#.#..
                    .byte $15, $00, $00, $00, $54 ; ...#.#.#.........................#.#.#..
                    .byte $15, $00, $00, $00, $54 ; ...#.#.#.........................#.#.#..
                    .byte $15, $00, $00, $00, $54 ; ...#.#.#.........................#.#.#..
                    .byte $15, $00, $00, $00, $54 ; ...#.#.#.........................#.#.#..
                    .byte $15, $00, $00, $00, $54 ; ...#.#.#.........................#.#.#..
                    .byte $15, $00, $00, $00, $54 ; ...#.#.#.........................#.#.#..
                    .byte $15, $00, $00, $00, $54 ; ...#.#.#.........................#.#.#..
                    .byte $15, $00, $00, $00, $54 ; ...#.#.#.........................#.#.#..
                    .byte $15, $00, $00, $00, $54 ; ...#.#.#.........................#.#.#..
                    .byte $15, $00, $00, $00, $54 ; ...#.#.#.........................#.#.#..
                    .byte $15, $00, $00, $00, $54 ; ...#.#.#.........................#.#.#..
                    .byte $15, $00, $00, $00, $54 ; ...#.#.#.........................#.#.#..
                    .byte $77, $77, $77, $77, $77
                    .byte $77, $77, $77, $77, $77
                    .byte $a7, $a7, $a7, $a7, $a7
                    .byte $a7, $a7, $a7, $a7, $a7
                    .byte $08, $08, $08, $08, $08
                    .byte $08, $08, $08, $08, $08
                    .byte $08, $08, $08, $08, $08
                    .byte $08, $08, $08, $08, $08
                    
DatObjDoorGrate     .byte $03
                    .byte $0f
                    .byte $00
                    .byte $55, $55, $55 ; .#.#.#.#.#.#.#.#.#.#.#.#
                    .byte $11, $11, $10 ; ...#...#...#...#...#....
                    .byte $11, $11, $10 ; ...#...#...#...#...#....
                    .byte $11, $11, $10 ; ...#...#...#...#...#....
                    .byte $11, $11, $10 ; ...#...#...#...#...#....
                    .byte $11, $11, $10 ; ...#...#...#...#...#....
                    .byte $11, $11, $10 ; ...#...#...#...#...#....
                    .byte $11, $11, $10 ; ...#...#...#...#...#....
                    .byte $11, $11, $10 ; ...#...#...#...#...#....
                    .byte $11, $11, $10 ; ...#...#...#...#...#....
                    .byte $11, $11, $10 ; ...#...#...#...#...#....
                    .byte $11, $11, $10 ; ...#...#...#...#...#....
                    .byte $11, $11, $10 ; ...#...#...#...#...#....
                    .byte $11, $11, $10 ; ...#...#...#...#...#....
                    .byte $55, $55, $55 ; .#.#.#.#.#.#.#.#.#.#.#.#
                    .byte $10, $10, $10
                    .byte $10, $10, $10
                    
DatObjDoorGround    .byte $03
                    .byte $0f
                    .byte $00
                    .byte $00, $00, $01 ; .......................#
                    .byte $00, $00, $01 ; .......................#
                    .byte $00, $00, $05 ; .....................#.#
                    .byte $00, $00, $15 ; ...................#.#.#
                    .byte $00, $00, $55 ; .................#.#.#.#
                    .byte $00, $01, $55 ; ...............#.#.#.#.#
                    .byte $00, $01, $55 ; ...............#.#.#.#.#
                    .byte $00, $05, $55 ; .............#.#.#.#.#.#
                    .byte $00, $15, $55 ; ...........#.#.#.#.#.#.#
                    .byte $00, $55, $55 ; .........#.#.#.#.#.#.#.#
                    .byte $01, $55, $55 ; .......#.#.#.#.#.#.#.#.#
                    .byte $01, $55, $55 ; .......#.#.#.#.#.#.#.#.#
                    .byte $05, $55, $55 ; .....#.#.#.#.#.#.#.#.#.#
                    .byte $15, $55, $55 ; ...#.#.#.#.#.#.#.#.#.#.#
                    .byte $55, $aa, $55 ; .#.#.#.##.#.#.#..#.#.#.#
ColObjDoorGround    .byte $a0, $af, $b3
                    .byte $b0, $a2, $b2
                    
DatObjDoorBell      .byte $03
                    .byte $13
                    .byte $00
                    .byte $00, $00, $00 ; ........................
                    .byte $00, $00, $00 ; ........................
                    .byte $00, $00, $00 ; ........................
                    .byte $00, $00, $00 ; ........................
                    .byte $00, $00, $00 ; ........................
                    .byte $00, $55, $00 ; .........#.#.#.#........
                    .byte $01, $55, $40 ; .......#.#.#.#.#.#......
                    .byte $05, $55, $50 ; .....#.#.#.#.#.#.#.#....
                    .byte $05, $82, $50 ; .....#.##.....#..#.#....
                    .byte $15, $14, $54 ; ...#.#.#...#.#...#.#.#..
                    .byte $14, $55, $14 ; ...#.#...#.#.#.#...#.#..
                    .byte $14, $55, $14 ; ...#.#...#.#.#.#...#.#..
                    .byte $14, $55, $14 ; ...#.#...#.#.#.#...#.#..
                    .byte $14, $55, $14 ; ...#.#...#.#.#.#...#.#..
                    .byte $15, $14, $54 ; ...#.#.#...#.#...#.#.#..
                    .byte $05, $82, $50 ; .....#.##.....#..#.#....
                    .byte $05, $55, $50 ; .....#.#.#.#.#.#.#.#....
                    .byte $01, $55, $40 ; .......#.#.#.#.#.#......
                    .byte $00, $55, $00 ; .........#.#.#.#........
ColObjDoorBell01    .byte $b3, $a0, $cc ;
                    .byte $a0
ColObjDoorBell02    .byte $a4
                    .byte $b1
                    .byte $ac, $80, $a0
                    
DatObjMapFiller     .byte $01
                    .byte $08
                    .byte $00
                    .byte $ff ; ########
                    .byte $ff ; ########
                    .byte $ff ; ########
                    .byte $ff ; ########
                    .byte $ff ; ########
                    .byte $ff ; ########
                    .byte $ff ; ########
                    .byte $ff ; ########
                    .byte $11
ColObjMapFiller     .byte $81 ; 
                    
DatObjMapWallNS     .byte $01
                    .byte $03
                    .byte $00
                    .byte $aa ; #.#.#.#.
                    .byte $aa ; #.#.#.#.
                    .byte $aa ; #.#.#.#.
                    
DatObjMapWallW      .byte $01
                    .byte $08
                    .byte $00
                    .byte $a0 ; #.#.....
                    .byte $a0 ; #.#.....
                    .byte $a0 ; #.#.....
                    .byte $a0 ; #.#.....
                    .byte $a0 ; #.#.....
                    .byte $a0 ; #.#.....
                    .byte $a0 ; #.#.....
                    .byte $a0 ; #.#.....
                    
DatObjMapWallE      .byte $01
                    .byte $08
                    .byte $00
                    .byte $0a ; ....#.#.
                    .byte $0a ; ....#.#.
                    .byte $0a ; ....#.#.
                    .byte $0a ; ....#.#.
                    .byte $0a ; ....#.#.
                    .byte $0a ; ....#.#.
                    .byte $0a ; ....#.#.
                    .byte $0a ; ....#.#.
                    
DatObjMapDoNSLe     .byte $01
                    .byte $03
                    .byte $00
                    .byte $50 ; .#.#....
                    .byte $50 ; .#.#....
                    .byte $50 ; .#.#....
                    
DatObjMapDoNSRi     .byte $01
                    .byte $03
                    .byte $00
                    .byte $05 ; .....#.#
                    .byte $05 ; .....#.#
                    .byte $05 ; .....#.#
                    
DatObjMapDoEWLe     .byte $01
                    .byte $04
                    .byte $00
                    .byte $50 ; .#.#....
                    .byte $50 ; .#.#....
                    .byte $50 ; .#.#....
                    .byte $50 ; .#.#....
                    
DatObjMapDoEWRi     .byte $01
                    .byte $04
                    .byte $00
                    .byte $05 ; .....#.#
                    .byte $05 ; .....#.#
                    .byte $05 ; .....#.#
                    .byte $05 ; .....#.#
                    
DatObjFloorStart    .byte $01
                    .byte $08
                    .byte $00
                    .byte $05 ; .....#.#
                    .byte $05 ; .....#.#
                    .byte $15 ; ...#.#.#
                    .byte $2a ; ..#.#.#.
                    .byte $aa ; #.#.#.#.
                    .byte $aa ; #.#.#.#.
                    .byte $ff ; ########
                    .byte $ff ; ########
ColObjFloorStart    .byte $a0
                    .byte $09
                    
DatObjFloorMid      .byte $01
                    .byte $08
                    .byte $00
                    .byte $55 ; .#.#.#.#
                    .byte $55 ; .#.#.#.#
                    .byte $55 ; .#.#.#.#
                    .byte $aa ; #.#.#.#.
                    .byte $aa ; #.#.#.#.
                    .byte $aa ; #.#.#.#.
                    .byte $ff ; ########
                    .byte $ff ; ########
ColObjFloorMid      .byte $b0
                    .byte $09
                    
DatObjFloorEnd      .byte $01
                    .byte $08
                    .byte $00
                    .byte $57 ; .#.#.###
                    .byte $57 ; .#.#.###
                    .byte $5c ; .#.###..
                    .byte $ac ; #.#.##..
                    .byte $b0 ; #.###...
                    .byte $b0 ; #.###...
                    .byte $c0 ; ##......
                    .byte $c0 ; ##......
ColObjFloorEnd      .byte $b7
                    .byte $09
                    
DatObjPole          .byte $01
                    .byte $08
                    .byte $00
                    .byte $10 ; ...#....
                    .byte $10 ; ...#....
                    .byte $10 ; ...#....
                    .byte $10 ; ...#....
                    .byte $10 ; ...#....
                    .byte $10 ; ...#....
                    .byte $10 ; ...#....
                    .byte $10 ; ...#....
                    .byte $10 ; ...#....
                    
DatObjPolePaFl      .byte $03
                    .byte $03
                    .byte $00
                    .byte $05, $45, $50 ; .....#.#.#...#.#.#.#....
                    .byte $15, $45, $40 ; ...#.#.#.#...#.#.#......
                    .byte $55, $45, $00 ; .#.#.#.#.#...#.#........
                    
DatObjPoleCover     .byte $01
                    .byte $01
                    .byte $00
                    .byte $00 ; ........
ColObjPoleCover     .byte $d9
                    .byte $09
                    
DatObjLadderMid     .byte $01
                    .byte $08
                    .byte $00
                    .byte $82 ; #.....#.
                    .byte $82 ; #.....#.
                    .byte $82 ; #.....#.
                    .byte $aa ; #.#.#.#.
                    .byte $82 ; #.....#.
                    .byte $82 ; #.....#.
                    .byte $82 ; #.....#.
                    .byte $aa ; #.#.#.#.
                    .byte $01
                    
DatObjLadderFl      .byte $01
                    .byte $06
                    .byte $00
                    .byte $96 ; #..#.##.
                    .byte $96 ; #..#.##.
                    .byte $96 ; #..#.##.
                    .byte $aa ; #.#.#.#.
                    .byte $96 ; #..#.##.
                    .byte $96 ; #..#.##.
ColObjLadderFl      .byte $01
                    .byte $09
                    
DatObjLadderXOn     .byte $01
                    .byte $06
                    .byte $00
                    .byte $ff ; ########
                    .byte $ff ; ########
                    .byte $ff ; ########
                    .byte $ff ; ########
                    .byte $ff ; ########
                    .byte $ff ; ########
                    
DatObjLadderTop     .byte $01
                    .byte $07
                    .byte $00
                    .byte $82 ; #.....#.
                    .byte $82 ; #.....#.
                    .byte $82 ; #.....#.
                    .byte $aa ; #.#.#.#.
                    .byte $82 ; #.....#.
                    .byte $82 ; #.....#.
                    .byte $82 ; #.....#.
                    .byte $01
                    
DatLadderPaFl       .byte $03
                    .byte $08
                    .byte $00
                    .byte $55, $96, $55 ; .#.#.#.##..#.##..#.#.#.#
                    .byte $55, $96, $55 ; .#.#.#.##..#.##..#.#.#.#
                    .byte $55, $96, $55 ; .#.#.#.##..#.##..#.#.#.#
                    .byte $aa, $aa, $00 ; #.#.#.#.#.#.#.#.........
                    .byte $a8, $82, $02 ; #.#.#...#.....#.......#.
                    .byte $a0, $82, $0a ; #.#.....#.....#.....#.#.
                    .byte $f0, $82, $0f ; ####....#.....#.....####
                    .byte $f0, $aa, $0f ; ####....#.#.#.#.....####
ColLadderPaFl01     .byte $01
ColLadderPaFl02     .byte $01
ColLadderPaFl03     .byte $01
                    .byte $09, $09, $09
                    
DatObjLadderXPa     .byte $03
                    .byte $08
                    .byte $00
                    .byte $ff, $ff, $ff ; ########################
                    .byte $ff, $ff, $ff ; ########################
                    .byte $ff, $ff, $ff ; ########################
                    .byte $ff, $ff, $ff ; ########################
                    .byte $ff, $ff, $ff ; ########################
                    .byte $ff, $ff, $ff ; ########################
                    .byte $ff, $ff, $ff ; ########################
                    .byte $ff, $ff, $ff ; ########################
                    
DatObjLiMaPoleOn    .byte $01
                    .byte $08
                    .byte $00
                    .byte $7d ; .#####.#
                    .byte $96 ; #..#.##.
                    .byte $eb ; ###.#.##
                    .byte $7d ; .#####.#
                    .byte $96 ; #..#.##.
                    .byte $eb ; ###.#.##
                    .byte $7d ; .#####.#
                    .byte $96 ; #..#.##.
                    .byte $55
                    .byte $05
                    
DatObjLiMaBall      .byte $03
                    .byte $0f
                    .byte $00
                    .byte $00, $69, $00 ; .........##.#..#........
                    .byte $01, $55, $40 ; .......#.#.#.#.#.#......
                    .byte $05, $55, $50 ; .....#.#.#.#.#.#.#.#....
                    .byte $07, $d5, $50 ; .....#####.#.#.#.#.#....
                    .byte $07, $d5, $50 ; .....#####.#.#.#.#.#....
                    .byte $1f, $55, $54 ; ...#####.#.#.#.#.#.#.#..
                    .byte $1d, $55, $54 ; ...###.#.#.#.#.#.#.#.#..
                    .byte $1d, $55, $54 ; ...###.#.#.#.#.#.#.#.#..
                    .byte $1d, $55, $54 ; ...###.#.#.#.#.#.#.#.#..
                    .byte $1d, $55, $54 ; ...###.#.#.#.#.#.#.#.#..
                    .byte $07, $55, $50 ; .....###.#.#.#.#.#.#....
                    .byte $05, $55, $50 ; .....#.#.#.#.#.#.#.#....
                    .byte $05, $55, $50 ; .....#.#.#.#.#.#.#.#....
                    .byte $01, $55, $40 ; .......#.#.#.#.#.#......
                    .byte $00, $55, $00 ; .........#.#.#.#........
                    .byte $c5, $c5, $c5
                    .byte $c5, $c5, $c5
                    .byte $01, $01, $01
                    .byte $01, $01, $01
                    
DatObjLiMaPole      .byte $01
                    .byte $01
                    .byte $00
                    .byte $00 ; ........
DatObjLiMaPole01    .byte $bd
DatObjLiMaPole02    .byte $a0
                    
DatObjLiMaSwFrm     .byte $03
                    .byte $14
                    .byte $00
                    .byte $00, $00, $00 ; ........................
                    .byte $00, $00, $00 ; ........................
                    .byte $00, $00, $00 ; ........................
                    .byte $00, $00, $00 ; ........................
                    .byte $05, $55, $50 ; .....#.#.#.#.#.#.#.#....
                    .byte $05, $55, $50 ; .....#.#.#.#.#.#.#.#....
                    .byte $05, $55, $50 ; .....#.#.#.#.#.#.#.#....
                    .byte $05, $00, $50 ; .....#.#.........#.#....
                    .byte $05, $00, $50 ; .....#.#.........#.#....
                    .byte $05, $00, $50 ; .....#.#.........#.#....
                    .byte $05, $00, $50 ; .....#.#.........#.#....
                    .byte $05, $00, $50 ; .....#.#.........#.#....
                    .byte $05, $00, $50 ; .....#.#.........#.#....
                    .byte $05, $00, $50 ; .....#.#.........#.#....
                    .byte $05, $00, $50 ; .....#.#.........#.#....
                    .byte $05, $00, $50 ; .....#.#.........#.#....
                    .byte $05, $00, $50 ; .....#.#.........#.#....
                    .byte $05, $55, $50 ; .....#.#.#.#.#.#.#.#....
                    .byte $05, $55, $50 ; .....#.#.#.#.#.#.#.#....
                    .byte $05, $55, $50 ; .....#.#.#.#.#.#.#.#....
                    .byte $70, $70, $70 ; 
                    .byte $70, $70, $70 ;
                    .byte $70, $70, $70 ;
                    
DatObjLiMaSwUp      .byte $01 ;
                    .byte $05 ;
                    .byte $00 ;
                    .byte $28 ; ..#.#...
                    .byte $14 ; ...#.#..
                    .byte $14 ; ...#.#..
                    .byte $55 ; .#.#.#.#
                    .byte $55 ; .#.#.#.#
                    .byte $11
                    
DatObjLiMaSwDo      .byte $01 ;
                    .byte $08 ;
                    .byte $00 ;
                    .byte $00 ; ........
                    .byte $00 ; ........
                    .byte $00 ; ........
                    .byte $55 ; .#.#.#.#
                    .byte $55 ; .#.#.#.#
                    .byte $14 ; ...#.#..
                    .byte $14 ; ...#.#..
                    .byte $28 ; ..#.#...
                    .byte $11
                    
DatObjFoFiHead      .byte $02
                    .byte $06
                    .byte $00
                    .byte $52, $50 ; .#.#..#..#.#....
                    .byte $52, $50 ; .#.#..#..#.#....
                    .byte $59, $50 ; .#.##..#.#.#....
                    .byte $08, $00 ; ....#...........
                    .byte $20, $00 ; ..#.............
                    .byte $20, $00 ; ..#.............
                    .byte $27, $27
                    
DatObjFoFiSwitch    .byte $03
                    .byte $16
                    .byte $00
                    .byte $00, $00, $00 ; ........................
                    .byte $00, $00, $00 ; ........................
                    .byte $00, $14, $00 ; ...........#.#..........
                    .byte $00, $55, $00 ; .........#.#.#.#........
                    .byte $01, $55, $40 ; .......#.#.#.#.#.#......
                    .byte $05, $55, $50 ; .....#.#.#.#.#.#.#.#....
                    .byte $15, $55, $54 ; ...#.#.#.#.#.#.#.#.#.#..
                    .byte $54, $00, $15 ; .#.#.#.............#.#.#
                    .byte $54, $00, $15 ; .#.#.#.............#.#.#
                    .byte $54, $00, $15 ; .#.#.#.............#.#.#
                    .byte $54, $00, $15 ; .#.#.#.............#.#.#
                    .byte $54, $00, $15 ; .#.#.#.............#.#.#
                    .byte $54, $00, $15 ; .#.#.#.............#.#.#
                    .byte $54, $00, $15 ; .#.#.#.............#.#.#
                    .byte $54, $00, $15 ; .#.#.#.............#.#.#
                    .byte $54, $00, $15 ; .#.#.#.............#.#.#
                    .byte $54, $00, $15 ; .#.#.#.............#.#.#
                    .byte $15, $aa, $54 ; ...#.#.##.#.#.#..#.#.#..
                    .byte $05, $55, $50 ; .....#.#.#.#.#.#.#.#....
                    .byte $01, $55, $40 ; .......#.#.#.#.#.#......
                    .byte $00, $55, $00 ; .........#.#.#.#........
                    .byte $00, $14, $00 ; ...........#.#..........
                    .byte $22, $22, $22
                    .byte $22, $22, $22
                    .byte $22, $22, $22
                    
DatObjFoFiTime      .byte $01
                    .byte $08
                    .byte $00
DatObjFoFiTime01    .byte $b5 ;
DatObjFoFiTime02    .byte $a0 ;
DatObjFoFiTime03    .byte $90 ;
DatObjFoFiTime04    .byte $a0 ;
DatObjFoFiTime05    .byte $87 ;
DatObjFoFiTime06    .byte $a0 ;
DatObjFoFiTime07    .byte $b0 ;
DatObjFoFiTime08    .byte $a0 ;
                    .byte $10
                    
DatObjMummyWall     .byte $01
                    .byte $07
                    .byte $00
                    .byte $54 ; .#.#.#..
                    .byte $54 ; .#.#.#..
                    .byte $54 ; .#.#.#..
                    .byte $00 ; ........
                    .byte $45 ; .#...#.#
                    .byte $45 ; .#...#.#
                    .byte $45 ; .#...#.#
                    .byte $40
                    
DatObjMummyOut      .byte $03
                    .byte $08
                    .byte $00
                    .byte $00, $01, $55 ; ...............#.#.#.#.#
                    .byte $00, $05, $55 ; .............#.#.#.#.#.#
                    .byte $00, $15, $55 ; ...........#.#.#.#.#.#.#
                    .byte $00, $55, $55 ; .........#.#.#.#.#.#.#.#
                    .byte $01, $55, $55 ; .......#.#.#.#.#.#.#.#.#
                    .byte $05, $55, $55 ; .....#.#.#.#.#.#.#.#.#.#
                    .byte $15, $55, $55 ; ...#.#.#.#.#.#.#.#.#.#.#
                    .byte $55, $55, $55 ; .#.#.#.#.#.#.#.#.#.#.#.#
                    .byte $20, $20, $20
                    
DatObjMummyAnkh     .byte $02
                    .byte $17
                    .byte $00
                    .byte $00, $00 ; ................
                    .byte $00, $00 ; ................
                    .byte $05, $00 ; .....#.#........
                    .byte $15, $40 ; ...#.#.#.#......
                    .byte $10, $40 ; ...#.....#......
                    .byte $40, $10 ; .#.........#....
                    .byte $40, $10 ; .#.........#....
                    .byte $40, $10 ; .#.........#....
                    .byte $40, $10 ; .#.........#....
                    .byte $40, $10 ; .#.........#....
                    .byte $10, $40 ; ...#.....#......
                    .byte $10, $40 ; ...#.....#......
                    .byte $10, $40 ; ...#.....#......
                    .byte $10, $40 ; ...#.....#......
                    .byte $05, $00 ; .....#.#........
                    .byte $05, $00 ; .....#.#........
                    .byte $aa, $a0 ; #.#.#.#.#.#.....
                    .byte $55, $50 ; .#.#.#.#.#.#....
                    .byte $05, $00 ; .....#.#........
                    .byte $05, $00 ; .....#.#........
                    .byte $05, $00 ; .....#.#........
                    .byte $05, $00 ; .....#.#........
                    .byte $05, $00 ; .....#.#........
ColObjMummyAnkh     .byte $b0, $a9, $a0
                    .byte $e8, $a0, $97
                    
DatObjKeyWhite      .byte $02
                    .byte $15
                    .byte $00
                    .byte $00, $00 ; ................
                    .byte $05, $50 ; .....#.#.#.#....
                    .byte $55, $55 ; .#.#.#.#.#.#.#.#
                    .byte $50, $05 ; .#.#.........#.#
                    .byte $50, $05 ; .#.#.........#.#
                    .byte $50, $05 ; .#.#.........#.#
                    .byte $15, $54 ; ...#.#.#.#.#.#..
                    .byte $05, $50 ; .....#.#.#.#....
                    .byte $01, $40 ; .......#.#......
                    .byte $01, $40 ; .......#.#......
                    .byte $02, $80 ; ......#.#.......
                    .byte $01, $40 ; .......#.#......
                    .byte $01, $40 ; .......#.#......
                    .byte $01, $40 ; .......#.#......
                    .byte $01, $40 ; .......#.#......
                    .byte $01, $44 ; .......#.#...#..
                    .byte $01, $54 ; .......#.#.#.#..
                    .byte $01, $50 ; .......#.#.#....
                    .byte $01, $50 ; .......#.#.#....
                    .byte $01, $54 ; .......#.#.#.#..
                    .byte $01, $44 ; .......#.#...#..
                    .byte $11, $11
                    .byte $11, $11
                    .byte $11, $11
                    
DatObjKeyRed        .byte $03
                    .byte $0f
                    .byte $00
                    .byte $00, $00, $00 ; ........................
                    .byte $14, $00, $00 ; ...#.#..................
                    .byte $14, $00, $00 ; ...#.#..................
                    .byte $15, $00, $00 ; ...#.#.#................
                    .byte $41, $00, $00 ; .#.....#................
                    .byte $55, $00, $00 ; .#.#.#.#................
                    .byte $41, $00, $00 ; .#.....#................
                    .byte $41, $55, $55 ; .#.....#.#.#.#.#.#.#.#.#
                    .byte $41, $96, $55 ; .#.....##..#.##..#.#.#.#
                    .byte $41, $00, $54 ; .#.....#.........#.#.#..
                    .byte $55, $00, $54 ; .#.#.#.#.........#.#.#..
                    .byte $41, $00, $10 ; .#.....#...........#....
                    .byte $55, $00, $10 ; .#.#.#.#...........#....
                    .byte $14, $01, $55 ; ...#.#.........#.#.#.#.#
                    .byte $14, $01, $45 ; ...#.#.........#.#...#.#
                    .byte $22, $22, $22
                    .byte $22, $22, $22
                    
DatObjKeyCyan       .byte $02
                    .byte $17
                    .byte $00
                    .byte $00, $00 ; ................
                    .byte $05, $50 ; .....#.#.#.#....
                    .byte $14, $14 ; ...#.#.....#.#..
                    .byte $54, $15 ; .#.#.#.....#.#.#
                    .byte $55, $55 ; .#.#.#.#.#.#.#.#
                    .byte $55, $55 ; .#.#.#.#.#.#.#.#
                    .byte $55, $55 ; .#.#.#.#.#.#.#.#
                    .byte $15, $54 ; ...#.#.#.#.#.#..
                    .byte $15, $54 ; ...#.#.#.#.#.#..
                    .byte $05, $50 ; .....#.#.#.#....
                    .byte $01, $40 ; .......#.#......
                    .byte $01, $40 ; .......#.#......
                    .byte $02, $80 ; ......#.#.......
                    .byte $01, $40 ; .......#.#......
                    .byte $01, $40 ; .......#.#......
                    .byte $01, $40 ; .......#.#......
                    .byte $01, $40 ; .......#.#......
                    .byte $01, $40 ; .......#.#......
                    .byte $01, $54 ; .......#.#.#.#..
                    .byte $01, $54 ; .......#.#.#.#..
                    .byte $01, $54 ; .......#.#.#.#..
                    .byte $01, $54 ; .......#.#.#.#..
                    .byte $01, $40 ; .......#.#......
                    .byte $33, $33
                    .byte $33, $33
                    .byte $33, $33
                    
DatObjKeyPurple     .byte $03
                    .byte $0f
                    .byte $00
                    .byte $00, $00, $00 ; ........................
                    .byte $00, $00, $50 ; .................#.#....
                    .byte $00, $01, $04 ; ...............#.....#..
                    .byte $00, $01, $04 ; ...............#.....#..
                    .byte $00, $01, $05 ; ...............#.....#.#
                    .byte $00, $01, $05 ; ...............#.....#.#
                    .byte $00, $01, $01 ; ...............#.......#
                    .byte $55, $55, $55 ; .#.#.#.#.#.#.#.#.#.#.#.#
                    .byte $55, $96, $55 ; .#.#.#.##..#.##..#.#.#.#
                    .byte $14, $01, $01 ; ...#.#.........#.......#
                    .byte $14, $01, $05 ; ...#.#.........#.....#.#
                    .byte $15, $01, $05 ; ...#.#.#.......#.....#.#
                    .byte $15, $01, $04 ; ...#.#.#.......#.....#..
                    .byte $14, $01, $04 ; ...#.#.........#.....#..
                    .byte $44, $00, $50 ; .#...#...........#.#....
                    .byte $44, $44, $44
                    .byte $44, $44, $44
                    
DatObjKeyGreen      .byte $03
                    .byte $0f
                    .byte $00
                    .byte $00, $00, $00 ; ........................
                    .byte $55, $40, $00 ; .#.#.#.#.#..............
                    .byte $55, $40, $00 ; .#.#.#.#.#..............
                    .byte $55, $40, $00 ; .#.#.#.#.#..............
                    .byte $55, $40, $00 ; .#.#.#.#.#..............
                    .byte $55, $40, $00 ; .#.#.#.#.#..............
                    .byte $55, $40, $00 ; .#.#.#.#.#..............
                    .byte $45, $55, $55 ; .#...#.#.#.#.#.#.#.#.#.#
                    .byte $45, $96, $55 ; .#...#.##..#.##..#.#.#.#
                    .byte $55, $40, $50 ; .#.#.#.#.#.......#.#....
                    .byte $55, $40, $54 ; .#.#.#.#.#.......#.#.#..
                    .byte $55, $40, $50 ; .#.#.#.#.#.......#.#....
                    .byte $55, $40, $54 ; .#.#.#.#.#.......#.#.#..
                    .byte $55, $40, $50 ; .#.#.#.#.#.......#.#....
                    .byte $55, $40, $00 ; .#.#.#.#.#..............
                    .byte $55, $55, $55
                    .byte $55, $55, $55
                    
DatObjKeyBlue       .byte $02
                    .byte $17
                    .byte $00
                    .byte $00, $00 ; ................
                    .byte $15, $54 ; ...#.#.#.#.#.#..
                    .byte $54, $15 ; .#.#.#.....#.#.#
                    .byte $54, $15 ; .#.#.#.....#.#.#
                    .byte $55, $55 ; .#.#.#.#.#.#.#.#
                    .byte $55, $55 ; .#.#.#.#.#.#.#.#
                    .byte $55, $55 ; .#.#.#.#.#.#.#.#
                    .byte $15, $54 ; ...#.#.#.#.#.#..
                    .byte $15, $54 ; ...#.#.#.#.#.#..
                    .byte $01, $40 ; .......#.#......
                    .byte $01, $40 ; .......#.#......
                    .byte $01, $40 ; .......#.#......
                    .byte $02, $80 ; ......#.#.......
                    .byte $01, $40 ; .......#.#......
                    .byte $01, $40 ; .......#.#......
                    .byte $01, $40 ; .......#.#......
                    .byte $01, $40 ; .......#.#......
                    .byte $01, $55 ; .......#.#.#.#.#
                    .byte $01, $55 ; .......#.#.#.#.#
                    .byte $01, $55 ; .......#.#.#.#.#
                    .byte $01, $45 ; .......#.#...#.#
                    .byte $01, $45 ; .......#.#...#.#
                    .byte $01, $40 ; .......#.#......
                    .byte $66, $66
                    .byte $66, $66
                    .byte $66, $66
                    
DatObjKeyYellow     .byte $03
                    .byte $0f
                    .byte $00
                    .byte $00, $00, $00 ; ........................
                    .byte $15, $00, $00 ; ...#.#.#................
                    .byte $44, $40, $00 ; .#...#...#..............
                    .byte $44, $40, $00 ; .#...#...#..............
                    .byte $55, $40, $00 ; .#.#.#.#.#..............
                    .byte $44, $40, $00 ; .#...#...#..............
                    .byte $44, $40, $00 ; .#...#...#..............
                    .byte $55, $55, $55 ; .#.#.#.#.#.#.#.#.#.#.#.#
                    .byte $55, $96, $55 ; .#.#.#.##..#.##..#.#.#.#
                    .byte $44, $40, $14 ; .#...#...#.........#.#..
                    .byte $44, $40, $14 ; .#...#...#.........#.#..
                    .byte $55, $40, $14 ; .#.#.#.#.#.........#.#..
                    .byte $44, $40, $10 ; .#...#...#.........#....
                    .byte $44, $40, $10 ; .#...#...#.........#....
                    .byte $15, $00, $00 ; ...#.#.#................
                    .byte $77, $77, $77
                    .byte $77, $77, $77
                    
DatObjLock          .byte $03
                    .byte $17
                    .byte $00
                    .byte $00, $00, $00 ; ........................
                    .byte $55, $55, $55 ; .#.#.#.#.#.#.#.#.#.#.#.#
                    .byte $55, $55, $55 ; .#.#.#.#.#.#.#.#.#.#.#.#
                    .byte $55, $41, $55 ; .#.#.#.#.#.....#.#.#.#.#
                    .byte $55, $00, $55 ; .#.#.#.#.........#.#.#.#
                    .byte $55, $00, $55 ; .#.#.#.#.........#.#.#.#
                    .byte $55, $00, $55 ; .#.#.#.#.........#.#.#.#
                    .byte $55, $41, $55 ; .#.#.#.#.#.....#.#.#.#.#
                    .byte $55, $41, $55 ; .#.#.#.#.#.....#.#.#.#.#
                    .byte $55, $41, $55 ; .#.#.#.#.#.....#.#.#.#.#
                    .byte $55, $41, $55 ; .#.#.#.#.#.....#.#.#.#.#
                    .byte $55, $41, $55 ; .#.#.#.#.#.....#.#.#.#.#
                    .byte $55, $41, $55 ; .#.#.#.#.#.....#.#.#.#.#
                    .byte $55, $41, $55 ; .#.#.#.#.#.....#.#.#.#.#
                    .byte $55, $00, $55 ; .#.#.#.#.........#.#.#.#
                    .byte $55, $00, $55 ; .#.#.#.#.........#.#.#.#
                    .byte $55, $00, $55 ; .#.#.#.#.........#.#.#.#
                    .byte $55, $00, $55 ; .#.#.#.#.........#.#.#.#
                    .byte $55, $00, $55 ; .#.#.#.#.........#.#.#.#
                    .byte $55, $00, $55 ; .#.#.#.#.........#.#.#.#
                    .byte $55, $55, $55 ; .#.#.#.#.#.#.#.#.#.#.#.#
                    .byte $55, $aa, $55 ; .#.#.#.##.#.#.#..#.#.#.#
                    .byte $55, $55, $55 ; .#.#.#.#.#.#.#.#.#.#.#.#
ColObjLock          .byte $80, $a0, $93
                    .byte $ff, $a4, $d2
                    .byte $a0, $b8, $b5
                    
DatObjGunPoleLe     .byte $01
                    .byte $08
                    .byte $00
                    .byte $3a ; ..###.#.
                    .byte $fa ; #####.#.
                    .byte $fa ; #####.#.
                    .byte $3a ; ..###.#.
                    .byte $3a ; ..###.#.
                    .byte $fa ; #####.#.
                    .byte $fa ; #####.#.
                    .byte $3a ; #.#.#.#.
                    .byte $06, $01
                    
DatObjGunPoleRi     .byte $01
                    .byte $08
                    .byte $00
                    .byte $ac ; #.#.##..
                    .byte $af ; #.#.####
                    .byte $af ; #.#.####
                    .byte $ac ; #.#.##..
                    .byte $ac ; #.#.##..
                    .byte $af ; #.#.####
                    .byte $af ; #.#.####
                    .byte $ac ; #.#.##..
                    .byte $06, $01
                    
DatObjGunMovRi01    .byte $02
                    .byte $0b
                    .byte $00
                    .byte $30, $30 ; ..##......##....
                    .byte $0c, $30 ; ....##....##....
                    .byte $c0, $cc ; ##....####..##..
                    .byte $e0, $cc ; ###.....##..##..
                    .byte $2a, $cc ; ..#.#.#.##..##..
                    .byte $2a, $ea ; ..#.#.#.###.#.#.
                    .byte $ea, $cc ; ###.#.#.##..##..
                    .byte $ec, $cc ; ###.##..##..##..
                    .byte $00, $cc ; ........##..##..
                    .byte $30, $30 ; ..##......##....
                    .byte $30, $30 ; ..##......##....
                    .byte $0e, $01
                    .byte $0e, $01
                    .byte $07, $0a
                    .byte $07, $0a
                    
DatObjGunMovRi02    .byte $02
                    .byte $0b
                    .byte $00
                    .byte $00, $30 ; ..........##....
                    .byte $cc, $30 ; ##..##....##....
                    .byte $cc, $cc ; ##..##..##..##..
                    .byte $20, $cc ; ..#.....##..##..
                    .byte $2a, $cc ; ..#.#.#.##..##..
                    .byte $ea, $ea ; ###.#.#.###.#.#.
                    .byte $ea, $cc ; ###.#.#.##..##..
                    .byte $2c, $cc ; ..#.##..##..##..
                    .byte $0c, $cc ; ....##..##..##..
                    .byte $c0, $30 ; ##........##....
                    .byte $30, $30 ; ..##......##....
                    .byte $0e, $01
                    .byte $0e, $01
                    .byte $07, $0a
                    .byte $07, $0a
                    
DatObjGunMovRi03    .byte $02
                    .byte $0b
                    .byte $00
                    .byte $30, $30 ; ..##......##....
                    .byte $c0, $30 ; ##........##....
                    .byte $0c, $cc ; ....##..##..##..
                    .byte $2c, $cc ; ..#.##..##..##..
                    .byte $ea, $cc ; ###.#.#.##..##..
                    .byte $ea, $ea ; ###.#.#.###.#.#.
                    .byte $2a, $cc ; ..#.#.#.##..##..
                    .byte $20, $cc ; ..#.....##..##..
                    .byte $cc, $cc ; ##..##..##..##..
                    .byte $cc, $30 ; ##..##....##....
                    .byte $00, $30 ; ..........##....
                    .byte $0e, $01
                    .byte $0e, $01
                    .byte $07, $0a
                    .byte $07, $0a
                    
DatObjGunMovRi04    .byte $02
                    .byte $0b
                    .byte $00
                    .byte $30, $30 ; ..##......##....
                    .byte $30, $30 ; ..##......##....
                    .byte $00, $cc ; ........##..##..
                    .byte $ec, $cc ; ###.##..##..##..
                    .byte $ea, $cc ; ###.#.#.##..##..
                    .byte $2a, $ea ; ..#.#.#.###.#.#.
                    .byte $2a, $cc ; ..#.#.#.##..##..
                    .byte $e0, $cc ; ###.....##..##..
                    .byte $c0, $cc ; ##......##..##..
                    .byte $0c, $30 ; ....##....##....
                    .byte $30, $30 ; ..##......##....
                    .byte $0e, $01
                    .byte $0e, $01
                    .byte $07, $0a
                    .byte $07, $0a
                    
DatObjGunMovLe01    .byte $02
                    .byte $0b
                    .byte $00
                    .byte $0c, $0c ;....##......##..
                    .byte $0c, $30 ; ....##....##....
                    .byte $3f, $03 ; ....####......##
                    .byte $3f, $0b ; ..######....#.##
                    .byte $3f, $a8 ; ..#######.#.#...
                    .byte $bf, $a8 ; #.#######.#.#...
                    .byte $3f, $ab ; ..#######.#.#.##
                    .byte $3f, $3b ; ..#######.##
                    .byte $3f, $00 ; ..######........
                    .byte $0c, $0c ; ....##......##..
                    .byte $0c, $0c ; ....##......##..
                    .byte $01, $0e
                    .byte $01, $0e
                    .byte $0a, $07
                    .byte $0a, $07
                    
DatObjGunMovLe02    .byte $02
                    .byte $0b
                    .byte $00
                    .byte $0c, $00 ; ....##..........
                    .byte $0c, $33 ; ....##....##..##
                    .byte $3f, $33 ; ..######..##..##
                    .byte $3f, $08 ; ..######..##..##
                    .byte $3f, $a8 ; ..#######.#.#...
                    .byte $bf, $ab ; #.#######.#.#.##
                    .byte $3f, $ab ; ..#######.#.#.##
                    .byte $3f, $38 ; ..######..###...
                    .byte $3f, $30 ; ..######..##....
                    .byte $0c, $03 ; ....##........##
                    .byte $0c, $0c ; ....##......##..
                    .byte $01, $0e
                    .byte $01, $0e
                    .byte $0a, $07
                    .byte $0a, $07
                    
DatObjGunMovLe03    .byte $02
                    .byte $0b
                    .byte $00
                    .byte $0c, $0c ; ....##......##..
                    .byte $0c, $03 ; ....##........##
                    .byte $3f, $30 ; ..######..##....
                    .byte $3f, $38 ; ..######..###...
                    .byte $3f, $ab ; ..#######.#.#.##
                    .byte $bf, $ab ; #.#######.#.#.##
                    .byte $3f, $a8 ; ..#######.#.#...
                    .byte $3f, $08 ; ..######....#...
                    .byte $3f, $33 ; ..######..##..##
                    .byte $0c, $33 ; ....##....##..##
                    .byte $0c, $00 ; ....##..........
                    .byte $01, $0e
                    .byte $01, $0e
                    .byte $0a, $07
                    .byte $0a, $07
                    
DatObjGunMovLe04    .byte $02
                    .byte $0b
                    .byte $00
                    .byte $0c, $0c ; ....##......##..
                    .byte $0c, $0c ; ....##......##..
                    .byte $3f, $00 ; ..######........
                    .byte $3f, $3b ; ..######..###.##
                    .byte $3f, $ab ; ..#######.#.#.##
                    .byte $bf, $a8 ; #.#######.#.#...
                    .byte $3f, $a8 ; ..#######.#.#...
                    .byte $3f, $0b ; ..######....#.##
                    .byte $3f, $03 ; ..######......##
                    .byte $0c, $30 ; ....##....##....
                    .byte $0c, $0c ; ....##......##..
                    .byte $01, $0e
                    .byte $01, $0e
                    .byte $0a, $07
                    .byte $0a, $07
                    
DatObjGunSwitch     .byte $02
                    .byte $17
                    .byte $00
                    .byte $00, $00 ; ................
                    .byte $01, $40 ; .......#.#......
                    .byte $01, $40 ; .......#.#......
                    .byte $05, $50 ; .....#.#.#.#....
                    .byte $05, $50 ; .....#.#.#.#....
                    .byte $15, $54 ; ...#.#.#.#.#.#..
                    .byte $15, $54 ; ...#.#.#.#.#.#..
                    .byte $01, $40 ; .......#.#......
                    .byte $00, $00 ; ................
                    .byte $01, $40 ; .......#.#......
                    .byte $05, $50 ; .....#.#.#.#....
                    .byte $05, $50 ; .....#.#.#.#....
                    .byte $05, $50 ; .....#.#.#.#....
                    .byte $05, $50 ; .....#.#.#.#....
                    .byte $02, $80 ; ......#.#.......
                    .byte $00, $00 ; ................
                    .byte $01, $40 ; .......#.#......
                    .byte $15, $54 ; ...#.#.#.#.#.#..
                    .byte $15, $54 ; ...#.#.#.#.#.#..
                    .byte $05, $50 ; .....#.#.#.#....
                    .byte $05, $50 ; .....#.#.#.#....
                    .byte $01, $40 ; .......#.#......
                    .byte $01, $40 ; .......#.#......
                    .byte $c0, $c0
                    .byte $11, $11
                    .byte $c0, $c0
                    
DatObjGunOper       .byte $02
                    .byte $01
                    .byte $00
                    .byte $00, $00 ; ................
ColObjGunOper01     .byte $e9
ColObjGunOper02     .byte $a0
                    
DatObjXmitBooth     .byte $04
                    .byte $20
                    .byte $00
                    .byte $00, $00, $00, $00 ; ................................
                    .byte $00, $00, $00, $00 ; ................................
                    .byte $03, $ff, $ff, $f8 ; ......#######################...
                    .byte $03, $ff, $ff, $f8 ; ......#######################...
                    .byte $0f, $ff, $ff, $e4 ; ....#######################..#..
                    .byte $0f, $ff, $ff, $e4 ; ....#######################..#..
                    .byte $3f, $ff, $ff, $94 ; ..#######################..#.#..
                    .byte $3f, $ff, $ff, $94 ; ..#######################..#.#..
                    .byte $ff, $ff, $fe, $54 ; #######################..#.#.#..
                    .byte $ff, $ff, $fe, $54 ; #######################..#.#.#..
                    .byte $ff, $57, $fe, $54 ; ########.#.#.##########..#.#.#..
                    .byte $fc, $55, $fe, $54 ; ######...#.#.#.########..#.#.#..
                    .byte $fc, $55, $fe, $54 ; ######...#.#.#.########..#.#.#..
                    .byte $f0, $55, $7e, $54 ; ####.....#.#.#.#.######..#.#.#..
                    .byte $f0, $55, $7e, $54 ; ####.....#.#.#.#.######..#.#.#..
                    .byte $f8, $55, $7e, $54 ; #####....#.#.#.#.######..#.#.#..
                    .byte $f8, $55, $7e, $54 ; #####....#.#.#.#.######..#.#.#..
                    .byte $f8, $55, $7e, $54 ; #####....#.#.#.#.######..#.#.#..
                    .byte $f8, $55, $7e, $54 ; #####....#.#.#.#.######..#.#.#..
                    .byte $fe, $55, $fe, $54 ; #######..#.#.#.########..#.#.#..
                    .byte $fe, $55, $fe, $54 ; #######..#.#.#.########..#.#.#..
                    .byte $ff, $d7, $fe, $54 ; ##########.#.##########..#.#.#..
                    .byte $ff, $ff, $fe, $54 ; #######################..#.#.#..
                    .byte $ff, $ff, $fe, $54 ; #######################..#.#.#..
                    .byte $ff, $ff, $fe, $00 ; #######################.........
                    .byte $ff, $ff, $fe, $00 ; #######################.........
                    .byte $ff, $ff, $fe, $00 ; #######################.........
                    .byte $ff, $ff, $fe, $00 ; #######################.........
                    .byte $ff, $ff, $fe, $00 ; #######################.........
                    .byte $ff, $ff, $fe, $00 ; #######################.........
                    .byte $ff, $ff, $fc, $00 ; ######################..........
                    .byte $ff, $ff, $fc, $00 ; ######################..........
                    .byte $0a, $0a, $0a, $0a
                    .byte $0a, $0a, $0a, $0a
                    .byte $0a, $0a, $0a, $0a
                    .byte $0a, $0a, $0a, $0a
                    .byte $0f, $0f, $0f, $0f
                    .byte $01, $01, $01, $01
                    .byte $01, $01, $01, $01
                    .byte $01, $01, $01, $01
                    
DatObjXmit          .byte $01
                    .byte $01
                    .byte $00
                    .byte $ff ; ########
                    .byte $0a
                    .byte $01
                    
DatObjXmitBack      .byte $03
                    .byte $01
                    .byte $00
                    .byte $00, $00, $00 ; ........................
ColObjXmitBack01    .byte $b0
ColObjXmitBack02    .byte $a0
ColObjXmitBack03    .byte $a0
ColObjXmitBack04    .byte $a0
ColObjXmitBack05    .byte $90
ColObjXmitBack06    .byte $b0
                    
DatObjXmitRcOv      .byte $02
                    .byte $0e
                    .byte $00
                    .byte $00, $00 ; ................
                    .byte $00, $00 ; ................
                    .byte $05, $40 ; .....#.#.#......
                    .byte $15, $50 ; ...#.#.#.#.#....
                    .byte $15, $50 ; ...#.#.#.#.#....
                    .byte $55, $54 ; .#.#.#.#.#.#.#..
                    .byte $55, $54 ; .#.#.#.#.#.#.#..
                    .byte $55, $54 ; .#.#.#.#.#.#.#..
                    .byte $55, $54 ; .#.#.#.#.#.#.#..
                    .byte $55, $54 ; .#.#.#.#.#.#.#..
                    .byte $55, $54 ; .#.#.#.#.#.#.#..
                    .byte $15, $50 ; ...#.#.#.#.#....
                    .byte $15, $50 ; ...#.#.#.#.#....
                    .byte $05, $40 ; .....#.#.#......
DatObjXmitRcOv01    .byte $a0
DatObjXmitRcOv02    .byte $e7
DatObjXmitRcOv03    .byte $a0
DatObjXmitRcOv04    .byte $8a
                    
DatObjTrapMov01     .byte $03
                    .byte $06
                    .byte $00
                    .byte $00, $00, $00 ; ........................
                    .byte $00, $00, $00 ; ........................
                    .byte $00, $00, $00 ; ........................
                    .byte $00, $00, $00 ; ........................
                    .byte $00, $00, $00 ; ........................
                    .byte $0a, $aa, $00 ; ....#.#.#.#.#.#.........
ColObjTrapMov011    .byte $b1
ColObjTrapMov012    .byte $90
ColObjTrapMov013    .byte $a0
                    .byte $09, $09, $09
                    
DatObjTrapMov02     .byte $03
                    .byte $05
                    .byte $00
                    .byte $00, $00, $00 ; ........................
                    .byte $00, $00, $00 ; ........................
                    .byte $00, $00, $00 ; ........................
                    .byte $00, $00, $00 ; ........................
                    .byte $0a, $aa, $00 ; ....#.#.#.#.#.#.........
ColObjTrapMov021    .byte $a0
ColObjTrapMov022    .byte $80
ColObjTrapMov023    .byte $a0
                    .byte $09, $09, $09
                    
DatObjTrapMov03     .byte $03
                    .byte $04
                    .byte $00
                    .byte $00, $00, $00 ; ........................
                    .byte $00, $00, $00 ; ........................
                    .byte $00, $00, $00 ; ........................
                    .byte $02, $aa, $80 ; ......#.#.#.#.#.#.......
ColObjTrapMov031    .byte $a0
ColObjTrapMov032    .byte $a0
ColObjTrapMov033    .byte $90
                    .byte $09, $09, $09
                    
DatObjTrapMov04     .byte $03
                    .byte $03
                    .byte $00
                    .byte $00, $00, $00 ; ........................
                    .byte $00, $00, $00 ; ........................
                    .byte $01, $55, $40 ; .......#.#.#.#.#.#......
ColObjTrapMov041    .byte $c5
ColObjTrapMov042    .byte $c2
ColObjTrapMov043    .byte $90
                    .byte $09, $09, $09
                    
DatObjTrapMov05     .byte $03
                    .byte $02
                    .byte $00
                    .byte $00, $00, $00 ; ........................
                    .byte $00, $55, $50 ; .........#.#.#.#.#.#....
ColObjTrapMov051    .byte $a0
ColObjTrapMov052    .byte $80
ColObjTrapMov053    .byte $ac
                    .byte $09, $09, $09
                    
DatObjTrapMov06     .byte $03
                    .byte $01
                    .byte $00
                    .byte $00, $55, $50 ; .........#.#.#.#.#.#....
ColObjTrapMov061    .byte $a0
ColObjTrapMov062    .byte $ac
ColObjTrapMov063    .byte $c8
                    .byte $09, $09, $09
                    
DatObjTrapMovBas    .byte $01
                    .byte $01
                    .byte $00
                    .byte $aa ; #.#.#.#.
                    .byte $00
                    .byte $09
                    
DatObjTrapSw        .byte $01
                    .byte $17
                    .byte $00
                    .byte $00 ; ........
                    .byte $14 ; ...#.#..
                    .byte $55 ; .#.#.#.#
                    .byte $55 ; .#.#.#.#
                    .byte $55 ; .#.#.#.#
                    .byte $55 ; .#.#.#.#
                    .byte $14 ; ...#.#..
                    .byte $00 ; ........
                    .byte $14 ; ...#.#..
                    .byte $14 ; ...#.#..
                    .byte $14 ; ...#.#..
                    .byte $14 ; ...#.#..
                    .byte $14 ; ...#.#..
                    .byte $14 ; ...#.#..
                    .byte $14 ; ...#.#..
                    .byte $14 ; ...#.#..
                    .byte $00 ; ........
                    .byte $14 ; ...#.#..
                    .byte $aa ; #.#.#.#.
                    .byte $55 ; .#.#.#.#
                    .byte $55 ; .#.#.#.#
                    .byte $55 ; .#.#.#.#
                    .byte $14 ; ...#.#..
ColObjTrapSw01      .byte $c0
                    .byte $10
ColObjTrapSw02      .byte $cc
                    
DatObjTrapOpen      .byte $03
                    .byte $06
                    .byte $00
                    .byte $00, $55, $50 ; .........#.#.#.#.#.#....
                    .byte $00, $55, $50 ; .........#.#.#.#.#.#....
                    .byte $01, $55, $40 ; .......#.#.#.#.#.#......
                    .byte $02, $aa, $80 ; ......#.#.#.#.#.#.......
                    .byte $0a, $aa, $00 ; ....#.#.#.#.#.#.........
                    .byte $0a, $aa, $00 ; ....#.#.#.#.#.#.........
                    
DatObjBlank         .byte $03
                    .byte $01
                    .byte $00
                    .byte $ff ; ########
                    .byte $ff ; ########
                    .byte $ff ; ########
                    
DatObjWalkBlank     .byte $08
                    .byte $06
                    .byte $00
                    .byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; ################################################################
                    .byte $0f, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; ....############################################################
                    .byte $3f, $ff, $ff, $ff, $ff, $ff, $ff, $fc ; ..############################################################..
                    .byte $3f, $ff, $ff, $ff, $ff, $ff, $ff, $fc ; ..############################################################..
                    .byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $f0 ; ############################################################....
                    .byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $f0 ; ############################################################....
                    
DatObjWalkMov01     .byte $08
                    .byte $06
                    .byte $00
                    .byte $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa ; #.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.
                    .byte $51, $41, $41, $41, $41, $41, $41, $40 ; .#.#...#.#.....#.#.....#.#.....#.#.....#.#.....#.#.....#.#......
                    .byte $45, $05, $05, $05, $05, $05, $05, $01 ; .#...#.#.....#.#.....#.#.....#.#.....#.#.....#.#.....#.#.......#
                    .byte $8a, $0a, $0a, $0a, $0a, $0a, $0a, $02 ; #...#.#.....#.#.....#.#.....#.#.....#.#.....#.#.....#.#.......#.
                    .byte $28, $28, $28, $28, $28, $28, $28, $0a ; ..#.#.....#.#.....#.#.....#.#.....#.#.....#.#.....#.#.....#.#.#.
                    .byte $28, $28, $28, $28, $28, $28, $28, $0a ; ..#.#.....#.#.....#.#.....#.#.....#.#.....#.#.....#.#.....#.#.#.
ColObjWalkMov011    .byte $c9, $a0, $af, $b1, $a0, $a2, $a0, $8a
                    .byte $09, $09, $09, $09, $09, $09, $09, $09
                    
DatObjWalkMov02     .byte $08
                    .byte $06
                    .byte $00
                    .byte $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa ; #.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.
                    .byte $50, $50, $50, $50, $50, $50, $50, $50 ; .#.#.....#.#.....#.#.....#.#.....#.#.....#.#.....#.#.....#.#....
                    .byte $41, $41, $41, $41, $41, $41, $41, $41 ; .#.....#.#.....#.#.....#.#.....#.#.....#.#.....#.#.....#.#.....#
                    .byte $82, $82, $82, $82, $82, $82, $82, $82 ; #.....#.#.....#.#.....#.#.....#.#.....#.#.....#.#.....#.#.....#.
                    .byte $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a ; ....#.#.....#.#.....#.#.....#.#.....#.#.....#.#.....#.#.....#.#.
                    .byte $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a ; ....#.#.....#.#.....#.#.....#.#.....#.#.....#.#.....#.#.....#.#.
ColObjWalkMov021    .byte $b2, $b9, $a0, $a6, $b0, $a0, $f0, $80
                    .byte $09, $09, $09, $09, $09, $09, $09, $09
                    
DatObjWalkMov03     .byte $08
                    .byte $06
                    .byte $00
                    .byte $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa ; #.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.
                    .byte $50, $14, $14, $14, $14, $14, $14, $14 ; .#.#.......#.#.....#.#.....#.#.....#.#.....#.#.....#.#.....#.#..
                    .byte $40, $50, $50, $50, $50, $50, $50, $51 ; .#.......#.#.....#.#.....#.#.....#.#.....#.#.....#.#.....#.#....
                    .byte $80, $a0, $a0, $a0, $a0, $a0, $a0, $a2 ; #.......#.#.....#.#.....#.#.....#.#.....#.#.....#.#.....#.#...#.
                    .byte $02, $82, $82, $82, $82, $82, $82, $8a ; ......#.#.....#.#.....#.#.....#.#.....#.#.....#.#.....#.#...#.#.
                    .byte $02, $82, $82, $82, $82, $82, $82, $8a ; ......#.#.....#.#.....#.#.....#.#.....#.#.....#.#.....#.#...#.#.
ColObjWalkMov031    .byte $8f, $a0, $89, $a0, $a0, $ff, $a0, $e7
                    .byte $09, $09, $09, $09, $09, $09, $09, $09
                    
DatObjWalkMov04     .byte $08
                    .byte $06
                    .byte $00
                    .byte $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa ; #.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.#.
                    .byte $51, $05, $05, $05, $05, $05, $05, $04 ; .#.#...#.....#.#.....#.#.....#.#.....#.#.....#.#.....#.#.....#..
                    .byte $44, $14, $14, $14, $14, $14, $14, $11 ; .#...#.....#.#.....#.#.....#.#.....#.#.....#.#.....#.#.....#...#
                    .byte $88, $28, $28, $28, $28, $28, $28, $22 ; #...#.....#.#.....#.#.....#.#.....#.#.....#.#.....#.#.....#...#.
                    .byte $20, $a0, $a0, $a0, $a0, $a0, $a0, $8a ; ..#.....#.#.....#.#.....#.#.....#.#.....#.#.....#.#.....#...#.#.
                    .byte $20, $a0, $a0, $a0, $a0, $a0, $a0, $8a ; ..#.....#.#.....#.#.....#.#.....#.#.....#.#.....#.#.....#...#.#.
ColObjWalkMov041    .byte $b6, $a0, $e6, $a0, $8c, $a0, $a0, $ba
                    .byte $09, $09, $09, $09, $09, $09, $09, $09
                    
DatObjWalkSw        .byte $03
                    .byte $08
                    .byte $00
                    .byte $00, $00, $00 ; ........................
                    .byte $01, $00, $40 ; .......#.........#......
                    .byte $05, $14, $50 ; .....#.#...#.#...#.#....
                    .byte $14, $55, $14 ; ...#.#...#.#.#.#...#.#..
                    .byte $54, $55, $15 ; .#.#.#...#.#.#.#...#.#.#
                    .byte $14, $55, $14 ; ...#.#...#.#.#.#...#.#..
                    .byte $05, $14, $50 ; .....#.#...#.#...#.#....
                    .byte $01, $00, $40 ; .......#.........#......
ColObjWalkSw01      .byte $c0
                    .byte $10
ColObjWalkSw02      .byte $c0
                    
DatObjWalkSpot      .byte $01
                    .byte $03
                    .byte $00
                    .byte $00 ; ........
                    .byte $00 ; ........
                    .byte $aa ; #.#.#.#.
                    .byte $00
                    
DatObjFrankCofRi    .byte $02
                    .byte $20
                    .byte $00
                    .byte $00, $00 ; ................
                    .byte $00, $00 ; ................
                    .byte $03, $fc ; ......########..
                    .byte $03, $fc ; ......########..
                    .byte $0f, $f4 ; ....########.#..
                    .byte $0f, $f4 ; ....########.#..
                    .byte $3f, $d4 ; ..########.#.#..
                    .byte $3f, $d4 ; ..########.#.#..
                    .byte $aa, $54 ; #.#.#.#..#.#.#..
                    .byte $aa, $54 ; #.#.#.#..#.#.#..
                    .byte $aa, $54 ; #.#.#.#..#.#.#..
                    .byte $aa, $54 ; #.#.#.#..#.#.#..
                    .byte $aa, $54 ; #.#.#.#..#.#.#..
                    .byte $aa, $54 ; #.#.#.#..#.#.#..
                    .byte $aa, $54 ; #.#.#.#..#.#.#..
                    .byte $aa, $54 ; #.#.#.#..#.#.#..
                    .byte $aa, $54 ; #.#.#.#..#.#.#..
                    .byte $aa, $54 ; #.#.#.#..#.#.#..
                    .byte $aa, $54 ; #.#.#.#..#.#.#..
                    .byte $aa, $54 ; #.#.#.#..#.#.#..
                    .byte $aa, $54 ; #.#.#.#..#.#.#..
                    .byte $aa, $54 ; #.#.#.#..#.#.#..
                    .byte $aa, $54 ; #.#.#.#..#.#.#..
                    .byte $aa, $54 ; #.#.#.#..#.#.#..
                    .byte $aa, $00 ; #.#.#.#.........
                    .byte $aa, $00 ; #.#.#.#.........
                    .byte $aa, $00 ; #.#.#.#.........
                    .byte $aa, $00 ; #.#.#.#.........
                    .byte $aa, $00 ; #.#.#.#.........
                    .byte $aa, $00 ; #.#.#.#.........
                    .byte $ff, $00 ; ########........
                    .byte $ff, $00 ; ########........
                    .byte $a7, $a7
                    .byte $a7, $a7
                    .byte $a7, $a7
                    .byte $a7, $a7
                    .byte $01, $01
                    .byte $00, $00
                    .byte $00, $00
                    .byte $09, $09
                    
DatObjFrankCofLe    .byte $02
                    .byte $20
                    .byte $00
                    .byte $00, $00 ; ................
                    .byte $00, $00 ; ................
                    .byte $03, $fc ; ......########..
                    .byte $03, $fc ; ......########..
                    .byte $0f, $f8 ; ....#########...
                    .byte $0f, $f8 ; ....#########...
                    .byte $3f, $e8 ; ..#########.#...
                    .byte $3f, $e8 ; ..#########.#...
                    .byte $aa, $a8 ; #.#.#.#.#.#.#...
                    .byte $aa, $a8 ; #.#.#.#.#.#.#...
                    .byte $aa, $a8 ; #.#.#.#.#.#.#...
                    .byte $aa, $a8 ; #.#.#.#.#.#.#...
                    .byte $aa, $a8 ; #.#.#.#.#.#.#...
                    .byte $aa, $a8 ; #.#.#.#.#.#.#...
                    .byte $aa, $a8 ; #.#.#.#.#.#.#...
                    .byte $aa, $a8 ; #.#.#.#.#.#.#...
                    .byte $aa, $a8 ; #.#.#.#.#.#.#...
                    .byte $aa, $a8 ; #.#.#.#.#.#.#...
                    .byte $aa, $a8 ; #.#.#.#.#.#.#...
                    .byte $aa, $a8 ; #.#.#.#.#.#.#...
                    .byte $aa, $a8 ; #.#.#.#.#.#.#...
                    .byte $aa, $a8 ; #.#.#.#.#.#.#...
                    .byte $aa, $a8 ; #.#.#.#.#.#.#...
                    .byte $aa, $a8 ; #.#.#.#.#.#.#...
                    .byte $aa, $a8 ; #.#.#.#.#.#.#...
                    .byte $aa, $ac ; #.#.#.#.#.#.##..
                    .byte $aa, $ac ; #.#.#.#.#.#.##..
                    .byte $aa, $b0 ; #.#.#.#.#.##....
                    .byte $aa, $b0 ; #.#.#.#.#.##....
                    .byte $aa, $c0 ; #.#.#.#.##......
                    .byte $ff, $c0 ; ##########......
                    .byte $ff, $00 ; ########........
                    .byte $a7, $a7
                    .byte $a7, $a7
                    .byte $a7, $a7
                    .byte $a7, $a7
                    .byte $01, $01
                    .byte $00, $00
                    .byte $00, $00
                    .byte $09, $09
                    
DatObjFrankCover    .byte $02
                    .byte $06
                    .byte $00
                    .byte $ff, $ff ; ################
                    .byte $ff, $ff ; ################
                    .byte $ff, $ff ; ################
                    .byte $ff, $ff ; ################
                    .byte $ff, $ff ; ################
                    .byte $ff, $ff ; ################
                    
DatObjTime          .byte $08
                    .byte $07
                    .byte $00
DatObjTimeData      .byte $00, $00, $00, $00, $00, $00, $00, $00 ; ................................................................
                    .byte $00, $00, $30, $00, $00, $30, $00, $00 ; ................................................................
                    .byte $00, $00, $30, $00, $00, $30, $00, $00 ; ..................##......................##....................
                    .byte $00, $00, $00, $00, $00, $00, $00, $00 ; ................................................................
                    .byte $00, $00, $30, $00, $00, $30, $00, $00 ; ..................##......................##....................
                    .byte $00, $00, $30, $00, $00, $30, $00, $00 ; ..................##......................##....................
                    .byte $00, $00, $00, $00, $00, $00, $00, $00 ; ................................................................
                    .byte $a0, $a5, $a0, $a2, $a0, $a0, $b0, $a0
                    .byte $01, $01, $01, $01, $01, $01, $01, $01
                    
DatObjCharBack      .byte $02
DatObjCharBackRo    .byte $18
                    .byte $00
                    .byte $ff, $ff ; ################
                    .byte $ff, $ff ; ################
                    .byte $ff, $ff ; ################
                    .byte $ff, $ff ; ################
                    .byte $ff, $ff ; ################
                    .byte $ff, $ff ; ################
                    .byte $ff, $ff ; ################
                    .byte $ff, $ff ; ################
                    .byte $ff, $ff ; ################
                    .byte $ff, $ff ; ################
                    .byte $ff, $ff ; ################
                    .byte $ff, $ff ; ################
                    .byte $ff, $ff ; ################
                    .byte $ff, $ff ; ################
                    .byte $ff, $ff ; ################
                    .byte $ff, $ff ; ################
                    .byte $ff, $ff ; ################
                    .byte $ff, $ff ; ################
                    .byte $ff, $ff ; ################
                    .byte $ff, $ff ; ################
                    .byte $ff, $ff ; ################
                    .byte $ff, $ff ; ################
                    .byte $ff, $ff ; ################
                    .byte $ff, $ff ; ################
                    
DatObjChar          .byte $02
DatObjCharRows      .byte $18
                    .byte $00
DatObjCharData      .byte $d2, $a0 ; ##.#..#.#.#.....
                    .byte $e8, $c2 ; ###.#...##....#.
                    .byte $a0, $85 ; #.#.....#....#.#
                    .byte $a0, $aa ; #.#.....#.#.#.#.
                    .byte $b7, $d5 ; #.##.#####.#.#.#
                    .byte $80, $c6 ; #.......##...##.
                    .byte $a9, $a0 ; #.#.#..##.#.....
                    .byte $e8, $c6 ; ###.#...##...##.
                    .byte $8c, $a0 ; #...##..#.#.....
                    .byte $81, $85 ; #......##....#.#
                    .byte $ba, $a4 ; #.###.#.#.#..#..
                    .byte $e5, $a0 ; ###..#.##.#.....
                    .byte $f5, $a0 ; ####.#.##.#.....
                    .byte $a5, $c6 ; #.#..#.###...##.
                    .byte $b0, $e0 ; #.##....###.....
                    .byte $c4, $a5 ; ##...#..#.#..#.#
                    .byte $a0, $aa ; #.#.....#.#.#.#.
                    .byte $a0, $a0 ; #.#.....#.#.....
                    .byte $b3, $c2 ; #.##..####....#.
                    .byte $a1, $a0 ; #.#....##.#.....
                    .byte $c9, $b5 ; ##..#..##.##.#.#
                    .byte $a0, $c3 ; #.#.....##....##
                    .byte $a0, $84 ; #.#.....#....#..
                    .byte $a0, $85 ; #.#.....#....#.#
                    .byte $d2, $b7 ; ##.#..#.#.##.###
                    .byte $85, $80 ; #....#.##.......
                    .byte $a0, $89 ; #.#.....#...#..#
; ------------------------------------------------------------------------------------------------------------- ;
; SetLvlLoadScrn    Function: 
;                   Parms   : 
;                   Returns : 
; ------------------------------------------------------------------------------------------------------------- ;
                    subroutine
SetLvlLoadScrn      pha
                    tya
                    pha
                    txa
                    pha
                    
                    lda #<CC_ScrnOptFile
                    sta $30
                    lda #>CC_ScrnOptFile
                    sta $31
                    
                    ldx #$03
                    ldy #$00
                    lda #" " ; $20
.BlankOut           sta ($30),y                     ; $0400 - default screen memory blanked out
                    iny
                    bne .BlankOut
                    
                    inc $31
                    dex
                    bpl .BlankOut
                    
                    lda #$00
                    sta WrkDatScrnTabOff
                    
                    lda #<TextSelectScreen ; $60
                    sta $3e
                    lda #>TextSelectScreen ; $77
                    sta $3f
                    
.NextLine           ldy #$00
                    lda ($3e),y                     ; $7760 - $05 $03 $ff
                    cmp #$ff                        ; EndOfTextSelectScreenData
                    beq .SetCursor
                    
                    ldy #$02
                    lda ($3e),y
                    cmp #$ff                        ; header line
                    beq .SetHeaderLine
                    
.SetSelectLineI     ldy #$00                        ; start pos in screen row
                    ldx WrkDatScrnTabOff
.SetSelectLine      lda ($3e),y
                    sta CC_TextScrnRowX,x
                    inx
                    iny                             ; screen row number
                    cpy #$03
                    bcc .SetSelectLine
                    
                    inx
                    stx WrkDatScrnTabOff
                    
.SetHeaderLine      ldy #$01                        ; screen row number
                    lda ($3e),y
                    tax
                    
                    clc
                    lda TabCtrlScrRowsLo,x
                    adc #$00
                    sta $30
                    lda TabCtrlScrRowsHi,x
                    adc #$04
                    sta $31
                    
                    clc
                    lda $30
                    ldy #$00                        ; start pos in screen row
                    adc ($3e),y
                    sta $30
                    bcc .AddRows
                    inc $31
                    
.AddRows            ldy #$00
                    clc
                    lda $3e
                    adc #$03
                    sta $3e
                    bcc .ScreenLineOut
                    inc $3f
                    
.ScreenLineOut      lda ($3e),y
                    and #$3f
                    sta ($30),y
                    lda ($3e),y
                    bmi .EndOfLine
                    
                    iny
                    jmp .ScreenLineOut
                    
.EndOfLine          clc
                    iny
                    tya
                    adc $3e
                    sta $3e
                    bcc .NextLine
                    inc $3f
                    
                    jmp .NextLine
                    
.SetCursor          ldx CC_TextScrnCrsrY
                    clc
                    lda #$00
                    adc TabCtrlScrRowsLo,x
                    sta $30
                    lda #$04
                    adc TabCtrlScrRowsHi,x
                    sta $31
                    
                    ldy CC_TextScrnCrsrX
                    dey
                    dey
                    lda #">"
                    sta ($30),y
                    
                    clc
                    ldx #$07                        ; unlimited lives screen row number
                    lda #$00
                    adc TabCtrlScrRowsLo,x
                    sta $30
                    lda #$04
                    adc TabCtrlScrRowsHi,x
                    sta $31
                    
                    ldy #$17                        ; offset start "off"
.MarkLivesOff       lda ($30),y
                    ora #$80
                    sta ($30),y
                    iny
                    cpy #$1a                        ; offset end "off"
                    bcc .MarkLivesOff
                    
.ReadDirectory      lda #"$"                        ; $0:z*
                    sta LoadFileNameId
                    lda #"0"
                    sta LoadFileNameId + 1
                    lda #":"
                    sta LoadFileNameId + 2
                    lda #"Z"
                    sta LoadFileNameId + 3
                    lda #"*"
                    sta LoadFileNameId + 4
                    
                    lda #$05
                    sta LoadFileNamLen
                    lda #$01
                    sta LoadFileAdrFlag             ; entry 2: $9800
                    
                    jsr PrepareIO
                    jsr LoadLevelData               ; load z* file names to $9800
                    jsr WaitRestart
                    
                    lda #<CC_LvlStor
                    sta $30
                    lda #>CC_LvlStor
                    sta $31
                    
                    lda #CC_TextScrnDynS            ; start row of dynamically filled screen area
                    sta SavOutputRowDyn
                    
                    lda #CC_TextScrnColL            ; default start column of left output area
                    sta SavOutputCol
                    
.ChkEndOfData       lda $31
                    cmp LoadFileEoDHi               ; address: end of loaded directory data
                    bcc .GetData                    ; lower
                    
                    bne .GoExit                     ; higher - finish
                    
                    lda $30                         ; equal
                    cmp LoadFileEoDLo               ; address: end of loaded directory data
                    bcs .GoExit                     ; equal or higher - finish
                    
.GetData            ldy #$00
                    lda ($30),y                     ; from $9800
                    iny
                    ora ($30),y
                    bne .PassHeader                 ; $00 $00 = EndOfDirData
                    
.GoExit             jmp .Exit                       ; finish
                    
.PassHeader         clc
                    lda $30
                    adc #$04                        ; header length
                    sta $30
                    bcc .FindStart
                    inc $31
                    
.FindStart          ldy #$00
                    lda ($30),y
                    bne .ChkStartApost
                    
                    inc $30
                    bne .ChkEndOfData
                    inc $31
                    jmp .ChkEndOfData
                    
.ChkStartApost      cmp #$22                        ; "
                    bne .SetNextChr
                    
                    iny                             ; start of filename
                    lda ($30),y                     ; get next chr
                    cmp #"Z" ; $5a                  ; z
                    beq .FoundName
                    
.SetNextChr         inc $30                         ; get next chr
                    bne .FindStart
                    inc $31
                    jmp .FindStart
                    
.FoundName          ldx WrkDatScrnTabOff
                    lda SavOutputCol
                    sta CC_TextScrnRowX,x
                    
                    lda SavOutputRowDyn
                    sta CC_TextScrnRowY,x
                    
                    lda #CC_TextScrnFile            ; type: dynamic castle data file entry
                    sta CC_TextScrnType,x
                    
                    ldx SavOutputRowDyn
                    clc
                    lda TabCtrlScrRowsLo,x
                    adc #$00
                    sta $32
                    lda TabCtrlScrRowsHi,x
                    adc #$04
                    sta $33
                    
                    ldx SavOutputCol
                    dex
                    dex
                    clc
                    txa
                    adc $32
                    sta $32
                    bcc .ChkEndApostI
                    inc $33
                    
.ChkEndApostI       ldy #$02                        ; bypass the "Z
.ChkEndApost        lda ($30),y
                    cmp #$22                        ; "
                    beq .StoreFileLen
                    
                    and #$3f
.ScreenOut          sta ($32),y
                    iny
                    jmp .ChkEndApost
                    
.StoreFileLen       ldx WrkDatScrnTabOff
                    tya
                    sta CC_TextScrnLen,x
                    dec CC_TextScrnLen,x
                    
.NextCtrlEntry      inx
                    inx
                    inx
                    inx                             ; each control entry is 4 bytes long
                    stx WrkDatScrnTabOff            ; point to next entry
                    
                    clc
                    tya
                    adc $30
                    sta $30
                    bcc .ChkLeftArea
                    inc $31
                    
.ChkLeftArea        lda SavOutputCol
                    cmp #CC_TextScrnColL            ; default start column of left  output area
                    bne .SetLeftArea
                    
.SetRightArea       lda #CC_TextScrnColR            ; default start column of right output area
                    sta SavOutputCol
.GoGetNextChr       jmp .SetNextChr
                    
.SetLeftArea        lda #CC_TextScrnColL
                    sta SavOutputCol
                    inc SavOutputRowDyn
                    lda SavOutputRowDyn
                    cmp #CC_TextScrnDynE            ; end row of dynamically filled screen area
                    bcc .GoGetNextChr
                    
.Exit               ldx WrkDatScrnTabOff
                    dex
                    dex
                    dex
                    dex                             ; each control entry is 4 bytes long
                    stx MaxDatScrnTabOff            ; save offset of last control data entry
                    
                    lda #$08                        ; first point to: unlim lives on/off entry
                    sta WrkDatScrnTabOff
                    
SetLvlLoadScrnX     pla
                    tax
                    pla
                    tay
                    pla
                    rts
; ------------------------------------------------------------------------------------------------------------- ;
SavOutputCol        .byte $a0
SavOutputRowDyn     .byte $a0
; ------------------------------------------------------------------------------------------------------------- ;
TextSelectScreen    .byte $05                       ; start pos in screen row
                    .byte $03                       ; screen row number
                    .byte $ff                       ; header: not selectable
                    
                    .byte $55                       ; use joystick 1 to move pointeR
                    .byte $53
                    .byte $45
                    .byte $20
                    .byte $4a
                    .byte $4f
                    .byte $59
                    .byte $53
                    .byte $54
                    .byte $49
                    .byte $43
                    .byte $4b
                    .byte $20
                    .byte $31
                    .byte $20
                    .byte $54
                    .byte $4f
                    .byte $20
                    .byte $4d
                    .byte $4f
                    .byte $56
                    .byte $45
                    .byte $20
                    .byte $50
                    .byte $4f
                    .byte $49
                    .byte $4e
                    .byte $54
                    .byte $45
                    .byte $d2
                    
                    .byte $05                       ; start pos in screen row
                    .byte $04                       ; screen row number
                    .byte $ff                       ; header: not selectable
                    
                    .byte $50                       ; press trigger button to selecT
                    .byte $52
                    .byte $45
                    .byte $53
                    .byte $53
                    .byte $20
                    .byte $54
                    .byte $52
                    .byte $49
                    .byte $47
                    .byte $47
                    .byte $45
                    .byte $52
                    .byte $20
                    .byte $42
                    .byte $55
                    .byte $54
                    .byte $54
                    .byte $4f
                    .byte $4e
                    .byte $20
                    .byte $54
                    .byte $4f
                    .byte $20
                    .byte $53
                    .byte $45
                    .byte $4c
                    .byte $45
                    .byte $43
                    .byte $d4
                    
                    .byte $03                       ; start pos in screen row
                    .byte $06                       ; screen row number
                    .byte $03                       ; selectable: resume
                    
                    .byte $52                       ; resume gameE
                    .byte $45
                    .byte $53
                    .byte $55
                    .byte $4d
                    .byte $45
                    .byte $20
                    .byte $47
                    .byte $41
                    .byte $4d
                    .byte $c5
                    
                    .byte $16                       ; start pos in screen row
                    .byte $06                       ; screen row number
                    .byte $04                       ; selectable: best times
                    
                    .byte $56                       ; view best timeS
                    .byte $49
                    .byte $45
                    .byte $57
                    .byte $20
                    .byte $42
                    .byte $45
                    .byte $53
                    .byte $54
                    .byte $20
                    .byte $54
                    .byte $49
                    .byte $4d
                    .byte $45
                    .byte $d3
                    
                    .byte $03                       ; start pos in screen row
                    .byte $07                       ; screen row number
                    .byte $00                       ; selectable: unlim lives
                    
                    .byte $55                       ; unlimited lives (on/off)
                    .byte $4e
                    .byte $4c
                    .byte $49
                    .byte $4d
                    .byte $49
                    .byte $54
                    .byte $45
                    .byte $44
                    .byte $20
                    .byte $4c
                    .byte $49
                    .byte $56
                    .byte $45
                    .byte $53
                    .byte $20
                    .byte $28
                    .byte $4f
                    .byte $4e
                    .byte $2f
                    .byte $4f
                    .byte $46
                    .byte $46
                    .byte $a9
                    
                    .byte $03                       ; start pos in screen row
                    .byte $08                       ; screen row number
                    .byte $01                       ; selectable: exit
                    
                    .byte $45                       ; exit menU
                    .byte $58
                    .byte $49
                    .byte $54
                    .byte $20
                    .byte $4d
                    .byte $45
                    .byte $4e
                    .byte $d5
                    
                    .byte $03                       ; start pos in screen row
                    .byte $0a                       ; screen row number
                    .byte $ff                       ; header: not selectable
                    
                    .byte $4c                       ; load game:
                    .byte $4f
                    .byte $41
                    .byte $44
                    .byte $20
                    .byte $47
                    .byte $41
                    .byte $4d
                    .byte $45
                    .byte $ba
                    
                    .byte $ff                       ; end of screen text
; ------------------------------------------------------------------------------------------------------------- ;
TabSoundsDataCpy    = *                             ; $77f7 - copied to  $7572  killing subroutine SetLvlLoadScrn
TabSoundsDataPtr    = SetLvlLoadScrn                ; $7572 - used with: InitSoundFX
                    
SndGunShot          .word SFX_GunShot               ; $758c - ray gun shot
SndTrapSwitch       .word SFX_TrapSwitch            ; $7598 - trap door switch
SndForcePing        .word SFX_ForcePing             ; $75a4 - close force field pings
SndOpenDoor         .word SFX_OpenDoor              ; $75b0 - open doors
SndMaTrXmit         .word SFX_MatterXmit            ; $75bc - matter transmitter: transmit
SndMaTrSelect       .word SFX_MatterSelect          ; $75d4 - matter transmitter: select receiver oval
SndLiMacSwitch      .word SFX_LightSwitch           ; $75e0 - lightning machine switch
SndFrankOut         .word SFX_FrankOut              ; $75ec - frankenstein out
SndDeath            .word SFX_Death                 ; $7605 - player/mummy/frank death
SndMapPing          .word SFX_MapPing               ; $7611 - map enter ping
SndWalkSwitch       .word SFX_WalkSwitch            ; $761d - walk way switch
SndMummyOut         .word SFX_MummyOut              ; $7629 - mummy out
SndKeyPing          .word SFX_KeyPing               ; $7635 - key pick ping
; ------------------------------------------------------------------------------------------------------------- ;
NoSndGunShot        = (SndGunShot     - TabSoundsDataCpy) / 2  
NoSndTrapSwitch     = (SndTrapSwitch  - TabSoundsDataCpy) / 2
NoSndForcePing      = (SndForcePing   - TabSoundsDataCpy) / 2
NoSndOpenDoor       = (SndOpenDoor    - TabSoundsDataCpy) / 2
NoSndMaTrXmit       = (SndMaTrXmit    - TabSoundsDataCpy) / 2
NoSndMaTrSelect     = (SndMaTrSelect  - TabSoundsDataCpy) / 2
NoSndLiMacSwitch    = (SndLiMacSwitch - TabSoundsDataCpy) / 2
NoSndFrankOut       = (SndFrankOut    - TabSoundsDataCpy) / 2
NoSndDeath          = (SndDeath       - TabSoundsDataCpy) / 2
NoSndMapPing        = (SndMapPing     - TabSoundsDataCpy) / 2
NoSndWalkSwitch     = (SndWalkSwitch  - TabSoundsDataCpy) / 2
NoSndMummyOut       = (SndMummyOut    - TabSoundsDataCpy) / 2
NoSndKeyPing        = (SndKeyPing     - TabSoundsDataCpy) / 2
; ------------------------------------------------------------------------------------------------------------- ;
SFX_GunShot         = * - TabSoundsDataCpy + TabSoundsDataPtr
                    .byte $10
                    .byte $00
                    .byte $00
                    .byte $80
                    .byte $0a
                    .byte $0a
                    .byte $00
SFX_GunShotTone     = * - TabSoundsDataCpy + TabSoundsDataPtr
                    .byte $b1
                    .byte $08
                    .byte $02
                    .byte $04
                    .byte $24
; ------------------------------------------------------------------------------------------------------------- ;
SFX_TrapSwitch      = * - TabSoundsDataCpy + TabSoundsDataPtr
                    .byte $10
                    .byte $00
                    .byte $00
                    .byte $20
                    .byte $0a
                    .byte $0a
                    .byte $00
SFX_TrapSwTone      = * - TabSoundsDataCpy + TabSoundsDataPtr
                    .byte $89
                    .byte $08
                    .byte $02
                    .byte $04
                    .byte $24
; ------------------------------------------------------------------------------------------------------------- ;
SFX_ForcePing       = * - TabSoundsDataCpy + TabSoundsDataPtr
                    .byte $10
                    .byte $00
                    .byte $00
                    .byte $10
                    .byte $0a
                    .byte $0a
                    .byte $00
SFX_ForcePngTone    = * - TabSoundsDataCpy + TabSoundsDataPtr
                    .byte $85
                    .byte $08
                    .byte $02
                    .byte $04
                    .byte $24
; ------------------------------------------------------------------------------------------------------------- ;
SFX_OpenDoor        = * - TabSoundsDataCpy + TabSoundsDataPtr
                    .byte $12
                    .byte $80
                    .byte $00
                    .byte $40
                    .byte $0a
                    .byte $0a
                    .byte $02
SFX_OpenDoorTone    = * - TabSoundsDataCpy + TabSoundsDataPtr
                    .byte $a5
                    .byte $08
                    .byte $02
                    .byte $06
                    .byte $24
; ------------------------------------------------------------------------------------------------------------- ;
SFX_MatterXmit      = * - TabSoundsDataCpy + TabSoundsDataPtr
                    .byte $10
                    .byte $00
                    .byte $00
                    .byte $14
                    .byte $0c
                    .byte $0c
                    .byte $11
                    .byte $00
                    .byte $00
                    .byte $14
                    .byte $0c
                    .byte $0c
                    .byte $12
                    .byte $00
                    .byte $00
                    .byte $14
                    .byte $0c
                    .byte $0c
                    .byte $00
SFX_MatterXTone     = * - TabSoundsDataCpy + TabSoundsDataPtr
                    .byte $a0
                    .byte $08
                    .byte $02
                    .byte $04
                    .byte $24
; ------------------------------------------------------------------------------------------------------------- ;
SFX_MatterSelect    = * - TabSoundsDataCpy + TabSoundsDataPtr
                    .byte $11
                    .byte $80
                    .byte $01
                    .byte $40
                    .byte $80
                    .byte $00
                    .byte $01
SFX_MatterSTone     = * - TabSoundsDataCpy + TabSoundsDataPtr
                    .byte $b0
                    .byte $08
                    .byte $12
                    .byte $05
                    .byte $24
; ------------------------------------------------------------------------------------------------------------- ;
SFX_LightSwitch     = * - TabSoundsDataCpy + TabSoundsDataPtr
                    .byte $10
                    .byte $00
                    .byte $00
                    .byte $80
                    .byte $08
                    .byte $08
                    .byte $00
SFX_LightSwTone     = * - TabSoundsDataCpy + TabSoundsDataPtr
                    .byte $a0
                    .byte $08
                    .byte $02
                    .byte $04
                    .byte $24
; ------------------------------------------------------------------------------------------------------------- ;
SFX_FrankOut        = * - TabSoundsDataCpy + TabSoundsDataPtr
                    .byte $10
                    .byte $00
                    .byte $00
                    .byte $80
                    .byte $0c
                    .byte $0c
                    .byte $11
                    .byte $40
                    .byte $00
                    .byte $40
                    .byte $0c
                    .byte $0c
                    .byte $18
                    .byte $00
                    .byte $19
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $01
                    .byte $0c
                    .byte $08
                    .byte $02
                    .byte $04
                    .byte $05
                    .byte $24
; ------------------------------------------------------------------------------------------------------------- ;
SFX_Death           = * - TabSoundsDataCpy + TabSoundsDataPtr
                    .byte $10
                    .byte $00
                    .byte $00
                    .byte $10
                    .byte $06
                    .byte $06
                    .byte $00
SFX_DeathTone       = * - TabSoundsDataCpy + TabSoundsDataPtr                  
                    .byte $96
                    .byte $08
                    .byte $02
                    .byte $04
                    .byte $24
; ------------------------------------------------------------------------------------------------------------- ;
SFX_MapPing         = * - TabSoundsDataCpy + TabSoundsDataPtr
                    .byte $10
                    .byte $00
                    .byte $00
                    .byte $10
                    .byte $0b
                    .byte $0b
                    .byte $00
                    .byte $2b
                    .byte $08
                    .byte $02
                    .byte $04
                    .byte $24
; ------------------------------------------------------------------------------------------------------------- ;
SFX_WalkSwitch      = * - TabSoundsDataCpy + TabSoundsDataPtr
                    .byte $10
                    .byte $00
                    .byte $00
                    .byte $80
                    .byte $09
                    .byte $09
                    .byte $00
SFX_WalkSwTone      = * - TabSoundsDataCpy + TabSoundsDataPtr
                    .byte $a0
                    .byte $08
                    .byte $02
                    .byte $04
                    .byte $24
; ------------------------------------------------------------------------------------------------------------- ;
SFX_MummyOut        = * - TabSoundsDataCpy + TabSoundsDataPtr
                    .byte $10
                    .byte $00
                    .byte $00
                    .byte $80
                    .byte $09
                    .byte $09
                    .byte $00
SFX_MummyOutTone    = * - TabSoundsDataCpy + TabSoundsDataPtr                  
                    .byte $80
                    .byte $08
                    .byte $02
                    .byte $04
                    .byte $24
; ------------------------------------------------------------------------------------------------------------- ;
SFX_KeyPing         = * - TabSoundsDataCpy + TabSoundsDataPtr
                    .byte $10
                    .byte $00
                    .byte $00
                    .byte $10
                    .byte $09
                    .byte $09
                    .byte $00
                    .byte $3f
                    .byte $08
                    .byte $02
                    .byte $04
                    .byte $24
; ------------------------------------------------------------------------------------------------------------- ;
T_7641              .byte $00                       ; $00 for a complete coverage of SetLvlLoadScrn
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
                    .byte $00
; ------------------------------------------------------------------------------------------------------------- ;
