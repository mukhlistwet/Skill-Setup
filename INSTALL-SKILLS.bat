@echo off
setlocal EnableExtensions
pushd "%~dp0"
title Skill Setup - Global Installer

 echo.
echo ================================================================
echo       SKILL SETUP - GLOBAL SKILLS INSTALLER
echo ================================================================
echo Repository : %CD%
echo.

set "MANIFEST_PATH=%~dp0manifest\skills-manifest.csv"

if not exist "%MANIFEST_PATH%" (
  echo [ERROR] manifest\skills-manifest.csv tidak ditemukan.
  pause
  popd
  exit /b 1
)

if not exist "scripts\install-global-skills.ps1" (
  echo [ERROR] scripts\install-global-skills.ps1 tidak ditemukan.
  echo Extract patch ini ke root repository Skill-Setup.
  pause
  popd
  exit /b 1
)

where node >nul 2>nul
if errorlevel 1 (
  echo [ERROR] Node.js tidak ditemukan. Install Node.js terlebih dahulu.
  pause
  popd
  exit /b 1
)
where npx.cmd >nul 2>nul
if errorlevel 1 (
  echo [ERROR] npx.cmd tidak ditemukan. Periksa instalasi Node.js/npm dan PATH.
  pause
  popd
  exit /b 1
)
where git >nul 2>nul
if errorlevel 1 (
  echo [WARNING] Git tidak ditemukan. Skills CLI/source retrieval mungkin gagal.
) else (
  for /f "delims=" %%V in ('node --version') do echo Node.js: %%V
  for /f "delims=" %%V in ('git --version') do echo Git    : %%V
)

echo.
echo PILIH TARGET CODING AGENT
echo [1] OpenCode + Codex + Antigravity (recommended default)
echo [2] OpenCode only
echo [3] Claude Code only
echo [4] Codex only
echo [5] Antigravity only
echo [6] Hermes Agent only
echo [7] ZCode only
echo [8] All supported agents
echo [9] Custom agent list (comma-separated)
echo.
choice /c 123456789 /n /m "Pilih [1-9]: "
set "AGENT_CHOICE=%ERRORLEVEL%"
if "%AGENT_CHOICE%"=="1" set "AGENTS_CSV=opencode,codex,antigravity"
if "%AGENT_CHOICE%"=="2" set "AGENTS_CSV=opencode"
if "%AGENT_CHOICE%"=="3" set "AGENTS_CSV=claude-code"
if "%AGENT_CHOICE%"=="4" set "AGENTS_CSV=codex"
if "%AGENT_CHOICE%"=="5" set "AGENTS_CSV=antigravity"
if "%AGENT_CHOICE%"=="6" set "AGENTS_CSV=hermes-agent"
if "%AGENT_CHOICE%"=="7" set "AGENTS_CSV=zcode"
if "%AGENT_CHOICE%"=="8" set "AGENTS_CSV=opencode,claude-code,codex,antigravity,hermes-agent,zcode"
if "%AGENT_CHOICE%"=="9" goto :CUSTOM_AGENTS
goto :CONDITIONAL

:CUSTOM_AGENTS
set /p "AGENTS_CSV=Masukkan agent IDs dipisahkan koma (contoh opencode,codex): "
if "%AGENTS_CSV%"=="" (
  echo [ERROR] Daftar agent kosong.
  pause
  popd
  exit /b 1
)

:CONDITIONAL
set "CONDITIONAL_CSV="
echo.
echo CONDITIONAL SKILL
echo [1] Core 11 saja (default)
echo [2] Core 11 + vercel-react-best-practices (React/Next.js)
choice /c 12 /n /m "Pilih [1-2]: "
if errorlevel 2 set "CONDITIONAL_CSV=vercel-react-best-practices"

echo.
echo Target agents : %AGENTS_CSV%
if not "%CONDITIONAL_CSV%"=="" echo Conditional  : %CONDITIONAL_CSV%
echo.
echo === DRY-RUN / PREVIEW ===
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\install-global-skills.ps1" -ManifestPath "%MANIFEST_PATH%" -AgentsCsv "%AGENTS_CSV%" -IncludeConditionalSkillsCsv "%CONDITIONAL_CSV%" -DryRun
if errorlevel 1 (
  echo.
  echo [ERROR] Dry-run gagal. Tidak ada skill yang di-install.
  pause
  popd
  exit /b 1
)

echo.
choice /c YN /n /m "Lanjutkan install sesuai preview? [Y/N]: "
if errorlevel 2 (
  echo Dibatalkan. Tidak ada perubahan.
  popd
  exit /b 0
)

echo.
echo === INSTALL ===
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\install-global-skills.ps1" -ManifestPath "%MANIFEST_PATH%" -AgentsCsv "%AGENTS_CSV%" -IncludeConditionalSkillsCsv "%CONDITIONAL_CSV%"
if errorlevel 1 (
  echo.
  echo [ERROR] Ada proses instalasi yang gagal. Periksa log di atas.
  pause
  popd
  exit /b 1
)

echo.
echo === VERIFY ===
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\verify-install.ps1" -ManifestPath "%MANIFEST_PATH%"
echo.
echo Selesai. Verifikasi lagi dari CLI/UI native setiap agent.
pause
popd
exit /b 0
