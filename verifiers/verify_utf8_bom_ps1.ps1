param(
  [Parameter(Mandatory=$true)]
  [string[]]$Paths
)

function Has-Utf8Bom([byte[]]$b){
  return ($b.Length -ge 3 -and $b[0] -eq 0xEF -and $b[1] -eq 0xBB -and $b[2] -eq 0xBF)
}

$fail = 0
foreach($p in $Paths){
  if(!(Test-Path -LiteralPath $p)){
    Write-Host "FAIL(MISSING): $p"
    $fail++
    continue
  }
  $b = [System.IO.File]::ReadAllBytes($p)
  if(Has-Utf8Bom $b){
    Write-Host "OK(UTF8_BOM): $p"
  } else {
    $head = ($b[0..([Math]::Min(15,$b.Length-1))] | ForEach-Object { "{0:X2}" -f $_ }) -join " "
    Write-Host "FAIL(NO_BOM): $p | FIRST_BYTES_HEX=$head"
    $fail++
  }
}

if($fail -gt 0){ exit 2 }
exit 0
