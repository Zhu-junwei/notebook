@echo off & chcp 65001>nul
:: 打开记事本，并等待记事本关闭 
:: win11 测试的没有效果 
start /WAIT notepad.exe
echo Notepad closed
pause