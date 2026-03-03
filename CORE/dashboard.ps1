# C:\HUMANIA\CORE\dashboard.ps1
function Show-UHDashboard {
    cls
    $Timestamp = Get-Date -Format "HH:mm:ss"
    $Guardian = Get-Process guardian -ErrorAction SilentlyContinue
    $Postgres = Get-Service postgresql* | Where-Object {$_.Status -eq 'Running'}

    Write-Host "====================================================" -ForegroundColor Cyan
    Write-Host "       ULTRAHUMANIA - CORE TELEMETRY V1.0" -ForegroundColor Cyan
    Write-Host "====================================================" -ForegroundColor Cyan
    Write-Host " HORA ACTUAL: $Timestamp"
    Write-Host "----------------------------------------------------"
    
    # Estado del Guardián (Rust)
    if ($Guardian) {
        Write-Host " [STATUS] GUARDIAN (Rust):  " -NoNewline
        Write-Host "ONLINE" -ForegroundColor Green -BackgroundColor Black
    } else {
        Write-Host " [STATUS] GUARDIAN (Rust):  " -NoNewline
        Write-Host "OFFLINE" -ForegroundColor Red
    }

    # Estado de PostgreSQL
    if ($Postgres) {
        Write-Host " [STATUS] DATABASE (v17):  " -NoNewline
        Write-Host "ONLINE" -ForegroundColor Green -BackgroundColor Black
    } else {
        Write-Host " [STATUS] DATABASE (v17):  " -NoNewline
        Write-Host "OFFLINE" -ForegroundColor Red
    }

    Write-Host "----------------------------------------------------"
    Write-Host " ÚLTIMA LEY INYECTADA:" -ForegroundColor Gray
    & psql -U postgres -d ultrahumania -t -c "SELECT titulo FROM leyes.constitucion ORDER BY id_ley DESC LIMIT 1;"
    Write-Host "====================================================" -ForegroundColor Cyan
}

# Ejecutar una vez para prueba
Show-UHDashboard