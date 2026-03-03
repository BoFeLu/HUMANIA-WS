param(
  [Parameter(Mandatory=$true)]
  [string[]]$Paths,

  [int]$MaxPasses = 4
)

$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$bakDir = "C:\HUMANIA\logs\ENCODING_FIX_MOJIBAKE_TO_UTF8_$ts"
New-Item -ItemType Directory -Force -Path $bakDir | Out-Null

$cp1252 = [Text.Encoding]::GetEncoding(1252)
$utf8NoBom = New-Object Text.UTF8Encoding($false)

function LooksMojibake([string]$s){
  return ($s -match 'Ã|Â|â€|�')
}

function FixOnce([string]$s){
  # Convert mojibake text -> proper unicode
  return [Text.Encoding]::UTF8.GetString($cp1252.GetBytes($s))
}

foreach($p in $Paths){
  if(!(Test-Path -LiteralPath $p)){
    Write-Host "SKIP (missing): $p"
    continue
  }

  # Backup exacto antes de tocar nada
  $leaf = Split-Path $p -Leaf
  $dstBak = Join-Path $bakDir ($leaf + ".bak")
  Copy-Item -LiteralPath $p -Destination $dstBak -Force

  # Leer como UTF-8 (tal como lo estás viendo)
  $bytes = [IO.File]::ReadAllBytes($p)
  $s = [Text.Encoding]::UTF8.GetString($bytes)

  if(!(LooksMojibake $s)){
    Write-Host "NOCHANGE (no mojibake detected): $p"
    continue
  }

  $pass = 0
  while($pass -lt $MaxPasses -and (LooksMojibake $s)){
    $new = FixOnce $s
    if($new -eq $s){ break }
    $s = $new
    $pass++
  }

  # Guardar como UTF-8 sin BOM
  [IO.File]::WriteAllText($p, $s, $utf8NoBom)

  Write-Host "FIXED(pass=$pass): $p"
}

Write-Host "Backup => $bakDir"
