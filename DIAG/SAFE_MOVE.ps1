param(
  [Parameter(Mandatory=$true)][string]$SourcePath,
  [Parameter(Mandatory=$true)][string]$DestDir
)

$pre="C:\HUMANIA\DIAG\UH_CRITICAL_PRECHECK.ps1"
$guard="C:\HUMANIA\DIAG\UH_PREMOVE_GUARD.ps1"

if (!(Test-Path $pre))  { Write-Host "[FAIL] Missing $pre"; exit 2 }
if (!(Test-Path $guard)){ Write-Host "[FAIL] Missing $guard"; exit 3 }

# 1) Critical presence check
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $pre
if ($LASTEXITCODE -ne 0) { Write-Host "[BLOCK] Critical precheck failed"; exit 10 }

# 2) Reference scan (core-only)
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $guard -TargetPath $SourcePath
if ($LASTEXITCODE -ne 0) { Write-Host "[BLOCK] Pre-move guard blocked"; exit 11 }

# 3) Execute move
if (!(Test-Path $DestDir)) { New-Item -Path $DestDir -ItemType Directory -Force | Out-Null }
Move-Item -LiteralPath $SourcePath -Destination $DestDir -Force

Write-Host "[OK] Moved: $SourcePath -> $DestDir"
exit 0
