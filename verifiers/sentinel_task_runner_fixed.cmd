@echo off
setlocal enableextensions
set LOGDIR=C:\HUMANIA\logs\evidence\sentinel_task
set PS=C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
set SCRIPT=C:\HUMANIA\sentinel\sentinel_tick_new.ps1

if not exist "%LOGDIR%" mkdir "%LOGDIR%"

echo START %DATE% %TIME% > "%LOGDIR%\runner_started.txt"

"%PS%" -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%" 1> "%LOGDIR%\stdout.txt" 2> "%LOGDIR%\stderr.txt"
set RC=%ERRORLEVEL%

echo exitcode=%RC% > "%LOGDIR%\runner_exitcode.txt"
echo DONE %DATE% %TIME% > "%LOGDIR%\runner_done.txt"

exit /b %RC%
