GIT LARGE OBJECT INCIDENT NOTE
Date: 2026-03-10

INCIDENT
Remote push to GitHub failed due to oversized object:
audit_archive/AUDIT_CHAIN_FIXED.jsonl
191.34 MB

OBSERVED EFFECT
- branch push rejected
- tag push rejected while history still referenced oversized blob

CAUSE
The oversized file was tracked in local unpublished history.

REMEDIATION
1. File removed from current index.
2. File added to .gitignore.
3. Local unpublished history rewritten to remove the path from N2.
4. Branch N2 force-pushed successfully after cleanup.
5. integrity_baseline_20260310 tag pushed successfully.

VALIDATION
- git log N2 -- audit_archive/AUDIT_CHAIN_FIXED.jsonl -> no output
- git rev-list --objects N2 | findstr AUDIT_CHAIN_FIXED.jsonl -> no output
- git ls-files --stage audit_archive/AUDIT_CHAIN_FIXED.jsonl -> no output
- origin/N2 now points to c99211f

LESSON
Large operational archives must not enter normal Git history.
