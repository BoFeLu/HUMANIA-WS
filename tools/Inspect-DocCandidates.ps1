$ErrorActionPreference = 'Stop'

$ts = Get-Date -Format 'yyyyMMdd_HHmmss'
$outDir = "C:\HUMANIA\HANDOFF\DOC_SYNC_CANDIDATES_$ts"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$patterns = @(
    'ARCHITECTURE',
    'SYSTEM_MAP',
    'DOCUMENTATION_INDEX',
    'INDEX',
    'SECURITY',
    'INTEGRITY',
    'RUNBOOK',
    'ROADMAP',
    'FOUNDATION',
    'CONTROL',
    'ORCHESTRATOR',
    'AI_RUNTIME',
    'BOOTSTRAP',
    'PHASE',
    'KNOWLEDGE'
)

Get-ChildItem -LiteralPath "C:\HUMANIA\docs" -Recurse -File |
    Where-Object {
        $n = $_.Name.ToUpperInvariant()
        foreach ($p in $patterns) {
            if ($n -like "*$p*") { return $true }
        }
        return $false
    } |
    Sort-Object FullName |
    Select-Object FullName, Length, LastWriteTime |
    Format-Table -AutoSize |
    Out-String -Width 4096 |
    Set-Content -LiteralPath "$outDir\CANDIDATE_DOCS.txt" -Encoding UTF8

Get-Content -LiteralPath "$outDir\CANDIDATE_DOCS.txt"
