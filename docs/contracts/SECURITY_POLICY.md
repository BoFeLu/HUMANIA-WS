# Security Policy (Canonical)

## Principle 0 — Security First (Non-negotiable)
Security is the primary constraint of HUMANIA WS.
Convenience and speed are always secondary.

## Public vs Private documentation

### Public (repo)
Public documentation MUST:
- avoid real filesystem paths
- avoid real usernames
- avoid hostnames/IPs
- avoid tokens, API keys, secrets, cookies
- avoid machine fingerprints that can help targeting
- use placeholders and variables (e.g., `$PROJECT_ROOT`, `$HOST_STAGING_DIR`)

### Private (local operator)
Private operational notes MAY contain real paths and environment specifics,
but MUST NOT be committed or published.

Recommended:
- keep private mappings under a local folder outside the repo
- or in a file explicitly excluded by `.gitignore`

## Redaction rules (mandatory)
Before publishing any excerpt or document:
- remove / replace:
  - `C:\Users\<name>\...` → `C:\Users\<USER>\...` or `$HOST_STAGING_DIR`
  - `/home/<user>/...` → `$PROJECT_ROOT`
  - `/mnt/c/Users/<name>/...` → `$WSL_HOST_MOUNT`
  - IPs/hosts → `$HOST_IP`, `$HOSTNAME`
  - tokens/keys → `[REDACTED]`

## Evidence handling
- Prefer short excerpts.
- Store long evidence as files.
- Treat logs as potentially sensitive.
- Never publish secrets even in “examples”.

## Bundle handling (security requirement)
Before uploading or sharing a bundle:
- list its contents
- scan for sensitive filenames/patterns
- stop if anything sensitive is present

This policy is binding.
Violation is a workflow error.
