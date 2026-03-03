param(
  [Parameter(Mandatory=$true)]
  [string]$FromDir,
  [string]$Root = "C:\HUMANIA"
)

Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"

$files = @(
  "humania_run.ps1",
  "humania_guard.ps1",
  "audit_verify.ps1",
  "kernel_manifest.json"
)

foreach($f in $files){
  $src = Join-Path $FromDir $f
  if(!(Test-Path $src)){ throw "MISSING_IN_BACKUP: $src" }
}

# Copy into place (overwrite)
foreach($f in $files){
  Copy-Item -Force (Join-Path $FromDir $f) (Join-Path $Root $f)
}

# Verify
$srcH = Get-FileHash ($files | ForEach-Object { Join-Path $FromDir $_ }) -Algorithm SHA256 | Sort-Object Path
$dstH = Get-FileHash ($files | ForEach-Object { Join-Path $Root $_ }) -Algorithm SHA256 | Sort-Object Path

for($i=0;$i -lt $srcH.Count;$i++){
  if($srcH[$i].Hash -ne $dstH[$i].Hash){
    throw "RESTORE_HASH_MISMATCH"
  }
}

"OK_RESTORE_FROM: $FromDir"
