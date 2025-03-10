@echo off
::获取管理员权限
%1 mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd.exe","/c %~s0 ::","","runas",1)(window.close)&&exit cd /d "%~dp0"

:start
mode con cols=55 lines=20
title mysql小工具
echo ************************************************
echo  1.开启mysql    2.关闭mysql    3.登录    4.退出  
echo ************************************************
echo.
set /p option=请输入你的选择:
echo.
if "%option%"=="1" net start mysql
if "%option%"=="2" net stop mysql
if "%option%"=="3" (
mode con cols=120 lines=60
title mysql commond
mysql -uroot -p --prompt="\u@\h \d>"
)
if "%option%"=="4" goto byebye
:: 等待5S回到菜单
timeout /t 5
cls
set option=null
goto start

:byebye
echo See you.
ping -n 2 127.0.0.1>nul
exit
pause