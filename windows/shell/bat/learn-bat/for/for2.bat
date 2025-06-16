@echo off & chcp 65001>nul
:: 打印指定目录下的所有文件夹,不包括子目录 
for /d %%i in ("C:\*") do echo %%i
echo **************
:: 打印指定目录下的所有文件，不包含子目录 
for %%i in ("C:\*") do echo %%i
pause