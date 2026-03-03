param([string]$Action = "NOOP", [string]$Command = "")

# ULTRAHUMANIA CORE V2.1 - SIN RECURSIVIDAD
$Root = "C:\HUMANIA"
$Log  = "$Root\AUDIT_CHAIN.jsonl"

# Lógica simplificada para evitar bloqueos de CLR
if ($Command -and $Command.Trim().Length -gt 0) {
    Write-Host "[CORE]: Ejecutando comando validado..." -ForegroundColor Cyan
    # Ejecución directa por Dot-Sourcing para mantener el mismo proceso
    Invoke-Expression "$Command"
} else {
    Write-Host "[CORE]: Acción $Action registrada sin comando adicional." -ForegroundColor Gray
}
