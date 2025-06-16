@echo off & chcp 65001>nul

call :sub
pause & exit

:sub
echo I'm sub.
:: %0指的是 :label标签, 这里是:sub
echo %0
exit /b