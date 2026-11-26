<#
.SYNOPSIS
    Backup semua folder global skills dari coding-agent ke direktori ber-timestamp.
.EXAMPLE
    .\scripts\backup-global.ps1
    .\scripts\backup-global.ps1 -DestinationRoot "D:\Backups"
#>
[CmdletBinding()]
param(
    [string]$DestinationRoot = $HOME
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$BackupDir = Join-Path $DestinationRoot ("AI-Skill-Backup-" + $Timestamp)
New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null

$Paths = @(
    @{ Agent = "codex";        Path = (Join-Path $HOME ".agents\skills") },
    @{ Agent = "claude-code";  Path = (Join-Path $HOME ".claude\skills") },
    @{ Agent = "opencode";     Path = (Join-Path $HOME ".config\opencode\skills") },
    @{ Agent = "antigravity";  Path = (Join-Path $HOME ".gemini\config\skills") },
    @{ Agent = "hermes-agent"; Path = (Join-Path $HOME ".hermes\skills") },
    @{ Agent = "zcode";        Path = (Join-Path $HOME ".zcode\skills") }
)

$BackupSummary = [System.Collections.Generic.List[object]]::new()

foreach ($Item in $Paths) {
    $SourcePath = $Item.Path
    if (Test-Path -LiteralPath $SourcePath) {
        $TargetName = $Item.Agent
        $TargetPath = Join-Path $BackupDir $TargetName
        Copy-Item -LiteralPath $SourcePath -Destination $TargetPath -Recurse -Force
        Write-Host "[OK] Backed up $($Item.Agent): $SourcePath" -ForegroundColor Green
        $BackupSummary.Add([PSCustomObject]@{
            agent       = $Item.Agent
            source_path = $SourcePath
            backup_path = $TargetPath
            status      = "backed_up"
        })
    }
    else {
        Write-Host "[SKIP] Not found ($($Item.Agent)): $SourcePath" -ForegroundColor DarkGray
        $BackupSummary.Add([PSCustomObject]@{
            agent       = $Item.Agent
            source_path = $SourcePath
            backup_path = $null
            status      = "not_found"
        })
    }
}

# Simpan snapshot inventory Skills CLI bila tersedia
$InventoryFile = Join-Path $BackupDir "skills-ls-global.txt"
try {
    $LsOutput = & npx.cmd skills ls -g 2>&1
    $LsOutput | Out-File -FilePath $InventoryFile -Encoding utf8
    Write-Host "[OK] Saved CLI snapshot: $InventoryFile" -ForegroundColor Green
}
catch {
    "Failed to run 'npx.cmd skills ls -g': $($_.Exception.Message)" | Out-File -FilePath $InventoryFile -Encoding utf8
    Write-Warning "Tidak bisa menjalankan 'npx.cmd skills ls -g'. Folder backup tetap tersimpan."
}

$MetaFile = Join-Path $BackupDir "backup-manifest.json"
[PSCustomObject]@{
    created_at = (Get-Date).ToString("o")
    computer   = $env:COMPUTERNAME
    user       = $env:USERNAME
    entries    = $BackupSummary
} | ConvertTo-Json -Depth 5 | Out-File -FilePath $MetaFile -Encoding utf8

Write-Host ""
Write-Host "Backup selesai: $BackupDir" -ForegroundColor Cyan
