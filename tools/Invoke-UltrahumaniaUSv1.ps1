param(
    [string]$Root = "C:\HUMANIA",
    [int]$RepoHealthThresholdMB = 50,
    [switch]$AlertOnFindings,
    [switch]$CopyToDesktop
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Ensure-Dir([string]$Path) {
    if (!(Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Write-Utf8File([string]$Path, [string[]]$Lines) {
    $Lines | Set-Content -LiteralPath $Path -Encoding UTF8
}

$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$desktop = [Environment]::GetFolderPath("Desktop")

$logsDir = Join-Path $Root "logs\ultrscript"
$docsStatusDir = Join-Path $Root "docs\status"
$docsContextDir = Join-Path $Root "docs\context"
$stateDir = Join-Path $Root "state\ultrscript"

Ensure-Dir $logsDir
Ensure-Dir $docsStatusDir
Ensure-Dir $docsContextDir
Ensure-Dir $stateDir

$repoHealthScript = Join-Path $Root "tools\Invoke-UltrahumaniaRepoHealthCheck.ps1"
$inventoryScript  = Join-Path $Root "verifiers\emit_canonical_inventory.ps1"
$notaryScript     = Join-Path $Root "tools\Invoke-UltrahumaniaNotary.ps1"

if (!(Test-Path -LiteralPath $repoHealthScript)) {
    throw "Missing required script: $repoHealthScript"
}
if (!(Test-Path -LiteralPath $inventoryScript)) {
    throw "Missing required script: $inventoryScript"
}
if (!(Test-Path -LiteralPath $notaryScript)) {
    throw "Missing required script: $notaryScript"
}

$usLog = Join-Path $logsDir ("ULTRASCRIPT_{0}.log" -f $ts)
$usMini = Join-Path $docsStatusDir ("ULTRASCRIPT_MINI_REPORT_{0}.md" -f $ts)
$usMiniLatest = Join-Path $docsStatusDir "ULTRASCRIPT_MINI_REPORT_LATEST.md"
$inventoryOut = Join-Path $docsContextDir ("ULTRASCRIPT_INVENTORY_{0}.json" -f $ts)
$inventoryLatest = Join-Path $docsContextDir "ULTRASCRIPT_INVENTORY_LATEST.json"
$stateJson = Join-Path $stateDir "last_run.json"

$logLines = New-Object System.Collections.Generic.List[string]
$logLines.Add("ULTRAHUMANIA US V1")
$logLines.Add("TS=$ts")
$logLines.Add("ROOT=$Root")
$logLines.Add("START=$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")

$repoArgs = @(
    "-NoProfile",
    "-ExecutionPolicy", "Bypass",
    "-File", $repoHealthScript,
    "-Root", $Root,
    "-ThresholdMB", $RepoHealthThresholdMB
)

if ($AlertOnFindings) {
    $repoArgs += "-AlertOnFindings"
}
if ($CopyToDesktop) {
    $repoArgs += "-CopyReportToDesktop"
}

$repoHealthOutput = & pwsh @repoArgs 2>&1
$repoHealthOutput | ForEach-Object { $logLines.Add("[REPOHEALTH] $_") }

$inventoryOutput = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $inventoryScript `
    -Root $Root `
    -OutPath $inventoryOut 2>&1

$inventoryOutput | ForEach-Object { $logLines.Add("[INVENTORY] $_") }

if (!(Test-Path -LiteralPath $inventoryOut)) {
    throw "Inventory output was not created: $inventoryOut"
}

Copy-Item -LiteralPath $inventoryOut -Destination $inventoryLatest -Force

$repoMiniLatest = Join-Path $docsStatusDir "REPO_HEALTH_MINI_REPORT_LATEST.md"
$repoMiniText = ""
if (Test-Path -LiteralPath $repoMiniLatest) {
    $repoMiniText = Get-Content -LiteralPath $repoMiniLatest -Raw
}

$inventoryObj = Get-Content -LiteralPath $inventoryOut -Raw | ConvertFrom-Json
$fileCount = $inventoryObj.file_count

$mini = @()
$mini += "# ULTRAHUMANIA US V1 MINI REPORT"
$mini += ""
$mini += "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$mini += "Root: $Root"
$mini += "RepoHealthThresholdMB: $RepoHealthThresholdMB"
$mini += "InventoryFile: $inventoryOut"
$mini += "InventoryFileCount: $fileCount"
$mini += "Log: $usLog"
$mini += ""
$mini += "## RepoHealth"
$mini += ""

if ([string]::IsNullOrWhiteSpace($repoMiniText)) {
    $mini += "RepoHealth mini report not found."
} else {
    $mini += $repoMiniText
}

Write-Utf8File -Path $usMini -Lines $mini
Copy-Item -LiteralPath $usMini -Destination $usMiniLatest -Force

$logLines.Add("US_MINI=$usMini")
$logLines.Add("US_MINI_LATEST=$usMiniLatest")
$logLines.Add("INVENTORY=$inventoryOut")
$logLines.Add("INVENTORY_LATEST=$inventoryLatest")
$logLines.Add("FILE_COUNT=$fileCount")

$state = [ordered]@{
    ts = (Get-Date -Format o)
    runid = $ts
    root = $Root
    inventory = $inventoryOut
    inventory_file_count = $fileCount
    repo_health_latest = $repoMiniLatest
    us_mini_report = $usMini
    us_log = $usLog
}
$state | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $stateJson -Encoding UTF8

$notaryOutput = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $notaryScript 2>&1
$notaryOutput | ForEach-Object { $logLines.Add("[NOTARY] $_") }

$logLines.Add("STATE_JSON=$stateJson")
$logLines.Add("END=$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")

Write-Utf8File -Path $usLog -Lines $logLines

if ($CopyToDesktop) {
    Copy-Item -LiteralPath $usMini -Destination (Join-Path $desktop ("ULTRASCRIPT_MINI_REPORT_{0}.md" -f $ts)) -Force
    Copy-Item -LiteralPath $usLog -Destination (Join-Path $desktop ("ULTRASCRIPT_LOG_{0}.log" -f $ts)) -Force
    Copy-Item -LiteralPath $inventoryOut -Destination (Join-Path $desktop ("ULTRASCRIPT_INVENTORY_{0}.json" -f $ts)) -Force
}

Write-Host "[OK] US_LOG=$usLog"
Write-Host "[OK] US_MINI=$usMini"
Write-Host "[OK] INVENTORY=$inventoryOut"
Write-Host "[OK] FILE_COUNT=$fileCount"
Write-Host "[OK] STATE_JSON=$stateJson"
$notaryOutput | ForEach-Object { Write-Host $_ }
exit 0
