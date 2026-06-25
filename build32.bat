@echo off
echo ===================================================
echo   hwReport - Build and Register (32-bit / x86)
echo ===================================================
echo Generating cryptographic key (SNK) if it does not exist...
powershell -ExecutionPolicy Bypass -File "GenerateKey.ps1"
echo.

echo Unregistering previous version to release file locks...
powershell -Command "$regasm = [System.Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory().Replace('Framework64', 'Framework') + 'regasm.exe'; if (Test-Path $regasm) { & $regasm 'dist\x86\hwReport.dll' /unregister 2>$null; & $regasm 'bin\x86\Release\net48\hwReport.dll' /unregister 2>$null; & $regasm 'bin\Release\net48\hwReport.dll' /unregister 2>$null }"

echo Stopping any process holding the DLL lock...
taskkill /f /im hwfcgi.exe >nul 2>nul

echo.
echo Cleaning previous build artifacts...
dotnet clean -c Release >nul 2>nul

echo Building for x86...
dotnet build -c Release -p:PlatformTarget=x86
if %errorlevel% neq 0 exit /b %errorlevel%

echo.
echo Registering DLL directly from build output (32-bit Administrator required)...
powershell -Command "$regasm = [System.Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory().Replace('Framework64', 'Framework') + 'regasm.exe'; if (Test-Path $regasm) { & $regasm 'bin\x86\Release\net48\hwReport.dll' /codebase /tlb } else { Write-Error '32-bit regasm.exe not found' ; exit 1 }"
if %errorlevel% neq 0 exit /b %errorlevel%

echo.
echo Copying to dist\x86\ for distribution...
if not exist "dist\x86" mkdir "dist\x86"
copy /Y "bin\x86\Release\net48\hwReport.dll" "dist\x86\hwReport.dll" >nul
copy /Y "bin\x86\Release\net48\hwReport.tlb" "dist\x86\hwReport.tlb" >nul

echo.
echo Process completed. The 32-bit DLL is registered and copied to 'dist\x86\'.
pause
