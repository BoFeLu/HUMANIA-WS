# HUMANIA N2 - VERIFICADOR ESTABLE (SIN BUCLES)
$ManifestPath = "C:\HUMANIA\kernel_manifest.json"
Write-Host "`n[ANALIZADOR N2]: Verificando integridad de la Red..." -ForegroundColor Yellow

$Manifest = Get-Content $ManifestPath | ConvertFrom-Json

foreach ($Item in $Manifest.items) {
    if (Test-Path $Item.path) {
        $CurrentHash = (Get-FileHash $Item.path -Algorithm SHA256).Hash
        
        # SI EL ARCHIVO ES EL MANIFIESTO, SOLO VERIFICAMOS QUE EXISTA Y SEA LEGIBLE
        if ($Item.path -like "*kernel_manifest.json") {
            Write-Host "[OK]: $($Item.path) - Registro de sistema activo." -ForegroundColor Cyan
        } 
        # PARA EL RESTO DE SCRIPTS, EXIGIMOS HASH PERFECTO
        elseif ($CurrentHash -eq $Item.sha256) {
            Write-Host "[OK]: $($Item.path) - Hash verificado." -ForegroundColor Green
        } 
        else {
            Write-Host "[ALERTA]: $($Item.path) - ¡MODIFICACIÓN DETECTADA!" -ForegroundColor Red
        }
    }
}
Write-Host "`n--- Sistema en equilibrio ---" -ForegroundColor Yellow