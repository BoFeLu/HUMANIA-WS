UH_GUARD_SPEC_v1
Timestamp: AUTO

OBJETIVO
Garantizar ejecución automática, invisible, redundante y sin errores silenciosos.
Generar artefactos con timestamp.
Ejecutar tests como árbitro final.
Emitir miniinforme por cierre.
Evitar interferencia entre sistemas.
Registrar todo con log y rotación.

ARQUITECTURA DOBLE SISTEMA (NO INTERFERENCIA)

SISTEMA A — RUNNER (Scheduled Task oculto)
Responsabilidad única:
- Generar CONTEXT_SUMMARY
- Generar STATUS_REPORT
- Generar DOCS_CONSTITUTION
- Generar MINI_REPORT
- Ejecutar tests
- Actualizar heartbeat

Configuración obligatoria:
- powershell.exe
- -NoProfile
- -ExecutionPolicy Bypass
- -WindowStyle Hidden
- Run whether user is logged on or not
- Hidden
- Restart on failure: habilitado
- Timeout máximo configurado

SISTEMA B — WATCHDOG (Servicio WinSW)
Responsabilidad única:
- Verificar heartbeat
- Detectar lock colgado
- Relanzar Runner si está detenido o estancado
- Registrar acción en log independiente

AISLAMIENTO ESTRICTO

Logs separados:
C:\HUMANIA\logs\runner\
C:\HUMANIA\logs\watchdog\

Estados separados:
C:\HUMANIA\state\runner\
C:\HUMANIA\state\watchdog\

LOCK GLOBAL OBLIGATORIO

Ruta:
C:\HUMANIA\state\locks\UH_GUARD.lock

Método:
Lock exclusivo mediante FileStream.
TTL obligatorio.
Si lock expira y no hay progreso -> watchdog puede relanzar.

HEARTBEAT

Runner debe actualizar:
- heartbeat.json
- last_success.json
- last_failure.json (si falla)

NO ERRORES SILENCIOSOS

Obligatorio:
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Prohibido:
SilentlyContinue en rutas críticas.

LOG ROTATION

Tamaño máximo por archivo.
Número máximo de archivos retenidos.
Registro de cada rotación.

MINIINFORME POR CIERRE

Debe incluir:
- Timestamp
- Artefactos generados
- Resultado de tests
- Delta
- Orden explícita al operador para nuevo chat
- Exigencia de ACK_INIT obligatorio

TESTS (ÁRBITRO FINAL)

Si cualquier test falla:
- No sellar cierre
- Exit code distinto de 0
- Registrar en last_failure.json
- Registrar en log

Tests mínimos:
- Coherencia entre documentos
- Secciones obligatorias presentes
- No hypotheticals
- Evidence-gated (1 comando)
- No cross-layer

FIN DE ESPECIFICACIÓN
