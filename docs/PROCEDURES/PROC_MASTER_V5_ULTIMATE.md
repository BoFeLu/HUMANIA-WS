# HUMANIA: PROC_MASTER_V4_ULTIMATE
**Estado:** CANÓNICO / DETERMINISTA / V4.0

## Índice
1. [Principios Fundamentales](#1-principios-fundamentales)
2. [Rotación de Auditoría (AUDIT-CHAIN)](#2-rotación-de-auditoría-audit-chain)
3. [Escritura y Despliegue de Documentos (DEPLOY-SAFETY)](#3-escritura-y-despliegue-de-documentos-deploy-safety)
4. [Transferencia Determinista de Archivos (I/O)](#4-transferencia-determinista-de-archivos-io)
5. [Procedimiento de Congelación (FREEZE PROCEDURE)](#5-procedimiento-de-congelación-freeze-procedure)
6. [Protocolo de Handover (Contractual)](#6-protocolo-de-handover-contractual)
7. [Contrato del Operador LLM (LLM_OPERATOR_CONTRACT)](#7-contrato-del-operador-llm-llm_operator_contract)
8. [Prohibiciones Generales Consolidadas](#8-prohibiciones-generales-consolidadas)

---

## 1. Principios Fundamentales

- **Evidencia primero**: Ninguna acción se asume. El primer paso siempre es descubrir capacidades (leer allowlists) o ejecutar una acción explícitamente permitida.
- **Entrega determinista (LAW-IO-002)**: Todo contenido debe entregarse como heredoc literal, listo para escribir. UTF-8 obligatorio.
- **Gobernanza estricta**: No se permiten ediciones directas a archivos canónicos. Los cambios estructurales requieren el flujo: `Propose` → `Review (Diff)` → `Apply` → `Verify` → `Audit`.
- **Atomicidad y verificación**: Cada paso debe ser corto, verificable y producir evidencia (hashes, logs) o detenerse.
- **Fail-closed**: Ante cualquier fallo de verificación, el proceso se detiene.

---

## 2. Rotación de Auditoría (AUDIT-CHAIN)

- **Condición de activación**: Rotar si el archivo supera los **200 MB** o tras **30 días**.
- **Método oficial**:
  1. Tomar un snapshot del log actual: tamaño, fecha de modificación y hash SHA256 (con `certutil` o .NET).
  2. Ejecutar `audit_verify.ps1` y confirmar que pasa (OK).
  3. Extraer el último `entry_hash` del archivo actual **sin usar `Get-Content -Tail`** (método prohibido).
  4. Archivar el log actual como `AUDIT_CHAIN_ARCHIVE_YYYYMMDD_HHMMSS.jsonl` y sellarlo con `certutil -hashfile`.
  5. Crear un nuevo archivo `AUDIT_CHAIN.jsonl` que comience con un registro `ROTATION_ANCHOR`. Este registro debe tener un campo `prev_hash` que sea exactamente el `entry_hash` extraído en el paso 3.
  6. Ejecutar `audit_verify.ps1` sobre el nuevo archivo y validar que el resultado es OK.

  **Método Oficial (CORREGIDO)**:
- Snapshot: size/mtime/hash + audit_verify.ps1 OK.
- Extracción del Hash: Para obtener el last_entry_hash sin usar el comando prohibido Tail, se debe abrir un FileStream de .NET en modo lectura, posicionar el puntero al final y retroceder por bloques hasta identificar el último carácter de nueva línea (\n), extrayendo así la última entrada de forma eficiente.
- Archivar con certutil SHA256.
- El nuevo log inicia con ROTATION_ANCHOR (prev_hash = hash extraído).

- **Prohibido**:
  - Usar `Get-FileHash` o `Get-Content -Tail` en cualquier lógica de rotación o verificación de auditoría.
  - Rotar sin necesidad (archivo pequeño).
  - Perder el archivo original sin sellarlo (calcular y guardar su hash).
  - Generar el nuevo log sin el ancla criptográfica al anterior.

---

## 3. Escritura y Despliegue de Documentos (DEPLOY-SAFETY)

- **Regla de escritura**: Usar `cmd` con `type nul >` para crear/sobrescribir y `echo >>` para añadir, **siempre en pasos separados**.
  - **NO** usar bloques `( ... )` de `cmd`.
  - **NO** usar here-strings pegadas directamente desde PowerShell.
- **Límites por bloque**: Máximo **100 líneas** o **8 KB**.
- **Sanitización**: Antes de usar `echo`, verificar la ausencia de caracteres especiales como `^`, `%`, `&` que puedan ser interpretados por `cmd`.
- **Atomicidad**: Seguir el flujo obligatorio: `Propose` → `Diff` → `Apply` → `Verify`.
- **Verificación post-escritura**: Calcular y registrar el hash SHA256 con `certutil -hashfile`.

**Detalle Técnico (Escapes)**: Al generar scripts desde un operador, todas las variables internas (ej: $src, $dest) deben escaparse con el acento grave (`$) para evitar que el intérprete las expanda antes de que lleguen al archivo destino.
**Límites**: Máximo 100 líneas / 8KB. Prohibido el uso de paréntesis ( ) en bloques de comandos.
---

## 4. Transferencia Determinista de Archivos (I/O)

### 4.1 Exportación a Descargas (Para revisión externa)
**Criterio de Integridad**: La transferencia de archivos (I/O) no es solo un movimiento de datos, es un acto de evidencia.
**Regla de Oro**: Ningún archivo se mueve de Downloads al repo sin un certutil -hashfile previo y posterior que coincida con el FREEZE_MANIFEST.json si el sistema está en estado congelado.
**Método .NET Obligatorio**:
``` powershell
  # Uso de acento grave para preservar variables en el despliegue
  [System.IO.File]::Copy((Resolve-Path `$srcRel).Path, `$dstAbs, `$true)
```

- **Objetivo**: Exportar un archivo crítico a la carpeta `Downloads` sin alterar su codificación ni contenido.
- **Método obligatorio**:
  `powershell
  cd C:\HUMANIA
  $srcRel = ".\ruta\relativa\al\archivo.ps1"
  $dstAbs = Join-Path $env:USERPROFILE "Downloads\NOMBRE_DESTINO_VERSIONADO.ps1"
  [System.IO.File]::Copy((Resolve-Path $srcRel).Path, $dstAbs, $true)
  Get-Item $dstAbs | Select Name, Length, LastWriteTime
  certutil -hashfile $dstAbs SHA256
  `
- **Prohibido**:
  - Usar `Out-File` o `Set-Content` para scripts críticos.
  - Reserializar o editar el archivo antes de calcular su hash.

### 4.2 Importación desde Descargas (Artefactos de ChatGPT)
- **Objetivo**: Mover un archivo descargado desde `Downloads` al repositorio sin alterarlo.
- **Método obligatorio**:
  `powershell
  cd C:\HUMANIA
  $src = "C:\Users\Alber2Pruebas\Downloads\NOMBRE_DESCARGADO.ext"
  $dest = ".\ruta\en\repo\NOMBRE_VERSIONADO.ext"
  if (!(Test-Path $src)) { throw "Archivo no encontrado: $src" }
  $destDir = Split-Path -Parent $dest
  New-Item -ItemType Directory -Force -Path $destDir | Out-Null
  [System.IO.File]::Move($src, (Resolve-Path $destDir).Path + "\" + (Split-Path $dest -Leaf))
  certutil -hashfile $dest SHA256
  `
- **Prohibido**:
  - Abrir o guardar el archivo con editores antes de calcular su hash.
  - Usar `Out-File` o `Set-Content` para reescribir scripts críticos.

---

## 5. Procedimiento de Congelación (FREEZE PROCEDURE)

### 5.1 Objetivo y Principios
- **Objetivo**: Producir un snapshot determinista y completamente auditado para declarar **HUMANIA v1.0** como "congelada" (infraestructura estable).
- **Principios**:
  - **Fail-closed**: Si alguna verificación (Gate) falla, el proceso de congelación se aborta.
  - **Evidencia desde el disco**: Todos los datos (tamaño, fecha, hash) se toman directamente del sistema de archivos.
  - **Artefactos deterministas**: Se generan con rutas y hashes explícitos.
  - **Ejecución controlada**: La acción de congelación debe estar permitida en `allowed_actions.txt`, ejecutarse vía el wrapper `humania_run.ps1` y quedar registrada en `AUDIT_CHAIN.jsonl`.

### 5.2 Entradas Canónicas (Inputs)
Todo freeze debe incluir la siguiente lista de archivos de `C:\HUMANIA`:
- `docs/context/CONTEXT_SUMMARY.md`
- `docs/context/STATUS_REPORT.md`
- `docs/contracts/DOCS_CONSTITUTION.txt`
- `docs/policies/EVENT_TYPE_REGISTRY.md`
- `docs/policies/ACTION_POLICY_MAP.json`
- `docs/policies/STATE_MACHINE_SPEC.md`
- `docs/schemas/SOLUTION_PROPOSAL_SCHEMA.json`
- `humania_run.ps1`
- `humania_guard.ps1`
- `audit_verify.ps1`
- `constitution_change.ps1`
- `allowed_actions.txt`
- `allowed_scripts.txt`
- `AUDIT_CHAIN.jsonl`

### 5.3 Salidas Deterministas (Outputs)
Se creará una nueva carpeta de snapshot:
`C:\HUMANIA\staging\FREEZE_SNAPSHOT_YYYYMMDD_HHMMSS\`

Que contendrá:
1. **`FREEZE_MANIFEST.json`**: Lista de todas las entradas con `path`, `sha256`, `bytes`, `last_write_time`. Incluye `freeze_id` (timestamp) y `operator` (usuario/host).
2. **`FREEZE_MANIFEST.sha256.txt`**: Hash SHA256 del manifiesto.
3. **`FREEZE_STATUS.txt`**: `PASS/FAIL` y códigos de razón deterministas.
4. *(Opcional)* Copias de los documentos canónicos, cuyos hashes deben coincidir con los del manifiesto.

### 5.4 Puertas Obligatorias (Gates)
- **Gate A — Integridad de auditoría**: `audit_verify.ps1` debe ejecutarse y devolver **OK**.
- **Gate B — Consistencia de allowlists**:
  - La acción de "freeze" debe estar listada en `allowed_actions.txt`.
  - Cualquier script utilizado debe estar en `allowed_scripts.txt`, aunque:
  No basta con que el script esté en allowed_scripts.txt. Se debe validar que el hash del script que se va a ejecutar coincida exactamente con el registrado en la última auditoría válida.
- **Gate C — Evidencia hash**:
  - Los SHA256 deben calcularse con método determinista (`certutil` o `[System.IO.File]`).
(Aclaración de Hashes):
Prohibido: Get-FileHash para la verificación de la cadena de auditoría (evita bloqueos de archivo).
Permitido/Obligatorio: certutil -hashfile o [System.IO.File] para generar la evidencia de los archivos estáticos del snapshot.

### 5.5 Registro en Auditoría
El proceso debe registrar en `AUDIT_CHAIN.jsonl`:
- `FREEZE_START` (con `freeze_id` y `target_version="v1.0"`)
- `FREEZE_MANIFEST_WRITTEN` (con `manifest_path` y `manifest_sha256`)
- `FREEZE_END` (con `PASS/FAIL` y `reason_codes`)

El freeze solo es válido si el evento `FREEZE_END` es `PASS`.

### 5.6 Prohibiciones Específicas
- Realizar un freeze manual sin artefactos ni registro de auditoría.
- Usar variables de tiempo sin validación contra el sistema de archivos.
- Cualquier acción fuera del wrapper, el guard o las allowlists.

---

## 6. Protocolo de Handover (Contractual)
El operador entrante debe verificar el estado de la AUDIT_CHAIN antes de cualquier acción. Si el último registro no es un ACTION_END o un ROTATION_ANCHOR válido, el sistema se considera "Corrupto" y se debe ejecutar audit_verify.ps1 antes de proceder.
### 6.1 Mensaje Canónico para un Nuevo Chat
Al iniciar un nuevo chat, se debe enviar el siguiente mensaje para garantizar la continuidad contractual:

`
Genera AHORA MISMO:
- docs/CONTEXT_SUMMARY.md (decisiones, avances, riesgos, pendientes)
- docs/STATUS_REPORT.md (estado operativo actual, incluye LEVEL_3)
- docs/DOCS_CONSTITUTION.txt (constitución canónica consolidada)

Debes integrar explícitamente:
1) Todas las leyes vigentes en docs/LAWS (lista + hashes).
2) Todos los procedimientos en docs/PROCEDURES (lista + hashes).
3) Registro de lecciones en docs/LESSONS (última entrada).
4) Estado de AUDIT_CHAIN.jsonl (size, última escritura, riesgos).
5) Restricciones activas (ej: NO Get-FileHash; NO Get-Content -Tail en audit; métodos deterministas).

Requisitos: sin emojis, sin contradicciones, sin suposiciones; si hay fricción normativa, señalarla antes de consolidar.
`

### 6.2 Condiciones de Entrega
- Máximo **100 líneas** o **8 KB**.
- No usar continuaciones pegadas desde PowerShell.
- No usar bloques `cmd ( ... )`.
- Verificar cualquier archivo escrito con `certutil -hashfile`.

---

## 7. Contrato del Operador LLM (LLM_OPERATOR_CONTRACT)

### 7.1 Criterios de Aceptación de Instrucciones
Una instrucción es aceptable **solo si**:
- Es ejecutable tal cual se presenta.
- Está dentro de las acciones/scripts permitidos (allowlist).
- Incluye pasos de verificación explícitos.
- No intenta omitir el wrapper (`humania_run.ps1`) ni el guard (`humania_guard.ps1`).

Si algún criterio falla, el operador debe **DETENERSE** y solicitar la evidencia faltante.

### 7.2 Invariantes del Sistema (Basados en FREEZE_CRITERIA)
Estas condiciones definen el estado "congelado" y deben cumplirse siempre:

1.  **Punto de entrada único**: Todo comando o script debe ejecutarse a través de `humania_run.ps1`. Prohibida la ejecución directa.
2.  **Invarianza del Guard**:
    - `humania_guard.ps1` debe aplicar la allowlist de forma estricta (fail-closed).
    - Solo se permite ejecutar `powershell.exe -File` con rutas bajo `C:\HUMANIA`.
    - Cualquier comando no permitido debe ser bloqueado con un mensaje de razón explícito.
3.  **Cadena de Auditoría Inmutable**:
    - `AUDIT_CHAIN.jsonl` es de solo adición (append-only).
    - `audit_verify.ps1` debe verificar la cadena de hashes de forma determinista, y tiene prohibido usar `Get-FileHash` o `Get-Content -Tail`.
4.  **Limitación de Salida (Output Bounding)**:
    - `stdout` y `stderr` deben estar separados.
    - Se debe proporcionar una vista previa acotada de la salida.
    - La salida completa debe persistirse en `logs\outputs`.
    - La auditoría debe registrar: `output_path`, `output_sha256`, `output_preview`, `output_truncated`, y `bytes`.
5.  **Manejo de Interrupciones**: Si existe un evento `ACTION_START` rezagado por una interrupción, se tolera solo si es el último evento del log. La política (WARN vs FAIL) debe estar explícitamente definida y ser estable.

---

## 8. Prohibiciones Generales Consolidadas

- **Generación de scripts**: No generar scripts grandes con `echo` en `cmd` ni usar bloques con paréntesis `( ... )`.
- **Codificación**: No usar Base64 manualmente en el chat o terminal (riesgo de truncado).
- **Cmdlets prohibidos en operativa crítica**:
  - `Get-FileHash`en lógica de auditoría.
  - `Get-Content -Tail`
  - `Out-File`
  - `Set-Content` (para scripts core/críticos)
- **Rotación de auditoría**: No rotar sin motivo justificado (tamaño/tiempo).
- **Freeze**: No realizar un freeze manual sin los artefactos y registros requeridos.
- **Edición directa**: No editar archivos canónicos sin seguir el flujo de gobernanza.NO Ediciones directas sin flujo Propose -> Diff -> Apply.
- **Omisión de seguridad**: No omitir el wrapper, el guard o las allowlists bajo ninguna circunstancia.
