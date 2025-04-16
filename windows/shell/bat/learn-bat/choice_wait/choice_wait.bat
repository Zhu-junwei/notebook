@echo off & setlocal enabledelayedexpansion
chcp 65001 > nul 

set "count=30"

:loop
cls
echo.
echo ----------------------------------------------------------
echo  输入数字【1】执行下一步操作
echo ----------------------------------------------------------
echo  输入数字【2】不执行下一步操作
echo ----------------------------------------------------------
echo.
echo. & choice /C 120 /N /T 1 /D 0 /M "请选择【 !count! 秒后默认结束不恢复旧书签】："

set /a "count-=1"

if "!errorlevel!" equ "1" (echo 1 & goto :end)
if "!errorlevel!" equ "2" (echo 2 & goto :end)
if !count! gtr 0 (goto :loop) else (echo 3 & goto :end)

:end

echo end
pause