# STATUS + CONTEXT snapshot (operational procedure)

## Goal
Create two small, canonical artifacts that allow a clean chat migration:
- STATUS_REPORT instance
- CONTEXT_SUMMARY instance

## Naming
Use local time.

- `docs/status/STATUS_REPORT_YYYYMMDD_HHMM.md`
- `docs/status/CONTEXT_SUMMARY_YYYYMMDD_HHMM.md`

## Steps

### Step 1 — Create files
Copy templates and fill them:

- Template: `docs/templates/STATUS_REPORT.md`
- Template: `docs/templates/CONTEXT_SUMMARY.md`

### Step 2 — Evidence discipline
- If output is long: save it into a file under `docs/evidence/`.
- In the report, reference:
  - file path
  - command used to generate it
  - a short excerpt (max ~30 lines total)

### Step 3 — Commit
Commit only the new snapshot files and any referenced evidence files.

### Step 4 — New chat bootstrap
In the new chat, paste ONLY:
- the latest CONTEXT_SUMMARY (full file)
- the current objective (one line)
- the next single action

## Definition of done
A new chat can resume work without asking “where were we?”.
