@echo off
echo ===================================================
echo   hwReport - Register (64-bit)
echo ===================================================

echo Unregistering previous version (if any)...
powershell -Command "$regasm = [System.Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory() + 'regasm.exe'; if (Test-Path $regasm) { & $regasm '%~dp0hwReport.dll' /unregister 2>$null }"

echo.
echo Registering hwReport.FastReport (Administrator required)...
powershell -Command "$regasm = [System.Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory() + 'regasm.exe'; if (Test-Path $regasm) { & $regasm '%~dp0hwReport.dll' /codebase /tlb } else { Write-Error '64-bit regasm.exe not found' ; exit 1 }"
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Could not register the DLL.
    pause
    exit /b 1
)

echo.
echo Registration successful.
pause
