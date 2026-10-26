@echo off
setlocal
cd /d "%~dp0"
title Terminal Tools - GUI Launcher
if not exist "%~dp0scripts\Troubleshooter-GUI.ps1" (
 echo ERROR: GUI script not found.
 pause
 exit /b 1
)
powershell.exe -NoProfile -STA -ExecutionPolicy Bypass -File "%~dp0scripts\Troubleshooter-GUI.ps1"
if errorlevel 1 (
 echo.
 echo The GUI could not start. Check the error above.
 pause
)
