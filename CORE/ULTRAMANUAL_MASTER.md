# ULTRAHUMANIA - MANUAL OPERATIVO MAESTRO (v2026.1)
**Estado de Integridad:** VERIFICADO (BOM-OK, DB-CONNECTED)
**Base de Datos SSoT:** ultrahumania (PostgreSQL)
**Fecha de Consolidación:** 2026-03-02

## 1. PRINCIPIOS CONSTITUCIONALES (Sync DB)
* [ID-17] Evidence-Gated: Avance basado en pruebas.
* [ID-18] BOM-Invariant: Integridad de scripts .ps1.
* [ID-19] Stop-Rule: Detención ante errores críticos.

## 2. RESOLUCIÓN DE INCIDENCIAS (KB-SYNC)
### [INC-001] Desalineación de Esquema de Base de Datos
* **Síntoma**: Error de columna inexistente durante inyección SQL.
* **Proceso**: Auditoría de metadatos -> Descubrimiento de SSoT -> Re-escritura determinista.
* **Lección**: Jamás suponer nombres de campos; validar siempre contra information_schema.

## 3. PERSISTENCIA Y MONITORIZACIÓN
* **Sustituto Rust**: Preparado para reemplazar WinSW como guardian.exe.
* **Objetivo**: Monitorización de heartbeat.txt y auto-reinicio de humania_run.ps1.

## 5. PROTOCOLOS DE RECUPERACIÓN Y MANTENIMIENTO
### 5.1 Gestión del Guardián (Rust)
* **Estado Operativo**: El proceso guardian.exe debe figurar siempre en el Task Manager.
* **Comando de Verificación**: `Get-Process guardian`
* **Procedimiento de Parada**: Para realizar mantenimiento manual sin que el Guardián reinicie el sistema, se debe matar primero al Guardián: `Stop-Process -Name guardian -Force`.

### 5.2 Análisis de Logs de Caída
* Si el sistema se reinicia, consultar la tabla kb.solutions para buscar el hash de evidencia del último fallo.
* Los errores críticos de Rust se redirigen al Event Viewer de Windows (UH_Guardian Source).

## 6. MAPA DE INFRAESTRUCTURA ACTUALIZADO
* **BIN**: Contiene los binarios críticos (guardian.exe, psql.exe).
* **CORE**: Contiene la lógica maestra y el UltraManual.
* **DB**: SSoT (Single Source of Truth) en PostgreSQL (DB: ultrahumania).
