@rem starts in 'asm' directory
@rem wants two parms: prg_long_name & prg_short_name
@rem because the old 'C64DisA' accepts only the short form
@rem --------------------------------------------------------------------------

@set  LNAM=%1
@set  SNAM=%2

@rem eventually kill a previous long one to allow a rename short-->long
@if   exist .\dis\%LNAM%.dis    del .\dis\%LNAM%.dis

@rem check for the prg to exist
@if   exist .\prg\%LNAM%.prg    goto DisAsm
@echo .\prg\%LNAM%.prg not found
@exit

:DisAsm
@"D:\Private\c64\Tools\c64asm\C64DISA.EXE" .\prg\%SNAM%.prg .\dis\%SNAM%.dis

@rem wait for a completed output (close file)
:Check
@if exist .\dis\%SNAM%.dis GOTO CleanUp
@goto Check

@rem rename the short form into the good long one
:CleanUp
@ren .\dis\%SNAM%.dis %LNAM%.dis

:MsgDisAsm
@echo.
@echo Disassembly: .\dis\%LNAM%.dis
