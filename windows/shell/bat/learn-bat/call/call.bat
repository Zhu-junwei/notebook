@echo off
echo 主脚本开始！
call :mySub 5 10
echo 返回主脚本！
pause
exit /b

:mySub
echo 这是子程序！
set /a result=%1 + %2
echo 计算结果：%result%
exit /b