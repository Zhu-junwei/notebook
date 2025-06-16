@echo off 
set sum=0 
call :sub  sum 1 2 3 4 5 6 7 8 9 10
echo 数据求和结果:%sum% 
pause>nul 
:sub 
echo %1 %2 
:: 在计算时会对%1参数进行展开 
set /a %1=%1+%2 
shift /2 
if not "%2"=="" goto sub 