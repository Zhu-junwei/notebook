@echo off
dir Z:
if %errorlevel% == 0 goto chenggong
if %errorlevel% == 1 goto shibai

:chenggong
echo ִ�гɹ�
goto byebye

:shibai
echo ִ��ʧ��
goto byebye

:byebye
echo See you.
ping -n 2 127.0.0.1>nul
pause