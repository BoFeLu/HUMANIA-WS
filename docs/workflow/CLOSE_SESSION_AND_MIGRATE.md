# Close session and migrate (anti-lag procedure)

## When to use this
Use this procedure at the first signs of:
- UI lag / freezes
- token bloat
- multi-topic drift
- repeated mistakes due to context overload

## Goal
End the current chat safely and restart with full operational continuity.

## Rules
- Do not paste massive outputs.
- Produce short, canonical artifacts.
- Store large evidence as files (attach / link), not in chat.

## Procedure (deterministic)

### Step 1 — Freeze objective
Write one sentence:
- Objective:
- What is blocked:

### Step 2 — Generate artifacts
Create (or update) these files in the repo:
- `docs/templates/STATUS_REPORT.md` (filled as a report instance OR copied into a new report file)
- `docs/templates/CONTEXT_SUMMARY.md` (filled as a summary instance OR copied into a new summary file)

Recommended pattern for instances:
- `docs/status/STATUS_REPORT_YYYYMMDD_HHMM.md`
- `docs/status/CONTEXT_SUMMARY_YYYYMMDD_HHMM.md`

### Step 3 — Evidence handling
- Save long outputs to files under `docs/evidence/` or `logs/` (repo policy dependent).
- In the report, reference:
  - file path
  - command used to generate it
  - a short excerpt

### Step 4 — Commit and push
- Make a small commit with only the new/updated docs.
- Push and open a PR if main is protected.

### Step 5 — Start a new chat
In the first message of the new chat, paste ONLY:
- the latest `CONTEXT_SUMMARY`
- the current objective
- the next step (single action)

## Expected outcome
- Chat stays responsive
- Work remains reproducible
- No context is “trapped” in a slow conversation
