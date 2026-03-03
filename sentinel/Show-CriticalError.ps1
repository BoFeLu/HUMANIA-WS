# PROTOCOLO DE ALERTA ROJA ACÚSTICA - ULTRAHUMANIA
Clear-Host
$Host.UI.RawUI.BackgroundColor = "DarkRed"
$Host.UI.RawUI.ForegroundColor = "White"
Clear-Host

# Función para la sirena
function Play-Siren {
    [console]::beep(800, 300)
    [console]::beep(500, 300)
}

Write-Host "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" -ForegroundColor White
Write-Host "!!   CRITICAL WARNING: CADENA DE INTEGRIDAD ROTA          !!" -ForegroundColor Yellow
Write-Host "!!   SE DETECTÓ UNA MODIFICACIÓN NO AUTORIZADA            !!" -ForegroundColor White
Write-Host "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" -ForegroundColor Yellow

while($true) {
    Write-Host "[ALERTA] INTEGRIDAD COMPROMETIDA - VERIFICAR LOGS" -ForegroundColor White
    Play-Siren
    Start-Sleep -Milliseconds 100
}
