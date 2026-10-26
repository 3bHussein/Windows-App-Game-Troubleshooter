@echo off
setlocal
set "GUI=%~dp0scripts\Troubleshooter-GUI.ps1"
if not exist "%GUI%" (echo Missing GUI script & pause & exit /b 1)
powershell.exe -NoProfile -STA -File "%GUI%"
if errorlevel 1 pause
endlocal
