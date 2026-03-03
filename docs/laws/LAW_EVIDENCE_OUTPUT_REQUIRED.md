# LAW N3: Evidence Output Required (Operator + IA)

Status: ACTIVE / PERMANENT  
Authority: HIGH  
Scope: All operational changes and closures (HUMANIA / TRANSHUMANIA)

## 1) Principle
No operation is considered completed, accepted, or “closed” unless there is:
1) A primary verification output (or equivalent evidence) produced by the system, AND
2) That output is saved to disk under C:\HUMANIA\logs\ (or a subfolder), AND
3) The operator pastes the primary output summary into the chat/session record.

Rationale: if IA is wrong and the human does not question it -> failure.
If IA is correct but the human is wrong -> failure.
If both are correct and evidence is recorded -> resilient, auditable, traceable.

## 2) What counts as “Important Operation”
Any action that changes at least one of:
- Kernel artifacts (humania_run.ps1, humania_guard.ps1, audit_verify.ps1, kernel_manifest.json)
- Security controls (ACLs, scheduled tasks, policies, guards)
- Canonical documentation structure / governance / laws / procedures
- Backup/restore mechanisms and paths
- Integrity verifiers or evidence emitters

## 3) Minimum Evidence Set (Primary)
For each important operation, the minimum acceptable evidence is:
- The primary verifier output (e.g., self_integrity_level1.ps1 result lines)
- Exit code (explicit)
- Saved path to evidence bundle (directory or file)

Example (minimum pasted):
[OK]/[FAIL] lines + exitcode + Saved => C:\HUMANIA\logs\...

## 4) Storage Rule
Evidence must be written to disk (deterministically), using:
- C:\HUMANIA\logs\...
- Prefer a timestamped folder under logs\evidence\...

## 5) Fail-Closed
If evidence is missing, unclear, or not saved: treat as FAIL and do not proceed to the next phase.

## 6) Format Recommendation (Operator Paste)
Always paste at least:
- The primary output lines
- exitcode=...
- Saved => <path>
