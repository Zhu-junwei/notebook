@echo off & chcp 65001>nul
setlocal enabledelayedexpansion

rem 示例：检查 winget 
call :CheckCommand winget
if "!CMD_FOUND!"=="1" (
    echo winget 已安装  
) else (
    echo winget 未安装  
)

rem 示例：检查 git 
call :CheckCommand git1
if "!CMD_FOUND!"=="1" (
    echo git 已安装 
) else (
    echo git 未安装 
)

pause

:CheckCommand
rem 用法：call :CheckCommand 命令名 
rem 返回值存储在 CMD_FOUND 中，1 表示存在，0 表示不存在 

set "CMD_FOUND=0"
where %1 >nul 2>&1
if %errorlevel%==0 (
    set "CMD_FOUND=1"
)
exit /b
pause
