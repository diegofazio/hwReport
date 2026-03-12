@echo off
setlocal
echo ===================================================
echo   hwReport - Verificador de Registro COM / OLE
echo ===================================================
echo.
echo Intentando crear el objeto "hwReport.FastReport"...
echo.

cscript //nologo test_com.vbs > nul 2>&1

if %ERRORLEVEL% EQU 0 goto :success
goto :error

:success
echo [ OK ] El objeto se ha creado correctamente. 
echo        La DLL esta registrada y lista para usar.
echo.
cscript //nologo test_com.vbs
goto :end

:error
echo [ERROR] No se pudo crear el objeto "hwReport.FastReport".
echo         Asegurate de haber ejecutado Build.bat o RegAsm.exe como Administrador.
echo.
echo Comando sugerido (Admin):
echo C:\Windows\Microsoft.NET\Framework64\v4.0.30319\regasm.exe "c:\harbour\contrib\hwReport\bin\Release\net48\hwReport.dll" /codebase /tlb
goto :end

:end
echo.
echo ===================================================
pause
