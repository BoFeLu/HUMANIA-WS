param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Root = "C:\HUMANIA"
$Staging = Join-Path $Root "staging"
$LogDir = Join-Path $Staging "pre_chat_logs"
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null

$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$log = Join-Path $LogDir ("PRECHAT_VERIFY_{0}.log" -f $ts)

function Run-Step([string]$Name, [string]$File, [string]$Args) {
  Add-Content -Encoding UTF8 $log ("`n== STEP {0} ==" -f $Name)
  Add-Content -Encoding UTF8 $log ("cmd=powershell.exe -NoProfile -ExecutionPolicy Bypass -File ""{0}"" {1}" -f $File, $Args)

  $out = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $File @($Args -split ' ') 2>&1
  $rc = $LASTEXITCODE

  ($out | Out-String).TrimEnd() | Add-Content -Encoding UTF8 $log
  Add-Content -Encoding UTF8 $log ("rc={0}" -f $rc)

  if ($rc -ne 0) { throw ("FAIL_STEP:{0} rc={1} log={2}" -f $Name,$rc,$log) }
}

# A) audit_verify (integrity authoritative)
$Verify = Join-Path $Root "audit_verify.ps1"
if (!(Test-Path $Verify)) { throw "Missing: $Verify" }
Run-Step -Name "audit_verify_integrityonly" -File $Verify -Args "-Mode IntegrityOnly"

# B) classifier-policy
$V1 = Join-Path $Staging "verify_classifier_policy.ps1"
if (!(Test-Path $V1)) { throw "Missing: $V1" }
Run-Step -Name "verify_classifier_policy" -File $V1 -Args ""

# C) tri-consistency
$V2 = Join-Path $Staging "verify_action_tri_consistency.ps1"
if (!(Test-Path $V2)) { throw "Missing: $V2" }
Run-Step -Name "verify_action_tri_consistency" -File $V2 -Args ""

"PASS log={0}" -f $log
exit 0
