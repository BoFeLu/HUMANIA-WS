# 📜 CONSTITUCIÓN DEL KERNEL HUMANIA (V4.0-GOLD)

Este directorio es un entorno de **Alta Integridad**. No es una carpeta de trabajo común.

## ⚖️ Leyes Invariantes
1. **Inmutabilidad:** Los archivos en \verifiers están blindados por ACL. No se deben modificar sin el Protocolo de Apertura Temporal.
2. **Integridad:** Cualquier cambio en el Kernel (humania_run, humania_guard, etc.) debe ser reflejado inmediatamente en el kernel_manifest.json.
3. **Validación:** No se permite la ejecución de acciones (excepto NOOP) si el self_diagnose.ps1 reporta un estado DEGRADED.
4. **Higiene:** La raíz debe permanecer limpia. Cualquier script nuevo debe nacer en \staging.

## 📂 Estructura Crítica
- humania_run.ps1: El motor de ejecución.
- humania_guard.ps1: El centinela de seguridad pre-vuelo.
- erifiers/: El búnker de lógica de validación.
- kernel_manifest.json: El ADN del sistema (Hashes SHA256).

## 🛠️ Protocolo de Emergencia
Si el sistema reporta DEGRADED:
1. Ejecutar powershell -File .\verifiers\self_diagnose.ps1.
2. Identificar el archivo corrupto o modificado.
3. Reconciliar el ADN usando el script de sincronización.

## 🛡️ CAPA 3: AUTO-REMEDIACIÓN (HEALING ENGINE)
**HUMANIA** posee la capacidad de restaurar su propio ADN técnico si detecta corrupción o pérdida de archivos críticos.

### 1. La Bóveda (The Vault)
Ubicada en \verifiers\vault, contiene copias maestras del Kernel GOLD. Esta carpeta está blindada por ACL y solo es accesible mediante el Protocolo de Apertura.

### 2. Protocolo de Resurrección
- **Trigger:** Si self_diagnose.ps1 reporta estado **DEGRADED**.
- **Acción:** Ejecutar powershell -File .\verifiers\humania_heal.ps1.
- **Mecánica:** El Cirujano compara el hash SHA256 de los archivos vivos contra el kernel_manifest.json. Si hay discrepancia o ausencia, sobreescribe el archivo usando la copia de la Bóveda.

> **NOTA:** El éxito de la Capa 3 depende de la integridad del Manifiesto. Si el Manifiesto es alterado, se debe recurrir a la **Capa 5 (Exportación Externa)**.
