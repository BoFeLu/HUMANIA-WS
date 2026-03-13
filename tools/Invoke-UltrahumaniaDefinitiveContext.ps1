Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-TextSafe {
    param([string]$Path)
    if (Test-Path -LiteralPath $Path) {
        return Get-Content -LiteralPath $Path -Raw
    }
    return ""
}

function Get-LatestFilePath {
    param(
        [string]$Directory,
        [string]$Filter
    )
    if (!(Test-Path -LiteralPath $Directory)) {
        return ""
    }

    $item = Get-ChildItem -LiteralPath $Directory -File -Filter $Filter -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if ($item) {
        return $item.FullName
    }

    return ""
}

function Get-TopLevelDirSummary {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Root
    )

    $dirs = Get-ChildItem -LiteralPath $Root -Directory -ErrorAction SilentlyContinue
    $rows = @()

    foreach ($dir in $dirs) {
        $files = Get-ChildItem -LiteralPath $dir.FullName -Recurse -File -ErrorAction SilentlyContinue

        $fileCount = @($files).Count

        $measure = $files | Measure-Object -Property Length -Sum
        if ($null -eq $measure -or $null -eq $measure.Sum) {
            $totalBytes = 0
        }
        else {
            $totalBytes = [int64]$measure.Sum
        }

        $rows += [pscustomobject]@{
            Name       = $dir.Name
            FullName   = $dir.FullName
            FileCount  = $fileCount
            TotalBytes = $totalBytes
        }
    }

    return $rows | Sort-Object TotalBytes -Descending
}

$root = "C:\HUMANIA"
$desktop = [Environment]::GetFolderPath("Desktop")
$ts = Get-Date -Format "yyyyMMdd_HHmmss"

$outRoot = Join-Path $root ("LA_CLAVE_{0}.md" -f $ts)
$outLatest = Join-Path $root "LA_CLAVE_LATEST.md"
$outDesktopTs = Join-Path $desktop ("LA_CLAVE_{0}.md" -f $ts)
$outDesktopLatest = Join-Path $desktop "LA_CLAVE_LATEST.md"

$ssot = Join-Path $root "ULTRAHUMANIA_SSoT.md"
$master = Join-Path $root "ULTRAHUMANIA_MASTER_SYSTEM_DOCUMENT.md"
$systemMap = Join-Path $root "docs\architecture\SYSTEM_MAP_CANONICAL.md"
$statusCanonical = Join-Path $root "docs\status\ULTRAHUMANIA_STATUS_CANONICAL.md"
$bootstrapIndex = Join-Path $root "HANDOFF\UH_BOOTSTRAP_INDEX.md"
$bootstrapContext = Join-Path $root "HANDOFF\UH_BOOTSTRAP_CONTEXT.ps1"

$execDiagram = Get-LatestFilePath -Directory (Join-Path $root "docs\architecture") -Filter "EXECUTION_DIAGRAM_REAL_*.md"
$clusterMap = Get-LatestFilePath -Directory (Join-Path $root "docs\architecture") -Filter "POSTGRESQL_CLUSTER_MAP_*.md"
$systemMapPg = Get-LatestFilePath -Directory (Join-Path $root "docs\architecture") -Filter "POSTGRESQL_SYSTEM_MAP*.md"
$blueprint = Get-LatestFilePath -Directory (Join-Path $root "docs\architecture") -Filter "ULTRAHUMANIA_ARCHITECTURE_BLUEPRINT_*.md"
$dataDomains = Get-LatestFilePath -Directory (Join-Path $root "docs\architecture") -Filter "ULTRAHUMANIA_DATA_DOMAINS_*.md"
$pgExpansion = Get-LatestFilePath -Directory (Join-Path $root "docs\architecture") -Filter "POSTGRESQL_EXPANSION_PLAN_*.md"

$latestReality = Join-Path $root "docs\architecture\SYSTEM_REALITY_REPORT_LATEST.md"
$latestComplete = Join-Path $root "docs\governance\COMPLETE_DESCRIPTION_UH_LATEST.md"
$latestDrift = Join-Path $root "docs\governance\DOCUMENT_DRIFT_REPORT_LATEST.md"
$latestInventory = Join-Path $root "docs\context\INVENTORY_CANON_LATEST.json"
$latestBootstrap = Join-Path $root "HANDOFF\UH_CHAT_BOOTSTRAP_LATEST.md"

$securityTool = Join-Path $root "tools\Get-UltrahumaniaSecurityHealth.ps1"
$securityOut = ""
$securityCode = -1
if (Test-Path -LiteralPath $securityTool) {
    $securityOut = (& pwsh -NoProfile -ExecutionPolicy Bypass -File $securityTool 2>&1 | Out-String)
    $securityCode = $LASTEXITCODE
}

$gitBranch = ""
$gitStatus = ""
$gitLog = ""
$gitRemote = ""
try { $gitBranch = (git branch --show-current | Out-String).Trim() } catch {}
try { $gitStatus = (git status --short | Out-String).Trim() } catch {}
try { $gitLog = (git log --oneline -n 12 | Out-String).Trim() } catch {}
try { $gitRemote = (git remote -v | Out-String).Trim() } catch {}

$schemasOut = ""
$schemasTmp = Join-Path $env:TEMP ("uh_schemas_{0}.txt" -f $ts)
$uhWrapper = Join-Path $root "uh"
if (Test-Path -LiteralPath $uhWrapper) {
    $psqlCommands = @(
        '\pset pager off',
        '\pset linestyle ascii',
        '\pset border 2',
        "\o $($schemasTmp -replace '\\','/')",
        'SELECT current_database();',
        '\dn',
        '\o',
        '\q'
    )
    $psqlCommands | & $uhWrapper | Out-Null
    if (Test-Path -LiteralPath $schemasTmp) {
        $schemasOut = Get-Content -LiteralPath $schemasTmp -Raw
        Remove-Item -LiteralPath $schemasTmp -Force -ErrorAction SilentlyContinue
    }
}

$topDirs = Get-TopLevelDirSummary -Root $root

$body = @"
LA_CLAVE
Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
File: $outRoot

==================================================
1. PRIMARY ENTRYPOINTS
==================================================

MASTER SYSTEM DOCUMENT
$master

SSoT
$ssot

SYSTEM MAP CANONICAL
$systemMap

EXECUTION DIAGRAM REAL
$execDiagram

STATUS CANONICAL
$statusCanonical

BOOTSTRAP INDEX
$bootstrapIndex

BOOTSTRAP CONTEXT GENERATOR
$bootstrapContext

==================================================
2. LATEST OPERATIONAL POINTERS
==================================================

LATEST BOOTSTRAP
$latestBootstrap

LATEST REALITY REPORT
$latestReality

LATEST COMPLETE DESCRIPTION
$latestComplete

LATEST DRIFT REPORT
$latestDrift

LATEST INVENTORY
$latestInventory

==================================================
3. SECURITY HEALTH
==================================================

SECURITY TOOL
$securityTool

EXIT CODE
$securityCode

OUTPUT
$securityOut

==================================================
4. GIT STATE
==================================================

BRANCH
$gitBranch

REMOTES
$gitRemote

STATUS SHORT
$gitStatus

RECENT COMMITS
$gitLog

==================================================
5. POSTGRESQL CONTEXT
==================================================

LATEST CLUSTER MAP
$clusterMap

LATEST POSTGRESQL SYSTEM MAP
$systemMapPg

LATEST POSTGRESQL EXPANSION PLAN
$pgExpansion

SCHEMAS SNAPSHOT
$schemasOut

==================================================
6. ARCHITECTURE / DATA DOCUMENTS
==================================================

ARCHITECTURE BLUEPRINT
$blueprint

DATA DOMAINS
$dataDomains

==================================================
7. TOP-LEVEL DISK USAGE SUMMARY
==================================================

$topDirs

==================================================
8. CURRENT VERIFIED REALITY
==================================================

- fail-secure model active
- canonical status exists and is primary
- canonical bootstrap index exists
- canonical handoff generator exists
- repo health hourly reminder exists
- canonical reminder daily task exists
- PostgreSQL ultrahumania contains operational, knowledge and governance domains
- schema germs created: ideas, archive, media, chats

==================================================
9. PENDING FOCUSES
==================================================

- keep canonical documentation aligned with rapid system changes
- control heavyweight generated artifacts, especially drift reports
- continue Git cleanup and split changes into logical commits
- clarify macrodomain composition and future database separation policy
- preserve ultrahumania as active core without breaking existing schemas

==================================================
10. PROCEDURAL RULE
==================================================

METHOD 3C5B applies:
- Clear
- Complete
- Correct
- Maximum 5 command blocks
- Evidence before next step

==================================================
END
==================================================
"@

$body | Set-Content -LiteralPath $outRoot -Encoding UTF8
$body | Set-Content -LiteralPath $outLatest -Encoding UTF8
Copy-Item -LiteralPath $outRoot -Destination $outDesktopTs -Force
Copy-Item -LiteralPath $outLatest -Destination $outDesktopLatest -Force

Write-Host "[OK] ROOT_TS=$outRoot"
Write-Host "[OK] ROOT_LATEST=$outLatest"
Write-Host "[OK] DESKTOP_TS=$outDesktopTs"
Write-Host "[OK] DESKTOP_LATEST=$outDesktopLatest"
