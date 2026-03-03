# HUMANIA N2 - SCRIPT DE CURACIÓN FORTALECIDO
$Root = "C:\HUMANIA"
$Vault = "$Root\verifiers\vault"
$ManifestPath = "$Root\verifiers\kernel_manifest.json"

Write-Host "`n[ESCUDO N2]: Iniciando verificación de integridad reforzada..." -ForegroundColor Cyan

# Verificación de existencia del manifiesto
if (-not (Test-Path $ManifestPath)) {
    Write-Host "[!] ERROR: Manifiesto no encontrado. El sistema está ciego." -ForegroundColor Red
    exit
}

$Manifest = Get-Content $ManifestPath | ConvertFrom-Json

foreach ($Entry in $Manifest.files) {
    $FilePath = Join-Path $Root $Entry.path
    
    if (Test-Path $FilePath) {
        # Cálculo del hash actual
        $CurrentHash = (Get-FileHash $FilePath -Algorithm SHA256).Hash
        
        if ($CurrentHash -ne $Entry.hash) {
            Write-Host "[!] ALERTA: Archivo $($Entry.path) CORRUPTO o MODIFICADO." -ForegroundColor Red
            Write-Host "[+] Restaurando desde la Vault segura..." -ForegroundColor Yellow
            Copy-Item -Path (Join-Path $Vault (Split-Path $Entry.path -Leaf)) -Destination $FilePath -Force
        } else {
            Write-Host "[OK]: $($Entry.path) verificado y seguro." -ForegroundColor Green
        }
    } else {
        Write-Host "[!] CRÍTICO: Falta el archivo $($Entry.path). Restaurando..." -ForegroundColor Magenta
        Copy-Item -Path (Join-Path $Vault (Split-Path $Entry.path -Leaf)) -Destination $FilePath -Force
    }
}