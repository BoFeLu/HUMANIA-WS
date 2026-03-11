# HANDOFF BOOTSTRAP CANONICAL MODEL - 2026-03-11

## Purpose

This document defines the canonical relationship between the repository, the trust root, the external reporting workspace, and the bootstrap bridge entrypoints.

## Canonical layer model

### 1. Core system
Path: `C:\HUMANIA`

Purpose:
- versioned operational core
- runtime scripts
- governance documents
- canonical maps
- tracked bootstrap bridge entrypoints

### 2. Trust root
Path: `C:\ULTRAHUMANIA_TRUST_ROOT`

Purpose:
- integrity root
- signed trust material
- allowed signers
- validation chain

### 3. External analytical workspace
Path: `C:\Users\Alber2Pruebas\Desktop\INFORMES UH`

Purpose:
- reports
- generated bootstrap files
- inspection outputs
- operational analysis artifacts

This workspace is external to the repository core.

## HANDOFF role inside repository

Repository path: `C:\HUMANIA\HANDOFF`

HANDOFF is not the analytical workspace itself.
HANDOFF is the minimal bridge between the tracked repository and the external workspace.

## Tracked official entrypoints

The following files are official tracked bridge entrypoints:

- `HANDOFF/UH_BOOTSTRAP_CONTEXT.ps1`
- `HANDOFF/UH_BOOTSTRAP_INDEX.md`

These files exist to reconnect the repository with the external bootstrap/reporting location.

## Ignored content policy

HANDOFF remains primarily an ignored workspace-facing area.
Temporary or generated inspection artifacts inside HANDOFF are not part of the canonical tracked repository state.

Examples:
- DOC_SYNC artifacts
- generated inspection outputs
- temporary trees
- transient analysis files

## Architectural rule

The repository must track the bridge entrypoints, but must not absorb the external analytical workspace itself.

## Status on 2026-03-11

Canonical bootstrap bridge reintegration is completed when:
- the stub works locally
- the tracked entrypoints are versioned in Git
- HANDOFF temporary artifacts remain ignored
- the external workspace remains outside the core repository
