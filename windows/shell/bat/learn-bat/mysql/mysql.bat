@echo off & setlocal enabledelayedexpansion
::获取管理员权限
net session >nul 2>&1 || powershell -NoP -C "Start-Process -FilePath '%~f0' -Verb RunAs" && exit

title mysql小工具
:start
cls
mode con cols=55 lines=20
echo *******************************************************
echo     1.开启mysql    2.关闭mysql    3.登录    4.退出  
echo *******************************************************
echo.
set "option="
set /p option=请输入你的选择:
echo.
if "%option%"=="1" net start mysql
if "%option%"=="2" net stop mysql
if "%option%"=="3" (
	mode con cols=120 lines=60
	title mysql commond
	set /p "user=请输入用户名(默认root): "
    if "!user!"=="" set "user=root"
    mysql -u!user! -p --prompt="\u@\h \d>"
)
if "%option%"=="4" goto byebye
goto start

:byebye
echo See you.
ping -n 2 127.0.0.1>nul
exit
pause