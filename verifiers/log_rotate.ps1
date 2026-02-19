$LogFile = "C:\HUMANIA\AUDIT_CHAIN.jsonl"
$MaxSize = 10MB
if (Test-Path $LogFile) {
    $Size = (Get-Item $LogFile).Length
    if ($Size -gt $MaxSize) {
        $Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        Move-Item $LogFile "C:\HUMANIA\logs\AUDIT_CHAIN_$Timestamp.jsonl.bak"
        New-Item -Path $LogFile -ItemType File
        Write-Host "[LOG] Rotación completada. Archivo histórico creado." -ForegroundColor Cyan
    }
}
