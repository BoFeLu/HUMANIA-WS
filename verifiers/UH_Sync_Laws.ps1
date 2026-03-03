# ULTRAHUMANIA - SINCRONIZADOR PROACTIVO (DB -> DESKTOP)
$PSQL = "C:\Program Files\PostgreSQL\17\bin\psql.exe"
$DesktopPath = [Environment]::GetFolderPath("Desktop")
$MasterMapFile = Join-Path $DesktopPath "ULTRAHUMANIA_MASTER_MAP.md"

# Extraer la última versión de la Constitución
$Constitucion = & $PSQL -h 127.0.0.1 -U uh_core -d ultrahumania -t -c "SELECT seccion || ': ' || contenido FROM norm.constitucion ORDER BY id DESC;"

if ($Constitucion) {
    "# 🏛️ CONSTITUCIÓN ACTUALIZADA (Sincronización Proactiva)
" + ($Constitucion -join "

") | Out-File -FilePath $MasterMapFile -Encoding UTF8
    Write-Host "[SYNC]: Archivo maestro actualizado con éxito." -ForegroundColor Green
}
