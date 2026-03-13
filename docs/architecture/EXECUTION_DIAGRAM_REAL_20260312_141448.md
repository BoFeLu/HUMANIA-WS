ULTRAHUMANIA EXECUTION DIAGRAM REAL
Generated: 2026-03-12 14:14:48

================================================
SERVICE LAYER
================================================

Service definition:
C:\HUMANIA\watchdog\UH_WATCHDOG.xml

Service arguments:
-NoProfile -NonInteractive -ExecutionPolicy Bypass -File "C:\HUMANIA\watchdog\UH_WATCHDOG_LOOP.ps1" -IntervalSeconds 60 -FailBackoffSeconds 300

================================================
WATCHDOG LAYER
================================================

Watchdog loop:
C:\HUMANIA\watchdog\UH_WATCHDOG_LOOP.ps1

Configured runner:
C:\ULTRAHUMANIA_TRUST_ROOT\secure_sentinel.ps1

================================================
SECURE EXECUTION CHAIN
================================================

WinSW
 -> UH_WATCHDOG_LOOP.ps1
 -> C:\ULTRAHUMANIA_TRUST_ROOT\secure_sentinel.ps1
 -> C:\ULTRAHUMANIA_TRUST_ROOT\root_verify.ps1
 -> C:\HUMANIA\sentinel\sentinel_tick_new.ps1

================================================
TRUST-ENFORCED INTERPRETATION
================================================

1. WinSW starts watchdog loop
2. watchdog loop invokes secure_sentinel.ps1
3. secure_sentinel.ps1 invokes root_verify.ps1
4. root_verify.ps1 validates signed root manifest
5. only if verification passes, sentinel_tick_new.ps1 is executed

================================================
CRITICAL FILES
================================================

C:\HUMANIA\watchdog\UH_WATCHDOG.xml
C:\HUMANIA\watchdog\UH_WATCHDOG_LOOP.ps1
C:\ULTRAHUMANIA_TRUST_ROOT\secure_sentinel.ps1
C:\ULTRAHUMANIA_TRUST_ROOT\root_verify.ps1
C:\ULTRAHUMANIA_TRUST_ROOT\root_manifest.json
C:\ULTRAHUMANIA_TRUST_ROOT\root_manifest.json.sig
C:\ULTRAHUMANIA_TRUST_ROOT\keys\allowed_signers
C:\HUMANIA\sentinel\sentinel_tick_new.ps1
C:\HUMANIA\sentinel\manifest.json
C:\HUMANIA\BIN\guardian.exe

================================================
CURRENT STATUS
================================================

- fail-secure active
- root verification enforced before sentinel execution
- signed baseline active
- runtime chain reconstructed from real files
