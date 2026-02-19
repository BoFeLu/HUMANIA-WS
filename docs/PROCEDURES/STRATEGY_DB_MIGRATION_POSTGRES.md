# ESTRATEGIA DE DATOS Y MIGRACIÓN POSTGRESQL (N5)
**OBJETIVO:** Transición de repositorio plano a Base de Datos Relacional de Conocimiento.

## 1. TAXONOMÍA DE FILTRADO (PRINCIPIO DE VALOR)
Para garantizar la excelencia, no todo byte será migrado. Se aplicará el siguiente criterio:
- **Nivel 1 (CRÍTICO):** Migración prioritaria. Documentación legal, procedimientos vivos y soluciones técnicas verificadas.
- **Nivel 2 (REFERENCIAL):** Migración diferida. Contexto histórico y contratos marco.
- **Nivel 3 (OBSOLETO):** Descarte. Redundancias y borradores superados (Permanecen en VITAL_FUNDACIONAL).

## 2. ARQUITECTURA DEL ESQUEMA (DRAFT V1)
- **KNOWLEDGE_BASE:** Tabla para soluciones técnicas indexadas.
- **LEGAL_CORPUS:** Tabla para leyes e invariantes con control de versiones.
- **AUDIT_TRAIL:** Registro inmutable de cambios para cumplimiento normativo.

## 3. PROTOCOLO DE CARGA SEGURO (ETL)
- **Limpieza:** Los scripts de PowerShell deben normalizar el texto a UTF-8 y eliminar caracteres de control.
- **Validación:** Uso de SHA256 para asegurar que el dato en SQL es idéntico al archivo .md original.
