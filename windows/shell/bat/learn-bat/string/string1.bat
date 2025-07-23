@echo off & chcp 65001>nul
set "str=hello"
:: 字符串截取 ~0,-1 第0个到倒数第2个字符（即去掉最后一个字符） 
:: hell
set "str1=%str:~0,-1%"
echo %str1%
set "str2=%str:~0,2%"
echo %str2%
:: 字符串截取 ~1 第1个到最后 
:: ello
set "str3=%str:~1%"
echo %str3%
pause