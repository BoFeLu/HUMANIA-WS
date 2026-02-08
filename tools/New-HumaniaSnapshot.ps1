param(
  [string]$Project = "HUMANIA-WS",
  [string]$Objective = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Paths
$RepoRoot = (git rev-parse --show-toplevel).Trim()
$Templates = Join-Path $RepoRoot "docs/templates"
$StatusDir = Join-Path $RepoRoot "docs/status"

$StatusTemplate = Join-Path $Templates "STATUS_REPORT.md"
$ContextTemplate = Join-Path $Templates "CONTEXT_SUMMARY.md"

if (!(Test-Path $StatusTemplate)) { throw "Missing template: $StatusTemplate" }
if (!(Test-Path $ContextTemplate)) { throw "Missing template: $ContextTemplate" }

New-Item -ItemType Directory -Path $StatusDir -Force | Out-Null

# Timestamp (local)
$ts = Get-Date -Format "yyyyMMdd_HHmm"

$statusOut  = Join-Path $StatusDir "STATUS_REPORT_$ts.md"
$contextOut = Join-Path $StatusDir "CONTEXT_SUMMARY_$ts.md"

# Create from templates (only if not already existing)
if (!(Test-Path $statusOut))  { Copy-Item $StatusTemplate  $statusOut  -Force }
if (!(Test-Path $contextOut)) { Copy-Item $ContextTemplate $contextOut -Force }

# Add small header hints (prepend) to make filling faster
$hint = @"
<!--
Project: $Project
Objective: $Objective
Generated (local): $(Get-Date -Format s)
-->
"@

# Prepend only if not already present
function Prepend-IfMissing($path) {
  $content = Get-Content $path -Raw
  if ($content -notmatch "Generated \(local\):") {
    Set-Content -Encoding UTF8 -Path $path -Value ($hint + "`r`n" + $content)
  }
}
Prepend-IfMissing $statusOut
Prepend-IfMissing $contextOut

Write-Host "Created:"
Write-Host " - $statusOut"
Write-Host " - $contextOut"
