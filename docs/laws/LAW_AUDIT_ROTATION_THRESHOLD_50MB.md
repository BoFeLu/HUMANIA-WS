# LEY N3: CONTROL DE VOLUMETRÍA Y PREVENCIÓN DE ENTROPÍA FÍSICA
## ESTADO: VIGENTE | VERSIÓN: 2.0 (Anti-Monstruos)

### 1. UMBRAL DE AUDITORÍA (AUDIT_CHAIN)
- **Límite de Alerta:** 50 MB.
- **Acción:** Al superar 50 MB, el sistema DEBE proponer un procedimiento de rotación (N5).
- **Hard Limit:** 100 MB. El sistema se negará a escribir en la cadena de auditoría sin un "Freeze" previo.

### 2. PROTOCOLO ANTI-MONSTRUO (SISTEMA DE CHIVATOS)
- **Umbral Crítico de Archivo:** 500 MB (Cualquier archivo en C:\HUMANIA).
- **Mecanismo de Alerta:** El humania_guard.ps1 realizará un escaneo de volumen en cada ciclo.
- **Acción de Bloqueo:** Si un archivo supera los 500 MB o crece más de 100 MB en una sola sesión, saltará la **ALERTA DE ENTROPÍA DESMESURADA**.
- **Excepción:** Solo el Capitán puede autorizar archivos de mayor tamaño mediante un 'Override' documentado.

### 3. PRESERVACIÓN DEL RIGOR
Queda prohibido el uso de métodos de escritura que no verifiquen el tamaño del output antes de confirmar la persistencia.
