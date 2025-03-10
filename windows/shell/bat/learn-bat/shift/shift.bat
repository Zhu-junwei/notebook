@echo off 
set sum=0 
call :sub  sum 1 2 3 4 5 6 7 8 9 
echo 数据求和结果:%sum% 
pause>nul 
:sub 
set /a %1=%1+%2 
shift /2 
if not "%2"=="" goto sub 