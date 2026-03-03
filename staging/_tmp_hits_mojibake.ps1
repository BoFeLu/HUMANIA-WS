$ErrorActionPreference="Stop"

$g="C:\HUMANIA\guard\UH_GUARD_RUN.ps1"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File $g -Trigger "MANUAL_STATUS" | Out-Null

$ls   = Get-Content "C:\HUMANIA\state\runner\last_success.json" -Raw | ConvertFrom-Json
$mini = ($ls.artifacts | Where-Object { $_ -like "*MINI_REPORT_*" } | Select-Object -First 1)
"MINI_PATH=$mini"

$txt  = Get-Content -LiteralPath $mini -Raw
$bad  = @("Ã","Â","â€”","â€","�")

$hits = foreach ($pat in $bad) {
  [pscustomobject]@{
    pattern = $pat
    count   = ([regex]::Matches($txt, [regex]::Escape($pat))).Count
  }
}

$hits | Format-Table -AutoSize
