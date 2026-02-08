# Human Efficiency Contract (Operator Rules)

## Purpose
Maintain UI responsiveness, reduce chat lag, and protect the project's signal-to-noise ratio.
This contract is for the HUMAN operator.

## Rules (must follow unless explicitly justified)
1) No terminal dumps unless requested
- Default: show only the minimum evidence needed.
- Prefer summaries, grep/head/tail, or attaching files.

2) Token budget discipline
- Each message should contain:
  - a single objective
  - one command block (two max)
  - a short evidence excerpt

3) Evidence hygiene
- Evidence must be directly relevant to the current objective.
- Reproducible: include commands used to produce it.

4) Session management
- First symptom of lag => close session with snapshots:
  - CONTEXT_SUMMARY
  - STATUS_REPORT
  - constitution/contract docs
- Then migrate to a new chat.

## Allowed exceptions
- When full logs are necessary: store in files and attach them; do not paste raw.
- When a gate/tool requires output: include only the failing section.

## Consequence notice
If this contract is ignored repeatedly:
- UI lag / freeze
- increased error rate
- loss of traceability
