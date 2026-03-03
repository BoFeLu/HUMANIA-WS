$Root = "C:\HUMANIA"
$Verify = "$Root\audit_verify.ps1"
$Log = "$Root\AUDIT_CHAIN.jsonl"
$Guard = "$Root\humania_guard.ps1"
$Runner = "$Root\humania_run.ps1"

$StateJson = "$Root\STATE.json"
$Dashboard = "$Root\dashboard.html"

$SecretsTelegram = "$Root\secrets\telegram.json"
$SecretsSmtp = "$Root\secrets\smtp.json"

$NotifyStatePath = "$Root\NOTIFY_STATE.json"
$CooldownSeconds = 600  # 10 min

function Add-AuditEntry {
  param([string]$Event,[hashtable]$Data)

  $prev = ("0" * 64)
  $last = Get-Content $Log -Tail 1 -ErrorAction SilentlyContinue
  if ($last) { $prev = (ConvertFrom-Json $last).entry_hash }

  $obj = [ordered]@{
    ts_utc    = (Get-Date).ToUniversalTime().ToString("o")
    event     = $Event
    data      = $Data
    prev_hash = $prev
  }

  $core = ($obj | ConvertTo-Json -Compress)
  $bytes = [Text.Encoding]::UTF8.GetBytes($core)
  $stream = New-Object IO.MemoryStream(,$bytes)
  $hash = (Get-FileHash -InputStream $stream -Algorithm SHA256).Hash.ToLower()

  $obj["entry_hash"] = $hash
  ($obj | ConvertTo-Json -Compress) | Out-File -FilePath $Log -Encoding UTF8 -Append
}

function Write-State([hashtable]$state) {
  $state["ts_utc"] = (Get-Date).ToUniversalTime().ToString("o")
  ($state | ConvertTo-Json -Depth 8) | Set-Content -Path $StateJson -Encoding UTF8
}

function Write-DashboardFromState {
  if (!(Test-Path $StateJson)) { return }
  $s = Get-Content $StateJson -Raw | ConvertFrom-Json

  $integrity = if ($s.integrity_ok) { "OK" } else { "FAIL" }
  $gate = if ($s.gate_pass) { "PASS" } else { "FAIL" }
  $ts = $s.ts_utc

  $html = @"
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta http-equiv="refresh" content="15">
<title>HUMANIA State</title>
<style>
body { font-family: Segoe UI, Arial, sans-serif; margin: 24px; }
.card { border: 1px solid #ddd; border-radius: 10px; padding: 16px; max-width: 820px; }
h1 { margin: 0 0 12px 0; font-size: 20px; }
.row { margin: 6px 0; }
.k { display: inline-block; width: 220px; color: #444; }
.v { font-weight: 600; }
.small { color: #666; font-size: 12px; margin-top: 10px; white-space: pre-wrap; }
.bad { color: #b00020; }
.good { color: #0b6b0b; }
</style>
</head>
<body>
<div class="card">
<h1>HUMANIA Control-Plane State</h1>
<div class="row"><span class="k">Timestamp (UTC)</span> <span class="v">$ts</span></div>
<div class="row"><span class="k">Integrity</span> <span class="v $(if($s.integrity_ok){'good'}else{'bad'})">$integrity</span></div>
<div class="row"><span class="k">Gate</span> <span class="v $(if($s.gate_pass){'good'}else{'bad'})">$gate</span></div>
<div class="row"><span class="k">Gate exit code</span> <span class="v">$($s.gate_exit_code)</span></div>
<div class="small">Note: $($s.note)</div>
</div>
</body>
</html>
"@
  $html | Set-Content -Path $Dashboard -Encoding UTF8
}

function Load-JsonOrNull([string]$path) {
  try {
    if (Test-Path $path) { return (Get-Content $path -Raw | ConvertFrom-Json) }
  } catch { }
  return $null
}

function Load-NotifyState {
  $ns = Load-JsonOrNull $NotifyStatePath
  if (-not $ns) {
    $ns = [ordered]@{
      last_sent_utc = $null
      last_status = "UNKNOWN" # OK / FAIL / UNKNOWN
    }
  }
  return $ns
}

function Save-NotifyState($ns) {
  ($ns | ConvertTo-Json -Depth 6) | Set-Content -Path $NotifyStatePath -Encoding UTF8
}

function Should-Notify($nowUtc, $ns, [string]$newStatus) {
  # Always notify on status change (FAIL->OK or OK->FAIL), but respect cooldown for repeated FAILs
  if ($ns.last_status -ne $newStatus) { return $true }

  if ($newStatus -eq "FAIL") {
    if ($ns.last_sent_utc) {
      try { $last = [datetime]::Parse($ns.last_sent_utc).ToUniversalTime() } catch { $last = $null }
      if ($last) {
        $delta = ($nowUtc - $last).TotalSeconds
        if ($delta -lt $CooldownSeconds) { return $false }
      }
    }
    return $true
  }

  # OK and unchanged: no spam
  return $false
}

function Send-Telegram([string]$text) {
  $cfg = Load-JsonOrNull $SecretsTelegram
  if (-not $cfg -or -not $cfg.enabled) { return $false }

  if (-not $cfg.bot_token -or -not $cfg.chat_id) { return $false }

  $uri = "https://api.telegram.org/bot$($cfg.bot_token)/sendMessage"
  $body = @{
    chat_id = $cfg.chat_id
    text = $text
    disable_web_page_preview = $true
  }

  try {
    Invoke-RestMethod -Method Post -Uri $uri -Body $body -TimeoutSec 10 | Out-Null
    return $true
  } catch {
    return $false
  }
}

function Send-Email([string]$subject, [string]$bodyText) {
  $cfg = Load-JsonOrNull $SecretsSmtp
  if (-not $cfg -or -not $cfg.enabled) { return $false }

  try {
    $msg = New-Object System.Net.Mail.MailMessage
    $msg.From = $cfg.from
    $msg.To.Add($cfg.to)
    $msg.Subject = $subject
    $msg.Body = $bodyText

    $smtp = New-Object System.Net.Mail.SmtpClient($cfg.smtp_host, [int]$cfg.smtp_port)
    $smtp.EnableSsl = [bool]$cfg.use_starttls
    $smtp.Credentials = New-Object System.Net.NetworkCredential($cfg.smtp_user, $cfg.smtp_app_password)
    $smtp.Send($msg)
    return $true
  } catch {
    return $false
  }
}

function Notify-IfNeeded {
  if (!(Test-Path $StateJson)) { return }
  $s = Get-Content $StateJson -Raw | ConvertFrom-Json

  $integrityOk = [bool]$s.integrity_ok
  $gatePass = [bool]$s.gate_pass

  $newStatus = if ($integrityOk -and $gatePass) { "OK" } else { "FAIL" }
  $nowUtc = (Get-Date).ToUniversalTime()

  $ns = Load-NotifyState
  if (-not (Should-Notify $nowUtc $ns $newStatus)) { return }

  $title = if ($newStatus -eq "OK") { "HUMANIA RECOVERY" } else { "HUMANIA ALERT" }
  $text = @"
$title
ts_utc=$($s.ts_utc)
integrity_ok=$integrityOk
gate_pass=$gatePass
gate_exit_code=$($s.gate_exit_code)
note=$($s.note)
"@

  $tgOk = Send-Telegram $text
  $emOk = Send-Email $title $text

  # Update notify state (even if delivery failed, to avoid loops; delivery failures are visible via audit)
  $ns.last_sent_utc = $nowUtc.ToString("o")
  $ns.last_status = $newStatus
  Save-NotifyState $ns

  # Record delivery outcome (no secrets)
  Add-AuditEntry -Event "NOTIFY_ATTEMPT" -Data @{
    status=$newStatus
    telegram_sent=$tgOk
    email_sent=$emOk
    cooldown_s=$CooldownSeconds
    note="notification attempt recorded"
    host=$env:COMPUTERNAME
    user=$env:USERNAME
  }
}

# Hard prerequisites
$missing = @()
foreach ($p in @($Log,$Verify,$Guard,$Runner)) { if (!(Test-Path $p)) { $missing += $p } }

if ($missing.Count -gt 0) {
  if (Test-Path $Log) {
    Add-AuditEntry -Event "SENTINEL_TICK_FAIL" -Data @{
      note="missing critical components"
      missing=$missing
      host=$env:COMPUTERNAME
      user=$env:USERNAME
    }
  }
  Write-State @{
    integrity_ok = $false
    gate_pass = $false
    gate_exit_code = 2
    note = ("missing critical components: " + ($missing -join ", "))
  }
  Write-DashboardFromState
  Notify-IfNeeded
  Write-Error ("Missing critical components: " + ($missing -join ", "))
  exit 2
}

# 1) IntegrityOnly (authoritative)
$outI = powershell -ExecutionPolicy Bypass -File $Verify -Mode IntegrityOnly 2>&1
$codeI = $LASTEXITCODE
if ($codeI -ne 0) {
  Add-AuditEntry -Event "SENTINEL_TICK_FAIL" -Data @{
    note="audit integrity verification failed (IntegrityOnly)"
    host=$env:COMPUTERNAME
    user=$env:USERNAME
    verifier_output=($outI | Out-String)
    exit_code=$codeI
  }
  Write-State @{
    integrity_ok = $false
    gate_pass = $false
    gate_exit_code = $codeI
    note = "integrity failed (IntegrityOnly)"
  }
  Write-DashboardFromState
  Notify-IfNeeded
  exit 2
}

# 2) Full gate (operational policy)
$outF = powershell -ExecutionPolicy Bypass -File $Verify 2>&1
$codeF = $LASTEXITCODE
$gatePass = ($codeF -eq 0)

Add-AuditEntry -Event "SENTINEL_TICK_OK" -Data @{
  note="audit integrity OK (state + gate recorded)"
  host=$env:COMPUTERNAME
  user=$env:USERNAME
  gate_exit_code=$codeF
  verifier_output=($outF | Out-String)
}

Write-State @{
  integrity_ok = $true
  gate_pass = $gatePass
  gate_exit_code = $codeF
  note = "integrity OK; gate recorded"
}

Write-DashboardFromState
Notify-IfNeeded
exit 0
