param(
  [string]$Trigger = "SCHEDULED_TICK",
  [string]$Root = "C:\HUMANIA",
  [int]$LockTtlSeconds = 180,
  [int]$HeartbeatStaleSeconds = 120,
  [int]$MaxLogBytes = 20MB,
  [int]$KeepLogs = 10
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# --- Paths ---
$GuardDir     = Join-Path $Root "guard"
$StateDir     = Join-Path $Root "state"
$RunnerState  = Join-Path $StateDir "runner"
$LocksDir     = Join-Path $StateDir "locks"
$LogsDir      = Join-Path $Root "logs"
$RunnerLogs   = Join-Path $LogsDir "runner"

$DocsContext  = Join-Path $Root "docs\context"
$DocsStatus   = Join-Path $Root "docs\status"
$DocsConst    = Join-Path $Root "docs\constitution"
$DocsVital    = Join-Path $Root "docs\laws\vital"

$LockPath     = Join-Path $LocksDir "UH_GUARD.lock"
$Heartbeat    = Join-Path $RunnerState "heartbeat.json"
$LastSuccess  = Join-Path $RunnerState "last_success.json"
$LastFailure  = Join-Path $RunnerState "last_failure.json"

# --- Utilities ---
function Ensure-Dir([string]$p) {
  if (!(Test-Path $p)) { New-Item -ItemType Directory -Path $p | Out-Null }
}

function NowStamp { (Get-Date).ToString("yyyyMMdd_HHmmss") }

function Write-Json([string]$Path, [hashtable]$Obj) {
  $Obj | ConvertTo-Json -Depth 8 | Set-Content -Encoding UTF8 -Path $Path
}

function Rotate-Log([string]$LogPath, [int]$MaxBytes, [int]$Keep) {
  if (!(Test-Path $LogPath)) { return }
  $len = (Get-Item $LogPath).Length
  if ($len -lt $MaxBytes) { return }

  for ($i = $Keep; $i -ge 1; $i--) {
    $older = "$LogPath.$i"
    $newer = "$LogPath." + ($i + 1)
    if (Test-Path $older) {
      if ($i -eq $Keep) { Remove-Item -Force $older }
      else { Rename-Item -Force $older $newer }
    }
  }
  Rename-Item -Force $LogPath "$LogPath.1"
}

function Log([string]$LogFile, [string]$Msg) {
  Rotate-Log -LogPath $LogFile -MaxBytes $MaxLogBytes -Keep $KeepLogs
  $line = "{0}  {1}" -f (Get-Date -Format o), $Msg
  Add-Content -Encoding UTF8 -Path $LogFile -Value $line
}

function Acquire-Lock([string]$Path) {
  # Exclusive lock by opening with no sharing
  $fs = [System.IO.File]::Open($Path,
    [System.IO.FileMode]::OpenOrCreate,
    [System.IO.FileAccess]::ReadWrite,
    [System.IO.FileShare]::None)

  # Stamp lock content
  $stamp = (Get-Date -Format o)
  $bytes = [System.Text.Encoding]::UTF8.GetBytes($stamp)
  $fs.SetLength(0)
  $fs.Write($bytes, 0, $bytes.Length)
  $fs.Flush()
  return $fs
}

function Touch-Heartbeat([string]$Path, [string]$Phase, [string]$RunId) {
  $obj = @{
    ts    = (Get-Date -Format o)
    phase = $Phase
    runid = $RunId
  }
  Write-Json -Path $Path -Obj $obj
}

function Require-File([string]$Path, [string]$Label) {
  if (!(Test-Path $Path)) { throw "FALTA_CRITICA: $Label => $Path" }
}




# ===============================
# INTEGRITY CHECK MODULE (CORE)
# ===============================

function Integrity-Check-CoreStructure {

  $root = "C:\HUMANIA"

  if (-not (Test-Path $root)) {
    throw "INTEGRITY_FAIL: Root path C:\HUMANIA does not exist."
  }

  # Enforce execution context
  if ($PSScriptRoot -notlike "C:\HUMANIA*") {
    throw "INTEGRITY_FAIL: Script not running inside C:\HUMANIA context."
  }

  $expectedRootDirs = @(
    "archive",
    "audit",
    "audit_archive",
    "BACKUP_INTEGRITY",
    "BIN",
    "CORE",
    "DIAG",
    "docs",
    "guard",
    "guardian",
    "HANDOFF",
    "LEX",
    "logs",
    "orchestrator",
    "RUNS",
    "sentinel",
    "SNAPSHOTS",
    "staging",
    "state",
    "tools",
    "verifiers",
    "watchdog"
  )

  $actualRootDirs = Get-ChildItem $root -Directory | Select-Object -ExpandProperty Name |
    Where-Object { $_ -ne '.git' }

  foreach ($expected in $expectedRootDirs) {
    if ($actualRootDirs -notcontains $expected) {
      throw "INTEGRITY_FAIL: Missing root directory: $expected"
    }
  }

  foreach ($actual in $actualRootDirs) {
    if ($expectedRootDirs -notcontains $actual) {
      throw "INTEGRITY_FAIL: Unexpected root directory detected: $actual"
    }
  }

  $requiredFiles = @(
    "C:\HUMANIA\guard\UH_GUARD_RUN.ps1",
    "C:\HUMANIA\docs\laws\vital\UH_GUARD_SPEC_v1.md",
    "C:\HUMANIA\docs\laws\vital\UH_STATUS_REPORT_GENERATION_PROCEDURE_v1.md",
    "C:\HUMANIA\verifiers\silent_run.vbs"
  )

  foreach ($f in $requiredFiles) {
    if (!(Test-Path $f)) {
      throw "INTEGRITY_FAIL: Missing file: $f"
    }
    if ((Get-Item $f).Length -eq 0) {
      throw "INTEGRITY_FAIL: Empty file detected: $f"
    }
  }
}

# --- Ensure dirs ---
Ensure-Dir $GuardDir
Ensure-Dir $RunnerState
Ensure-Dir $LocksDir
Ensure-Dir $RunnerLogs
Ensure-Dir $DocsVital

$RunId = NowStamp
$LogFile = Join-Path $RunnerLogs ("UH_GUARD_{0}.log" -f (Get-Date).ToString("yyyyMMdd"))

try {
  Log $LogFile "[START] UH_GUARD_RUN runid=$RunId"
  Touch-Heartbeat -Path $Heartbeat -Phase "start" -RunId $RunId
  # --- Integrity enforcement ---
  Integrity-Check-CoreStructure
  # --- End integrity enforcement ---

  # Lock (exclusive)
  $lockFs = Acquire-Lock -Path $LockPath
  try {
    Touch-Heartbeat -Path $Heartbeat -Phase "lock_acquired" -RunId $RunId

    # Require vital spec (guard rail)
    Require-File -Path (Join-Path $DocsVital "UH_GUARD_SPEC_v1.md") -Label "UH_GUARD_SPEC_v1"
    Require-File -Path (Join-Path $DocsVital "HUMANIA_DOCUMENTATION_AND_PROGRESS_LAW_v1.txt") -Label "HUMANIA_DOCUMENTATION_AND_PROGRESS_LAW_v1"

    # --- Encoding invariant (fail-closed): scripts canónicos deben ser UTF-8 con BOM ---
$bomVerifier = "C:\HUMANIA\verifiers\verify_utf8_bom_ps1.ps1"
if (!(Test-Path -LiteralPath $bomVerifier)) { throw "BOM_VERIFIER_MISSING: $bomVerifier" }

# Lista mínima crítica (ampliable)
& $bomVerifier -Paths @(
  "C:\HUMANIA\guard\UH_GUARD_RUN.ps1",
  "C:\HUMANIA\verifiers\verify_utf8_bom_ps1.ps1"
)
if ($LASTEXITCODE -ne 0) { throw "ENCODING_FAIL: UTF8_BOM required for critical scripts (exitcode=$LASTEXITCODE)" }
# --- End encoding invariant ---
    $ts = NowStamp

    Touch-Heartbeat -Path $Heartbeat -Phase "success" -RunId $RunId
        Write-Json -Path $LastSuccess -Obj @{
      ts      = (Get-Date -Format o)
      runid   = $RunId
      trigger = $Trigger
      status  = "PASS"
    }    Log $LogFile "[PASS] runid=$RunId status=PASS"
    Write-Host "[OK] Runner PASS."
  }
  finally {
    if ($lockFs) { $lockFs.Dispose() }
  }
}
catch {
  $err = $_.Exception.ToString()
  try {
    Write-Json -Path $LastFailure -Obj @{ ts=(Get-Date -Format o); runid=$RunId; trigger=$Trigger; error=$err }
  } catch {}
  try { Log $LogFile "[FAIL] runid=$RunId err=$err" } catch {}
  Write-Host "[FAIL] Runner FAIL (ver last_failure.json y logs)."
  exit 1
}





# ===============================
# ARTIFACT CONSISTENCY CHECK











# STAGE1_NOTE: minimal runtime candidate V2 generated outside repo
# STAGE1_NOTE: descriptive artifact generation removed
# STAGE1_NOTE: descriptive artifact validation removed
# STAGE1_NOTE: repo not modified by this operation
