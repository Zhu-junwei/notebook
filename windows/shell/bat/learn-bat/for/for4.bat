@echo off & chcp 65001>nul
:: 打印指定目录下的 
:: 从start 开始，以step为步长，直至最接近end那个整数为止 
for /l %%i in (1,1,5) do echo %%i
for /l %%i in (5,-1,1) do echo %%i
pause