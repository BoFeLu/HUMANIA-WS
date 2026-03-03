param(
  [Parameter(Mandatory=$true)]
  [string[]]$Paths
)

$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$bakDir = "C:\HUMANIA\logs\ENCODING_FIX_CP1252_TO_UTF8_$ts"
New-Item -ItemType Directory -Force -Path $bakDir | Out-Null

$cp1252 = [Text.Encoding]::GetEncoding(1252)
$utf8NoBom = New-Object Text.UTF8Encoding($false)

function LooksMojibake([string]$s){
  return ($s -match 'Ã|Â|â€|�')
}

foreach($p in $Paths){
  if(!(Test-Path -LiteralPath $p)){
    Write-Host "SKIP (missing): $p"
    continue
  }

  # leer bytes tal cual
  $bytes = [IO.File]::ReadAllBytes($p)

  # decodificar como UTF-8 (tal como estás viendo ahora)
  $current = [Text.Encoding]::UTF8.GetString($bytes)

  # backup exacto antes de tocar nada
  $leaf = Split-Path $p -Leaf
  $dstBak = Join-Path $bakDir ($leaf + ".bak")
  Copy-Item -LiteralPath $p -Destination $dstBak -Force

  if(!(LooksMojibake $current)){
    Write-Host "NOCHANGE (no mojibake detected): $p"
    continue
  }

  # Reparación: bytes CP1252 del texto actual -> reinterpretar como UTF-8
  $fixed = [Text.Encoding]::UTF8.GetString($cp1252.GetBytes($current))

  # Guardar como UTF-8 sin BOM
  [IO.File]::WriteAllText($p, $fixed, $utf8NoBom)

  Write-Host "FIXED: $p"
}

Write-Host "Backup => $bakDir"
