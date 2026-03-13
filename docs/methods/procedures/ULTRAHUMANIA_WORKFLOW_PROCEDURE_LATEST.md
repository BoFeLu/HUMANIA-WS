ULTRAHUMANIA WORKFLOW PROCEDURE

TITLE
Evidence-Gated Development Workflow with ECS

PURPOSE
Establish the mandatory working procedure for evolving ULTRAHUMANIA with safety,
rigor, control, traceability, reality alignment and governed growth.

SCOPE
This procedure is binding for both:
- the AI assistant
- the human operator

CORE PRINCIPLE
Do not advance by haste, accumulation of uncontrolled changes, or "it seems fine".

Every relevant change must follow this sequence:

1. ANALYSIS
- Understand the current real state
- Identify the actual problem
- Identify affected files, systems, risks and dependencies
- Collect evidence before deciding

2. DESIGN
- Define the intended change before building
- Prefer bounded, simple, reversible designs
- Avoid improvisation on critical files
- Define expected result and verification criteria

3. CONSTRUCTION
- Apply the smallest controlled change possible
- Prefer deterministic procedures
- Prefer explicit full blocks when safer than fragile patching
- Group changes by purpose, not by convenience

4. TEST
- Execute direct verification
- Confirm expected behavior
- Confirm that no critical subsystem is broken
- Require observable output and evidence

5. ANALYSIS OF RESULTS
- Compare actual result versus expected design
- Detect mismatches, regressions, drift, friction or hidden side effects
- Do not assume success without evidence

6. CORRECTIONS
- Fix only the demonstrated issue
- Do not widen scope without justification
- Preserve perimeter control
- Prefer solutions that improve the system instead of merely hiding the symptom

7. TESTS UNTIL ECS
Do not stop at "it works" or "no visible error".

Repeat correction and testing until ECS is achieved:

E = EFFICIENCY
- The solution is not unnecessarily heavy, slow, repetitive or wasteful

C = CORRECTION
- The solution actually solves the intended problem
- The result matches the design and evidence

S = SOLIDITY
- The solution is secure
- The solution is stable
- The solution does not introduce fragile behavior or unacceptable risk

Higher-quality target, when reasonably achievable:
- elegance
- clarity
- scalability
- maintainability
- architectural coherence

8. GIT UPDATE
Only after a change has evidence and ECS:
- classify the change correctly
- stage by coherent groups
- avoid mixing runtime, docs, tools and experiments without need
- keep repository state understandable and auditable

9. DOCUMENTATION
After Git classification and/or commit preparation:
- document what changed
- document why it changed
- document verification evidence
- align canonical docs with actual reality
- do not leave documentation behind the system state

MANDATORY GATES
A phase is not complete unless it leaves verifiable evidence.
Do not move to the next phase without minimum closure evidence of the current one.

MANDATORY RULES
- evidence before decisions
- no blind execution
- no uncontrolled growth
- no undocumented critical change
- no assumption of success without verification
- no divergence between documentation and real system state
- security and stability take priority over speed

RATIONALE
When analysis, careful design, testing, organization, Git discipline and aligned
documentation are missing, the system degrades, drift increases, and risk grows.

EXPECTED EFFECT
This workflow is intended to make ULTRAHUMANIA grow with control:
analysis
design
construction
test
analysis
corrections
tests until ECS
Git update
documentation aligned with reality

END DOCUMENT
