$ErrorActionPreference = 'Stop'

$ts = Get-Date -Format 'yyyyMMdd_HHmmss'
$outDir = "C:\HUMANIA\HANDOFF\DOC_SYNC_INSPECTION_$ts"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$targets = @(
    "C:\HUMANIA\docs\architecture",
    "C:\HUMANIA\docs\governance",
    "C:\HUMANIA\docs\context",
    "C:\HUMANIA\docs\status",
    "C:\HUMANIA\docs\analysis",
    "C:\HUMANIA\docs\constitution"
)

foreach ($t in $targets) {
    if (Test-Path -LiteralPath $t) {
        $safe = ($t -replace '[:\\]', '_').Trim('_')
        Get-ChildItem -LiteralPath $t -Recurse -File |
            Sort-Object FullName |
            Select-Object FullName, Length, LastWriteTime |
            Format-Table -AutoSize |
            Out-String -Width 4096 |
            Set-Content -LiteralPath "$outDir\$safe.txt" -Encoding UTF8
    }
}

Get-ChildItem -LiteralPath $outDir | Select-Object Name, Length, LastWriteTime | Format-Table -AutoSize
