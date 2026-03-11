ULTRAHUMANIA — SINGLE SOURCE OF TRUTH (SSoT)
Version: 2026-03-11

PURPOSE
This document provides the minimal canonical context required to understand the ULTRAHUMANIA system without repeatedly reconstructing project context across sessions.

----------------------------------------------------------------

1. PROJECT IDENTITY

ULTRAHUMANIA is a long-term infrastructure project evolving from:

NEXUS
AIOPS1
AIOPS2
HUMANIA
TRANSHUMANIA
ULTRAHUMANIA

The objective is to build a robust personal computing platform integrating:

- automation
- integrity verification
- observability
- knowledge management
- AI orchestration
- documented system evolution

----------------------------------------------------------------

2. CORE PRINCIPLES

ULTRAHUMANIA operates under these rules:

- evidence-based operations
- deterministic scripts
- no hidden assumptions
- documented decisions
- incremental evolution
- reproducible system state

Every significant change must produce:

evidence
documentation
verification

----------------------------------------------------------------

3. CURRENT SYSTEM ARCHITECTURE

High-level trust chain:

external signing authority
miniPC or Pocophone signer
root_manifest.json.sig
allowed_signers
root_verify.ps1
secure_sentinel.ps1
sentinel manifest
protected runtime files

----------------------------------------------------------------

4. TRUST ROOT LOCATION

C:\ULTRAHUMANIA_TRUST_ROOT

Main components:

guardian.exe
root_manifest.json
root_manifest.json.sig
root_verify.ps1
secure_sentinel.ps1
keys\allowed_signers
pending\
archive\

----------------------------------------------------------------

5. REPOSITORY ROOT

C:\HUMANIA

Main directories:

CORE
guard
watchdog
sentinel
verifiers
state
docs
tools
HANDOFF

HANDOFF is a repository-side minimal bridge area: it keeps temporary inspection artifacts ignored by design, while officially tracked bootstrap bridge entrypoints reconnect the repository with the external INFORMES UH workspace.

----------------------------------------------------------------

6. CANONICAL ARCHITECTURE DOCUMENTS

docs/architecture/ULTRAHUMANIA_RUNTIME_ARCHITECTURE.txt
docs/architecture/ULTRAHUMANIA_INTEGRITY_ARCHITECTURE.txt
docs/governance/ARCHITECTURE_MASTER_N2.md
docs/governance/INDEX_MASTER.md

----------------------------------------------------------------

7. GOVERNANCE DOCUMENTS

docs/governance/SIGNED_BASELINE_UPDATE_PROCEDURE_20260310.md
docs/governance/DUAL_SIGNING_AUTHORITY_NOTE_20260311.md
docs/governance/INTEGRITY_AND_GIT_INCIDENT_REPORT_20260310.md
docs/governance/TRUST_ROOT_BACKUP_EVIDENCE_20260310.md
docs/governance/INTEGRITY_PHASE_STATUS_20260311.md

----------------------------------------------------------------

8. OPERATIONAL TOOLS

tools/Update-SignedRootBaseline.ps1
tools/Get-UltrahumaniaSecurityHealth.ps1

Health check command:

pwsh -NoProfile -ExecutionPolicy Bypass -File C:\HUMANIA\tools\Get-UltrahumaniaSecurityHealth.ps1

Expected result:

OVERALL STATUS: OK

----------------------------------------------------------------

9. CURRENT PROJECT STATE

Validated components:

- repository integrity stabilized
- signed trust-root baseline operational
- dual signing authority active
- baseline update workflow validated
- unified health-check operational
- architecture documentation synchronized

----------------------------------------------------------------

10. CURRENT LIMITATIONS

- trust root located on the Windows host
- verification scripts implemented in PowerShell
- knowledge extraction from chats not yet implemented
- ULTRA_DB knowledge system planned but not implemented

----------------------------------------------------------------

11. CURRENT DEVELOPMENT FOCUS

- system consolidation
- architectural clarity
- documentation coherence

----------------------------------------------------------------

12. SESSION START PROTOCOL

For any new session involving ULTRAHUMANIA:

1. read this SSoT
2. review runtime architecture
3. review integrity architecture
4. run health check

Only then start new work.

----------------------------------------------------------------

13. FINAL NOTE

ULTRAHUMANIA evolves through documented architecture and reproducible procedures rather than rigid initial design.

This SSoT exists to prevent context reconstruction across sessions.

