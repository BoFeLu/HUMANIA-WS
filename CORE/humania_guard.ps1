param([string]$Action="NOOP")
powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\HUMANIA\CORE\humania_guard.ps1 -Action $Action
