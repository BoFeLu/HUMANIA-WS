ULTRAHUMANIA INTEGRITY + GIT INCIDENT REPORT
Generated: 2026-03-10

SUMMARY
This report documents the integrity hardening work, the git hook/runtime issues, the signed trust-root implementation, and the large-file history incident that blocked remote push.

PART 1 - INITIAL PROBLEMS
1. Git pre-commit hook invoked an ambiguous PowerShell runtime.
2. Sentinel protected INFRA_MAP.md while also regenerating it, causing false positives.
3. Sentinel attempted to write to $env:USERPROFILE\Desktop even under service/systemprofile context.
4. GitHub push failed because repository history contained:
   audit_archive/AUDIT_CHAIN_FIXED.jsonl
   size: 191.34 MB
   exceeding GitHub hard limit.

PART 2 - DIAGNOSIS
1. Hook path ambiguity was confirmed by mismatch between manual execution and git-hook execution.
2. INFRA_MAP.md false positive was confirmed by manifest design conflict.
3. systemprofile Desktop failure was confirmed by service-context execution path:
   C:\Windows\System32\config\systemprofile\Desktop\INFRA_MAP.md
4. Push rejection was confirmed by remote GH001 error and local evidence showing the oversized audit blob in branch history.

PART 3 - CORRECTIONS APPLIED
1. Pre-commit hook changed to deterministic PowerShell 7 path.
2. INFRA_MAP.md removed from integrity manifest.
3. Sentinel write logic hardened to skip non-existent Desktop target directories.
4. External trust root created at:
   C:\ULTRAHUMANIA_TRUST_ROOT
5. root_manifest.json created and signed with Ed25519/OpenSSH signing flow.
6. root_verify.ps1 implemented to validate signed root manifest before sentinel execution.
7. secure_sentinel.ps1 implemented to enforce trust-chain execution.
8. Oversized audit blob removed from tracked HEAD and cleaned from N2 history.
9. Branch N2 force-pushed cleanly to origin after history rewrite.
10. integrity_baseline_20260310 tag pushed successfully.

PART 4 - RESULTING TRUST CHAIN
allowed_signers
-> verifies root_manifest.json.sig
-> root_verify.ps1 validates signed root_manifest.json
-> root_manifest.json protects sentinel_tick_new.ps1
-> secure_sentinel.ps1 executes sentinel only after root validation
-> sentinel_tick_new.ps1 validates internal manifest targets

PART 5 - VALIDATED EVIDENCE
Observed successful outputs:
[ROOT OK] manifest signature valid
[ROOT OK] C:\HUMANIA\sentinel\sentinel_tick_new.ps1
[OK] C:\HUMANIA\BIN\guardian.exe
[OK] C:\HUMANIA\sentinel\sentinel_tick_new.ps1

Observed git state after remediation:
HEAD -> N2 -> c99211f
origin/N2 -> c99211f
tag integrity_baseline_20260310 present on remote

PART 6 - CURRENT LIMITATIONS
1. Trust root remains on same host.
2. Trust logic still depends on PowerShell scripts.
3. Working tree still contains unrelated modified runtime/ops files.
4. Backup/tagging exists, but baseline update procedure should be formalized further.

PART 7 - NEXT RECOMMENDED ACTIONS
1. Formalize baseline update procedure.
2. Define what runtime artifacts must never be versioned.
3. Harden .gitignore for operational noise.
4. Consider external custody of signing material on mini-PC or mobile.
