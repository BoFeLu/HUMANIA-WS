$ErrorActionPreference = 'Stop'

$ts = Get-Date -Format 'yyyyMMdd_HHmmss'
$outDir = "C:\HUMANIA\HANDOFF\DOC_SYNC_REFERENCES_$ts"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$terms = @(
    'ULTRAHUMANIA_TRUST_ROOT',
    'root_manifest.json',
    'root_verify.ps1',
    'secure_sentinel.ps1',
    'allowed_signers',
    'Update-SignedRootBaseline.ps1',
    'Get-UltrahumaniaSecurityHealth.ps1',
    'miniPC',
    'Pocophone',
    'Termux',
    'integrity_baseline_20260310',
    'signed baseline',
    'dual signing'
)

$files = Get-ChildItem -LiteralPath "C:\HUMANIA\docs" -Recurse -File

foreach ($term in $terms) {
    $safe = ($term -replace '[^A-Za-z0-9._-]', '_')
    $matches = foreach ($f in $files) {
        Select-String -LiteralPath $f.FullName -Pattern $term -SimpleMatch -ErrorAction SilentlyContinue
    }

    if ($matches) {
        $matches |
            Select-Object Path, LineNumber, Line |
            Format-Table -AutoSize |
            Out-String -Width 4096 |
            Set-Content -LiteralPath "$outDir\$safe.txt" -Encoding UTF8
    } else {
        "NO_MATCHES: $term" | Set-Content -LiteralPath "$outDir\$safe.txt" -Encoding UTF8
    }
}

Get-ChildItem -LiteralPath $outDir | Select-Object Name, Length | Format-Table -AutoSize
