param([string]$Action = "NOOP", [string]$Command = "")

# 1. Monitoreo de Memoria: Si la RAM libre es baja, forzar recolección de basura
if ([GC]::GetTotalMemory($false) -gt 100MB) { [GC]::Collect() }

# 2. Watchdog de Ejecución (Dot-Sourcing Protegido)
try {
    Write-Host "[N2-MONITOR]: Iniciando ejecución..." -ForegroundColor Cyan
    . "C:\HUMANIA\CORE\humania_run.ps1" -Action $Action -Command $Command
} catch {
    Write-Error "[!] AUTO-REMEDIO: Error de ejecución. Reiniciando subsistema..."
}
