Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = "C:\HUMANIA"
$desktop = [Environment]::GetFolderPath("Desktop")
$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$handoff = Join-Path $desktop ("ULTRAHUMANIA_NEW_CHAT_HANDOFF_{0}.md" -f $ts)

$ssot = Join-Path $root "ULTRAHUMANIA_SSoT.md"
$systemMap = Join-Path $root "docs\architecture\SYSTEM_MAP_CANONICAL.md"
$canonicalStatus = Join-Path $root "docs\status\ULTRAHUMANIA_STATUS_CANONICAL.md"
$canonicalIndex = Join-Path $root "HANDOFF\UH_BOOTSTRAP_INDEX.md"

$latestBootstrap = Join-Path $root "HANDOFF\UH_CHAT_BOOTSTRAP_LATEST.md"
$latestComplete  = Join-Path $root "docs\governance\COMPLETE_DESCRIPTION_UH_LATEST.md"
$latestReality   = Join-Path $root "docs\architecture\SYSTEM_REALITY_REPORT_LATEST.md"
$latestDrift     = Join-Path $root "docs\governance\DOCUMENT_DRIFT_REPORT_LATEST.md"
$latestInventory = Join-Path $root "docs\context\INVENTORY_CANON_LATEST.json"

$executionDiagram = Get-ChildItem -LiteralPath (Join-Path $root "docs\architecture") -File -Filter "EXECUTION_DIAGRAM_REAL_*.md" -ErrorAction SilentlyContinue |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 1

$watchdogLoop = Join-Path $root "watchdog\UH_WATCHDOG_LOOP.ps1"
$runner = ""
if (Test-Path -LiteralPath $watchdogLoop) {
  $watchdogText = Get-Content -LiteralPath $watchdogLoop -Raw
  if ($watchdogText -match '\$Runner\s*=\s*"([^"]+)"') {
    $runner = $Matches[1]
  }
}

$required = @(
  $ssot
  $systemMap
  $canonicalStatus
  $canonicalIndex
  $latestBootstrap
  $latestComplete
  $latestReality
  $latestDrift
  $latestInventory
)

$missing = @($required | Where-Object { -not (Test-Path -LiteralPath $_) })
if ($missing.Count -gt 0) {
  Write-Host "[FAIL] Missing required canonical files:"
  $missing | ForEach-Object { Write-Host $_ }
  exit 2
}

$executionDiagramPath = if ($executionDiagram) { $executionDiagram.FullName } else { "MISSING" }

$body = @"
ULTRAHUMANIA NEW CHAT HANDOFF
Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

PRIMARY ENTRYPOINTS
- $ssot
- $systemMap
- $executionDiagramPath
- $canonicalStatus
- $canonicalIndex

SECONDARY / LATEST
- $latestBootstrap
- $latestComplete
- $latestReality
- $latestDrift
- $latestInventory

CURRENT VERIFIED STATE
- canonical status file active
- canonical index active
- latest/history canonicalization active
- watchdog runner = $runner

IMPORTANT
- ULTRAHUMANIA_STATUS_CANONICAL.md is the primary current status reference.
- UH_BOOTSTRAP_INDEX.md is canonical and must remain canonical.
- STATUS_REPORT_* artifacts are historical/legacy.
- UH_BOOTSTRAP_CONTEXT.ps1 now generates this short canonical handoff.
- Do not use STATUS_REPORT_* or UH_BOOTSTRAP_CONTEXT.ps1 output as primary status evidence.
- Read first: handoff, SSoT, SYSTEM_MAP_CANONICAL, EXECUTION_DIAGRAM_REAL, ULTRAHUMANIA_STATUS_CANONICAL, UH_BOOTSTRAP_INDEX.

PRIMARY COMMANDS
pwsh -NoProfile -ExecutionPolicy Bypass -File C:\HUMANIA\tools\Get-UltrahumaniaSecurityHealth.ps1
pwsh -NoProfile -ExecutionPolicy Bypass -File C:\HUMANIA\tools\Update-UltrahumaniaCanonicalStatus.ps1
pwsh -NoProfile -ExecutionPolicy Bypass -File C:\HUMANIA\tools\Update-UltrahumaniaLatestPointers.ps1
pwsh -NoProfile -ExecutionPolicy Bypass -File C:\HUMANIA\tools\Update-UltrahumaniaCanonicalIndex.ps1
"@

$body | Set-Content -LiteralPath $handoff -Encoding UTF8

Write-Host "[OK] HANDOFF=$handoff"
Get-Item -LiteralPath $handoff | Format-List FullName,Length,LastWriteTime
Write-Host ""
Get-Content -LiteralPath $handoff -Raw
