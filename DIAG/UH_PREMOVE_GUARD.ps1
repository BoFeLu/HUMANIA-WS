param(
  [Parameter(Mandatory=$true)]
  [string]$TargetPath
)

$Root = "C:\HUMANIA"

# Scripts núcleo que importan (reduce ruido)
$coreScripts = @(
  "$Root\humania_run.ps1",
  "$Root\humania_guard.ps1"
) | Where-Object { Test-Path $_ }

# 1) Bloqueo si el TargetPath aparece referenciado en núcleo
foreach ($s in $coreScripts) {
  $hit = Select-String -LiteralPath $s -SimpleMatch -Pattern $TargetPath -ErrorAction SilentlyContinue
  if ($hit) {
    Write-Host "[BLOCK] TargetPath referenced in core script: $s"
    $hit | Select-Object Path,LineNumber,Line
    exit 10
  }
}

# 2) Si es carpeta: bloquear si contiene ficheros que el núcleo referencia por nombre
if (Test-Path $TargetPath -PathType Container) {
  $files = Get-ChildItem $TargetPath -Recurse -File -ErrorAction SilentlyContinue
  foreach ($f in $files) {
    foreach ($s in $coreScripts) {
      $hit2 = Select-String -Path $s -Pattern [Regex]::Escape($f.Name) -SimpleMatch -ErrorAction SilentlyContinue
      if ($hit2) {
        Write-Host "[BLOCK] Core references filename inside target: $($f.Name)"
        Write-Host " core=$s"
        Write-Host " inside=$($f.FullName)"
        exit 11
      }
    }
  }
}

Write-Host "[OK] Pre-move scan passed (core-only)."
exit 0

