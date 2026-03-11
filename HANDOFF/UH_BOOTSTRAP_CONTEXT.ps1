$ErrorActionPreference = 'Stop'

$BootstrapDir = "C:\Users\Alber2Pruebas\Desktop\INFORMES UH"
$IndexPath = Join-Path $BootstrapDir "UH_BOOTSTRAP_INDEX.md"

Write-Host "[BOOTSTRAP STUB] External bootstrap location expected:" -ForegroundColor Cyan
Write-Host $BootstrapDir

if (!(Test-Path -LiteralPath $BootstrapDir)) {
    Write-Host "[FAIL] Bootstrap directory not found." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[OK] Bootstrap directory exists." -ForegroundColor Green

if (Test-Path -LiteralPath $IndexPath) {
    Write-Host "[OK] Index found:" -ForegroundColor Green
    Write-Host $IndexPath
} else {
    Write-Host "[WARN] UH_BOOTSTRAP_INDEX.md not found in external bootstrap directory." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "[LATEST BOOTSTRAP FILES]" -ForegroundColor Cyan

Get-ChildItem -LiteralPath $BootstrapDir -Filter "UH_CHAT_BOOTSTRAP_*.md" -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 5 Name, Length, LastWriteTime |
    Format-Table -AutoSize

exit 0
