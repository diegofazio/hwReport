@echo off
echo ===================================================
echo   hwReport - Unregister (32-bit)
echo ===================================================
echo.
echo Unregistering hwReport.FastReport...
powershell -Command "$regasm = [System.Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory().Replace('Framework64', 'Framework') + 'regasm.exe'; if (Test-Path $regasm) { & $regasm '%~dp0hwReport.dll' /unregister 2>$null } else { Write-Error '32-bit regasm.exe not found'; exit 1 }"

echo.
echo Unregistration complete.
pause
