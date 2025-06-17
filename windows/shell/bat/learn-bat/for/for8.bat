@echo off & chcp 65001>nul

:: skip=n 忽略（屏蔽、隐藏）文本前N行的内容。（N不能等于0，N必须大于0） 
echo -------------不使用skip-----------------
for /f "usebackq delims=" %%i in ("%SystemRoot%\System32\drivers\etc\hosts") do (
    echo %%i
)
echo -------------使用skip-----------------
for /f "usebackq skip=5 delims=" %%i in ("%SystemRoot%\System32\drivers\etc\hosts") do (
    echo %%i
)

pause