@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "C:\HUMANIA\sentinel\sentinel_tick_new.ps1"
exit /b %ERRORLEVEL%
