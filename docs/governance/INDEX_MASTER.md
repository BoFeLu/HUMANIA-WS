# ÍNDICE MAESTRO DE HUMANIA (N2)
**ESTADO: OPERATIVO | VERSIÓN: 2026.02.19**

## I. GOBERNANZA (N2)
- [CONSTITUTION_MASTER_N2.md](CONSTITUTION_MASTER_N2.md) - Fundamento Constitucional.
- [ARCHITECTURE_MASTER_N2.md](ARCHITECTURE_MASTER_N2.md) - Arquitectura Maestra (SSoT).
- [INDEX_MASTER.md](INDEX_MASTER.md) - Este documento (SSoT).

## II. LEYES INVARIANTES (N3)
- [LAW_EVIDENCE_OUTPUT_REQUIRED.md](../laws/LAW_EVIDENCE_OUTPUT_REQUIRED.md) - Evidencia obligatoria (output + exitcode + ruta guardada).
- [LAW_IO_MASTER_TRANSFER.md](../laws/LAW_IO_MASTER_TRANSFER.md) - Protocolo de Intercambio.
- [LAW_AUDIT_ROTATION_THRESHOLD_50MB.md](../laws/LAW_AUDIT_ROTATION_THRESHOLD_50MB.md) - Umbral Anti-Monstruo.
- [LAW-COMM-001_TUTEO_OBLIGATORIO.md](../laws/LAW-COMM-001_TUTEO_OBLIGATORIO.md) - Norma de Comunicación.

## III. PROCEDIMIENTOS (N5)
- [KNOWN_ISSUES_DB_SEED.jsonl](../procedures/KNOWN_ISSUES_DB_SEED.jsonl) - Semilla canónica (JSONL) para el esquema Problemas→Soluciones (futuro Postgres).
- [PROC_MASTER_V5_ULTIMATE.md](../procedures/PROC_MASTER_V5_ULTIMATE.md) - Manual de Operaciones.
- [STRATEGY_DB_MIGRATION_POSTGRES.md](../procedures/STRATEGY_DB_MIGRATION_POSTGRES.md) - Plan de Datos (Ex-LOG_005).
- [KNOWLEDGE_BASE_LESSONS.psv](../procedures/KNOWLEDGE_BASE_LESSONS.psv) - Memoria de fallos técnicos.

## IV. PROTOCOLO DE EXCELENCIA (N1)
- **Verificación Rápida Obligatoria:** Ninguna fase se cierra sin que el Operador pegue el output de éxito de la terminal.
- Codificación canónica docs: **UTF-8 (preferible sin BOM)**. BOM tolerado si no rompe tooling. Evidencia: logs\ENCODING_*.
---

## Seguridad y Resiliencia del Núcleo (Kernel)

- Blindaje del núcleo (ACL anti-borrado + backup externo D:\ + verificación SHA256)
  - Documento canónico: docs/governance/CONSTITUTION_MASTER_N2.md (sección “BLINDAJE DEL NÚCLEO”)
  - Evidencia: logs/KERNEL_HASHSET_*.txt y backups en D:\HUMANIA_BACKUP_SECURE\


## V. INTEGRIDAD Y RESILIENCIA (OPERATIVO)

### Kernel Backup (D:\)
- Tarea: HUMANIA_KERNEL_BACKUP (Daily 03:00)
- Script: C:\HUMANIA\verifiers\kernel_backup.ps1
- Evidencia: C:\HUMANIA\logs\KERNEL_HASHSET_*.txt y D:\HUMANIA_BACKUP_SECURE\KERNEL_*\KERNEL_HASHES.txt

### Self-Integrity Check (LEVEL_1)
- Script: C:\HUMANIA\verifiers\self_integrity_level1.ps1
- Ejecución: powershell -NoProfile -ExecutionPolicy Bypass -File C:\HUMANIA\verifiers\self_integrity_level1.ps1
- Evidencia: C:\HUMANIA\logs\SELF_INTEGRITY_LEVEL1_*.txt





## 2026-03-11 - Integrity Documentation Sync

Relevant current references:
- docs/architecture/ULTRAHUMANIA_INTEGRITY_ARCHITECTURE.txt
- docs/governance/DOCUMENTATION_SYNC_NOTE_20260311.md
- docs/governance/INTEGRITY_PHASE_STATUS_20260311.md
- docs/governance/INTEGRITY_AND_GIT_INCIDENT_REPORT_20260310.md
- docs/governance/SIGNED_BASELINE_UPDATE_PROCEDURE_20260310.md
- docs/governance/REMOTE_SIGNING_CUSTODY_NOTE_20260311.md
- docs/governance/DUAL_SIGNING_AUTHORITY_NOTE_20260311.md
- docs/governance/TRUST_ROOT_BACKUP_EVIDENCE_20260310.md
- docs/governance/SIGNED_BASELINE_APPLY_20260311_103844.md
- docs/governance/BASELINE_SIGNING_QUICKGUIDE_PLAIN_20260311.txt
- docs/governance/HEALTHCHECK_QUICKGUIDE_PLAIN_20260311.txt
- docs/governance/HANDOFF_BOOTSTRAP_CANONICAL_MODEL_20260311.md

Operational tools:
- tools/Update-SignedRootBaseline.ps1
- tools/Get-UltrahumaniaSecurityHealth.ps1

------------------------------------------------------------

SSOT ENTRYPOINT
BASELINE_TS: 20260311

Canonical system entrypoint:

C:\HUMANIA\ULTRAHUMANIA_SSoT.md

This document defines the minimal context required to
understand the system architecture, governance and runtime
structure without reconstructing project context manually.

------------------------------------------------------------


SYSTEM MAP CANONICAL
BASELINE_TS: 20260311

Canonical structural map:
docs/architecture/SYSTEM_MAP_CANONICAL.md

This document defines modules, domains, critical paths and
trust-root relationships at system level.


