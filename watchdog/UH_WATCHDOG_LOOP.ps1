param(
  [int]$IntervalSeconds = 60,
  [int]$FailBackoffSeconds = 300
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

$Runner = "C:\HUMANIA\sentinel\sentinel_tick_new.ps1"
$LogDir = "C:\HUMANIA\logs\watchdog"
$LoopLog = Join-Path $LogDir "UH_WATCHDOG_LOOP.log"

if (!(Test-Path $LogDir)) { New-Item -ItemType Directory -Force -Path $LogDir | Out-Null }

function LogLine([string]$m) {
  $line = "{0}  {1}" -f (Get-Date -Format o), $m
  Add-Content -Encoding UTF8 -Path $LoopLog -Value $line
}

LogLine "[LOOP_START] interval=$IntervalSeconds fail_backoff=$FailBackoffSeconds runner=$Runner"

while ($true) {
  try {
    LogLine "[TICK] invoking runner"
    $out = & powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File $Runner 2>&1
    $code = $LASTEXITCODE

    if ($out) {
      # Compact: one joined block to avoid multi-line storm in service logs
      $joined = ($out -join " | ")
      LogLine ("[RUN_OUT] " + $joined)
    }

    if ($code -eq 0) {
      LogLine "[RUN_PASS]"
      Start-Sleep -Seconds $IntervalSeconds
    } else {
      LogLine ("[RUN_FAIL] exit=" + $code + " -> backoff=" + $FailBackoffSeconds)
      Start-Sleep -Seconds $FailBackoffSeconds
    }
  } catch {
    LogLine ("[LOOP_EXCEPTION] " + $_.Exception.ToString())
    Start-Sleep -Seconds $FailBackoffSeconds
  }
}
