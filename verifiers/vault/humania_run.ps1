param(
  [string]$Action = "NOOP",
  [string]$Command = ""
)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\HUMANIA\humania_run.ps1 -Action $Action -Command $Command
