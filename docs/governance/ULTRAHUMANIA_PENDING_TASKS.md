ULTRAHUMANIA PENDING TASKS

LAST UPDATED: 2026-03-12

------------------------------------------------------------

CRITICAL TASKS

1. Activate FAIL-SECURE execution gate in sentinel
   sentinel must abort runtime if root_verify fails

2. Harden trust root directory
   C:\ULTRAHUMANIA_TRUST_ROOT
   permissions read-only except signing operations

3. Maintain distributed verification nodes
   Windows
   MiniPC
   Pocophone Termux

------------------------------------------------------------

DOCUMENTATION TASKS

Update these documents to reflect repaired trust chain:

ULTRAHUMANIA_SSoT.md
SYSTEM_MAP_CANONICAL.md
INTEGRITY_PHASE_STATUS_20260311.md

------------------------------------------------------------

INVENTORY TASKS

Run canonical inventory generation

verifiers\emit_canonical_inventory.ps1

------------------------------------------------------------

BASELINE POLICY

When a protected file changes:

1 update hash in root_manifest.json
2 sign manifest
3 verify signature
4 verify on multiple nodes
5 record evidence
