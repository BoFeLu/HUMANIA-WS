ULTRAHUMANIA SYSTEM MAP CANONICAL
MAP_ID: UH_SYSTEM_MAP
BASELINE_TS: 20260312
LOCATION: C:\HUMANIA\docs\architecture\SYSTEM_MAP_CANONICAL.md

PURPOSE
Canonical structural map of the ULTRAHUMANIA system.
This document identifies the principal modules, their roles, dependencies and critical paths.

================================================================

1. SYSTEM ROOT

C:\HUMANIA

Main system purpose:
personal infrastructure platform for automation, integrity, observability,
documentation, controlled evolution and future AI orchestration.

================================================================

2. PRIMARY EXECUTION DOMAINS

2.1 Runtime domain
- CORE
- guard
- watchdog
- sentinel
- verifiers
- guardian
- state

2.2 Trust domain
- C:\ULTRAHUMANIA_TRUST_ROOT
- root manifests
- signatures
- allowed_signers
- root verification chain

2.3 Documentation domain
- docs\architecture
- docs\governance
- docs\context
- docs\status
- docs\analysis
- docs\constitution

2.4 Tooling domain
- tools
- verifier scripts
- inspection scripts
- baseline update tools
- health check tools
- governance cycle tools

2.5 Analysis workspace
- HANDOFF
- temporary inspection output
- context reconstruction artifacts
- non-runtime workspace material

================================================================

3. MAIN DIRECTORIES AND ROLES

C:\HUMANIA\CORE
Core operational logic and main system functions.

C:\HUMANIA\guard
Execution guards and control logic.

C:\HUMANIA\watchdog
Persistent supervision and service continuity layer.

C:\HUMANIA\sentinel
Integrity validation and alerting layer.

C:\HUMANIA\verifiers
Verification, audit, inventory and consistency scripts.

C:\HUMANIA\guardian
Binary or external guard-related control components.

C:\HUMANIA\state
Operational state, status, locks, runner evidence and runtime persistence.

C:\HUMANIA\docs
Canonical knowledge, architecture, governance, context and status documentation.

C:\HUMANIA\tools
Operational maintenance, health-check, governance-cycle and baseline update scripts.

C:\HUMANIA\HANDOFF
Workspace for handoff artifacts, inspections and context transfer material.
Not considered runtime core.

================================================================

4. TRUST ROOT STRUCTURE

Root path:
C:\ULTRAHUMANIA_TRUST_ROOT

Current trust-root elements:
- guardian.exe
- root_manifest.json
- root_manifest.json.sig
- root_verify.ps1
- secure_sentinel.ps1
- keys\allowed_signers
- pending\
- archive\

Current canonical root signer:
- ultrahumania_root_signer

Current verification nodes:
- Windows
- MiniPC
- Pocophone / Termux

Windows role:
- active runtime host
- verification host

================================================================

5. CRITICAL EXECUTION CHAIN

WinSW
-> C:\HUMANIA\watchdog\UH_WATCHDOG_LOOP.ps1
-> C:\ULTRAHUMANIA_TRUST_ROOT\secure_sentinel.ps1
-> C:\ULTRAHUMANIA_TRUST_ROOT\root_verify.ps1
-> C:\HUMANIA\sentinel\sentinel_tick_new.ps1

================================================================

6. CRITICAL OPERATIONAL TOOLS

C:\HUMANIA\tools\Update-SignedRootBaseline.ps1
Purpose:
prepare, import, validate and activate signed root baseline updates.

C:\HUMANIA\tools\Get-UltrahumaniaSecurityHealth.ps1
Purpose:
perform unified trust and integrity health checks.

C:\HUMANIA\tools\Invoke-UltrahumaniaGovernanceCycle.ps1
Purpose:
generate inventory, reality report, drift report, status report and bootstrap outputs.

================================================================

7. CANONICAL DOCUMENT ENTRYPOINTS

Root entrypoint:
C:\HUMANIA\ULTRAHUMANIA_SSoT.md

Governance reference:
C:\HUMANIA\docs\governance\SSOT_REFERENCE.md

Master documents:
C:\HUMANIA\docs\governance\ARCHITECTURE_MASTER_N2.md
C:\HUMANIA\docs\governance\INDEX_MASTER.md

Core architecture:
C:\HUMANIA\docs\architecture\EXECUTION_DIAGRAM_REAL_20260312_141448.md
C:\HUMANIA\docs\architecture\ULTRAHUMANIA_RUNTIME_ARCHITECTURE.txt
C:\HUMANIA\docs\architecture\ULTRAHUMANIA_INTEGRITY_ARCHITECTURE.txt

================================================================

8. CURRENT OPERATIONAL STATUS

Validated at 2026-03-12:
- repository structurally audited
- signed baseline active
- root_verify.ps1 = PASS
- Get-UltrahumaniaSecurityHealth.ps1 = PASS
- fail-secure active
- governance cycle operational
- pending manifest state cleaned
- quarantine-first cleanup validated

================================================================

9. KNOWN STRUCTURAL LIMITATIONS

- trust root still hosted on the same Windows machine
- verification logic still primarily implemented in PowerShell
- documentation corpus remains large and historically layered
- knowledge extraction / ULTRA_DB not yet implemented
- logs and historical artifacts still require stronger lifecycle automation

================================================================

10. NEXT STRUCTURAL PHASES

1. housekeeping / retention automation
2. latest/history canonicalization
3. evidence policy refinement
4. trust perimeter expansion
5. possible machine-readable health outputs
6. later knowledge-base implementation

================================================================

11. INTERPRETATION RULE

If another document conflicts with this system map on structure,
the conflict must be resolved by checking:
- ULTRAHUMANIA_SSoT.md
- EXECUTION_DIAGRAM_REAL_*.md
- root_verify.ps1 outputs
- Get-UltrahumaniaSecurityHealth.ps1 outputs
and then updating the outdated document.

================================================================

12. TRUST CHAIN REPAIR EVENT

Date: 2026-03-12

Event:
Trust chain restored after signing key loss.

Actions:
- new root signer generated
- allowed_signers updated
- sentinel hash recomputed
- root_manifest updated
- manifest re-signed

Verification nodes:
- Windows
- MiniPC
- Pocophone / Termux

Result:
Distributed signature verification operational.

================================================================

13. FAIL-SECURE ACTIVATION EVENT

Date: 2026-03-12

Event:
watchdog runner changed from direct sentinel execution
to secure_sentinel enforced execution.

Result:
root_verify is enforced before sentinel execution.
