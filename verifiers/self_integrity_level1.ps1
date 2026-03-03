param()

$ErrorActionPreference = "Stop"

$Root = "C:\HUMANIA"
$OutDir = "$Root\logs"
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$OUT = "$OutDir\SELF_INTEGRITY_LEVEL1_$ts.txt"

function Write-Line([string]$s){
  $s | Add-Content -LiteralPath $OUT -Encoding UTF8
  Write-Host $s
}

$fail = $false

try {
  # 1) Kernel presence
  $kernel = @(
    "$Root\humania_run.ps1",
    "$Root\humania_guard.ps1",
    "$Root\audit_verify.ps1",
    "$Root\kernel_manifest.json"
  )
  $present = ($kernel | Where-Object { Test-Path -LiteralPath $_ }).Count
  if($present -eq 4){ Write-Line "[OK] Kernel files present (4/4)" }
  else { Write-Line "[FAIL] Kernel files present ($present/4)"; $fail=$true }

  # 2) ACL anti-delete for operator (DENY DE) on kernel
  $me = "$env:USERDOMAIN\$env:USERNAME"
  $need = "(DENY)(DE)"
  $aclOk = $true
  foreach($f in $kernel){
    if(!(Test-Path -LiteralPath $f)){ $aclOk=$false; continue }
    $acl = (icacls $f 2>$null | Out-String)
    if($acl -notmatch [regex]::Escape($me) -or $acl -notmatch [regex]::Escape($need)){
      $aclOk = $false
    }
  }
  if($aclOk){ Write-Line "[OK] ACL anti-delete present for operator on kernel (DENY DE)" }
  else { Write-Line "[FAIL] ACL anti-delete missing on kernel"; $fail=$true }

  # 3) Docs structure (canonical dirs)
  $docs = "$Root\docs"
  $reqDirs = @("context","governance","laws","policies","procedures")
  $missing = @()
  foreach($d in $reqDirs){
    $p = Join-Path $docs $d
    if(!(Test-Path -LiteralPath $p)){ $missing += $p }
  }
  if($missing.Count -eq 0){ Write-Line "[OK] Docs structure OK" }
  else {
    foreach($m in $missing){ Write-Line "[FAIL] Docs dir missing: $m" }
    $fail = $true
  }

  # 4) Case-dup detection (robusto en Windows): dir /ad es la “realidad observable”
  # Si hubiera realmente 2 entradas distintas, aparecerían 2 líneas distintas.
  $dirText = (cmd /c 'dir /ad "C:\HUMANIA\docs"' 2>$null | Out-String)
  $hits = ([regex]::Matches($dirText, '^\s*\d{2}\/\d{2}\/\d{4}\s+\d{2}:\d{2}\s+\<DIR\>\s+procedures\s*$', "IgnoreCase,Multiline")).Count

  if($hits -eq 1){
    Write-Line "[OK] No case-dup dir for procedures (dir listing canonical)"
  } elseif($hits -eq 0) {
    Write-Line "[FAIL] procedures dir not visible in dir listing"
    $fail = $true
  } else {
    Write-Line "[FAIL] Case-dup dir appears multiple times in dir listing: procedures"
    $fail = $true
  }

} catch {
  Write-Line "[FAIL] Exception: $($_.Exception.Message)"
  $fail = $true
}

if($fail){ exit 1 } else { exit 0 }
