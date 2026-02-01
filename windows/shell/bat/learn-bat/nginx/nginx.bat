@echo off & chcp 65001 >nul & setlocal
%~1 start "" conhost "%~f0" "::" & exit
mode con cols=80 lines=40
title Nginx 管理工具 
powershell -ExecutionPolicy Bypass -File "%~dp0nginx.ps1"
exit /b