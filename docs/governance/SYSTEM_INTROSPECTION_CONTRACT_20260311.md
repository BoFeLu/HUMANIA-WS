# SYSTEM INTROSPECTION CONTRACT - 2026-03-11

## Purpose

This document defines the minimum operational contract for the first implementation stage of the ULTRAHUMANIA system introspection layer.

## Canonical subsystem name

ULTRAHUMANIA_SYSTEM_INSPECTOR

## Implementation posture

First-stage implementation must be:

- read-only
- deterministic
- evidence-oriented
- reviewable
- non-remediating by default

## Exact input classes

The first-stage inspector may consume only these input classes:

1. Repository structure signals
   - presence of key directories
   - presence of canonical files
   - presence of expected governance documents

2. Trust-root visibility signals
   - existence of trust-root path
   - existence of key trust files
   - non-invasive file presence checks only

3. Bootstrap bridge signals
   - presence of tracked HANDOFF entrypoints
   - visibility of expected external workspace path references

4. Selected state/log/runtime indicators
   - existence of selected state files
   - existence of selected logs
   - last-known generated artifacts
   - no mutation, no cleanup, no rotation

5. Documentation coherence signals
   - existence of current canonical governance references
   - minimal consistency checks between overview/index/reference files

## Exact output families for stage 1

The inspector may generate only reporting outputs from these families:

- SYSTEM_HEALTH_REPORT
- SYSTEM_STRUCTURE_SNAPSHOT
- TRUST_ROOT_STATUS
- BOOTSTRAP_STATUS
- DOC_SYNC_STATUS
- CRITICAL_PATH_STATUS

## Stage-1 output rule

All outputs must be descriptive and evidence-oriented.
Outputs must not perform hidden repair, hidden correction, or hidden state modification.

## Trigger model

The trigger model is not yet fixed for production.
At this stage the subsystem is defined for:

- manual execution first
- periodic execution later, only after validation

## Operational mode

Stage 1 is:

- reporting-oriented
- recommendation-light
- non-remediating

This means:
- it may report findings
- it may classify findings
- it may suggest next checks
- it must not apply changes automatically

## Explicit prohibitions

The subsystem must not:

- change trust-root contents
- rewrite runtime-protected files
- modify Git state
- auto-heal by default
- rotate or purge artifacts silently
- produce conclusions without evidence anchors

## Relationship with other subsystems

The inspector is not a replacement for:

- runner
- watchdog
- sentinel
- trust-root verification
- governance review
- PostgreSQL/notarial evidence storage

It is a reporting and introspection layer that complements them.

## Stage-1 design closure

The first implementation stage is therefore defined as:

read-only + deterministic + reporting-oriented + evidence-first + manually executable
