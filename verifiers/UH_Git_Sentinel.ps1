# ULTRAHUMANIA - SENTINEL DE CONTROL DE VERSIONES (BLINDADO)
Set-Location "C:\HUMANIA"

# 1. Configuración de robustez: Ignorar cambios de permisos y normalizar finales de línea
git config core.fileMode false
git config core.autocrlf true

# 2. Intentar limpiar el índice de archivos bloqueados/fantasma
try {
    git add . 2>$null
} catch {
    Write-Host "[!] Aviso: Algunos archivos están bloqueados, saltando..." -ForegroundColor Yellow
}

# 3. Verificar estado real
$Status = git status --porcelain
if ($Status) {
    $Fecha = Get-Date -Format 'yyyy-MM-dd HH:mm'
    # Commit usando -a para incluir modificaciones y saltar bloqueos de archivos nuevos no indexables
    git commit -a -m "AUTO-SYNC: Sello de Integridad ($Fecha) [Blindado]"
    Write-Host "[GIT]: Escudo de versiones actualizado." -ForegroundColor Green
} else {
    Write-Host "[GIT]: Sin cambios significativos." -ForegroundColor Gray
}
