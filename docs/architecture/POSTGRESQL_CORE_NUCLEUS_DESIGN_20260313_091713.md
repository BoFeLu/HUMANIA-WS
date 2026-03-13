POSTGRESQL CORE NUCLEUS DESIGN

PURPOSE
Define the correct nucleus of the ULTRAHUMANIA PostgreSQL system before new schema creation.

CURRENT CORE DATABASE
ultrahumania

CURRENT CONFIRMED DOMAINS

1. OPERATIONAL
- execution
- norm
- public
- soporte

2. KNOWLEDGE
- kb
- uh_knowledge

3. GOVERNANCE
- leyes
- notary

DESIGN PRINCIPLE
Do not split into new databases yet.
Grow schema-first inside ultrahumania.

NEXT GROWTH DOMAINS
- ideas
- archive
- media
- chats

DESIGN RULES
- operational data must remain separated from knowledge data
- governance data must remain explicit and auditable
- new domains must be additive, not destructive
- no schema creation without prior evidence and table-level design
- no ingestion before schema responsibilities are clearly defined

TARGET NUCLEUS

A. operational_core
Existing:
execution, norm, public, soporte

B. knowledge_core
Existing:
kb, uh_knowledge

C. governance_core
Existing:
leyes, notary

D. expansion_germs
To be designed before creation:
ideas, archive, media, chats

NEXT MANDATORY STEP
Capture live PostgreSQL evidence:
- version
- databases
- schemas
- owners
- key relations

Only after that:
- define tables for ideas, archive, media, chats
- review naming and ownership
- decide if any schema must be merged, renamed or kept separate

END DOCUMENT
