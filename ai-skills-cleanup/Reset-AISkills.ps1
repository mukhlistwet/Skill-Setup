<#
.SYNOPSIS
  Audit and safely remove common global or project-local AI Agent Skills folders.

.DESCRIPTION
  - Supports Windows PowerShell 5.1 and PowerShell 7+.
  - Audits known skill locations for OpenCode, Agent Skills/skills.sh,
    Claude Code, Codex, Antigravity, Cursor, Windsurf, Cline, Roo, Kilo,
    Continue, and Zencoder.
  - Supports custom paths and environment-variable-based config locations.
  - Creates a backup before deletion (unless backup fails, in which case it stops).
  - Deletes directory trees without traversing symlinks/junctions. Link metadata
    is recorded in the backup; linked targets are never recursively deleted.
  - Does NOT remove MCP servers, providers, API keys, agent/rules configuration,
    plugins, npm packages, caches, project dependencies, or application files.

.EXAMPLE
  .\Reset-AISkills.ps1
  .\Reset-AISkills.ps1 -Mode Audit
  .\Reset-AISkills.ps1 -Mode CleanupGlobal
  .\Reset-AISkills.ps1 -Mode CleanupProject -ProjectPath 'D:\Projects\my-app'
  .\Reset-AISkills.ps1 -Mode CleanupBoth -ProjectPath 'D:\Projects\my-app'
  .\Reset-AISkills.ps1 -Mode Audit -ExtraSkillPath 'D:\Shared\agent-skills'
#>

[CmdletBinding()]
param(
    [ValidateSet('Interactive', 'Audit', 'CleanupGlobal', 'CleanupProject', 'CleanupBoth')]
    [string]$Mode = 'Interactive',

    [string]$ProjectPath,

    [string[]]$ExtraSkillPath = @(),

    [string]$BackupRoot
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

function Write-Section {
    param([string]$Title)
    Write-Host ''
    Write-Host ('=' * 72) -ForegroundColor DarkGray
    Write-Host $Title -ForegroundColor Cyan
    Write-Host ('=' * 72) -ForegroundColor DarkGray
}

function Get-PropertyValue {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Name
    )
    $property = $Object.PSObject.Properties[$Name]
    if ($null -ne $property) { return $property.Value }
    return $null
}

function Test-IsReparsePoint {
    param([Parameter(Mandatory = $true)]$Item)
    return (($Item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0)
}

function Get-NormalizedPath {
    param([Parameter(Mandatory = $true)][string]$Path)
    $fullPath = [System.IO.Path]::GetFullPath($Path)
    $pathRoot = [System.IO.Path]::GetPathRoot($fullPath)
    if ($fullPath.Length -gt $pathRoot.Length) {
        return $fullPath.TrimEnd([char[]]@([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar))
    }
    return $fullPath
}

function New-Candidate {
    param(
        [string]$Path,
        [string]$Scope,
        [string]$Source
    )

    if ([string]::IsNullOrWhiteSpace($Path)) { return $null }
    if (-not (Test-Path -LiteralPath $Path)) { return $null }

    try {
        $item = Get-Item -LiteralPath $Path -Force -ErrorAction Stop
        if (-not $item.PSIsContainer) {
            Write-Warning "Dilewati karena bukan folder: $Path"
            return $null
        }

        return [pscustomobject]@{
            Path       = Get-NormalizedPath -Path $item.FullName
            Scope      = $Scope
            Source     = $Source
            IsLink     = (Test-IsReparsePoint -Item $item)
            Attributes = [string]$item.Attributes
        }
    }
    catch {
        Write-Warning "Tidak dapat memeriksa '$Path': $($_.Exception.Message)"
        return $null
    }
}

function Get-GlobalCandidates {
    param([string[]]$CustomPaths = @())

    $homePath = $HOME
    $paths = @(
        @{ Path = (Join-Path $homePath '.agents\skills'); Source = 'Agent Skills / skills.sh' },
        @{ Path = (Join-Path $homePath '.config\agents\skills'); Source = 'Agent Skills (alternate config)' },
        @{ Path = (Join-Path $homePath '.config\opencode\skills'); Source = 'OpenCode' },
        @{ Path = (Join-Path $homePath '.config\opencode\skill'); Source = 'OpenCode (legacy singular folder)' },
        @{ Path = (Join-Path $homePath '.claude\skills'); Source = 'Claude Code' },
        @{ Path = (Join-Path $homePath '.codex\skills'); Source = 'Codex' },
        @{ Path = (Join-Path $homePath '.gemini\antigravity\skills'); Source = 'Antigravity' },
        @{ Path = (Join-Path $homePath '.cursor\skills'); Source = 'Cursor' },
        @{ Path = (Join-Path $homePath '.windsurf\skills'); Source = 'Windsurf' },
        @{ Path = (Join-Path $homePath '.codeium\windsurf\skills'); Source = 'Windsurf (alternate location)' },
        @{ Path = (Join-Path $homePath '.cline\skills'); Source = 'Cline' },
        @{ Path = (Join-Path $homePath '.roo\skills'); Source = 'Roo Code' },
        @{ Path = (Join-Path $homePath '.kilocode\skills'); Source = 'Kilo Code' },
        @{ Path = (Join-Path $homePath '.continue\skills'); Source = 'Continue' },
        @{ Path = (Join-Path $homePath '.zencoder\skills'); Source = 'Zencoder' },
        @{ Path = (Join-Path $homePath '.zcode\skills'); Source = 'ZCode (candidate location)' }
    )

    if (-not [string]::IsNullOrWhiteSpace($env:APPDATA)) {
        $paths += @{ Path = (Join-Path $env:APPDATA 'opencode\skills'); Source = 'OpenCode (Roaming AppData)' }
    }

    # Honor custom config roots when these environment variables are present.
    if (-not [string]::IsNullOrWhiteSpace($env:OPENCODE_CONFIG_DIR)) {
        $paths += @(
            @{ Path = (Join-Path $env:OPENCODE_CONFIG_DIR 'skills'); Source = 'OpenCode (OPENCODE_CONFIG_DIR)' },
            @{ Path = (Join-Path $env:OPENCODE_CONFIG_DIR 'skill'); Source = 'OpenCode legacy (OPENCODE_CONFIG_DIR)' }
        )
    }
    if (-not [string]::IsNullOrWhiteSpace($env:XDG_CONFIG_HOME)) {
        $paths += @{ Path = (Join-Path $env:XDG_CONFIG_HOME 'opencode\skills'); Source = 'OpenCode (XDG_CONFIG_HOME)' }
    }
    if (-not [string]::IsNullOrWhiteSpace($env:CODEX_HOME)) {
        $paths += @{ Path = (Join-Path $env:CODEX_HOME 'skills'); Source = 'Codex (CODEX_HOME)' }
    }
    if (-not [string]::IsNullOrWhiteSpace($env:CLAUDE_CONFIG_DIR)) {
        $paths += @{ Path = (Join-Path $env:CLAUDE_CONFIG_DIR 'skills'); Source = 'Claude Code (CLAUDE_CONFIG_DIR)' }
    }

    foreach ($entry in $paths) {
        $candidate = New-Candidate -Path $entry.Path -Scope 'Global' -Source $entry.Source
        if ($null -ne $candidate) { $candidate }
    }

    foreach ($customPath in $CustomPaths) {
        $candidate = New-Candidate -Path $customPath -Scope 'Custom' -Source 'User-supplied custom path'
        if ($null -ne $candidate) { $candidate }
    }
}

function Get-ProjectCandidates {
    param(
        [Parameter(Mandatory = $true)][string]$RootPath,
        [string[]]$CustomPaths = @()
    )

    if (-not (Test-Path -LiteralPath $RootPath -PathType Container)) {
        throw "Project path tidak ditemukan atau bukan folder: $RootPath"
    }

    $root = Get-NormalizedPath -Path (Get-Item -LiteralPath $RootPath -Force).FullName
    $relativePaths = @(
        @{ Path = '.agents\skills'; Source = 'Project Agent Skills' },
        @{ Path = '.claude\skills'; Source = 'Project Claude Code' },
        @{ Path = '.codex\skills'; Source = 'Project Codex' },
        @{ Path = '.opencode\skills'; Source = 'Project OpenCode' },
        @{ Path = '.cursor\skills'; Source = 'Project Cursor' },
        @{ Path = '.windsurf\skills'; Source = 'Project Windsurf' },
        @{ Path = '.cline\skills'; Source = 'Project Cline' },
        @{ Path = '.roo\skills'; Source = 'Project Roo Code' },
        @{ Path = '.kilocode\skills'; Source = 'Project Kilo Code' },
        @{ Path = '.continue\skills'; Source = 'Project Continue' },
        @{ Path = '.gemini\antigravity\skills'; Source = 'Project Antigravity' },
        @{ Path = '.github\skills'; Source = 'Project GitHub Agent Skills' },
        @{ Path = '.zencoder\skills'; Source = 'Project Zencoder' },
        @{ Path = '.zcode\skills'; Source = 'Project ZCode (candidate location)' }
    )

    foreach ($entry in $relativePaths) {
        $fullPath = Join-Path $root $entry.Path
        $candidate = New-Candidate -Path $fullPath -Scope 'Project' -Source $entry.Source
        if ($null -ne $candidate) { $candidate }
    }

    foreach ($customPath in $CustomPaths) {
        $candidate = New-Candidate -Path $customPath -Scope 'Project custom' -Source 'User-supplied custom path'
        if ($null -ne $candidate) { $candidate }
    }
}

function Remove-DuplicateCandidates {
    param([object[]]$Candidates)
    $seen = @{}
    $result = @()
    foreach ($candidate in $Candidates) {
        if ($null -eq $candidate) { continue }
        $key = $candidate.Path.ToLowerInvariant()
        if (-not $seen.ContainsKey($key)) {
            $seen[$key] = $true
            $result += $candidate
        }
    }
    return $result
}

function Get-DirectorySummary {
    param([Parameter(Mandatory = $true)]$Candidate)
    try {
        if ($Candidate.IsLink) { return 'Directory link (target will NOT be traversed)' }
        $count = @(Get-ChildItem -LiteralPath $Candidate.Path -Force -ErrorAction Stop).Count
        return "$count item(s) at top level"
    }
    catch {
        return 'Contents could not be enumerated'
    }
}

function Get-LinkMetadata {
    param(
        [Parameter(Mandatory = $true)]$Item,
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$RelativePath
    )

    [pscustomobject]@{
        RelativePath = $RelativePath
        FullPath     = $Item.FullName
        IsDirectory  = [bool]$Item.PSIsContainer
        Attributes   = [string]$Item.Attributes
        LinkType     = Get-PropertyValue -Object $Item -Name 'LinkType'
        Target       = Get-PropertyValue -Object $Item -Name 'Target'
    }
}

function Copy-TreeSafely {
    param(
        [Parameter(Mandatory = $true)][string]$Source,
        [Parameter(Mandatory = $true)][string]$Destination,
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$RelativePrefix,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][System.Collections.ArrayList]$Links
    )

    $sourceItem = Get-Item -LiteralPath $Source -Force -ErrorAction Stop
    if (Test-IsReparsePoint -Item $sourceItem) {
        [void]$Links.Add((Get-LinkMetadata -Item $sourceItem -RelativePath $RelativePrefix))
        return
    }

    if (-not $sourceItem.PSIsContainer) {
        $parent = Split-Path -Parent $Destination
        if (-not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
        Copy-Item -LiteralPath $Source -Destination $Destination -Force -ErrorAction Stop
        return
    }

    if (-not (Test-Path -LiteralPath $Destination)) {
        New-Item -ItemType Directory -Path $Destination -Force | Out-Null
    }

    foreach ($child in Get-ChildItem -LiteralPath $Source -Force -ErrorAction Stop) {
        $childRelative = if ([string]::IsNullOrEmpty($RelativePrefix)) { $child.Name } else { Join-Path $RelativePrefix $child.Name }
        $childDestination = Join-Path $Destination $child.Name
        if (Test-IsReparsePoint -Item $child) {
            [void]$Links.Add((Get-LinkMetadata -Item $child -RelativePath $childRelative))
            continue
        }
        if ($child.PSIsContainer) {
            Copy-TreeSafely -Source $child.FullName -Destination $childDestination -RelativePrefix $childRelative -Links $Links
        }
        else {
            Copy-Item -LiteralPath $child.FullName -Destination $childDestination -Force -ErrorAction Stop
        }
    }
}

function Remove-TreeSafely {
    param([Parameter(Mandatory = $true)][string]$Path)

    $item = Get-Item -LiteralPath $Path -Force -ErrorAction Stop
    if (Test-IsReparsePoint -Item $item) {
        # Delete only the link object; never recurse into its target.
        if ($item.PSIsContainer) {
            [System.IO.Directory]::Delete($item.FullName, $false)
        }
        else {
            [System.IO.File]::Delete($item.FullName)
        }
        return
    }

    if ($item.PSIsContainer) {
        foreach ($child in Get-ChildItem -LiteralPath $item.FullName -Force -ErrorAction Stop) {
            Remove-TreeSafely -Path $child.FullName
        }
        [System.IO.Directory]::Delete($item.FullName, $false)
    }
    else {
        [System.IO.File]::Delete($item.FullName)
    }
}

function Invoke-SkillsAudit {
    param([object[]]$Candidates)

    Write-Section 'AUDIT - Skill folders found'
    if ($Candidates.Count -eq 0) {
        Write-Host 'Tidak ada skill folder pada lokasi yang diperiksa.' -ForegroundColor Green
        return
    }

    $index = 0
    foreach ($candidate in $Candidates) {
        $index++
        $linkLabel = if ($candidate.IsLink) { ' [LINK]' } else { '' }
        Write-Host ("[{0}] {1}{2}" -f $index, $candidate.Path, $linkLabel) -ForegroundColor Yellow
        Write-Host ("    Scope: {0} | Source: {1} | {2}" -f $candidate.Scope, $candidate.Source, (Get-DirectorySummary -Candidate $candidate)) -ForegroundColor Gray
    }

    Write-Host ''
    Write-Host 'Tidak termasuk dalam audit otomatis: custom paths yang tidak diberikan, folder skills generik di root project,' -ForegroundColor DarkYellow
    Write-Host 'skills yang dibundel di dalam plugin/extension, dan lokasi di luar daftar/override yang dikenal.' -ForegroundColor DarkYellow
}

function Invoke-SkillsCleanup {
    param([object[]]$Candidates)

    if ($Candidates.Count -eq 0) {
        Write-Host 'Tidak ada target untuk dihapus.' -ForegroundColor Green
        return
    }

    Invoke-SkillsAudit -Candidates $Candidates
    Write-Section 'KONFIRMASI PENGHAPUSAN'
    Write-Host 'Yang akan dihapus hanya folder skill yang tercantum di atas.' -ForegroundColor White
    Write-Host 'Konfigurasi MCP/provider/API key/agent/rules dan file project lain tidak menjadi target.' -ForegroundColor Green
    Write-Host 'Folder symlink/junction akan dilepas sebagai link saja; target-nya tidak dihapus.' -ForegroundColor Green

    $confirmation = Read-Host "Ketik HAPUS untuk melanjutkan (selain itu batal)"
    if ($confirmation -cne 'HAPUS') {
        Write-Host 'Dibatalkan. Tidak ada folder yang dihapus.' -ForegroundColor Yellow
        return
    }

    if ([string]::IsNullOrWhiteSpace($script:BackupRoot)) {
        $script:BackupRoot = Join-Path $HOME ( 'skills-cleanup-backup-' + (Get-Date -Format 'yyyyMMdd-HHmmss') )
    }
    $backupPath = Get-NormalizedPath -Path $script:BackupRoot
    if (Test-Path -LiteralPath $backupPath) {
        throw "Folder backup sudah ada. Gunakan path backup baru: $backupPath"
    }

    foreach ($candidate in $Candidates) {
        if ($backupPath.StartsWith($candidate.Path + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase) -or
            $backupPath.Equals($candidate.Path, [System.StringComparison]::OrdinalIgnoreCase)) {
            throw "Lokasi backup tidak boleh berada di dalam folder target skill: $backupPath"
        }
    }

    Write-Section 'BACKUP'
    New-Item -ItemType Directory -Path $backupPath -Force | Out-Null
    $manifest = @()
    $position = 0

    foreach ($candidate in $Candidates) {
        $position++
        $folderName = ('{0:D3}_{1}' -f $position, (($candidate.Source -replace '[^a-zA-Z0-9_-]', '_').Trim('_')))
        $destination = Join-Path $backupPath $folderName
        $links = New-Object System.Collections.ArrayList

        Write-Host ("Backup: {0}" -f $candidate.Path) -ForegroundColor Cyan
        try {
            Copy-TreeSafely -Source $candidate.Path -Destination $destination -RelativePrefix '' -Links $links
            if ($links.Count -gt 0) {
                $links | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $backupPath ($folderName + '_links.json')) -Encoding UTF8
            }
            $manifest += [pscustomobject]@{
                OriginalPath = $candidate.Path
                BackupPath  = $destination
                Scope       = $candidate.Scope
                Source      = $candidate.Source
                IsLink      = $candidate.IsLink
                LinkCount   = $links.Count
                Status      = 'Backup OK'
            }
        }
        catch {
            throw "Backup gagal untuk '$($candidate.Path)'. Penghapusan dihentikan. Detail: $($_.Exception.Message)"
        }
    }

    $manifest | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $backupPath 'manifest.json') -Encoding UTF8
    $manifest | Export-Csv -LiteralPath (Join-Path $backupPath 'manifest.csv') -NoTypeInformation -Encoding UTF8
    Write-Host "Backup tersimpan di: $backupPath" -ForegroundColor Green

    Write-Section 'PENGHAPUSAN'
    $removed = 0
    $failed = @()
    foreach ($candidate in $Candidates) {
        try {
            Write-Host ("Menghapus: {0}" -f $candidate.Path) -ForegroundColor Yellow
            Remove-TreeSafely -Path $candidate.Path
            $removed++
            Write-Host '  OK' -ForegroundColor Green
        }
        catch {
            $failed += [pscustomobject]@{ Path = $candidate.Path; Error = $_.Exception.Message }
            Write-Host ("  GAGAL: {0}" -f $_.Exception.Message) -ForegroundColor Red
        }
    }

    Write-Section 'HASIL'
    Write-Host ("Berhasil dihapus: {0} dari {1}" -f $removed, $Candidates.Count) -ForegroundColor Green
    Write-Host "Backup: $backupPath" -ForegroundColor Cyan

    if ($failed.Count -gt 0) {
        $failed | Export-Csv -LiteralPath (Join-Path $backupPath 'deletion-errors.csv') -NoTypeInformation -Encoding UTF8
        Write-Host 'Beberapa target gagal dihapus. Lihat deletion-errors.csv pada folder backup.' -ForegroundColor Red
    }
    else {
        Write-Host 'Semua target yang dipilih berhasil dihapus.' -ForegroundColor Green
    }
}

function Read-ProjectPathIfNeeded {
    param([string]$CurrentPath)
    if (-not [string]::IsNullOrWhiteSpace($CurrentPath)) { return $CurrentPath }
    return (Read-Host 'Masukkan full path project (contoh: D:\Projects\my-app)')
}

Write-Host 'AI AGENT SKILLS CLEANUP - Windows' -ForegroundColor Cyan
Write-Host 'Audit -> Preview -> Backup -> Confirm -> Delete' -ForegroundColor Gray
Write-Host 'Jalankan dari user Windows yang memiliki folder skills tersebut.' -ForegroundColor Gray

if ($Mode -eq 'Interactive') {
    Write-Section 'MENU'
    Write-Host '1. Audit global skills saja (tidak menghapus)'
    Write-Host '2. Hapus global skills'
    Write-Host '3. Hapus project skills'
    Write-Host '4. Hapus global + project skills'
    Write-Host '5. Keluar'
    $choice = Read-Host 'Pilih 1-5'

    switch ($choice) {
        '1' { $Mode = 'Audit' }
        '2' { $Mode = 'CleanupGlobal' }
        '3' { $Mode = 'CleanupProject'; $ProjectPath = Read-ProjectPathIfNeeded -CurrentPath $ProjectPath }
        '4' { $Mode = 'CleanupBoth'; $ProjectPath = Read-ProjectPathIfNeeded -CurrentPath $ProjectPath }
        default { Write-Host 'Selesai. Tidak ada perubahan.' -ForegroundColor Yellow; exit 0 }
    }
}

$globalCandidates = @()
$projectCandidates = @()

if ($Mode -in @('Audit', 'CleanupGlobal', 'CleanupBoth')) {
    $globalCandidates = @(Get-GlobalCandidates -CustomPaths $ExtraSkillPath)
}
if ($Mode -in @('CleanupProject', 'CleanupBoth')) {
    $ProjectPath = Read-ProjectPathIfNeeded -CurrentPath $ProjectPath
    $projectCandidates = @(Get-ProjectCandidates -RootPath $ProjectPath -CustomPaths $ExtraSkillPath)
}

$allCandidates = @(Remove-DuplicateCandidates -Candidates (@($globalCandidates) + @($projectCandidates)))

if ($Mode -eq 'Audit') {
    Invoke-SkillsAudit -Candidates $allCandidates
}
else {
    Invoke-SkillsCleanup -Candidates $allCandidates
}
