# DECISION-0002 — Fluency rules (human contract + AI warnings)

## Status
Accepted

## Context
Long technical chats degrade UI responsiveness and increase error rate (copy/paste truncation, token waste, context drift).
We need a stable, documented operational discipline that is independent of any specific chat.

## Decision
- We adopt a Human Efficiency Contract:
  - minimize pasted output
  - single-objective messages
  - short evidence snippets or attached files
  - close sessions early when lag appears
- We authorize the AI to emit automatic operational warnings when the contract is violated.
- Contracts live in `docs/contracts/` and are treated as canonical.

## Consequences
- Higher consistency and fewer failures due to UI lag or oversized messages.
- The operator is explicitly responsible for efficiency; the AI can remind when discipline slips.
- Workflow becomes predictable and transferable between chats and tools.
