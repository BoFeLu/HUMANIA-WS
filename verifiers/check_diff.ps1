# COMPARADOR DE INTEGRIDAD N2 - VERSIÓN REFORZADA
$Path = "C:\HUMANIA\kernel_manifest.json"
$CurrentContent = Get-Content $Path -Raw
$OldHash = "7820DAFE5190A2984A84AC57A82581AD22CD11DDB3B78AB1CB38CD27BBE6A9FC"
$NewHash = (Get-FileHash $Path -Algorithm SHA256).Hash

Write-Host "`n--- INVESTIGACIÓN DE MANIFIESTO ---" -ForegroundColor Cyan
Write-Host "Hash Original (GOLD): $OldHash" -ForegroundColor Gray
Write-Host "Hash Detectado:       $NewHash" -ForegroundColor Red

# 1. Reducimos el contenido para que la IA no se colapse (quitamos espacios)
$JsonLimpio = Get-Content $Path | ConvertFrom-Json | ConvertTo-Json -Compress

$Uri = "http://127.0.0.1:1234/v1/chat/completions"
$Prompt = "Kernel, el hash cambió de $OldHash a $NewHash. Compara este contenido ACTUAL con la versión GOLD y dime qué ha cambiado exactamente (revisa fechas o archivos): $JsonLimpio"

$Body = @{
    model = "mistral-7b-instruct-v0.3"
    messages = @( @{ role = "user"; content = $Prompt } )
    temperature = 0.1
} | ConvertTo-Json -Compress

try {
    Write-Host "`n[SISTEMA]: Consultando al Kernel (espera hasta 5 min)..." -ForegroundColor Yellow
    
    # 2. AQUÍ ESTÁ EL CAMBIO CLAVE: Timeout de 300 segundos
    $Result = Invoke-WebRequest -Uri $Uri -Method Post -Body $Body -ContentType "application/json" -TimeoutSec 300
    
    $Response = $Result.Content | ConvertFrom-Json
    Write-Host "`n[VERDICTO DEL KERNEL]:" -ForegroundColor Green
    Write-Host $Response.choices[0].message.content -ForegroundColor White
} catch {
    Write-Host "`n[!] ERROR: El Kernel sigue tardando demasiado o LM Studio está cerrado." -ForegroundColor Red
}