; -------------------------------------------------------------------------------------------------------------- ;
; The Castles of Dr Creep - CREEP.PRG: Loader Code from $c000 to $c22e
; -------------------------------------------------------------------------------------------------------------- ;
                    * equ $c000
; -------------------------------------------------------------------------------------------------------------- ;
; compiler settings
; -------------------------------------------------------------------------------------------------------------- ;
                    incdir  ..\inc                  ; C64 System Includes

C64CIA1             include cia1.asm                ; Complex Interface Adapter (CIA) #1 Registers  $DC00-$DC0F
C64CIA2             include cia2.asm                ; Complex Interface Adapter (CIA) #2 Registers  $DD00-$DD0F
C64SID              include sid.asm                 ; Sound Interface Device (SID) Registers        $D400-$D41C
C64VicII            include vic.asm                 ; Video Interface Chip (VIC-II) Registers       $D000-$D02E
C64Kernel           include kernel.asm              ; Kernel Vectors
C64Colors           include color.asm               ; Colour RAM Address / Colours
C64Memory           include mem.asm                 ; Memory Layout
; ------------------------------------------------------------------------------------------------------------- ;
PtrTxtScreen        = $14                           ; 
PtrTxtScreenLo      = $14                           ; 
PtrTxtScreenHi      = $15                           ; 

PtrColorRam         = $16                           ; 
PtrColorRamLo       = $16                           ; 
PtrColorRamHi       = $17                           ; 

PtrFrom             = $14                           ; 
PtrFromLo           = $14                           ; 
PtrFromHi           = $15                           ; 

PtrTo               = $16                           ; 
PtrToLo             = $16                           ; 
PtrToHi             = $17                           ; 
; ------------------------------------------------------------------------------------------------------------- ;
PicStart            = $0800                         ; start address load picture
MainStart           = $0800                         ; start address game code

ScreenText          = $0400                         ; game info text
ScreenMC            = $cc00                         ; target title picture screen color info
ScreenBitMap        = $e000                         ; target title picture bitmap info

PicBitMap           = PicStart                      ; $0000 - $1f3f - koala picture bitmap
PicColorsMC         = PicStart      + $1f40         ; $1f40 - $2327 - koala picture color video ram
PicColorsRam        = PicColorsMC   + $03e8         ; $2328 - $270f - koala picture color ram 
PicColorsBkgr       = PicColorsRam  + $03e8         ; $2710         - koala picture color background
; -------------------------------------------------------------------------------------------------------------- ;
InfoText            lda #<ScreenText                ; 
                    sta PtrTxtScreenLo              ; 
                    lda #>ScreenText                ; 
                    sta PtrTxtScreenHi              ; 
                    
                    lda #<COLORAM                   ; 
                    sta PtrColorRamLo               ; 
                    lda #>COLORAM                   ; 
                    sta PtrColorRamHi               ; 
                    
                    ldy #$00                        ; 
ClearTxtScrnI       lda #$20                        ; 
ClearTxtScrn        sta (PtrTxtScreen),y            ; 
ClearTxtColor       sta (PtrColorRam),y             ; 
                    iny                             ; 
                    bne ClearTxtScrn                ; 
                    
                    inc PtrTxtScreenHi              ; 
                    inc PtrColorRamHi               ; 
                    lda PtrTxtScreenHi              ; 
                    cmp #<(>ScreenText + $04)       ; $04 pages
                    bne ClearTxtScrnI               ; 
                    
                    lda #<InfoTextRows              ; 
                    sta PtrFromLo                   ; 
                    lda #>InfoTextRows              ; 
                    sta PtrFromHi                   ; 
                    
SetNextTextRow      ldy #$00                        ; 
                    lda (PtrFrom),y                 ; ($14/$15) points to header of TextRownn
                    bmi LoadPic                     ; ScrnColnn - all text rows processed
                    
                    ldy #$01                        ; 
                    lda (PtrFrom),y                 ; ScrnRownn
                    asl a                           ; *2
                    tax                             ; 
                    lda TabScreenRows,x             ; 
                    sta PtrToLo                     ; 
                    lda TabScreenRows+1,x           ; 
                    sta PtrToHi                     ; ($16/$17) points to screen row start address now
                    
                    dey                             ; $00
                    clc                             ; 
                    lda PtrToLo                     ; 
                    adc (PtrFrom),y                 ; ScrnColnn
                    sta PtrToLo                     ; 
                    lda PtrToHi                     ; 
                    adc #$00                        ; 
                    sta PtrToHi                     ; ($16/$17) points to screen row/col start address now
                    
                    clc                             ; 
                    lda PtrFromLo                   ; 
                    adc #$02                        ; text header length
                    sta PtrFromLo                   ; 
                    lda PtrFromHi                   ; 
                    adc #$00                        ; 
                    sta PtrFromHi                   ; ($14/$15) points to TextRownn now
                    
                    ldy #$00                        ; 
TextRowOut          lda (PtrFrom),y                 ; 
                    bmi LastCharOut                 ; 
                    
                    sta (PtrTo),y                   ; 
                    iny                             ; 
                    jmp TextRowOut                  ; 
                    
LastCharOut         and #$7f                        ; .####### - normalize
                    sta (PtrTo),y                   ; 
                    
                    iny                             ; length last text row
                    tya                             ; 
                    clc                             ; 
                    adc PtrFromLo                   ; 
                    sta PtrFromLo                   ; 
                    lda PtrFromHi                   ; 
                    adc #$00                        ; 
                    sta PtrFromHi                   ; ($14/$15) points to header of next TextRownn now
                    jmp SetNextTextRow              ; 
; -------------------------------------------------------------------------------------------------------------- ;
LoadPic             lda #YELLOW                     ; 
                    sta EXTCOL                      ; VIC($D020) Border Color
                    sta BGCOL0                      ; VIC($D021) Background Color 0
                    lda #$16                        ; ...#.##. - 01=screen($0400-$07e7) 03=char($1800-$1fff)
                    sta VMCSB                       ; VIC($D018) VIC Chip Memory Control
                    
                    lda #$02                        ; 
                    ldx #$08                        ; 
                    ldy #$00                        ; 
                    jsr SETLFS                      ; Kernel($FFBA) Set logical file parameters ($FE00)
                    
                    lda #Blank - PicATitle          ; length file name
                    ldx #<PicATitle                 ; 
                    ldy #>PicATitle                 ; 
                    jsr SETNAM                      ; Kernel($FFBD) Set filename parameters ($FDF9)
                    
                    lda #$00                        ; flag: load
                    ldx #<PicStart                  ; 
                    ldy #>PicStart                  ; 
                    jsr LOAD                        ; Kernel($FFD5) Load from device (via $330 to $F49E)
                    
                    lda #<PicColorsMC               ; 
                    sta PtrFromLo                   ; 
                    lda #>PicColorsMC               ; 
                    sta PtrFromHi                   ; 
                    
                    lda #<ScreenMC                  ; 
                    sta PtrToLo                     ; 
                    lda #>ScreenMC                  ; 
                    sta PtrToHi                     ; 
                    
                    ldy #$00                        ; 
CopyPicColorsMC     lda (PtrFrom),y                 ; 
                    sta (PtrTo),y                   ; 
                    iny                             ; 
                    bne CopyPicColorsMC             ; 
                    
                    inc PtrFromHi                   ; 
                    inc PtrToHi                     ; 
                    lda PtrToHi                     ; 
                    cmp #<(>ScreenMC + $04)         ; $04 pages
                    bne CopyPicColorsMC             ; 
                    
                    lda #<PicBitMap                 ; 
                    sta PtrFromLo                   ; 
                    lda #>PicBitMap                 ; 
                    sta PtrFromHi                   ; 
                    
                    lda #<ScreenBitMap              ; 
                    sta PtrToLo                     ; 
                    lda #>ScreenBitMap              ; 
                    sta PtrToHi                     ; 
                    
                    ldy #$00                        ; 
CopyPicBitMap       lda (PtrFrom),y                 ; 
                    sta (PtrTo),y                   ; 
                    iny                             ; 
                    bne CopyPicBitMap               ; 
                    
                    inc PtrFromHi                   ; 
                    inc PtrToHi                     ; 
                    lda PtrToHi                     ; 
                    cmp #<(>ScreenBitMap + $20)     ; $20 pages
                    bne CopyPicBitMap               ; 
                    
                    lda #<PicColorsRam              ; 
                    sta PtrFromLo                   ; 
                    lda #>PicColorsRam              ; 
                    sta PtrFromHi                   ; 
                    
                    lda #<COLORAM                   ; 
                    sta PtrToLo                     ; 
                    lda #>COLORAM                   ; 
                    sta PtrToHi                     ; 
                    
                    ldy #$00                        ; 
CopyPicColorsRam    lda (PtrFrom),y                 ; 
                    sta (PtrTo),y                   ; 
                    iny                             ; 
                    bne CopyPicColorsRam            ; 
                    inc PtrFromHi                   ; 
                    inc PtrToHi                     ; 
                    lda PtrToHi                     ; 
                    cmp #$dc                        ; 
                    bne CopyPicColorsRam            ; 
                    
ShowPic             lda C2DDRA                      ; CIA2($DD02) Data Dir A
                    ora #$03                        ; ......## - 1=output
                    sta C2DDRA                      ; CIA2($DD02) Data Dir A
                    
                    lda CI2PRA                      ; CIA2($DD00) Data Port A - Bits 0-1 = VIC mem bank
                    and #VIC_MemBank_3              ; ######.. - $c000-$ffff
                    sta CI2PRA                      ; CIA2($DD00) Data Port A - Bits 0-1 = VIC mem bank
                    
                    lda #$3b                        ; ..###.## - 25rows / screen enab / bitmap mode
                    sta SCROLY                      ; VIC($D011) VIC Control Register 1 (and Vertical Fine Scrolling)
                    
                    lda #$18                        ; ...##... - 40 cols / multi color mode
                    sta SCROLX                      ; VIC($D016) VIC Control Register 2 (and Horizontal Fine Scrolling)
                    
                    lda #$38                        ; ..## #.. . - color $0c00-$0fe7  screen $2000-$3fff
                    sta VMCSB                       ; VIC($D018) VIC Chip Memory Control
                    
                    lda #YELLOW                     ; 
                    sta EXTCOL                      ; VIC($D020) Border Color
                    lda #WHITE                      ; 
                    sta BGCOL0                      ; VIC($D021) Background Color 0
                    
                    lda #$02                        ; 
                    ldx #$08                        ; 
                    ldy #$00                        ; 
                    jsr SETLFS                      ; Kernel($FFBA) Set logical file parameters ($FE00)
                    
                    lda #TabScreenRows - Object     ; length file name
                    ldx #<Object                    ; 
                    ldy #>Object                    ; 
                    jsr SETNAM                      ; Kernel($FFBD) Set filename parameters ($FDF9)
                    
                    lda #$00                        ; flag: load
                    ldx #<MainStart                 ; 
                    ldy #>MainStart                 ; 
                    jsr LOAD                        ; Kernel($FFD5) Load from device (via $330 to $F49E)
                    
StartGame           jmp MainStart                   ; 
; -------------------------------------------------------------------------------------------------------------- ;
                    dc.b $81 ; 
; -------------------------------------------------------------------------------------------------------------- ;
PicATitle           dc.b $50 ; p
                    dc.b $49 ; i
                    dc.b $43 ; c
                    dc.b $20 ; _
                    dc.b $41 ; a
                    dc.b $20 ; _
                    dc.b $54 ; t
                    dc.b $49 ; i
                    dc.b $54 ; t
                    dc.b $4c ; l
                    dc.b $45 ; e
                    
Blank               dc.b $20 ; _
                    dc.b $20 ; _
                    dc.b $20 ; _
                    
Object              dc.b $4f ; o
                    dc.b $42 ; b
                    dc.b $4a ; j
                    dc.b $45 ; e
                    dc.b $43 ; c
                    dc.b $54 ; t
; -------------------------------------------------------------------------------------------------------------- ;
TabScreenRows       dc.w $0400                     ; row 01
                    dc.w $0428                     ; row 02
                    dc.w $0450                     ; row 03
                    dc.w $0478                     ; row 04
                    dc.w $04a0                     ; row 05
                    dc.w $04c8                     ; row 06
                    dc.w $04f0                     ; row 07
                    dc.w $0518                     ; row 08
                    dc.w $0540                     ; row 09
                    dc.w $0568                     ; row 10
                    dc.w $0590                     ; row 11
                    dc.w $05b8                     ; row 12
                    dc.w $05e0                     ; row 13
                    dc.w $0608                     ; row 14
                    dc.w $0630                     ; row 15
                    dc.w $0658                     ; row 16
                    dc.w $0680                     ; row 17
                    dc.w $06a8                     ; row 18
                    dc.w $06d0                     ; row 19
                    dc.w $06f8                     ; row 20
                    dc.w $0720                     ; row 21
                    dc.w $0748                     ; row 22
                    dc.w $0770                     ; row 23
                    dc.w $0798                     ; row 24
                    dc.w $07c0                     ; row 25
; -------------------------------------------------------------------------------------------------------------- ;
InfoTextRows        equ  *
; -------------------------------------------------------------------------------------------------------------- ;
ScrnCol01           dc.b $06 ; 
ScrnRow01           dc.b $01 ; 
TextRow01           dc.b $42 ; b
                    dc.b $52 ; r
                    dc.b $30 ; 0
                    dc.b $44 ; d
                    dc.b $45 ; e
                    dc.b $52 ; r
                    dc.b $42 ; b
                    dc.b $55 ; u
                    dc.b $4e ; n
                    dc.b $44 ; d
                    dc.b $20 ; _
                    dc.b $53 ; s
                    dc.b $4f ; o
                    dc.b $46 ; f
                    dc.b $54 ; t
                    dc.b $57 ; w
                    dc.b $41 ; a
                    dc.b $52 ; r
                    dc.b $45 ; e
                    dc.b $20 ; _
                    dc.b $50 ; p
                    dc.b $52 ; r
                    dc.b $45 ; e
                    dc.b $53 ; s
                    dc.b $45 ; e
                    dc.b $4e ; n
                    dc.b $54 ; t
EoTxRow01           dc.b $d3 ; S
; -------------------------------------------------------------------------------------------------------------- ;
ScrnCol02           dc.b $06 ; 
ScrnRow02           dc.b $0a ; 
TextRow02           dc.b $22 ; "
                    dc.b $54 ; t
                    dc.b $48 ; h
                    dc.b $45 ; e
                    dc.b $20 ; _
                    dc.b $43 ; c
                    dc.b $41 ; a
                    dc.b $53 ; s
                    dc.b $54 ; t
                    dc.b $4c ; l
                    dc.b $45 ; e
                    dc.b $53 ; s
                    dc.b $20 ; _
                    dc.b $4f ; o
                    dc.b $46 ; f
                    dc.b $20 ; _
                    dc.b $44 ; d
                    dc.b $4f ; o
                    dc.b $43 ; c
                    dc.b $54 ; t
                    dc.b $4f ; o
                    dc.b $52 ; r
                    dc.b $20 ; _
                    dc.b $43 ; c
                    dc.b $52 ; r
                    dc.b $45 ; e
                    dc.b $45 ; e
                    dc.b $50 ; p
EoTxRow02           dc.b $a2 ; <shift> "
; -------------------------------------------------------------------------------------------------------------- ;
ScrnCol03           dc.b $0f ; 
ScrnRow03           dc.b $0d ; <enter>
TextRow03           dc.b $42 ; b
                    dc.b $59 ; y
                    dc.b $20 ; _
                    dc.b $45 ; e
                    dc.b $44 ; d
                    dc.b $20 ; _
                    dc.b $48 ; h
                    dc.b $4f ; o
                    dc.b $42 ; b
                    dc.b $42 ; b
EoTxRow03           dc.b $d3 ; S
; -------------------------------------------------------------------------------------------------------------- ;
ScrnCol04           dc.b $02 ; 
ScrnRow04           dc.b $17 ; 
TextRow04           dc.b $50 ; p
                    dc.b $4c ; l
                    dc.b $45 ; e
                    dc.b $41 ; a
                    dc.b $53 ; s
                    dc.b $45 ; e
                    dc.b $20 ; _
                    dc.b $41 ; a
                    dc.b $4c ; l
                    dc.b $4c ; l
                    dc.b $4f ; o
                    dc.b $57 ; w
                    dc.b $20 ; _
                    dc.b $54 ; t
                    dc.b $57 ; w
                    dc.b $4f ; o
                    dc.b $20 ; _
                    dc.b $4d ; m
                    dc.b $49 ; i
                    dc.b $4e ; n
                    dc.b $55 ; u
                    dc.b $54 ; t
                    dc.b $45 ; e
                    dc.b $53 ; s
                    dc.b $20 ; _
                    dc.b $46 ; f
                    dc.b $4f ; o
                    dc.b $52 ; r
                    dc.b $20 ; _
                    dc.b $4c ; l
                    dc.b $4f ; o
                    dc.b $41 ; a
                    dc.b $44 ; d
                    dc.b $49 ; i
                    dc.b $4e ; n
EoTxRow04           dc.b $c7 ; G
; -------------------------------------------------------------------------------------------------------------- ;
ScrnCol05           dc.b $05 ; 
ScrnRow05           dc.b $0f ; 
TextRow05           dc.b $42 ; b
                    dc.b $52 ; r
                    dc.b $4f ; o
                    dc.b $4b ; k
                    dc.b $45 ; e
                    dc.b $4e ; n
                    dc.b $20 ; _
                    dc.b $42 ; b
                    dc.b $59 ; y
                    dc.b $20 ; _
                    dc.b $42 ; b
                    dc.b $4c ; l
                    dc.b $41 ; a
                    dc.b $44 ; d
                    dc.b $45 ; e
                    dc.b $20 ; _
                    dc.b $52 ; r
                    dc.b $55 ; u
                    dc.b $4e ; n
                    dc.b $4e ; n
                    dc.b $45 ; e
                    dc.b $52 ; r
                    dc.b $20 ; _
                    dc.b $37 ; 7
                    dc.b $2f ; /
                    dc.b $38 ; 8
                    dc.b $34 ; 4
EoTxRow05           dc.b $a0 ; <_ (shift)>
; -------------------------------------------------------------------------------------------------------------- ;
EoInfoTextRows      dc.b $80 ; 
; -------------------------------------------------------------------------------------------------------------- ;
                    dc.b $00 ; 
                    dc.b $00 ; 
                    dc.b $00 ; 
; -------------------------------------------------------------------------------------------------------------- ;
