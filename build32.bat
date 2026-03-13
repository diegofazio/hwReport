@echo off
echo ===================================================
echo   hwReport - Build and Register (32-bit / x86)
echo ===================================================
echo Generating cryptographic key (SNK) if it does not exist...
powershell -ExecutionPolicy Bypass -File "GenerateKey.ps1"
echo.

echo Building for x86...
dotnet build -c Release -p:PlatformTarget=x86
if %errorlevel% neq 0 exit /b %errorlevel%

echo.
echo Preparing distribution folder...
if not exist "dist\x86" mkdir "dist\x86"
copy /y "bin\Release\net48\hwReport.dll" "dist\x86\"
copy /y "bin\Release\net48\hwReport.tlb" "dist\x86\"

echo.
echo Registering DLL in the system (32-bit Administrator required)...

powershell -Command "$regasm = [System.Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory().Replace('Framework64', 'Framework') + 'regasm.exe'; if (Test-Path $regasm) { & $regasm 'dist\x86\hwReport.dll' /codebase /tlb } else { Write-Error '32-bit regasm.exe not found' ; exit 1 }"
if %errorlevel% neq 0 exit /b %errorlevel%

echo.
echo Process completed. The 32-bit DLL is in 'dist\x86'.
pause
