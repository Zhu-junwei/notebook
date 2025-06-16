@echo off & chcp 65001>nul
set "str= he llo "
:: 去掉空格 %变量名:旧字符串=新字符串%
set "str=%str: =%"
echo %str%
call :sub1 "hello"
pause & exit

:sub1 
:: 输出结果 "hello"
echo %1
:: 输出结果 hello
echo %~1
set a=%~1
echo %a%