param(
  [Parameter(Mandatory=$true)]
  [string[]]$Paths
)

$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$bakDir = "C:\HUMANIA\logs\ENCODING_ADD_BOM_UTF8_$ts"
New-Item -ItemType Directory -Force -Path $bakDir | Out-Null

$utf8NoBom = New-Object Text.UTF8Encoding($false)
$utf8Bom   = New-Object Text.UTF8Encoding($true)

foreach($p in $Paths){
  if(!(Test-Path -LiteralPath $p)){
    Write-Host "SKIP (missing): $p"
    continue
  }

  $leaf = Split-Path $p -Leaf
  Copy-Item -LiteralPath $p -Destination (Join-Path $bakDir ($leaf + ".bak")) -Force

  # leer como UTF-8 (sin BOM) y reescribir con UTF-8 BOM
  $s = [IO.File]::ReadAllText($p, $utf8NoBom)
  [IO.File]::WriteAllText($p, $s, $utf8Bom)

  Write-Host "BOM_ADDED: $p"
}

Write-Host "Backup => $bakDir"
