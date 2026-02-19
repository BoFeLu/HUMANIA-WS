# LEY N3: NORMA MAESTRA DE INTERCAMBIO Y TRANSFERENCIA DE ARTEFACTOS
## ESTADO: VIGENTE | VERSIÓN: 1.0 | AUTORIDAD: MÁXIMA

### 1. PRINCIPIO DE DETERMINISMO (Ex-LAW-IO-002)
Toda entrega de artefactos debe ser determinista. Se prohíbe el uso de métodos de "copy-paste" para bloques superiores a 100 líneas. El sistema debe proponer un archivo descargable.

### 2. PROTOCOLO DE TRANSFERENCIA NIVEL 3 (Ex-LAW_LEVEL_3_TRANSFER)
El flujo obligatorio para la entrada de datos es:
- **Descarga/Generación**: Creación del artefacto en origen.
- **Importación con Hash**: Verificación vía SHA256 antes de la persistencia.
- **Propose/Diff/Apply**: Comparación obligatoria de cambios antes de la escritura final.

### 3. CONTROL DE VOLUMETRÍA (Protocolo Anti-Monstruo)
Cualquier archivo que supere los 50MB debe ser fragmentado o gestionado bajo un canal de flujo validado para prevenir la corrupción de los logs de auditoría y el desbordamiento de memoria del sistema.

### 4. SELLADO DE INTEGRIDAD
Al finalizar cada sesión de transferencia masiva, se debe emitir un manifiesto de integridad (Hash Seal) sobre la carpeta de destino.
