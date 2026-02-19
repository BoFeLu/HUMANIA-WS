$Root = "C:\HUMANIA"
$ManifestPath = "$Root\kernel_manifest.json"
if (!(Test-Path $ManifestPath)) { exit 1 }

$Manifest = Get-Content $ManifestPath | ConvertFrom-Json
$Success = $true

foreach ($item in $Manifest.items) {
    $fileName = Split-Path $item.path -Leaf
    # EXCEPCIONES OPERATIVAS: Archivos que cambian por diseño
    if ($fileName -eq "kernel_manifest.json" -or $fileName -eq "AUDIT_CHAIN.jsonl") { continue }

    if (!(Test-Path $item.path)) { $Success = $false; break }
    $currentHash = (Get-FileHash $item.path -Algorithm SHA256).Hash
    if ($currentHash -ne $item.sha256) { $Success = $false; break }
}

if ($Success) { exit 0 } else { exit 1 }
