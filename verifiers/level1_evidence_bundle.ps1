param(
  [string]$Root = "C:\HUMANIA",
  [string]$BackupRoot = "D:\HUMANIA_BACKUP_SECURE"
)

Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"

$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$OutDir = Join-Path $Root ("logs\evidence\level1_" + $ts)
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

function SaveText([string]$Path, [string]$Text){
  $Text | Set-Content -Encoding UTF8 -LiteralPath $Path
}

# 1) Level1 verifier: output + exitcode
$L1 = Join-Path $Root "verifiers\self_integrity_level1.ps1"
$L1_OUT = Join-Path $OutDir "SELF_INTEGRITY_LEVEL1.txt"

$proc = Start-Process -FilePath "powershell.exe" -ArgumentList @(
  "-NoProfile","-ExecutionPolicy","Bypass","-File",$L1
) -NoNewWindow -PassThru -Wait -RedirectStandardOutput (Join-Path $OutDir "SELF_INTEGRITY_LEVEL1_STDOUT.txt") -RedirectStandardError (Join-Path $OutDir "SELF_INTEGRITY_LEVEL1_STDERR.txt")

# Unificar salida para lectura humana
$stdout = Get-Content -LiteralPath (Join-Path $OutDir "SELF_INTEGRITY_LEVEL1_STDOUT.txt") -Raw -ErrorAction SilentlyContinue
$stderr = Get-Content -LiteralPath (Join-Path $OutDir "SELF_INTEGRITY_LEVEL1_STDERR.txt") -Raw -ErrorAction SilentlyContinue
SaveText $L1_OUT ($stdout + "`n" + $stderr)

SaveText (Join-Path $OutDir "SELF_INTEGRITY_LEVEL1_EXITCODE.txt") ("exitcode=" + $proc.ExitCode)

# 2) Kernel hashset (C:\)
$kernelC = @(
  (Join-Path $Root "humania_run.ps1"),
  (Join-Path $Root "humania_guard.ps1"),
  (Join-Path $Root "audit_verify.ps1"),
  (Join-Path $Root "kernel_manifest.json")
)

Get-FileHash -Algorithm SHA256 -LiteralPath $kernelC |
  Sort-Object Path |
  Format-Table -AutoSize | Out-String |
  Set-Content -Encoding UTF8 -LiteralPath (Join-Path $OutDir "KERNEL_SHA256_C.txt")

# 3) Discover last kernel backup in D:\ and compare
$last = Get-ChildItem -LiteralPath $BackupRoot -Directory -Filter "KERNEL_*" |
  Sort-Object LastWriteTime -Descending | Select-Object -First 1

if($null -eq $last){
  SaveText (Join-Path $OutDir "KERNEL_BACKUP_LAST_PATH.txt") "NONE"
  throw "NO_KERNEL_BACKUP_FOUND_UNDER: $BackupRoot"
}

SaveText (Join-Path $OutDir "KERNEL_BACKUP_LAST_PATH.txt") $last.FullName

$kernelD = @(
  (Join-Path $last.FullName "humania_run.ps1"),
  (Join-Path $last.FullName "humania_guard.ps1"),
  (Join-Path $last.FullName "audit_verify.ps1"),
  (Join-Path $last.FullName "kernel_manifest.json")
)

Get-FileHash -Algorithm SHA256 -LiteralPath $kernelD |
  Sort-Object Path |
  Format-Table -AutoSize | Out-String |
  Set-Content -Encoding UTF8 -LiteralPath (Join-Path $OutDir "KERNEL_SHA256_D_LAST.txt")

$src = Get-FileHash -Algorithm SHA256 -LiteralPath $kernelC | Sort-Object Path
$dst = Get-FileHash -Algorithm SHA256 -LiteralPath $kernelD | Sort-Object Path

Compare-Object ($src.Hash) ($dst.Hash) -IncludeEqual |
  Format-Table -AutoSize | Out-String |
  Set-Content -Encoding UTF8 -LiteralPath (Join-Path $OutDir "KERNEL_HASH_COMPARE_C_vs_D_LAST.txt")

"OK_EVIDENCE_BUNDLE => $OutDir"
