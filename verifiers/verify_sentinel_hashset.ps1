param(
  [string]$Baseline = ""
)

$ROOT="C:\HUMANIA"
if($Baseline -eq ""){
  $latest = Get-ChildItem "$ROOT\logs" -Filter "SENTINEL_HASHSET_*.txt" -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending | Select-Object -First 1
  if(!$latest){ Write-Host "[FAIL] No baseline found in $ROOT\logs"; exit 2 }
  $Baseline = $latest.FullName
}

$files=@(
  "$ROOT\staging\sentinel_tick_new.ps1",
  "$ROOT\staging\sentinel_tick_notify.ps1"
)

if(!(Test-Path $Baseline)){
  Write-Host "[FAIL] Baseline missing: $Baseline"
  exit 2
}

$base=@{}
Get-Content $Baseline | ForEach-Object {
  $line=$_.Trim()
  if($line -match '^[A-Za-z]:\\' -and $line -match '\s+[0-9A-Fa-f]{64}$'){
    $p=$line -replace '\s+[0-9A-Fa-f]{64}$',''
    $h=($line -split '\s+')[-1].ToUpperInvariant()
    $base[$p]=$h
  }
}

$ok=$true
foreach($f in $files){
  if(!(Test-Path $f)){
    Write-Host "[FAIL] Missing: $f"
    $ok=$false
    continue
  }
  $h=(Get-FileHash $f -Algorithm SHA256).Hash.ToUpperInvariant()
  if($base.ContainsKey($f)){
    if($h -ne $base[$f]){
      Write-Host "[FAIL] Mismatch: $f"
      Write-Host "  expected: $($base[$f])"
      Write-Host "  got     : $h"
      $ok=$false
    } else {
      Write-Host "[OK] $f"
    }
  } else {
    Write-Host "[WARN] Not in baseline: $f ($h)"
  }
}

if($ok){ exit 0 } else { exit 1 }