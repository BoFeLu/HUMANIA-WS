@echo off
setlocal
echo START> "C:\HUMANIA\logs\evidence\B_start.txt"
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -NonInteractive -Command "[System.IO.File]::WriteAllText('C:\HUMANIA\logs\evidence\B_ps_ran.txt','PS_RAN')"
echo END> "C:\HUMANIA\logs\evidence\B_end.txt"
exit /b %ERRORLEVEL%
