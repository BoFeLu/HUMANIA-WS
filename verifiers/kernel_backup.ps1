param(
  [string]$Root = "C:\HUMANIA",
  [string]$BackupRoot = "D:\HUMANIA_BACKUP_SECURE",
  [int]$Keep = 30
)

Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"

$ts = Get-Date -Format yyyyMMdd_HHmmss
$dest = Join-Path $BackupRoot ("KERNEL_" + $ts)
New-Item -ItemType Directory -Force -Path $dest | Out-Null

$files = @(
  "humania_run.ps1",
  "humania_guard.ps1",
  "audit_verify.ps1",
  "kernel_manifest.json"
)

# Copy kernel files
robocopy $Root $dest $files /R:2 /W:2 | Out-Null

# Hash + write
$dstPaths = $files | ForEach-Object { Join-Path $dest $_ }
Get-FileHash $dstPaths -Algorithm SHA256 |
  Sort-Object Path |
  Format-Table -AutoSize |
  Out-String |
  Set-Content -Encoding UTF8 (Join-Path $dest "KERNEL_HASHES.txt")

# Verify hashes match C:\ vs D:\
$srcPaths = $files | ForEach-Object { Join-Path $Root $_ }
$src = Get-FileHash $srcPaths -Algorithm SHA256 | Sort-Object Path
$dst = Get-FileHash $dstPaths -Algorithm SHA256 | Sort-Object Path

for($i=0;$i -lt $src.Count;$i++){
  if($src[$i].Hash -ne $dst[$i].Hash){
    throw "HASH_MISMATCH: $($src[$i].Path) vs $($dst[$i].Path)"
  }
}

# Rotation (keep last N)
$dirs = Get-ChildItem $BackupRoot -Directory -Filter "KERNEL_*" |
  Sort-Object Name -Descending

$toRemove = $dirs | Select-Object -Skip $Keep
foreach($d in $toRemove){
  Remove-Item -LiteralPath $d.FullName -Recurse -Force
}

"OK: $dest"
