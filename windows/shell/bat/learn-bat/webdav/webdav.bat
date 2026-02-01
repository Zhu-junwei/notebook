@echo off & chcp 65001 >nul & setlocal
%~1 start "" conhost "%~f0" "::" & exit
mode con cols=80 lines=40
title WebDAV 轻量服务器管理 
powershell -ExecutionPolicy Bypass -File "%~dp0webdav.ps1"
exit /b