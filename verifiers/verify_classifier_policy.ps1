param()

$root = "C:\HUMANIA"

$classifierPath = Join-Path $root "staging\ACTION_CLASSIFIER.ps1"
$policyPath     = Join-Path $root "docs\policies\ACTION_POLICY_MAP.json"

if (!(Test-Path $classifierPath) -or !(Test-Path $policyPath)) {
  Write-Host "FAIL: missing classifier or policy file"
  exit 2
}

# Extract classifier actions
$classifierText = Get-Content $classifierPath -Raw
$classifierActions = Select-String -InputObject $classifierText -Pattern '"([A-Z0-9_]+)"\s*\{' -AllMatches |
  ForEach-Object { $_.Matches } |
  ForEach-Object { $_.Groups[1].Value } |
  Sort-Object -Unique

# Extract policy actions
$policy = Get-Content $policyPath -Raw | ConvertFrom-Json
$policyActions = @()

foreach ($kind in $policy.kinds.PSObject.Properties.Name) {
  $policyActions += $policy.kinds.$kind.allowed_actions
}

$policyActions = $policyActions | Sort-Object -Unique

# Compare
$missingInPolicy = $classifierActions | Where-Object { $_ -notin $policyActions }
$missingInClassifier = $policyActions | Where-Object { $_ -notin $classifierActions }

if ($missingInPolicy.Count -gt 0 -or $missingInClassifier.Count -gt 0) {
  Write-Host "FAIL: classifier-policy mismatch"
  Write-Host "MissingInPolicy: $($missingInPolicy -join ',')"
  Write-Host "MissingInClassifier: $($missingInClassifier -join ',')"
  exit 1
}

Write-Host "PASS"
exit 0
