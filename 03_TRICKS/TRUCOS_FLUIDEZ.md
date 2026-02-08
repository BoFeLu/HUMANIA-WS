# Trucos de fluidez (operativo)

## Reducir errores por copypaste truncado
- Preferir heredoc: cat <<'EOF' > file
- Preferir bloques cortos y deterministas.
- Guardar salidas en ficheros cuando importe la evidencia.

## Reducir carga de UI (chat)
- No pedir respuestas gigantes si no son necesarias.
- Evitar regeneraciones repetidas de mensajes largos.
- Cerrar chat al primer síntoma de lag y usar bundle.

## Estilo de trabajo recomendado
- 1 objetivo operacional por sesión.
- 1 bloque de comandos por mensaje (o 2 como máximo).
- Siempre: evidencia antes de cambiar.

## “Fuente única de verdad”
- STATUS_REPORT.md y CONTEXT_SUMMARY.md son los documentos guía.
- El chat no es un repositorio: solo un canal de ejecución.
