# EXECUTION DIAGRAM REAL

Generated truth alignment date: 2026-03-16
System root: C:\HUMANIA

## CANONICAL ACTIVE EXECUTION PATH

Scheduled Task
-> UH_Watchdog_Task
-> powershell.exe
-> C:\HUMANIA\guard\UH_GUARD_RUN.ps1
-> C:\ULTRAHUMANIA_TRUST_ROOT\secure_sentinel.ps1
-> C:\ULTRAHUMANIA_TRUST_ROOT\root_verify.ps1
-> C:\HUMANIA\sentinel\sentinel_tick_new.ps1

## MEANING

1. UH_Watchdog_Task is the canonical launcher.
2. UH_GUARD_RUN.ps1 is the active runtime guard entrypoint.
3. secure_sentinel.ps1 enforces root verification before sentinel execution.
4. root_verify.ps1 validates trust-root integrity.
5. sentinel_tick_new.ps1 is the protected runtime tick target.

## LEGACY RUNTIME STATUS

Disabled / not canonical:

- service UH_WATCHDOG
- service UH_WATCHDOG_N2
- UH_WATCHDOG_LOOP.ps1 as active runtime path
- HUMANIA_GUARD_TICK task
- UH_GUARD_RUNNER task

## VERIFIED OPERATIONAL CONCLUSION

The real execution path is task-based, not WinSW-based.

Canonical launcher:
UH_Watchdog_Task

Canonical guard path:
C:\HUMANIA\guard\UH_GUARD_RUN.ps1

Protected chain:
C:\HUMANIA\guard\UH_GUARD_RUN.ps1
-> C:\ULTRAHUMANIA_TRUST_ROOT\secure_sentinel.ps1
-> C:\ULTRAHUMANIA_TRUST_ROOT\root_verify.ps1
-> C:\HUMANIA\sentinel\sentinel_tick_new.ps1

## 2026-03-17 - SecurityHealth Alignment Addendum

Validated after integrity recovery close-out and canonical/runtime documentation alignment.

The execution chain represented in this diagram remains valid for the active guard and protected sentinel runtime path:

- UH_Watchdog_Task
- C:\HUMANIA\guard\UH_GUARD_RUN.ps1
- C:\HUMANIA\sentinel\sentinel_tick_new.ps1

Additional verified operational alignment:

- health verification is performed through tools/Get-UltrahumaniaSecurityHealth.ps1
- RepoHealth naming is no longer the active reference for the validated health provider path
- volatile runtime evidence artifacts may exist on disk for observability, but they are not part of the canonical execution chain represented by this diagram
