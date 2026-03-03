param(
  [Parameter(Mandatory=$true)]
  [string[]]$Paths,

  [int]$Passes = 2
)

$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$bakDir = "C:\HUMANIA\logs\ENCODING_FIX_${ts}"
New-Item -ItemType Directory -Force -Path $bakDir | Out-Null

$cp1252 = [Text.Encoding]::GetEncoding(1252)
$utf8   = New-Object Text.UTF8Encoding($false)

function Fix-Once([string]$s) {
  # Interpret current text as if it were CP1252 bytes and decode as UTF-8
  $b = $cp1252.GetBytes($s)
  return $utf8.GetString($b)
}

foreach($p in $Paths){
  if(!(Test-Path -LiteralPath $p)){
    Write-Host "SKIP (missing): $p"
    continue
  }

  # Backup exacto antes de tocar
  $leaf = Split-Path $p -Leaf
  $dstBak = Join-Path $bakDir ($leaf + ".bak")
  Copy-Item -LiteralPath $p -Destination $dstBak -Force

  # Leer y aplicar N pasadas
  $t = Get-Content -LiteralPath $p -Raw
  for($i=1; $i -le $Passes; $i++){
    $t = Fix-Once $t
  }

  # Guardar como UTF-8 sin BOM
  [IO.File]::WriteAllText($p, $t, $utf8)

  Write-Host "OK: $p"
}

Write-Host "Backup => $bakDir"
