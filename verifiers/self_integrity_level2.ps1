param(
  [string]$Root="C:\HUMANIA",
  [string]$TaskName="HUMANIA_SENTINEL_TICK"
)

Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"

$fail = 0
function OK($m){ Write-Host "[OK]  $m" }
function FAIL($m){ Write-Host "[FAIL] $m"; $script:fail = 1 }

# 1) Sentinel script present
$sent1 = Join-Path $Root "sentinel\sentinel_tick_new.ps1"
$sent2 = Join-Path $Root "staging\sentinel_tick_new.ps1"

$sent = $null
if(Test-Path -LiteralPath $sent1){ $sent = $sent1 }
elseif(Test-Path -LiteralPath $sent2){ $sent = $sent2 }

if($null -eq $sent){
  FAIL "sentinel_tick_new.ps1 not found under $Root\sentinel or $Root\staging"
} else {
  OK "Sentinel script present => $sent"
}

# 2) Task exists and last result
$taskInfo = & schtasks /Query /TN $TaskName /V /FO LIST 2>&1
if($LASTEXITCODE -ne 0){
  FAIL "Scheduled task missing or not queryable: $TaskName"
} else {
  OK "Scheduled task query OK: $TaskName"
  $lastResult = ($taskInfo | Select-String -Pattern "Último resultado|Last Result").ToString()
  $nextRun    = ($taskInfo | Select-String -Pattern "Hora próxima ejecución|Next Run Time").ToString()
  $runAs      = ($taskInfo | Select-String -Pattern "Ejecutar como usuario|Run As User").ToString()
  $state      = ($taskInfo | Select-String -Pattern "Estado:|Status:").ToString()

  if($lastResult -match ":\s*0(\s*)$"){
    OK "Task last result = 0"
  } else {
    FAIL "Task last result not 0 => $lastResult"
  }

  if($state){ OK $state.Trim() } else { FAIL "Task state not found in query output" }
  if($nextRun){ OK $nextRun.Trim() } else { FAIL "Next run time not found" }
  if($runAs){ OK $runAs.Trim() } else { FAIL "Run-as user not found" }
}

# 3) Minimal evidence files expected (soft checks; adapt if your sentinel uses different paths)
$stateFile = Join-Path $Root "STATE.json"
if(Test-Path -LiteralPath $stateFile){
  OK "STATE present => $stateFile"
} else {
  FAIL "STATE missing => $stateFile"
}

$signalsDir = Join-Path $Root "logs\signals"
if(Test-Path -LiteralPath $signalsDir){
  $sig = Get-ChildItem -LiteralPath $signalsDir -File -Filter "SIGNAL_*.json" -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending | Select-Object -First 1
  if($sig){
    OK "Latest SIGNAL => $($sig.FullName)"
  } else {
    FAIL "No SIGNAL_*.json found under $signalsDir"
  }
} else {
  FAIL "Signals dir missing => $signalsDir"
}

if($fail -ne 0){ exit 1 } else { exit 0 }
