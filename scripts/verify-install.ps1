<#
.SYNOPSIS
    Verifikasi prasyarat Windows, manifest, global skills, dan (opsional) konfigurasi project.
.EXAMPLE
    .\scripts\verify-install.ps1
    .\scripts\verify-install.ps1 -ProjectPath "D:\Projects\MyApp"
#>
[CmdletBinding()]
param(
    [string]$ProjectPath = "",
    [string]$ManifestPath = (Join-Path $PSScriptRoot "..\manifest\skills-manifest.csv")
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"
function Test-CommandVersion {
    param([string]$Command, [string[]]$ArgsList)
    try {
        $Out = & $Command @ArgsList 2>&1 | Select-Object -First 1
        return [string]$Out
    }
    catch { return $null }
}

Write-Host "=== 1. Prerequisites Check ===" -ForegroundColor Cyan
$NodeVer = Test-CommandVersion -Command "node" -ArgsList @("--version")
$NpmVer  = Test-CommandVersion -Command "npm"  -ArgsList @("--version")
$GitVer  = Test-CommandVersion -Command "git"  -ArgsList @("--version")
Write-Host "Node.js : $(if ($NodeVer) { $NodeVer } else { 'MISSING' })"
Write-Host "npm     : $(if ($NpmVer)  { $NpmVer  } else { 'MISSING' })"
Write-Host "Git     : $(if ($GitVer)  { $GitVer  } else { 'MISSING' })"
if ($NodeVer -match '^v(\d+)\.(\d+)\.(\d+)') {
    $Parsed = [version]"$($Matches[1]).$($Matches[2]).$($Matches[3])"
    if ($Parsed -lt [version]"22.20.0") {
        Write-Warning "Node.js < 22.20.0: di bawah minimum yang didokumentasikan Skills CLI."
    }
    elseif ($Parsed -lt [version]"24.15.0") {
        Write-Warning "Node.js memenuhi minimum Skills CLI, tetapi di bawah syarat Context Mode Engine 24.15.0+."
    }
    else { Write-Host "[OK] Versi Node.js memenuhi syarat Skills CLI & Context Mode." -ForegroundColor Green }
}

Write-Host "`n=== 2. Manifest Readiness ===" -ForegroundColor Cyan
if (Test-Path -LiteralPath $ManifestPath -PathType Leaf) {
    $Rows = @(Import-Csv -LiteralPath $ManifestPath)
    $Pending = @($Rows | Where-Object { $_.source -match '<.*>' -or [string]::IsNullOrWhiteSpace($_.source) -or $_.ref -match '<.*>' })
    $Unpinned = @($Rows | Where-Object { [string]::IsNullOrWhiteSpace([string]$_.ref) })
    Write-Host "Total skill di manifest : $($Rows.Count)"
    if ($Pending.Count -gt 0) {
        Write-Warning "$($Pending.Count) skill masih memiliki source/ref placeholder atau kosong secara tidak valid."
        $Pending | Select-Object skill, source, ref | Format-Table -AutoSize
    }
    else { Write-Host "[OK] Tidak ada placeholder source/ref." -ForegroundColor Green }
    if ($Unpinned.Count -gt 0) {
        Write-Warning "$($Unpinned.Count) skill belum di-pin ke tag/commit. Instalasi mengambil default branch upstream."
        $Unpinned | Select-Object skill, source | Format-Table -AutoSize
    }
}
else { Write-Warning "Manifest tidak ditemukan: $ManifestPath" }

Write-Host "`n=== 3. Global Skill Directories ===" -ForegroundColor Cyan
$AgentDirs = @(
    @{ Agent = "opencode"; Path = (Join-Path $HOME ".config\opencode\skills") },
    @{ Agent = "claude-code"; Path = (Join-Path $HOME ".claude\skills") },
    @{ Agent = "codex"; Path = (Join-Path $HOME ".agents\skills") },
    @{ Agent = "antigravity"; Path = (Join-Path $HOME ".gemini\config\skills") },
    @{ Agent = "hermes-agent"; Path = (Join-Path $HOME ".hermes\skills") },
    @{ Agent = "zcode"; Path = (Join-Path $HOME ".zcode\skills") }
)
$DirReport = foreach ($Entry in $AgentDirs) {
    $Exists = Test-Path -LiteralPath $Entry.Path
    $Count = if ($Exists) { @(Get-ChildItem -LiteralPath $Entry.Path -Directory -ErrorAction SilentlyContinue).Count } else { 0 }
    [PSCustomObject]@{ Agent = $Entry.Agent; Exists = $Exists; SkillCount = $Count; Path = $Entry.Path }
}
$DirReport | Format-Table -AutoSize

Write-Host "=== 4. Skills CLI Global Inventory ===" -ForegroundColor Cyan
if (Get-Command npx.cmd -ErrorAction SilentlyContinue) {
    & npx.cmd skills ls -g
    if ($LASTEXITCODE -ne 0) { Write-Warning "'npx.cmd skills ls -g' mengembalikan exit code $LASTEXITCODE." }
}
else { Write-Warning "npx.cmd tidak ditemukan; inventory global dilewati." }

if (-not [string]::IsNullOrWhiteSpace($ProjectPath)) {
    Write-Host "`n=== 5. Project Verification: $ProjectPath ===" -ForegroundColor Cyan
    if (-not (Test-Path -LiteralPath $ProjectPath -PathType Container)) {
        Write-Warning "Folder project tidak ditemukan: $ProjectPath"
    }
    else {
        $HasAgentsMd = Test-Path -LiteralPath (Join-Path $ProjectPath "AGENTS.md")
        $HasDesignMd = Test-Path -LiteralPath (Join-Path $ProjectPath "DESIGN.md")
        $HasLock = Test-Path -LiteralPath (Join-Path $ProjectPath "skills-lock.json")
        Write-Host "AGENTS.md        : $HasAgentsMd"
        Write-Host "DESIGN.md        : $HasDesignMd"
        Write-Host "skills-lock.json : $HasLock"
        $ProjSkillRoots = @(".agents\skills", ".claude\skills", ".hermes\skills", ".zcode\skills")
        $Seen = @{}
        foreach ($Rel in $ProjSkillRoots) {
            $Full = Join-Path $ProjectPath $Rel
            if (Test-Path -LiteralPath $Full) {
                Get-ChildItem -LiteralPath $Full -Directory -ErrorAction SilentlyContinue | ForEach-Object {
                    if ($Seen.ContainsKey($_.Name)) { $Seen[$_.Name] += ", $Rel" } else { $Seen[$_.Name] = $Rel }
                }
            }
        }
        $Duplicates = @($Seen.GetEnumerator() | Where-Object { $_.Value -match ',' })
        if ($Duplicates.Count -gt 0) {
            Write-Warning "Terdeteksi potensi duplicate skill ID di project:"
            $Duplicates | ForEach-Object { Write-Host "  - $($_.Key): $($_.Value)" -ForegroundColor Yellow }
        }
        else { Write-Host "[OK] Tidak ada duplicate skill ID di direktori project." -ForegroundColor Green }
    }
}
Write-Host "`nCatatan: validasi direktori bukan bukti skill berhasil ter-load. Periksa juga dari UI/CLI native setiap coding-agent." -ForegroundColor DarkGray
