# ULTRAHUMANIA — Chat Bootstrap Protocol

## Principle
Never assume system state.  
All conclusions must come from evidence.

---

## Phase 1 — Canonical context

Primary source:

LA_CLAVE_LATEST.md

If missing:

Get-ChildItem C:\HUMANIA\LA_CLAVE*

Purpose:
- global system state
- key paths
- canonical artifacts

---

## Phase 2 — Operational status

Evidence:

cd C:\HUMANIA
Get-UltrahumaniaSecurityHealth.ps1

Confirms:

- watchdog
- guardian
- sentinel
- integrity

---

## Phase 3 — Repository state

Evidence:

git status
git log --oneline -7

Purpose:

- latest commit
- drift detection
- untracked artifacts

---

## Phase 4 — Active subsystem

Identify subsystem currently being worked on.

Example PostgreSQL evidence:

psql -U uh_core -d ultrahumania -c "\dn+"
psql -U uh_core -d ultrahumania -c "\dt *.*"

Example architecture evidence:

SYSTEM_MAP_CANONICAL.md

Example runtime evidence:

RUNS
logs
sentinel state

---

## Phase 5 — Targeted evidence

Request only the minimal information needed.

Example:

\d+ ideas.idea

---

## Expected result

After bootstrap the new chat should know:

- system state
- repository state
- database structure
- runtime condition
- canonical documentation

---

## Operational rules

1. Never assume state
2. Always request evidence
3. Confirm before acting
4. Document every change
5. Close finished work blocks with commits

