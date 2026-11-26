<#
.SYNOPSIS
    Install project-level skills from the repository manifest using --copy.
.EXAMPLE
    .\scripts\install-project-skills.ps1 -ProjectPath "D:\Projects\MarketingSite" -Skills design-taste-frontend -DryRun
    .\scripts\install-project-skills.ps1 -ProjectPath "D:\Projects\MarketingSite" -SkillsCsv "design-taste-frontend" -AgentsCsv "opencode,codex"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectPath,
    [string[]]$Skills = @(),
    [string]$SkillsCsv = "",
    [string]$ManifestPath = "",
    [string[]]$Agents = @(),
    [string]$AgentsCsv = "",
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Resolve the manifest after parameter binding. Do not reference $PSScriptRoot
# in a param() default expression: it can be empty during parameter binding
# in some Windows PowerShell invocation contexts.
if ([string]::IsNullOrWhiteSpace($ManifestPath)) {
    $CurrentScriptPath = $PSCommandPath
    if ([string]::IsNullOrWhiteSpace($CurrentScriptPath)) {
        $CurrentScriptPath = $MyInvocation.MyCommand.Path
    }
    if ([string]::IsNullOrWhiteSpace($CurrentScriptPath)) {
        throw "Tidak dapat menentukan lokasi file script. Berikan -ManifestPath secara eksplisit."
    }
    $CurrentScriptDirectory = Split-Path -Parent -Path $CurrentScriptPath
    $ManifestPath = Join-Path -Path $CurrentScriptDirectory -ChildPath "..\manifest\skills-manifest.csv"
}
$ManifestPath = [System.IO.Path]::GetFullPath($ManifestPath)

$KnownAgents = @("opencode", "claude-code", "codex", "antigravity", "hermes-agent", "zcode")

if (-not (Test-Path -LiteralPath $ProjectPath -PathType Container)) {
    throw "Folder project tidak ditemukan: $ProjectPath"
}
if (-not (Test-Path -LiteralPath $ManifestPath -PathType Leaf)) {
    throw "Manifest tidak ditemukan: $ManifestPath"
}
if (-not (Get-Command npx.cmd -ErrorAction SilentlyContinue)) {
    throw "npx.cmd tidak ditemukan. Install Node.js (termasuk npm) lalu buka terminal baru."
}

$RequestedSkills = @($Skills)
if (-not [string]::IsNullOrWhiteSpace($SkillsCsv)) {
    $RequestedSkills += @($SkillsCsv -split '[,;]' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
}
$RequestedSkills = @($RequestedSkills | ForEach-Object { $_.Trim() } | Where-Object { $_ } | Select-Object -Unique)
if ($RequestedSkills.Count -eq 0) {
    throw "Tentukan minimal satu skill melalui -Skills atau -SkillsCsv."
}

$EffectiveAgents = @()
if (-not [string]::IsNullOrWhiteSpace($AgentsCsv)) {
    $EffectiveAgents = @($AgentsCsv -split '[,;]' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
}
elseif ($Agents -and $Agents.Count -gt 0) {
    $EffectiveAgents = @($Agents | ForEach-Object { $_.Trim() } | Where-Object { $_ })
}
if ($EffectiveAgents.Count -gt 0) {
    $UnknownAgents = @($EffectiveAgents | Where-Object { $KnownAgents -notcontains $_ })
    if ($UnknownAgents.Count -gt 0) {
        throw "Agent tidak dikenal: $($UnknownAgents -join ', '). Valid: $($KnownAgents -join ', ')"
    }
    $EffectiveAgents = @($EffectiveAgents | Select-Object -Unique)
}

$Rows = @(Import-Csv -LiteralPath $ManifestPath)
$Selected = @()
foreach ($SkillName in $RequestedSkills) {
    $Match = $Rows | Where-Object { $_.skill -eq $SkillName } | Select-Object -First 1
    if (-not $Match) {
        throw "Skill '$SkillName' tidak terdaftar di $ManifestPath"
    }
    $Selected += $Match
}

$InvalidRows = @($Selected | Where-Object {
    [string]::IsNullOrWhiteSpace($_.source) -or $_.source -match '<.*>' -or $_.ref -match '<.*>'
})
if ($InvalidRows.Count -gt 0) {
    Write-Host "[ERROR] Manifest memiliki source/ref yang belum valid:" -ForegroundColor Red
    $InvalidRows | Select-Object skill, source, ref | Format-Table -AutoSize
    exit 1
}
$Unpinned = @($Selected | Where-Object { [string]::IsNullOrWhiteSpace([string]$_.ref) })
if ($Unpinned.Count -gt 0) {
    Write-Warning "Skill project berikut memakai default branch (ref kosong): $($Unpinned.skill -join ', '). Pin ref untuk hasil reproducible."
}

Push-Location -LiteralPath $ProjectPath
try {
    $UsedHermes = $false
    foreach ($Row in $Selected) {
        $TargetAgents = if ($EffectiveAgents.Count -gt 0) {
            $EffectiveAgents
        }
        else {
            @($Row.agents -split ';' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
        }
        if ($TargetAgents -contains "hermes-agent") { $UsedHermes = $true }

        $SourceSpec = [string]$Row.source
        if (-not [string]::IsNullOrWhiteSpace([string]$Row.ref)) {
            $SourceSpec = "$($Row.source)@$($Row.ref)"
        }
        $ArgsList = @("--yes", "skills", "add", $SourceSpec, "--skill", [string]$Row.skill)
        foreach ($Agent in $TargetAgents) {
            $ArgsList += @("--agent", $Agent)
        }
        $ArgsList += @("--copy", "--yes")

        $CmdDisplay = "npx.cmd " + (($ArgsList | ForEach-Object { if ($_ -match '\s') { '"' + $_ + '"' } else { $_ } }) -join ' ')
        if ($DryRun) {
            Write-Host "[DRY-RUN] ($ProjectPath) $CmdDisplay" -ForegroundColor Cyan
            continue
        }
        Write-Host "[INSTALL PROJECT] $($Row.skill) -> $ProjectPath" -ForegroundColor Yellow
        & npx.cmd @ArgsList
        $ExitCode = $LASTEXITCODE
        if ($ExitCode -ne 0) {
            throw "Gagal memasang $($Row.skill) (Skills CLI exit code $ExitCode)"
        }
        Write-Host "[OK] $($Row.skill) terpasang dengan --copy" -ForegroundColor Green
    }
    if ($UsedHermes -and -not $DryRun) {
        Write-Host "`n[REMINDER] Jika memakai Hermes Agent pada repo ini, jalankan: hermes skills trust" -ForegroundColor Yellow
    }
}
finally {
    Pop-Location
}
