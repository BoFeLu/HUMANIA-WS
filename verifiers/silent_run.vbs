Set WinScriptHost = CreateObject("WScript.Shell")
' Ejecuta el comando (Argumento 0) con estilo de ventana 0 (oculto)
WinScriptHost.Run Chr(34) & WScript.Arguments(0) & Chr(34), 0
Set WinScriptHost = Nothing
