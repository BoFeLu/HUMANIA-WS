param(
  [string]$Action="NOOP",
  [string]$Command=""
)

if ($Command -and $Command.Trim().Length -gt 0) {
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\HUMANIA\CORE\humania_run.ps1 -Action $Action -Command $Command
} else {
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\HUMANIA\CORE\humania_run.ps1 -Action $Action
}
