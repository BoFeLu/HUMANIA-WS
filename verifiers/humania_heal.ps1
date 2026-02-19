$Root = "C:\HUMANIA"
$Vault = "$Root\verifiers\vault"
$Manifest = Get-Content "$Root\kernel_manifest.json" | ConvertFrom-Json

foreach ($item in $Manifest.items) {
    $fileName = Split-Path $item.path -Leaf
    $vaultFile = "$Vault\$fileName"
    $needsHeal = $false

    if (!(Test-Path $item.path)) { $needsHeal = $true }
    else {
        $currentHash = (Get-FileHash $item.path -Algorithm SHA256).Hash
        if ($currentHash -ne $item.sha256) { $needsHeal = $true }
    }

    if ($needsHeal) {
        Write-Host "[ALERTA] Corrupción detectada en $fileName. Restaurando..." -ForegroundColor Red
        Copy-Item $vaultFile -Destination $item.path -Force
    }
}
