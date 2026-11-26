<#
.SYNOPSIS
    Install project-level skills dari manifest/skills-manifest.csv menggunakan --copy.
.EXAMPLE
    .\scripts\install-project-skills.ps1 -ProjectPath "D:\Projects\MarketingSite" -Skills design-taste-frontend -DryRun
    .\scripts\install-project-skills.ps1 -ProjectPath "D:\Projects\MarketingSite" -Skills design-taste-frontend -Agents opencode,claude-code,codex
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectPath,

    [Parameter(Mandatory = $true)]
    [string[]]$Skills,

    [string]$ManifestPath = (Join-Path $PSScriptRoot "..\manifest\skills-manifest.csv"),
    [string[]]$Agents = @(),
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $ProjectPath -PathType Container)) {
    throw "Folder project tidak ditemukan: $ProjectPath"
}
if (-not (Test-Path -LiteralPath $ManifestPath -PathType Leaf)) {
    throw "Manifest tidak ditemukan: $ManifestPath"
}

$Rows = Import-Csv -LiteralPath $ManifestPath
$Selected = @()

foreach ($SkillName in $Skills) {
    $Match = $Rows | Where-Object { $_.skill -eq $SkillName } | Select-Object -First 1
    if (-not $Match) {
        throw "Skill '$SkillName' tidak terdaftar di $ManifestPath"
    }
    $Selected += $Match
}

$InvalidRows = $Selected | Where-Object {
    $_.source -match '<.*>' -or [string]::IsNullOrWhiteSpace($_.source) -or
    $_.ref -match '<.*>' -or [string]::IsNullOrWhiteSpace($_.ref)
}

if ($InvalidRows) {
    Write-Host "[ERROR] Manifest masih berisi placeholder pada skill berikut:" -ForegroundColor Red
    $InvalidRows | Select-Object skill, source, ref | Format-Table -AutoSize
    Write-Host "Pin commit/tag pada manifest\skills-manifest.csv sebelum memasang ke project." -ForegroundColor Yellow
    exit 1
}

Push-Location -LiteralPath $ProjectPath
try {
    $UsedHermes = $false
    foreach ($Row in $Selected) {
        $TargetAgents = if ($Agents.Count -gt 0) {
            $Agents
        } else {
            ($Row.agents -split ';') | ForEach-Object { $_.Trim() } | Where-Object { $_ }
        }

        if ($TargetAgents -contains "hermes-agent") {
            $UsedHermes = $true
        }

        $SourceSpec = "$($Row.source)@$($Row.ref)"
        $ArgsList = @("skills", "add", $SourceSpec, "--skill", $Row.skill)
        foreach ($Agent in $TargetAgents) {
            $ArgsList += @("--agent", $Agent)
        }
        $ArgsList += @("--copy", "--yes")

        $CmdDisplay = "npx.cmd " + ($ArgsList -join " ")
        if ($DryRun) {
            Write-Host "[DRY-RUN] ($ProjectPath) $CmdDisplay" -ForegroundColor Cyan
            continue
        }

        Write-Host "[INSTALL PROJECT] $($Row.skill) -> $ProjectPath" -ForegroundColor Yellow
        & npx.cmd @ArgsList
        if ($LASTEXITCODE -ne 0) {
            throw "Gagal memasang $($Row.skill) (exit code $LASTEXITCODE)"
        }
        Write-Host "[OK] $($Row.skill) terpasang dengan --copy" -ForegroundColor Green
    }

    if ($UsedHermes -and -not $DryRun) {
        Write-Host ""
        Write-Host "[REMINDER] Jika memakai Hermes Agent pada repo ini, jalankan: hermes skills trust" -ForegroundColor Yellow
    }
}
finally {
    Pop-Location
}
