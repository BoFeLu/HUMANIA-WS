# POSTGRESQL SYSTEM MAP - CANONICAL DRAFT
ULTRAHUMANIA / HUMANIA
Status: Draft outside repo pending controlled incorporation
Date: 2026-03-17

## 1. PURPOSE

This document consolidates verified evidence about the PostgreSQL environment currently used by the ULTRAHUMANIA system.

Its purpose is to define a canonical descriptive baseline for:
- database topology
- ownership and privileges
- schema distribution
- knowledge-engine structure
- operational implications for AIOPS, governance, notary and future ingestion

This draft is based only on inspected evidence gathered during the current audit sequence.

## 2. VERIFIED DATABASE TOPOLOGY

Detected non-template databases:

- aiops2
- humania_db
- knowledgeops
- normops
- postgres
- ultrahumania
- ultrahumania_knowledge

Observed summary:

- aiops2: 5 schemas, 12 tables, 36 functions
- humania_db: 2 schemas, 1 table, 0 functions
- knowledgeops: 5 schemas, 6 tables, 36 functions
- normops: 5 schemas, 4 tables, 36 functions
- postgres: 1 schema, 0 tables, 0 functions
- ultrahumania: 12 schemas, 36 tables, 7 views, 42 functions
- ultrahumania_knowledge: 1 schema, 3 tables, 0 functions

## 3. DATABASE ROLES AND OWNERSHIP

Operational connection verified:
- role: uh_core
- database: postgres
- host: localhost
- port: 5432

Ownership evidence gathered from visible tables:

- aiops2 -> owner aiops2 -> 12 tables
- knowledgeops -> owner postgres -> 6 tables
- normops -> owner postgres -> 4 tables
- ultrahumania -> owner postgres -> 5 tables
- ultrahumania -> owner uh_core -> 31 tables

Operational implication:
- uh_core is the main operational role for the core system database
- ownership is not uniform across the cluster
- maintenance operations such as ANALYZE are permission-limited under uh_core for objects owned by other roles

## 4. ARCHITECTURAL INTERPRETATION OF THE CLUSTER

The cluster currently shows a hybrid architecture:

1. central semantic / operational nucleus
2. subsystem-specific databases
3. smaller or transitional stores

Working interpretation:

- ultrahumania = primary system database and semantic backbone
- aiops2 = operational AIOPS2 database
- knowledgeops = knowledge-processing subsystem database
- normops = normative / governance subsystem database
- humania_db = small auxiliary or older knowledge store
- ultrahumania_knowledge = small auxiliary or transitional store
- postgres = administrative database

This interpretation is evidence-based but still pending formal adoption as canonical architecture policy.

## 5. ULTRAHUMANIA AS CORE DATABASE

The database ultrahumania is the clear core of the system.

Detected schemas:

- archive
- chats
- execution
- ideas
- kb
- leyes
- media
- norm
- notary
- public
- soporte
- uh_knowledge

Detected object counts:
- 12 schemas
- 36 tables
- 7 views
- 42 functions

This database contains the broadest domain coverage and the only clearly active knowledge dataset identified during the audit.

## 6. TABLE ACTIVITY OBSERVATION

Approximate row activity evidence shows clear real data mainly in:

- ultrahumania.uh_knowledge.incident_event ~ 7562 rows
- ultrahumania.uh_knowledge.knowledge_item ~ 22 rows
- ultrahumania.uh_knowledge.incident_signature ~ 16 rows

Many other tables appear with reltuples = -1, which means the current evidence is insufficient to claim real population without updated statistics or direct counting.

Operational conclusion:
- the only clearly active and evidenced knowledge nucleus is ultrahumania.uh_knowledge

## 7. KNOWLEDGE ENGINE SCHEMA

The schema ultrahumania.uh_knowledge contains five core tables:

- evidence
- incident_event
- incident_family
- incident_signature
- knowledge_item

Detected total columns: 48

### 7.1 Table: incident_event

Observed columns:
- id
- raw_log_line
- runid
- signature_id
- ts_utc

Interpretation:
- raw incident/event ingestion
- event-level operational observations
- link to signature-level classification

### 7.2 Table: incident_signature

Observed columns:
- created_at
- family_id
- first_seen
- id
- kind
- last_seen
- occurrences
- severity
- signature_text

Interpretation:
- repeated pattern detection layer
- frequency and severity tracking
- bridge between raw events and family-level semantics

### 7.3 Table: incident_family

Observed columns:
- confidence
- created_at
- description
- family_key
- id
- severity
- status
- title
- updated_at

Interpretation:
- semantic grouping of recurring incident signatures
- classification layer for operational patterns

### 7.4 Table: knowledge_item

Observed columns:
- component
- confidence
- created_at
- file_path
- id
- kind
- rationale
- runid
- scope
- severity
- statement
- status
- title
- toolchain
- trigger
- updated_at

Interpretation:
- structured and operationalizable knowledge artifact
- supports manually reasoned or system-derived knowledge

### 7.5 Table: evidence

Observed columns:
- created_at
- excerpt
- id
- knowledge_id
- runid
- source_kind
- source_path
- trigger
- ts_utc

Interpretation:
- traceability layer
- connects knowledge items to verifiable evidence

## 8. KNOWLEDGE ENGINE RELATIONSHIPS

Verified primary keys:
- evidence.id
- incident_event.id
- incident_family.id
- incident_signature.id
- knowledge_item.id

Verified foreign keys:
- evidence.knowledge_id -> knowledge_item.id
- incident_event.signature_id -> incident_signature.id
- incident_signature.family_id -> incident_family.id

Model interpretation:

incident_event
  -> incident_signature
  -> incident_family

knowledge_item
  -> evidence

This yields two coordinated domains:
- observation domain
- formalized knowledge domain

Operationally, the global pattern is:

runtime observation
-> event
-> signature
-> family
-> formalized knowledge
-> evidence trail

## 9. SUBSYSTEM DATABASES

### 9.1 aiops2

Schemas:
- chat
- core
- evidence
- exec
- public

Observed structure:
- 12 tables
- 36 functions
- all visible tables owned by aiops2

Interpretation:
- isolated subsystem database for AIOPS2
- likely agent runtime / automation backend

### 9.2 knowledgeops

Schemas:
- audit
- core
- meta
- public
- vec

Observed structure:
- 6 tables
- 36 functions
- visible tables owned by postgres

Interpretation:
- knowledge processing subsystem
- vec suggests vector or embedding-oriented design
- ownership/governance not yet aligned with uh_core pattern

### 9.3 normops

Schemas:
- audit
- core
- meta
- public
- versioning

Observed structure:
- 4 tables
- 36 functions
- visible tables owned by postgres

Interpretation:
- normative / governance subsystem
- includes versioning layer
- ownership/governance also not yet aligned with uh_core pattern

### 9.4 humania_db

Schemas:
- kb
- public

Observed structure:
- 1 table
- 0 functions

Interpretation:
- very small database
- likely legacy, auxiliary or transitional

### 9.5 ultrahumania_knowledge

Schemas:
- public

Observed structure:
- 3 tables
- 0 functions

Interpretation:
- small auxiliary or transitional knowledge store
- relationship to ultrahumania.uh_knowledge must be clarified later

## 10. PERMISSION FINDINGS

Attempted ANALYZE under uh_core produced repeated permission warnings on objects not owned by uh_core.

This is consistent with the ownership map and indicates:

- uh_core is not universal maintenance owner
- cluster governance is multi-owner
- future automated maintenance, ingestion or reconciliation must respect owner boundaries

This is not a runtime failure but a governance fact that must be documented.

## 11. OPERATIONAL CONCLUSIONS

Based on current evidence:

- ultrahumania is the primary database nucleus
- ultrahumania.uh_knowledge is the only clearly evidenced active knowledge core
- aiops2 is structurally isolated and likely intended as dedicated subsystem backend
- knowledgeops and normops are structurally meaningful but not yet fully documented canonically
- ownership and privileges are not unified across the cluster
- the cluster already supports a real AIOps-style learning pipeline from events to knowledge

## 12. DOCUMENTATION GAP IDENTIFIED

Before connecting:
- AIOPS1
- AIOPS2
- notary
- orchestrator
- local LM
- automatic ingestion

the project needs canonical PostgreSQL documentation covering:

- database purpose per database
- schema purpose per schema
- owner and maintenance model
- active vs transitional databases
- role of ultrahumania_knowledge and humania_db
- relation of knowledgeops and normops to ultrahumania
- version/install topology of PostgreSQL in the host environment

## 13. REMAINING OPEN ITEMS

The following items remain insufficiently documented and should be captured in a later controlled extension:

1. exact PostgreSQL installation/version topology on host
2. service names, binaries and data directories
3. extension inventory
4. enum/domain definitions for USER-DEFINED column types
5. index inventory for uh_knowledge
6. exact role privileges beyond visible ownership
7. explicit architectural decision on whether the cluster is permanently hybrid or will be consolidated

## 14. CURRENT CANONICAL WORKING INTERPRETATION

Until superseded by a formally adopted architecture decision, the safest working interpretation is:

- ultrahumania = core semantic and operational database
- uh_core = core operational role
- aiops2 = dedicated agent database
- knowledgeops = knowledge-processing subsystem database
- normops = normative subsystem database
- humania_db and ultrahumania_knowledge = small auxiliary/transitional stores
- postgres-owned objects require explicit governance review before maintenance automation

## 15. RECOMMENDED NEXT RUNBOOK STEP

The next prudent step is not large-scale implementation.

The next prudent step is to complete host-level PostgreSQL topology evidence:
- installed versions
- binaries
- services
- data directories
- active instance mapping

Only after that should this draft be promoted into repo-controlled canonical documentation.

## 16. POSTGRESQL INSTALLATION ARCHITECTURE

Additional host-level inspection produced the following verified findings:

### 16.1 Installed program directories

Detected under C:\Program Files\PostgreSQL:

- 16
- 17

This confirms the host contains at least two PostgreSQL program installations.

### 16.2 Active client binary currently reached by PATH

The psql executable currently resolved by command discovery is:

- C:\Program Files\PostgreSQL\16\bin\psql.exe

Observed file/product version:

- FileVersion: 16.12
- ProductVersion: 16.12

Operational implication:
- the operator shell currently resolves PostgreSQL client tooling from installation 16 unless an explicit path is used.

### 16.3 Active server version reached on localhost:5432

Verified with:
- psql -U uh_core -d postgres -c "select version();"

Observed result:
- PostgreSQL 17.6 on x86_64-windows, 64-bit

Operational implication:
- the current active server instance is PostgreSQL 17.6
- the active psql client and the active PostgreSQL server are not from the same major installation tree

### 16.4 Client/server split condition

Current verified topology:

- client binary in PATH: PostgreSQL 16.12
- active connected server: PostgreSQL 17.6
- connection target: localhost:5432

This is an important architectural fact and must remain documented because it may affect:
- operator expectations
- binary selection for maintenance tasks
- script reproducibility
- future upgrade and migration reasoning

### 16.5 Privilege boundary of uh_core

The role uh_core can connect and query ordinary metadata, but cannot inspect protected settings such as:
- data_directory

Observed server response indicates that reading such parameters requires a role with privileges equivalent to:
- pg_read_all_settings

Operational implication:
- uh_core is a valid operational role
- uh_core is not a full administrative introspection role

### 16.6 Documentation consequence

The PostgreSQL architecture must now be treated as having:
- multi-installation host footprint
- client/server version split
- privilege-separated operational access

Any future maintenance runbook must distinguish clearly between:
- server instance actually running
- client binary actually being invoked
- role used for ordinary operations
- role required for administrative inspection
