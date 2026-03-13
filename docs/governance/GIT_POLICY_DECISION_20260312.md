GIT POLICY DECISION
Generated: 2026-03-12 19:40:23

CURRENT FACTS
- pre-commit executes sentinel/sentinel_tick_new.ps1
- several ephemeral runtime files are already tracked
- .gitignore alone does not untrack already indexed files

DECISION
1. Keep canonical architecture and governance documents trackable.
2. Treat runtime state JSON files as ephemeral.
3. Treat old WinSW *.old logs as ephemeral.
4. Treat generated STATUS_REPORT_* and INVENTORY_CANON_* artifacts as generated artifacts, not primary canonical sources.
5. Do not remove anything from the Git index without explicit evidence and a dedicated step.

NEXT STEP
Perform a controlled git rm --cached on approved ephemeral files only.
