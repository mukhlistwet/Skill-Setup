<#
.SYNOPSIS
    Install global skills from manifest/skills-manifest.csv.
.DESCRIPTION
    Installs scope=global skills and only the explicitly selected conditional skills.
    A blank ref is allowed and means the source repository's default branch is used.
    This is convenient but not reproducible; pin a tag or full commit SHA in the manifest for strict repeatability.
.EXAMPLE
    .\scripts\install-global-skills.ps1 -DryRun
    .\scripts\install-global-skills.ps1 -Agents opencode,codex,antigravity
    .\scripts\install-global-skills.ps1 -AgentsCsv "opencode,codex" -IncludeConditionalSkillsCsv "vercel-react-best-practices"
#>
[CmdletBinding()]
param(
    [string]$ManifestPath = (Join-Path $PSScriptRoot "..\manifest\skills-manifest.csv"),
    [string[]]$Agents = @(),
    [string]$AgentsCsv = "",
    [string[]]$IncludeConditionalSkills = @(),
    [string]$IncludeConditionalSkillsCsv = "",
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$KnownAgents = @("opencode", "claude-code", "codex", "antigravity", "hermes-agent", "zcode")
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

$Conditional = @($IncludeConditionalSkills)
if (-not [string]::IsNullOrWhiteSpace($IncludeConditionalSkillsCsv)) {
    $Conditional += @($IncludeConditionalSkillsCsv -split '[,;]' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
}
$Conditional = @($Conditional | Select-Object -Unique)

if (-not (Test-Path -LiteralPath $ManifestPath -PathType Leaf)) {
    throw "Manifest tidak ditemukan: $ManifestPath"
}
if (-not (Get-Command npx.cmd -ErrorAction SilentlyContinue)) {
    throw "npx.cmd tidak ditemukan. Install Node.js (termasuk npm) lalu buka terminal baru."
}

$Rows = @(Import-Csv -LiteralPath $ManifestPath)
$Selected = @($Rows | Where-Object {
    ($_.scope -eq "global") -or
    ($_.scope -eq "conditional" -and $Conditional -contains $_.skill)
})
if ($Selected.Count -eq 0) {
    throw "Tidak ada skill global/conditional yang dipilih di manifest."
}

$InvalidRows = @($Selected | Where-Object {
    [string]::IsNullOrWhiteSpace($_.skill) -or
    [string]::IsNullOrWhiteSpace($_.source) -or
    $_.source -match '<.*>' -or
    $_.ref -match '<.*>'
})
if ($InvalidRows.Count -gt 0) {
    Write-Host "[ERROR] Manifest berisi skill/source/ref yang belum valid:" -ForegroundColor Red
    $InvalidRows | Select-Object skill, source, ref | Format-Table -AutoSize
    exit 1
}

$Unpinned = @($Selected | Where-Object { [string]::IsNullOrWhiteSpace($_.ref) })
if ($Unpinned.Count -gt 0) {
    Write-Warning "$($Unpinned.Count) skill memakai default branch (ref kosong). Isi kolom ref dengan tag/full commit SHA untuk instalasi yang reproducible."
}

$Results = [System.Collections.Generic.List[object]]::new()
foreach ($Row in $Selected) {
    $TargetAgents = if ($EffectiveAgents.Count -gt 0) {
        $EffectiveAgents
    }
    else {
        @($Row.agents -split ';' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
    }

    $SourceSpec = [string]$Row.source
    if (-not [string]::IsNullOrWhiteSpace([string]$Row.ref)) {
        $SourceSpec = "$($Row.source)@$($Row.ref)"
    }

    $ArgsList = @("--yes", "skills", "add", $SourceSpec, "--skill", [string]$Row.skill, "--global")
    foreach ($Agent in $TargetAgents) {
        $ArgsList += @("--agent", $Agent)
    }
    $ArgsList += "--yes"
    $CmdDisplay = "npx.cmd " + (($ArgsList | ForEach-Object { if ($_ -match '\s') { '"' + $_ + '"' } else { $_ } }) -join ' ')

    if ($DryRun) {
        Write-Host "[DRY-RUN] $CmdDisplay" -ForegroundColor Cyan
        $Results.Add([PSCustomObject]@{ Skill = $Row.skill; Status = "DRY-RUN"; Target = ($TargetAgents -join ",") })
        continue
    }

    Write-Host "[INSTALL] $($Row.skill) -> $($TargetAgents -join ', ')" -ForegroundColor Yellow
    try {
        & npx.cmd @ArgsList
        $ExitCode = $LASTEXITCODE
        if ($ExitCode -ne 0) {
            throw "Skills CLI exit code $ExitCode"
        }
        Write-Host "[OK] $($Row.skill)" -ForegroundColor Green
        $Results.Add([PSCustomObject]@{ Skill = $Row.skill; Status = "OK"; Target = ($TargetAgents -join ",") })
    }
    catch {
        Write-Host "[FAIL] $($Row.skill): $($_.Exception.Message)" -ForegroundColor Red
        $Results.Add([PSCustomObject]@{ Skill = $Row.skill; Status = "FAILED"; Target = ($TargetAgents -join ",") })
    }
}

Write-Host "`n=== Ringkasan Instalasi Global ===" -ForegroundColor Cyan
$Results | Format-Table -AutoSize
if (@($Results | Where-Object { $_.Status -eq "FAILED" }).Count -gt 0) {
    exit 1
}
