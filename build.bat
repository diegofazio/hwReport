@echo off
echo ===================================================
echo   hwReport - Full Build (x86 and x64)
echo ===================================================
echo.
echo Calling 32-bit build...
call build32.bat
echo.
echo Calling 64-bit build...
call build64.bat
echo.
echo Full build process completed.
pause
