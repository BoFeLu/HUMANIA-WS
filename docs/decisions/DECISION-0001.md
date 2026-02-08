# DECISION-0001 — Governance model (public repo, owner-controlled)

## Status
Accepted

## Context
HUMANIA-WS is a public repository to share a work system (docs, procedures, templates).
We want:
- public visibility
- community feedback (issues/comments)
- owner-controlled changes (only the owner merges to main)

## Decision
- Repo is public, MIT-licensed.
- `main` is protected: changes must go through Pull Requests.
- No direct pushes to `main`.
- Force-push and deletions on `main` are blocked.
- CODEOWNERS is used so the owner is the default reviewer/owner of all paths.
- We do NOT use "Restrict updates" on personal repos because it can deadlock PR merges.

## Consequences
- Contributors can open issues and discuss.
- Only the owner can merge PRs to `main`.
- Workflow remains operable without bypass-user support (personal repo limitation).
