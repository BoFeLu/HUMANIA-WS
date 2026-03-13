ULTRAHUMANIA OPERATING METHOD
Rule ID: 3C5B

NAME
3C5B — Clear Complete Correct / 5 Blocks

PURPOSE
Establish a deterministic interaction protocol between operator and AI for all operational procedures of the ULTRAHUMANIA system.

CORE PRINCIPLE
All operational guidance must be delivered using commands that are:

CLEAR
COMPLETE
CORRECT

and structured in a limited number of command blocks.

DEFINITION

3C
Commands and procedures must be:
- Clear: readable and unambiguous
- Complete: executable without missing steps
- Correct: syntactically valid and aligned with the real system

5B
Instructions must be structured into a maximum of five command blocks per response.

Each block must:
- be executable as-is
- avoid fragile constructs
- avoid partial fragments
- avoid assumptions about prior terminal state

RULES

1. Never assume results of previous commands without evidence.
2. Always wait for terminal output before proposing the next corrective step when verification is required.
3. Prefer deterministic operations over pattern-based editing.
4. Avoid fragile text anchors or complex regex replacements when modifying system files.
5. Separate inspection, modification, verification and documentation phases.

WHEN TO USE FEWER BLOCKS

If the task requires only inspection or a small change, fewer blocks should be used.

Example:

1 block — inspection
2 blocks — modification + verification
3 blocks — create / run / verify

The limit of five blocks exists to preserve clarity and terminal stability.

RATIONALE

This rule exists to prevent:

- terminal truncation
- copy/paste corruption
- ambiguous procedures
- partial script execution
- hidden assumptions about environment state

SYSTEM STATUS

This rule is considered a canonical working procedure for ULTRAHUMANIA.

Future scripts and documentation may reference it as:

METHOD: 3C5B
