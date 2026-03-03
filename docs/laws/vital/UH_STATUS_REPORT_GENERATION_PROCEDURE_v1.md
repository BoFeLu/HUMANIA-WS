UH_STATUS_REPORT_GENERATION_PROCEDURE_v1
Timestamp: AUTO

OBJETIVO

Formalizar el mecanismo obligatorio para generar:
- CONTEXT_SUMMARY
- STATUS_REPORT
- DOCS_CONSTITUTION
- MINI_REPORT

Cada vez que un chat:
- se ralentiza,
- alcanza un hito importante,
- o requiere cierre LEVEL_N.

PRINCIPIO ESTRUCTURAL

La generación de STATUS_REPORT no es manual.
Se realiza exclusivamente mediante ejecución del Runner oficial:

C:\HUMANIA\guard\UH_GUARD_RUN.ps1

COMANDO ÚNICO AUTORIZADO (SIEMPRE EL MISMO)

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\HUMANIA\guard\UH_GUARD_RUN.ps1"

REGLAS OBLIGATORIAS

1) El asistente debe proporcionar este comando al operador cuando detecte:
   - ralentización del chat
   - cierre LEVEL_N
   - consolidación importante

2) El operador ejecutará el comando.
3) El Runner generará automáticamente:
   - STATUS_REPORT con timestamp
   - CONTEXT_SUMMARY con timestamp
   - DOCS_CONSTITUTION con timestamp
   - MINI_REPORT con timestamp

4) El asistente NO debe generar manualmente estos archivos fuera del Runner.

5) El MINI_REPORT es obligatorio y debe incluir:
   - artefactos generados
   - resumen de delta
   - estado de tests
   - orden explícita de abrir nuevo chat
   - exigencia de ACK_INIT

6) Prohibido:
   - generar STATUS_REPORT manual
   - cerrar chat sin pasar por Runner
   - omitir MINI_REPORT

FLUJO OFICIAL DE CIERRE

1) El asistente detecta cierre necesario.
2) Proporciona el comando oficial.
3) El operador ejecuta.
4) Se verifican:
   - last_success.json
   - MINI_REPORT generado
5) Se abre nuevo chat con snapshot LEVEL_N.

INVENTARIO CANÓNICO (OBLIGATORIO)

Desde versión 4.0.0-GOLD:

El Runner genera adicionalmente:
- INVENTORY_CANON_{timestamp}.json

Ubicación:
C:\HUMANIA\docs\context\

Reglas:

1) El inventario se genera automáticamente mediante:
   C:\HUMANIA\verifiers\emit_canonical_inventory.ps1

2) El directorio:
   C:\HUMANIA\state\locks
   queda excluido explícitamente del inventario
   (lock activo durante ejecución del Runner).

3) El inventario es validado por:
   Integrity-Check-ArtifactConsistency

4) MINI_REPORT debe incluir la ruta del INVENTORY_CANON generado.

5) El inventario pasa a formar parte de los artefactos obligatorios del cierre LEVEL_N.

FIN DEL PROCEDIMIENTO
