# Post-merge cleanup (canonical order)

## Purpose
Avoid ambiguity, warnings, and accidental data loss when cleaning up branches after a Pull Request merge.

This procedure is **mandatory** for HUMANIA WS.
All tooling and AI-provided instructions must follow this order.

## Golden rule
**Never delete branches before synchronizing `main` locally.**

## Canonical order (DO NOT REORDER)

### Step 1 — Merge on GitHub
- Use **Squash and merge** (recommended).
- Do NOT delete the branch yet (optional but safer).

### Step 2 — Synchronize local main (FIRST local action)
```bash
git checkout main
git pull origin main
git status -sb
