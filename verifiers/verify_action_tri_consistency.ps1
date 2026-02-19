param()

$root = "C:\HUMANIA"

$classifierPath = Join-Path $root "staging\ACTION_CLASSIFIER.ps1"
$policyPath     = Join-Path $root "docs\policies\ACTION_POLICY_MAP.json"
$allowPath      = Join-Path $root "allowed_actions.txt"

if (!(Test-Path $classifierPath) -or !(Test-Path $policyPath) -or !(Test-Path $allowPath)) {
  Write-Host "FAIL: missing required file"
  exit 2
}

# --- CLASSIFIER ACTIONS ---
$classifierText = Get-Content $classifierPath -Raw
$classifierActions = Select-String -InputObject $classifierText -Pattern '"([A-Z0-9_]+)"\s*\{' -AllMatches |
  ForEach-Object { $_.Matches } |
  ForEach-Object { $_.Groups[1].Value } |
  Sort-Object -Unique

# --- POLICY ACTIONS ---
$policy = Get-Content $policyPath -Raw | ConvertFrom-Json
$policyActions = @()
foreach ($kind in $policy.kinds.PSObject.Properties.Name) {
  $policyActions += $policy.kinds.$kind.allowed_actions
}
$policyActions = $policyActions | Sort-Object -Unique

# --- ALLOWLIST ACTIONS ---
$allowActions = Get-Content $allowPath |
  Where-Object { $_ -and ($_ -notmatch '^#') } |
  ForEach-Object { $_.Trim() } |
  Sort-Object -Unique

# --- DIFFS ---
$diff1 = $allowActions | Where-Object { $_ -notin $classifierActions }
$diff2 = $allowActions | Where-Object { $_ -notin $policyActions }

$diff3 = $classifierActions | Where-Object { $_ -notin $allowActions }
$diff4 = $policyActions | Where-Object { $_ -notin $allowActions }

$diff5 = $classifierActions | Where-Object { $_ -notin $policyActions }
$diff6 = $policyActions | Where-Object { $_ -notin $classifierActions }

if ($diff1 -or $diff2 -or $diff3 -or $diff4 -or $diff5 -or $diff6) {

  Write-Host "FAIL: action tri-consistency mismatch"

  if ($diff1) { Write-Host "InAllowNotInClassifier: $($diff1 -join ',')" }
  if ($diff2) { Write-Host "InAllowNotInPolicy: $($diff2 -join ',')" }

  if ($diff3) { Write-Host "InClassifierNotInAllow: $($diff3 -join ',')" }
  if ($diff4) { Write-Host "InPolicyNotInAllow: $($diff4 -join ',')" }

  if ($diff5) { Write-Host "InClassifierNotInPolicy: $($diff5 -join ',')" }
  if ($diff6) { Write-Host "InPolicyNotInClassifier: $($diff6 -join ',')" }

  exit 1
}

Write-Host "PASS"
exit 0
