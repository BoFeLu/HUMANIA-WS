# HUMANIA WS (Human–IA Work System)

HUMANIA WS is a documentation-first work system for operating complex, long-running technical projects with AI assistance.

HUMANIA WS es un sistema de trabajo (humano–IA) centrado en documentación canónica para proyectos técnicos largos y complejos, evitando pérdida de contexto y degradación de fluidez.

## Name clarification
HUMANIA WS is an independent, non-commercial documentation project.  
It is not affiliated with, endorsed by, or related to any company, product, or organization named “Humania”.

Aclaración: HUMANIA WS es un proyecto independiente y no comercial de documentación. No guarda relación ni afiliación con entidades llamadas “Humania”.

## What this is
- A practical system to work with AI on complex projects
- Canonical docs (decisions/contracts/workflows) that survive chat resets
- An operational discipline to prevent UI lag, context loss, and repeated mistakes

## Qué es esto (resumen en español)
- Un sistema práctico para trabajar con IA en proyectos complejos
- Documentos canónicos que sobreviven a reinicios de chat
- Disciplina operativa para mantener fluidez y trazabilidad

## Real-world usage loop (operating model)

### 1) Work in short-lived chats
- One objective per message
- Avoid long terminal dumps unless explicitly requested
- Prefer small, verifiable steps

Canonical rules:
- docs/contracts/HUMAN_EFFICIENCY_CONTRACT.md
- docs/contracts/AI_WARNINGS_POLICY.md
- docs/contracts/TONE_AND_LANGUAGE_POLICY.md

### 1) Trabajo real (en español, directo)
- Un objetivo por mensaje
- Evitar volcados largos (salvo petición explícita)
- Cambios pequeños y verificables

Documentos canónicos:
- docs/contracts/HUMAN_EFFICIENCY_CONTRACT.md
- docs/contracts/AI_WARNINGS_POLICY.md
- docs/contracts/TONE_AND_LANGUAGE_POLICY.md

### 2) When lag appears: close session properly
Follow:
- docs/workflow/CLOSE_SESSION_AND_MIGRATE.md
- docs/workflow/STATUS_AND_CONTEXT_SNAPSHOT.md

Create snapshot instances under `docs/status/`:
- `STATUS_REPORT_YYYYMMDD_HHMM.md`
- `CONTEXT_SUMMARY_YYYYMMDD_HHMM.md`

### 2) Si aparece lag: cierre y migración (español)
- Cierra la sesión de forma segura y migra a un chat nuevo
- Genera STATUS_REPORT y CONTEXT_SUMMARY como instancias en `docs/status/`
- Evidencias largas: a fichero en `docs/evidence/` y solo extractos en el reporte

### 3) Commit via PR (protected main)
- Create a branch
- Commit only relevant docs/evidence
- Open a PR and squash-merge

### 4) Post-merge cleanup (mandatory order)
Follow exactly:
- docs/workflow/POST_MERGE_CLEANUP.md

## Coordination / collaboration
- docs/coordination/COORDINATION_PROTOCOL.md

## License
MIT (see LICENSE)
