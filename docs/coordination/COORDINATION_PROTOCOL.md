# HUMANIA Coordination Protocol (HCP)
## A Verified Multiâ€‘Node Humanâ€“LLM Communication Framework

---

### What this is

**HUMANIA Coordination Protocol (HCP)** is a practical, evidenceâ€‘driven framework for **coordinated work between a human and multiple intelligent systems** (LLMs, terminals, services, and tools).

It formalizes a **multiâ€‘node communication method** where:
- a **human remains the control authority**,
- one or more **LLMs act as reasoning and planning nodes**,
- one or more **execution environments** (terminal, OS, services, infra) act as stateful system nodes,
- all interaction is **paced, verifiable, reproducible, and resilient**.

This is not prompt engineering.
This is not autonomous agents.
This is **coordination engineering**.

---

### Why this exists

Modern LLM usage breaks down when:
- context grows large,
- systems become stateful,
- commands are copied manually,
- results are paraphrased instead of evidenced,
- chats drift without checkpoints.

HCP exists to solve **that exact failure mode**.

---

### Core principles

1. **Humanâ€‘inâ€‘Control**
   - The human sets direction, rhythm, and stopping points.
   - LLMs never execute; they propose.

2. **Explicit Nodes**
   - Human
   - LLM(s) (ChatGPT, Cursor, others)
   - Terminal / OS
   - Running systems (services, containers, infra)

3. **Evidence First**
   - All claims must be backed by terminal output or artifacts.
   - Memory and interpretation are never substitutes for evidence.

4. **Deterministic Exchange**
   - No freeâ€‘form copy/paste.
   - All artifacts move through defined exchange boundaries.

5. **Small, Verified Steps**
   - Each step is validated before the next.
   - No speculative chains of actions.

---

### Canonical communication loop

1. **LLM proposes**
   - Small, explicit blocks of commands or checks.
   - Clear acceptance criteria.

2. **Human executes**
   - In a clean terminal.
   - Without modifying proposed commands.

3. **System responds**
   - Raw output is produced.

4. **Human captures evidence**
   - Entire terminal output.
   - No summarization.

5. **Evidence returned to LLM**
   - LLM reasons only on verified state.

This loop can involve **multiple LLMs and tools simultaneously**.
The protocol scales linearly with complexity.

---

### Multiâ€‘node capability

HCP is designed for **more than two nodes**:

- Human
- Chatâ€‘based LLM
- IDEâ€‘embedded LLM (e.g. Cursor)
- Terminal / OS
- Observability stack
- External tools

All nodes communicate **through the human**, using strict procedures.
There is no hidden state sharing.

---

### Key procedures (nonâ€‘exhaustive)

- Shared Folder (ShF) as exchange boundary
- Fast execution/feedback terminal loop
- Noâ€‘`exit` rule for interactive shells
- Message block limits per LLM response
- Phaseâ€‘based validation and gating

These procedures are documented in `/procedures`.

---

### What HCP enables

- Longâ€‘running projects without context collapse
- Safe execution on live systems
- Real verification of LLM reasoning
- Collaboration across multiple AIs
- Transition from experimentation to engineering

---

### What HCP explicitly avoids

- Autonomous decision making
- Unverified recommendations
- Blind trust in AI output
- Monolithic prompts
- Opaque agent frameworks

---

### Status

**Preliminary / v0**
Actively developed and validated in a real AIOps system.

This repository documents the **method**, not a product.

---

### License

Licensed under the MIT License. See the LICENSE file for details.

