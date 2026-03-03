@echo off

Write-Output 'PowerShell ejecutado por: ' + [System.Security.Principal.WindowsIdentity]::GetCurrent().Name | Out-File -FilePath 'C:\HUMANIA\logs\evidence\resultado_directo.txt' -Encoding utf8
