@echo off
echo ===================================================
echo   hwReport - Build and Register (64-bit / x64)
echo ===================================================
echo Generating cryptographic key (SNK) if it does not exist...
powershell -ExecutionPolicy Bypass -File "GenerateKey.ps1"
echo.

echo Building for x64...
dotnet build -c Release -p:PlatformTarget=x64
if %errorlevel% neq 0 exit /b %errorlevel%

echo.
echo Preparing distribution folder...
if not exist "dist\x64" mkdir "dist\x64"
copy /y "bin\Release\net48\hwReport.dll" "dist\x64\"
copy /y "bin\Release\net48\hwReport.tlb" "dist\x64\"

echo.
echo Registering DLL in the system (64-bit Administrator required)...

powershell -Command "$regasm = [System.Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory() + 'regasm.exe'; if (Test-Path $regasm) { & $regasm 'dist\x64\hwReport.dll' /codebase /tlb } else { Write-Error '64-bit regasm.exe not found' ; exit 1 }"
if %errorlevel% neq 0 exit /b %errorlevel%

echo.
echo Process completed. The 64-bit DLL is in 'dist\x64'.
pause
