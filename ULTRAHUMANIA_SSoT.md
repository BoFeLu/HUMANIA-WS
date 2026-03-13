ULTRAHUMANIA — SINGLE SOURCE OF TRUTH
SSOT_ID: UH_SSoT
BASELINE_TS: 20260312
LOCATION: C:\HUMANIA\ULTRAHUMANIA_SSoT.md

PURPOSE
Canonical entrypoint for understanding ULTRAHUMANIA without reconstructing context.

------------------------------------------------------------

SYSTEM_IDENTITY
ULTRAHUMANIA evolved from:

NEXUS
AIOPS1
AIOPS2
HUMANIA
TRANSHUMANIA
ULTRAHUMANIA

Primary objective:
robust personal infrastructure integrating automation, integrity verification,
observability, knowledge management and AI orchestration.

------------------------------------------------------------

SYSTEM_ROOT

C:\HUMANIA

Core subsystems include:

CORE
guard
watchdog
sentinel
verifiers
state
docs
tools
HANDOFF

------------------------------------------------------------

TRUST_ROOT

C:\ULTRAHUMANIA_TRUST_ROOT

Key components:

guardian.exe
root_manifest.json
root_manifest.json.sig
root_verify.ps1
secure_sentinel.ps1
keys\allowed_signers
pending\
archive\

------------------------------------------------------------

CANONICAL MASTER DOCUMENTS

docs/governance/ARCHITECTURE_MASTER_N2.md
docs/governance/INDEX_MASTER.md

------------------------------------------------------------

ARCHITECTURE DOCUMENTS

docs/architecture/SYSTEM_MAP_CANONICAL.md
docs/architecture/EXECUTION_DIAGRAM_REAL_20260312_141448.md
docs/architecture\ULTRAHUMANIA_RUNTIME_ARCHITECTURE.txt
docs/architecture\ULTRAHUMANIA_INTEGRITY_ARCHITECTURE.txt

------------------------------------------------------------

INTEGRITY GOVERNANCE DOCUMENTS

docs/governance/SIGNED_BASELINE_UPDATE_PROCEDURE_20260310.md
docs/governance/DUAL_SIGNING_AUTHORITY_NOTE_20260311.md
docs/governance/INTEGRITY_AND_GIT_INCIDENT_REPORT_20260310.md
docs/governance/TRUST_ROOT_BACKUP_EVIDENCE_20260310.md
docs/governance/INTEGRITY_PHASE_STATUS_20260311.md
docs/governance/PRIMARY_DOC_ALIGNMENT_AUDIT_20260312_141752.md

------------------------------------------------------------

OPERATIONAL TOOLS

tools/Update-SignedRootBaseline.ps1
tools/Get-UltrahumaniaSecurityHealth.ps1
tools/Invoke-UltrahumaniaGovernanceCycle.ps1

------------------------------------------------------------

HEALTH CHECK COMMAND

pwsh -NoProfile -ExecutionPolicy Bypass -File C:\HUMANIA\tools\Get-UltrahumaniaSecurityHealth.ps1

Expected result:

OVERALL STATUS: OK

------------------------------------------------------------

SESSION START PROTOCOL

1 Read this SSoT
2 Review SYSTEM_MAP_CANONICAL.md
3 Review latest EXECUTION_DIAGRAM_REAL_*.md
4 Run health check
5 Review HANDOFF\UH_BOOTSTRAP_INDEX.md

------------------------------------------------------------

NOTE

This document is the canonical entrypoint for ULTRAHUMANIA.
All major architectural references must be reachable from here.

------------------------------------------------------------

TRUST CHAIN STATUS

Date: 2026-03-12

Root signer:
ultrahumania_root_signer

Protected runtime file:
C:\HUMANIA\sentinel\sentinel_tick_new.ps1

Current hash:
38FE796A741C4993D0C96B20875E475CFA4438E6C28B6548C90332E9E20AD953

Verification nodes:

Windows
MiniPC
Pocophone (Termux)

Result:
Distributed verification operational.

------------------------------------------------------------

CURRENT VERIFIED RUNTIME STATUS

Fail-secure:
ACTIVE

Current watchdog runner:
C:\ULTRAHUMANIA_TRUST_ROOT\secure_sentinel.ps1

Current enforced chain:
WinSW
-> UH_WATCHDOG_LOOP.ps1
-> secure_sentinel.ps1
-> root_verify.ps1
-> sentinel_tick_new.ps1

Meaning:
root_verify is enforced before sentinel execution.

------------------------------------------------------------

CURRENT OPERATIONAL STATUS

- signed baseline active
- root verification active
- fail-secure active
- governance cycle operational
- quarantine-first cleanup model validated

METHOD RULE: 3C5B (Clear Complete Correct / 5 Blocks)
Reference: C:\HUMANIA\docs\governance\ULTRAHUMANIA_METHOD_3C5B.md

IDEAS DOCUMENT:
C:\HUMANIA\docs\ideas\ULTRAHUMANIA_IDEAS_AND_NEXT_STEPS.md

POSTGRESQL SYSTEM MAP:
C:\HUMANIA\POSTGRESQL_SYSTEM_MAP_LATEST.md

LA_CLAVE:
C:\HUMANIA\LA_CLAVE_LATEST.md
