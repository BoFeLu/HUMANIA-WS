# --- HUMANIA: SCRIPT DE ENLACE LOCAL (MISTRAL 7B) ---
$Uri = "http://localhost:1234/v1/chat/completions"
$Body = @{
    model = "mistral-7b-instruct-v0.3"
    messages = @(
        @{ role = "system"; content = "Eres el Kernel de HUMANIA. Responde de forma técnica y breve." },
        @{ role = "user"; content = "Hola Mistral, confirma tu estado de conexión con el sistema HUMANIA N2." }
    )
    temperature = 0.7
} | ConvertTo-Json

Write-Host "--- ENVIANDO PETICIÓN AL CEREBRO LOCAL ---" -ForegroundColor Cyan
try {
    $Response = Invoke-RestMethod -Uri $Uri -Method Post -Body $Body -ContentType "application/json"
    Write-Host "`n[MISTRAL RESPONDE]:" -ForegroundColor Green
    Write-Host $Response.choices[0].message.content -ForegroundColor White
} catch {
    Write-Host "`n[ERROR] No se pudo contactar con LM Studio." -ForegroundColor Red
}
