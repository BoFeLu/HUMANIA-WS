param(
    [string]$Root = "C:\HUMANIA",
    [string]$DbName = "ultrahumania",
    [string]$DbUser = "uh_core"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-TextOrError {
    param([scriptblock]$Script)
    try {
        $out = & $Script 2>&1 | Out-String
        return $out.TrimEnd()
    }
    catch {
        return "[ERROR] $($_.Exception.Message)"
    }
}

function Get-FileTextSafe {
    param([string]$Path)
    if (Test-Path -LiteralPath $Path) {
        return (Get-Content -LiteralPath $Path -Raw -Encoding UTF8)
    }
    return "[MISSING] $Path"
}

$desktop = [Environment]::GetFolderPath("Desktop")
$docsDir = Join-Path $Root "docs\handoff"
New-Item -ItemType Directory -Path $docsDir -Force | Out-Null

$ts = Get-Date -Format "yyyyMMdd_HHmmss"

$handoffMd  = Join-Path $docsDir ("ULTRAHUMANIA_CHAT_HANDOFF_{0}.md" -f $ts)
$handoffTxt = Join-Path $desktop ("ULTRAHUMANIA_CHAT_HANDOFF_{0}.txt" -f $ts)

$latestMd  = Join-Path $docsDir "ULTRAHUMANIA_CHAT_HANDOFF_LATEST.md"
$latestTxt = Join-Path $desktop "ULTRAHUMANIA_CHAT_HANDOFF_LATEST.txt"

$laClaveLatest = Join-Path $Root "LA_CLAVE_LATEST.md"

Push-Location $Root

$gitStatus  = Get-TextOrError { git status }
$gitLog     = Get-TextOrError { git log --oneline -8 }

$pgSchemas  = Get-TextOrError { psql -U $DbUser -d $DbName -c "\dn+" }
$pgTables   = Get-TextOrError { psql -U $DbUser -d $DbName -c "\dt *.*" }

Pop-Location

$laClaveText = Get-FileTextSafe -Path $laClaveLatest

$content = @"
ULTRAHUMANIA CHAT HANDOFF
Generated: $(Get-Date)

MANDATORY RULE
No asumir nada en ningún subsistema del proyecto.
Toda afirmación debe derivarse de evidencia.

GIT STATUS
$gitStatus

GIT LOG
$gitLog

POSTGRESQL SCHEMAS
$pgSchemas

POSTGRESQL TABLES
$pgTables

LA_CLAVE_LATEST.md
$laClaveText
"@

Set-Content -LiteralPath $handoffMd -Value $content -Encoding UTF8
Set-Content -LiteralPath $handoffTxt -Value $content -Encoding UTF8

Copy-Item $handoffMd $latestMd -Force
Copy-Item $handoffTxt $latestTxt -Force

Write-Host "HANDOFF_MD=$handoffMd"
Write-Host "HANDOFF_TXT=$handoffTxt"
Write-Host "LATEST_MD=$latestMd"
Write-Host "LATEST_TXT=$latestTxt"
