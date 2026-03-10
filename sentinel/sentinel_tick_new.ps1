# --- ULTRAHUMANIA SENTINEL CORE V3.1 ---
$ErrorActionPreference = 'Stop'

$ManifestPath = "C:\HUMANIA\sentinel\manifest.json"
$StateFile = "C:\HUMANIA\sentinel\last_alert.state"
$DocPaths = @(
    "C:\HUMANIA\INFRA_MAP.md",
    "$env:USERPROFILE\Desktop\INFRA_MAP.md"
)

try {
    if (!(Test-Path -LiteralPath $ManifestPath)) {
        throw "Manifest not found: $ManifestPath"
    }

    $Manifest = Get-Content -LiteralPath $ManifestPath -Raw | ConvertFrom-Json
    $StatusReport = "### ESTADO DE INFRAESTRUCTURA - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`r`n`r`n"

    foreach ($Item in $Manifest.items) {
        $Exists = Test-Path -LiteralPath $Item.path
        if (-not $Exists) {
            throw "ARCHIVO ELIMINADO: $($Item.path)"
        }

        $CurrentHash = (Get-FileHash -LiteralPath $Item.path -Algorithm SHA256).Hash
        if ($CurrentHash -ne $Item.sha256) {
            throw "MODIFICACION DETECTADA en $($Item.path)"
        }

        Write-Host "[OK] $($Item.path)" -ForegroundColor Green
        $StatusReport += "- [OK] $($Item.path) (Integridad verificada)`r`n"
    }

    $StatusReport += "`r`n---`r`nGenerado automaticamente por Sentinel V3.1`r`n"

    foreach ($path in $DocPaths) {
        $dir = Split-Path $path
        if (Test-Path -LiteralPath $dir) {
            $StatusReport | Set-Content -LiteralPath $path -Encoding UTF8
        }
    }

    exit 0
}
catch {
    $ErrorMsg = "ALERTA CRITICA: $($_.Exception.Message)"
    Write-Host "[FALLO] $ErrorMsg" -ForegroundColor Red

    $SendAlert = $true
    if (Test-Path -LiteralPath $StateFile) {
        $LastAlert = Get-Item -LiteralPath $StateFile
        if ($LastAlert.LastWriteTime -gt (Get-Date).AddMinutes(-10)) {
            $SendAlert = $false
        }
    }

    if ($SendAlert) {
        New-Item -ItemType File -Force -Path $StateFile | Out-Null
        try {
            msg * /TIME:0 "$ErrorMsg" | Out-Null
        } catch {
        }
    }

    exit 1
}
