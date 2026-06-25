@echo off
echo ===================================================
echo   hwReport - Build and Register (64-bit / x64)
echo ===================================================
echo Generating cryptographic key (SNK) if it does not exist...
powershell -ExecutionPolicy Bypass -File "GenerateKey.ps1"
echo.

echo Unregistering previous version to release file locks...
powershell -Command "$regasm = [System.Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory() + 'regasm.exe'; if (Test-Path $regasm) { & $regasm 'dist\x64\hwReport.dll' /unregister 2>$null; & $regasm 'bin\x64\Release\net48\hwReport.dll' /unregister 2>$null; & $regasm 'bin\Release\net48\hwReport.dll' /unregister 2>$null }"

echo Stopping any process holding the DLL lock...
taskkill /f /im hwfcgi.exe >nul 2>nul
taskkill /f /im 11_factura_a.exe >nul 2>nul

echo.
echo Cleaning previous build artifacts...
dotnet clean -c Release >nul 2>nul

echo Building for x64...
dotnet build -c Release -p:PlatformTarget=x64
if %errorlevel% neq 0 exit /b %errorlevel%

echo.
echo Registering DLL directly from build output (64-bit Administrator required)...
powershell -Command "$regasm = [System.Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory() + 'regasm.exe'; if (Test-Path $regasm) { & $regasm 'bin\x64\Release\net48\hwReport.dll' /codebase /tlb } else { Write-Error '64-bit regasm.exe not found' ; exit 1 }"
if %errorlevel% neq 0 exit /b %errorlevel%

echo.
echo Copying to dist\x64\ for distribution...
if not exist "dist\x64" mkdir "dist\x64"
copy /Y "bin\x64\Release\net48\hwReport.dll" "dist\x64\hwReport.dll" >nul
copy /Y "bin\x64\Release\net48\hwReport.tlb" "dist\x64\hwReport.tlb" >nul

echo.
echo Process completed. The 64-bit DLL is registered and copied to 'dist\x64\'.
pause
