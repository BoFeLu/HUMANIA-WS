$Root = "C:\HUMANIA"
$Log = "$Root\AUDIT_CHAIN.jsonl"
$ManifestPath = "$Root\kernel_manifest.json"
$StateJson = "$Root\STATE.json"

function Add-AuditEntry {
    param([string]$Event,[hashtable]$Data)
    try {
        $prev = ("0" * 64)
        if (Test-Path $Log) {
            $last = Get-Content $Log -Tail 1 -ErrorAction SilentlyContinue
            if ($last) { $prev = (ConvertFrom-Json $last).entry_hash }
        }
        $obj = [ordered]@{
            ts_utc     = (Get-Date).ToUniversalTime().ToString("o")
            event      = $Event
            data       = $Data
            prev_hash  = $prev
        }
        $core = ($obj | ConvertTo-Json -Compress)
        $bytes = [Text.Encoding]::UTF8.GetBytes($core)
        $stream = New-Object IO.MemoryStream( ,$bytes)
        $hash = (Get-FileHash -InputStream $stream -Algorithm SHA256).Hash.ToLower()
        $obj["entry_hash"] = $hash
        ($obj | ConvertTo-Json -Compress) | Out-File -FilePath $Log -Encoding UTF8 -Append
    } catch { 
        Write-Error "Fallo en Add-AuditEntry: $(.Exception.Message)" 
    }
}

# --- INICIO DE VERIFICACIÓN ---
try {
    if (!(Test-Path $ManifestPath)) { throw "Manifiesto no encontrado" }
    $Manifest = Get-Content $ManifestPath | ConvertFrom-Json
    
    foreach ($Item in $Manifest.items) {
        $PathExists = Test-Path $Item.path
        
        if (!$PathExists) {
            # ERROR CRÍTICO: ARCHIVO DESAPARECIDO
            Write-Host "[CRÍTICO]: $($Item.path) - ¡ARCHIVO ELIMINADO!" -ForegroundColor Red
            Start-Process powershell.exe -ArgumentList "-NoProfile", "-File", "C:\HUMANIA\sentinel\Show-CriticalError.ps1"
            Add-AuditEntry -Event "FILE_MISSING" -Data @{ Path = $Item.path }
            return # Detenemos ejecución para que la alarma sea la prioridad
        }
        
        $CurrentHash = (Get-FileHash $Item.path -Algorithm SHA256).Hash
        if ($CurrentHash -ne $Item.sha256) {
            # ERROR CRÍTICO: ARCHIVO MODIFICADO
            Write-Host "[ALERTA]: $($Item.path) - ¡MODIFICACIÓN DETECTADA!" -ForegroundColor Red
            Start-Process powershell.exe -ArgumentList "-NoProfile", "-File", "C:\HUMANIA\sentinel\Show-CriticalError.ps1"
            Add-AuditEntry -Event "INTEGRITY_VIOLATION" -Data @{ Path = $Item.path; Expected = $Item.sha256; Found = $CurrentHash }
            return
        }
        Write-Host "[OK]: $($Item.path)" -ForegroundColor Green
    }
} catch {
    Write-Host "[ERROR DE SISTEMA]: $(.Exception.Message)" -ForegroundColor Magenta
}
