# ==========================================================
# ULTRAHUMANIA - ORQUESTADOR FINAL v1.2
# ==========================================================
function Invoke-Mistral {
    param([string]$Prompt)
    $Uri = "http://localhost:1234/v1/chat/completions"
    $Body = @{
        model = "mistralai/mistral-7b-instruct-v0.3"
        messages = @(@{role="user"; content=$Prompt})
        temperature = 0.5
    } | ConvertTo-Json
    try {
        $Response = Invoke-RestMethod -Uri $Uri -Method Post -Body $Body -ContentType "application/json" -TimeoutSec 180
        return $Response.choices[0].message.content
    } catch { return "ERROR: LM Studio no responde. Revisa el puerto 1234." }
}

function Get-UHContext {
    param([string]$Busqueda)
    $SQL = "SELECT item_name, physical_path FROM kb.knowledge_base WHERE item_name ILIKE '%$Busqueda%' OR category ILIKE '%$Busqueda%';"
    return psql -U postgres -d humania_db -c "$SQL" -t -A
}

Clear-Host
Write-Host ">>> ULTRAHUMANIA: NEXUS-BRIDGE ACTIVO <<<" -ForegroundColor Cyan
$Query = Read-Host "
¿Qué necesitas localizar en la Mina de Oro?"

if ($Query) {
    $Evidencia = Get-UHContext -Busqueda $Query
    if ($Evidencia) {
        Write-Host "[EVIDENCIA ENCONTRADA]:
$Evidencia" -ForegroundColor Green
        $IA_Resp = Invoke-Mistral -Prompt "El usuario busca '$Query'. Los datos reales en su disco son: $Evidencia. Responde qué tiene y dónde."
        Write-Host "
[MISTRAL ANALIZA]:
$IA_Resp" -ForegroundColor White
    } else {
        Write-Host "[INFO] No hay registros. Consultando a la IA general..." -ForegroundColor Magenta
        Invoke-Mistral -Prompt $Query
    }
}
