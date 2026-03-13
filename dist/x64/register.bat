@echo off
echo Registering hwReport.FastReport (Administrator required)...
echo.
powershell -Command "$regasm = [System.Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory() + 'regasm.exe'; if (Test-Path $regasm) { & $regasm '%~dp0hwReport.dll' /codebase /tlb } else { Write-Error 'regasm.exe not found' ; exit 1 }"
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Could not register the DLL.
    pause
    exit /b 1
)

echo.
echo Registration successful.
pause
