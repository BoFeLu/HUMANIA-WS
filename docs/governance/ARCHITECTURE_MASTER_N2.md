# ARQUITECTURA MAESTRA DE ULTRAHUMANIA (N2)
**ESTADO: VIGENTE | VERSIÓN: 2026.02.27 | AUTORIDAD: GOBERNANZA**

## 1. Propósito del sistema
ULTRAHUMANIA define un sistema de trabajo humano–IA gobernado por leyes canónicas, evidencia verificable y continuidad entre sesiones, para ejecutar operaciones técnicas y de conocimiento sin suposiciones, sin deriva y con trazabilidad total.

## 2. Componentes (visión de conjunto)
- **Operador humano (autoridad final):** decide, valida outputs, y aprueba cambios.
- **LLM/Asistente:** actúa bajo leyes vitales (no hypotheticals, evidence-first, stop rule, no cross-layer, evidence-gated).
- **Runner (UH_GUARD_RUN):** genera snapshots canónicos (CONTEXT/STATUS/CONSTITUTION/MINI/INVENTORY) y aplica tests mínimos de contenido.
- **Watchdog (UH_WATCHDOG):** supervisión/continuidad del loop (evidencia separada por hashes y logs).
- **Notario (Ledger/DB):** módulo de auditoría inmutable para eventos y evidencia (PostgreSQL).
- **Agentes AIOPS:**
  - **AIOPS1:** mantenimiento/operativa base (ya completado según canónicos del proyecto).
  - **AIOPS2:** agente ampliado (pendiente), con mayor capacidad y usos.
- **Orquestador:** coordinación entre LLM local/remoto, agentes y fuentes de datos.
- **LLM local (Mistral 7B):** motor local integrado en la arquitectura (instalado).
- **Base de Datos PostgreSQL (doble esquema):**
  - Esquema de problemas/soluciones técnicas.
  - Esquema de corpus legal/procedimental (HUMANIA–TRANSHUMANIA–ULTRAHUMANIA).

## 3. Artefactos canónicos y continuidad entre chats
- Snapshot de continuidad LEVEL_3: generado por el runner.
- Artefactos mínimos a adjuntar en nuevo chat:
  - CONTEXT_SUMMARY_{ts}.md
  - STATUS_REPORT_{ts}.md
  - DOCS_CONSTITUTION_{ts}.txt
  - MINI_REPORT_{ts}.md
  - INVENTORY_CANON_{ts}.json (si el runner lo genera para el ts)
- En el nuevo chat: ACK_INIT obligatorio antes de cualquier acción.

## 4. Invariantes operativos (resumen)
- Evidence-first + fail-closed.
- No hypotheticals.
- Evidence-gated (HASTA 5 bloques por turno, solo foco activo/consulta directa).
- Stop rule (no avanzar sin output pegado).
- No cross-layer.

## 5. Estado del módulo actual
Módulo activo: **aseguramiento de continuidad y contextualización perfecta entre chats** (protocolos, canónicos, handoff mecánico, ausencia de reexplicación).

## 6. Pendientes canónicos inmediatos
- Asegurar que el paquete de handoff incluya explícitamente INVENTORY en last_success.json o en MINI_REPORT.
- Añadir un artefacto canónico de “handoff delta” (CHAT_HANDOFF/DELTA_SINCE_LAST_SUCCESS) si se adopta como estándar.

## 2026-03-11 - Integrity Architecture Addendum

New canonical integrity references added after trust-root hardening, external signing validation, signed baseline workflow validation, and unified health-check validation:

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
- tools/Update-SignedRootBaseline.ps1
- tools/Get-UltrahumaniaSecurityHealth.ps1

Operational state validated:
- signed baseline update: PASS
- dual signing authority: PASS
- health check: OVERALL STATUS: OK
