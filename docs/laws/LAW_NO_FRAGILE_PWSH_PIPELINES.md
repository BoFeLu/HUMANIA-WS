# LAW: NO FRAGILE PWSH PIPELINES - LEVEL_3

## Reglas (OBLIGATORIAS)
1) Prohibido usar Get-FileHash en operativa. Usar: certutil -hashfile.
2) Prohibido usar here-strings largos en sesiones pwsh para generar docs criticos.
3) Para generar docs: usar cmd con redireccion a fichero.

## Motivo
Hemos observado cuelgues intermitentes de sesiones pwsh en operaciones triviales.
La via cmd+certutil es mas robusta en este entorno.
