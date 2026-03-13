ULTRAHUMANIA PROCEDURE
System Bootstrap Using LA_CLAVE

PURPOSE

Provide deterministic reconstruction of system context at session start.

BOOTSTRAP ARTIFACT

LA_CLAVE_LATEST.md

LOCATION

C:\HUMANIA\LA_CLAVE_LATEST.md

SECONDARY COPY

Desktop\LA_CLAVE_LATEST.md

PROCESS

1. Verify existence of LA_CLAVE_LATEST.md
2. Verify timestamped LA_CLAVE file
3. Confirm hash equality
4. Read LA_CLAVE to reconstruct context
5. Continue runbook from canonical state

VERIFICATION COMMANDS

Test-Path C:\HUMANIA\LA_CLAVE_LATEST.md

Get-ChildItem C:\HUMANIA\LA_CLAVE_*.md

Get-FileHash C:\HUMANIA\LA_CLAVE_LATEST.md

EXPECTED RESULT

Context reconstruction without manual intervention.

SECURITY RULE

LA_CLAVE generation must occur through:

tools\Invoke-UltrahumaniaDefinitiveContext.ps1

END PROCEDURE
