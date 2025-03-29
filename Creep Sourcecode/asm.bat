@set  FNAM=%1

@"D:\Private\c64\Tools\Dasm\dasm.exe" .\asm\%FNAM%.asm -o.\prg\%FNAM%.prg -L.\lst\%FNAM%.txt

@echo Source     : .\asm\%FNAM%.asm
@echo Executable : .\prg\%FNAM%.prg
@echo Listing    : .\lst\%FNAM%.txt

@echo.
@rem @echo lst -^> .\lst\%FNAM%.txt
