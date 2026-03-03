# ULTRAHUMANIA - GESTOR DE ROTACIÓN DE LOGS (PROTOCOLO N2)
$LogPaths = @("C:\HUMANIA\AUDIT_CHAIN.jsonl", "C:\HUMANIA\logs\watchdog\UH_WATCHDOG_LOOP.log")
$MaxSizeBytes = 10MB
$HistoryPath = "C:\HUMANIA\logs\history"

if (!(Test-Path $HistoryPath)) { New-Item -ItemType Directory -Force -Path $HistoryPath }

foreach ($File in $LogPaths) {
    if (Test-Path $File) {
        $FileInfo = Get-Item $File
        if ($FileInfo.Length -gt $MaxSizeBytes) {
            $Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
            $NewName = "$HistoryPath\($FileInfo.BaseName)_$Timestamp($FileInfo.Extension)"
            Move-Item -Path $File -Destination $NewName
            Write-Host "[LOGROTATE]: $File rotado a $NewName" -ForegroundColor Cyan
            # Crear nuevo archivo vacío para que el sistema siga escribiendo
            "" | Out-File $File -Encoding UTF8
        }
    }
}

# Purga de archivos de más de 30 días en el histórico
Get-ChildItem $HistoryPath | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-30) } | Remove-Item -Force
