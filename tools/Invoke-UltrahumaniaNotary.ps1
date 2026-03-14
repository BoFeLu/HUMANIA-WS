param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ts = Get-Date -Format 'yyyyMMddHHmmss'
$root = 'C:\HUMANIA'

$stateFile = Join-Path $root 'state\ultrscript\last_run.json'
$outDir    = Join-Path $root 'docs\notary'

if (-not (Test-Path -LiteralPath $stateFile)) {
    throw "Missing state file: $stateFile"
}

if (-not (Test-Path -LiteralPath $outDir)) {
    New-Item -ItemType Directory -Path $outDir -Force | Out-Null
}

$raw = Get-Content -LiteralPath $stateFile -Raw
$state = $raw | ConvertFrom-Json

$stateTs = if ($state.ts -is [DateTime]) {
    $state.ts.ToString('o')
} else {
    [string]$state.ts
}

$outFile    = Join-Path $outDir ("LA_CLAVE_{0}.md" -f $ts)
$latestFile = Join-Path $outDir 'LA_CLAVE_LATEST.md'

$lines = @()
$lines += '# LA_CLAVE'
$lines += ''
$lines += "timestamp: $ts"
$lines += "state_ts: $stateTs"
$lines += "runid: $($state.runid)"
$lines += ''
$lines += '## SYSTEM ROOT'
$lines += "$($state.root)"
$lines += ''
$lines += '## INVENTORY'
$lines += "$($state.inventory)"
$lines += ''
$lines += '## FILE COUNT'
$lines += "$($state.inventory_file_count)"
$lines += ''
$lines += '## MINI REPORT'
$lines += "$($state.us_mini_report)"
$lines += ''
$lines += '## LOG'
$lines += "$($state.us_log)"
$lines += ''
$lines += '## REPO HEALTH'
$lines += "$($state.repo_health_latest)"
$lines += ''
$lines += '## STATE SOURCE'
$lines += "$stateFile"

$lines | Set-Content -LiteralPath $outFile -Encoding UTF8
$lines | Set-Content -LiteralPath $latestFile -Encoding UTF8

Write-Output "[OK] NOTARY_FILE=$outFile"
Write-Output "[OK] NOTARY_LATEST=$latestFile"
