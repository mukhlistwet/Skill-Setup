@echo off
setlocal
cd /d "%~dp0"
echo Starting read-only skills audit...
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Reset-AISkills.ps1" -Mode Audit
echo.
echo Audit finished. No files were deleted.
pause
endlocal
