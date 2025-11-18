@echo off
::获取管理员权限
net session >nul 2>&1 || powershell -NoP -C "Start-Process -FilePath '%~f0' -Verb RunAs" && exit

:start
mode con cols=55 lines=20
title PostgreSQL小工具
echo ***************************************************
echo  1.开启PostgreSQL   2.关闭PostgreSQL    3.退出
echo ***************************************************
echo.
set /p option=请输入你的选择:
echo.
if "%option%"=="1" net start PostgreSQL
if "%option%"=="2" net stop PostgreSQL
if "%option%"=="3" goto byebye
:: 等待3S回到菜单
timeout /t 3
cls
set option=null
goto start

:byebye
echo See you.
ping -n 2 127.0.0.1>nul
exit
pause