@echo off
echo Generating cryptographic key (SNK) if it does not exist...
powershell -ExecutionPolicy Bypass -File "GenerateKey.ps1"
echo.

dotnet build -c Release
if %errorlevel% neq 0 exit /b %errorlevel%

echo.
echo Preparing distribution folder...
if not exist "dist" mkdir "dist"
copy /y "bin\Release\net48\hwReport.dll" "dist\"
copy /y "bin\Release\net48\hwReport.tlb" "dist\"

echo.
echo Registering DLL in the system (Administrator required)...

powershell -Command "$regasm = [System.Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory() + 'regasm.exe'; if (Test-Path $regasm) { & $regasm 'dist\hwReport.dll' /codebase /tlb } else { Write-Error 'regasm.exe not found' ; exit 1 }"
if %errorlevel% neq 0 exit /b %errorlevel%

echo.
echo Process completed. The DLL is in the 'dist' folder.
pause