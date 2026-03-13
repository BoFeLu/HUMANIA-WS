param(
  [string]$Root = "C:\HUMANIA",
  [string]$OutPath = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function NowStamp { (Get-Date).ToString("yyyyMMdd_HHmmss") }

function Sha256([string]$p) {
  (Get-FileHash -Algorithm SHA256 -Path $p).Hash
}

if (!(Test-Path $Root)) { throw "MISSING_ROOT: $Root" }

# Canonical roots (must match UH_GUARD_RUN CoreStructure)
$RootDirs = @(
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

# Noise exclusions (keeps project knowable, avoids endless churn)
# NOTE: logs\watchdog contains service-managed hot logs that may be locked by WinSW.
# NOTE: BIN\winsw*.log are also hot service-managed logs and must not be hashed.
$ExcludePrefixes = @(
  (Join-Path $Root "logs\outputs"),
  (Join-Path $Root "logs\diagnostics"),
  (Join-Path $Root "logs\auto_tick"),
  (Join-Path $Root "logs\evidence"),
  (Join-Path $Root "logs\watchdog"),
  (Join-Path $Root "state\locks")
)

$ExcludeExactPaths = @(
  (Join-Path $Root "BIN\winsw.err.log"),
  (Join-Path $Root "BIN\winsw.out.log"),
  (Join-Path $Root "BIN\winsw.wrapper.log"),
  (Join-Path $Root "BIN\winsw.out.log.old")
)

$ts = NowStamp
if ([string]::IsNullOrWhiteSpace($OutPath)) {
  $OutPath = Join-Path (Join-Path $Root "docs\context") ("INVENTORY_CANON_{0}.json" -f $ts)
}

# Build file list
$targets = foreach ($d in $RootDirs) {
  $p = Join-Path $Root $d
  if (Test-Path $p) { $p }
}

$files = foreach ($t in $targets) {
  Get-ChildItem -Path $t -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object {
      $full = $_.FullName
      $skip = $false
      foreach ($x in $ExcludePrefixes) {
        if ($full.StartsWith($x, [System.StringComparison]::OrdinalIgnoreCase)) { $skip = $true; break }
      }
      if (-not $skip) {
        foreach ($x in $ExcludeExactPaths) {
          if ($full.Equals($x, [System.StringComparison]::OrdinalIgnoreCase)) { $skip = $true; break }
        }
      }
      -not $skip
    }
}

# Deterministic ordering
$files = $files | Sort-Object FullName

$items = foreach ($f in $files) {
  [ordered]@{
    path = $f.FullName
    sha256 = (Sha256 -p $f.FullName)
    length = [int64]$f.Length
    last_write_time_utc = $f.LastWriteTimeUtc.ToString("o")
  }
}

$obj = [ordered]@{
  schema = "INVENTORY_CANON_V1"
  ts_utc = (Get-Date).ToUniversalTime().ToString("o")
  root = $Root
  root_dirs = $RootDirs
  exclude_prefixes = $ExcludePrefixes
  exclude_exact_paths = $ExcludeExactPaths
  file_count = $items.Count
  items = $items
}

$obj | ConvertTo-Json -Depth 6 | Set-Content -Encoding UTF8 -Path $OutPath

"[OK] WROTE=" + $OutPath
"FILE_COUNT=" + $items.Count
