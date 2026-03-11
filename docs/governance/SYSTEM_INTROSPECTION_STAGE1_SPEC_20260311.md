# SYSTEM INTROSPECTION STAGE-1 SPEC - 2026-03-11

## Purpose

This document defines the minimal operational specification for the first manually executable version of ULTRAHUMANIA_SYSTEM_INSPECTOR.

## Stage-1 implementation posture

Stage 1 must remain:

- read-only
- deterministic
- evidence-first
- manually executable
- reporting-oriented
- non-remediating

## Exact stage-1 input set

### Governance / architecture documents
- C:\HUMANIA\docs\governance\INDEX_MASTER.md
- C:\HUMANIA\docs\governance\ULTRAHUMANIA_SYSTEM_OVERVIEW.md
- C:\HUMANIA\docs\governance\SYSTEM_INTROSPECTION_LAYER_DRAFT_20260311.md
- C:\HUMANIA\docs\governance\SYSTEM_INTROSPECTION_CONTRACT_20260311.md
- C:\HUMANIA\docs\architecture\SYSTEM_MAP_CANONICAL.md
- C:\HUMANIA\docs\architecture\ULTRAHUMANIA_INTEGRITY_ARCHITECTURE.txt

### Local operational signals
- C:\HUMANIA\tools\Get-UltrahumaniaSecurityHealth.ps1
- C:\HUMANIA\tools\Update-SignedRootBaseline.ps1
- C:\HUMANIA\sentinel\manifest.json
- C:\HUMANIA\sentinel\last_alert.state
- C:\HUMANIA\sentinel\sentinel_tick_new.ps1
- C:\HUMANIA\watchdog\UH_WATCHDOG.exe
- C:\HUMANIA\watchdog\UH_WATCHDOG.xml
- C:\HUMANIA\HANDOFF\UH_BOOTSTRAP_CONTEXT.ps1
- C:\HUMANIA\HANDOFF\UH_BOOTSTRAP_INDEX.md

### Runner state signals
- C:\HUMANIA\state\runner\heartbeat.json
- C:\HUMANIA\state\runner\last_failure.json
- C:\HUMANIA\state\runner\last_success.json

### Trust-root visibility scope
- top-level visibility of C:\ULTRAHUMANIA_TRUST_ROOT
- file presence checks only at stage 1
- no mutation
- no signature rewrite
- no pending/archive manipulation

## Exact stage-1 checks

### Check family 1 - Presence checks
The inspector must verify the presence of every stage-1 input path listed above.

### Check family 2 - Minimal structure checks
The inspector must verify:
- that the three runner state files exist
- that the two HANDOFF bridge entrypoints exist
- that trust-root top-level critical files exist
- that watchdog executable and XML exist
- that sentinel manifest and main tick script exist

### Check family 3 - Documentation coherence checks
The inspector may perform minimal consistency checks across:
- INDEX_MASTER.md
- ULTRAHUMANIA_SYSTEM_OVERVIEW.md
- SYSTEM_INTROSPECTION_LAYER_DRAFT_20260311.md
- SYSTEM_INTROSPECTION_CONTRACT_20260311.md
- SYSTEM_MAP_CANONICAL.md

Stage 1 coherence checks must remain descriptive, not semantic-heavy.

### Check family 4 - Freshness visibility checks
The inspector may capture visible LastWriteTime values for the monitored inputs in order to produce a time-oriented state snapshot.

## Exact stage-1 outputs

Stage 1 may generate these outputs only:

- SYSTEM_HEALTH_REPORT
- SYSTEM_STRUCTURE_SNAPSHOT
- TRUST_ROOT_STATUS
- BOOTSTRAP_STATUS
- DOC_SYNC_STATUS
- CRITICAL_PATH_STATUS

## Stage-1 output location policy

Output file paths are not yet fixed canonically.
Before implementation, stage-1 outputs must be proposed explicitly and validated.

## Manual execution model

Stage 1 is defined for direct manual execution by the operator.
No scheduled execution is part of the approved stage-1 operational baseline yet.

## Stage-1 prohibited behavior

The inspector must not:

- modify trust-root contents
- modify repository contents
- modify Git state
- rewrite runner state files
- rotate logs
- purge artifacts
- trigger hidden remediation
- infer conclusions beyond observed evidence

## Minimum success criterion

A stage-1 inspector implementation is acceptable only if it can:
- read the defined inputs
- report path presence/absence
- report minimal critical-path visibility
- emit descriptive outputs without changing protected state
