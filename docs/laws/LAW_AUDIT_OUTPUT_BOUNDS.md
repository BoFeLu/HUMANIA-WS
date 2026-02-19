# LAW: Audit Output Bounding + Safe Reading (LEVEL_3)

## Motivo
AUDIT_CHAIN.jsonl puede contener líneas gigantes (pocas entradas con output masivo), causando cuelgues y degradación.

## Reglas (OBLIGATORIAS)
1) Prohibido leer AUDIT_CHAIN.jsonl con `Get-Content` (incl. `-Tail`) hasta estabilizar:
   - Solo lectura por streaming binario/StreamReader y herramientas de “tail” controladas.
2) Prohibido registrar `output` sin límite en el audit.
   - Objetivo: cap duro (p.ej. 4 KB) y truncado explícito.
3) Si `output` excede el cap:
   - Volcar salida completa a `logs/outputs/<run_id>.txt`
   - Guardar en el audit: `output_truncated=true`, `output_sha256`, `output_path`, `output_bytes`.
4) Prohibido serializar “dumps” (módulos, env completo, listas enormes) dentro de audit entries.

## Cumplimiento
- Cualquier cambio estructural se implementa vía `constitution_change.ps1` (propose→diff→apply), con hashes verificados.
