Set objShell = CreateObject("WScript.Shell")
command = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File ""C:\HUMANIA\sentinel\sentinel_tick_new.ps1"" > ""C:\HUMANIA\logs\evidence\vbs_debug.txt"" 2>&1"
objShell.Run command, 0, True