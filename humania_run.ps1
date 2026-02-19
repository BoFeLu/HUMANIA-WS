param(
  [Parameter(Mandatory=$true)][string]$Action,
  [Parameter(Mandatory=$false)][string]$Command
)

# --- KERNEL AUTO-ROOT (REPARADO) ---
$Root = "C:\HUMANIA"

$KernelManifest = "$Root\kernel_manifest.json"
$KernelVerify   = "$Root\verifiers\kernel_manifest_verify.ps1"



# ---------------- KERNEL READ_ONLY GATE (manifest-based) ----------------

function Kernel-Gate {
  param([string]$ActionName)

  if (!(Test-Path $KernelManifest) -or !(Test-Path $KernelVerify)) {
    # Missing gate components => block everything except NOOP
    if ($ActionName -ne "NOOP") { return $false }
    return $true
  }

  $out = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $KernelVerify 2>&1
  $rc  = $LASTEXITCODE
  if ($rc -eq 0) { return $true }

  # If kernel mismatch => only allow NOOP
  if ($ActionName -ne "NOOP") { return $false }
  return $true
}

# Enforce before doing anything else
if (-not (Kernel-Gate -ActionName $Action)) {
  Add-AuditEntry -Event "ACTION_END" -Data @{
    action=$Action
    run_id="KERNEL_GATE_BLOCK"
    exit_code=98
    output=("BLOCKED: kernel_manifest mismatch or missing. Action denied. manifest=" + $KernelManifest)
  }
  exit 98
}
# -----------------------------------------------------------------------
$Guard = "$Root\humania_guard.ps1"
$Log  = "$Root\AUDIT_CHAIN.jsonl"

function Add-AuditEntry {
  param([string]$Event,[hashtable]$Data)

  $prev = ("0" * 64)
  $last = Get-Content $Log -Tail 1 -ErrorAction SilentlyContinue
  if ($last) { $prev = (ConvertFrom-Json $last).entry_hash }

  $obj = [ordered]@{
    ts_utc    = (Get-Date).ToUniversalTime().ToString("o")
    event     = $Event
    data      = $Data
    prev_hash = $prev
  }

  $core = ($obj | ConvertTo-Json -Compress)
  $bytes = [Text.Encoding]::UTF8.GetBytes($core)
  $stream = New-Object IO.MemoryStream(,$bytes)
  $hash = (Get-FileHash -InputStream $stream -Algorithm SHA256).Hash.ToLower()

  $obj["entry_hash"] = $hash
  ($obj | ConvertTo-Json -Compress) | Out-File -FilePath $Log -Encoding UTF8 -Append
}

function Assert-AllowlistedCommand {
  param([string]$Cmd)

  if (!$Cmd -or $Cmd.Trim().Length -eq 0) { return }

  # Reject multiline / embedded newlines
  if ($Cmd -match "(\r|\n)") {
    throw "NON-COMPLIANT: multiline -Command is forbidden. Use powershell ... -File C:\HUMANIA\..."
  }

  # Must start with powershell(.exe)
  if ($Cmd -notmatch '^(?i)\s*powershell(?:\.exe)?\b') {
    throw "NON-COMPLIANT: command must start with powershell(.exe) and use -File."
  }

  # Accept -File "<path>" OR -File <path>
  if ($Cmd -match '(?i)\s-File\s+"([^"]+)"') {
    $p = $Matches[1]
  } elseif ($Cmd -match '(?i)\s-File\s+([^\s]+)') {
    $p = $Matches[1]
  } else {
    throw "NON-COMPLIANT: command must use -File C:\HUMANIA\... (quoted or unquoted)."
  }

  $abs = [System.IO.Path]::GetFullPath($p)

  if ($abs -notlike 'C:\HUMANIA\*') {
    throw "NON-COMPLIANT: -File path must be under C:\HUMANIA\ (got: $abs)"
  }
  if (!(Test-Path $abs)) {
    throw "NON-COMPLIANT: -File target not found: $abs"
  }
}

# Pre-flight (blocks on integrity failure)
powershell -ExecutionPolicy Bypass -File $Guard -Action $Action
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$runId = [Guid]::NewGuid().ToString()

Add-AuditEntry -Event "ACTION_START" -Data @{
  action=$Action
  run_id=$runId
  host=$env:COMPUTERNAME
  user=$env:USERNAME
  command=$Command
}

if ($Command -and $Command.Trim().Length -gt 0) {
  try {
    Assert-AllowlistedCommand -Cmd $Command

    # Execute the provided command string (allowlisted)
    $out = powershell -NoProfile -ExecutionPolicy Bypass -Command $Command 2>&1
    $code = $LASTEXITCODE

    Add-AuditEntry -Event "ACTION_END" -Data @{
      action=$Action
      run_id=$runId
      exit_code=$code
      output=($out | Out-String)
    }
    exit $code
  } catch {
    Add-AuditEntry -Event "ACTION_END" -Data @{
      action=$Action
      run_id=$runId
      exit_code=99
      output=("BLOCKED: " + ($_ | Out-String))
    }
    exit 99
  }
} else {
  Add-AuditEntry -Event "ACTION_END" -Data @{
    action=$Action
    run_id=$runId
    exit_code=0
    output="NO COMMAND (logged only)"
  }
  exit 0
}


