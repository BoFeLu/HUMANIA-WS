$List="C:\HUMANIA\LEX\CRITICAL_PATHS.txt"
if (!(Test-Path $List)) { Write-Host "[FAIL] Missing list $List"; exit 2 }

$missing=@()
Get-Content $List | ForEach-Object {
  $p=$_.Trim()
  if ($p -and !(Test-Path $p)) { $missing += $p }
}

if ($missing.Count -gt 0) {
  Write-Host "[BLOCK] Missing critical paths:"
  $missing | ForEach-Object { Write-Host " - $_" }
  exit 10
}

Write-Host "[OK] All critical paths present."
exit 0
