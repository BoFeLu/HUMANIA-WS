$ExportPath = "C:\HUMANIA\SYSTEM_FULL_EXPORT.json"
$Root = "C:\HUMANIA"

Write-Host "Iniciando exportaci" + [char]0xF3 + "n de seguridad..." -ForegroundColor Cyan

$Data = [ordered]@{
    system_name = "HUMANIA"
    version     = "4.0.0-GOLD"
    timestamp   = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    files       = @()
}

$FilesToExport = Get-ChildItem -Path $Root -File
foreach ($file in $FilesToExport) {
    $Data.files += @{
        name   = $file.Name
        hash   = (Get-FileHash $file.FullName).Hash
        size   = $file.Length
        content_base64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($file.FullName))
    }
}

$Data | ConvertTo-Json -Depth 10 | Set-Content $ExportPath -Encoding utf8
$msg = "Exportaci" + [char]0xF3 + "n total completada en: $ExportPath"
Write-Host $msg -ForegroundColor Yellow
