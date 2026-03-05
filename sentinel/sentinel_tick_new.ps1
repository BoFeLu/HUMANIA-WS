# --- ULTRAHUMANIA SENTINEL CORE V3.0 (ULTRAEXCELENCIA) ---
$ManifestPath = "C:\HUMANIA\sentinel\manifest.json"
$StateFile = "C:\HUMANIA\sentinel\last_alert.state" # Control de Fatiga
$DocPaths = @("C:\HUMANIA\INFRA_MAP.md", "$env:USERPROFILE\Desktop\INFRA_MAP.md")

try {
    if (!(Test-Path $ManifestPath)) { throw "Manifiesto no encontrado" }
    $Manifest = Get-Content $ManifestPath | ConvertFrom-Json
    $StatusReport = "### ESTADO DE INFRAESTRUCTURA - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n`n"

    foreach ($Item in $Manifest.items) {
        $Exists = Test-Path $Item.path
        if ($Exists) {
            $CurrentHash = (Get-FileHash $Item.path -Algorithm SHA256).Hash
            if ($CurrentHash -eq $Item.sha256) {
                Write-Host "[OK]: $($Item.path)" -ForegroundColor Green
                $StatusReport += "- **[OK]** $($Item.path) (Integridad verificada)`n"
            } else { throw "MODIFICACIÓN DETECTADA en $($Item.path)" }
        } else { throw "ARCHIVO ELIMINADO: $($Item.path)" }
    }

    # AUTO-DOCUMENTACIÓN: Escribir en raíz y escritorio
    $StatusReport += "`n---`n*Generado automáticamente por Sentinel V3.0*"
    $StatusReport | Out-File $DocPaths[0] -Encoding utf8
    $StatusReport | Copy-Item -Destination $DocPaths[1] -Force

} catch {
    $ErrorMsg = "ALERTA CRÍTICA: $($_.Exception.Message)"
    Write-Host "[FALLO]: $ErrorMsg" -ForegroundColor Red
    
    # LEY DE FATIGA: Solo avisa si han pasado más de 10 min desde la última alerta
    $SendAlert = $true
    if (Test-Path $StateFile) {
        $LastAlert = Get-Item $StateFile
        if ($LastAlert.LastWriteTime -gt (Get-Date).AddMinutes(-10)) { $SendAlert = $false }
    }

    if ($SendAlert) {
        New-Item $StateFile -ItemType File -Force | Out-Null
        Invoke-Expression "msg * /TIME:0 '$ErrorMsg'"
    }
}
