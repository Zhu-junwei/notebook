@echo off & chcp 65001 >nul
setlocal enabledelayedexpansion

:: 配置目标文件和文件夹 
set "target=20250614_静谧之声.jpg"
set "folder=D:\systemfile\Pictures\BingWallpapers\"

:: 初始化  
set "prev="
set "found="
set "next="
set /a count=0
set "rand="

:: 一遍遍历，最新文件在前 
for /f "delims=" %%F in ('dir /b /a:-d /o:-d "%folder%\*"') do (
    set /a count+=1

    :: 动态随机选择（蓄水池采样，每个文件被选概率相等）
    set /a r=%random% %% !count!
    if !r! EQU 0 (
        set "rand=%%F"
    )

    :: 上/下文件逻辑 
    if not defined found (
        if /i "%%F"=="%target%" (
            set "found=1"
        ) else (
            set "prev=%%F"
        )
    ) else (
        if not defined next (
            set "next=%%F"
        )
    )
)

:: 补位 
if not defined rand set "rand=%target%"
if not defined prev set "prev=%target%"
if not defined next set "next=%target%"

:: 输出 
echo 上一个文件: %prev%
echo 当前文件: %target%
echo 下一个文件: %next%
echo 随机文件: %rand%
