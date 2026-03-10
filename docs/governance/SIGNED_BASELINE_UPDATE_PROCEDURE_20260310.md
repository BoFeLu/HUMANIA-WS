ULTRAHUMANIA SIGNED BASELINE UPDATE PROCEDURE
Generated: 2026-03-10

PURPOSE
Define the mandatory procedure for any legitimate change affecting the signed integrity chain.

SCOPE
- C:\ULTRAHUMANIA_TRUST_ROOT\root_manifest.json
- C:\ULTRAHUMANIA_TRUST_ROOT\root_manifest.json.sig
- C:\ULTRAHUMANIA_TRUST_ROOT\root_verify.ps1
- C:\ULTRAHUMANIA_TRUST_ROOT\secure_sentinel.ps1
- C:\HUMANIA\sentinel\sentinel_tick_new.ps1
- C:\HUMANIA\sentinel\manifest.json

MANDATORY STEPS
1. Make only the intended controlled change.
2. Verify resulting behavior manually.
3. Refresh affected hashes.
4. Re-sign root manifest if sentinel baseline changed.
5. Validate root_verify.ps1 returns exit code 0.
6. Validate secure_sentinel.ps1 returns exit code 0.
7. Record evidence outputs.
8. Document rationale and effect.
9. Commit only the repository-side artifacts relevant to the change.
10. Preserve trust-root backup outside the repo.

EVIDENCE GATE
No baseline change is accepted without:
- successful signature verification
- successful root verification
- successful secure sentinel execution
- recorded outputs
- documented reason

PROHIBITIONS
- Do not sign blindly after uncontrolled edits.
- Do not include generated files in integrity manifests.
- Do not rely on ambiguous PATH resolution for trust-chain execution.
- Do not push rewritten history without prior backup/tag.

CURRENT APPROVED ENTRYPOINT
C:\ULTRAHUMANIA_TRUST_ROOT\secure_sentinel.ps1
