@echo off
setlocal
cd /d "%~dp0"
if not exist "%~dp0scripts\Troubleshooter-GUI.ps1" (
 echo ERROR: Missing scripts\Troubleshooter-GUI.ps1
 pause
 exit /b 1
)
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -STA -File "%~dp0scripts\Troubleshooter-GUI.ps1"
if errorlevel 1 (
 echo.
 echo GUI could not start. Please share the error above.
 pause
)
endlocal
