param(
    [switch]$PrepareOnly,
    [string]$ImportSignaturePath = ""
)

$ErrorActionPreference = 'Stop'

$RepoPath = "C:\HUMANIA"
$RootPath = "C:\ULTRAHUMANIA_TRUST_ROOT"
$ActiveManifestPath = "$RootPath\root_manifest.json"
$ActiveSignaturePath = "$RootPath\root_manifest.json.sig"
$AllowedSignersPath = "$RootPath\keys\allowed_signers"
$PendingDir = "$RootPath\pending"
$ArchiveDir = "$RootPath\archive"
$PendingManifestPath = "$PendingDir\root_manifest.pending.json"
$PendingSignaturePath = "$PendingDir\root_manifest.pending.json.sig"
$RootVerifyPath = "$RootPath\root_verify.ps1"
$SecureSentinelPath = "$RootPath\secure_sentinel.ps1"
$EvidenceDir = "$RepoPath\docs\governance"

function Invoke-ManifestVerify {
    param(
        [string]$ManifestPath,
        [string]$SignaturePath
    )

    $verifyCmd = 'ssh-keygen -Y verify -f "{0}" -I ultrahumania_manifest -n ultrahumania_manifest -s "{1}" < "{2}"' -f `
        $AllowedSignersPath, $SignaturePath, $ManifestPath

    $output = cmd /c $verifyCmd 2>&1
    $exitCode = $LASTEXITCODE

    return [pscustomobject]@{
        ExitCode = $exitCode
        Output   = $output
    }
}

if (!(Test-Path -LiteralPath $ActiveManifestPath)) {
    throw "Missing active manifest: $ActiveManifestPath"
}

if (!(Test-Path -LiteralPath $AllowedSignersPath)) {
    throw "Missing allowed_signers: $AllowedSignersPath"
}

New-Item -ItemType Directory -Force -Path $PendingDir | Out-Null
New-Item -ItemType Directory -Force -Path $ArchiveDir | Out-Null
New-Item -ItemType Directory -Force -Path $EvidenceDir | Out-Null

$currentManifest = Get-Content -LiteralPath $ActiveManifestPath -Raw | ConvertFrom-Json

$pendingManifest = [ordered]@{
    items = @()
}

foreach ($item in $currentManifest.items) {
    if (!(Test-Path -LiteralPath $item.path)) {
        throw "Protected file missing: $($item.path)"
    }

    $pendingManifest.items += [ordered]@{
        path   = $item.path
        sha256 = (Get-FileHash -LiteralPath $item.path -Algorithm SHA256).Hash
    }
}

$pendingManifest | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $PendingManifestPath -Encoding UTF8

if ($PrepareOnly -and [string]::IsNullOrWhiteSpace($ImportSignaturePath)) {
    Write-Host "[PENDING READY] $PendingManifestPath"
    exit 0
}

if ([string]::IsNullOrWhiteSpace($ImportSignaturePath)) {
    throw "Use -PrepareOnly or -ImportSignaturePath <path>"
}

if (!(Test-Path -LiteralPath $ImportSignaturePath)) {
    throw "Missing signature file: $ImportSignaturePath"
}

$srcSig = [System.IO.Path]::GetFullPath($ImportSignaturePath)
$dstSig = [System.IO.Path]::GetFullPath($PendingSignaturePath)

if ($srcSig -ne $dstSig) {
    Copy-Item -LiteralPath $ImportSignaturePath -Destination $PendingSignaturePath -Force
}

$verify = Invoke-ManifestVerify -ManifestPath $PendingManifestPath -SignaturePath $PendingSignaturePath
if ($verify.ExitCode -ne 0) {
    $verify.Output | ForEach-Object { Write-Host $_ }
    throw "Pending manifest signature verification failed"
}

$ts = Get-Date -Format 'yyyyMMdd_HHmmss'

Copy-Item -LiteralPath $ActiveManifestPath -Destination "$ArchiveDir\root_manifest.$ts.json" -Force
if (Test-Path -LiteralPath $ActiveSignaturePath) {
    Copy-Item -LiteralPath $ActiveSignaturePath -Destination "$ArchiveDir\root_manifest.$ts.json.sig" -Force
}

Copy-Item -LiteralPath $PendingManifestPath -Destination $ActiveManifestPath -Force
Copy-Item -LiteralPath $PendingSignaturePath -Destination $ActiveSignaturePath -Force

pwsh -NoProfile -ExecutionPolicy Bypass -File $RootVerifyPath
if ($LASTEXITCODE -ne 0) {
    throw "root_verify.ps1 failed after baseline activation"
}

pwsh -NoProfile -ExecutionPolicy Bypass -File $SecureSentinelPath
if ($LASTEXITCODE -ne 0) {
    throw "secure_sentinel.ps1 failed after baseline activation"
}

$evidencePath = "$EvidenceDir\SIGNED_BASELINE_APPLY_$ts.md"
@"
SIGNED BASELINE APPLY EVIDENCE
Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

Pending manifest:
$PendingManifestPath

Imported signature:
$ImportSignaturePath

Active manifest:
$ActiveManifestPath

Active signature:
$ActiveSignaturePath

Verification result:
$($verify.Output -join "`r`n")

Post-activation checks:
- root_verify.ps1: PASS
- secure_sentinel.ps1: PASS
"@ | Set-Content -LiteralPath $evidencePath -Encoding UTF8

Write-Host "[BASELINE UPDATED] $ActiveManifestPath"
Write-Host "[EVIDENCE WRITTEN] $evidencePath"
exit 0
