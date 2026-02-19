param(
    [string]$Action = "NOOP"
)

$Root = "C:\HUMANIA"
$Log  = "$Root\AUDIT_CHAIN.jsonl"

$AllowFile   = "$Root\allowed_actions.txt"
$VerifyScript = "$Root\audit_verify.ps1"

# ---------------- low-level helpers (NO Get-FileHash, NO Get-Content -Tail) ----------------
function Sha256HexUtf8 {
    param([Parameter(Mandatory=$true)][string]$Text)
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
        $hash  = $sha.ComputeHash($bytes)
        return ([BitConverter]::ToString($hash) -replace "-","").ToLower()
    } finally {
        $sha.Dispose()
    }
}

function Get-LastAuditEntryHashSafe {
    param([Parameter(Mandatory=$true)][string]$Path)

    if (!(Test-Path $Path)) { return ("0" * 64) }

    $tailBytes = 131072 # 128 KiB
    $fs = [System.IO.File]::Open($Path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
    try {
        $len = $fs.Length
        if ($len -le 0) { return ("0" * 64) }

        $read = [Math]::Min([int64]$tailBytes, [int64]$len)
        [void]$fs.Seek(-1 * $read, [System.IO.SeekOrigin]::End)

        $buf = New-Object byte[] $read
        [void]$fs.Read($buf, 0, $buf.Length)
    } finally {
        $fs.Close()
    }

    $txt = [System.Text.Encoding]::UTF8.GetString($buf)
    $lines = $txt -split "`n"

    for ($i = $lines.Count - 1; $i -ge 0; $i--) {
        $s = $lines[$i].Trim()
        if ($s.Length -gt 0) {
            try {
                $o = $s | ConvertFrom-Json -ErrorAction Stop
                if ($o.entry_hash) { return [string]$o.entry_hash }
            } catch {
                return ("0" * 64) # safe fallback if tail window hits an incomplete JSON fragment
            }
        }
    }

    return ("0" * 64)
}

function Ensure-AuditFile {
    if (!(Test-Path $Log)) {
        New-Item -ItemType File -Path $Log -Force | Out-Null
    }
}

function Add-AuditEntry {
    param([Parameter(Mandatory=$true)][string]$Event,[Parameter(Mandatory=$true)][hashtable]$Data)

    # Solo escribir en la consola para depuración
    Write-Host "Event: $Event, Data: $($Data | ConvertTo-Json -Compress)"
}


# ---------------- policy checks ----------------
function Read-Allowlist([string]$Path) {
    if (!(Test-Path $Path)) { return @() }
    return (Get-Content $Path -ErrorAction Stop |
        ForEach-Object { $_.Trim() } |
        Where-Object { $_ -and -not $_.StartsWith("#") } |
        Sort-Object -Unique)
}

function Deny([string]$Reason) {
    Add-AuditEntry -Event "GUARD_BLOCK" -Data @{
        action=$Action
        blocked=$true
        reason=$Reason
    }
    Write-Error $Reason
    exit 99
}

# ---------------- main ----------------
try {
    Write-Host "Checking if Action: $Action is allowed..."
    if (!(Test-Path $AllowFile)) {
        Write-Host "Missing allowlist file: $AllowFile"
        exit 99
    }

    $allowed = Read-Allowlist -Path $AllowFile
    if ($Action -notin $allowed) {
        Write-Host "Action '$Action' not allowlisted in $AllowFile"
        exit 99
    }

    Write-Host "Action '$Action' is allowed."
    exit 0
} catch {
    Write-Host "Error: " + ($_ | Out-String)
    exit 99
}

