$ErrorActionPreference = 'Stop'

$ts = Get-Date -Format 'yyyyMMdd_HHmmss'
$outFile = "C:\HUMANIA\HANDOFF\DOC_SYNC_HEADS_$ts.txt"

$candidates = Get-ChildItem -LiteralPath "C:\HUMANIA\docs" -Recurse -File |
    Where-Object {
        $_.Name -match 'ARCHITECTURE|SYSTEM_MAP|DOCUMENTATION_INDEX|SECURITY|INTEGRITY|RUNBOOK|ROADMAP|FOUNDATION|BOOTSTRAP|INDEX'
    } |
    Sort-Object FullName

foreach ($f in $candidates) {
    "==================================================" | Add-Content -LiteralPath $outFile -Encoding UTF8
    $f.FullName | Add-Content -LiteralPath $outFile -Encoding UTF8
    "--------------------------------------------------" | Add-Content -LiteralPath $outFile -Encoding UTF8
    Get-Content -LiteralPath $f.FullName -TotalCount 30 | Add-Content -LiteralPath $outFile -Encoding UTF8
    "" | Add-Content -LiteralPath $outFile -Encoding UTF8
}

Get-Item -LiteralPath $outFile | Format-List FullName, Length, LastWriteTime
