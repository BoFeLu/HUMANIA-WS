param([string]$Action = "NOOP")
$MasterHash = "F77B8AC94581FF160C4EDA56D7008D9DC2903D0B3C492ECB5182E2121F4EFDE6"
$CurrentHash = (Get-FileHash "C:\HUMANIA\CORE\humania_guard.ps1" -Algorithm SHA256).Hash

if ($CurrentHash -ne $MasterHash) {
    Write-Error "[!] CRITICAL: CORE_INTEGRITY_VIOLATION en Guard. Ejecucion abortada."
    exit 99
}
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\HUMANIA\CORE\humania_guard.ps1" -Action $Action
