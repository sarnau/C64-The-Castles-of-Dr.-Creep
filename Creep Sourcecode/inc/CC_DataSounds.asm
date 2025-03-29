; ------------------------------------------------------------------------------------------------------------- ;
; Castles of Dr Creep - Sounds
; ------------------------------------------------------------------------------------------------------------- ;
TabSoundsDataPtr    = *                             ; used with: InitSoundFX
;                   
SndGunShot          dc.w SFX_GunShot                ; ray gun shot
SndTrapSwitch       dc.w SFX_TrapSwitch             ; trap door switch
SndForcePing        dc.w SFX_ForcePing              ; close force field pings
SndOpenDoor         dc.w SFX_OpenDoor               ; open doors
SndMaTrXmit         dc.w SFX_MatterXmit             ; matter transmitter: transmit
SndMaTrSelect       dc.w SFX_MatterSelect           ; matter transmitter: select receiver oval
SndLiMacSwitch      dc.w SFX_LightSwitch            ; lightning machine switch
SndFrankOut         dc.w SFX_FrankOut               ; frankenstein out
SndDeath            dc.w SFX_Death                  ; player/mummy/frank death
SndMapPing          dc.w SFX_MapPing                ; map enter ping
SndWalkSwitch       dc.w SFX_WalkSwitch             ; walk way switch
SndMummyOut         dc.w SFX_MummyOut               ; mummy out
SndKeyPing          dc.w SFX_KeyPick                ; key pick ping
; ------------------------------------------------------------------------------------------------------------- ;
NoSndGunShot        equ (SndGunShot     - TabSoundsDataPtr) / 2  
NoSndTrapSwitch     equ (SndTrapSwitch  - TabSoundsDataPtr) / 2
NoSndForcePing      equ (SndForcePing   - TabSoundsDataPtr) / 2
NoSndOpenDoor       equ (SndOpenDoor    - TabSoundsDataPtr) / 2
NoSndMaTrXmit       equ (SndMaTrXmit    - TabSoundsDataPtr) / 2
NoSndMaTrSelect     equ (SndMaTrSelect  - TabSoundsDataPtr) / 2
NoSndLiMacSwitch    equ (SndLiMacSwitch - TabSoundsDataPtr) / 2
NoSndFrankOut       equ (SndFrankOut    - TabSoundsDataPtr) / 2
NoSndDeath          equ (SndDeath       - TabSoundsDataPtr) / 2
NoSndMapPing        equ (SndMapPing     - TabSoundsDataPtr) / 2
NoSndWalkSwitch     equ (SndWalkSwitch  - TabSoundsDataPtr) / 2
NoSndMummyOut       equ (SndMummyOut    - TabSoundsDataPtr) / 2
NoSndKeyPing        equ (SndKeyPing     - TabSoundsDataPtr) / 2
; ------------------------------------------------------------------------------------------------------------- ;
SFX_GunShot         dc.b $10
                    dc.b $00
                    dc.b $00
                    dc.b $80
                    dc.b $0a
                    dc.b $0a
                    dc.b $00
SFX_GunShotTone     dc.b $b1
SFX_GunShotHeight     = $2c
                    dc.b $08
                    dc.b $02
                    dc.b $04
                    dc.b $24
; ------------------------------------------------------------------------------------------------------------- ;
SFX_TrapSwitch      dc.b $10
                    dc.b $00
                    dc.b $00
                    dc.b $20
                    dc.b $0a
                    dc.b $0a
                    dc.b $00
SFX_TrapSwitchTone  dc.b $89
SFX_TrapSwitchHeight  = $2b
                    dc.b $08
                    dc.b $02
                    dc.b $04
                    dc.b $24
; ------------------------------------------------------------------------------------------------------------- ;
SFX_ForcePing       dc.b $10
                    dc.b $00
                    dc.b $00
                    dc.b $10
                    dc.b $0a
                    dc.b $0a
                    dc.b $00
SFX_ForcePingHeight dc.b $85
SFX_ForcePingSwitch   = $0c
                    dc.b $08
                    dc.b $02
                    dc.b $04
                    dc.b $24
; ------------------------------------------------------------------------------------------------------------- ;
SFX_OpenDoor        dc.b $12
                    dc.b $80
                    dc.b $00
                    dc.b $40
                    dc.b $0a
                    dc.b $0a
                    dc.b $02
SFX_OpenDoorTone    dc.b $a5
SFX_OpenDoorHeight    = $10
                    dc.b $08
                    dc.b $02
                    dc.b $06
                    dc.b $24
; ------------------------------------------------------------------------------------------------------------- ;
SFX_MatterXmit      dc.b $10
                    dc.b $00
                    dc.b $00
                    dc.b $14
                    dc.b $0c
                    dc.b $0c
                    dc.b $11
                    dc.b $00
                    dc.b $00
                    dc.b $14
                    dc.b $0c
                    dc.b $0c
                    dc.b $12
                    dc.b $00
                    dc.b $00
                    dc.b $14
                    dc.b $0c
                    dc.b $0c
                    dc.b $00
SFX_MatterXmitTone  dc.b $a0
SFX_MatterXmitMask    = $3f
                    dc.b $08
                    dc.b $02
                    dc.b $04
                    dc.b $24
; ------------------------------------------------------------------------------------------------------------- ;
SFX_MatterSelect    dc.b $11
                    dc.b $80
                    dc.b $01
                    dc.b $40
                    dc.b $80
                    dc.b $00
                    dc.b $01
SFX_MatterSelTone   dc.b $b0
SFX_MatterSelHeight   = $32
                    dc.b $08
                    dc.b $12
                    dc.b $05
                    dc.b $24
; ------------------------------------------------------------------------------------------------------------- ;
SFX_LightSwitch     dc.b $10
                    dc.b $00
                    dc.b $00
                    dc.b $80
                    dc.b $08
                    dc.b $08
                    dc.b $00
SFX_LightSwitchTone dc.b $a0
SFX_LightSwitchOn     = $23
SFX_LightSwitchOff    = $2f
                    dc.b $08
                    dc.b $02
                    dc.b $04
                    dc.b $24
; ------------------------------------------------------------------------------------------------------------- ;
SFX_FrankOut        dc.b $10
                    dc.b $00
                    dc.b $00
                    dc.b $80
                    dc.b $0c
                    dc.b $0c
                    dc.b $11
                    dc.b $40
                    dc.b $00
                    dc.b $40
                    dc.b $0c
                    dc.b $0c
                    dc.b $18
                    dc.b $00
                    dc.b $19
                    dc.b $00
                    dc.b $00
                    dc.b $00
                    dc.b $01
                    dc.b $0c
                    dc.b $08
                    dc.b $02
                    dc.b $04
                    dc.b $05
                    dc.b $24
; ------------------------------------------------------------------------------------------------------------- ;
SFX_Death           dc.b $10
                    dc.b $00
                    dc.b $00
                    dc.b $10
                    dc.b $06
                    dc.b $06
                    dc.b $00
SFX_DeathTone       dc.b $96
                    dc.b $08
                    dc.b $02
                    dc.b $04
                    dc.b $24
; ------------------------------------------------------------------------------------------------------------- ;
SFX_MapPing         dc.b $10
                    dc.b $00
                    dc.b $00
                    dc.b $10
                    dc.b $0b
                    dc.b $0b
                    dc.b $00
SFX_MapPingTone     dc.b $2b
SFX_MapPingHeight     = $28
                    dc.b $08
                    dc.b $02
                    dc.b $04
                    dc.b $24
; ------------------------------------------------------------------------------------------------------------- ;
SFX_WalkSwitch      dc.b $10
                    dc.b $00
                    dc.b $00
                    dc.b $80
                    dc.b $09
                    dc.b $09
                    dc.b $00
SFX_WalkSwitchTone  dc.b $a0
SFX_WalkSwitchOff     = $1e
SFX_WalkSwitchLeft    = $18
SFX_WalkSwitchRight   = $24
                    dc.b $08
                    dc.b $02
                    dc.b $04
                    dc.b $24
; ------------------------------------------------------------------------------------------------------------- ;
SFX_MummyOut        dc.b $10
                    dc.b $00
                    dc.b $00
                    dc.b $80
                    dc.b $09
                    dc.b $09
                    dc.b $00
SFX_MummyOutTone    dc.b $80
SFX_MummyOutHeight    = $24
                    dc.b $08
                    dc.b $02
                    dc.b $04
                    dc.b $24
; ------------------------------------------------------------------------------------------------------------- ;
SFX_KeyPick         dc.b $10
                    dc.b $00
                    dc.b $00
                    dc.b $10
                    dc.b $09
                    dc.b $09
                    dc.b $00
SFX_KeyPickTone     dc.b $3f ;
SFX_KeyPickHeight     = $38
                    dc.b $08
                    dc.b $02
                    dc.b $04
                    dc.b $24
; ------------------------------------------------------------------------------------------------------------- ;
TabTune2Play        = *
TabTune2PlayBlock   = * - 1                         ; referenced with yr start offset of $02 in  .CopyWrkTune
TabTune2PlayCtrl    dc.b $99                        ; 
TabTune2PlayCutLo   dc.b $a0                        ; 
TabTune2PlayCutHi   dc.b $c1                        ; 
TabTune2PlayRes     dc.b $c6                        ; 
TabTune2PlayVol     dc.b $ce                        ; 
                    dc.b $a2                        ; 
                    dc.b $aa                        ; 
                    
TabTune2PlayCopyLen dc.b $02 ; $00 - 
                    dc.b $01 ; $01 - 
                    dc.b $02 ; $02 - 
                    dc.b $02 ; $03 - 
                    dc.b $06 ; $04 - 
                    dc.b $05 ; $05 - 
                    dc.b $02 ; $06 - 
                    dc.b $02 ; $07 - 
                    dc.b $02 ; $08 - 
                    dc.b $01 ; $09 - demo music load failed
                    
TabTune2PlayVocAdr  dc.w FRELO1                     ; $D400 - Oscillator 1 Frequency Control (low byte)
                    dc.w FRELO2                     ; $D407 - Oscillator 2 Frequency Control (low byte)
                    dc.w FRELO3                     ; $D40E - Oscillator 3 Frequency Control (low byte)
; ------------------------------------------------------------------------------------------------------------- ;
TabSidVoicesData    dc.w TabSidVoice1               ; address voice 01 register values
                    dc.w TabSidVoice2               ; address voice 02 register values
                    dc.w TabSidVoice3               ; address voice 03 register values
; ------------------------------------------------------------------------------------------------------------- ;
TabSidVoices        equ  *
TabSidVoice1        dc.b $a0 ; $00                  ; Oscillator 1 register values
                    dc.b $a9 ; $01
                    dc.b $b5 ; $02
                    dc.b $a0 ; $03
TabSidVoice1Control dc.b $e5 ; $04                  ; Oscillator 1 control register
                    dc.b $a0 ; $05
                    dc.b $86 ; $06
                    
TabSidVoice2        dc.b $a0 ; $07                  ; Oscillator 2 register values
                    dc.b $80 ; $08
                    dc.b $ba ; $09
                    dc.b $ce ; $0a
TabSidVoice2Control dc.b $8d ; $0b                  ; Oscillator 2 control register
                    dc.b $a0 ; $0c
                    dc.b $82 ; $0d
                    
TabSidVoice3        dc.b $a0 ; $0e                  ; Oscillator 3 register values
                    dc.b $b8 ; $0f
                    dc.b $bc ; $10
                    dc.b $a0 ; $11
TabSidVoice3Control dc.b $b0 ; $12                  ; Oscillator 3 control register
                    dc.b $a0 ; $13
                    dc.b $cc ; $14

TabSidCutLo         dc.b $a0 ; $15
TabSidCutHi         dc.b $b0 ; $16
TabSidRes           dc.b $84 ; $17
                    
TabSidVolume        dc.b $0f ; $18                  ; all $18 TabSidVoices bytes copied in WarmStart if in demo mode
; ------------------------------------------------------------------------------------------------------------- ;
TabTune2Play01      dc.b $0c
                    dc.b $1c
                    dc.b $2d
                    dc.b $3e
                    dc.b $51
                    dc.b $66
                    dc.b $7b
                    dc.b $91
                    dc.b $a9
                    dc.b $c3
                    dc.b $dd
                    dc.b $fa
                    dc.b $18
                    dc.b $38
                    dc.b $5a
                    dc.b $7d
                    dc.b $a3
                    dc.b $cc
                    dc.b $f6
                    dc.b $23
                    dc.b $53
                    dc.b $86
                    dc.b $bb
                    dc.b $f4
                    dc.b $30
                    dc.b $70
                    dc.b $b4
                    dc.b $fb
                    dc.b $47
                    dc.b $98
                    dc.b $ed
                    dc.b $47
                    dc.b $a7
                    dc.b $0c
                    dc.b $77
                    dc.b $e9
                    dc.b $61
                    dc.b $e1
                    dc.b $68
                    dc.b $f7
                    dc.b $8f
                    dc.b $30
                    dc.b $da
                    dc.b $8f
                    dc.b $4e
                    dc.b $18
                    dc.b $ef
                    dc.b $d2
                    dc.b $c3
                    dc.b $c3
                    dc.b $d1
                    dc.b $ef
                    dc.b $1f
                    dc.b $60
                    dc.b $b5
                    dc.b $1e
                    dc.b $9c
                    dc.b $31
                    dc.b $df
                    dc.b $a5
                    dc.b $87
                    dc.b $86
                    dc.b $a2
                    dc.b $df
                    dc.b $3e
                    dc.b $c1
                    dc.b $6b
                    dc.b $3c
                    dc.b $39
                    dc.b $63
                    dc.b $be
                    dc.b $4b
                    dc.b $0f
                    dc.b $0c
                    dc.b $45
                    dc.b $bf
                    dc.b $7d
                    dc.b $83
                    dc.b $d6
                    dc.b $79
                    dc.b $73
                    dc.b $c7
                    dc.b $7c
                    dc.b $97
                    dc.b $1e
                    dc.b $18
                    dc.b $8b
                    dc.b $7e
                    dc.b $fa
                    dc.b $06
                    dc.b $ac
                    dc.b $f3
                    dc.b $e6
                    dc.b $8f
                    dc.b $f8
                    dc.b $2e
                    
TabTune2Play02      dc.b $01
                    dc.b $01
                    dc.b $01
                    dc.b $01
                    dc.b $01
                    dc.b $01
                    dc.b $01
                    dc.b $01
                    dc.b $01
                    dc.b $01
                    dc.b $01
                    dc.b $01
                    dc.b $02
                    dc.b $02
                    dc.b $02
                    dc.b $02
                    dc.b $02
                    dc.b $02
                    dc.b $02
                    dc.b $03
                    dc.b $03
                    dc.b $03
                    dc.b $03
                    dc.b $03
                    dc.b $04
                    dc.b $04
                    dc.b $04
                    dc.b $04
                    dc.b $05
                    dc.b $05
                    dc.b $05
                    dc.b $06
                    dc.b $06
                    dc.b $07
                    dc.b $07
                    dc.b $07
                    dc.b $08
                    dc.b $08
                    dc.b $09
                    dc.b $09
                    dc.b $0a
                    dc.b $0b
                    dc.b $0b
                    dc.b $0c
                    dc.b $0d
                    dc.b $0e
                    dc.b $0e
                    dc.b $0f
                    dc.b $10
                    dc.b $11
                    dc.b $12
                    dc.b $13
                    dc.b $15
                    dc.b $16
                    dc.b $17
                    dc.b $19
                    dc.b $1a
                    dc.b $1c
                    dc.b $1d
                    dc.b $1f
                    dc.b $21
                    dc.b $23
                    dc.b $25
                    dc.b $27
                    dc.b $2a
                    dc.b $2c
                    dc.b $2f
                    dc.b $32
                    dc.b $35
                    dc.b $38
                    dc.b $3b
                    dc.b $3f
                    dc.b $43
                    dc.b $47
                    dc.b $4b
                    dc.b $4f
                    dc.b $54
                    dc.b $59
                    dc.b $5e
                    dc.b $64
                    dc.b $6a
                    dc.b $70
                    dc.b $77
                    dc.b $7e
                    dc.b $86
                    dc.b $8e
                    dc.b $96
                    dc.b $9f
                    dc.b $a8
                    dc.b $b3
                    dc.b $bd
                    dc.b $c8
                    dc.b $d4
                    dc.b $e1
                    dc.b $ee
                    dc.b $fd
; ------------------------------------------------------------------------------------------------------------- ;
