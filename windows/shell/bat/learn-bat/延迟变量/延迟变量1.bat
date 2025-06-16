@echo off 
set a=4 
:: 下面这一行，%a%在预处理的时候赋值为4
set a=5 & echo %a% 

:: 开启延迟后，执行的时候才会赋值 
setlocal enabledelayedexpansion 
set a=4 
:: 这里的值是5
set a=5 & echo !a! 
endlocal
pause 