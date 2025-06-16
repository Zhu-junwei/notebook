@echo off & chcp 65001>nul
set str=www.cn-dos.net 
set n=4 
set "result=%str:~%n%%"

:: 方法2：直接指定偏移量 
set "result=%str:~3%"

echo 方法1结果: %result%
echo 方法2结果: %result%
pause>nul 