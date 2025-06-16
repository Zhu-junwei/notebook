@echo off & chcp 65001>nul
:: 打印指定目录下的
:: for /r "C:\Windows\System32\drivers" %%i in (*) do echo %%i
:: 不指定目录默认是脚本所在目录 ，所有文件，包括子目录 
for /r %%i in (*) do echo %%i
:: 列出目录所有文件，包括子目录 
:: /ad → 只列目录
:: /s → 递归所有子目录
:: /b → 简洁格式（只输出文件名或目录名，不带其他信息） 
for /f "delims=" %%i in ('dir /ad /b /s "%~dp0"') do echo %%i
echo *************
:: 查看指定目录及其目录下的所有exe文件
::for /r "C:\Windows\System32\" %%i in (*.exe) do echo %%i
echo *************
:: 找具体文件的时候需要再判断再判断一下文件是否存在 
for /r "C:\Windows\System32\" %%i in (hosts) do if exist %%i echo %%i
pause