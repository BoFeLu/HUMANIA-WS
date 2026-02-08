# Procedimiento BUNDLE (cuando el chat ya se ralentiza)

Objetivo: continuidad perfecta entre chats sin depender del historial del chat.

## 1) En el chat viejo (orden de cierre)
Pedir generación inmediata de:
- CONTEXT_SUMMARY.md (decisiones, avances, riesgos, pendientes)
- STATUS_REPORT.md (estado operativo actual)
- DOCS_CONSTITUTION.txt (constitución canónica)

Requisitos:
- coherentes entre sí
- SIN EMOJIS
- descargables con botones

Además, STATUS_REPORT.md debe incluir una sección final (LEVEL_3) que:
- define snapshot de cierre de sesión
- contiene la orden explícita al operador
- fuerza ACK obligatorio del nuevo chat
- captura delta final y últimos 8 mensajes con valor
- avisa de chat ralentizado y conveniencia de cierre/cambio (decisión humana)

## 2) Descargar y mover a ShF (Windows)
Descargar los 3 archivos y moverlos a:
C:\Users\Alber2Pruebas\Desktop\ShF\

## 3) Copiar al repo (WSL)
Ejemplo (ajustar nombres timestamp):
cd /home/aiops_user/aiops_os_agent_remote || exit 1
set -euo pipefail

cp -v "/mnt/c/Users/Alber2Pruebas/Desktop/ShF/CONTEXT_SUMMARY_YYYYMMDD_HHMMSS.md" \
  docs/context/CONTEXT_SUMMARY.md

cp -v "/mnt/c/Users/Alber2Pruebas/Desktop/ShF/STATUS_REPORT_YYYYMMDD_HHMMSS.md" \
  docs/context/STATUS_REPORT.md

cp -v "/mnt/c/Users/Alber2Pruebas/Desktop/ShF/DOCS_CONSTITUTION_YYYYMMDD_HHMMSS.txt" \
  docs/context/DOCS_CONSTITUTION.txt

ls -lh docs/context/CONTEXT_SUMMARY.md docs/context/STATUS_REPORT.md docs/context/DOCS_CONSTITUTION.txt

## 4) Generar bundle
cd /home/aiops_user/aiops_os_agent_remote || exit 1
set -euo pipefail

bin/context-one

Salida esperada en Windows:
C:\Users\Alber2Pruebas\Desktop\ShF\AIOPS_BUNDLE_YYYYMMDD_HHMMSS.tar.gz

## 5) Abrir nuevo chat
Subir:
- AIOPS_CONTEXT_FULL_*.txt
- AIOPS_BUNDLE_*.tar.gz

Pegar ACK obligatorio + foco y prohibiciones (ver plantilla).
