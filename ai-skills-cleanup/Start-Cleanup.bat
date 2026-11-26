@echo off
setlocal
cd /d "%~dp0"
echo Starting AI Agent Skills Cleanup...
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Reset-AISkills.ps1"
echo.
echo Script finished. Review the output above.
pause
endlocal
