<#
.SYNOPSIS
    Restore folder global skills dari hasil backup-global.ps1 secara aman.
.DESCRIPTION
    Membuat pre-rollback safety snapshot terlebih dahulu sebelum memulihkan direktori
    dari BackupPath. Tidak menyentuh file built-in aplikasi atau konfigurasi lain.
.EXAMPLE
    .\scripts\rollback.ps1 -BackupPath "$HOME\AI-Skill-Backup-20261126-180000" -DryRun
    .\scripts\rollback.ps1 -BackupPath "$HOME\AI-Skill-Backup-20261126-180000"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$BackupPath,

    [switch]$DryRun,
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $BackupPath -PathType Container)) {
    throw "Folder backup tidak ditemukan: $BackupPath"
}

$Targets = @{
    "codex"        = (Join-Path $HOME ".agents\skills")
    "claude-code"  = (Join-Path $HOME ".claude\skills")
    "opencode"     = (Join-Path $HOME ".config\opencode\skills")
    "antigravity"  = (Join-Path $HOME ".gemini\config\skills")
    "hermes-agent" = (Join-Path $HOME ".hermes\skills")
    "zcode"        = (Join-Path $HOME ".zcode\skills")
}

$Planned = [System.Collections.Generic.List[object]]::new()
foreach ($Key in $Targets.Keys) {
    $Src = Join-Path $BackupPath $Key
    if (Test-Path -LiteralPath $Src -PathType Container) {
        $Planned.Add([PSCustomObject]@{
            Agent       = $Key
            Source      = $Src
            Destination = $Targets[$Key]
        })
    }
}

if ($Planned.Count -eq 0) {
    throw "Tidak ada subfolder agent yang dikenali di dalam $BackupPath"
}

Write-Host "=== Rencana Rollback ===" -ForegroundColor Cyan
$Planned | Format-Table -AutoSize

if ($DryRun) {
    Write-Host "[DRY-RUN] Tidak ada perubahan yang ditulis ke disk." -ForegroundColor Cyan
    exit 0
}

if (-not $Force) {
    $Answer = Read-Host "Lanjutkan rollback? Ketik YES untuk konfirmasi"
    if ($Answer -ne "YES") {
        Write-Host "Rollback dibatalkan." -ForegroundColor Yellow
        exit 0
    }
}

# Safety snapshot sebelum rollback
$BackupScript = Join-Path $PSScriptRoot "backup-global.ps1"
if (Test-Path -LiteralPath $BackupScript) {
    Write-Host "Membuat pre-rollback safety snapshot..." -ForegroundColor Yellow
    & $BackupScript
}

foreach ($Item in $Planned) {
    $DestParent = Split-Path -Path $Item.Destination -Parent
    if (-not (Test-Path -LiteralPath $DestParent)) {
        New-Item -ItemType Directory -Force -Path $DestParent | Out-Null
    }
    if (Test-Path -LiteralPath $Item.Destination) {
        Remove-Item -LiteralPath $Item.Destination -Recurse -Force
    }
    Copy-Item -LiteralPath $Item.Source -Destination $Item.Destination -Recurse -Force
    Write-Host "[RESTORED] $($Item.Agent) -> $($Item.Destination)" -ForegroundColor Green
}

Write-Host ""
Write-Host "Rollback selesai. Jalankan .\scripts\verify-install.ps1 untuk verifikasi." -ForegroundColor Cyan
