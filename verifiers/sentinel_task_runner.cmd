@echo off
setlocal enableextensions

set LOGDIR=C:\HUMANIA\logs\evidence\sentinel_task
set PS=C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
set SCRIPT=C:\HUMANIA\sentinel\sentinel_tick_new.ps1

if not exist "%LOGDIR%" mkdir "%LOGDIR%"

rem Mark: started (always)
echo START %DATE% %TIME% > "%LOGDIR%\runner_started.txt"

rem Build TS from DATE/TIME (locale-agnostic-ish: remove separators/spaces)
set TS=%DATE%_%TIME%
set TS=%TS:/=%
set TS=%TS::=%
set TS=%TS:.=%
set TS=%TS:,=%
set TS=%TS: =%
if "%TS%"=="" set TS=NO_TS

set OUT=%LOGDIR%\stdout_%TS%.txt
set ERR=%LOGDIR%\stderr_%TS%.txt

"%PS%" -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%" 1>"%OUT%" 2>"%ERR%"
set RC=%ERRORLEVEL%

echo exitcode=%RC% > "%LOGDIR%\runner_exitcode.txt"
echo DONE %DATE% %TIME% > "%LOGDIR%\runner_done.txt"

exit /b %RC%
