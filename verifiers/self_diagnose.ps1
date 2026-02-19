$Root = "C:\HUMANIA"
$ManifestPath = "$Root\kernel_manifest.json"
$Report = [ordered]@{
    ts_utc = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    status = "HEALTHY"
    issues = @()
}

if (!(Test-Path $ManifestPath)) {
    $Report.status = "CRITICAL"; $Report.issues += "Missing manifest"; return
}

$Manifest = Get-Content $ManifestPath | ConvertFrom-Json

foreach ($item in $Manifest.items) {
    $fileName = Split-Path $item.path -Leaf
    
    # EXCLUSIÓN CRÍTICA: No podemos validar el hash de los archivos que cambian 
    # para realizar la validación (El Observador)
    if ($fileName -eq "kernel_manifest.json" -or 
        $fileName -eq "kernel_manifest_verify.ps1" -or 
        $fileName -eq "self_diagnose.ps1" -or
        $fileName -eq "AUDIT_CHAIN.jsonl") { continue }

    if (!(Test-Path $item.path)) {
        $Report.status = "DEGRADED"; $Report.issues += "Missing: $fileName"
    } else {
        $currentHash = (Get-FileHash $item.path -Algorithm SHA256).Hash
        if ($currentHash -ne $item.sha256) {
            $Report.status = "DEGRADED"; $Report.issues += "Hash mismatch: $fileName"
        }
    }
}

if ($Report.status -eq "HEALTHY") {
    Write-Host "[OK] HUMANIA Heartbeat: NORMAL" -ForegroundColor Green
} else {
    Write-Host "[WARN] HUMANIA Heartbeat: $($Report.status)" -ForegroundColor Red
    $Report.issues | ForEach-Object { Write-Host "  > $_" -ForegroundColor Yellow }
}
