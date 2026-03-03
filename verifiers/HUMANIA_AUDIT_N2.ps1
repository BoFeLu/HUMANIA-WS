$Uri = "http://127.0.0.1:1234/v1/chat/completions"

# 1. LEER EL INTERIOR DE UN SCRIPT PARA ANÁLISIS REAL
$ContenidoHeal = Get-Content "C:\HUMANIA\verifiers\humania_heal.ps1" -Raw

Write-Host "`n--- KERNEL HUMANIA N2: ANÁLISIS DE CÓDIGO Y SISTEMA ---" -ForegroundColor Cyan

$Prompt = @"
### INSTRUCCIONES: Eres el Kernel de Seguridad de HUMANIA N2. 
1. RESPONDE SIEMPRE EN ESPAÑOL.
2. Analiza el siguiente contenido del script 'humania_heal.ps1' y dime si es seguro ejecutarlo.
3. No te cortes, da el informe completo de todos los archivos .ps1 de la carpeta.

CONTENIDO DE HEAL:
$ContenidoHeal
"@

$Body = @{
    model = "mistral-7b-instruct-v0.3"
    messages = @( @{ role = "user"; content = $Prompt } )
    temperature = 0.3
    max_tokens = 1000 # Espacio de sobra para no cortarse
} | ConvertTo-Json -Compress

try {
    $Result = Invoke-WebRequest -Uri $Uri -Method Post -Body $Body -ContentType "application/json" -TimeoutSec 300
    $Response = $Result.Content | ConvertFrom-Json
    $Analisis = $Response.choices[0].message.content
    
    Write-Host "`n[INFORME DEL KERNEL N2]:" -ForegroundColor Green
    Write-Host $Analisis -ForegroundColor White
    $Analisis | Out-File "C:\HUMANIA\verifiers\AUDIT_REPORT.txt" -Encoding utf8
} catch {
    Write-Host "`n[!] ERROR CRÍTICO EN EL KERNEL" -ForegroundColor Red
}