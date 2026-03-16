ULTRAHUMANIA SYSTEM REALITY REPORT
TS: 20260312_161209

SYSTEM ROOT
C:\HUMANIA

TRUST ROOT
C:\ULTRAHUMANIA_TRUST_ROOT

ACTUAL RUNTIME CHAIN
Scheduled task:
UH_Watchdog_Task

Current action:
powershell.exe -ExecutionPolicy Bypass -NoProfile -NonInteractive -WindowStyle Hidden -File C:\HUMANIA\guard\UH_GUARD_RUN.ps1 -Trigger SCHEDULED_TICK

Active guard:
C:\HUMANIA\guard\UH_GUARD_RUN.ps1

FAIL-SECURE ACTIVE
True

EXPECTED SECURE RUNNER
C:\ULTRAHUMANIA_TRUST_ROOT\secure_sentinel.ps1

ROOT VERIFY
ExitCode: 0

[ROOT OK] manifest signature valid
[ROOT OK] C:\HUMANIA\sentinel\sentinel_tick_new.ps1

HEALTH CHECK
ExitCode: 0

ULTRAHUMANIA SECURITY HEALTH CHECK

allowed_signers                  OK  C:\ULTRAHUMANIA_TRUST_ROOT\keys\allowed_signers
root_manifest.json               OK  C:\ULTRAHUMANIA_TRUST_ROOT\root_manifest.json
root_manifest.json.sig           OK  C:\ULTRAHUMANIA_TRUST_ROOT\root_manifest.json.sig
root_verify.ps1                  OK  C:\ULTRAHUMANIA_TRUST_ROOT\root_verify.ps1
secure_sentinel.ps1              OK  C:\ULTRAHUMANIA_TRUST_ROOT\secure_sentinel.ps1
sentinel manifest                OK  C:\HUMANIA\sentinel\manifest.json
guardian.exe                     OK  C:\HUMANIA\BIN\guardian.exe
sentinel_tick_new.ps1            OK  C:\HUMANIA\sentinel\sentinel_tick_new.ps1

root manifest signature          OK

[ROOT OK] manifest signature valid
[ROOT OK] C:\HUMANIA\sentinel\sentinel_tick_new.ps1
root_verify execution            OK

[ROOT OK] manifest signature valid
[ROOT OK] C:\HUMANIA\sentinel\sentinel_tick_new.ps1
[OK] C:\HUMANIA\BIN\guardian.exe
[OK] C:\HUMANIA\sentinel\sentinel_tick_new.ps1
secure_sentinel execution        OK

OVERALL STATUS: OK

CURRENT PROTECTED FILE
C:\HUMANIA\sentinel\sentinel_tick_new.ps1

CURRENT PROTECTED HASH
38FE796A741C4993D0C96B20875E475CFA4438E6C28B6548C90332E9E20AD953

ROOT MANIFEST HASH
38FE796A741C4993D0C96B20875E475CFA4438E6C28B6548C90332E9E20AD953

CURRENT INVENTORY
C:\HUMANIA\docs\context\INVENTORY_CANON_20260312_161209.json
