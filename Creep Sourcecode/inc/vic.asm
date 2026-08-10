; ------------------------------------------------------------------------------------------------------------- ;
; C64 VIC-II (Video Interface Chip II) Registers  $D000-$D02E
; ------------------------------------------------------------------------------------------------------------- ;
SP0X                = $D000
SP0Y                = $D001
SP1X                = $D002
SP1Y                = $D003
SP2X                = $D004
SP2Y                = $D005
SP3X                = $D006
SP3Y                = $D007
SP4X                = $D008
SP4Y                = $D009
SP5X                = $D00A
SP5Y                = $D00B
SP6X                = $D00C
SP6Y                = $D00D
SP7X                = $D00E
SP7Y                = $D00F
MSIGX               = $D010
SCROLY              = $D011
RASTER              = $D012
LPENX               = $D013
LPENY               = $D014
SPENA               = $D015
SCROLX              = $D016
YXPAND              = $D017
VMCSB               = $D018
VICIRQ              = $D019
IRQMASK             = $D01A
SPBGPR              = $D01B
SPMC                = $D01C
XXPAND              = $D01D
SPSPCL              = $D01E
SPBGCL              = $D01F
EXTCOL              = $D020
BGCOL0              = $D021
BGCOL1              = $D022
BGCOL2              = $D023
BGCOL3              = $D024
SPMC0               = $D025
SPMC1               = $D026
SP0COL              = $D027
SP1COL              = $D028
SP2COL              = $D029
SP3COL              = $D02A
SP4COL              = $D02B
SP5COL              = $D02C
SP6COL              = $D02D
SP7COL              = $D02E
; ------------------------------------------------------------------------------------------------------------- ;
; VIC-II memory bank select (via CIA2 CI2PRA bits 0-1, value = 3 - bank number, since the field is inverted)
; ------------------------------------------------------------------------------------------------------------- ;
VIC_MemBank_0        = $03                     ; Bank 0: $0000-$3FFF
VIC_MemBank_1        = $02                     ; Bank 1: $4000-$7FFF
VIC_MemBank_2        = $01                     ; Bank 2: $8000-$BFFF
VIC_MemBank_3        = $00                     ; Bank 3: $C000-$FFFF
VIC_MemBankClr       = $FC                     ; AND mask to clear CI2PRA bits 0-1 before setting a new bank
