@echo off
echo ===================================================
echo   hwReport - Register (32-bit)
echo ===================================================

echo Unregistering previous version (if any)...
powershell -Command "$regasm = [System.Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory().Replace('Framework64', 'Framework') + 'regasm.exe'; if (Test-Path $regasm) { & $regasm '%~dp0hwReport.dll' /unregister 2>$null }"

echo.
echo Registering hwReport.FastReport (32-bit Administrator required)...
powershell -Command "$regasm = [System.Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory().Replace('Framework64', 'Framework') + 'regasm.exe'; if (Test-Path $regasm) { & $regasm '%~dp0hwReport.dll' /codebase /tlb } else { Write-Error '32-bit regasm.exe not found' ; exit 1 }"
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Could not register the DLL.
    pause
    exit /b 1
)

echo.
echo Registration successful.
pause
