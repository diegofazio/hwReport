@echo off
echo Generando clave criptografica (SNK) si no existe...
powershell -ExecutionPolicy Bypass -File "GenerateKey.ps1"
echo.

dotnet build -c Release
echo.
echo Registrando DLL en el sistema (Requiere Admin)...
C:\Windows\Microsoft.NET\Framework64\v4.0.30319\regasm.exe "bin\Release\net48\hwReport.dll" /codebase /tlb
rem pause