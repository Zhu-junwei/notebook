@echo off 
:begin 
set /a var+=1 
echo %var% 
:: leq 小于等于 
if %var% leq 3 goto begin 
pause