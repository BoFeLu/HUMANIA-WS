# NOTARY SUBSYSTEM

Generated: 2026-03-13
Status: VALIDATED FROM REAL EXECUTION EVIDENCE

## PURPOSE

The NOTARY subsystem certifies the latest verified operational snapshot produced by ULTRAHUMANIA USv1.

It does not infer state.
It derives its output only from:

- C:\HUMANIA\state\ultrscript\last_run.json

## CURRENT EXECUTION CHAIN

Invoke-UltrahumaniaUSv1.ps1
-> generates inventory
-> generates mini report
-> writes state\ultrscript\last_run.json
-> invokes Invoke-UltrahumaniaNotary.ps1
-> generates LA_CLAVE_YYYYMMDDHHMMSS.md
-> updates LA_CLAVE_LATEST.md

## SOURCE OF TRUTH

Primary state source:

- C:\HUMANIA\state\ultrscript\last_run.json

## GENERATED OUTPUTS

Versioned notarial snapshot:

- C:\HUMANIA\docs\notary\LA_CLAVE_YYYYMMDDHHMMSS.md

Canonical latest pointer:

- C:\HUMANIA\docs\notary\LA_CLAVE_LATEST.md

## CURRENT CERTIFIED FIELDS

The current NOTARY output certifies these fields from last_run.json:

- timestamp
- state_ts
- runid
- root
- inventory
- inventory_file_count
- us_mini_report
- us_log
- repo_health_latest
- state source path

## VALIDATION RESULT

Validated in a full real USv1 run.

Evidence confirmed:

- USv1 updates last_run.json
- NOTARY runs inside the same execution chain
- LA_CLAVE_LATEST.md updates correctly
- state_ts matches the exact ts value in last_run.json
- runid matches
- inventory path matches
- inventory_file_count matches
- mini report path matches
- log path matches

## CURRENT LIMITS

The NOTARY subsystem currently certifies the latest USv1 state snapshot only.

It does not currently certify:

- Git status
- service state
- task scheduler state
- hashes of referenced files
- PostgreSQL runtime state

Those items must not be claimed as certified by NOTARY unless explicitly added and validated later.

## OPERATIONAL RULE

If LA_CLAVE_LATEST.md and last_run.json diverge, last_run.json remains the operational source of truth until NOTARY is rerun successfully.

## CURRENT STATUS

NOTARY is:

- implemented
- integrated into USv1
- evidence-based
- validated after defect correction
- ready to remain as canonical notarial snapshot layer
