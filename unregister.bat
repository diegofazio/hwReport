@echo off
echo ===================================================
echo   hwReport - Unregister COM Components
echo ===================================================
echo.

echo 1. Unregistering 64-bit...
powershell -Command "$regasm = [System.Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory() + 'regasm.exe'; if (Test-Path $regasm) { & $regasm 'dist\x64\hwReport.dll' /u } else { echo '64-bit regasm.exe not found' }"

echo.
echo 2. Unregistering 32-bit...
powershell -Command "$regasm = [System.Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory().Replace('Framework64', 'Framework') + 'regasm.exe'; if (Test-Path $regasm) { & $regasm 'dist\x86\hwReport.dll' /u } else { echo '32-bit regasm.exe not found' }"

echo.
echo ===================================================
echo Process completed.
pause
