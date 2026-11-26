@echo off
setlocal EnableExtensions
pushd "%~dp0"
title Skill Setup - Project Design Skill Installer

 echo.
echo ================================================================
echo       PROJECT-LEVEL DESIGN SKILL INSTALLER
echo ================================================================
echo Skill: design-taste-frontend (installed with --copy)
echo.
set "MANIFEST_PATH=%~dp0manifest\skills-manifest.csv"

if not exist "%MANIFEST_PATH%" (
  echo [ERROR] manifest\skills-manifest.csv tidak ditemukan.
  pause
  popd
  exit /b 1
)
if not exist "scripts\install-project-skills.ps1" (
  echo [ERROR] scripts\install-project-skills.ps1 tidak ditemukan.
  pause
  popd
  exit /b 1
)
where npx.cmd >nul 2>nul
if errorlevel 1 (
  echo [ERROR] npx.cmd tidak ditemukan. Install Node.js/npm dahulu.
  pause
  popd
  exit /b 1
)

set /p "PROJECT_PATH=Masukkan full path root project (contoh D:\Projects\MyApp): "
if "%PROJECT_PATH%"=="" (
  echo [ERROR] Project path kosong.
  pause
  popd
  exit /b 1
)
if not exist "%PROJECT_PATH%\" (
  echo [ERROR] Folder project tidak ditemukan: %PROJECT_PATH%
  pause
  popd
  exit /b 1
)
set "AGENTS_CSV=opencode,codex,antigravity"
set /p "AGENTS_INPUT=Target agent CSV [%AGENTS_CSV%]: "
if not "%AGENTS_INPUT%"=="" set "AGENTS_CSV=%AGENTS_INPUT%"

echo.
echo Project : %PROJECT_PATH%
echo Agents  : %AGENTS_CSV%
echo.
echo === DRY-RUN / PREVIEW ===
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\install-project-skills.ps1" -ManifestPath "%MANIFEST_PATH%" -ProjectPath "%PROJECT_PATH%" -SkillsCsv "design-taste-frontend" -AgentsCsv "%AGENTS_CSV%" -DryRun
if errorlevel 1 (
  echo [ERROR] Dry-run gagal. Tidak ada perubahan.
  pause
  popd
  exit /b 1
)
choice /c YN /n /m "Lanjutkan install project-level? [Y/N]: "
if errorlevel 2 (
  echo Dibatalkan.
  popd
  exit /b 0
)

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\install-project-skills.ps1" -ManifestPath "%MANIFEST_PATH%" -ProjectPath "%PROJECT_PATH%" -SkillsCsv "design-taste-frontend" -AgentsCsv "%AGENTS_CSV%"
if errorlevel 1 (
  echo [ERROR] Instalasi gagal. Periksa output di atas.
  pause
  popd
  exit /b 1
)
echo.
echo Selesai. Periksa perubahan project dan commit skill folder yang dihasilkan jika memang diinginkan.
pause
popd
exit /b 0
