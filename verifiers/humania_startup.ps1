# HUMANIA N2 - PROTOCOLO DE ARRANQUE MAESTRO (VERSIÓN PRO)
Clear-Host
$host.UI.RawUI.WindowTitle = "HUMANIA N2 - SECURE BOOT"

Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "   SISTEMA HUMANIA N2 - PROTOCOLO DE INICIO PRO     " -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan

# 1. VERIFICACIÓN DE INTEGRIDAD DE ARCHIVOS
Write-Host "`n[1/5] ESCUDO: Verificando integridad del núcleo..." -ForegroundColor Yellow
& "C:\HUMANIA\verifiers\humania_heal_v2.ps1"

# 2. TEST DE CONEXIÓN CON EL KERNEL (LM STUDIO)
Write-Host "`n[2/5] KERNEL: Test de latencia con LM Studio..." -ForegroundColor Yellow
try {
    $Test = Test-NetConnection -ComputerName 127.0.0.1 -Port 1234 -WarningAction SilentlyContinue
    if ($Test.TcpTestSucceeded) {
        Write-Host "[OK]: Kernel (IA) está en línea y escuchando." -ForegroundColor Green
    } else {
        Write-Host "[!] ALERTA: LM Studio no responde en el puerto 1234." -ForegroundColor Red
    }
} catch { Write-Host "[!] ERROR de conexión." -ForegroundColor Red }

# 3. ANÁLISIS DE PROCESOS SOSPECHOSOS
Write-Host "`n[3/5] SEGURIDAD: Buscando procesos de alto riesgo..." -ForegroundColor Yellow
$Suspects = Get-Process | Where-Object { $_.Description -match "miner|hack|bypass|exploit|remote" -or $_.Name -eq "netcat" }
if ($Suspects) {
    Write-Host "[ALERTA]: Procesos sospechosos detectados!" -ForegroundColor Red
    $Suspects | Select-Object Name, Id, Description | Format-Table
} else {
    Write-Host "[OK]: No se detectan amenazas activas en memoria." -ForegroundColor Green
}

# 4. SALUD DEL HARDWARE (DISCO Y BATERÍA)
Write-Host "`n[4/5] HARDWARE: Diagnóstico de componentes..." -ForegroundColor Yellow
# Disco (C:)
$Drive = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
$FreeGB = [math]::Round($Drive.FreeSpace / 1GB, 2)
$PercentFree = [math]::Round(($Drive.FreeSpace / $Drive.Size) * 100, 1)
Write-Host "[DISCO C:]: $FreeGB GB Libres ($PercentFree%)" -ForegroundColor Cyan

# Batería (Si es portátil)
$Battery = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue
if ($Battery) {
    Write-Host "[BATERÍA]: $($Battery.EstimatedChargeRemaining)% disponible." -ForegroundColor Cyan
}

# 5. OPTIMIZACIÓN DEL HOST
Write-Host "`n[5/5] HOST: Limpieza de archivos temporales..." -ForegroundColor Yellow
$TempFiles = Get-ChildItem "$env:TEMP\*" -Recurse -ErrorAction SilentlyContinue | Measure-Object | Select-Object -ExpandProperty Count
Write-Host "[INFO]: $TempFiles archivos temporales detectados." -ForegroundColor Cyan

Write-Host "`n====================================================" -ForegroundColor Cyan
Write-Host "        SISTEMA N2 LISTO PARA OPERAR                " -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "Pulsa cualquier tecla para entrar al Shell..."
$null = [Console]::ReadKey($true)

# Borra archivos temporales de más de 7 días
Get-ChildItem "$env:TEMP\*" -Recurse -ErrorAction SilentlyContinue | 
    Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-7) } | 
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue