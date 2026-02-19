param(
  [string]$LogPath = "C:\HUMANIA\AUDIT_CHAIN.jsonl",
  [switch]$NoRunPairCheck
)

Set-StrictMode -Version Latest

function Get-RunIdSafe {
  param([Parameter(Mandatory=$true)]$Obj)
  try {
    if ($null -eq $Obj) { return "" }
    if ($Obj.PSObject.Properties.Match("data").Count -eq 0) { return "" }
    $d = $Obj.data
    if ($null -eq $d) { return "" }
    if ($d.PSObject.Properties.Match("run_id").Count -eq 0) { return "" }
    if ($null -eq $d.run_id) { return "" }
    return [string]$d.run_id
  } catch { return "" }
}
$ErrorActionPreference = "Stop"

function Sha256HexUtf8 {
  param([Parameter(Mandatory=$true)][string]$Text)
  $sha = [System.Security.Cryptography.SHA256]::Create()
  try {
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
    $hash  = $sha.ComputeHash($bytes)
    return ([BitConverter]::ToString($hash) -replace "-", "").ToLower()
  } finally {
    $sha.Dispose()
  }
}

function Fail {
  param([int]$Code,[string]$Msg)
  Write-Error $Msg
  exit $Code
}

if (!(Test-Path $LogPath)) {
  Write-Host ("OK: audit log not found (treat as empty): {0}" -f $LogPath)
  exit 0
}

$absLog = (Resolve-Path $LogPath).Path

# Stream read to handle large logs without loading into memory
$fs = [System.IO.File]::Open(
  $absLog,
  [System.IO.FileMode]::Open,
  [System.IO.FileAccess]::Read,
  [System.IO.FileShare]::ReadWrite
)
$sr = New-Object System.IO.StreamReader($fs, (New-Object System.Text.UTF8Encoding($false)))

$prevExpected = ("0" * 64)
$openRuns = @{}
$lineNo = 0
$nonEmpty = 0
$lastEvent = ""
$lastRunId = ""
$lastLineNo = 0

try {
  while (($line = $sr.ReadLine()) -ne $null) {
    $lineNo++
    if ($null -eq $line) { continue }

    $s = $line.Trim()
    if ($s.Length -eq 0) { continue }
    $nonEmpty++
    $lastLineNo = $lineNo

    try {
      $obj = $s | ConvertFrom-Json -ErrorAction Stop
    } catch {
      Fail 1 ("FAIL line {0}: invalid JSON" -f $lineNo)
    }

    if ($null -eq $obj.prev_hash)  { Fail 1 ("FAIL line {0}: missing prev_hash"  -f $lineNo) }
    if ($null -eq $obj.entry_hash) { Fail 1 ("FAIL line {0}: missing entry_hash" -f $lineNo) }

    $prevHash  = [string]$obj.prev_hash
    $entryHash = [string]$obj.entry_hash

    if ($prevHash -ne [string]$prevExpected) {
      Fail 1 ("FAIL line {0}: prev_hash mismatch (got {1}, expected {2})" -f $lineNo,$prevHash,$prevExpected)
    }

    # Reconstruct the exact hashed core string:
    # the writer hashed ConvertTo-Json -Compress of the ordered object WITHOUT entry_hash,
    # then wrote the object WITH entry_hash. So strip the trailing entry_hash field from the raw line.
    $coreRaw = $s -replace ',"entry_hash":"[^"]+"\}$','}'
    if ($coreRaw -eq $s) {
      Fail 2 ("FAIL line {0}: cannot strip entry_hash safely (format unexpected)" -f $lineNo)
    }

    $calc = Sha256HexUtf8 -Text $coreRaw
    if ($calc -ne $entryHash) {
      Fail 2 ("FAIL line {0}: entry_hash mismatch (got {1}, calc {2})" -f $lineNo,$entryHash,$calc)
    }

    $prevExpected = $entryHash

    $lastEvent = [string]$obj.event
    $rid = (Get-RunIdSafe $obj); if ($rid) { $lastRunId = $rid } else { $lastRunId = "" }

    $rid = (Get-RunIdSafe $obj); if (-not $NoRunPairCheck -and $obj.event -and $rid) {
      $rid = $rid
      $ev  = [string]$obj.event

      if ($ev -eq "ACTION_START") {
        if (-not $openRuns.ContainsKey($rid)) { $openRuns[$rid] = $lineNo }
      } elseif ($ev -eq "ACTION_END") {
        if ($openRuns.ContainsKey($rid)) { [void]$openRuns.Remove($rid) }
      }
    }
  }
} finally {
  $sr.Close()
  $fs.Close()
}

if (-not $NoRunPairCheck -and $openRuns.Count -gt 0) {
  # Allow exactly one trailing ACTION_START for the last run_id (interpreted as interrupted run)
  if ($openRuns.Count -eq 1 -and $lastEvent -eq "ACTION_START" -and $openRuns.ContainsKey($lastRunId)) {
    Write-Warning ("WARN: trailing ACTION_START without ACTION_END for run_id={0} (line {1}); treating as interrupted run." -f $lastRunId,$openRuns[$lastRunId])
  } else {
    $first = $openRuns.GetEnumerator() | Select-Object -First 1
    Fail 3 ("GATE FAIL: missing ACTION_END for run_id={0} (ACTION_START at line {1})" -f $first.Key,$first.Value)
  }
}

Write-Host ("OK: verified {0} entries: {1}" -f $nonEmpty,$absLog)
exit 0
