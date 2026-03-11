ULTRAHUMANIA — SINGLE SOURCE OF TRUTH
SSOT_ID: UH_SSoT
BASELINE_TS: 20260311
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

docs/architecture/ULTRAHUMANIA_RUNTIME_ARCHITECTURE.txt
docs/architecture/ULTRAHUMANIA_INTEGRITY_ARCHITECTURE.txt

------------------------------------------------------------

INTEGRITY GOVERNANCE DOCUMENTS

docs/governance/SIGNED_BASELINE_UPDATE_PROCEDURE_20260310.md
docs/governance/DUAL_SIGNING_AUTHORITY_NOTE_20260311.md
docs/governance/INTEGRITY_AND_GIT_INCIDENT_REPORT_20260310.md
docs/governance/TRUST_ROOT_BACKUP_EVIDENCE_20260310.md
docs/governance/INTEGRITY_PHASE_STATUS_20260311.md

------------------------------------------------------------

OPERATIONAL TOOLS

tools/Update-SignedRootBaseline.ps1
tools/Get-UltrahumaniaSecurityHealth.ps1

------------------------------------------------------------

HEALTH CHECK COMMAND

pwsh -NoProfile -ExecutionPolicy Bypass -File C:\HUMANIA\tools\Get-UltrahumaniaSecurityHealth.ps1

Expected result:

OVERALL STATUS: OK

------------------------------------------------------------

SESSION START PROTOCOL

1 Read this SSoT
2 Review architecture documents
3 Review integrity architecture
4 Run health check

------------------------------------------------------------

NOTE

This document is the canonical entrypoint for ULTRAHUMANIA.
All major architectural references must be reachable from here.

SYSTEM MAP DOCUMENT

docs/architecture/SYSTEM_MAP_CANONICAL.md

This is the canonical structural map of modules, domains,
execution chains and major system paths.

