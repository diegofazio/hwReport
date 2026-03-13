@echo off
setlocal
echo ===================================================
echo   hwReport - COM / OLE Registration Verifier
echo ===================================================
echo.
echo Attempting to create the "hwReport.FastReport" object...
echo.

cscript //nologo test_com.vbs > nul 2>&1

if %ERRORLEVEL% EQU 0 goto :success
goto :error

:success
echo [ OK ] Object created successfully. 
echo        The DLL is registered and ready for use.
echo.
cscript //nologo test_com.vbs
goto :end

:error
echo [ERROR] Could not create the "hwReport.FastReport" object.
echo         Ensure Build.bat or dist\register.bat was run as Administrator.
echo.
echo Suggested Command (Admin):
echo regasm.exe "dist\hwReport.dll" /codebase /tlb
goto :end

:end
echo.
echo ===================================================
pause
