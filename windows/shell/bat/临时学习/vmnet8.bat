@echo off
::获取管理员权限
%1 mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd.exe","/c %~s0 ::","","runas",1)(window.close)&&exit cd /d "%~dp0"

:start
mode con cols=55 lines=10
title VMnet8网络设置
echo ************************************************
echo  1.重启    2.禁用    3.启用  4.退出
echo ************************************************
echo.
set /p option=请输入你的选择:
echo.
if "%option%"=="1" (
netsh interface set interface name="VMware Network Adapter VMnet8" admin=DISABLED
netsh interface set interface name="VMware Network Adapter VMnet8" admin=ENABLED
) 
if "%option%"=="2" netsh interface set interface name="VMware Network Adapter VMnet8" admin=DISABLED
if "%option%"=="3" netsh interface set interface name="VMware Network Adapter VMnet8" admin=ENABLED
if "%option%"=="4" goto byebye
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