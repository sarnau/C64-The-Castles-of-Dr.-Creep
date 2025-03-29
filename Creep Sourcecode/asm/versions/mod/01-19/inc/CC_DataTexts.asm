; ------------------------------------------------------------------------------------------------------------- ;
; Castles of Dr Creep - Texts / Load castle data sceen texts
; ------------------------------------------------------------------------------------------------------------- ;
TextGameOver            dc.b $3c                        ; StartPos  : PosX = 3c
                        dc.b $38                        ; StartPos  : PosY = 38
                        dc.b LT_RED                     ; ColorNo   :
                        dc.b $22                        ; Format    : 22 = normal/double size
                        dc.b $47 ; g                    ; Text      : (max 20 chr) = game oveR
                        dc.b $41 ; a
                        dc.b $4d ; m
                        dc.b $45 ; e
                        dc.b $20 ; _
                        dc.b $4f ; o
                        dc.b $56 ; v
                        dc.b $45 ; e
                        dc.b $d2 ; R                    ; EndOfLine = Bit 7 set
                        
                        dc.b $00                        ; EndOfText = 00
                        
TextGameOverP1          dc.b $30                        ; StartPos  : PosX = 30
                        dc.b $68                        ; StartPos  : PosY = 68
                        dc.b YELLOW                     ; ColorNo   :
                        dc.b $21                        ; Format    : 21 = normal/normal size
                        dc.b $46 ; f                    ; Text      : (max 20 chr) =      ; for player 1
                        dc.b $4f ; o
                        dc.b $52 ; r
                        dc.b $20 ; _
                        dc.b $50 ; p
                        dc.b $4c ; l
                        dc.b $41 ; a
                        dc.b $59 ; y
                        dc.b $45 ; e
                        dc.b $52 ; r
                        dc.b $20 ; _
                        dc.b $b1 ; 1                    ; EndOfLine = Bit 7 set
                        
                        dc.b $00                        ; EndOfText = 00
                        
TextGameOverP2          dc.b $30                        ; StartPos  : PosX = 30
                        dc.b $80                        ; StartPos  : PosY = 80
                        dc.b ORANGE                     ; ColorNo   :
                        dc.b $21                        ; Format    : 21 = normal/normal size
                        dc.b $46 ; f                    ; Text      : (max 20 chr) =      ; for player 2
                        dc.b $4f ; o
                        dc.b $52 ; r
                        dc.b $20 ; _
                        dc.b $50 ; p
                        dc.b $4c ; l
                        dc.b $41 ; a
                        dc.b $59 ; y
                        dc.b $45 ; e
                        dc.b $52 ; r
                        dc.b $20 ; _
                        dc.b $b2 ; 2                    ; EndOfLine = Bit 7 set
                        
                        dc.b $00                        ; EndOfText = 00
; ------------------------------------------------------------------------------------------------------------- ;
TextBestTimePlayers     = *
TextBestTimeP1          dc.b $b1 ; 1                    ; "1" - for TextHiScorePNo - bit 8 set for EndOfLine
TextBestTimeP2          dc.b $b2 ; 2                    ; "2"
; ------------------------------------------------------------------------------------------------------------- ;
TextOneUp               dc.b CC_Player1MapTxtGridCol    ; StartPos  : PosX = 10
                        dc.b $00                        ; StartPos  : PosY = 00
TextOneUpColor          dc.b CC_MultiColor0Player1      ; ColorNo   : .hbu016.
                        dc.b $22                        ; Format    : 22 = normal/double size
                        dc.b $4f ; o                    ; Text      : (max 20 chr) = one uP
                        dc.b $4e ; n
                        dc.b $45 ; e
                        dc.b $20 ; _
                        dc.b $55 ; u
                        dc.b $d0 ; P
                        
TextTwoUp               dc.b CC_Player2MapTxtGridCol    ; StartPos  : PosX = 74
                        dc.b $00                        ; StartPos  : PosY = 00
TextTwoUpColor          dc.b CC_MultiColor0Player2      ; ColorNo   : .hbu016.
                        dc.b $22                        ; Format    : 22 = normal/double size
                        dc.b $54 ; t                    ; Text      : (max 20 chr) = two uP
                        dc.b $57 ; w
                        dc.b $4f ; o
                        dc.b $20 ; _
                        dc.b $55 ; u
                        dc.b $d0 ; P
                        
                        dc.b $00                        ; EndOfText = 00
; ------------------------------------------------------------------------------------------------------------- ;
TextEscape              dc.b $20                        ; StartPos  : PosX = 20
                        dc.b $00                        ; StartPos  : PosY = 00
                        dc.b LT_GREEN                   ; ColorNo   :
                        dc.b $22                        ; Format    : 22 = normal/double size
                        dc.b $50 ; p                     ; Text      : (max 20 chr) = player
                        dc.b $4c ; l
                        dc.b $41 ; a
                        dc.b $59 ; y
                        dc.b $45 ; e
                        dc.b $52 ; r
                        dc.b $20 ; _
TextEscapePNo           dc.b $20                        ; player number
                        dc.b $20 ; _
                        dc.b $45 ; e                    ; escapeS
                        dc.b $53 ; s
                        dc.b $43 ; c
                        dc.b $41 ; a
                        dc.b $50 ; p
                        dc.b $45 ; e
                        dc.b $d3 ; S                    ; EndOfLine = Bit 7 set
                        
                        dc.b $38                        ; StartPos  : PosX = 38
                        dc.b $18                        ; StartPos  : PosY = 18
                        dc.b YELLOW                     ; ColorNo   :
                        dc.b $21                        ; Format    : 21 = normal/normal size
                        dc.b $54 ; t                    ; Text      : (max 20 chr) = time
                        dc.b $49 ; i
                        dc.b $4d ; m
                        dc.b $45 ; e
                        dc.b $ba ; :                    ; EndOfLine = Bit 7 set
                        
                        dc.b $00                        ; EndOfText = 00
; ------------------------------------------------------------------------------------------------------------- ;
TextHiScore             dc.b $40                        ; StartPos  : PosX = 40
                        dc.b $a0                        ; StartPos  : PosY = a0
                        dc.b LT_BLUE                    ; ColorNo   :
                        dc.b $22                        ; Format    : 22 = normal/double size
                        dc.b $50 ; p                    ; Text      : (max 20 chr) = player__
                        dc.b $4c ; l
                        dc.b $41 ; a
                        dc.b $59 ; y
                        dc.b $45 ; e
                        dc.b $52 ; r
                        dc.b $20 ; _
TextHiScorePNo          dc.b $a0 ; _                    ; EndOfLine = Bit 7 set
                        
                        dc.b $14                        ; StartPos  : PosX = 20
                        dc.b $b8                        ; StartPos  : PosY = 00
                        dc.b GREY                       ; ColorNo   :
                        dc.b $21                        ; Format    : 21 = normal/normal size
                        dc.b $45 ; e                    ; Text      : (max 20 chr) = enter your initialS
                        dc.b $4e ; n
                        dc.b $54 ; t
                        dc.b $45 ; e
                        dc.b $52 ; r
                        dc.b $20 ; _
                        dc.b $59 ; y
                        dc.b $4f ; o
                        dc.b $55 ; u
                        dc.b $52 ; r
                        dc.b $20 ; _
                        dc.b $49 ; i
                        dc.b $4e ; n
                        dc.b $49 ; i
                        dc.b $54 ; t
                        dc.b $49 ; i
                        dc.b $41 ; a
                        dc.b $4c ; l
                        dc.b $d3 ; S                    ; EndOfLine = Bit 7 set
                        
                        dc.b $18                        ; StartPos  : PosX = 18
                        dc.b $c0                        ; StartPos  : PosY = c0
                        dc.b GREY                       ; ColorNo   :
                        dc.b $21                        ; Format    : 21 = normal/normal size
                        dc.b $46 ; f                    ; Text      : (max 20 chr) = followed bY
                        dc.b $4f ; o
                        dc.b $4c ; l
                        dc.b $4c ; l
                        dc.b $4f ; o
                        dc.b $57 ; w
                        dc.b $45 ; e
                        dc.b $44 ; d
                        dc.b $20 ; _
                        dc.b $42 ; b
                        dc.b $d9 ; Y                    ; EndOfLine = Bit 7 set
                        
                        dc.b $78                        ; StartPos  : PosX = 78
                        dc.b $c0                        ; StartPos  : PosY = c0
                        dc.b GREY                       ; ColorNo   :
                        dc.b $31                        ; Format    : 31 = reverse/normal size
                        dc.b $52 ; r                    ; Text      : (max 20 chr) = returN
                        dc.b $45 ; e
                        dc.b $54 ; t
                        dc.b $55 ; u
                        dc.b $52 ; r
                        dc.b $ce ; N                    ; EndOfLine = Bit 7 set
                        
                        dc.b $00                        ; EndOfText = 00
; ------------------------------------------------------------------------------------------------------------- ;
TextBestTimes           dc.b $28                        ; StartPos  : PosX = 28
                        dc.b $00                        ; StartPos  : PosY = 00
                        dc.b YELLOW                     ; ColorNo   :
                        dc.b $21                        ; Format    : 21 = normal/normal size
                        dc.b $42 ; b                    ; Text      : (max 20 chr) = best times foR
                        dc.b $45 ; e
                        dc.b $53 ; s
                        dc.b $54 ; t
                        dc.b $20 ; _
                        dc.b $54 ; t
                        dc.b $49 ; i
                        dc.b $4d ; m
                        dc.b $45 ; e
                        dc.b $53 ; s
                        dc.b $20 ; _
                        dc.b $46 ; f
                        dc.b $4f ; o
                        dc.b $d2 ; R                    ; EndOfLine = Bit 7 set
                        
                        dc.b $18                        ; StartPos  : PosX = 18
                        dc.b $28                        ; StartPos  : PosY = 28
                        dc.b LT_GREEN                   ; ColorNo   :
                        dc.b $21                        ; Format    : 21 = normal/normal size
                        dc.b $31 ; 1                    ; Text      : (max 20 chr) = 1 player  2 playerS
                        dc.b $20 ; _
                        dc.b $50 ; p
                        dc.b $4c ; l
                        dc.b $41 ; a
                        dc.b $59 ; y
                        dc.b $45 ; e
                        dc.b $52 ; r
                        dc.b $20 ; _
                        dc.b $20 ; _
                        dc.b $32 ; 2
                        dc.b $20 ; _
                        dc.b $50 ; p
                        dc.b $4c ; l
                        dc.b $41 ; a
                        dc.b $59 ; y
                        dc.b $45 ; e
                        dc.b $52 ; r
                        dc.b $d3 ; S                    ; EndOfLine = Bit 7 set
                        
                        dc.b $00                        ; EndOfText = 00
; ------------------------------------------------------------------------------------------------------------- ;
TextExit                dc.b $10                        ; StartPos  : PosX = 10
                        dc.b $c0                        ; StartPos  : PosY = c0
                        dc.b GREY                       ; ColorNo   :
                        dc.b $21                        ; Format    : 21 = normal/normal size
                        dc.b $50 ; p                    ; Text      : (max 20 chr) = presS
                        dc.b $52 ; r
                        dc.b $45 ; e
                        dc.b $53 ; s
                        dc.b $d3 ; S                    ; EndOfLine = Bit 7 set
                        
                        dc.b $78                        ; StartPos  : PosX = 78
                        dc.b $c0                        ; StartPos  : PosY = c0
                        dc.b GREY                       ; ColorNo   :
                        dc.b $21                        ; Format    : 21 = normal/normal size
                        dc.b $54 ; t                    ; Text      : (max 20 chr) = to exiT
                        dc.b $4f ; o
                        dc.b $20 ; _
                        dc.b $45 ; e
                        dc.b $58 ; x
                        dc.b $49 ; i
                        dc.b $d4 ; T                    ; EndOfLine = Bit 7 set
                        
                        dc.b $48                        ; StartPos  : PosX = 40
                        dc.b $c0                        ; StartPos  : PosY = c0
                        dc.b GREY                       ; ColorNo   :
                        dc.b $31                        ; Format    : 31 = reverse/normal size
                        dc.b $46 ; f                    ; Text      : (max 20 chr) = fire
                        dc.b $49 ; i
                        dc.b $52 ; r
                        dc.b $c5 ; E                    ; EndOfLine = Bit 7 set
                        
                        dc.b $00                        ; EndOfText = 00
; ------------------------------------------------------------------------------------------------------------- ;
TextIOError             dc.b $3c                        ; StartPos  : PosX = 3c
                        dc.b $50                        ; StartPos  : PosY = 50
                        dc.b LT_RED                     ; ColorNo   :
                        dc.b $22                        ; Format    : 22 = normal/double size
                        dc.b $49 ; i                    ; Text      : (max 20 chr) = i/o erroR
                        dc.b $2f ; /
                        dc.b $4f ; o
                        dc.b $20 ; _
                        dc.b $45 ; e
                        dc.b $52 ; r
                        dc.b $52 ; r
                        dc.b $4f ; o
                        dc.b $d2 ; R                    ; EndOfLine = Bit 7 set
                        
                        dc.b $00                        ; EndOfText = 00
; ------------------------------------------------------------------------------------------------------------- ;
TextSaveGame            dc.w RoomTextLine
                        
                        dc.b $2c                        ; StartPos  : PosX = 2c
                        dc.b $00                        ; StartPos  : PosY = 00
                        dc.b WHITE                      ; ColorNo   :
                        dc.b $22                        ; Format    : 22 = normal/double size
                        dc.b $53 ; s                    ; Text      : (max 20 chr) = save positioN
                        dc.b $41 ; a
                        dc.b $56 ; v
                        dc.b $45 ; e
                        dc.b $20 ; _
                        dc.b $50 ; p
                        dc.b $4f ; o
                        dc.b $53 ; s
                        dc.b $49 ; i
                        dc.b $54 ; t
                        dc.b $49 ; i
                        dc.b $4f ; o
                        dc.b $ce ; N                    ; EndOfLine = Bit 7 set
                        
                        dc.b $00                        ; EndOfText
                        
                        dc.b $00                        ; EndOfData
                        dc.b $00
; ------------------------------------------------------------------------------------------------------------- ;
TextResumeGame          dc.w RoomTextLine
                        
                        dc.b $34                        ; StartPos  : PosX = 34
                        dc.b $00                        ; StartPos  : PosY = 00
                        dc.b WHITE                      ; ColorNo   :
                        dc.b $22                        ; Format    : 22 = normal/double size
                        dc.b $52 ; r                    ; Text      : (max 20 chr) = resume gamE
                        dc.b $45 ; e
                        dc.b $53 ; s
                        dc.b $55 ; u
                        dc.b $4d ; m
                        dc.b $45 ; e
                        dc.b $20 ; _
                        dc.b $47 ; g
                        dc.b $41 ; a
                        dc.b $4d ; m
                        dc.b $c5 ; E                    ; EndOfLine = Bit 7 set
                        
                        dc.b $00                        ; EndOfText
                        
                        dc.b $00                        ; EndOfData
                        dc.b $00
; ------------------------------------------------------------------------------------------------------------- ;
TextFileName            dc.w RoomTextLine
                        
                        dc.b $1c                        ; StartPos  : PosX = 1c
                        dc.b $30                        ; StartPos  : PosY = 30
                        dc.b LT_GREEN                   ; ColorNo   :
                        dc.b $21                        ; Format    : 21 = normal/normal size
                        dc.b $54 ; t                    ; Text      : (max 20 chr) = type in file namE
                        dc.b $59 ; y
                        dc.b $50 ; p
                        dc.b $45 ; e
                        dc.b $20 ; _
                        dc.b $49 ; i
                        dc.b $4e ; n
                        dc.b $20 ; _
                        dc.b $46 ; f
                        dc.b $49 ; i
                        dc.b $4c ; l
                        dc.b $45 ; e
                        dc.b $20 ; _
                        dc.b $4e ; n
                        dc.b $41 ; a
                        dc.b $4d ; m
                        dc.b $c5 ; E                    ; EndOfLine = Bit 7 set
                        
                        dc.b $18                        ; StartPos  : PosX = 18
                        dc.b $38                        ; StartPos  : PosY = 38
                        dc.b LT_GREEN                   ; ColorNo   :
                        dc.b $21                        ; Format    : 21 = normal/normal size
                        dc.b $46 ; f                    ; Text      : (max 20 chr) = followed bY
                        dc.b $4f ; o
                        dc.b $4c ; l
                        dc.b $4c ; l
                        dc.b $4f ; o
                        dc.b $57 ; w
                        dc.b $45 ; e
                        dc.b $44 ; d
                        dc.b $20 ; _
                        dc.b $42 ; b
                        dc.b $d9 ; Y                    ; EndOfLine = Bit 7 set
                        
                        dc.b $78                        ; StartPos  : PosX = 78
                        dc.b $38                        ; StartPos  : PosY = 38
                        dc.b LT_GREEN                   ; ColorNo   :
                        dc.b $31                        ; Format    : 21 = normal/normal size
                        dc.b $52 ; r                    ; Text      : (max 20 chr) = returN
                        dc.b $45 ; e
                        dc.b $54 ; t
                        dc.b $55 ; u
                        dc.b $52 ; r
                        dc.b $ce ; N                    ; EndOfLine = Bit 7 set
                        
                        dc.b $20                        ; StartPos  : PosX = 20
                        dc.b $78                        ; StartPos  : PosY = 78
                        dc.b LT_RED                     ; ColorNo   :
                        dc.b $21                        ; Format    : 21 = normal/normal size
                        dc.b $50 ; p                    ; Text      : (max 20 chr) = press
                        dc.b $52 ; r
                        dc.b $45 ; e
                        dc.b $53 ; s
                        dc.b $53 ; s
                        
                        dc.b $20 ; _                    ; blank - placeholder filled with "restorE" below
                        dc.b $20 ; _
                        dc.b $20 ; _
                        dc.b $20 ; _
                        dc.b $20 ; _
                        dc.b $20 ; _
                        dc.b $20 ; _
                        dc.b $20 ; _
                        dc.b $20 ; _
                        
                        dc.b $54 ; t                    ; tO
                        dc.b $cf ; O                    ; EndOfLine = Bit 7 set
                        
                        dc.b $50                        ; StartPos  : PosX = 50
                        dc.b $78                        ; StartPos  : PosY = 78
                        dc.b LT_RED                     ; ColorNo   :
                        dc.b $31                        ; Format    : 31 = reverse/normal size
                        dc.b $52 ; r                    ; Text      : (max 20 chr) = restorE
                        dc.b $45 ; e
                        dc.b $53 ; s
                        dc.b $54 ; t
                        dc.b $4f ; o
                        dc.b $52 ; r
                        dc.b $c5 ; E                    ; EndOfLine = Bit 7 set
                        
                        dc.b $48                        ; StartPos  : PosX = 48
                        dc.b $80                        ; StartPos  : PosY = 80
                        dc.b LT_RED                     ; ColorNo   :
                        dc.b $21                        ; Format    : 21 = normal/normal size
                        dc.b $43 ; c                    ; Text      : (max 20 chr) = canceL
                        dc.b $41 ; a
                        dc.b $4e ; n
                        dc.b $43 ; c
                        dc.b $45 ; e
                        dc.b $cc ; L                    ; EndOfLine = Bit 7 set
                        
                        dc.b $00                        ; EndOfText
                        
                        dc.b $00                        ; EndOfData
                        dc.b $00
; ------------------------------------------------------------------------------------------------------------- ;
; Load Castle Data Screen Text Lines (Fix Part)
; ------------------------------------------------------------------------------------------------------------- ;
ScreenLineHeader        equ  $00                        ; line header
ScreenLineCol           equ  $00                        ; start column
ScreenLineDataEnd       equ    $ff                      ;   end of text screen data 
ScreenLineRow           equ  $01                        ; start row
ScreenLineRowTopOff       equ  CC_LoadCtrlAreaTop       ; start offset of top line
ScreenLineId            equ  $02                        ; control table entry number
ScreenLineIdLives         equ CC_LoadCtrlIdLives        ; $00
ScreenLineIdExit          equ CC_LoadCtrlIdExit         ; $01
ScreenLineIdResume        equ CC_LoadCtrlIdResume       ; $03
ScreenLineIdTimes         equ CC_LoadCtrlIdTimes        ; $04
ScreenLineIdNoSelect      equ $ff                       ; info line: not cursor selectable
ScreenLineHeaderLen     equ  $03                        ; line header length
; ------------------------------------------------------------------------------------------------------------- ;
ScreenLineData          equ  *                          ; texts for level / options select screen
ScreenLineJoyMov        equ  ScreenLineRowTopOff        ; load screen row number
ScreenLineJoyMovLoc     equ  CC_LoadCtrlAreaInfo        ; 
ScreenLineJoyMovHdr     dc.b ScreenLineJoyMovLoc        ; start in info display area
                        dc.b ScreenLineJoyMov           ; screen row number
                        dc.b ScreenLineIdNoSelect       ; header line: not cursor selectable
                        
ScreenLineJoyMovTxt     dc.b $55 ; u                    ; use joystick 1 to move pointeR
                        dc.b $53 ; s
                        dc.b $45 ; e
                        dc.b $20 ; _
                        dc.b $4a ; j
                        dc.b $4f ; o
                        dc.b $59 ; y
                        dc.b $53 ; s
                        dc.b $54 ; t
                        dc.b $49 ; i
                        dc.b $43 ; c
                        dc.b $4b ; k
                        dc.b $20 ; _
                        dc.b $31 ; 1
                        dc.b $20 ; _
                        dc.b $54 ; t
                        dc.b $4f ; o
                        dc.b $20 ; _
                        dc.b $4d ; m
                        dc.b $4f ; o
                        dc.b $56 ; v
                        dc.b $45 ; e
                        dc.b $20 ; _
                        dc.b $50 ; p
                        dc.b $4f ; o
                        dc.b $49 ; i
                        dc.b $4e ; n
                        dc.b $54 ; z
                        dc.b $45 ; e
ScreenLineJoyMovEnd     dc.b $d2 ; R
; ------------------------------------------------------------------------------------------------------------- ;
ScreenLineJoySel        equ  ScreenLineJoyMov + $01     ; load screen row number
ScreenLineJoySelLoc     equ  CC_LoadCtrlAreaInfo        ; 
ScreenLineJoySelHdr     dc.b ScreenLineJoySelLoc        ; start in info display area
                        dc.b ScreenLineJoySel           ; screen row number
                        dc.b ScreenLineIdNoSelect       ; header: not selectable
                    
ScreenLineJoySelTxt     dc.b $50 ; p                    ; press trigger button to selecT
                        dc.b $52 ; r
                        dc.b $45 ; e
                        dc.b $53 ; s
                        dc.b $53 ; s
                        dc.b $20 ; _
                        dc.b $54 ; t
                        dc.b $52 ; r
                        dc.b $49 ; i
                        dc.b $47 ; g
                        dc.b $47 ; g
                        dc.b $45 ; e
                        dc.b $52 ; r
                        dc.b $20 ; _
                        dc.b $42 ; b
                        dc.b $55 ; u
                        dc.b $54 ; t
                        dc.b $54 ; t
                        dc.b $4f ; o
                        dc.b $4e ; n
                        dc.b $20 ; _
                        dc.b $54 ; t
                        dc.b $4f ; o
                        dc.b $20 ; _
                        dc.b $53 ; s
                        dc.b $45 ; e
                        dc.b $4c ; l
                        dc.b $45 ; e
                        dc.b $43 ; c
ScreenLineJoySelEnd     dc.b $d4 ; T
; ------------------------------------------------------------------------------------------------------------- ;
ScreenLineResume        equ  ScreenLineJoySel + $02     ; load screen row number
ScreenLineResumeLoc     equ  CC_LoadCtrlAreaLe          ; 
ScreenLineResumeHdr     dc.b ScreenLineResumeLoc        ; start in left display area
                        dc.b ScreenLineResume           ; screen row number
                        dc.b ScreenLineIdResume         ; selectable: resume
                        
ScreenLineResumeTxt     dc.b $52 ; r                    ; resume gameE
                        dc.b $45 ; e
                        dc.b $53 ; s
                        dc.b $55 ; u
                        dc.b $4d ; m
                        dc.b $45 ; e
                        dc.b $20 ; _
                        dc.b $47 ; g
                        dc.b $41 ; a
                        dc.b $4d ; m
ScreenLineResumeEnd     dc.b $c5 ; E
; ------------------------------------------------------------------------------------------------------------- ;
ScreenLineTimes         equ  ScreenLineJoySel + $02     ; load screen row number
ScreenLineTimesLoc      equ  CC_LoadCtrlAreaRi          ; 
ScreenLineTimesHdr      dc.b ScreenLineTimesLoc         ; start in right display area
                        dc.b ScreenLineTimes            ; screen row number
                        dc.b ScreenLineIdTimes          ; selectable: best times
                        
ScreenLineTimesTxt      dc.b $56 ; v                    ; view best timeS
                        dc.b $49 ; i
                        dc.b $45 ; e
                        dc.b $57 ; w
                        dc.b $20 ; _
                        dc.b $42 ; b
                        dc.b $45 ; e
                        dc.b $53 ; s
                        dc.b $54 ; t
                        dc.b $20 ; _
                        dc.b $54 ; t
                        dc.b $49 ; i
                        dc.b $4d ; m
                        dc.b $45 ; e
ScreenLineTimesEnd      dc.b $d3 ; S
; ------------------------------------------------------------------------------------------------------------- ;
ScreenLineLives         equ  ScreenLineResume + $01     ; load screen row number
ScreenLineLivesLoc      equ  CC_LoadCtrlAreaLe          ; 
ScreenLineLivesHdr      dc.b ScreenLineLivesLoc         ; start in left display area
                        dc.b ScreenLineLives            ; screen row number
                        dc.b ScreenLineIdLives          ; selectable: unlimited no of lives
                        
ScreenLineLivesTxt      dc.b $55 ; u                    ; unlimited lives (on/off)
                        dc.b $4e ; n
                        dc.b $4c ; l
                        dc.b $49 ; i
                        dc.b $4d ; m
                        dc.b $49 ; e
                        dc.b $54 ; t
                        dc.b $45 ; e
                        dc.b $44 ; d
                        dc.b $20 ; _
                        dc.b $4c ; l
                        dc.b $49 ; i
                        dc.b $56 ; v
                        dc.b $45 ; e
                        dc.b $53 ; s
                        dc.b $20 ; _
                        dc.b $28 ; (
ScreenLineLivesOn       dc.b $4f ; o
                        dc.b $4e ; n
                        dc.b $2f ; /
ScreenLineLivesOff      dc.b $4f ; o
                        dc.b $46 ; f
                        dc.b $46 ; f
ScreenLineLivesEnd      dc.b $a9 ; )
; ------------------------------------------------------------------------------------------------------------- ;
ScreenLineExit          equ  ScreenLineLives + $01      ; load screen row number
ScreenLineExitLoc       equ  CC_LoadCtrlAreaLe          ; 
ScreenLineExitHdr       dc.b ScreenLineExitLoc          ; start in left display area
                        dc.b ScreenLineExit             ; screen row number
                        dc.b ScreenLineIdExit           ; selectable: exit
                        
ScreenLineExitTxt       dc.b $45 ; e                    ; exit menU
                        dc.b $58 ; x
                        dc.b $49 ; i
                        dc.b $54 ; t
                        dc.b $20 ; _
                        dc.b $4d ; m
                        dc.b $45 ; e
                        dc.b $4e ; n
ScreenLineExitEnd       dc.b $d5 ; U
; ------------------------------------------------------------------------------------------------------------- ;
ScreenLineGame          equ  ScreenLineExit + $02       ; load screen row number
ScreenLineGameLoc       equ  CC_LoadCtrlAreaLe          ; 
ScreenLineGameHdr       dc.b ScreenLineGameLoc          ; start in left display area
                        dc.b ScreenLineGame             ; screen row number
                        dc.b ScreenLineIdNoSelect       ; header: not selectable
                        
ScreenLineGameTxt       dc.b $4c ; l                    ; load game:
                        dc.b $4f ; o
                        dc.b $41 ; a
                        dc.b $44 ; d
                        dc.b $20 ; _
                        dc.b $47 ; g
                        dc.b $41 ; a
                        dc.b $4d ; m
                        dc.b $45 ; e
ScreenLineGameEnd       dc.b $ba ; :
; ------------------------------------------------------------------------------------------------------------- ;
ScreenLineLinesEnd      dc.b ScreenLineDataEnd          ; end of screen text
; ------------------------------------------------------------------------------------------------------------- ;
