@echo off
dir Z:
if %errorlevel% == 0 goto chenggong
if %errorlevel% == 1 goto shibai

:chenggong
echo 执行成功
goto byebye

:shibai
echo 执行失败
goto byebye

:byebye
echo See you.
ping -n 2 127.0.0.1>nul
pause