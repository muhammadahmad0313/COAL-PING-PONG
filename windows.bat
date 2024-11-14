@echo off

REM Base directory for all ASM files (adjust as needed)
set "ASM_BASE_DIR=C:\Users\abdur\Documents\asm"

REM Check if the filename is provided as an argument
if "%~1"=="" (
  echo Please provide the name of the .asm file.
  exit /b 1
)

REM Ensure the provided file is inside the ASM base directory
set "FILE_PATH=%~1"
if not "%FILE_PATH%"=="%ASM_BASE_DIR%\%~nx1" (
  echo Error: The file must be inside the %ASM_BASE_DIR% directory.
  exit /b 1
)

REM Extract the filename without the extension
set "FILENAME=%~n1"

REM Get the directory of the file being passed
set "FILE_DIR=%~dp1"

REM Get the path relative to the base directory
set "RELATIVE_PATH=%FILE_DIR:%ASM_BASE_DIR%\=%"

REM Launch DOSBox with NASM and AFD
if "%~2"=="debug" (
  dosbox -c "mount c %ASM_BASE_DIR%" ^
          -c "c:" ^
          -c "NASM.EXE %RELATIVE_PATH%\%FILENAME%.asm -o %RELATIVE_PATH%\%FILENAME%.COM" ^
          -c "AFD.EXE %RELATIVE_PATH%\%FILENAME%.COM" 
) else (
  dosbox -c "mount c %ASM_BASE_DIR%" ^
          -c "c:" ^
          -c "NASM.EXE -f bin %RELATIVE_PATH%\%FILENAME%.asm -o %RELATIVE_PATH%\%FILENAME%.COM" ^
          -c "cd %RELATIVE_PATH%" ^
          -c "%FILENAME%.COM"
)
