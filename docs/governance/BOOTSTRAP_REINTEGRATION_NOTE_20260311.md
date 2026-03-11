BOOTSTRAP REINTEGRATION NOTE
BASELINE_TS: 20260311

Situation:
The historical bootstrap subsystem is currently externalized outside C:\HUMANIA.

External active location:
C:\Users\Alber2Pruebas\Desktop\INFORMES UH

Observed evidence:
- UH_BOOTSTRAP_INDEX.md exists there
- multiple UH_CHAT_BOOTSTRAP_*.md files exist there
- no bootstrap generator script currently exists inside C:\HUMANIA except the newly recreated HANDOFF stub

Temporary resolution:
- C:\HUMANIA\HANDOFF\UH_BOOTSTRAP_INDEX.md recreated as local reference
- C:\HUMANIA\HANDOFF\UH_BOOTSTRAP_CONTEXT.ps1 recreated as safe stub
- bootstrap remains operationally external until a full reintegration or redesign is implemented

Rule:
Do not assume that HANDOFF currently generates bootstrap files.
The stub only locates and reports the current external bootstrap source.
