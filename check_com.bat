@echo off
setlocal enabledelayedexpansion
echo ===================================================
echo   hwReport - COM / OLE Registration Verifier
echo ===================================================
echo.

set CSCRIPT64=%SystemRoot%\System32\cscript.exe
set CSCRIPT32=%SystemRoot%\SysWOW64\cscript.exe

echo 1. Checking 64-bit Registration...
if exist "!CSCRIPT64!" (
    !CSCRIPT64! //nologo test_com.vbs > %TEMP%\hw64.tmp 2>&1
    if !ERRORLEVEL! EQU 0 (
        set /p RES64=<%TEMP%\hw64.tmp
        echo [ OK ] !RES64!
    ) else (
        echo [ SKIP ] Not registered for 64-bit or error.
    )
) else (
    echo [ N/A ] 64-bit environment not found.
)

echo.
echo 2. Checking 32-bit Registration...
if exist "!CSCRIPT32!" (
    !CSCRIPT32! //nologo test_com.vbs > %TEMP%\hw32.tmp 2>&1
    if !ERRORLEVEL! EQU 0 (
        set /p RES32=<%TEMP%\hw32.tmp
        echo [ OK ] !RES32!
    ) else (
        echo [ SKIP ] Not registered for 32-bit or error.
    )
) else (
    :: On 32-bit OS, System32 IS 32-bit
    !CSCRIPT64! //nologo test_com.vbs > %TEMP%\hw32.tmp 2>&1
    if !ERRORLEVEL! EQU 0 (
        set /p RES32=<%TEMP%\hw32.tmp
        echo [ OK ] !RES32!
    ) else (
        echo [ SKIP ] Not registered for 32-bit or error.
    )
)

echo.
echo ===================================================
echo If you missing one, run build32.bat or build64.bat 
echo as Administrator.
echo ===================================================
pause
