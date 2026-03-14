# REPOSITORY ARTIFACT POLICY

Generated: 2026-03-13
Status: ACTIVE WORKING POLICY

## PURPOSE

Control repository growth and prevent generated runtime artifacts from overwhelming Git history.

## RULES

1. Canonical pointers and current state files may be versioned.
2. Historical timestamped runtime artifacts must not be committed by default.
3. Large or repetitive generated artifacts must remain outside normal commits unless explicitly justified by evidence.
4. Runtime truth must remain reconstructible from:
   - latest pointers
   - current state files
   - operational scripts
   - canonical documentation

## VERSION BY DEFAULT

- ULTRAHUMANIA_SSoT.md
- docs/notary/LA_CLAVE_LATEST.md
- docs/notary/NOTARY_SUBSYSTEM_LATEST.md
- docs/status/ULTRASCRIPT_MINI_REPORT_LATEST.md
- docs/status/REPO_HEALTH_MINI_REPORT_LATEST.md
- docs/context/ULTRASCRIPT_INVENTORY_LATEST.json
- state/ultrscript/last_run.json
- operational scripts under tools/

## DO NOT VERSION BY DEFAULT

- docs/notary/LA_CLAVE_YYYYMMDDHHMMSS.md
- docs/status/ULTRASCRIPT_MINI_REPORT_YYYYMMDD_HHMMSS.md
- docs/status/REPO_HEALTH_MINI_REPORT_YYYYMMDD_HHMMSS.md
- docs/context/ULTRASCRIPT_INVENTORY_YYYYMMDD_HHMMSS.json
- archive/status/*
- backup files
- ad hoc copies
- experimental duplicates

## EXCEPTION RULE

A historical generated artifact may be committed only when:
- it is required as evidence for an incident, milestone, audit, or design decision
- and the reason is stated explicitly in the commit or companion document

## OPERATIONAL INTENT

Canonical latest files represent the current system state.
Historical generated files remain available locally but should not pollute routine commits.
