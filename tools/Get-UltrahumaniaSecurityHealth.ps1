$ErrorActionPreference = "Stop"

$RootPath = "C:\ULTRAHUMANIA_TRUST_ROOT"

$AllowedSignersPath = "$RootPath\keys\allowed_signers"
$RootManifestPath = "$RootPath\root_manifest.json"
$RootSignaturePath = "$RootPath\root_manifest.json.sig"

$RootVerifyPath = "$RootPath\root_verify.ps1"
$SecureSentinelPath = "$RootPath\secure_sentinel.ps1"

$SentinelManifestPath = "C:\HUMANIA\sentinel\manifest.json"
$GuardianPath = "C:\HUMANIA\BIN\guardian.exe"
$SentinelPath = "C:\HUMANIA\sentinel\sentinel_tick_new.ps1"

function Show-Result {
    param(
        [string]$Name,
        [bool]$Ok,
        [string]$Detail
    )

    $status = if ($Ok) { "OK" } else { "FAIL" }

    if ([string]::IsNullOrWhiteSpace($Detail)) {
        Write-Host ("{0,-32} {1}" -f $Name,$status)
    }
    else {
        Write-Host ("{0,-32} {1}  {2}" -f $Name,$status,$Detail)
    }
}

$allOk = $true

Write-Host ""
Write-Host "ULTRAHUMANIA SECURITY HEALTH CHECK"
Write-Host ""

$checks = @(
    @{Name="allowed_signers";Path=$AllowedSignersPath},
    @{Name="root_manifest.json";Path=$RootManifestPath},
    @{Name="root_manifest.json.sig";Path=$RootSignaturePath},
    @{Name="root_verify.ps1";Path=$RootVerifyPath},
    @{Name="secure_sentinel.ps1";Path=$SecureSentinelPath},
    @{Name="sentinel manifest";Path=$SentinelManifestPath},
    @{Name="guardian.exe";Path=$GuardianPath},
    @{Name="sentinel_tick_new.ps1";Path=$SentinelPath}
)

foreach ($c in $checks) {

    $exists = Test-Path -LiteralPath $c.Path

    Show-Result $c.Name $exists $c.Path

    if (-not $exists) {
        $allOk = $false
    }
}

Write-Host ""

$prereqOk =
    (Test-Path -LiteralPath $AllowedSignersPath) -and
    (Test-Path -LiteralPath $RootManifestPath) -and
    (Test-Path -LiteralPath $RootSignaturePath)

if ($prereqOk) {

    $verifyCmd = 'ssh-keygen -Y verify -f "{0}" -I ultrahumania_manifest -n ultrahumania_manifest -s "{1}" < "{2}"' -f `
        $AllowedSignersPath,$RootSignaturePath,$RootManifestPath

    $output = cmd /c $verifyCmd 2>&1

    $ok = ($LASTEXITCODE -eq 0)

    Show-Result "root manifest signature" $ok ""

    if (-not $ok) {
        $output | ForEach-Object { Write-Host $_ }
        $allOk = $false
    }
}
else {

    Show-Result "root manifest signature" $false "missing files"
    $allOk = $false
}

Write-Host ""

if (Test-Path -LiteralPath $RootVerifyPath) {

    pwsh -NoProfile -ExecutionPolicy Bypass -File $RootVerifyPath | Out-Host

    $ok = ($LASTEXITCODE -eq 0)

    Show-Result "root_verify execution" $ok ""

    if (-not $ok) { $allOk = $false }
}
else {

    Show-Result "root_verify execution" $false "missing script"
    $allOk = $false
}

Write-Host ""

if (Test-Path -LiteralPath $SecureSentinelPath) {

    pwsh -NoProfile -ExecutionPolicy Bypass -File $SecureSentinelPath | Out-Host

    $ok = ($LASTEXITCODE -eq 0)

    Show-Result "secure_sentinel execution" $ok ""

    if (-not $ok) { $allOk = $false }
}
else {

    Show-Result "secure_sentinel execution" $false "missing script"
    $allOk = $false
}

Write-Host ""

if ($allOk) {
    Write-Host "OVERALL STATUS: OK"
    exit 0
}
else {
    Write-Host "OVERALL STATUS: FAIL"
    exit 1
}
