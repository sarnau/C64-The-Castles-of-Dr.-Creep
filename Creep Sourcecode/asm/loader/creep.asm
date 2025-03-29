; ------------------------------------------------------------------------------------------------------------- ;
; The Castles of Dr Creep - CREEP.PRG: Loader Code from $c000 to $c22e
; ------------------------------------------------------------------------------------------------------------- ;
                  * = $c000                       ; Start address
; ------------------------------------------------------------------------------------------------------------- ;
; compiler settings                                                                                             ;
; ------------------------------------------------------------------------------------------------------------- ;
C64CIA2           .include  inc\cia2.asm          ; Complex Interface Adapter (CIA) #2 Registers  $DD00-$DD0F
C64VicII          .include  inc\vic.asm           ; Video Interface Chip (VIC-II) Registers       $D000-$D02E
C64Kernel         .include  inc\kernel.asm        ; Kernel Vectors
C64Colors         .include  inc\color.asm         ; Colour RAM Address / Colours
;
Report            .opt      R=creep.txt           ; Report file
BinaryOut         .opt      O=creep.prg           ; Compiled binary output file
;
Switches          .opt      T                     ; Summary report
                  .opt      S                     ; Symbol table
;                  .opt      L                    ; Compiler listing
; ------------------------------------------------------------------------------------------------------------- ;
ScreenInfoText    = $0400                         ; game info text
ScreenColors      = $cc00                         ; target title picture screen color info
ScreenBitMap      = $e000                         ; target title picture bitmap info

PictureBitMap     = $0800                         ; title picture bitmap info
PictureColorScrn  = $2740                         ; title picture screen color info
PictureColorRam   = $2b28                         ; title picture color ram info
; ------------------------------------------------------------------------------------------------------------- ;
                  lda #<ScreenInfoText
                  sta $14
                  lda #>ScreenInfoText
                  sta $15
                  
                  lda #<COLORAM
                  sta $16
                  lda #>COLORAM
                  sta $17
                  
                  ldy #$00
ClearScrnColorI   lda #" "
ClearScrnColor    sta ($14),y
                  sta ($16),y
                  iny
                  bne ClearScrnColor
                  
                  inc $15
                  inc $17
                  lda $15
                  cmp #$08
                  bne ClearScrnColorI
                  
                  lda #<InfoTextRows
                  sta $14
                  lda #>InfoTextRows
                  sta $15
                  
SetNextTextRow    ldy #$00
                  lda ($14),y                     ; ($14/$15) points to header of TextRownn
                  bmi LoadTitlePic                ; ScrnColnn - all text rows processed
                  
                  ldy #$01
                  lda ($14),y                     ; ScrnRownn
                  asl a                           ; *2
                  tax
                  lda TabScreenRows,x
                  sta $16
                  lda TabScreenRows+1,x
                  sta $17                         ; ($16/$17) points to screen row start address now
                  
                  dey                             ; 00
                  clc
                  lda $16
                  adc ($14),y                     ; ScrnColnn                   
                  sta $16
                  lda $17
                  adc #$00
                  sta $17                         ; ($16/$17) points to screen row/col start address now
                  
                  clc
                  lda $14
                  adc #$02                        ; text header length
                  sta $14
                  lda $15
                  adc #$00
                  sta $15                         ; ($14/$15) points to TextRownn now
                  
                  ldy #$00
TextRowOut        lda ($14),y
                  bmi LastCharOut
    
                  sta ($16),y
                  iny
                  jmp TextRowOut
    
LastCharOut       and #$7f                        ; normalize
                  sta ($16),y
                  
                  iny                             ; length last text row
                  tya
                  clc
                  adc $14
                  sta $14
                  lda $15
                  adc #$00
                  sta $15                         ; ($14/$15) points to header of next TextRownn now
                  jmp SetNextTextRow
    
LoadTitlePic      lda #YELLOW
                  sta EXTCOL                      ; $D020 - Border Color
                  sta BGCOL0                      ; $D021 - Background Color
                  lda #$16                        ;   01=screen($0400-$07e7) 03=char($1800-$1fff)
                  sta VMCSB                       ; $D018 - VIC-II Chip Memory Control
    
                  lda #$02
                  ldx #$08
                  ldy #$00
                  jsr SETLFS                      ; $FFBA - set logical file parameters
    
                  lda #Blank-PicATitle            ; title picture
                  ldx #<PicATitle
                  ldy #>PicATitle
                  jsr SETNAM                      ; $FFBD - set filename parameters
    
                  lda #$00
                  ldx #$00
                  ldy #$08
                  jsr LOAD                        ; $FFD5 - load from device
    
                  lda #<PictureColorScrn
                  sta $14
                  lda #>PictureColorScrn
                  sta $15
    
                  lda #<ScreenColors
                  sta $16
                  lda #>ScreenColors
                  sta $17
    
                  ldy #$00
CopyTitleColorS   lda ($14),y
                  sta ($16),y
                  iny
                  bne CopyTitleColorS
    
                  inc $15
                  inc $17
                  lda $17
                  cmp #$d0
                  bne CopyTitleColorS
    
                  lda #<PictureBitMap
                  sta $14
                  lda #>PictureBitMap
                  sta $15
                  
                  lda #<ScreenBitMap
                  sta $16
                  lda #>ScreenBitMap
                  sta $17
                  
                  ldy #$00
CopyTitleBitMap   lda ($14),y
                  sta ($16),y
                  iny
                  bne CopyTitleBitMap
    
                  inc $15
                  inc $17
                  lda $17
                  cmp #$00
                  bne CopyTitleBitMap
    
                  lda #<PictureColorRam
                  sta $14
                  lda #>PictureColorRam
                  sta $15
                  
                  lda #<COLORAM
                  sta $16
                  lda #>COLORAM
                  sta $17
                  
                  ldy #$00
CopyTitleColorR   lda ($14),y
                  sta ($16),y
                  iny
                  bne CopyTitleColorR
    
                  inc $15
                  inc $17
                  lda $17
                  cmp #$dc
                  bne CopyTitleColorR
    
DisplayTitlePic   lda C2DDRA                      ; $DD02 - Data Direction Register A
                  ora #$03
                  sta C2DDRA
                  
                  lda CI2PRA                      ; $DD00 - Data Port Register A
                  and #$fc                        ;   Bits 0-1: 00=VIC-memory-bank-3 ($c000-$ffff)
                  sta CI2PRA
                  
                  lda #$3b                        ;   Bit 4: 01=screen enable    Bit 3: 01=25-rows
                  sta SCROLY                      ; $D011 - VIC Control Register 1
                  
                  lda #$18                        ;   Bit 4: 01=multicolor text  Bit 3: 01=40 columns
                  sta SCROLX                      ; $D016 - VIC Control Register 2
                  
                  lda #$38                        ;   Bits 4-7: 03=screen($0c00-$0fe7)  Bits 1-3: 04=char($2000-$27ff)
                  sta VMCSB                       ; $D018 - VIC-II Chip Memory Control
                  
                  lda #YELLOW
                  sta EXTCOL                      ; $D020 - Border Color
                  lda #WHITE
                  sta BGCOL0                      ; $D021 - Background Color
    
LoadMainPgm       lda #$02
                  ldx #$08
                  ldy #$00
                  jsr SETLFS                      ; $FFBA - set logical file parameters
    
                  lda #TabScreenRows-Object
                  ldx #<Object
                  ldy #>Object
                  jsr SETNAM                      ; $FFBD - set filename parameters
    
                  lda #$00
                  ldx #$00
                  ldy #$08
                  jsr LOAD                        ; $FFD5 - load from device
    
GoMainPgm         jmp $0800

                  .byte $81

PicATitle         .text "PIC A TITLE"
Blank             .text "   "
Object            .text "OBJECT"

TabScreenRows     .word $0400                     ; row 01
                  .word $0428                     ; row 02
                  .word $0450                     ; row 03
                  .word $0478                     ; row 04
                  .word $04a0                     ; row 05
                  .word $04c8                     ; row 06
                  .word $04f0                     ; row 07
                  .word $0518                     ; row 08
                  .word $0540                     ; row 09
                  .word $0568                     ; row 10
                  .word $0590                     ; row 11
                  .word $05b8                     ; row 12
                  .word $05e0                     ; row 13
                  .word $0608                     ; row 14
                  .word $0630                     ; row 15
                  .word $0658                     ; row 16
                  .word $0680                     ; row 17
                  .word $06a8                     ; row 18
                  .word $06d0                     ; row 19
                  .word $06f8                     ; row 20
                  .word $0720                     ; row 21
                  .word $0748                     ; row 22
                  .word $0770                     ; row 23
                  .word $0798                     ; row 24
                  .word $07c0                     ; row 25

InfoTextRows       = *

ScrnCol01         .byte $06 
ScrnRow01         .byte $01
TextRow01         .text "BR0DERBUND SOFTWARE PRESENT"
EoTxRow01         .byte $d3                       ; S

ScrnCol02         .byte $06 
ScrRow02          .byte $0a
TextRow02         .byte $22                       ; "
                  .text "THE CASTLES OF DOCTOR CREEP"
EoTxRow02         .byte $a2                       ; "

ScrnCol03         .byte $0f
ScrnRow03         .byte $0d 
TextRow03         .text "BY ED HOBB"
EoTxRow03         .byte $d3      ; S                        

ScrnCol04         .byte $02
ScrnRow04         .byte $17
TextRow04         .text "PLEASE ALLOW TWO MINUTES FOR LOADIN"
EoTxRow04         .byte $c7                               ; G

ScrnCol05         .byte $05 
ScrnRow05         .byte $0f
TextRow05         .text "BROKEN BY BLADE RUNNER 7/84"
EoTxRow05         .byte $a0
 
EoInfoTextRows    .byte $80

                  .byte $00
                  .byte $00
                  .byte $00
