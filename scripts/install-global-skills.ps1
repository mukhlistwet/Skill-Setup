<#
.SYNOPSIS
    Install global core skills dari manifest/skills-manifest.csv secara idempotent.
.DESCRIPTION
    Membaca manifest, memvalidasi bahwa tidak ada placeholder source/ref, dan memasang
    skill dengan scope 'global' (serta conditional skills tertentu jika diminta).
    Tidak pernah menghapus skill lain di luar manifest.
.EXAMPLE
    .\scripts\install-global-skills.ps1 -DryRun
    .\scripts\install-global-skills.ps1 -Agents opencode,claude-code,codex,antigravity
    .\scripts\install-global-skills.ps1 -IncludeConditionalSkills vercel-react-best-practices
#>
[CmdletBinding()]
param(
    [string]$ManifestPath = (Join-Path $PSScriptRoot "..\manifest\skills-manifest.csv"),
    [string[]]$Agents = @(),
    [string[]]$IncludeConditionalSkills = @(),
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $ManifestPath)) {
    throw "Manifest tidak ditemukan: $ManifestPath"
}

$Rows = Import-Csv -LiteralPath $ManifestPath
$Selected = $Rows | Where-Object {
    ($_.scope -eq "global") -or
    ($_.scope -eq "conditional" -and ($IncludeConditionalSkills -contains $_.skill))
}

if (-not $Selected) {
    throw "Tidak ada skill dengan scope 'global' yang ditemukan pada manifest."
}

# Fail-fast jika masih ada placeholder
$InvalidRows = $Selected | Where-Object {
    $_.source -match '<.*>' -or [string]::IsNullOrWhiteSpace($_.source) -or
    $_.ref -match '<.*>' -or [string]::IsNullOrWhiteSpace($_.ref)
}

if ($InvalidRows) {
    Write-Host "[ERROR] Manifest masih berisi placeholder pada skill berikut:" -ForegroundColor Red
    $InvalidRows | Select-Object skill, source, ref | Format-Table -AutoSize
    Write-Host "Lengkapi source URL dan tag/commit SHA di manifest\skills-manifest.csv sebelum instalasi." -ForegroundColor Yellow
    Write-Host "Lihat panduan pemulihan source di runbooks\03-MAINTENANCE.md." -ForegroundColor Yellow
    exit 1
}

$Results = [System.Collections.Generic.List[object]]::new()

foreach ($Row in $Selected) {
    $TargetAgents = if ($Agents.Count -gt 0) {
        $Agents
    } else {
        ($Row.agents -split ';') | ForEach-Object { $_.Trim() } | Where-Object { $_ }
    }

    $SourceSpec = "$($Row.source)@$($Row.ref)"
    $ArgsList = @("skills", "add", $SourceSpec, "--skill", $Row.skill, "--global")
    foreach ($Agent in $TargetAgents) {
        $ArgsList += @("--agent", $Agent)
    }
    $ArgsList += "--yes"

    $CmdDisplay = "npx.cmd " + ($ArgsList -join " ")
    if ($DryRun) {
        Write-Host "[DRY-RUN] $CmdDisplay" -ForegroundColor Cyan
        $Results.Add([PSCustomObject]@{ Skill = $Row.skill; Status = "DRY-RUN"; Target = ($TargetAgents -join ",") })
        continue
    }

    Write-Host "[INSTALL] $($Row.skill) -> $($TargetAgents -join ', ')" -ForegroundColor Yellow
    try {
        & npx.cmd @ArgsList
        if ($LASTEXITCODE -ne 0) {
            throw "Exit code $LASTEXITCODE"
        }
        Write-Host "[OK] $($Row.skill)" -ForegroundColor Green
        $Results.Add([PSCustomObject]@{ Skill = $Row.skill; Status = "OK"; Target = ($TargetAgents -join ",") })
    }
    catch {
        Write-Host "[FAIL] $($Row.skill): $($_.Exception.Message)" -ForegroundColor Red
        $Results.Add([PSCustomObject]@{ Skill = $Row.skill; Status = "FAILED"; Target = ($TargetAgents -join ",") })
    }
}

Write-Host ""
Write-Host "=== Ringkasan Instalasi Global ===" -ForegroundColor Cyan
$Results | Format-Table -AutoSize

if ($Results | Where-Object { $_.Status -eq "FAILED" }) {
    exit 1
}
