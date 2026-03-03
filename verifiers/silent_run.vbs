Option Explicit
Dim sh, fso, ts, logPath, rcPath, arg0, cmdline, rc

logPath = "C:\HUMANIA\logs\evidence\silent_run_arglog.txt"
rcPath  = "C:\HUMANIA\logs\evidence\silent_run_last_exitcode.txt"

Set fso = CreateObject("Scripting.FileSystemObject")

' Log (append)
Set ts = fso.OpenTextFile(logPath, 8, True)
ts.WriteLine "----- " & Now & " -----"
If WScript.Arguments.Count > 0 Then
  arg0 = WScript.Arguments(0)
  ts.WriteLine "ARG0_BEGIN"
  ts.WriteLine arg0
  ts.WriteLine "ARG0_END"
Else
  ts.WriteLine "NO_ARGS"
End If
ts.Close

If WScript.Arguments.Count = 0 Then WScript.Quit 87 ' invalid parameter

Set sh = CreateObject("WScript.Shell")

' Ejecutar SIEMPRE vía cmd.exe /c para .cmd/.bat y quoting robusto
cmdline = "cmd.exe /c " & WScript.Arguments(0)

' bWaitOnReturn = True para capturar exitcode (y evitar tareas “colgadas”)
rc = sh.Run(cmdline, 0, True)

' Guardar exitcode (overwrite)
Set ts = fso.OpenTextFile(rcPath, 2, True) ' ForWriting=2
ts.WriteLine "time=" & Now
ts.WriteLine "exitcode=" & rc
ts.Close

Set sh = Nothing