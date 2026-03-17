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

function Add-CheckResult {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][ValidateSet('PASS','WARN','FAIL')][string]$Status,
        [Parameter(Mandatory = $true)][string]$Message
    )
    $script:checks.Add([pscustomobject]@{
        name    = $Name
        status  = $Status
        message = $Message
    })
}

function Get-TextSeverity {
    param([string]$Text)

    if ([string]::IsNullOrWhiteSpace($Text)) { return 'WARN' }

    if ($Text -match '(?im)\bFAIL\b|OVERALL STATUS:\s*FAIL|OverallStatus:\s*FAIL') { return 'FAIL' }
    if ($Text -match '(?im)\bWARN\b|OVERALL STATUS:\s*WARN|OverallStatus:\s*WARN') { return 'WARN' }
    if ($Text -match '(?im)\bPASS\b|OVERALL STATUS:\s*PASS|OVERALL STATUS:\s*OK|OverallStatus:\s*PASS|OverallStatus:\s*OK') { return 'PASS' }

    return 'WARN'
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

$repoHealthScript = Join-Path $Root "tools\Get-UltrahumaniaSecurityHealth.ps1"
$inventoryScript  = Join-Path $Root "verifiers\emit_canonical_inventory.ps1"
$notaryScript     = Join-Path $Root "tools\Invoke-UltrahumaniaNotary.ps1"

$hasRepoHealthScript = Test-Path -LiteralPath $repoHealthScript
if (!(Test-Path -LiteralPath $inventoryScript))  { throw "Missing required script: $inventoryScript" }
if (!(Test-Path -LiteralPath $notaryScript))     { throw "Missing required script: $notaryScript" }

$usLog = Join-Path $logsDir ("ULTRASCRIPT_{0}.log" -f $ts)
$usMini = Join-Path $docsStatusDir ("ULTRASCRIPT_MINI_REPORT_{0}.md" -f $ts)
$usMiniLatest = Join-Path $docsStatusDir "ULTRASCRIPT_MINI_REPORT_LATEST.md"
$inventoryOut = Join-Path $docsContextDir ("ULTRASCRIPT_INVENTORY_{0}.json" -f $ts)
$inventoryLatest = Join-Path $docsContextDir "ULTRASCRIPT_INVENTORY_LATEST.json"
$stateJson = Join-Path $stateDir "last_run.json"

$logLines = New-Object System.Collections.Generic.List[string]
$script:checks = New-Object System.Collections.Generic.List[object]

$logLines.Add("ULTRAHUMANIA US V1")
$logLines.Add("TS=$ts")
$logLines.Add("ROOT=$Root")
$logLines.Add("START=$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")

if ($hasRepoHealthScript) {
    Add-CheckResult -Name 'Required:Get-UltrahumaniaSecurityHealth.ps1' -Status PASS -Message 'present'
} else {
    Add-CheckResult -Name 'Required:Get-UltrahumaniaSecurityHealth.ps1' -Status WARN -Message 'missing; degraded mode'
}
Add-CheckResult -Name 'Required:emit_canonical_inventory.ps1' -Status PASS -Message 'present'
Add-CheckResult -Name 'Required:Invoke-UltrahumaniaNotary.ps1' -Status PASS -Message 'present'

$repoArgs = @(
    "-NoProfile",
    "-ExecutionPolicy", "Bypass",
    "-File", $repoHealthScript,
    "-Root", $Root,
    "-ThresholdMB", $RepoHealthThresholdMB
)

if ($AlertOnFindings) { $repoArgs += "-AlertOnFindings" }
if ($CopyToDesktop)   { $repoArgs += "-CopyReportToDesktop" }

if ($hasRepoHealthScript) {
    $repoHealthOutput = & powershell.exe @repoArgs 2>&1
    $repoHealthOutput | ForEach-Object { $logLines.Add("[REPOHEALTH] $_") }
} else {
    $repoHealthOutput = @('[WARN] RepoHealth script missing; degraded mode active.')
    $repoHealthOutput | ForEach-Object { $logLines.Add("[REPOHEALTH] $_") }
}

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

if ($hasRepoHealthScript) {
    $repoSignalText = ($repoHealthOutput | Out-String)
    if ([string]::IsNullOrWhiteSpace($repoSignalText)) {
        $repoSignalText = $repoMiniText
    }

    $repoSeverity = Get-TextSeverity -Text $repoSignalText
    switch ($repoSeverity) {
        'FAIL' { Add-CheckResult -Name 'SecurityHealth' -Status FAIL -Message 'security health indicates FAIL' }
        'WARN' { Add-CheckResult -Name 'SecurityHealth' -Status WARN -Message 'security health indicates WARN or ambiguous state' }
        default { Add-CheckResult -Name 'SecurityHealth' -Status PASS -Message 'security health indicates PASS/OK' }
    }
} else {
    Add-CheckResult -Name 'SecurityHealth' -Status WARN -Message 'security health script missing; skipped'
}

Add-CheckResult -Name 'Inventory' -Status PASS -Message ("file_count={0}" -f $fileCount)

$notaryOutput = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $notaryScript 2>&1
$notaryOutput | ForEach-Object { $logLines.Add("[NOTARY] $_") }
Add-CheckResult -Name 'Notary' -Status PASS -Message 'executed'

$failCount = @($script:checks | Where-Object status -eq 'FAIL').Count
$warnCount = @($script:checks | Where-Object status -eq 'WARN').Count

if ($failCount -gt 0) {
    $overall = 'FAIL'
}
elseif ($warnCount -gt 0) {
    $overall = 'WARN'
}
else {
    $overall = 'PASS'
}

$mini = @()
$mini += "# ULTRAHUMANIA US V1 MINI REPORT"
$mini += ""
$mini += "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$mini += "Root: $Root"
$mini += "RepoHealthThresholdMB: $RepoHealthThresholdMB"
$mini += "InventoryFile: $inventoryOut"
$mini += "InventoryFileCount: $fileCount"
$mini += "Log: $usLog"
$mini += "OverallStatus: $overall"
$mini += "FailCount: $failCount"
$mini += "WarnCount: $warnCount"
$mini += ""
$mini += "## Checks"
$mini += ""
foreach ($c in $script:checks) {
    $mini += "- [$($c.status)] $($c.name) :: $($c.message)"
}
$mini += ""
$mini += "## SecurityHealth"
$mini += ""
if ([string]::IsNullOrWhiteSpace($repoMiniText)) {
    $mini += "SecurityHealth mini report not found."
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
$logLines.Add("OVERALL_STATUS=$overall")
$logLines.Add("FAIL_COUNT=$failCount")
$logLines.Add("WARN_COUNT=$warnCount")

foreach ($c in $script:checks) {
    $logLines.Add("[CHECK][$($c.status)] $($c.name) :: $($c.message)")
}

$state = [ordered]@{
    ts = (Get-Date -Format o)
    runid = $ts
    root = $Root
    inventory = $inventoryOut
    inventory_file_count = $fileCount
    repo_health_latest = $repoMiniLatest
    us_mini_report = $usMini
    us_log = $usLog
    overall_status = $overall
    fail_count = $failCount
    warn_count = $warnCount
    checks = @($script:checks | ForEach-Object {
        [pscustomobject]@{
            name = $_.name
            status = $_.status
            message = $_.message
        }
    })
}

$state | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $stateJson -Encoding UTF8

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
Write-Host "[OK] OVERALL_STATUS=$overall"
Write-Host "[OK] FAIL_COUNT=$failCount"
Write-Host "[OK] WARN_COUNT=$warnCount"
$notaryOutput | ForEach-Object { Write-Host $_ }
exit 0


